-- 3. Создание рейсов
INSERT INTO flight (flight_number, aircraft_id, departure_time, arrival_time, status_id, flight_tags, booking_window)
VALUES
    ('SU100', 1, '2026-05-01 10:00:00+00', '2026-05-01 12:00:00+00', 1, '{"wifi", "meal"}', '["2025-05-01 10:00:00+00", "2026-04-30 10:00:00+00"]'),
    ('DP200', 3, '2026-05-02 15:00:00+00', '2026-05-02 18:00:00+00', 1, '{}', '["2025-05-02 15:00:00+00", "2026-05-01 15:00:00+00"]')
ON CONFLICT (flight_number, departure_time) DO UPDATE
    SET flight_tags = EXCLUDED.flight_tags,
        booking_window = EXCLUDED.booking_window,
        status_id = EXCLUDED.status_id;