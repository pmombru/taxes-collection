--
-- PostgreSQL database dump
--

-- Dumped from database version 11.5
-- Dumped by pg_dump version 11.5

-- Started on 2019-09-18 15:21:09

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2980 (class 1262 OID 16385)
-- Name: TaxesCollection; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "TaxesCollection" WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Spanish_Argentina.1252' LC_CTYPE = 'Spanish_Argentina.1252';


ALTER DATABASE "TaxesCollection" OWNER TO postgres;

\connect "TaxesCollection"

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 227 (class 1255 OID 16388)
-- Name: ownedcompaniestaxpayed(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ownedcompaniestaxpayed(individual_id integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$
/***********************************************************************************
Objective: Returns the total amount of taxes payed by all the companies owned/co-owned by an individual
Inputs: Individual ID
Outputs:
- If the individual id exists, returns the total amount of taxed payed
- If the individual id does not exist, returns NULL
************************************************************************************/
DECLARE
	amount numeric;	
BEGIN

	SELECT SUM(A.AMOUNT)
	INTO STRICT amount
	FROM TAX_PAYMENT A, OWN_REL B
	WHERE B.INDIVIDUAL_ID = $1
	AND A.TAXPAYER_ID = B.COMPANY_ID;

	RETURN amount;
END;$_$;


ALTER FUNCTION public.ownedcompaniestaxpayed(individual_id integer) OWNER TO postgres;

--
-- TOC entry 214 (class 1255 OID 16389)
-- Name: totaltaxpermonth(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.totaltaxpermonth(taxpayer_id integer) RETURNS TABLE(tax_amount numeric, year double precision, month double precision)
    LANGUAGE sql
    AS $_$
/***********************************************************************************
Objective: Returns a list of total amounts of taxes payed by a taxpayer and by month
Inputs: Taxpayer ID
Outputs: A table with columns TAX_AMOUNT, YEAR, MONTH. The table is ordered by YEAR and MONTH in descending way
************************************************************************************/
SELECT SUM(FOO.AMOUNT) TAX_AMOUNT, FOO.YEAR, FOO.MONTH
FROM
(SELECT AMOUNT, PAYMENT_DATE, EXTRACT (YEAR FROM PAYMENT_DATE) AS YEAR, EXTRACT (MONTH FROM PAYMENT_DATE) AS MONTH
FROM TAX_PAYMENT A
WHERE A.TAXPAYER_ID = $1) AS FOO
GROUP BY FOO.YEAR, FOO.MONTH
ORDER BY FOO.YEAR DESC, FOO.MONTH DESC;
$_$;


ALTER FUNCTION public.totaltaxpermonth(taxpayer_id integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 196 (class 1259 OID 16853)
-- Name: agency; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.agency (
    agency_id integer NOT NULL,
    number character varying NOT NULL,
    address character varying NOT NULL,
    person_in_charge character varying NOT NULL,
    number_of_emp integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    created_by character varying NOT NULL
);


ALTER TABLE public.agency OWNER TO postgres;

--
-- TOC entry 197 (class 1259 OID 16859)
-- Name: agency_agency_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.agency_agency_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.agency_agency_id_seq OWNER TO postgres;

--
-- TOC entry 2982 (class 0 OID 0)
-- Dependencies: 197
-- Name: agency_agency_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.agency_agency_id_seq OWNED BY public.agency.agency_id;


--
-- TOC entry 198 (class 1259 OID 16861)
-- Name: agency_phone_number; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.agency_phone_number (
    rel_id integer NOT NULL,
    agency_id integer NOT NULL,
    phone_number character varying NOT NULL,
    phone_type_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    created_by character varying NOT NULL
);


ALTER TABLE public.agency_phone_number OWNER TO postgres;

--
-- TOC entry 199 (class 1259 OID 16867)
-- Name: agency_phone_number_rel_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.agency_phone_number_rel_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.agency_phone_number_rel_id_seq OWNER TO postgres;

--
-- TOC entry 2984 (class 0 OID 0)
-- Dependencies: 199
-- Name: agency_phone_number_rel_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.agency_phone_number_rel_id_seq OWNED BY public.agency_phone_number.rel_id;


--
-- TOC entry 200 (class 1259 OID 16869)
-- Name: company; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.company (
    taxpayer_id integer NOT NULL,
    cuit_number character varying NOT NULL,
    commencement_date date NOT NULL,
    website character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying DEFAULT CURRENT_USER NOT NULL
);


ALTER TABLE public.company OWNER TO postgres;

--
-- TOC entry 201 (class 1259 OID 16877)
-- Name: individual; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.individual (
    taxpayer_id integer NOT NULL,
    doc_number character varying NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    date_of_birth date NOT NULL,
    home_address character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying DEFAULT CURRENT_USER NOT NULL
);


ALTER TABLE public.individual OWNER TO postgres;

--
-- TOC entry 202 (class 1259 OID 16885)
-- Name: own_rel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.own_rel (
    rel_id integer NOT NULL,
    individual_id integer NOT NULL,
    company_id integer NOT NULL,
    start_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying DEFAULT CURRENT_USER NOT NULL
);


ALTER TABLE public.own_rel OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 16894)
-- Name: own_rel_rel_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.own_rel_rel_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.own_rel_rel_id_seq OWNER TO postgres;

--
-- TOC entry 2988 (class 0 OID 0)
-- Dependencies: 203
-- Name: own_rel_rel_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.own_rel_rel_id_seq OWNED BY public.own_rel.rel_id;


--
-- TOC entry 204 (class 1259 OID 16896)
-- Name: phone_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.phone_type (
    phone_type_id integer NOT NULL,
    type character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying DEFAULT CURRENT_USER NOT NULL
);


ALTER TABLE public.phone_type OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 16904)
-- Name: phone_type_phone_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.phone_type_phone_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.phone_type_phone_type_id_seq OWNER TO postgres;

--
-- TOC entry 2990 (class 0 OID 0)
-- Dependencies: 205
-- Name: phone_type_phone_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.phone_type_phone_type_id_seq OWNED BY public.phone_type.phone_type_id;


--
-- TOC entry 206 (class 1259 OID 16906)
-- Name: tax_payment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tax_payment (
    payment_id integer NOT NULL,
    agency_id integer NOT NULL,
    taxpayer_id integer NOT NULL,
    amount numeric NOT NULL,
    payment_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    tax_type_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying DEFAULT CURRENT_USER NOT NULL
);


ALTER TABLE public.tax_payment OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 16915)
-- Name: tax_payment_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tax_payment_payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tax_payment_payment_id_seq OWNER TO postgres;

--
-- TOC entry 2992 (class 0 OID 0)
-- Dependencies: 207
-- Name: tax_payment_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tax_payment_payment_id_seq OWNED BY public.tax_payment.payment_id;


--
-- TOC entry 208 (class 1259 OID 16917)
-- Name: tax_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tax_type (
    tax_type_id integer NOT NULL,
    type character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying DEFAULT CURRENT_USER NOT NULL
);


ALTER TABLE public.tax_type OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 16925)
-- Name: tax_type_tax_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tax_type_tax_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tax_type_tax_type_id_seq OWNER TO postgres;

