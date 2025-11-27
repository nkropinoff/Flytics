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
