1. SELECT

1.1. **Клиенты, у которых стоимость бронирования выше средней**
```sql
SELECT 
    c.first_name,
    c.last_name,
    c.email,
    b.total_cost
FROM client c
JOIN booking b ON c.id = b.client_id
WHERE b.total_cost > (
    SELECT AVG(total_cost) 
    FROM booking
);
```
![](images/img1.png)

1.2. **Все рейсы с информацией о количестве проданных билетов на каждый рейс**
```sql
SELECT 
    f.id,
    fn.number as flight_number,
    a.name as airline,
    f.departure_time,
    f.arrival_time,
    (
        SELECT COUNT(*) 
        FROM ticket t 
        WHERE t.flight_id = f.id
    ) as tickets_sold
FROM flight f
JOIN flight_number fn ON f.flight_number = fn.number
JOIN aircraft ac ON f.aircraft_id = ac.id
JOIN airline a ON ac.airline_iata_code = a.iata_code;
```
![](images/img2.png)

1.3. **Клиенты, у которых есть бронирования со статусом "confirmed"**
```sql
SELECT first_name, last_name, email
FROM client
WHERE id IN (
    SELECT client_id 
    FROM booking 
    WHERE status_id = (
        SELECT id 
        FROM booking_status 
        WHERE description = 'confirmed'
    )
);
```
![](images/img3.png)