--
-- TOC entry 2994 (class 0 OID 0)
-- Dependencies: 209
-- Name: tax_type_tax_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tax_type_tax_type_id_seq OWNED BY public.tax_type.tax_type_id;


--
-- TOC entry 210 (class 1259 OID 16927)
-- Name: taxpayer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.taxpayer (
    taxpayer_id integer NOT NULL,
    type character varying NOT NULL,
    email character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying DEFAULT CURRENT_USER NOT NULL
);


ALTER TABLE public.taxpayer OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 16935)
-- Name: taxpayer_phone_number; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.taxpayer_phone_number (
    rel_id integer NOT NULL,
    taxpayer_id integer NOT NULL,
    phone_number character varying NOT NULL,
    phone_type_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying DEFAULT CURRENT_USER NOT NULL
);


ALTER TABLE public.taxpayer_phone_number OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 16943)
-- Name: taxpayer_phone_number_rel_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.taxpayer_phone_number_rel_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.taxpayer_phone_number_rel_id_seq OWNER TO postgres;

--
-- TOC entry 2997 (class 0 OID 0)
-- Dependencies: 212
-- Name: taxpayer_phone_number_rel_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.taxpayer_phone_number_rel_id_seq OWNED BY public.taxpayer_phone_number.rel_id;


--
-- TOC entry 213 (class 1259 OID 16945)
-- Name: taxpayer_taxpayer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.taxpayer_taxpayer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.taxpayer_taxpayer_id_seq OWNER TO postgres;

--
-- TOC entry 2998 (class 0 OID 0)
-- Dependencies: 213
-- Name: taxpayer_taxpayer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.taxpayer_taxpayer_id_seq OWNED BY public.taxpayer.taxpayer_id;


--
-- TOC entry 2748 (class 2604 OID 16947)
-- Name: agency agency_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agency ALTER COLUMN agency_id SET DEFAULT nextval('public.agency_agency_id_seq'::regclass);


--
-- TOC entry 2750 (class 2604 OID 16948)
-- Name: agency_phone_number rel_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agency_phone_number ALTER COLUMN rel_id SET DEFAULT nextval('public.agency_phone_number_rel_id_seq'::regclass);


--
-- TOC entry 2763 (class 2604 OID 16949)
-- Name: own_rel rel_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.own_rel ALTER COLUMN rel_id SET DEFAULT nextval('public.own_rel_rel_id_seq'::regclass);


--
-- TOC entry 2768 (class 2604 OID 16950)
-- Name: phone_type phone_type_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.phone_type ALTER COLUMN phone_type_id SET DEFAULT nextval('public.phone_type_phone_type_id_seq'::regclass);


--
-- TOC entry 2773 (class 2604 OID 16951)
-- Name: tax_payment payment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_payment ALTER COLUMN payment_id SET DEFAULT nextval('public.tax_payment_payment_id_seq'::regclass);


--
-- TOC entry 2779 (class 2604 OID 16952)
-- Name: tax_type tax_type_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_type ALTER COLUMN tax_type_id SET DEFAULT nextval('public.tax_type_tax_type_id_seq'::regclass);


--
-- TOC entry 2783 (class 2604 OID 16953)
-- Name: taxpayer taxpayer_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taxpayer ALTER COLUMN taxpayer_id SET DEFAULT nextval('public.taxpayer_taxpayer_id_seq'::regclass);


--
-- TOC entry 2789 (class 2604 OID 16954)
-- Name: taxpayer_phone_number rel_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taxpayer_phone_number ALTER COLUMN rel_id SET DEFAULT nextval('public.taxpayer_phone_number_rel_id_seq'::regclass);


--
-- TOC entry 2957 (class 0 OID 16853)
-- Dependencies: 196
-- Data for Name: agency; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.agency (agency_id, number, address, person_in_charge, number_of_emp, created_at, created_by) VALUES (1, '1', '5th Av. 400', 'Dana Harris', 10, '2019-09-09 14:59:56.557672', 'postgres');
INSERT INTO public.agency (agency_id, number, address, person_in_charge, number_of_emp, created_at, created_by) VALUES (2, '2', 'Jacksonville 2323', 'Jack Craig', 15, '2019-09-09 14:59:56.557672', 'postgres');
INSERT INTO public.agency (agency_id, number, address, person_in_charge, number_of_emp, created_at, created_by) VALUES (3, '3', 'Park Ave. 210', 'Ashley Roy', 7, '2019-09-10 14:51:11.043039', 'postgres');
INSERT INTO public.agency (agency_id, number, address, person_in_charge, number_of_emp, created_at, created_by) VALUES (6, '4', 'North Av. 550', 'Jack Daniels', 5, '2019-09-13 09:22:09.738156', 'postgres');


