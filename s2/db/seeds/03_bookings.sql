-- 4. Создание бронирований
INSERT INTO booking (client_id, booking_date, total_cost, status_id, discount_code, channel, insurance_amount)
VALUES
    ((SELECT id FROM client WHERE email = 'ivan.ivanov@example.com'), '2026-04-01 12:00:00+00', 15000, 2, 'SPRING26', 'WEB', 1500.00),
    ((SELECT id FROM client WHERE email = 'anna.smirnova@example.com'), '2026-04-05 14:30:00+00', 10000, 2, NULL, 'APP', 0.00)
ON CONFLICT (client_id, booking_date) DO UPDATE
    SET total_cost = EXCLUDED.total_cost,
        channel = EXCLUDED.channel,
        insurance_amount = EXCLUDED.insurance_amount;
