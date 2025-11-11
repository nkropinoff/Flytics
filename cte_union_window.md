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

6. PARTITION BY + ORDER BY
6.1. Для каждого клиента рассчитать нарастающий итог стоимости всех его бронирований, упорядоченных по дате.
```sql
SELECT
	client_id,
	sum(total_cost) OVER (
		PARTITION BY client_id
		ORDER BY booking_date
	)
FROM booking;
```
![](images/Pasted%20image%2020251111180945.png)
6.2 Для каждого тарифа на рейс определить, насколько его цена отличается от средней цены всех тарифов на этот же самый рейс.
```sql
SELECT
	f.flight_number,
	f.departure_time,
	tpf.tickets_sold,
	SUM(tpf.tickets_sold) OVER (
		PARTITION BY f.flight_number
		ORDER BY f.departure_time
	) 
FROM flight AS f
JOIN (
	SELECT 
		flight_id,
		COUNT(id) AS tickets_sold
	FROM ticket
	GROUP BY flight_id
	) AS tpf ON f.id = tpf.flight_id;
```
![](images/Pasted%20image%2020251111183210.png)

7. RANGE / ROWS
7.1 Для каждого бронирования показать суммарную стоимость всех бронирований этого же клиента, которые были сделаны в тот же день.
```sql
SELECT 
	client_id,
	booking_date,
	total_cost,
	SUM(total_cost) OVER (
		PARTITION BY client_id
		ORDER BY CAST(booking_date AS DATE)
		RANGE BETWEEN CURRENT ROW AND CURRENT ROW
	)
FROM booking
```
![](images/Pasted%20image%2020251111190337.png)

7.2 Для каждого тарифа на рейс найти среднюю цену всех тарифов на этот же рейс, чья цена отличается от цены текущего тарифа не более чем на 5000.
```sql
SELECT 
	flight_id,
	price,
	ROUND (AVG(price) OVER (
		PARTITION BY flight_id
		ORDER BY price
		RANGE BETWEEN 5000 PRECEDING AND 5000 FOLLOWING
	), 2) AS avg_price
FROM fare
```
![](images/Pasted%20image%2020251111191323.png)

7.3 Для каждого клиента рассчитать среднюю стоимость его последних **трех** бронирований, включая текущее. 
```sql
SELECT
    client_id,
    booking_date,
    total_cost,
    ROUND(
        AVG(total_cost) OVER (
            PARTITION BY client_id
            ORDER BY booking_date
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2
    ) AS avg_last_3_bookings
FROM
    booking
```
![](images/Pasted%20image%2020251111191833.png])

7.4 Для каждого номера рейса вывести дату вылета, количество проданных билетов на эту дату, а также скользящее среднее по количеству проданных билетов, рассчитанное по текущему и двум предыдущим рейсам с тем же номером.
```sql
WITH tickets_per_flight AS (
    SELECT
        flight_id,
        COUNT(id) AS tickets_sold
    FROM
        ticket
    GROUP BY
        flight_id
)

SELECT
    f.flight_number,
    f.departure_time,
    tpf.tickets_sold,
    ROUND(
        AVG(tpf.tickets_sold) OVER (
            PARTITION BY f.flight_number
            ORDER BY f.departure_time
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2
    ) AS moving_avg_tickets_last_3_days
FROM
    flight AS f
JOIN
    tickets_per_flight AS tpf ON f.id = tpf.flight_id
ORDER BY
    f.flight_number, f.departure_time;
```
![](images/Pasted%20image%2020251111193516.png)

8. ROW_NUMBER, RANK, DENSE_RANK
8.1 Пронумеровать всех пассажиров по дате их рождения от самого старшего к самому младшему.
```sql
SELECT
    first_name,
    last_name,
    birthdate,
    ROW_NUMBER() OVER (ORDER BY birthdate ASC) AS age_rank
FROM
    passenger;
```
![](images/Pasted%20image%2020251111193951.png)

8.2 Ранжировать тарифы каждого рейса по их цене.
```sql
SELECT
    flight_id,
    price,
    RANK() OVER (PARTITION BY flight_id ORDER BY price ASC) AS price_rank
FROM
    fare;
```
![](images/Pasted%20image%2020251111194140.png)

8.3  Присвоить ранг самолетам каждой авиакомпании по вместимости их моделей.
```sql
SELECT
    al.name AS airline_name,
    am.model,
    am.capacity,
    DENSE_RANK() OVER (PARTITION BY ac.airline_iata_code ORDER BY am.capacity DESC) AS capacity_rank
FROM
    aircraft AS ac
JOIN
    aircraft_model AS am ON ac.model = am.model
JOIN
    airline AS al ON ac.airline_iata_code = al.iata_code;
```
![](images/Pasted%20image%2020251111194636.png)

9. LAG, LEAD, FIRST_VALUE, LAST_VALUE
9.1 Для каждого бронирования клиента вывести его стоимость и стоимость предыдущего бронирования этого же клиента.
```sql
SELECT
    client_id,
    booking_date,
    total_cost,
    LAG(total_cost, 1, 0) OVER (PARTITION BY client_id ORDER BY booking_date) AS previous_booking_cost
FROM
    booking;
```
![](images/Pasted%20image%2020251111201556.png)

9.2 Для каждого рейса с определенным номером вывести время его вылета и время вылета следующего рейса с тем же номером.
```sql
SELECT
    flight_number,
    departure_time,
    LEAD(departure_time) OVER (PARTITION BY flight_number ORDER BY departure_time) AS next_flight_time
FROM
    flight;
```
![](images/Pasted%20image%2020251111201721.png)

9.3 Для каждого бронирования клиента отобразить его стоимость, а также стоимость самого первого бронирования этого клиента.
```sql
SELECT
    client_id,
    booking_date,
    total_cost,
    FIRST_VALUE(total_cost) OVER (PARTITION BY client_id ORDER BY booking_date) AS first_booking_cost
FROM
    booking;
```
![](images/Pasted%20image%2020251111201836.png)

9.4 Для каждого тарифа на рейс показать его цену и цену самого дорогого тарифа на этом же рейсе.
```sql
SELECT
    flight_id,
    price,
    LAST_VALUE(price) OVER (
        PARTITION BY flight_id
        ORDER BY price
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS most_expensive_fare
FROM
    fare;
```
![](images/Pasted%20image%2020251111202030.png)
