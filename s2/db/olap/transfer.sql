-- 1. dim_date
INSERT INTO olap.dim_date (date_id, full_date, day_name)
SELECT TO_CHAR(d, 'YYYYMMDD')::INT AS date_id,
       d::DATE                     AS full_date,
       TO_CHAR(d, 'Day')           AS day_name
FROM generate_series(
                     CURRENT_DATE - INTERVAL '5 years',
                     CURRENT_DATE + INTERVAL '1 year',
                     INTERVAL '1 day'
     ) AS d
ON CONFLICT (date_id) DO NOTHING;

-- 2. dim_channel
INSERT INTO olap.dim_channel (channel_name)
VALUES ('WEB'),
       ('APP'),
       ('PARTNER'),
       ('OFFLINE')
ON CONFLICT (channel_name) DO NOTHING;

-- 3. fact_bookings
INSERT INTO olap.fact_bookings (booking_id, date_id, channel_id, total_cost)
SELECT b.id                                     AS booking_id,
       TO_CHAR(b.booking_date, 'YYYYMMDD')::INT AS date_id,
       dc.channel_id,
       b.total_cost
FROM public.booking b
         JOIN olap.dim_channel dc ON dc.channel_name = b.channel
ON CONFLICT (booking_id) DO NOTHING;