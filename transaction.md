1. Базовые операции с транзакциями

1.1 BEGIN COMMIT

```sql
BEGIN;

INSERT INTO booking (client_id, booking_date, total_cost, status_id)
VALUES (5, NOW(), 28000, 2);

INSERT INTO payment (booking_id, payment_method_id, payment_status_id, payment_date)
SELECT id, 1, 2, NOW() 
FROM booking 
WHERE client_id = 5 AND booking_date = (SELECT MAX(booking_date) FROM booking WHERE client_id = 5);

COMMIT;
```
Создаем новое бронирование и записываем оплату для этого бронирования

![](images/img41.png)
![](images/img42.png)

1.2 BEGIN COMMIT
```sql
BEGIN;

INSERT INTO passenger (first_name, last_name, birthdate, passport_series, passport_number)
VALUES ('Sergey', 'Kuznetsov', '1991-03-20', '5566', '778899');

INSERT INTO ticket (seat_number, booking_id, passenger_id, fare_id, flight_id)
SELECT 'C8', 2, id, 1, 1
FROM passenger 
WHERE passport_series = '5566' AND passport_number = '778899';

COMMIT;
```
Создаем нового пассажира и создаем билет для него
![](images/img43.png)
![](images/img44.png)

2.1 ROLLBACK
![](images/img45.png)
![](images/img46.png)

2.2 ROLLBACK
![](images/img47.png)
![](images/img48.png)

3.1 Ошибка в транзакции

До транзакции:

![](images/img49.png)

Транзакция с ошибкой:

![](images/img50.png)

После транзакции с ошибкой ничего не изменилось:

![](images/img49.png)

3.2 Ошибка в транзакции

До транзакции:

![](images/img49.png)

Транзакция с ошибкой:

![](images/img51.png)

После транзакции с ошибкой ничего не изменилось:

![](images/img49.png)

4.1 SAVEPOINT

```sql
BEGIN;

INSERT INTO booking (client_id, booking_date, total_cost, status_id)
VALUES (5, NOW(), 30000, 2);

SAVEPOINT first_savepoint;

INSERT INTO passenger (first_name, last_name, birthdate, passport_series, passport_number)
VALUES ('Olga', 'Semenova', '1985-07-12', '1234', '999888');

COMMIT;

SELECT * FROM booking WHERE client_id = 5 ORDER BY booking_date DESC LIMIT 1;
SELECT * FROM passenger WHERE passport_series = '1234' AND passport_number = '999888';
```
![](images/img52.png)
![](images/img53.png)

4.2 SAVEPOINT

```sql
BEGIN;

-- Изменение 1
INSERT INTO booking (client_id, booking_date, total_cost, status_id)
VALUES (3, NOW(), 15000, 1);

SAVEPOINT sp1;

-- Изменение 2
INSERT INTO passenger (first_name, last_name, birthdate, passport_series, passport_number)
VALUES ('Dmitry', 'Volkov', '1992-11-05', '7777', '111222');

SAVEPOINT sp2;

-- Изменение 3
UPDATE booking SET total_cost = 50000 WHERE client_id = 3 AND booking_date = (SELECT MAX(booking_date) FROM booking WHERE client_id = 3);

SELECT * FROM booking WHERE client_id = 3 ORDER BY booking_date DESC LIMIT 1;
SELECT * FROM passenger WHERE passport_series = '7777' AND passport_number = '111222';

ROLLBACK TO SAVEPOINT sp2;

SELECT * FROM booking WHERE client_id = 3 ORDER BY booking_date DESC LIMIT 1;

ROLLBACK TO SAVEPOINT sp1;

SELECT * FROM passenger WHERE passport_series = '7777' AND passport_number = '111222';
SELECT * FROM booking WHERE client_id = 3 ORDER BY booking_date DESC LIMIT 1;

COMMIT;
```
