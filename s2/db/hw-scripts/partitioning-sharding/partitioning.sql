-- 1. Секционирование RANGE / LIST / HASH

-- 1.1 RANGE

-- Создаем копию booking по секционирование
CREATE TABLE booking_range_part
(
    id               INT,
    client_id        INT         NOT NULL,
    booking_date     TIMESTAMPTZ NOT NULL,
    total_cost       INT         NOT NULL,
    status_id        INT         NOT NULL,
    discount_code    VARCHAR(50),
    channel          VARCHAR(10),
    insurance_amount NUMERIC(10, 2),
    PRIMARY KEY (id, booking_date) -- составной primary key
) PARTITION BY RANGE (booking_date);

-- Создаем секции по годам
CREATE TABLE booking_range_2024 PARTITION OF booking_range_part FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
CREATE TABLE booking_range_2025 PARTITION OF booking_range_part FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
CREATE TABLE booking_range_2026 PARTITION OF booking_range_part FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');
CREATE TABLE booking_range_default PARTITION OF booking_range_part DEFAULT;

-- Индекс для поиска по дате
CREATE INDEX idx_booking_range_date ON booking_range_part(booking_date);

-- Копируем данные из оригинальной booking
INSERT INTO booking_range_part
SELECT id, client_id, booking_date, total_cost, status_id, discount_code, channel, insurance_amount FROM booking;

-- Запрос и его анализ
EXPLAIN ANALYZE
SELECT * FROM booking_range_part
WHERE booking_date >= '2025-05-01' AND booking_date < '2025-05-15';

-- 1.2 LIST

-- Создаем копию flight таблицы под секционирование
CREATE TABLE flight_list_part
(
    id               INT,
    flight_number    VARCHAR(8)  NOT NULL,
    aircraft_id      INT         NOT NULL,
    departure_time   TIMESTAMPTZ NOT NULL,
    arrival_time     TIMESTAMPTZ NOT NULL,
    status_id        INT         NOT NULL,
    flight_tags      TEXT[],
    booking_window   TSTZRANGE,
    actual_departure TIMESTAMPTZ,
    PRIMARY KEY (id, status_id) -- составной pk
) PARTITION BY LIST (status_id);

-- Создаем секции под статусы
CREATE TABLE flight_list_on_time PARTITION OF flight_list_part FOR VALUES IN (1);
CREATE TABLE flight_list_delayed PARTITION OF flight_list_part FOR VALUES IN (2);
CREATE TABLE flight_list_landed PARTITION OF flight_list_part FOR VALUES IN (3);
CREATE TABLE flight_list_cancelled PARTITION OF flight_list_part FOR VALUES IN (4);
CREATE TABLE flight_list_default PARTITION OF flight_list_part DEFAULT;

-- Индекс для поиска по статусу
CREATE INDEX idx_flight_list_status ON flight_list_part (status_id);

-- Копируем данные
INSERT INTO flight_list_part
SELECT id, flight_number, aircraft_id, departure_time, arrival_time, status_id, flight_tags, booking_window, actual_departure
FROM flight;

-- Запрос и его анализ
EXPLAIN ANALYZE
SELECT * FROM flight_list_part
WHERE status_id = 4;

-- 1.3 HASH
CREATE TABLE client_hash_part
(
    id                  INT PRIMARY KEY,
    first_name          VARCHAR(100) NOT NULL,
    last_name           VARCHAR(100) NOT NULL,
    email               VARCHAR(100) NOT NULL,
    password_hash       VARCHAR(100) NOT NULL,
    phone_number        VARCHAR(20),
    registration_date   DATE,
    loyalty_points      INT,
    home_address_coords POINT,
    notes               TEXT
) PARTITION BY HASH (id);

CREATE TABLE client_hash_p0 PARTITION OF client_hash_part FOR VALUES WITH (MODULUS 4, REMAINDER 0);
CREATE TABLE client_hash_p1 PARTITION OF client_hash_part FOR VALUES WITH (MODULUS 4, REMAINDER 1);
CREATE TABLE client_hash_p2 PARTITION OF client_hash_part FOR VALUES WITH (MODULUS 4, REMAINDER 2);
CREATE TABLE client_hash_p3 PARTITION OF client_hash_part FOR VALUES WITH (MODULUS 4, REMAINDER 3);

INSERT INTO client_hash_part
SELECT id, first_name, last_name, email, password_hash, phone_number, registration_date, loyalty_points, home_address_coords, notes
FROM client;

-- Запрос и его анализ
EXPLAIN ANALYZE
SELECT * FROM client_hash_part
WHERE id = 1002;

