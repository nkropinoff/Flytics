-- 1. Сравнение LSN до и после INSERT --

-- 1.1 Текущий LSN --
SELECT pg_current_wal_lsn() as lsn_before;

-- 1.2 Вставка новой строки --
INSERT INTO booking (client_id, booking_date, total_cost, status_id, channel)
VALUES (25502, NOW(), 17000, 1, 'WEB');

-- 1.3 Новый LSN --
SELECT pg_current_wal_lsn() as lsn_after;

-- 2. Сравнение WAL до и после COMMIT --

-- 2.1 Состояние до транзакции --
SELECT
    pg_current_wal_lsn() AS lsn,
    pg_current_wal_insert_lsn() AS insert_lsn,
    wal_records,
    wal_bytes
FROM pg_stat_wal;

-- 2.2 Начало транзакции --
BEGIN;

INSERT INTO booking (client_id, booking_date, total_cost, status_id, channel)
VALUES (25501, NOW(), 18000, 1, 'WEB');

-- 2.3 Состояние в момент транзакции --
SELECT
    pg_current_wal_lsn() AS lsn,
    pg_current_wal_insert_lsn() AS insert_lsn,
    wal_records,
    wal_bytes
FROM pg_stat_wal;

-- 2.4 Commit --
COMMIT;

-- 2.5 Состояние после COMMIT --
SELECT
    pg_current_wal_lsn() AS lsn,
    pg_current_wal_insert_lsn() AS insert_lsn,
    wal_records,
    wal_bytes
FROM pg_stat_wal;

-- 3. Анализ WAL размера до и после массовой операции --

-- 3.1 Состояние до операции --
SELECT
    pg_current_wal_lsn()            AS lsn,
    pg_walfile_name(pg_current_wal_lsn()) AS wal_file,
    wal_records,
    wal_bytes
FROM pg_stat_wal;

-- 3.2 Массовая операция (перезаписываем на имеющееся значение чтобы не сломать распределение)
UPDATE booking
SET total_cost = total_cost
WHERE booking_date >= NOW() - INTERVAL '1 year';

-- 3.3 Состояние после операции --
SELECT
    pg_current_wal_lsn() AS lsn,
    pg_walfile_name(pg_current_wal_lsn()) AS wal_file,
    wal_records,
    wal_bytes
FROM pg_stat_wal;

