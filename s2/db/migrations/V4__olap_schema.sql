CREATE SCHEMA IF NOT EXISTS olap;

-- dim_date
CREATE TABLE olap.dim_date
(
    date_id   INT PRIMARY KEY, -- YYYYMMDD
    full_date DATE        NOT NULL,
    day_name  VARCHAR(15) NOT NULL
);

-- dim_channel
CREATE TABLE olap.dim_channel
(
    channel_id   SERIAL PRIMARY KEY,
    channel_name VARCHAR(10) NOT NULL UNIQUE
);

-- fact_bookings
CREATE TABLE olap.fact_bookings
(
    booking_id INT PRIMARY KEY,
    date_id    INT NOT NULL REFERENCES olap.dim_date (date_id),
    channel_id INT NOT NULL REFERENCES olap.dim_channel (channel_id),
    total_cost INT NOT NULL
);