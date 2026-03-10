-- Моделирование обновления данных --

-- 0. Добавим тестовую строку --
INSERT INTO city (name) VALUES ('Samara');

-- 1. До обновления --
SELECT xmin, xmax, ctid, id, name
FROM city
WHERE name = 'Samara';

-- 2. Обновление 1 --
UPDATE city
SET name = 'Samara_v2'
WHERE name = 'Samara';

-- 3. После обновления 1 --
SELECT xmin, xmax, ctid, id, name
FROM city
WHERE name = 'Samara_v2';

-- 4. Обновление 2 --
UPDATE city
SET name = 'Samara_v3'
WHERE name = 'Samara_v2';

-- 5. После обновления 2 --
SELECT xmin, xmax, ctid, id, name
FROM city
WHERE name = 'Samara_v3';

-- 6. Анализ t_infomask
SELECT
    t_ctid,
    t_xmin,
    t_xmax,
    t_infomask
FROM heap_page_items(get_raw_page('city', 0));


--