-- task 3 --
SELECT xmin, xmax, ctid, id, name FROM city WHERE id = 6;

-- deadlock model --
BEGIN;
UPDATE city SET name = 'Moscow_Tx2' WHERE id = 2;

UPDATE city SET name = 'Kazan_Tx2_Wants' WHERE id = 1;

-- Блокировки на уровне строк --
BEGIN;
SELECT * FROM city WHERE id = 1 FOR SHARE;

BEGIN;
SELECT * FROM city WHERE id = 2 FOR KEY SHARE;

BEGIN;
SELECT * FROM city WHERE id = 3 FOR KEY SHARE;
