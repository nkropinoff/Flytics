-- ЗАПРОСЫ --

-- 1. Точный поиск --
SELECT id, first_name, last_name, email
FROM client
WHERE phone_number = '818-479-5287';

-- 2. Поиск по диапазону --
SELECT id, booking_date, total_cost, status_id
FROM booking
WHERE total_cost > 10000 AND total_cost < 50000;

-- 3. Поиск по префиксу (like%) --
SELECT id, first_name, last_name, passport_series
FROM passenger
WHERE last_name LIKE 'Ma%';

-- 4. Поиск по суффиксу (%like) --
UPDATE client
SET loyalty_points = loyalty_points + 50
WHERE email LIKE '%@gmail.com%';

-- 5. Поиск по 2 параметрам (для составного индекса) --
DELETE FROM booking
WHERE client_id IN (255000, 255002, 255003) AND booking_date < '2026-01-01';



-- АНАЛИЗ ВЫПОЛНЕНИЯ ЗАПРОСОВ --

-- 1.1 --
EXPLAIN ANALYZE
SELECT id, first_name, last_name, email
FROM client
WHERE phone_number = '818-479-5287';

-- 1.2 --
EXPLAIN (ANALYZE,BUFFERS)
SELECT id, first_name, last_name, email
FROM client
WHERE phone_number = '818-479-5287';

-- 2.1 --
EXPLAIN ANALYZE
SELECT id, booking_date, total_cost, status_id
FROM booking
WHERE total_cost > 10000 AND total_cost < 50000;

-- 2.2 --
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, booking_date, total_cost, status_id
FROM booking
WHERE total_cost > 10000 AND total_cost < 50000;

-- 3.1 --
EXPLAIN ANALYZE
SELECT id, first_name, last_name, passport_series
FROM passenger
WHERE last_name LIKE 'Ma%';

-- 3.2 --
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, first_name, last_name, passport_series
FROM passenger
WHERE last_name LIKE 'Ma%';

-- 4.1 --
BEGIN;
EXPLAIN ANALYZE
UPDATE client
SET loyalty_points = loyalty_points + 50
WHERE email LIKE '%@gmail.com%';
ROLLBACK;

-- 4.2 --
BEGIN;
EXPLAIN (ANALYZE, BUFFERS)
UPDATE client
SET loyalty_points = loyalty_points + 50
WHERE email LIKE '%@gmail.com%';
ROLLBACK;

-- 5.1 --
BEGIN;
EXPLAIN ANALYZE
DELETE FROM booking
WHERE client_id IN (255000, 255002, 255003) AND booking_date < '2026-01-01';
ROLLBACK;

-- 5.2 --
BEGIN;
EXPLAIN (ANALYZE, BUFFERS)
DELETE FROM booking
WHERE client_id IN (255000, 255002, 255003) AND booking_date < '2026-01-01';
ROLLBACK;



-- СОЗДАНИЕ B-tree ИНДЕКСОВ --

-- 1. Индекс для точного поиска
CREATE INDEX idx_client_phone ON client(phone_number);

-- 2. Индекс для поиска по диапазону
CREATE INDEX idx_booking_total_cost ON booking(total_cost);

-- 3. Индекс для поиска по префиксу (LIKE 'Ma%')
CREATE INDEX idx_passenger_last_name ON passenger(last_name varchar_pattern_ops);

-- 4. Индекс для поиска по суффиксу (%LIKE)
CREATE INDEX idx_client_email ON client(email);

-- 5. Составной индекс для IN и <
CREATE INDEX idx_booking_client_date ON booking(client_id, booking_date);


-- УДАЛЕНИЕ существующих индексов --
DROP INDEX IF EXISTS idx_client_phone;

DROP INDEX IF EXISTS idx_booking_total_cost;

DROP INDEX IF EXISTS idx_passenger_last_name;

DROP INDEX IF EXISTS idx_client_email;

DROP INDEX IF EXISTS idx_booking_client_date;

-- СОЗДАНИЕ Hash ИНДЕКСОВ --
-- 1. Hash индекс для точного поиска
CREATE INDEX idx_client_phone_hash ON client USING hash (phone_number);

-- 2. Hash индекс по total_cost
CREATE INDEX idx_booking_total_cost_hash ON booking USING hash (total_cost);

-- 3. Hash индекс по last_name
CREATE INDEX idx_passenger_last_name_hash ON passenger USING hash (last_name);

-- 4. Hash индекс по email
CREATE INDEX idx_client_email_hash ON client USING hash (email);

-- 5. Составной hash-индекс создать нельзя
