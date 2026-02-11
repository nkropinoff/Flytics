1. AVG
1.1. **Средняя стоимость всех бронирований**
```sql
SELECT AVG(total_cost) AS average_booking_cost
FROM booking;
```
![](images/Pasted%20image%2020251028143016.png)

1.2 **Средняя цена билетов эконом-класса**
```sql
SELECT AVG(f.price) AS average_economy_price
FROM fare f
JOIN fare_class fc ON f.fare_class_id = fc.id
WHERE fc.description = 'Economy';
```
![](images/Pasted%20image%2020251028143057.png)

2. COUNT
2.1  **Общее количество рейсов в базе**
```sql
SELECT COUNT(*) AS total_flights
FROM flight;
```
![](mages/Pasted%20image&2020251028143418.png)

2.2 **Количество рейсов авиакомпании Аэрофлот**
```sql
SELECT COUNT(fl.id) AS aeroflot_flights_count
FROM flight fl
JOIN aircraft ac ON fl.aircraft_id = ac.id
JOIN airline al ON ac.airline_iata_code = al.iata_code
WHERE al.name = 'Аэрофлот';
```
![](images/Pasted%20image%2020251028143515.png)

3. MIN
3.1 **Минимальная цена среди всех билетов**
```sql
SELECT MIN(price) AS min_price
FROM fare;
```
![](images/Pasted%20image%2020251028143704.png)

3.2 **Самое раннее время вылета**
```sql
SELECT MIN(departure_time) AS earliest_departure
FROM flight;
```
![](images/Pasted%20image%2020251028143756.png)

4. MAX
4.1 **Максимальная цена среди всех билетов**
```sql
SELECT MAX(price) AS max_price
FROM fare;
```
![](images/Pasted%20image%2020251028143855.png)

4.2 **Самое позднее время вылета**
```sql
SELECT MAX(departure_time) AS latest_departure
FROM flight;
```
![](images/Pasted%20image%2020251028143925.png)

5. SUM
5.1 **Общая выручка по всем бронированиям**
```sql
SELECT SUM(total_cost) AS total_revenue
FROM booking;
```
![](images/Pasted%20image%2020251028144115.png)

5.2 **Общее количество доступных мест эконом-класса**
```sql
SELECT SUM(f.available_seats) AS total_economy_seats
FROM fare f
JOIN fare_class fc ON f.fare_class_id = fc.id
WHERE fc.description = 'Economy';
```
![](images/Pasted%20image%2020251028144154.png)

6. STRING_AGG
6.1 **Список всех городов через запятую**
```sql
SELECT STRING_AGG(name, ', ' ORDER BY name) AS all_cities
FROM city;
```
![](images/Pasted%20image%2020251028144248.png))

6.2 **Список всех авиакомпаний через точку с запятой**
```sql
SELECT STRING_AGG(name, '; ' ORDER BY name) AS all_airlines
FROM airline;
```
![](images/Pasted%20image%2020251028144530.png)

7. Комбинирование функций
7.1 **Общая статистика по всем бронированиям**
```sql
SELECT COUNT(*) AS total_bookings, SUM(total_cost) AS total_revenue, AVG(total_cost) AS average_cost, MIN(total_cost) AS min_cost, MAX(total_cost) AS max_cost FROM booking;
```
![](images/Pasted%20image%2020251028144636.png)

7.2 **Статистика по вместимости самолетов**
```sql
SELECT COUNT(*) AS total_aircraft_models,
       SUM(capacity) AS total_capacity,
       AVG(capacity) AS avg_capacity,
       MIN(capacity) AS smallest_capacity,
       MAX(capacity) AS largest_capacity,
       STRING_AGG(model, ', ' ORDER BY capacity DESC) AS models_by_capacity
FROM aircraft_model;
```
![](images/Pasted%20image%2020251028145221.png)

8. GROUP BY

8.1 Количество рейсов для каждого самолета

