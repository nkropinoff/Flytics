CREATE TABLE city (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);
CREATE TABLE airport (
    iata_code VARCHAR(3) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city_id INT NOT NULL REFERENCES city(id)
);
CREATE TABLE airline (
    iata_code VARCHAR(3) PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);
CREATE TABLE aircraft_model (
    model VARCHAR(50) PRIMARY KEY,
    capacity SMALLINT NOT NULL CHECK (capacity > 0)
);
CREATE TABLE aircraft (
    id SERIAL PRIMARY KEY,
    model VARCHAR(50) NOT NULL REFERENCES aircraft_model(model),
    airline_iata_code VARCHAR(3) NOT NULL REFERENCES airline(iata_code),
    UNIQUE(model, airline_iata_code)
);
CREATE TABLE flight_status (
    id SERIAL PRIMARY KEY,
    description VARCHAR(50) UNIQUE NOT NULL
);
CREATE TABLE flight_number (
    number VARCHAR(8) PRIMARY KEY,
    departure_airport_id VARCHAR(3) NOT NULL REFERENCES airport(iata_code),
    arrival_airport_id VARCHAR(3) NOT NULL REFERENCES airport(iata_code)
);
CREATE TABLE flight (
    id SERIAL PRIMARY KEY,
    flight_number VARCHAR(8) NOT NULL REFERENCES flight_number(number),    
    aircraft_id INT NOT NULL REFERENCES aircraft(id),
    departure_time TIMESTAMPTZ NOT NULL,
    arrival_time TIMESTAMPTZ NOT NULL,
    status_id INT NOT NULL REFERENCES flight_status(id),
    UNIQUE(flight_number, departure_time)
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
  total_cost INT NOT NULL,
  status_id INT NOT NULL,
  FOREIGN KEY (status_id) REFERENCES booking_status(id),
  FOREIGN KEY (client_id) REFERENCES client(id),
  UNIQUE(client_id, booking_date)
);
CREATE TABLE passenger (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  birthdate DATE NOT NULL,
  passport_series CHAR(4) NOT NULL,
  passport_number CHAR(6) NOT NULL,
  UNIQUE(passport_series, passport_number)
);
CREATE TABLE fare_class (
  id SERIAL PRIMARY KEY,
  description VARCHAR(50) UNIQUE NOT NULL
);
CREATE TABLE fare (
  id SERIAL PRIMARY KEY,
  flight_id INT NOT NULL,
  fare_class_id INT NOT NULL,
  price INT NOT NULL,
  available_seats INT NOT NULL CHECK (available_seats >= 0),
  FOREIGN KEY (fare_class_id) REFERENCES fare_class(id),
  FOREIGN KEY (flight_id) REFERENCES flight(id),
  UNIQUE(flight_id, fare_class_id)
);
CREATE TABLE ticket (
  id SERIAL PRIMARY KEY,
  seat_number VARCHAR(4) NOT NULL,
  booking_id INT NOT NULL,
  passenger_id INT NOT NULL,
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
    booking_id INT NOT NULL,
    payment_method_id INT NOT NULL,
    payment_status_id INT NOT NULL,
    payment_date TIMESTAMPTZ NOT NULL,
    FOREIGN KEY (booking_id) REFERENCES booking(id),
    FOREIGN KEY (payment_method_id) REFERENCES payment_method(id),
    FOREIGN KEY (payment_status_id) REFERENCES payment_status(id),
    UNIQUE(booking_id, payment_date)
);