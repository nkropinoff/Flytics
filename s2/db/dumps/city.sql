--
-- PostgreSQL database dump
--

\restrict OgIh8Y8de8NsJpF1OF3DZADMBehbbczT2ksIAspFAHrCE7igHaGKHDnk4ACoi36

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

SET default_tablespace = '';

SET default_table_access_method = heap;

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
-- Name: city id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.city ALTER COLUMN id SET DEFAULT nextval('public.city_id_seq'::regclass);


--
-- Data for Name: city; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.city (id, name) FROM stdin;
1	Kazan
2	Moscow
3	Cheboksary
4	Yoshkar-Ola
5	Sochi
6	City_In_Progress
\.


--
-- Name: city_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.city_id_seq', 6, true);


--
-- Name: city city_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.city
    ADD CONSTRAINT city_pkey PRIMARY KEY (id);


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
-- PostgreSQL database dump complete
--

\unrestrict OgIh8Y8de8NsJpF1OF3DZADMBehbbczT2ksIAspFAHrCE7igHaGKHDnk4ACoi36