--
-- TOC entry 2959 (class 0 OID 16861)
-- Dependencies: 198
-- Data for Name: agency_phone_number; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.agency_phone_number (rel_id, agency_id, phone_number, phone_type_id, created_at, created_by) VALUES (1, 1, '47474747', 1, '2019-09-09 15:00:05.562036', 'postgres');
INSERT INTO public.agency_phone_number (rel_id, agency_id, phone_number, phone_type_id, created_at, created_by) VALUES (2, 1, '57575757', 2, '2019-09-09 15:00:05.562036', 'postgres');
INSERT INTO public.agency_phone_number (rel_id, agency_id, phone_number, phone_type_id, created_at, created_by) VALUES (3, 2, '71717171', 1, '2019-09-09 15:00:05.562036', 'postgres');


--
-- TOC entry 2961 (class 0 OID 16869)
-- Dependencies: 200
-- Data for Name: company; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.company (taxpayer_id, cuit_number, commencement_date, website, created_at, created_by) VALUES (2, '4781010', '2005-07-22', 'www.newcompany.com', '2019-09-09 14:59:12.357671', 'postgres');
INSERT INTO public.company (taxpayer_id, cuit_number, commencement_date, website, created_at, created_by) VALUES (3, '21212121', '2007-11-01', 'www.abccompany.com', '2019-09-09 14:59:12.357671', 'postgres');
INSERT INTO public.company (taxpayer_id, cuit_number, commencement_date, website, created_at, created_by) VALUES (4, '34343434', '2008-01-20', 'www.xtracompany.com', '2019-09-09 14:59:12.357671', 'postgres');
INSERT INTO public.company (taxpayer_id, cuit_number, commencement_date, website, created_at, created_by) VALUES (6, '102020', '2001-03-21', 'www.byco.com', '2019-09-09 14:59:12.357671', 'postgres');
INSERT INTO public.company (taxpayer_id, cuit_number, commencement_date, website, created_at, created_by) VALUES (7, '717171717171', '2003-12-07', 'www.nextco.com', '2019-09-09 14:59:12.357671', 'postgres');
INSERT INTO public.company (taxpayer_id, cuit_number, commencement_date, website, created_at, created_by) VALUES (11, '40404040', '2001-10-10', 'www.test.com', '2019-09-09 17:18:20.312411', 'postgres');
INSERT INTO public.company (taxpayer_id, cuit_number, commencement_date, website, created_at, created_by) VALUES (17, '20201010', '2019-02-21', 'www.cdhcompany.com', '2019-09-11 15:39:59.663919', 'postgres');
INSERT INTO public.company (taxpayer_id, cuit_number, commencement_date, website, created_at, created_by) VALUES (25, '12340987', '2007-02-02', 'www.test2lmted.com', '2019-09-13 10:32:41.691266', 'postgres');
INSERT INTO public.company (taxpayer_id, cuit_number, commencement_date, website, created_at, created_by) VALUES (27, '1111111111', '2007-04-02', 'www.test5lmted.com', '2019-09-13 10:44:52.235455', 'postgres');
INSERT INTO public.company (taxpayer_id, cuit_number, commencement_date, website, created_at, created_by) VALUES (31, '222222222', '2007-11-02', 'www.test6lmted.com', '2019-09-13 10:47:01.327014', 'postgres');
INSERT INTO public.company (taxpayer_id, cuit_number, commencement_date, website, created_at, created_by) VALUES (32, '3333333', '2008-10-17', 'www.test7lmted.com', '2019-09-13 10:49:34.202729', 'postgres');
INSERT INTO public.company (taxpayer_id, cuit_number, commencement_date, website, created_at, created_by) VALUES (34, '444444444', '2009-11-07', 'www.test8lmted.com', '2019-09-13 10:54:32.440007', 'postgres');
INSERT INTO public.company (taxpayer_id, cuit_number, commencement_date, website, created_at, created_by) VALUES (38, '5555', '2010-12-07', 'www.test9lmted.com', '2019-09-13 11:01:18.111006', 'postgres');
INSERT INTO public.company (taxpayer_id, cuit_number, commencement_date, website, created_at, created_by) VALUES (41, '80808080', '2005-07-10', 'www.abctest.com', '2019-09-16 11:00:39.448538', 'postgres');
INSERT INTO public.company (taxpayer_id, cuit_number, commencement_date, website, created_at, created_by) VALUES (42, '9191', '2010-08-10', 'www.truetest.com', '2019-09-16 11:05:35.436566', 'postgres');
INSERT INTO public.company (taxpayer_id, cuit_number, commencement_date, website, created_at, created_by) VALUES (47, '4040', '2011-08-10', 'www.truetest.com', '2019-09-16 11:14:18.990897', 'postgres');
INSERT INTO public.company (taxpayer_id, cuit_number, commencement_date, website, created_at, created_by) VALUES (50, '20202121', '2005-11-22', 'www.test20lmted.com', '2019-09-18 09:36:04.961103', 'postgres');
INSERT INTO public.company (taxpayer_id, cuit_number, commencement_date, website, created_at, created_by) VALUES (51, '21212222', '2005-01-20', 'www.test21lmted.com', '2019-09-18 09:38:57.706731', 'postgres');


--
-- TOC entry 2962 (class 0 OID 16877)
-- Dependencies: 201
-- Data for Name: individual; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.individual (taxpayer_id, doc_number, first_name, last_name, date_of_birth, home_address, created_at, created_by) VALUES (1, '12345678', 'John', 'Jackson', '1997-10-10', 'Newark Ave. 132', '2019-09-09 14:59:02.363352', 'postgres');
INSERT INTO public.individual (taxpayer_id, doc_number, first_name, last_name, date_of_birth, home_address, created_at, created_by) VALUES (5, '5151515151', 'Annie', 'Wilson', '1990-07-21', 'Jackson Park Ave. 4321', '2019-09-09 14:59:02.363352', 'postgres');


