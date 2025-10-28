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
