ALTER TABLE client
    ADD COLUMN phone_number VARCHAR(20),
    ADD COLUMN registration_date DATE DEFAULT CURRENT_DATE,
    ADD COLUMN loyalty_points INT DEFAULT 0 CHECK (loyalty_points >= 0),
    ADD COLUMN home_address_coords POINT,
    ADD COLUMN notes TEXT;

ALTER TABLE passenger
    ADD COLUMN profile_data JSONB,
    ADD COLUMN gender CHAR(1) CHECK (gender IN ('M', 'F')),
    ADD COLUMN has_children BOOLEAN DEFAULT FALSE;

ALTER TABLE flight
    ADD COLUMN flight_tags TEXT[],
    ADD COLUMN booking_window TSTZRANGE,
    ADD COLUMN actual_departure TIMESTAMPTZ;

ALTER TABLE booking
    ADD COLUMN discount_code VARCHAR(50),
    ADD COLUMN channel VARCHAR(10) CHECK (channel IN ('WEB', 'APP', 'PARTNER', 'OFFLINE')),
    ADD COLUMN insurance_amount NUMERIC(10, 2);
