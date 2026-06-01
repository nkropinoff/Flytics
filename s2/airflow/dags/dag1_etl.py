from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
import csv
import json
import os
import psycopg2

DATA_DIR = '/opt/airflow/data'
PG_CONFIG = {
    'host': 'host.docker.internal',
    'port': 54322,
    'dbname': 'flytics',
    'user': 'postgres',
    'password': 'postgres'
}

default_args = {
    'owner': 'student',
    'depends_on_past': False,
    'start_date': datetime(2026, 6, 1),
    'retries': 1,
}


def extract_csv(**context):
    filepath = os.path.join(DATA_DIR, 'airlines_new.csv')
    airlines = []
    with open(filepath, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            iata = row['iata_code'].strip().upper()
            name = row['name'].strip()
            if not iata or len(iata) < 2 or len(iata) > 3:
                raise ValueError(f"Invalid iata_code: '{iata}'")
            if not name:
                raise ValueError(f"Empty name for iata_code: '{iata}'")
            airlines.append({'iata_code': iata, 'name': name})
    if not airlines:
        raise ValueError("No valid airlines found in CSV")
    print(f"Extracted {len(airlines)} airlines from CSV")
    context['ti'].xcom_push(key='airlines', value=airlines)


def load_airlines(**context):
    airlines = context['ti'].xcom_pull(key='airlines', task_ids='extract_csv')
    conn = psycopg2.connect(**PG_CONFIG)
    cur = conn.cursor()
    loaded = 0
    for a in airlines:
        cur.execute(
            "INSERT INTO airline (iata_code, name) VALUES (%s, %s) "
            "ON CONFLICT (iata_code) DO UPDATE SET name = EXCLUDED.name",
            (a['iata_code'], a['name'])
        )
        loaded += 1
    conn.commit()
    cur.close()
    conn.close()
    print(f"Loaded/updated {loaded} airlines in PostgreSQL")


def extract_json(**context):
    filepath = os.path.join(DATA_DIR, 'flights_new.json')
    with open(filepath, 'r', encoding='utf-8') as f:
        flights = json.load(f)

    validated = []
    for fl in flights:
        if not fl.get('flight_number') or not fl.get('aircraft_id'):
            raise ValueError(f"Missing required fields in flight: {fl}")
        if fl['departure_time'] >= fl['arrival_time']:
            raise ValueError(
                f"departure_time >= arrival_time for flight {fl.get('id')}: "
                f"{fl['departure_time']} >= {fl['arrival_time']}"
            )
        validated.append(fl)

    if not validated:
        raise ValueError("No valid flights found in JSON")
    print(f"Extracted {len(validated)} flights from JSON")
    context['ti'].xcom_push(key='flights', value=validated)


def load_flights(**context):
    flights = context['ti'].xcom_pull(key='flights', task_ids='extract_json')
    conn = psycopg2.connect(**PG_CONFIG)
    cur = conn.cursor()

    # Проверка существования aircraft_id
    cur.execute("SELECT id FROM aircraft")
    existing_aircraft = {row[0] for row in cur.fetchall()}

    loaded = 0
    skipped = 0
    for fl in flights:
        if fl['aircraft_id'] not in existing_aircraft:
            print(f"Skipping flight {fl.get('id')}: aircraft_id {fl['aircraft_id']} not found")
            skipped += 1
            continue
        cur.execute(
            "INSERT INTO flight (id, flight_number, aircraft_id, departure_time, "
            "arrival_time, status_id, flight_tags, booking_window, actual_departure) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s) "
            "ON CONFLICT (id) DO NOTHING",
            (
                fl['id'],
                fl['flight_number'],
                fl['aircraft_id'],
                fl['departure_time'],
                fl['arrival_time'],
                fl['status_id'],
                fl.get('flight_tags', []),
                fl.get('booking_window'),
                fl.get('actual_departure')
            )
        )
        loaded += 1

    conn.commit()
    cur.close()
    conn.close()
    print(f"Loaded {loaded} flights into PostgreSQL, skipped {skipped} (bad aircraft_id)")


with DAG(
    dag_id='etl_load_external_data',
    default_args=default_args,
    description='ETL: load airlines (CSV) and flights (JSON) into PostgreSQL',
    schedule_interval=None,
    catchup=False,
    tags=['etl', 'postgres'],
) as dag:

    task_extract_csv = PythonOperator(
        task_id='extract_csv',
        python_callable=extract_csv,
        provide_context=True,
    )

    task_load_airlines = PythonOperator(
        task_id='load_airlines',
        python_callable=load_airlines,
        provide_context=True,
    )

    task_extract_json = PythonOperator(
        task_id='extract_json',
        python_callable=extract_json,
        provide_context=True,
    )

    task_load_flights = PythonOperator(
        task_id='load_flights',
        python_callable=load_flights,
        provide_context=True,
    )

    task_extract_csv >> task_load_airlines
    task_extract_json >> task_load_flights
