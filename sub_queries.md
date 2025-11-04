1. SELECT

1.1. **Все рейсы с количеством билетов на каждом рейсе**
```sql
SELECT 
    fn.number as flight_number,
    f.departure_time,
    (
        SELECT COUNT(*) 
        FROM ticket t 
        WHERE t.flight_id = f.id
    ) as tickets_count
FROM flight f
JOIN flight_number fn ON f.flight_number = fn.number;
```
![](images/img1.png)

1.2. **Клиенты с количеством их бронирований**
```sql
SELECT 
    first_name,
    last_name,
    email,
    (
        SELECT COUNT(*) 
        FROM booking b 
        WHERE b.client_id = c.id
    ) as bookings_count
FROM client c;
```
![](images/img2.png)

1.3. **Аэропорты с количеством вылетающих рейсов**
```sql
SELECT 
    a.iata_code,
    a.name as airport_name,
    (
        SELECT COUNT(*) 
        FROM flight_number fn 
        WHERE fn.departure_airport_id = a.iata_code
    ) as departing_flights
FROM airport a;
```
![](images/img3.png)
