--
-- PostgreSQL database dump
--

\restrict OXXhZMd9KAt6tkJ57qGLEMnWmBrfgGuRHAMsJEEjVIZ8SWhoB0OI9IFw56xquZ8

-- Dumped from database version 17.8 (Debian 17.8-1.pgdg13+1)
-- Dumped by pg_dump version 17.8 (Debian 17.8-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pageinspect; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pageinspect WITH SCHEMA public;


--
-- Name: EXTENSION pageinspect; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pageinspect IS 'inspect the contents of database pages at a low level';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: aircraft; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aircraft (
    id integer NOT NULL,
    model character varying(50) NOT NULL,
    airline_iata_code character varying(3) NOT NULL
);


ALTER TABLE public.aircraft OWNER TO postgres;

--
-- Name: aircraft_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.aircraft_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.aircraft_id_seq OWNER TO postgres;

--
-- Name: aircraft_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.aircraft_id_seq OWNED BY public.aircraft.id;


--
-- Name: aircraft_model; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aircraft_model (
    model character varying(50) NOT NULL,
    capacity smallint NOT NULL,
    CONSTRAINT aircraft_model_capacity_check CHECK ((capacity > 0))
);


ALTER TABLE public.aircraft_model OWNER TO postgres;

--
-- Name: airline; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.airline (
    iata_code character varying(3) NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.airline OWNER TO postgres;

--
-- Name: airport; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.airport (
    iata_code character varying(3) NOT NULL,
    name character varying(100) NOT NULL,
    city_id integer NOT NULL
);


ALTER TABLE public.airport OWNER TO postgres;

--
-- Name: booking; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.booking (
    id integer NOT NULL,
    client_id integer NOT NULL,
    booking_date timestamp with time zone NOT NULL,
    total_cost integer NOT NULL,
    status_id integer NOT NULL,
    discount_code character varying(50),
    channel character varying(10),
    insurance_amount numeric(10,2),
    CONSTRAINT booking_channel_check CHECK (((channel)::text = ANY ((ARRAY['WEB'::character varying, 'APP'::character varying, 'PARTNER'::character varying, 'OFFLINE'::character varying])::text[])))
);


ALTER TABLE public.booking OWNER TO postgres;

--
-- Name: booking_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.booking_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.booking_id_seq OWNER TO postgres;

--
-- Name: booking_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.booking_id_seq OWNED BY public.booking.id;


--
-- Name: booking_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.booking_status (
    id integer NOT NULL,
    description character varying(50) NOT NULL
);


ALTER TABLE public.booking_status OWNER TO postgres;

--
-- Name: booking_status_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.booking_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.booking_status_id_seq OWNER TO postgres;

--
-- Name: booking_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.booking_status_id_seq OWNED BY public.booking_status.id;


--
-- Name: city; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.city (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.city OWNER TO postgres;

--
-- Name: city_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.city_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.city_id_seq OWNER TO postgres;

--
-- Name: city_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.city_id_seq OWNED BY public.city.id;


--
-- Name: client; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.client (
    id integer NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    password_hash character varying(100) NOT NULL,
    phone_number character varying(20),
    registration_date date DEFAULT CURRENT_DATE,
    loyalty_points integer DEFAULT 0,
    home_address_coords point,
    notes text,
    CONSTRAINT client_loyalty_points_check CHECK ((loyalty_points >= 0))
);


ALTER TABLE public.client OWNER TO postgres;

--
-- Name: client_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.client_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.client_id_seq OWNER TO postgres;

--
-- Name: client_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.client_id_seq OWNED BY public.client.id;


--
-- Name: fare; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fare (
    id integer NOT NULL,
    flight_id integer NOT NULL,
    fare_class_id integer NOT NULL,
    price integer NOT NULL,
    available_seats integer NOT NULL,
    CONSTRAINT fare_available_seats_check CHECK ((available_seats >= 0))
);


ALTER TABLE public.fare OWNER TO postgres;

--
-- Name: fare_class; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fare_class (
    id integer NOT NULL,
    description character varying(50) NOT NULL
);


ALTER TABLE public.fare_class OWNER TO postgres;

--
-- Name: fare_class_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fare_class_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fare_class_id_seq OWNER TO postgres;

--
-- Name: fare_class_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fare_class_id_seq OWNED BY public.fare_class.id;


--
-- Name: fare_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fare_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fare_id_seq OWNER TO postgres;

--
-- Name: fare_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fare_id_seq OWNED BY public.fare.id;


--
-- Name: flight; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.flight (
    id integer NOT NULL,
    flight_number character varying(8) NOT NULL,
    aircraft_id integer NOT NULL,
    departure_time timestamp with time zone NOT NULL,
    arrival_time timestamp with time zone NOT NULL,
    status_id integer NOT NULL,
    flight_tags text[],
    booking_window tstzrange,
    actual_departure timestamp with time zone
);


ALTER TABLE public.flight OWNER TO postgres;

--
-- Name: flight_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.flight_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.flight_id_seq OWNER TO postgres;

--
-- Name: flight_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.flight_id_seq OWNED BY public.flight.id;


--
-- Name: flight_number; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.flight_number (
    number character varying(8) NOT NULL,
    departure_airport_id character varying(3) NOT NULL,
    arrival_airport_id character varying(3) NOT NULL
);


ALTER TABLE public.flight_number OWNER TO postgres;

--
-- Name: flight_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.flight_status (
    id integer NOT NULL,
    description character varying(50) NOT NULL
);


ALTER TABLE public.flight_status OWNER TO postgres;

--
-- Name: flight_status_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.flight_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.flight_status_id_seq OWNER TO postgres;

--
-- Name: flight_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.flight_status_id_seq OWNED BY public.flight_status.id;


--
-- Name: flyway_schema_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.flyway_schema_history (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE public.flyway_schema_history OWNER TO postgres;

--
-- Name: passenger; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.passenger (
    id integer NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    birthdate date NOT NULL,
    passport_series character(4) NOT NULL,
    passport_number character(6) NOT NULL,
    profile_data jsonb,
    gender character(1),
    has_children boolean DEFAULT false,
    CONSTRAINT passenger_gender_check CHECK ((gender = ANY (ARRAY['M'::bpchar, 'F'::bpchar])))
);


ALTER TABLE public.passenger OWNER TO postgres;

--
-- Name: passenger_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.passenger_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.passenger_id_seq OWNER TO postgres;

--
-- Name: passenger_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.passenger_id_seq OWNED BY public.passenger.id;


--
-- Name: payment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment (
    id integer NOT NULL,
    booking_id integer NOT NULL,
    payment_method_id integer NOT NULL,
    payment_status_id integer NOT NULL,
    payment_date timestamp with time zone NOT NULL
);


ALTER TABLE public.payment OWNER TO postgres;

--
-- Name: payment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payment_id_seq OWNER TO postgres;

--
-- Name: payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payment_id_seq OWNED BY public.payment.id;


--
-- Name: payment_method; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment_method (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.payment_method OWNER TO postgres;

--
-- Name: payment_method_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payment_method_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payment_method_id_seq OWNER TO postgres;

--
-- Name: payment_method_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payment_method_id_seq OWNED BY public.payment_method.id;


--
-- Name: payment_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment_status (
    id integer NOT NULL,
    description character varying(50) NOT NULL
);


ALTER TABLE public.payment_status OWNER TO postgres;

--
-- Name: payment_status_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payment_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payment_status_id_seq OWNER TO postgres;

--
-- Name: payment_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payment_status_id_seq OWNED BY public.payment_status.id;


--
-- Name: ticket; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ticket (
    id integer NOT NULL,
    seat_number character varying(4) NOT NULL,
    booking_id integer NOT NULL,
    passenger_id integer NOT NULL,
    fare_id integer NOT NULL,
    flight_id integer NOT NULL
);


ALTER TABLE public.ticket OWNER TO postgres;

--
-- Name: ticket_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ticket_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ticket_id_seq OWNER TO postgres;

--
-- Name: ticket_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ticket_id_seq OWNED BY public.ticket.id;


--
-- Name: aircraft id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aircraft ALTER COLUMN id SET DEFAULT nextval('public.aircraft_id_seq'::regclass);


--
-- Name: booking id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking ALTER COLUMN id SET DEFAULT nextval('public.booking_id_seq'::regclass);


--
-- Name: booking_status id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_status ALTER COLUMN id SET DEFAULT nextval('public.booking_status_id_seq'::regclass);


--
-- Name: city id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.city ALTER COLUMN id SET DEFAULT nextval('public.city_id_seq'::regclass);


--
-- Name: client id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client ALTER COLUMN id SET DEFAULT nextval('public.client_id_seq'::regclass);


--
-- Name: fare id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fare ALTER COLUMN id SET DEFAULT nextval('public.fare_id_seq'::regclass);


--
-- Name: fare_class id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fare_class ALTER COLUMN id SET DEFAULT nextval('public.fare_class_id_seq'::regclass);


--
-- Name: flight id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.flight ALTER COLUMN id SET DEFAULT nextval('public.flight_id_seq'::regclass);


--
-- Name: flight_status id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.flight_status ALTER COLUMN id SET DEFAULT nextval('public.flight_status_id_seq'::regclass);


--
-- Name: passenger id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.passenger ALTER COLUMN id SET DEFAULT nextval('public.passenger_id_seq'::regclass);


--
-- Name: payment id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment ALTER COLUMN id SET DEFAULT nextval('public.payment_id_seq'::regclass);


--
-- Name: payment_method id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_method ALTER COLUMN id SET DEFAULT nextval('public.payment_method_id_seq'::regclass);


--
-- Name: payment_status id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_status ALTER COLUMN id SET DEFAULT nextval('public.payment_status_id_seq'::regclass);


--
-- Name: ticket id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket ALTER COLUMN id SET DEFAULT nextval('public.ticket_id_seq'::regclass);


--
-- Name: aircraft aircraft_model_airline_iata_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aircraft
    ADD CONSTRAINT aircraft_model_airline_iata_code_key UNIQUE (model, airline_iata_code);


--
-- Name: aircraft_model aircraft_model_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aircraft_model
    ADD CONSTRAINT aircraft_model_pkey PRIMARY KEY (model);


--
-- Name: aircraft aircraft_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aircraft
    ADD CONSTRAINT aircraft_pkey PRIMARY KEY (id);


--
-- Name: airline airline_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.airline
    ADD CONSTRAINT airline_pkey PRIMARY KEY (iata_code);


--
-- Name: airport airport_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.airport
    ADD CONSTRAINT airport_pkey PRIMARY KEY (iata_code);


--
-- Name: booking booking_client_id_booking_date_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking
    ADD CONSTRAINT booking_client_id_booking_date_key UNIQUE (client_id, booking_date);


--
-- Name: booking booking_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking
    ADD CONSTRAINT booking_pkey PRIMARY KEY (id);


--
-- Name: booking_status booking_status_description_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_status
    ADD CONSTRAINT booking_status_description_key UNIQUE (description);


--
-- Name: booking_status booking_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_status
    ADD CONSTRAINT booking_status_pkey PRIMARY KEY (id);


--
-- Name: city city_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.city
    ADD CONSTRAINT city_pkey PRIMARY KEY (id);


--
-- Name: client client_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT client_email_key UNIQUE (email);


--
-- Name: client client_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT client_pkey PRIMARY KEY (id);


--
-- Name: fare_class fare_class_description_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fare_class
    ADD CONSTRAINT fare_class_description_key UNIQUE (description);


--
-- Name: fare_class fare_class_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fare_class
    ADD CONSTRAINT fare_class_pkey PRIMARY KEY (id);


--
-- Name: fare fare_flight_id_fare_class_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fare
    ADD CONSTRAINT fare_flight_id_fare_class_id_key UNIQUE (flight_id, fare_class_id);


--
-- Name: fare fare_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fare
    ADD CONSTRAINT fare_pkey PRIMARY KEY (id);


--
-- Name: flight flight_flight_number_departure_time_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.flight
    ADD CONSTRAINT flight_flight_number_departure_time_key UNIQUE (flight_number, departure_time);


--
-- Name: flight_number flight_number_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.flight_number
    ADD CONSTRAINT flight_number_pkey PRIMARY KEY (number);


--
-- Name: flight flight_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.flight
    ADD CONSTRAINT flight_pkey PRIMARY KEY (id);


--
-- Name: flight_status flight_status_description_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.flight_status
    ADD CONSTRAINT flight_status_description_key UNIQUE (description);


--
-- Name: flight_status flight_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.flight_status
    ADD CONSTRAINT flight_status_pkey PRIMARY KEY (id);


--
-- Name: flyway_schema_history flyway_schema_history_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.flyway_schema_history
    ADD CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank);


--
-- Name: passenger passenger_passport_series_passport_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.passenger
    ADD CONSTRAINT passenger_passport_series_passport_number_key UNIQUE (passport_series, passport_number);


--
-- Name: passenger passenger_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.passenger
    ADD CONSTRAINT passenger_pkey PRIMARY KEY (id);


--
-- Name: payment payment_booking_id_payment_date_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_booking_id_payment_date_key UNIQUE (booking_id, payment_date);


--
-- Name: payment_method payment_method_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_method
    ADD CONSTRAINT payment_method_name_key UNIQUE (name);


--
-- Name: payment_method payment_method_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_method
    ADD CONSTRAINT payment_method_pkey PRIMARY KEY (id);


--
-- Name: payment payment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (id);


--
-- Name: payment_status payment_status_description_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_status
    ADD CONSTRAINT payment_status_description_key UNIQUE (description);


--
-- Name: payment_status payment_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_status
    ADD CONSTRAINT payment_status_pkey PRIMARY KEY (id);


--
-- Name: ticket ticket_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT ticket_pkey PRIMARY KEY (id);


--
-- Name: ticket ticket_seat_number_flight_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT ticket_seat_number_flight_id_key UNIQUE (seat_number, flight_id);


--
-- Name: flyway_schema_history_s_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX flyway_schema_history_s_idx ON public.flyway_schema_history USING btree (success);


--
-- Name: aircraft aircraft_airline_iata_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aircraft
    ADD CONSTRAINT aircraft_airline_iata_code_fkey FOREIGN KEY (airline_iata_code) REFERENCES public.airline(iata_code);


--
-- Name: aircraft aircraft_model_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aircraft
    ADD CONSTRAINT aircraft_model_fkey FOREIGN KEY (model) REFERENCES public.aircraft_model(model);


--
-- Name: airport airport_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.airport
    ADD CONSTRAINT airport_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.city(id);


--
-- Name: booking booking_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking
    ADD CONSTRAINT booking_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.client(id);


--
-- Name: booking booking_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking
    ADD CONSTRAINT booking_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.booking_status(id);


--
-- Name: fare fare_fare_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fare
    ADD CONSTRAINT fare_fare_class_id_fkey FOREIGN KEY (fare_class_id) REFERENCES public.fare_class(id);


--
-- Name: fare fare_flight_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fare
    ADD CONSTRAINT fare_flight_id_fkey FOREIGN KEY (flight_id) REFERENCES public.flight(id);


--
-- Name: flight flight_aircraft_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.flight
    ADD CONSTRAINT flight_aircraft_id_fkey FOREIGN KEY (aircraft_id) REFERENCES public.aircraft(id);


--
-- Name: flight flight_flight_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.flight
    ADD CONSTRAINT flight_flight_number_fkey FOREIGN KEY (flight_number) REFERENCES public.flight_number(number);


--
-- Name: flight_number flight_number_arrival_airport_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.flight_number
    ADD CONSTRAINT flight_number_arrival_airport_id_fkey FOREIGN KEY (arrival_airport_id) REFERENCES public.airport(iata_code);


--
-- Name: flight_number flight_number_departure_airport_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.flight_number
    ADD CONSTRAINT flight_number_departure_airport_id_fkey FOREIGN KEY (departure_airport_id) REFERENCES public.airport(iata_code);


--
-- Name: flight flight_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.flight
    ADD CONSTRAINT flight_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.flight_status(id);


--
-- Name: payment payment_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.booking(id);


--
-- Name: payment payment_payment_method_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_payment_method_id_fkey FOREIGN KEY (payment_method_id) REFERENCES public.payment_method(id);


--
-- Name: payment payment_payment_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_payment_status_id_fkey FOREIGN KEY (payment_status_id) REFERENCES public.payment_status(id);


--
-- Name: ticket ticket_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT ticket_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.booking(id);


--
-- Name: ticket ticket_fare_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT ticket_fare_id_fkey FOREIGN KEY (fare_id) REFERENCES public.fare(id);


--
-- Name: ticket ticket_flight_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT ticket_flight_id_fkey FOREIGN KEY (flight_id) REFERENCES public.flight(id);


--
-- Name: ticket ticket_passenger_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT ticket_passenger_id_fkey FOREIGN KEY (passenger_id) REFERENCES public.passenger(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO admin;
GRANT USAGE ON SCHEMA public TO app;
GRANT USAGE ON SCHEMA public TO readonly;


--
-- Name: TABLE aircraft; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.aircraft TO admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.aircraft TO app;
GRANT SELECT ON TABLE public.aircraft TO readonly;


--
-- Name: SEQUENCE aircraft_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.aircraft_id_seq TO admin;
GRANT SELECT,USAGE ON SEQUENCE public.aircraft_id_seq TO app;
GRANT SELECT ON SEQUENCE public.aircraft_id_seq TO readonly;


--
-- Name: TABLE aircraft_model; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.aircraft_model TO admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.aircraft_model TO app;
GRANT SELECT ON TABLE public.aircraft_model TO readonly;


--
-- Name: TABLE airline; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.airline TO admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.airline TO app;
GRANT SELECT ON TABLE public.airline TO readonly;


--
-- Name: TABLE airport; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.airport TO admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.airport TO app;
GRANT SELECT ON TABLE public.airport TO readonly;


--
-- Name: TABLE booking; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.booking TO admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.booking TO app;
GRANT SELECT ON TABLE public.booking TO readonly;


--
-- Name: SEQUENCE booking_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.booking_id_seq TO admin;
GRANT SELECT,USAGE ON SEQUENCE public.booking_id_seq TO app;
GRANT SELECT ON SEQUENCE public.booking_id_seq TO readonly;


--
-- Name: TABLE booking_status; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.booking_status TO admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.booking_status TO app;
GRANT SELECT ON TABLE public.booking_status TO readonly;


--
-- Name: SEQUENCE booking_status_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.booking_status_id_seq TO admin;
GRANT SELECT,USAGE ON SEQUENCE public.booking_status_id_seq TO app;
GRANT SELECT ON SEQUENCE public.booking_status_id_seq TO readonly;


--
-- Name: TABLE city; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.city TO admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.city TO app;
GRANT SELECT ON TABLE public.city TO readonly;


--
-- Name: SEQUENCE city_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.city_id_seq TO admin;
GRANT SELECT,USAGE ON SEQUENCE public.city_id_seq TO app;
GRANT SELECT ON SEQUENCE public.city_id_seq TO readonly;


--
-- Name: TABLE client; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.client TO admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.client TO app;
GRANT SELECT ON TABLE public.client TO readonly;


--
-- Name: SEQUENCE client_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.client_id_seq TO admin;
GRANT SELECT,USAGE ON SEQUENCE public.client_id_seq TO app;
GRANT SELECT ON SEQUENCE public.client_id_seq TO readonly;


--
-- Name: TABLE fare; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.fare TO admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.fare TO app;
GRANT SELECT ON TABLE public.fare TO readonly;


--
-- Name: TABLE fare_class; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.fare_class TO admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.fare_class TO app;
GRANT SELECT ON TABLE public.fare_class TO readonly;


--
-- Name: SEQUENCE fare_class_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.fare_class_id_seq TO admin;
GRANT SELECT,USAGE ON SEQUENCE public.fare_class_id_seq TO app;
GRANT SELECT ON SEQUENCE public.fare_class_id_seq TO readonly;


--
-- Name: SEQUENCE fare_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.fare_id_seq TO admin;
GRANT SELECT,USAGE ON SEQUENCE public.fare_id_seq TO app;
GRANT SELECT ON SEQUENCE public.fare_id_seq TO readonly;


--
-- Name: TABLE flight; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.flight TO admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.flight TO app;
GRANT SELECT ON TABLE public.flight TO readonly;


--
-- Name: SEQUENCE flight_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.flight_id_seq TO admin;
GRANT SELECT,USAGE ON SEQUENCE public.flight_id_seq TO app;
GRANT SELECT ON SEQUENCE public.flight_id_seq TO readonly;


--
-- Name: TABLE flight_number; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.flight_number TO admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.flight_number TO app;
GRANT SELECT ON TABLE public.flight_number TO readonly;


--
-- Name: TABLE flight_status; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.flight_status TO admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.flight_status TO app;
GRANT SELECT ON TABLE public.flight_status TO readonly;


--
-- Name: SEQUENCE flight_status_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.flight_status_id_seq TO admin;
GRANT SELECT,USAGE ON SEQUENCE public.flight_status_id_seq TO app;
GRANT SELECT ON SEQUENCE public.flight_status_id_seq TO readonly;


--
-- Name: TABLE flyway_schema_history; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.flyway_schema_history TO admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.flyway_schema_history TO app;
GRANT SELECT ON TABLE public.flyway_schema_history TO readonly;


--
-- Name: TABLE passenger; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.passenger TO admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.passenger TO app;
GRANT SELECT ON TABLE public.passenger TO readonly;


--
-- Name: SEQUENCE passenger_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.passenger_id_seq TO admin;
GRANT SELECT,USAGE ON SEQUENCE public.passenger_id_seq TO app;
GRANT SELECT ON SEQUENCE public.passenger_id_seq TO readonly;


--
-- Name: TABLE payment; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.payment TO admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.payment TO app;
GRANT SELECT ON TABLE public.payment TO readonly;


--
-- Name: SEQUENCE payment_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.payment_id_seq TO admin;
GRANT SELECT,USAGE ON SEQUENCE public.payment_id_seq TO app;
GRANT SELECT ON SEQUENCE public.payment_id_seq TO readonly;


--
-- Name: TABLE payment_method; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.payment_method TO admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.payment_method TO app;
GRANT SELECT ON TABLE public.payment_method TO readonly;


--
-- Name: SEQUENCE payment_method_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.payment_method_id_seq TO admin;
GRANT SELECT,USAGE ON SEQUENCE public.payment_method_id_seq TO app;
GRANT SELECT ON SEQUENCE public.payment_method_id_seq TO readonly;


--
-- Name: TABLE payment_status; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.payment_status TO admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.payment_status TO app;
GRANT SELECT ON TABLE public.payment_status TO readonly;


--
-- Name: SEQUENCE payment_status_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.payment_status_id_seq TO admin;
GRANT SELECT,USAGE ON SEQUENCE public.payment_status_id_seq TO app;
GRANT SELECT ON SEQUENCE public.payment_status_id_seq TO readonly;


--
-- Name: TABLE ticket; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.ticket TO admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.ticket TO app;
GRANT SELECT ON TABLE public.ticket TO readonly;


--
-- Name: SEQUENCE ticket_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.ticket_id_seq TO admin;
GRANT SELECT,USAGE ON SEQUENCE public.ticket_id_seq TO app;
GRANT SELECT ON SEQUENCE public.ticket_id_seq TO readonly;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO admin;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,USAGE ON SEQUENCES TO app;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT ON SEQUENCES TO readonly;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO admin;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES TO app;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT ON TABLES TO readonly;


--
-- PostgreSQL database dump complete
--

\unrestrict OXXhZMd9KAt6tkJ57qGLEMnWmBrfgGuRHAMsJEEjVIZ8SWhoB0OI9IFw56xquZ8