```sql
SELECT aircraft_id, COUNT(*) AS flights_count FROM flight GROUP BY aircraft_id;
```
![](images/Pasted%20image%2020251028142647.png)

8.2 Общая стоимость бронирований для каждого клиента

```sql
SELECT client_id, SUM(total_cost) AS total_spent FROM booking GROUP BY client_id;
```

![](images/Pasted%20image%2020251028142710.png)

9. **HAVING**

9.1 Клиенты с общей суммой бронирований больше 5000

```sql
SELECT client_id, SUM(total_cost) AS total_spent 
FROM booking 
GROUP BY client_id 
HAVING SUM(total_cost) > 5000;
```
![](images/Pasted%20image%2020251028142859.png)

9.2 Рейсы с более чем 2 доступными тарифами

```sql
SELECT flight_id, COUNT(*) AS fare_count 
FROM fare 
GROUP BY flight_id 
HAVING COUNT(*) > 2;
```
![](images/Pasted%20image%2020251028142918.png)

 10. **GROUPING SETS**

10.1 Количество рейсов по статусам и общее количество

```sql
SELECT status_id, COUNT(*) AS flights_count 
FROM flight 
GROUP BY GROUPING SETS (status_id, ());
```

![](images/Pasted%20image%2020251028143232.png)

10.2 Средняя цена билетов по классам обслуживания и общая средняя


```sql
SELECT fare_class_id, AVG(price) AS avg_price 
FROM fare 
GROUP BY GROUPING SETS (fare_class_id, ());
```
![](images/Pasted%20image%2020251028143446.png)

11.  **ROLLUP**

11.1 Количество бронирований по клиентам и статусам

```sql
SELECT client_id, status_id, COUNT(*) AS booking_count 
FROM booking 
GROUP BY ROLLUP(client_id, status_id);
```

![](images/Pasted%20image%2020251028143714.png)

11.2 Общая стоимость билетов по рейсам и классам с промежуточными итогами

```sql
SELECT flight_id, fare_class_id, SUM(price) AS total_price 
FROM fare 
GROUP BY ROLLUP(flight_id, fare_class_id);
```

![](images/Pasted%20image%2020251028143811.png)

12. **CUBE**

12.1 Количество самолетов по моделям и авиакомпаниям со всеми комбинациями

```sql
SELECT model, airline_iata_code, COUNT(*) AS aircraft_count 
FROM aircraft 
GROUP BY CUBE(model, airline_iata_code);
```

![](images/Pasted%20image%2020251028143938.png)

12.2 Количество билетов по рейсам и тарифам со всеми возможными группировками

```sql
SELECT flight_id, fare_id, COUNT(*) AS ticket_count 
FROM ticket 
GROUP BY CUBE(flight_id, fare_id);
```
![](images/Pasted%20image%2020251028144010.png)

13. **SELECT, FROM, WHERE, GROUP BY, HAVING, ORDER BY** (Комбинированный)

13.1 Клиенты со статусом "pending" или "confirmed", сортировка по общей сумме

```sql
SELECT 
    client_id,
    COUNT(*) AS booking_count,
    SUM(total_cost) AS total_spent
FROM booking
WHERE status_id IN (1, 2)
GROUP BY client_id
HAVING SUM(total_cost) > 10000
ORDER BY total_spent DESC;

```

![](images/Pasted%20image%2020251028144348.png)

13.2 Рейсы с тарифами дороже 10000, средняя цена по рейсу

```sql
SELECT 
    flight_id,
    COUNT(fare.id) AS fare_count,
    AVG(fare.price) AS avg_price,
    MIN(fare.price) AS min_price,
    MAX(fare.price) AS max_price
FROM fare
WHERE price > 10000
GROUP BY flight_id
HAVING COUNT(fare.id) >= 1
ORDER BY avg_price DESC;
```

![](images/Pasted%20image%2020251028144437.png)