--
-- TOC entry 2963 (class 0 OID 16885)
-- Dependencies: 202
-- Data for Name: own_rel; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by) VALUES (1, 1, 2, '2005-07-22 00:00:00', '2019-09-09 14:59:30.373851', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by) VALUES (2, 1, 3, '2007-11-01 00:00:00', '2019-09-09 14:59:30.373851', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by) VALUES (3, 1, 4, '2008-01-20 00:00:00', '2019-09-09 14:59:30.373851', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by) VALUES (4, 5, 6, '2001-03-21 00:00:00', '2019-09-09 14:59:30.373851', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by) VALUES (5, 5, 7, '2003-12-07 00:00:00', '2019-09-09 14:59:30.373851', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by) VALUES (15, 1, 11, '2001-10-10 00:00:00', '2019-09-09 17:18:20.312411', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by) VALUES (16, 5, 11, '2001-10-10 00:00:00', '2019-09-09 17:18:20.312411', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by) VALUES (18, 1, 27, '2007-04-02 00:00:00', '2019-09-13 10:44:52.235455', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by) VALUES (22, 5, 31, '2007-11-02 00:00:00', '2019-09-13 10:47:01.327014', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by) VALUES (23, 1, 32, '2008-10-17 00:00:00', '2019-09-13 10:49:34.202729', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by) VALUES (24, 5, 32, '2008-10-17 00:00:00', '2019-09-13 10:49:34.202729', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by) VALUES (25, 1, 34, '2009-11-07 00:00:00', '2019-09-13 10:54:32.440007', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by) VALUES (26, 5, 34, '2009-11-07 00:00:00', '2019-09-13 10:54:32.440007', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by) VALUES (27, 1, 38, '2010-12-07 00:00:00', '2019-09-13 11:01:18.111006', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by) VALUES (28, 5, 38, '2010-12-07 00:00:00', '2019-09-13 11:01:18.111006', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by) VALUES (29, 5, 42, '2010-08-10 00:00:00', '2019-09-16 11:05:35.436566', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by) VALUES (30, 1, 42, '2010-08-10 00:00:00', '2019-09-16 11:05:35.436566', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by) VALUES (34, 5, 47, '2011-08-10 00:00:00', '2019-09-16 11:14:18.990897', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by) VALUES (35, 1, 47, '2011-08-10 00:00:00', '2019-09-16 11:14:18.990897', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by) VALUES (36, 1, 50, '2005-11-22 00:00:00', '2019-09-18 09:36:04.961103', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by) VALUES (37, 5, 50, '2005-11-22 00:00:00', '2019-09-18 09:36:04.961103', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by) VALUES (38, 5, 51, '2005-01-20 00:00:00', '2019-09-18 09:38:57.706731', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by) VALUES (39, 1, 51, '2005-01-20 00:00:00', '2019-09-18 09:38:57.706731', 'postgres');


--
-- TOC entry 2965 (class 0 OID 16896)
-- Dependencies: 204
-- Data for Name: phone_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.phone_type (phone_type_id, type, created_at, created_by) VALUES (1, 'Landline', '2019-09-09 14:58:25.717285', 'postgres');
INSERT INTO public.phone_type (phone_type_id, type, created_at, created_by) VALUES (2, 'Mobile', '2019-09-09 14:58:25.717285', 'postgres');
INSERT INTO public.phone_type (phone_type_id, type, created_at, created_by) VALUES (3, 'Fax', '2019-09-09 14:58:25.717285', 'postgres');


