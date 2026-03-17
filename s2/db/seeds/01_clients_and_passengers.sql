-- 1. Создание клиентов
INSERT INTO client (first_name, last_name, email, password_hash, phone_number, registration_date, loyalty_points, home_address_coords, notes)
VALUES
    ('Ivan', 'Ivanov', 'ivan.ivanov@example.com', 'hashed_pass_1', '+79991234567', '2023-01-15', 150, point(55.7558, 37.6173), 'VIP client'),
    ('Anna', 'Smirnova', 'anna.smirnova@example.com', 'hashed_pass_2', '+79997654321', '2024-05-20', 0, NULL, 'Regular user')
ON CONFLICT (email) DO UPDATE
    SET phone_number = EXCLUDED.phone_number,
        loyalty_points = EXCLUDED.loyalty_points,
        notes = EXCLUDED.notes;

-- 2. Создание пассажиров
INSERT INTO passenger (first_name, last_name, birthdate, passport_series, passport_number, profile_data, gender, has_children)
VALUES
    ('Ivan', 'Ivanov', '1990-05-15', '1234', '567890', '{"meal": "vegan", "seat_preference": "window"}', 'M', FALSE),
    ('Anna', 'Smirnova', '1995-10-20', '4321', '098765', '{"meal": "standard", "seat_preference": "aisle"}', 'F', TRUE)
ON CONFLICT (passport_series, passport_number) DO UPDATE
    SET profile_data = EXCLUDED.profile_data,
        has_children = EXCLUDED.has_children;