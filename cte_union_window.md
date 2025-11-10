1. CTE

1.1 Клиенты с несколькими бронированиями

```sql
WITH client_bookings AS (
    SELECT 
        client_id,
        COUNT(*) as booking_count
    FROM booking
    GROUP BY client_id
)
SELECT 
    c.first_name,
    c.last_name,
    cb.booking_count
FROM client c
JOIN client_bookings cb ON c.id = cb.client_id
WHERE cb.booking_count > 1
ORDER BY cb.booking_count DESC;
```

![](images/Pasted%20image%2020251110233054.png)

1.2 Общая статистика по клиентам

```sql
WITH client_stats AS (
    SELECT 
        client_id,
        COUNT(*) as total_bookings,
        SUM(total_cost) as total_spent,
        AVG(total_cost) as avg_booking_cost
    FROM booking
    GROUP BY client_id
)
SELECT 
    c.first_name || ' ' || c.last_name as full_name,
    cs.total_bookings,
    cs.total_spent,
    ROUND(cs.avg_booking_cost) as avg_cost
FROM client c
JOIN client_stats cs ON c.id = cs.client_id
ORDER BY cs.total_spent DESC;
```

![](images/Pasted%20image%2020251110233306.png)

1.3 Рейсы с названиями авиакомпаний

```sql
WITH flight_info AS (
    SELECT 
        f.id,
        f.flight_number,
        f.departure_time,
        f.aircraft_id
    FROM flight f
)

SELECT 
    fi.flight_number,
    fi.departure_time,
    al.name as airline_name
FROM flight_info fi
JOIN aircraft ac ON fi.aircraft_id = ac.id
JOIN airline al ON ac.airline_iata_code = al.iata_code
ORDER BY fi.departure_time
LIMIT 5;
```

![](images/Pasted%20image%2020251110233524.png)

1.4 Все клиенты

```sql
WITH all_clients AS (
    SELECT 
        id,
        first_name,
        last_name,
        email
    FROM client
)
SELECT * FROM all_clients
ORDER BY first_name;
```

![](images/Pasted%20image%2020251110233701.png)

1.5 Количество билетов на каждый рейс

```sql
WITH tickets_per_flight AS (
    SELECT 
        flight_id,
        COUNT(*) as ticket_count
    FROM ticket
    GROUP BY flight_id
)
SELECT 
    f.flight_number,
    f.departure_time,
    tpf.ticket_count
FROM flight f
JOIN tickets_per_flight tpf ON f.id = tpf.flight_id
ORDER BY tpf.ticket_count DESC;
```

![](images/Pasted%20image%2020251110233828.png)

2. UNION

2.1 Объединение имен клиентов и пассажиров

```sql
SELECT first_name, last_name
FROM client

UNION

SELECT first_name, last_name
FROM passenger
ORDER BY last_name;
```

![](images/Pasted%20image%2020251110234038.png)

2.2 Список всех городов и авиакомпаний

```sql
SELECT name as location_name
FROM city

UNION

SELECT name as location_name
FROM airline
ORDER BY location_name;
```

![](images/Pasted%20image%2020251110234124.png)

2.3 Все IATA коды

```sql
SELECT iata_code, 'airport' as code_type, name
FROM airport

UNION

SELECT iata_code, 'airline' as code_type, name
FROM airline
ORDER BY code_type, iata_code;
```
![](images/Pasted%20image%2020251110234336.png)

3. INTERSECT

3.1 Клиенты, которые также являются пассажирами

```sql
SELECT first_name, last_name
FROM client

INTERSECT

SELECT first_name, last_name
FROM passenger
ORDER BY last_name;
```

![](images/Pasted%20image%2020251110234456.png)

3.2 Рейсы, на которые проданы билеты

```sql
SELECT id
FROM flight

INTERSECT

SELECT flight_id
FROM ticket
ORDER BY id;
```

![](images/Pasted%20image%2020251110234555.png)

3.3 Общие статусы в разных таблицах

```sql
SELECT description
FROM booking_status

INTERSECT

SELECT description
FROM payment_status
ORDER BY description;
```

![](images/Pasted%20image%2020251110234642.png)

4. EXCEPT

4.1 Рейсы без проданных билетов

```sql
SELECT id
FROM flight

EXCEPT

SELECT flight_id
FROM ticket
ORDER BY id;

```

![](images/Pasted%20image%2020251110234838.png)

4.2 Пассажиры, который не являются клиентами

```sql
SELECT first_name, last_name
FROM passenger

EXCEPT

SELECT first_name, last_name
FROM client
ORDER BY last_name;
```

![](images/Pasted%20image%2020251110234937.png)

4.3 Аэропорты без прилетающих рейсов

```sql
SELECT iata_code
FROM airport

EXCEPT

SELECT arrival_airport_id
FROM flight_number;
```

![](images/Pasted%20image%2020251110235209.png)

5. PARTITION BY

5.1 Подсчет количества бронирований для каждого клиента

```sql
SELECT 
    b.id,
    b.client_id,
    c.first_name,
    c.last_name,
    b.booking_date,
    b.total_cost,
    COUNT(*) OVER (PARTITION BY b.client_id) as client_bookings_count
FROM booking b
JOIN client c ON b.client_id = c.id
ORDER BY c.last_name, b.booking_date;
```

![](images/Pasted%20image%2020251110235427.png)

5.2 Средняя цена тарифов по каждому классу

```sql
SELECT 
    f.id as fare_id,
    fc.description as class_name,
    f.price,
    f.flight_id,
    AVG(f.price) OVER (PARTITION BY f.fare_class_id) as avg_price_in_class
FROM fare f
JOIN fare_class fc ON f.fare_class_id = fc.id
ORDER BY fc.description, f.price;
```

![](images/Pasted%20image%2020251110235522.png)
