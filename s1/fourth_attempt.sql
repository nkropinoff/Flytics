CREATE TABLE city (
	id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL
);

CREATE TABLE airport (
	id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	iata_code VARCHAR(3) UNIQUE,
	city_id INT NOT NULL REFERENCES city(id)
);

CREATE TABLE airline (
	id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	iata_code VARCHAR(3) UNIQUE NOT NULL
);

CREATE TABLE aircraft (
	id SERIAL PRIMARY KEY,
	model VARCHAR(50) NOT NULL,
	capacity SMALLINT NOT NULL CHECK (capacity > 0),
	airline_id INT NOT NULL REFERENCES airline(id)
);

CREATE TABLE flight_status (
	id SERIAL PRIMARY KEY,
	description VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE flight (
	id SERIAL PRIMARY KEY,
	fight_number VARCHAR(8) NOT NULL,
	airline_id INT NOT NULL REFERENCES airline(id),
	aircraft_id INT NOT NULL REFERENCES aircraft(id),
	departure_airport_id INT NOT NULL REFERENCES airport(id),
	arrival_airport_id INT NOT NULL REFERENCES airport(id),
	departure_time TIMESTAMPTZ NOT NULL,
	arrival_time TIMESTAMPTZ NOT NULL,
	status_id INT NOT NULL REFERENCES flight_status(id),
	
	UNIQUE(number, departure_airport_id, departure_time)
);

CREATE TABLE client (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(100) NOT NULL
);

CREATE TABLE booking_status (
  id SERIAL PRIMARY KEY,
  description VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE booking (
  id SERIAL PRIMARY KEY,
  client_id INT NOT NULL,
  booking_date TIMESTAMPTZ NOT NULL,
  total_cost NUMERIC(10, 2) NOT NULL,
  status_id INT NOT NULL,
  FOREIGN KEY (status_id) REFERENCES booking_status(id),
  FOREIGN KEY (client_id) REFERENCES client(id)
);

CREATE TABLE passenger (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  birthdate DATE NOT NULL,
  passport_series CHAR(4) NOT NULL,
  passport_number CHAR(6) NOT NULL
);

CREATE TABLE fare_class (
  id SERIAL PRIMARY KEY,
  description VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE fare (
  id SERIAL PRIMARY KEY,
  flight_id INT NOT NULL,
  fare_class_id INT NOT NULL,
  price NUMERIC(10, 2) NOT NULL,
  available_seats INT NOT NULL CHECK (available_seats >= 0),
  FOREIGN KEY (fare_class_id) REFERENCES fare_class(id),
  FOREIGN KEY (flight_id) REFERENCES flight(id)
);

CREATE TABLE ticket (
  id SERIAL PRIMARY KEY,
  seat_number VARCHAR(4) NOT NULL,
  booking_id INT NOT NULL,
  passenger_id INT NOT NULL,
  price NUMERIC(10, 2) NOT NULL,
  fare_id INT NOT NULL,
  flight_id INT NOT NULL,
  FOREIGN KEY (flight_id) REFERENCES flight(id),
  FOREIGN KEY (fare_id) REFERENCES fare(id),
  FOREIGN KEY (passenger_id) REFERENCES passenger(id),
  FOREIGN KEY (booking_id) REFERENCES booking(id),
  UNIQUE (seat_number, flight_id)
);

CREATE TABLE payment_status (
  id SERIAL PRIMARY KEY,
  description VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE payment_method (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE payment (
    id SERIAL PRIMARY KEY,
    booking_id INT NOT NULL UNIQUE,
    amount NUMERIC(10, 2) NOT NULL CHECK (amount > 0),
    payment_method_id INT NOT NULL,
    payment_status_id INT NOT NULL,
    payment_date TIMESTAMPTZ NOT NULL,
  
    FOREIGN KEY (booking_id) REFERENCES booking(id),
    FOREIGN KEY (payment_method_id) REFERENCES payment_method(id),
    FOREIGN KEY (payment_status_id) REFERENCES payment_status(id)
);


ALTER TABLE passenger ADD COLUMN biography varchar(300);
ALTER TABLE passenger ALTER COLUMN biography TYPE text;
ALTER TABLE passenger ALTER COLUMN biography SET NOT NULL;
ALTER TABLE passenger DROP COLUMN biography;

INSERT INTO city (name) 
VALUES ('Kazan');

INSERT INTO city (name) 
VALUES ('Moscow');

INSERT INTO city (name) 
VALUES ('Cheboksary');

INSERT INTO city (name) 
VALUES ('Yoshkar-Ola');

INSERT INTO city (name) 
VALUES ('Sochi');

INSERT INTO airport (name, iata_code, city_id)
VALUES ('Международный аэропорт Шереметьево имени А. С. Пушкина', 'SVO', 2);

INSERT INTO airport (name, iata_code, city_id)
VALUES ('Аэропорт Чебоксары имени А. Г. Николаева', 'CSY', 3);

INSERT INTO airport (name, iata_code, city_id)
VALUES ('Международный аэропорт Казань имени Габдуллы Тукая', 'KZN', 1);

INSERT INTO airport (name, iata_code, city_id)
VALUES ('Аэропорт Йошкар-Ола', 'JOK', 4);

INSERT INTO airport (name, iata_code, city_id)
VALUES ('Международный аэропорт имени В. И. Севастьянова', 'AER', 5);

INSERT INTO airline (name, iata_code)
VALUES ('S7 Airlines', 'S7');

INSERT INTO airline (name, iata_code)
VALUES ('Аэрофлот — Российские авиалинии', 'SU');

INSERT INTO airline (name, iata_code)
VALUES ('Победа', 'DP');

INSERT INTO airline (name, iata_code)
VALUES ('Россия', 'FV');

INSERT INTO airline (name, iata_code)
VALUES ('UTair', 'UT');

INSERT INTO aircraft (model, capacity, airline_id)
VALUES ('Airbus A320', 174, 1);

INSERT INTO aircraft (model, capacity, airline_id)
VALUES ('Airbus A321', 189, 1);

INSERT INTO aircraft (model, capacity, airline_id)
VALUES ('Boeing 737-800', 189, 3);

INSERT INTO aircraft (model, capacity, airline_id)
VALUES ('Boeing 747-400', 522, 4);

INSERT INTO aircraft (model, capacity, airline_id)
VALUES ('Boeing 777-300ER', 402, 2);

INSERT INTO flight_status (description)
VALUES ('On time');

INSERT INTO flight_status (description)
VALUES ('Delayed');

INSERT INTO flight_status (description)
VALUES ('Landed');

INSERT INTO flight_status (description)
VALUES ('Cancelled');

INSERT INTO flight (flight_number, airline_id, aircraft_id, departure_airport_id, arrival_airport_id, departure_time, arrival_time, status_id)
VALUES('SU1234', 2, 5, 3, 2, '2025-10-26 14:30:00+03', '2025-10-26 16:00:00+03', 3);

INSERT INTO flight (flight_number, airline_id, aircraft_id, departure_airport_id, arrival_airport_id, departure_time, arrival_time, status_id)
VALUES('S79999', 1, 1, 1, 5, '2025-09-09 11:35:00+03', '2025-10-26 15:46:00+03', 3);

INSERT INTO flight (flight_number, airline_id, aircraft_id, departure_airport_id, arrival_airport_id, departure_time, arrival_time, status_id)
VALUES('FV5773', 4, 4, 4, 1, '2025-10-28 22:30:00+03', '2025-10-29 00:20:00+03', 1);

INSERT INTO flight (flight_number, airline_id, aircraft_id, departure_airport_id, arrival_airport_id, departure_time, arrival_time, status_id)
VALUES('DP2286', 3, 3, 5, 3, '2025-10-27 06:30:00+03', '2025-10-27 11:00:00+03', 4);

INSERT INTO flight (flight_number, airline_id, aircraft_id, departure_airport_id, arrival_airport_id, departure_time, arrival_time, status_id)
VALUES('S71916', 1, 2, 3, 1, '2025-10-28 20:28:00+03', '2025-10-28 22:57:00+03', 3);

INSERT INTO booking_status (description)
VALUES ('processing');

INSERT INTO booking_status (description)
VALUES ('success');

INSERT INTO booking_status (description)
VALUES ('failed');

INSERT INTO client (first_name, last_name, email, password_hash)
VALUES ('EGOR', 'SOROKIN', 'egorik2006@gmail.com', '5d640ca634edfaa17813cab1492208f2');

INSERT INTO client (first_name, last_name, email, password_hash)
VALUES ('NIKITA', 'KROPINOV', 'kropinof2005@gmail.com', '5d750ca634edfaa17813cab1492208f2');

INSERT INTO client (first_name, last_name, email, password_hash)
VALUES ('AMIR', 'KHUBEEV', 'amir2006@gmail.com', '5d640ca634edfaa17820cab1492208c2');

INSERT INTO payment_status (description)
VALUES ('processing');

INSERT INTO payment_status (description)
VALUES ('success');

INSERT INTO payment_status (description)
VALUES ('failed');

INSERT INTO payment_method (name)
VALUES ('SberPay');

INSERT INTO payment_method (name)
VALUES ('YandexPay');

INSERT INTO payment_method (name)
VALUES ('T-Pay');

INSERT INTO fare_class (description)
VALUES ('Economy class');

INSERT INTO fare_class (description)
VALUES ('Business class');

INSERT INTO fare_class (description)
VALUES ('First class');

INSERT INTO booking (client_id, booking_date, total_cost, status_id)
VALUES 
  (1, NOW(), 5000.00, 1),
  (2, NOW(), 7500.00, 2),
  (3, NOW(), 10500.00, 3);

INSERT INTO payment (booking_id, amount, payment_method_id, payment_status_id, payment_date)
VALUES
  (1, 600, 1, 3, '2025-09-1'),
  (2, 660, 3, 2, '2025-08-16'),
  (3, 666, 2, 2, '2025-07-28');

INSERT INTO passenger (first_name, last_name, birthdate, passport_series, passport_number)
VALUES
  ('EGOR', 'SOROKIN', '2006-10-26', '9730', '527153'),
  ('NIKITA', 'KROPINOF', '2005-11-18', '1920', '445978'),
  ('AMIR', 'KHUBEEV', '2006-06-08', '1111', '212121');

INSERT INTO fare (flight_id, fare_class_id, price, available_seats)
VALUES
  (1, 1, 15000, 100),
  (2, 3, 75000, 10),
  (3, 2, 35000, 30);

INSERT INTO ticket (seat_number, booking_id, passenger_id, price, fare_id, flight_id)
VALUES
  ('A1', 1, 3, 15000, 1, 1),
  ('B5', 2, 2, 75000, 2, 1),
  ('C12', 1, 2, 35000, 3, 1)

UPDATE passenger
SET passport_series=7777
WHERE first_name='AMIR'

UPDATE client
SET email='amir2006@yandex.ru'
WHERE last_name='KHUBEEV'

UPDATE aircraft
SET capacity=523
WHERE model='Boeing 747-400'