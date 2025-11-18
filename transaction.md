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
