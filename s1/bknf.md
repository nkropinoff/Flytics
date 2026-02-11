## 1НФ
- Аномалия: в таблице payment потенциальным ключом является booking_id
- Решение: Изменен потенциальный первичный ключ, теперь это пара (booking_id, payment_date)

- Аномалия: в таблице booking нет потенциального ключа
- Решение: пара (client_id, booking_date) уникальная 

- Аномалия: в таблице fare нет потенциального ключа
- Решение: пара (flight_id, fare_class_id) уникальная 

## 2НФ
- Аномалия: в таблице aircraft потенциальный ключ (model, airline_id), но capacity зависит только от model
- Решение: Декомпозиция в отдельную таблицы, где model определяет поле capacity

- Аномалия: в таблице flight потенциальным ключом является (flight_number, departure_airport_id, departure_time), но поля departure_airport_id и arrival_airport_id зависят только от flight_number.
- Решение: Декомпозиция в отдельную таблицу, где flight_number определяет departure_airport_id и arrival_airport_id. А в оставшейся таблице flight потенциальным ключом является пара (flight_number, departure_time) и однозначно определяет все поля


