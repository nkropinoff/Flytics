from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
import psycopg2
import clickhouse_connect

PG_CONFIG = {
    'host': 'host.docker.internal',
    'port': 54322,
    'dbname': 'flytics',
    'user': 'postgres',
    'password': 'postgres'
}

CH_CONFIG = {
    'host': 'clickhouse',
    'port': 8123,
    'username': 'default',
    'password': 'password',
    'database': 'default'
}

default_args = {
    'owner': 'student',
    'depends_on_past': False,
    'start_date': datetime(2026, 6, 1),
    'retries': 1,
}


def create_clickhouse_tables(**context):
    ch = clickhouse_connect.get_client(**CH_CONFIG)

    ch.command("""
        CREATE TABLE IF NOT EXISTS airline (
            iata_code String,
            name String
        ) ENGINE = MergeTree()
        ORDER BY iata_code
    """)

    ch.command("""
        CREATE TABLE IF NOT EXISTS flight (
            id UInt32,
            flight_number String,
            aircraft_id UInt32,
            departure_time DateTime64(0, 'UTC'),
            arrival_time DateTime64(0, 'UTC'),
            status_id UInt32,
            flight_tags Array(String),
            actual_departure Nullable(DateTime64(0, 'UTC'))
        ) ENGINE = MergeTree()
        ORDER BY (departure_time, id)
    """)

    ch.command("""
        CREATE TABLE IF NOT EXISTS booking (
            id UInt32,
            client_id UInt32,
            booking_date DateTime64(0, 'UTC'),
            total_cost UInt32,
            status_id UInt32,
            channel String
        ) ENGINE = MergeTree()
        ORDER BY (booking_date, id)
    """)

    ch.close()
    print("ClickHouse tables created (if not exists)")


def load_to_clickhouse(**context):
    pg = psycopg2.connect(**PG_CONFIG)
    pg_cur = pg.cursor()
    ch = clickhouse_connect.get_client(**CH_CONFIG)

    # --- airline ---
    pg_cur.execute("SELECT iata_code, name FROM airline")
    rows = pg_cur.fetchall()
    if rows:
        ch.insert('airline', rows, column_names=['iata_code', 'name'])
        print(f"Loaded {len(rows)} rows into ClickHouse airline")

    # --- flight ---
    pg_cur.execute(
        "SELECT id, flight_number, aircraft_id, departure_time, "
        "arrival_time, status_id, flight_tags, actual_departure FROM flight"
    )
    rows = pg_cur.fetchall()
    if rows:
        clean = []
        for r in rows:
            clean.append((
                r[0], r[1], r[2], r[3], r[4], r[5],
                r[6] if r[6] else [],   # NULL → []
                r[7]                     # actual_departure (Nullable)
            ))
        ch.insert('flight', clean, column_names=[
            'id', 'flight_number', 'aircraft_id', 'departure_time',
            'arrival_time', 'status_id', 'flight_tags', 'actual_departure'
        ])
        print(f"Loaded {len(clean)} rows into ClickHouse flight")

    # --- booking ---
    pg_cur.execute(
        "SELECT id, client_id, booking_date, total_cost, status_id, channel FROM booking"
    )
    rows = pg_cur.fetchall()
    if rows:
        clean = []
        for r in rows:
            clean.append((
                r[0], r[1], r[2], r[3], r[4],
                r[5] if r[5] else ''    # NULL → ''
            ))
        ch.insert('booking', clean, column_names=[
            'id', 'client_id', 'booking_date', 'total_cost', 'status_id', 'channel'
        ])
        print(f"Loaded {len(clean)} rows into ClickHouse booking")

    pg_cur.close()
    pg.close()
    ch.close()
    print("Data loaded from PostgreSQL to ClickHouse")


def build_datamart(**context):
    ch = clickhouse_connect.get_client(**CH_CONFIG)

    ch.command("""
        CREATE TABLE IF NOT EXISTS daily_flight_stats (
            date Date,
            airline_iata String,
            flights_count UInt32,
            unique_routes UInt32
        ) ENGINE = SummingMergeTree()
        ORDER BY (date, airline_iata)
    """)

    ch.command("TRUNCATE TABLE daily_flight_stats")

    pg = psycopg2.connect(**PG_CONFIG)
    pg_cur = pg.cursor()
    pg_cur.execute("SELECT id, airline_iata_code FROM aircraft")
    aircraft_map = {row[0]: row[1] for row in pg_cur.fetchall()}

    pg_cur.execute(
        "SELECT departure_time::date, aircraft_id, flight_number FROM flight"
    )
    rows = pg_cur.fetchall()
    pg_cur.close()
    pg.close()

    from collections import defaultdict
    stats = defaultdict(lambda: {'flights': 0, 'routes': set()})

    for date_val, ac_id, route in rows:
        airline = aircraft_map.get(ac_id, 'UNKNOWN')
        key = (date_val, airline)
        stats[key]['flights'] += 1
        stats[key]['routes'].add(route)

    data = []
    for (date_val, airline), val in stats.items():
        data.append([
            date_val,
            airline,
            val['flights'],
            len(val['routes'])
        ])

    if data:
        ch.insert('daily_flight_stats', data, column_names=[
            'date', 'airline_iata', 'flights_count', 'unique_routes'
        ])
        print(f"Built datamart: {len(data)} rows in daily_flight_stats")

    ch.close()
    print("Analytics datamart built successfully")


def check_data_quality(**context):
    pg = psycopg2.connect(**PG_CONFIG)
    pg_cur = pg.cursor()
    ch = clickhouse_connect.get_client(**CH_CONFIG)

    for table in ['airline', 'flight', 'booking']:
        pg_cur.execute(f"SELECT count(*) FROM {table}")
        pg_count = pg_cur.fetchone()[0]
        ch_count = ch.query(f"SELECT count() FROM {table}").result_rows[0][0]
        status = "OK" if pg_count == ch_count else "MISMATCH"
        print(f"[{status}] {table}: PG={pg_count}, CH={ch_count}")

    pg_cur.close()
    pg.close()

    mart_rows = ch.query("SELECT count() FROM daily_flight_stats").result_rows[0][0]
    print(f"Datamart rows: {mart_rows}")
    if mart_rows == 0:
        raise ValueError("Datamart is empty — check source data")

    ch.close()
    print("Data quality check completed")


with DAG(
    dag_id='analytics_to_clickhouse',
    default_args=default_args,
    description='Analytics: load data from PostgreSQL to ClickHouse and build datamart',
    schedule_interval=None,
    catchup=False,
    tags=['analytics', 'clickhouse'],
) as dag:

    task_create_tables = PythonOperator(
        task_id='create_clickhouse_tables',
        python_callable=create_clickhouse_tables,
        provide_context=True,
    )

    task_load = PythonOperator(
        task_id='load_to_clickhouse',
        python_callable=load_to_clickhouse,
        provide_context=True,
    )

    task_datamart = PythonOperator(
        task_id='build_datamart',
        python_callable=build_datamart,
        provide_context=True,
    )

    task_check_quality = PythonOperator(
        task_id='check_data_quality',
        python_callable=check_data_quality,
        provide_context=True,
    )

    task_create_tables >> task_load >> task_datamart >> task_check_quality