--
-- TOC entry 2967 (class 0 OID 16906)
-- Dependencies: 206
-- Data for Name: tax_payment; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (1, 1, 1, 170, '2019-03-14 00:00:00', 1, '2019-09-09 15:00:25.633404', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (2, 1, 1, 2500, '2019-04-17 00:00:00', 3, '2019-09-09 15:00:25.633404', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (3, 2, 2, 17000, '2019-04-20 00:00:00', 4, '2019-09-09 15:00:25.633404', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (4, 1, 1, 200, '2019-03-17 00:00:00', 2, '2019-09-09 15:00:25.633404', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (5, 1, 1, 1000, '2019-04-21 00:00:00', 3, '2019-09-09 15:00:25.633404', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (6, 1, 2, 2500, '2019-07-10 00:00:00', 4, '2019-09-09 15:00:25.633404', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (7, 2, 3, 1000, '2019-07-11 00:00:00', 2, '2019-09-09 15:00:25.633404', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (9, 1, 4, 7000, '2019-02-20 00:00:00', 4, '2019-09-09 15:00:25.633404', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (10, 1, 4, 2700, '2019-06-17 00:00:00', 3, '2019-09-09 15:00:25.633404', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (11, 1, 4, 1300, '2019-08-25 00:00:00', 2, '2019-09-09 15:00:25.633404', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (12, 2, 6, 500, '2019-01-25 00:00:00', 4, '2019-09-09 15:00:25.633404', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (13, 2, 6, 800, '2019-04-04 00:00:00', 1, '2019-09-09 15:00:25.633404', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (14, 1, 7, 8000, '2019-04-30 00:00:00', 4, '2019-09-09 15:00:25.633404', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (18, 2, 7, 5500, '2019-04-30 00:00:00', 4, '2019-09-09 15:08:19.109291', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (22, 1, 1, 250, '2019-09-10 00:00:00', 1, '2019-09-11 16:01:14.102663', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (23, 1, 2, 2000, '2019-03-14 00:00:00', 4, '2019-09-13 09:09:07.748269', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (24, 2, 4, 1890, '2019-07-14 00:00:00', 3, '2019-09-13 09:14:29.554568', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (25, 3, 5, 880, '2019-01-22 00:00:00', 4, '2019-09-13 09:31:40.716798', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (26, 3, 7, 1000, '2019-02-21 00:00:00', 2, '2019-09-13 09:35:26.074262', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (27, 1, 7, 2000, '2019-03-21 00:00:00', 3, '2019-09-13 09:37:23.303826', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (28, 2, 38, 8000, '2019-09-13 00:00:00', 4, '2019-09-13 11:20:10.332918', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (36, 2, 42, 290, '2018-03-14 00:00:00', 1, '2019-09-16 11:59:33.796616', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (37, 1, 42, 370, '2018-03-22 00:00:00', 2, '2019-09-16 11:59:33.796616', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (38, 1, 42, 500, '2018-03-25 00:00:00', 4, '2019-09-16 11:59:33.796616', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (39, 2, 42, 570, '2018-10-22 00:00:00', 4, '2019-09-16 11:59:33.796616', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (40, 1, 47, 1000, '2018-10-01 00:00:00', 4, '2019-09-16 11:59:33.796616', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (41, 2, 42, 800, '2019-03-14 00:00:00', 1, '2019-09-16 12:01:22.204421', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (42, 2, 42, 900, '2019-04-17 00:00:00', 3, '2019-09-16 14:16:45.237399', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (44, 2, 42, 1500, '2019-05-17 00:00:00', 4, '2019-09-16 14:19:44.594542', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (45, 2, 42, 550, '2018-05-17 00:00:00', 1, '2019-09-16 14:20:25.751476', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (46, 2, 42, 2000, '2017-02-15 00:00:00', 1, '2019-09-16 14:21:03.680738', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (47, 2, 42, 3000, '2017-03-15 00:00:00', 1, '2019-09-16 14:21:32.431987', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (48, 2, 42, 950, '2017-04-15 00:00:00', 4, '2019-09-16 14:21:44.771896', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (49, 2, 42, 1000, '2017-04-22 00:00:00', 3, '2019-09-16 14:22:08.209987', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by) VALUES (53, 1, 5, 1000, '2019-09-10 00:00:00', 1, '2019-09-18 15:05:58.979543', 'postgres');


--
-- TOC entry 2969 (class 0 OID 16917)
-- Dependencies: 208
-- Data for Name: tax_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tax_type (tax_type_id, type, created_at, created_by) VALUES (1, 'Stamp Duty', '2019-09-09 15:00:14.131541', 'postgres');
INSERT INTO public.tax_type (tax_type_id, type, created_at, created_by) VALUES (2, 'Real Estate', '2019-09-09 15:00:14.131541', 'postgres');
INSERT INTO public.tax_type (tax_type_id, type, created_at, created_by) VALUES (3, 'Automotive Patent', '2019-09-09 15:00:14.131541', 'postgres');
INSERT INTO public.tax_type (tax_type_id, type, created_at, created_by) VALUES (4, 'Gross Income', '2019-09-09 15:00:14.131541', 'postgres');


--
-- TOC entry 2971 (class 0 OID 16927)
-- Dependencies: 210
-- Data for Name: taxpayer; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by) VALUES (2, 'C', 'taxpayer2@gmail.com', '2019-09-09 14:58:37.372677', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by) VALUES (3, 'C', 'taxpayer3@gmail.com', '2019-09-09 14:58:37.372677', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by) VALUES (4, 'C', 'taxpayer4@gmail.com', '2019-09-09 14:58:37.372677', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by) VALUES (5, 'I', 'taxpayer5@gmail.com', '2019-09-09 14:58:37.372677', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by) VALUES (6, 'C', 'taxpayer6@gmail.com', '2019-09-09 14:58:37.372677', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by) VALUES (7, 'C', 'taxpayer7@gmail.com', '2019-09-09 14:58:37.372677', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by) VALUES (11, 'C', 'test@yahoo.com', '2019-09-09 17:18:20.312411', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by) VALUES (1, 'I', 'taxpayer111@gmail.com', '2019-09-09 14:58:37.372677', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by) VALUES (17, 'C', 'taxpayer8@gmail.com', '2019-09-10 17:39:58.597244', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by) VALUES (24, 'I', 'taxpayer10@gmail.com', '2019-09-11 15:55:29.480214', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by) VALUES (25, 'C', 'taxpayer12@gmail.com', '2019-09-13 10:32:41.691266', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by) VALUES (27, 'C', 'taxpayer13@gmail.com', '2019-09-13 10:44:52.235455', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by) VALUES (31, 'C', 'taxpayer14@gmail.com', '2019-09-13 10:47:01.327014', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by) VALUES (32, 'C', 'taxpayer15@gmail.com', '2019-09-13 10:49:34.202729', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by) VALUES (34, 'C', 'taxpayer16@gmail.com', '2019-09-13 10:54:32.440007', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by) VALUES (38, 'C', 'taxpayer17@gmail.com', '2019-09-13 11:01:18.111006', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by) VALUES (41, 'C', 'taxpayer15@gmail.com', '2019-09-16 11:00:39.448538', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by) VALUES (42, 'C', 'taxpayer18@gmail.com', '2019-09-16 11:05:35.436566', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by) VALUES (47, 'C', 'taxpayer18@gmail.com', '2019-09-16 11:14:18.990897', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by) VALUES (50, 'C', 'taxpayer20@gmail.com', '2019-09-18 09:36:04.961103', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by) VALUES (51, 'C', 'taxpayer21@gmail.com', '2019-09-18 09:38:57.706731', 'postgres');


--
-- TOC entry 2972 (class 0 OID 16935)
-- Dependencies: 211
-- Data for Name: taxpayer_phone_number; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (1, 1, '11111111', 1, '2019-09-09 14:58:48.86957', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (2, 1, '22222222', 2, '2019-09-09 14:58:48.86957', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (3, 2, '33333333', 1, '2019-09-09 14:58:48.86957', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (10, 11, '5555555', 1, '2019-09-09 17:18:20.312411', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (11, 11, '77777777', 2, '2019-09-09 17:18:20.312411', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (12, 27, '10101010', 1, '2019-09-13 10:44:52.235455', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (14, 31, '10101010', 3, '2019-09-13 10:47:01.327014', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (15, 32, '10101010', 3, '2019-09-13 10:49:34.202729', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (16, 32, '20202020', 1, '2019-09-13 10:49:34.202729', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (17, 32, '30303030', 2, '2019-09-13 10:49:34.202729', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (18, 34, '41414141', 3, '2019-09-13 10:54:32.440007', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (19, 34, '71717171', 1, '2019-09-13 10:54:32.440007', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (20, 34, '9191919191', 2, '2019-09-13 10:54:32.440007', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (21, 38, '41414141', 3, '2019-09-13 11:01:18.111006', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (22, 38, '71717171', 1, '2019-09-13 11:01:18.111006', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (23, 38, '9191919191', 2, '2019-09-13 11:01:18.111006', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (27, 41, '7575757575', 1, '2019-09-16 11:00:39.448538', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (28, 41, '88888888', 2, '2019-09-16 11:00:39.448538', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (29, 41, '7777777777', 3, '2019-09-16 11:00:39.448538', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (30, 42, '5454545454', 1, '2019-09-16 11:05:35.436566', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (31, 42, '10203040', 2, '2019-09-16 11:05:35.436566', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (32, 42, '7777777777', 3, '2019-09-16 11:05:35.436566', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (33, 47, '5454545454', 1, '2019-09-16 11:14:18.990897', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (34, 47, '10203040', 2, '2019-09-16 11:14:18.990897', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (35, 47, '7777777777', 3, '2019-09-16 11:14:18.990897', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (36, 50, '10101010', 1, '2019-09-18 09:36:04.961103', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (37, 50, '20202020', 2, '2019-09-18 09:36:04.961103', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (38, 50, '30303030', 2, '2019-09-18 09:36:04.961103', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (39, 51, '30303030', 1, '2019-09-18 09:38:57.706731', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (40, 51, '20202020', 2, '2019-09-18 09:38:57.706731', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by) VALUES (41, 51, '10101010', 3, '2019-09-18 09:38:57.706731', 'postgres');


--
-- TOC entry 2999 (class 0 OID 0)
-- Dependencies: 197
-- Name: agency_agency_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.agency_agency_id_seq', 1, false);


--
-- TOC entry 3000 (class 0 OID 0)
-- Dependencies: 199
-- Name: agency_phone_number_rel_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.agency_phone_number_rel_id_seq', 1, false);


--
-- TOC entry 3001 (class 0 OID 0)
-- Dependencies: 203
-- Name: own_rel_rel_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.own_rel_rel_id_seq', 1, false);


--
-- TOC entry 3002 (class 0 OID 0)
-- Dependencies: 205
-- Name: phone_type_phone_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.phone_type_phone_type_id_seq', 1, false);


--
-- TOC entry 3003 (class 0 OID 0)
-- Dependencies: 207
-- Name: tax_payment_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tax_payment_payment_id_seq', 1, false);


--
-- TOC entry 3004 (class 0 OID 0)
-- Dependencies: 209
-- Name: tax_type_tax_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tax_type_tax_type_id_seq', 1, false);


--
-- TOC entry 3005 (class 0 OID 0)
-- Dependencies: 212
-- Name: taxpayer_phone_number_rel_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.taxpayer_phone_number_rel_id_seq', 1, false);


--
-- TOC entry 3006 (class 0 OID 0)
-- Dependencies: 213
-- Name: taxpayer_taxpayer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.taxpayer_taxpayer_id_seq', 1, false);


--
-- TOC entry 2774 (class 2606 OID 16956)
-- Name: tax_payment Amount must be a positive value; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.tax_payment
    ADD CONSTRAINT "Amount must be a positive value" CHECK ((amount > (0)::numeric)) NOT VALID;


--
-- TOC entry 2758 (class 2606 OID 16968)
-- Name: individual Birth date cannot be after current date; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.individual
    ADD CONSTRAINT "Birth date cannot be after current date" CHECK ((date_of_birth <= CURRENT_TIMESTAMP)) NOT VALID;


--
-- TOC entry 2754 (class 2606 OID 16957)
-- Name: company Commencement date cannot be after current date; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.company
    ADD CONSTRAINT "Commencement date cannot be after current date" CHECK ((commencement_date <= CURRENT_TIMESTAMP)) NOT VALID;


--
-- TOC entry 2749 (class 2606 OID 16958)
-- Name: agency Created At date cannot be after current date; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.agency
    ADD CONSTRAINT "Created At date cannot be after current date" CHECK ((created_at <= CURRENT_TIMESTAMP)) NOT VALID;


--
-- TOC entry 2751 (class 2606 OID 16959)
-- Name: agency_phone_number Created At date cannot be after current date; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.agency_phone_number
    ADD CONSTRAINT "Created At date cannot be after current date" CHECK ((created_at <= CURRENT_TIMESTAMP)) NOT VALID;


--
-- TOC entry 2755 (class 2606 OID 16960)
-- Name: company Created At date cannot be after current date; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.company
    ADD CONSTRAINT "Created At date cannot be after current date" CHECK ((created_at <= CURRENT_TIMESTAMP)) NOT VALID;


--
-- TOC entry 2759 (class 2606 OID 16961)
-- Name: individual Created At date cannot be after current date; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.individual
    ADD CONSTRAINT "Created At date cannot be after current date" CHECK ((created_at <= CURRENT_TIMESTAMP)) NOT VALID;


--
-- TOC entry 2764 (class 2606 OID 16962)
-- Name: own_rel Created At date cannot be after current date; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.own_rel
    ADD CONSTRAINT "Created At date cannot be after current date" CHECK ((created_at <= CURRENT_TIMESTAMP)) NOT VALID;


--
-- TOC entry 2769 (class 2606 OID 16963)
-- Name: phone_type Created At date cannot be after current date; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.phone_type
    ADD CONSTRAINT "Created At date cannot be after current date" CHECK ((created_at <= CURRENT_TIMESTAMP)) NOT VALID;


--
-- TOC entry 2775 (class 2606 OID 16964)
-- Name: tax_payment Created At date cannot be after current date; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.tax_payment
    ADD CONSTRAINT "Created At date cannot be after current date" CHECK ((created_at <= CURRENT_TIMESTAMP)) NOT VALID;


--
-- TOC entry 2780 (class 2606 OID 16965)
-- Name: tax_type Created At date cannot be after current date; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.tax_type
    ADD CONSTRAINT "Created At date cannot be after current date" CHECK ((created_at <= CURRENT_TIMESTAMP)) NOT VALID;


--
-- TOC entry 2790 (class 2606 OID 16966)
-- Name: taxpayer_phone_number Created At date cannot be after current date; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.taxpayer_phone_number
    ADD CONSTRAINT "Created At date cannot be after current date" CHECK ((created_at <= CURRENT_TIMESTAMP)) NOT VALID;


--
-- TOC entry 2784 (class 2606 OID 16967)
-- Name: taxpayer Created At date cannot be after current date; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.taxpayer
    ADD CONSTRAINT "Created At date cannot be after current date" CHECK ((created_at <= CURRENT_TIMESTAMP)) NOT VALID;


--
-- TOC entry 2785 (class 2606 OID 16969)
-- Name: taxpayer Email must have a valid format; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.taxpayer
    ADD CONSTRAINT "Email must have a valid format" CHECK (((email)::text ~ similar_escape('[A-Za-z0-9._%-]+@[A-Za-z0-9._%-]+\.[A-Za-z]{2,4}'::text, NULL::text))) NOT VALID;


--
-- TOC entry 2776 (class 2606 OID 16970)
-- Name: tax_payment Payment date cannot be after current date; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.tax_payment
    ADD CONSTRAINT "Payment date cannot be after current date" CHECK ((payment_date <= CURRENT_TIMESTAMP)) NOT VALID;


--
-- TOC entry 2765 (class 2606 OID 16971)
-- Name: own_rel Start date cannot be after current date; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.own_rel
    ADD CONSTRAINT "Start date cannot be after current date" CHECK ((start_date <= CURRENT_TIMESTAMP)) NOT VALID;


--
-- TOC entry 2786 (class 2606 OID 16972)
-- Name: taxpayer Type can only be C for Company or I for Individual; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.taxpayer
    ADD CONSTRAINT "Type can only be C for Company or I for Individual" CHECK (((type)::text = ANY (ARRAY[('I'::character varying)::text, ('C'::character varying)::text]))) NOT VALID;


--
-- TOC entry 2792 (class 2606 OID 16974)
-- Name: agency agency_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agency
    ADD CONSTRAINT agency_number_key UNIQUE (number);


--
-- TOC entry 2796 (class 2606 OID 16976)
-- Name: agency_phone_number agency_phone_number_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agency_phone_number
    ADD CONSTRAINT agency_phone_number_pkey PRIMARY KEY (rel_id);


--
-- TOC entry 2794 (class 2606 OID 16978)
-- Name: agency agency_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agency
    ADD CONSTRAINT agency_pkey PRIMARY KEY (agency_id);


--
-- TOC entry 2799 (class 2606 OID 16980)
-- Name: company company_cuit_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT company_cuit_number_key UNIQUE (cuit_number);


--
-- TOC entry 2801 (class 2606 OID 16982)
-- Name: company company_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT company_pkey PRIMARY KEY (taxpayer_id);


--
-- TOC entry 2803 (class 2606 OID 16984)
-- Name: individual individual_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individual
    ADD CONSTRAINT individual_pkey PRIMARY KEY (taxpayer_id);


--
-- TOC entry 2805 (class 2606 OID 16986)
-- Name: own_rel own_rel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.own_rel
    ADD CONSTRAINT own_rel_pkey PRIMARY KEY (rel_id);


--
-- TOC entry 2808 (class 2606 OID 16988)
-- Name: phone_type phone_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.phone_type
    ADD CONSTRAINT phone_type_pkey PRIMARY KEY (phone_type_id);


--
-- TOC entry 2810 (class 2606 OID 16990)
-- Name: phone_type phone_type_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.phone_type
    ADD CONSTRAINT phone_type_type_key UNIQUE (type);


--
-- TOC entry 2812 (class 2606 OID 16992)
-- Name: tax_payment tax_payment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_payment
    ADD CONSTRAINT tax_payment_pkey PRIMARY KEY (payment_id);


--
-- TOC entry 2815 (class 2606 OID 16994)
-- Name: tax_type tax_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_type
    ADD CONSTRAINT tax_type_pkey PRIMARY KEY (tax_type_id);


--
-- TOC entry 2817 (class 2606 OID 16996)
-- Name: tax_type tax_type_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_type
    ADD CONSTRAINT tax_type_type_key UNIQUE (type);


--
-- TOC entry 2821 (class 2606 OID 16998)
-- Name: taxpayer_phone_number taxpayer_phone_number_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taxpayer_phone_number
    ADD CONSTRAINT taxpayer_phone_number_pkey PRIMARY KEY (rel_id);


--
-- TOC entry 2819 (class 2606 OID 17000)
-- Name: taxpayer taxpayer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taxpayer
    ADD CONSTRAINT taxpayer_pkey PRIMARY KEY (taxpayer_id);


--
-- TOC entry 2797 (class 1259 OID 17001)
-- Name: agency_phone_number_u_1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX agency_phone_number_u_1 ON public.agency_phone_number USING btree (agency_id, phone_number);


--
-- TOC entry 2806 (class 1259 OID 17002)
-- Name: own_rel_u_1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX own_rel_u_1 ON public.own_rel USING btree (individual_id, company_id);


--
-- TOC entry 2813 (class 1259 OID 17003)
-- Name: tax_payment_u_1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX tax_payment_u_1 ON public.tax_payment USING btree (agency_id, taxpayer_id, payment_date, tax_type_id);


--
-- TOC entry 2822 (class 1259 OID 17004)
-- Name: taxpayer_phone_number_u_1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX taxpayer_phone_number_u_1 ON public.taxpayer_phone_number USING btree (taxpayer_id, phone_number);


--
-- TOC entry 2823 (class 2606 OID 17005)
-- Name: agency_phone_number agency_phone_number_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agency_phone_number
    ADD CONSTRAINT agency_phone_number_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agency(agency_id);


--
-- TOC entry 2824 (class 2606 OID 17010)
-- Name: agency_phone_number agency_phone_number_phone_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agency_phone_number
    ADD CONSTRAINT agency_phone_number_phone_type_id_fkey FOREIGN KEY (phone_type_id) REFERENCES public.phone_type(phone_type_id);


--
-- TOC entry 2825 (class 2606 OID 17015)
-- Name: company company_taxpayer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT company_taxpayer_id_fkey FOREIGN KEY (taxpayer_id) REFERENCES public.taxpayer(taxpayer_id);


--
-- TOC entry 2826 (class 2606 OID 17020)
-- Name: individual individual_taxpayer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individual
    ADD CONSTRAINT individual_taxpayer_id_fkey FOREIGN KEY (taxpayer_id) REFERENCES public.taxpayer(taxpayer_id);


--
-- TOC entry 2827 (class 2606 OID 17025)
-- Name: own_rel own_rel_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.own_rel
    ADD CONSTRAINT own_rel_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.company(taxpayer_id);


--
-- TOC entry 2828 (class 2606 OID 17030)
-- Name: own_rel own_rel_individual_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.own_rel
    ADD CONSTRAINT own_rel_individual_id_fkey FOREIGN KEY (individual_id) REFERENCES public.individual(taxpayer_id);


--
-- TOC entry 2829 (class 2606 OID 17035)
-- Name: tax_payment tax_payment_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_payment
    ADD CONSTRAINT tax_payment_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agency(agency_id);


--
-- TOC entry 2830 (class 2606 OID 17040)
-- Name: tax_payment tax_payment_tax_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_payment
    ADD CONSTRAINT tax_payment_tax_type_id_fkey FOREIGN KEY (tax_type_id) REFERENCES public.tax_type(tax_type_id);


--
-- TOC entry 2831 (class 2606 OID 17045)
-- Name: tax_payment tax_payment_taxpayer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_payment
    ADD CONSTRAINT tax_payment_taxpayer_id_fkey FOREIGN KEY (taxpayer_id) REFERENCES public.taxpayer(taxpayer_id);


--
-- TOC entry 2832 (class 2606 OID 17050)
-- Name: taxpayer_phone_number taxpayer_phone_number_phone_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taxpayer_phone_number
    ADD CONSTRAINT taxpayer_phone_number_phone_type_id_fkey FOREIGN KEY (phone_type_id) REFERENCES public.phone_type(phone_type_id);


--
-- TOC entry 2833 (class 2606 OID 17055)
-- Name: taxpayer_phone_number taxpayer_phone_number_taxpayer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taxpayer_phone_number
    ADD CONSTRAINT taxpayer_phone_number_taxpayer_id_fkey FOREIGN KEY (taxpayer_id) REFERENCES public.taxpayer(taxpayer_id);


--
-- TOC entry 2955 (class 6104 OID 16561)
-- Name: publi_agencies; Type: PUBLICATION; Schema: -; Owner: postgres
--

CREATE PUBLICATION publi_agencies WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION publi_agencies OWNER TO postgres;

--
-- TOC entry 2956 (class 6100 OID 17222)
-- Name: subs_taxes_collection; Type: SUBSCRIPTION; Schema: -; Owner: postgres
--

CREATE SUBSCRIPTION subs_taxes_collection CONNECTION 'host=127.0.0.1 user=rep password=billboard port=5432 dbname=TaxesCollection' PUBLICATION pub_taxes_collection WITH (connect = false, slot_name = 'subs_taxes_collection');


ALTER SUBSCRIPTION subs_taxes_collection OWNER TO postgres;

--
-- TOC entry 2981 (class 0 OID 0)
-- Dependencies: 196
-- Name: TABLE agency; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.agency TO readonly;


--
-- TOC entry 2983 (class 0 OID 0)
-- Dependencies: 198
-- Name: TABLE agency_phone_number; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.agency_phone_number TO readonly;


--
-- TOC entry 2985 (class 0 OID 0)
-- Dependencies: 200
-- Name: TABLE company; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.company TO readonly;


--
-- TOC entry 2986 (class 0 OID 0)
-- Dependencies: 201
-- Name: TABLE individual; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.individual TO readonly;


--
-- TOC entry 2987 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE own_rel; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.own_rel TO readonly;


--
-- TOC entry 2989 (class 0 OID 0)
-- Dependencies: 204
-- Name: TABLE phone_type; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.phone_type TO readonly;


--
-- TOC entry 2991 (class 0 OID 0)
-- Dependencies: 206
-- Name: TABLE tax_payment; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tax_payment TO readonly;


--
-- TOC entry 2993 (class 0 OID 0)
-- Dependencies: 208
-- Name: TABLE tax_type; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tax_type TO readonly;


--
-- TOC entry 2995 (class 0 OID 0)
-- Dependencies: 210
-- Name: TABLE taxpayer; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.taxpayer TO readonly;


--
-- TOC entry 2996 (class 0 OID 0)
-- Dependencies: 211
-- Name: TABLE taxpayer_phone_number; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.taxpayer_phone_number TO readonly;


--
-- TOC entry 1739 (class 826 OID 16851)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT ON TABLES  TO readonly;


-- Completed on 2019-09-18 15:21:09

--
-- PostgreSQL database dump complete
--

