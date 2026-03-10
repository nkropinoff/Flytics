-- task 3 --
BEGIN;

UPDATE city SET name = 'City_In_Progress' WHERE id = 6;

SELECT xmin, xmax, ctid, id, name FROM city WHERE id = 6;

COMMIT;

-- deadlock model --
BEGIN;
UPDATE city SET name = 'Kazan_Tx1' WHERE id = 1;

UPDATE city SET name = 'Moscow_Tx1_Wants' WHERE id = 2;

-- Блокировки на уровне строк --
BEGIN;
SELECT * FROM city WHERE id = 1 FOR UPDATE;

BEGIN;
SELECT * FROM city WHERE id = 2 FOR NO KEY UPDATE;

BEGIN;
SELECT * FROM city WHERE id = 3 FOR UPDATE;