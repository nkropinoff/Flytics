5. CASE

Категоризация стоимости бронирования.

```sql
CREATE OR REPLACE FUNCTION categorize_booking_price(booking_id INT)
RETURNS VARCHAR(20)
LANGUAGE plpgsql
AS $$
DECLARE
	current_cost INT;
	category VARCHAR(20);
BEGIN
	SELECT total_cost
	INTO current_cost
	FROM booking
	WHERE id = booking_id;

	category := CASE
		WHEN current_cost <= 10000 THEN 'low'
		WHEN current_cost <= 30000 THEN 'medium'
		ELSE 'high'
	END;

	RETURN category;
END;
$$;
SELECT total_cost, categorize_booking_price(15) AS booking_price_category
FROM booking
WHERE id = 15
```
![](images/img101.png)


6. WHILE

6.1. Создание тестовых клиентов с помощью цикла.

```sql
CREATE OR REPLACE PROCEDURE create_test_clients(count_clients INT)
LANGUAGE plpgsql
AS $$
DECLARE
    i INT := 1;
BEGIN
    WHILE i <= count_clients LOOP
        INSERT INTO client (first_name, last_name, email, password_hash)
        VALUES (
            'TestFirstName' || i,
            'TestLastName' || i,
            'testclient' || i || '@example.com',
            'hash' || i
        );
        i := i + 1;
    END LOOP;
END;
$$;
CALL create_test_clients(3);
SELECT * FROM client
```
![](images/img102.png)

6.2. Статистика по классам перелетов.
```sql
CREATE OR REPLACE FUNCTION count_fare_classes_stats()
RETURNS TABLE(class_id INT, total_flights BIGINT, avg_price NUMERIC)
LANGUAGE plpgsql
AS $$
DECLARE
    total_classes INT;
    current_id INT := 1;
BEGIN
    SELECT COUNT(*) INTO total_classes FROM fare_class;
    WHILE current_id <= total_classes LOOP
        SELECT 
            current_id,
            COUNT(f.id),
            AVG(f.price)
        INTO class_id, total_flights, avg_price
        FROM fare f 
        WHERE f.fare_class_id = current_id;
        RETURN NEXT;
        current_id := current_id + 1;
    END LOOP;
END;
$$;
SELECT * FROM count_fare_classes_stats();
```
![](images/img103.png)


7. EXCEPTION

7.1. Попытка добавить уже существующую авиакомпанию.
```sql
CREATE OR REPLACE FUNCTION safe_insert_airline(
    p_iata_code VARCHAR(3),
    p_name VARCHAR(100)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO airline (iata_code, name)
    VALUES (p_iata_code, p_name);
EXCEPTION
    WHEN unique_violation THEN
        NULL;
END;
$$;
SELECT safe_insert_airline('TST', 'Test Airlines');
```
![](images/img104.png)
![](images/img105.png)

7.2. Попытка деления на ноль.
```sql
CREATE OR REPLACE FUNCTION calculate_occupancy_rate(
    p_passengers INT,
    p_capacity INT
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (p_passengers::NUMERIC / p_capacity::NUMERIC) * 100;
EXCEPTION
    WHEN division_by_zero THEN
        RETURN 0;
END;
$$;
SELECT calculate_occupancy_rate(150, 200);
SELECT calculate_occupancy_rate(130, 0);
```
![](images/img106.png)
![](images/img107.png)
