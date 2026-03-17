-- GIN --

-- 1. Создание GIN индекса по полю `flight_tags` (тип `TEXT[]`, массив) — теги рейса --
CREATE INDEX idx_flight_tags_gin ON flight USING gin (flight_tags);

-- 1 * Удаление idx_flight_tags_gin
DROP INDEX IF EXISTS idx_flight_tags_gin;

-- 2. Создание GIN индекса по полю `profile_data` (тип `JSONB`) — предпочтения пассажира --
CREATE INDEX idx_passenger_profile_gin ON passenger USING gin (profile_data jsonb_path_ops);

-- 2 * Удаление idx_passenger_profile_gin;
DROP INDEX IF EXISTS idx_passenger_profile_gin;

-- 3. Сканирование: ищем рейсы у которых есть тег 'wifi' --
EXPLAIN ANALYZE
SELECT flight_number, departure_time
FROM flight
WHERE flight_tags @> ARRAY['wifi'];

-- 4. Сканирование: ищем пассажиров вегитарианцев
EXPLAIN ANALYZE
SELECT first_name, last_name
FROM passenger
WHERE profile_data @> '{"meal": "vegan"}';

-- 5. Сканирование: ищем рейсы у которых НЕТ тега 'wifi'
EXPLAIN ANALYZE
SELECT flight_number, departure_time
FROM flight
WHERE NOT (flight_tags @> ARRAY['wifi']);


-- GIST --

-- 1. Создание GiST индекса по полю `booking_window` (тип `TSTZRANGE`, range) — диапазон времени, когда открыта продажа билетов.
CREATE INDEX idx_flight_booking_window_gist ON flight USING gist (booking_window);

-- 1 * Удаление idx_flight_booking_window_gist
DROP INDEX IF EXISTS idx_flight_booking_window_gist;

-- 2. Создание GiST индекса по полю `home_address_coords` (тип `POINT`) — геометрический тип
CREATE INDEX idx_client_coords_gist ON client USING gist (home_address_coords);

-- 2 * Удаление idx_client_coords_gist
DROP INDEX IF EXISTS idx_client_coords_gist;

-- 3. Сканирование: ищем рейсы чье окно продаж пересекается с выходными
EXPLAIN ANALYZE
SELECT flight_number
FROM flight
WHERE booking_window && tstzrange('2026-03-07 00:00:00+03', '2026-03-09 00:00:00+03');

-- 4. Сканирование: ищем 5 клиентов которые живут ближе всего к аэропорту (55.97, 37.41)
EXPLAIN ANALYZE
SELECT id, first_name, home_address_coords <-> point(55.97, 37.41) AS distance
FROM client
ORDER BY home_address_coords <-> point(55.97, 37.41)
LIMIT 5;

-- 5. Сканирование: Ищем рейсы чье окно продаж строго в марте
EXPLAIN ANALYZE
SELECT flight_number
FROM flight
WHERE booking_window <@ tstzrange('2026-03-01 00:00:00+03', '2026-03-31 23:59:59+03');


-- JOIN --

-- 1. Точечная выборка - ищем бронирования одного клиента
EXPLAIN ANALYZE
SELECT c.first_name, b.total_cost, b.booking_date
FROM client c
JOIN booking b ON c.id = b.client_id
WHERE c.id = 255002;

-- 2. Hash
EXPLAIN ANALYZE
SELECT f.flight_number, a.model
FROM flight f
JOIN aircraft a ON f.aircraft_id = a.id;

-- 3. Слияние отсортированных данных (первые 50)
EXPLAIN ANALYZE
SELECT c.id, c.first_name, b.total_cost
FROM client c
JOIN booking b ON c.id = b.client_id
ORDER BY c.id
LIMIT 50;

-- 4. Join больших таблиц
EXPLAIN ANALYZE
SELECT c.email, b.booking_date
FROM client c
JOIN booking b ON c.id = b.client_id;


-- 5. Join справочной таблицы
EXPLAIN ANALYZE
SELECT fn.number, a.name AS departure_airport_name
FROM flight_number fn
JOIN airport a ON fn.departure_airport_id = a.iata_code;