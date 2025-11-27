1. NEW

1.1. При создании рейса автоматически создаются тарифы для него.

```sql
CREATE OR REPLACE FUNCTION create_fares_for_new_flight()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO fare (flight_id, fare_class_id, price, available_seats)
    SELECT 
        NEW.id,
        fc.id,
        CASE 
            WHEN fc.description = 'Economy' THEN 10000
            WHEN fc.description = 'Business' THEN 25000
            WHEN fc.description = 'First' THEN 50000
            ELSE 15000
        END,
        (SELECT capacity FROM aircraft_model am 
         JOIN aircraft a ON a.model = am.model 
         WHERE a.id = NEW.aircraft_id)
    FROM fare_class fc;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trigger_create_fares
    AFTER INSERT ON flight
    FOR EACH ROW
    EXECUTE FUNCTION create_fares_for_new_flight();

INSERT INTO flight (
    flight_number, 
    aircraft_id, 
    departure_time, 
    arrival_time, 
    status_id
) 
VALUES (
    'DP300',
    (SELECT id FROM aircraft LIMIT 1),
    '2026-01-15 10:00:00+00',
    '2026-01-15 13:00:00+00',
    (SELECT id FROM flight_status WHERE description = 'Scheduled')
);
```
![](images/img110.png)
![](images/img111.png)


1.2. Автоматическое присвоение статуса pending при бронировании + проверка на правильность суммы.

```sql
CREATE OR REPLACE FUNCTION set_initial_booking_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status_id IS NULL THEN
        SELECT id INTO NEW.status_id 
        FROM booking_status 
        WHERE description = 'pending';
    END IF;
    IF NEW.total_cost <= 0 THEN
        RAISE EXCEPTION 'Total cost must be greater than 0';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trigger_validate_booking
    BEFORE INSERT ON booking
    FOR EACH ROW
    EXECUTE FUNCTION set_initial_booking_status();

INSERT INTO booking (client_id, booking_date, total_cost, status_id)
VALUES (
    (SELECT id FROM client WHERE email = 'ivan@mail.ru'),
    NOW(),
    25000,
    NULL
);
```
![](images/img112.png)


2. OLD

2.1. Логирование удаленных из базы пассажиров.

```sql
CREATE TABLE IF NOT EXISTS passenger_archive (
    id INT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    birthdate DATE NOT NULL,
    passport_series CHAR(4) NOT NULL,
    passport_number CHAR(6) NOT NULL,
    archived_at TIMESTAMPTZ DEFAULT NOW(),
    archive_reason VARCHAR(100) DEFAULT 'Manual deletion'
);

CREATE OR REPLACE FUNCTION archive_deleted_passenger()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO passenger_archive 
        (id, first_name, last_name, birthdate, passport_series, passport_number, archive_reason)
    VALUES 
        (OLD.id, OLD.first_name, OLD.last_name, OLD.birthdate, 
         OLD.passport_series, OLD.passport_number, 'Manual deletion');
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_archive_passenger
    BEFORE DELETE ON passenger
    FOR EACH ROW
    EXECUTE FUNCTION archive_deleted_passenger();

INSERT INTO passenger (first_name, last_name, birthdate, passport_series, passport_number)
VALUES ('Test', 'User', '1990-01-01', '1234', '567890')

DELETE FROM passenger 
WHERE passport_series = '1234' AND passport_number = '567890';

SELECT * FROM passenger_archive;
```
![](images/img113.png)
