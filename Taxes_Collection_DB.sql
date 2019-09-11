--
-- PostgreSQL database dump
--

-- Dumped from database version 11.5
-- Dumped by pg_dump version 11.5

-- Started on 2019-09-11 16:07:06

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
-- TOC entry 2971 (class 1262 OID 16867)
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
-- TOC entry 2972 (class 0 OID 0)
-- Dependencies: 2971
-- Name: DATABASE "TaxesCollection"; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE "TaxesCollection" IS 'Taxes Collection Database';


--
-- TOC entry 229 (class 1255 OID 17830)
-- Name: insertcompany(character varying, character varying, date, character varying, character varying, integer[], character varying[], integer[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insertcompany(email character varying, cuit_number character varying, comencement_date date, website character varying, login character varying, individuals integer[], phone_numbers character varying[], phone_type_ids integer[]) RETURNS void
    LANGUAGE plpgsql
    AS $_$
/***********************************************************************************
Objective: Inserts a company into DB along with their owner relationships
Inputs: 
- Email
- Cuit Number
- Comencement Date
- Website
- User
- List of individual ids that own the company (These individuals must exist in DB)
- List of phone numbers for the company
- List of phone type ids for the phone numbers (These type ids must exist in DB)
Outputs: N/A
************************************************************************************/
DECLARE
	counter integer := 0;
	ind_cant integer;
	phone_cant integer;
	phone_type_id_cant integer;
	comp_id integer;
BEGIN

	ind_cant = array_length(individuals, 1);
	phone_cant = array_length(phone_numbers, 1);
	phone_type_id_cant = array_length(phone_type_ids, 1);
	
	IF(ind_cant = 0) THEN
		RAISE 'At least 1 individual that owns the company must be informed';
	ELSE
		IF(phone_cant = 0) THEN
			RAISE 'At least 1 phone number for the company must be informed';
		ELSE
			IF(phone_type_id_cant = 0) THEN
				RAISE 'Phone type ids must be informed for phone numbers';
			ELSE
				IF(phone_cant <> phone_type_id_cant) THEN
					RAISE 'Quantity of phone type ids does not match the informed quantity of phone numbers';
				ELSE
					--Creates a taxpayer for the company
					INSERT INTO TAXPAYER
					(type, email, created_at, created_by, last_upd_by)
					VALUES
					('C',$1,CURRENT_TIMESTAMP,$5,$5)
					RETURNING taxpayer_id INTO comp_id;

					--Creates the company
					INSERT INTO COMPANY
					(taxpayer_id, cuit_number, comencement_date, website, created_at, created_by, last_upd_by)
					VALUES
					(comp_id,$2,$3,$4,CURRENT_TIMESTAMP,$5,$5);

					--Creates the ownerships for the company
					WHILE counter < ind_cant LOOP
						counter = counter+1;

						INSERT INTO OWN_REL
						(individual_id, company_id, start_date, created_at, created_by, last_upd_by)
						VALUES
						(individuals[counter],comp_id,$3,CURRENT_TIMESTAMP,$5,$5);
					END LOOP;					

					--Creates the phone numbers for the company
					counter := 0;
					WHILE counter < phone_cant LOOP
						counter = counter+1;

						INSERT INTO TAXPAYER_PHONE_NUMBER
						(taxpayer_id, phone_number, phone_type_id, created_at, created_by, last_upd_by)
						VALUES
						(comp_id,phone_numbers[counter],phone_type_ids[counter],CURRENT_TIMESTAMP,$5,$5);
					END LOOP;
				END IF;
			END IF;	
		END IF;	
	END IF;	
END;$_$;


ALTER FUNCTION public.insertcompany(email character varying, cuit_number character varying, comencement_date date, website character varying, login character varying, individuals integer[], phone_numbers character varying[], phone_type_ids integer[]) OWNER TO postgres;

--
-- TOC entry 228 (class 1255 OID 17831)
-- Name: inserttaxpayment(integer, integer, numeric, date, integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.inserttaxpayment(agency_id integer, taxpayer_id integer, amount numeric, payment_date date, tax_type_id integer, login character varying) RETURNS void
    LANGUAGE plpgsql
    AS $_$
/***********************************************************************************
Objective: Inserts a tax payment into DB
Inputs: Agency Id, Taxpayer Id, Amount, Payment Date, Tax Type, User
Outputs: N/A
************************************************************************************/
BEGIN
	INSERT INTO TAX_PAYMENT
	(agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by, last_upd_by)
	VALUES
	($1,$2,$3,$4,$5,CURRENT_TIMESTAMP,$6,$6);
END;$_$;


ALTER FUNCTION public.inserttaxpayment(agency_id integer, taxpayer_id integer, amount numeric, payment_date date, tax_type_id integer, login character varying) OWNER TO postgres;

--
-- TOC entry 227 (class 1255 OID 17601)
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
-- TOC entry 226 (class 1255 OID 17600)
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
-- TOC entry 207 (class 1259 OID 17494)
-- Name: agency; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.agency (
    agency_id integer NOT NULL,
    number character varying NOT NULL,
    address character varying NOT NULL,
    person_in_charge character varying NOT NULL,
    number_of_emp integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    created_by character varying NOT NULL,
    last_upd_by character varying NOT NULL
);


ALTER TABLE public.agency OWNER TO postgres;

--
-- TOC entry 206 (class 1259 OID 17492)
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
-- TOC entry 2974 (class 0 OID 0)
-- Dependencies: 206
-- Name: agency_agency_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.agency_agency_id_seq OWNED BY public.agency.agency_id;


--
-- TOC entry 209 (class 1259 OID 17507)
-- Name: agency_phone_number; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.agency_phone_number (
    rel_id integer NOT NULL,
    agency_id integer,
    phone_number character varying NOT NULL,
    phone_type_id integer,
    created_at timestamp without time zone NOT NULL,
    created_by character varying NOT NULL,
    last_upd_by character varying NOT NULL
);


ALTER TABLE public.agency_phone_number OWNER TO postgres;

--
-- TOC entry 208 (class 1259 OID 17505)
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
-- TOC entry 2976 (class 0 OID 0)
-- Dependencies: 208
-- Name: agency_phone_number_rel_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.agency_phone_number_rel_id_seq OWNED BY public.agency_phone_number.rel_id;


--
-- TOC entry 203 (class 1259 OID 17471)
-- Name: company; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.company (
    taxpayer_id integer NOT NULL,
    cuit_number character varying NOT NULL,
    comencement_date date NOT NULL,
    website character varying,
    created_at timestamp without time zone NOT NULL,
    created_by character varying NOT NULL,
    last_upd_by character varying NOT NULL
);


ALTER TABLE public.company OWNER TO postgres;

--
-- TOC entry 202 (class 1259 OID 17463)
-- Name: individual; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.individual (
    taxpayer_id integer NOT NULL,
    doc_number character varying NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    date_of_birth date NOT NULL,
    home_address character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    created_by character varying NOT NULL,
    last_upd_by character varying NOT NULL
);


ALTER TABLE public.individual OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 17483)
-- Name: own_rel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.own_rel (
    rel_id integer NOT NULL,
    individual_id integer,
    company_id integer,
    start_date timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    created_by character varying NOT NULL,
    last_upd_by character varying NOT NULL
);


ALTER TABLE public.own_rel OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 17481)
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
-- TOC entry 2980 (class 0 OID 0)
-- Dependencies: 204
-- Name: own_rel_rel_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.own_rel_rel_id_seq OWNED BY public.own_rel.rel_id;


--
-- TOC entry 201 (class 1259 OID 17452)
-- Name: phone_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.phone_type (
    phone_type_id integer NOT NULL,
    type character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    created_by character varying NOT NULL,
    last_upd_by character varying NOT NULL
);


ALTER TABLE public.phone_type OWNER TO postgres;

--
-- TOC entry 200 (class 1259 OID 17450)
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
-- TOC entry 2982 (class 0 OID 0)
-- Dependencies: 200
-- Name: phone_type_phone_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.phone_type_phone_type_id_seq OWNED BY public.phone_type.phone_type_id;


--
-- TOC entry 211 (class 1259 OID 17518)
-- Name: tax_payment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tax_payment (
    payment_id integer NOT NULL,
    agency_id integer,
    taxpayer_id integer,
    amount numeric NOT NULL,
    payment_date timestamp without time zone NOT NULL,
    tax_type_id integer,
    created_at timestamp without time zone NOT NULL,
    created_by character varying NOT NULL,
    last_upd_by character varying NOT NULL
);


ALTER TABLE public.tax_payment OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 17516)
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
-- TOC entry 2984 (class 0 OID 0)
-- Dependencies: 210
-- Name: tax_payment_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tax_payment_payment_id_seq OWNED BY public.tax_payment.payment_id;


--
-- TOC entry 213 (class 1259 OID 17529)
-- Name: tax_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tax_type (
    tax_type_id integer NOT NULL,
    type character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    created_by character varying NOT NULL,
    last_upd_by character varying NOT NULL
);


ALTER TABLE public.tax_type OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 17527)
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
-- TOC entry 2986 (class 0 OID 0)
-- Dependencies: 212
-- Name: tax_type_tax_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tax_type_tax_type_id_seq OWNED BY public.tax_type.tax_type_id;


--
-- TOC entry 197 (class 1259 OID 17430)
-- Name: taxpayer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.taxpayer (
    taxpayer_id integer NOT NULL,
    type character varying NOT NULL,
    email character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    created_by character varying NOT NULL,
    last_upd_by character varying NOT NULL
);


ALTER TABLE public.taxpayer OWNER TO postgres;

--
-- TOC entry 199 (class 1259 OID 17441)
-- Name: taxpayer_phone_number; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.taxpayer_phone_number (
    rel_id integer NOT NULL,
    taxpayer_id integer,
    phone_number character varying NOT NULL,
    phone_type_id integer,
    created_at timestamp without time zone NOT NULL,
    created_by character varying NOT NULL,
    last_upd_by character varying NOT NULL
);


ALTER TABLE public.taxpayer_phone_number OWNER TO postgres;

--
-- TOC entry 198 (class 1259 OID 17439)
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
-- TOC entry 2989 (class 0 OID 0)
-- Dependencies: 198
-- Name: taxpayer_phone_number_rel_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.taxpayer_phone_number_rel_id_seq OWNED BY public.taxpayer_phone_number.rel_id;


--
-- TOC entry 196 (class 1259 OID 17428)
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
-- TOC entry 2990 (class 0 OID 0)
-- Dependencies: 196
-- Name: taxpayer_taxpayer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.taxpayer_taxpayer_id_seq OWNED BY public.taxpayer.taxpayer_id;


--
-- TOC entry 2763 (class 2604 OID 17497)
-- Name: agency agency_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agency ALTER COLUMN agency_id SET DEFAULT nextval('public.agency_agency_id_seq'::regclass);


--
-- TOC entry 2765 (class 2604 OID 17510)
-- Name: agency_phone_number rel_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agency_phone_number ALTER COLUMN rel_id SET DEFAULT nextval('public.agency_phone_number_rel_id_seq'::regclass);


--
-- TOC entry 2761 (class 2604 OID 17486)
-- Name: own_rel rel_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.own_rel ALTER COLUMN rel_id SET DEFAULT nextval('public.own_rel_rel_id_seq'::regclass);


--
-- TOC entry 2755 (class 2604 OID 17455)
-- Name: phone_type phone_type_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.phone_type ALTER COLUMN phone_type_id SET DEFAULT nextval('public.phone_type_phone_type_id_seq'::regclass);


--
-- TOC entry 2767 (class 2604 OID 17521)
-- Name: tax_payment payment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_payment ALTER COLUMN payment_id SET DEFAULT nextval('public.tax_payment_payment_id_seq'::regclass);


--
-- TOC entry 2771 (class 2604 OID 17532)
-- Name: tax_type tax_type_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_type ALTER COLUMN tax_type_id SET DEFAULT nextval('public.tax_type_tax_type_id_seq'::regclass);


--
-- TOC entry 2749 (class 2604 OID 17433)
-- Name: taxpayer taxpayer_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taxpayer ALTER COLUMN taxpayer_id SET DEFAULT nextval('public.taxpayer_taxpayer_id_seq'::regclass);


--
-- TOC entry 2753 (class 2604 OID 17444)
-- Name: taxpayer_phone_number rel_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taxpayer_phone_number ALTER COLUMN rel_id SET DEFAULT nextval('public.taxpayer_phone_number_rel_id_seq'::regclass);


--
-- TOC entry 2959 (class 0 OID 17494)
-- Dependencies: 207
-- Data for Name: agency; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.agency (agency_id, number, address, person_in_charge, number_of_emp, created_at, created_by, last_upd_by) VALUES (1, '1', '5th Av. 400', 'Dana Harris', 10, '2019-09-09 14:59:56.557672', 'postgres', 'postgres');
INSERT INTO public.agency (agency_id, number, address, person_in_charge, number_of_emp, created_at, created_by, last_upd_by) VALUES (2, '2', 'Jacksonville 2323', 'Jack Craig', 15, '2019-09-09 14:59:56.557672', 'postgres', 'postgres');
INSERT INTO public.agency (agency_id, number, address, person_in_charge, number_of_emp, created_at, created_by, last_upd_by) VALUES (3, '3', 'Park Ave. 210', 'Ashley Roy', 7, '2019-09-10 14:51:11.043039', 'postgres', 'postgres');


--
-- TOC entry 2961 (class 0 OID 17507)
-- Dependencies: 209
-- Data for Name: agency_phone_number; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.agency_phone_number (rel_id, agency_id, phone_number, phone_type_id, created_at, created_by, last_upd_by) VALUES (1, 1, '47474747', 1, '2019-09-09 15:00:05.562036', 'postgres', 'postgres');
INSERT INTO public.agency_phone_number (rel_id, agency_id, phone_number, phone_type_id, created_at, created_by, last_upd_by) VALUES (2, 1, '57575757', 2, '2019-09-09 15:00:05.562036', 'postgres', 'postgres');
INSERT INTO public.agency_phone_number (rel_id, agency_id, phone_number, phone_type_id, created_at, created_by, last_upd_by) VALUES (3, 2, '71717171', 1, '2019-09-09 15:00:05.562036', 'postgres', 'postgres');


--
-- TOC entry 2955 (class 0 OID 17471)
-- Dependencies: 203
-- Data for Name: company; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.company (taxpayer_id, cuit_number, comencement_date, website, created_at, created_by, last_upd_by) VALUES (2, '4781010', '2005-07-22', 'www.newcompany.com', '2019-09-09 14:59:12.357671', 'postgres', 'postgres');
INSERT INTO public.company (taxpayer_id, cuit_number, comencement_date, website, created_at, created_by, last_upd_by) VALUES (3, '21212121', '2007-11-01', 'www.abccompany.com', '2019-09-09 14:59:12.357671', 'postgres', 'postgres');
INSERT INTO public.company (taxpayer_id, cuit_number, comencement_date, website, created_at, created_by, last_upd_by) VALUES (4, '34343434', '2008-01-20', 'www.xtracompany.com', '2019-09-09 14:59:12.357671', 'postgres', 'postgres');
INSERT INTO public.company (taxpayer_id, cuit_number, comencement_date, website, created_at, created_by, last_upd_by) VALUES (6, '102020', '2001-03-21', 'www.byco.com', '2019-09-09 14:59:12.357671', 'postgres', 'postgres');
INSERT INTO public.company (taxpayer_id, cuit_number, comencement_date, website, created_at, created_by, last_upd_by) VALUES (7, '717171717171', '2003-12-07', 'www.nextco.com', '2019-09-09 14:59:12.357671', 'postgres', 'postgres');
INSERT INTO public.company (taxpayer_id, cuit_number, comencement_date, website, created_at, created_by, last_upd_by) VALUES (11, '40404040', '2001-10-10', 'www.test.com', '2019-09-09 17:18:20.312411', 'postgres', 'postgres');
INSERT INTO public.company (taxpayer_id, cuit_number, comencement_date, website, created_at, created_by, last_upd_by) VALUES (17, '20201010', '2019-02-21', 'www.cdhcompany.com', '2019-09-11 15:39:59.663919', 'postgres', 'postgres');


--
-- TOC entry 2954 (class 0 OID 17463)
-- Dependencies: 202
-- Data for Name: individual; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.individual (taxpayer_id, doc_number, first_name, last_name, date_of_birth, home_address, created_at, created_by, last_upd_by) VALUES (1, '12345678', 'John', 'Jackson', '1997-10-10', 'Newark Ave. 132', '2019-09-09 14:59:02.363352', 'postgres', 'postgres');
INSERT INTO public.individual (taxpayer_id, doc_number, first_name, last_name, date_of_birth, home_address, created_at, created_by, last_upd_by) VALUES (5, '5151515151', 'Annie', 'Wilson', '1990-07-21', 'Jackson Park Ave. 4321', '2019-09-09 14:59:02.363352', 'postgres', 'postgres');


--
-- TOC entry 2957 (class 0 OID 17483)
-- Dependencies: 205
-- Data for Name: own_rel; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by, last_upd_by) VALUES (1, 1, 2, '2005-07-22 00:00:00', '2019-09-09 14:59:30.373851', 'postgres', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by, last_upd_by) VALUES (2, 1, 3, '2007-11-01 00:00:00', '2019-09-09 14:59:30.373851', 'postgres', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by, last_upd_by) VALUES (3, 1, 4, '2008-01-20 00:00:00', '2019-09-09 14:59:30.373851', 'postgres', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by, last_upd_by) VALUES (4, 5, 6, '2001-03-21 00:00:00', '2019-09-09 14:59:30.373851', 'postgres', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by, last_upd_by) VALUES (5, 5, 7, '2003-12-07 00:00:00', '2019-09-09 14:59:30.373851', 'postgres', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by, last_upd_by) VALUES (15, 1, 11, '2001-10-10 00:00:00', '2019-09-09 17:18:20.312411', 'postgres', 'postgres');
INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by, last_upd_by) VALUES (16, 5, 11, '2001-10-10 00:00:00', '2019-09-09 17:18:20.312411', 'postgres', 'postgres');


--
-- TOC entry 2953 (class 0 OID 17452)
-- Dependencies: 201
-- Data for Name: phone_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.phone_type (phone_type_id, type, created_at, created_by, last_upd_by) VALUES (1, 'Landline', '2019-09-09 14:58:25.717285', 'postgres', 'postgres');
INSERT INTO public.phone_type (phone_type_id, type, created_at, created_by, last_upd_by) VALUES (2, 'Mobile', '2019-09-09 14:58:25.717285', 'postgres', 'postgres');
INSERT INTO public.phone_type (phone_type_id, type, created_at, created_by, last_upd_by) VALUES (3, 'Fax', '2019-09-09 14:58:25.717285', 'postgres', 'postgres');


--
-- TOC entry 2963 (class 0 OID 17518)
-- Dependencies: 211
-- Data for Name: tax_payment; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by, last_upd_by) VALUES (1, 1, 1, 170, '2019-03-14 00:00:00', 1, '2019-09-09 15:00:25.633404', 'postgres', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by, last_upd_by) VALUES (2, 1, 1, 2500, '2019-04-17 00:00:00', 3, '2019-09-09 15:00:25.633404', 'postgres', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by, last_upd_by) VALUES (3, 2, 2, 17000, '2019-04-20 00:00:00', 4, '2019-09-09 15:00:25.633404', 'postgres', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by, last_upd_by) VALUES (4, 1, 1, 200, '2019-03-17 00:00:00', 2, '2019-09-09 15:00:25.633404', 'postgres', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by, last_upd_by) VALUES (5, 1, 1, 1000, '2019-04-21 00:00:00', 3, '2019-09-09 15:00:25.633404', 'postgres', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by, last_upd_by) VALUES (6, 1, 2, 2500, '2019-07-10 00:00:00', 4, '2019-09-09 15:00:25.633404', 'postgres', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by, last_upd_by) VALUES (7, 2, 3, 1000, '2019-07-11 00:00:00', 2, '2019-09-09 15:00:25.633404', 'postgres', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by, last_upd_by) VALUES (8, 2, 3, 3000, '2019-10-11 00:00:00', 4, '2019-09-09 15:00:25.633404', 'postgres', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by, last_upd_by) VALUES (9, 1, 4, 7000, '2019-02-20 00:00:00', 4, '2019-09-09 15:00:25.633404', 'postgres', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by, last_upd_by) VALUES (10, 1, 4, 2700, '2019-06-17 00:00:00', 3, '2019-09-09 15:00:25.633404', 'postgres', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by, last_upd_by) VALUES (11, 1, 4, 1300, '2019-08-25 00:00:00', 2, '2019-09-09 15:00:25.633404', 'postgres', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by, last_upd_by) VALUES (12, 2, 6, 500, '2019-01-25 00:00:00', 4, '2019-09-09 15:00:25.633404', 'postgres', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by, last_upd_by) VALUES (13, 2, 6, 800, '2019-04-04 00:00:00', 1, '2019-09-09 15:00:25.633404', 'postgres', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by, last_upd_by) VALUES (14, 1, 7, 8000, '2019-04-30 00:00:00', 4, '2019-09-09 15:00:25.633404', 'postgres', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by, last_upd_by) VALUES (15, 2, 7, 7000, '2019-11-29 00:00:00', 3, '2019-09-09 15:00:25.633404', 'postgres', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by, last_upd_by) VALUES (18, 2, 7, 5500, '2019-04-30 00:00:00', 4, '2019-09-09 15:08:19.109291', 'postgres', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by, last_upd_by) VALUES (22, 1, 1, 250, '2019-09-10 00:00:00', 1, '2019-09-11 16:01:14.102663', 'postgres', 'postgres');


--
-- TOC entry 2965 (class 0 OID 17529)
-- Dependencies: 213
-- Data for Name: tax_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tax_type (tax_type_id, type, created_at, created_by, last_upd_by) VALUES (1, 'Stamp Duty', '2019-09-09 15:00:14.131541', 'postgres', 'postgres');
INSERT INTO public.tax_type (tax_type_id, type, created_at, created_by, last_upd_by) VALUES (2, 'Real Estate', '2019-09-09 15:00:14.131541', 'postgres', 'postgres');
INSERT INTO public.tax_type (tax_type_id, type, created_at, created_by, last_upd_by) VALUES (3, 'Automotive Patent', '2019-09-09 15:00:14.131541', 'postgres', 'postgres');
INSERT INTO public.tax_type (tax_type_id, type, created_at, created_by, last_upd_by) VALUES (4, 'Gross Income', '2019-09-09 15:00:14.131541', 'postgres', 'postgres');


--
-- TOC entry 2949 (class 0 OID 17430)
-- Dependencies: 197
-- Data for Name: taxpayer; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by, last_upd_by) VALUES (2, 'C', 'taxpayer2@gmail.com', '2019-09-09 14:58:37.372677', 'postgres', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by, last_upd_by) VALUES (3, 'C', 'taxpayer3@gmail.com', '2019-09-09 14:58:37.372677', 'postgres', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by, last_upd_by) VALUES (4, 'C', 'taxpayer4@gmail.com', '2019-09-09 14:58:37.372677', 'postgres', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by, last_upd_by) VALUES (5, 'I', 'taxpayer5@gmail.com', '2019-09-09 14:58:37.372677', 'postgres', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by, last_upd_by) VALUES (6, 'C', 'taxpayer6@gmail.com', '2019-09-09 14:58:37.372677', 'postgres', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by, last_upd_by) VALUES (7, 'C', 'taxpayer7@gmail.com', '2019-09-09 14:58:37.372677', 'postgres', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by, last_upd_by) VALUES (11, 'C', 'test@yahoo.com', '2019-09-09 17:18:20.312411', 'postgres', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by, last_upd_by) VALUES (1, 'I', 'taxpayer111@gmail.com', '2019-09-09 14:58:37.372677', 'postgres', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by, last_upd_by) VALUES (17, 'C', 'taxpayer8@gmail.com', '2019-09-10 17:39:58.597244', 'postgres', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by, last_upd_by) VALUES (24, 'I', 'taxpayer10@gmail.com', '2019-09-11 15:55:29.480214', 'postgres', 'postgres');


--
-- TOC entry 2951 (class 0 OID 17441)
-- Dependencies: 199
-- Data for Name: taxpayer_phone_number; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by, last_upd_by) VALUES (1, 1, '11111111', 1, '2019-09-09 14:58:48.86957', 'postgres', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by, last_upd_by) VALUES (2, 1, '22222222', 2, '2019-09-09 14:58:48.86957', 'postgres', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by, last_upd_by) VALUES (3, 2, '33333333', 1, '2019-09-09 14:58:48.86957', 'postgres', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by, last_upd_by) VALUES (10, 11, '5555555', 1, '2019-09-09 17:18:20.312411', 'postgres', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by, last_upd_by) VALUES (11, 11, '77777777', 2, '2019-09-09 17:18:20.312411', 'postgres', 'postgres');


--
-- TOC entry 2991 (class 0 OID 0)
-- Dependencies: 206
-- Name: agency_agency_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.agency_agency_id_seq', 3, true);


--
-- TOC entry 2992 (class 0 OID 0)
-- Dependencies: 208
-- Name: agency_phone_number_rel_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.agency_phone_number_rel_id_seq', 3, true);


--
-- TOC entry 2993 (class 0 OID 0)
-- Dependencies: 204
-- Name: own_rel_rel_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.own_rel_rel_id_seq', 17, true);


--
-- TOC entry 2994 (class 0 OID 0)
-- Dependencies: 200
-- Name: phone_type_phone_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.phone_type_phone_type_id_seq', 3, true);


--
-- TOC entry 2995 (class 0 OID 0)
-- Dependencies: 210
-- Name: tax_payment_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tax_payment_payment_id_seq', 22, true);


--
-- TOC entry 2996 (class 0 OID 0)
-- Dependencies: 212
-- Name: tax_type_tax_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tax_type_tax_type_id_seq', 4, true);


--
-- TOC entry 2997 (class 0 OID 0)
-- Dependencies: 198
-- Name: taxpayer_phone_number_rel_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.taxpayer_phone_number_rel_id_seq', 11, true);


--
-- TOC entry 2998 (class 0 OID 0)
-- Dependencies: 196
-- Name: taxpayer_taxpayer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.taxpayer_taxpayer_id_seq', 24, true);


--
-- TOC entry 2768 (class 2606 OID 17821)
-- Name: tax_payment CHK_Amount; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.tax_payment
    ADD CONSTRAINT "CHK_Amount" CHECK ((amount > (0)::numeric)) NOT VALID;


--
-- TOC entry 2759 (class 2606 OID 17813)
-- Name: company CHK_Comencement_Date; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.company
    ADD CONSTRAINT "CHK_Comencement_Date" CHECK ((comencement_date <= CURRENT_TIMESTAMP)) NOT VALID;


--
-- TOC entry 2766 (class 2606 OID 17815)
-- Name: agency_phone_number CHK_Created_At; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.agency_phone_number
    ADD CONSTRAINT "CHK_Created_At" CHECK ((created_at <= CURRENT_TIMESTAMP)) NOT VALID;


--
-- TOC entry 2760 (class 2606 OID 17816)
-- Name: company CHK_Created_At; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.company
    ADD CONSTRAINT "CHK_Created_At" CHECK ((created_at <= CURRENT_TIMESTAMP)) NOT VALID;


--
-- TOC entry 2757 (class 2606 OID 17818)
-- Name: individual CHK_Created_At; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.individual
    ADD CONSTRAINT "CHK_Created_At" CHECK ((created_at <= CURRENT_TIMESTAMP)) NOT VALID;


--
-- TOC entry 2762 (class 2606 OID 17819)
-- Name: own_rel CHK_Created_At; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.own_rel
    ADD CONSTRAINT "CHK_Created_At" CHECK ((created_at <= CURRENT_TIMESTAMP)) NOT VALID;


--
-- TOC entry 2756 (class 2606 OID 17820)
-- Name: phone_type CHK_Created_At; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.phone_type
    ADD CONSTRAINT "CHK_Created_At" CHECK ((created_at <= CURRENT_TIMESTAMP)) NOT VALID;


--
-- TOC entry 2769 (class 2606 OID 17823)
-- Name: tax_payment CHK_Created_At; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.tax_payment
    ADD CONSTRAINT "CHK_Created_At" CHECK ((created_at <= CURRENT_TIMESTAMP)) NOT VALID;


--
-- TOC entry 2772 (class 2606 OID 17824)
-- Name: tax_type CHK_Created_At; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.tax_type
    ADD CONSTRAINT "CHK_Created_At" CHECK ((created_at <= CURRENT_TIMESTAMP)) NOT VALID;


--
-- TOC entry 2754 (class 2606 OID 17825)
-- Name: taxpayer_phone_number CHK_Created_At; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.taxpayer_phone_number
    ADD CONSTRAINT "CHK_Created_At" CHECK ((created_at <= CURRENT_TIMESTAMP)) NOT VALID;


--
-- TOC entry 2750 (class 2606 OID 17826)
-- Name: taxpayer CHK_Created_At; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.taxpayer
    ADD CONSTRAINT "CHK_Created_At" CHECK ((created_at <= CURRENT_TIMESTAMP)) NOT VALID;


--
-- TOC entry 2758 (class 2606 OID 17817)
-- Name: individual CHK_Date_Of_Birth; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.individual
    ADD CONSTRAINT "CHK_Date_Of_Birth" CHECK ((date_of_birth <= CURRENT_TIMESTAMP)) NOT VALID;


--
-- TOC entry 2751 (class 2606 OID 17829)
-- Name: taxpayer CHK_Email; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.taxpayer
    ADD CONSTRAINT "CHK_Email" CHECK (((email)::text ~ similar_escape('[A-Za-z0-9._%-]+@[A-Za-z0-9._%-]+\.[A-Za-z]{2,4}'::text, NULL::text))) NOT VALID;


--
-- TOC entry 2770 (class 2606 OID 17822)
-- Name: tax_payment CHK_Payment_Date; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.tax_payment
    ADD CONSTRAINT "CHK_Payment_Date" CHECK ((payment_date <= CURRENT_TIMESTAMP)) NOT VALID;


--
-- TOC entry 2752 (class 2606 OID 17827)
-- Name: taxpayer CHK_Type; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.taxpayer
    ADD CONSTRAINT "CHK_Type" CHECK (((type)::text = ANY ((ARRAY['I'::character varying, 'C'::character varying])::text[]))) NOT VALID;


--
-- TOC entry 2764 (class 2606 OID 17814)
-- Name: agency CHL_Created_At; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.agency
    ADD CONSTRAINT "CHL_Created_At" CHECK ((created_at <= CURRENT_TIMESTAMP)) NOT VALID;


--
-- TOC entry 2792 (class 2606 OID 17504)
-- Name: agency agency_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agency
    ADD CONSTRAINT agency_number_key UNIQUE (number);


--
-- TOC entry 2796 (class 2606 OID 17515)
-- Name: agency_phone_number agency_phone_number_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agency_phone_number
    ADD CONSTRAINT agency_phone_number_pkey PRIMARY KEY (rel_id);


--
-- TOC entry 2794 (class 2606 OID 17502)
-- Name: agency agency_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agency
    ADD CONSTRAINT agency_pkey PRIMARY KEY (agency_id);


--
-- TOC entry 2785 (class 2606 OID 17480)
-- Name: company company_cuit_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT company_cuit_number_key UNIQUE (cuit_number);


--
-- TOC entry 2787 (class 2606 OID 17478)
-- Name: company company_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT company_pkey PRIMARY KEY (taxpayer_id);


--
-- TOC entry 2783 (class 2606 OID 17470)
-- Name: individual individual_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individual
    ADD CONSTRAINT individual_pkey PRIMARY KEY (taxpayer_id);


--
-- TOC entry 2789 (class 2606 OID 17491)
-- Name: own_rel own_rel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.own_rel
    ADD CONSTRAINT own_rel_pkey PRIMARY KEY (rel_id);


--
-- TOC entry 2779 (class 2606 OID 17460)
-- Name: phone_type phone_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.phone_type
    ADD CONSTRAINT phone_type_pkey PRIMARY KEY (phone_type_id);


--
-- TOC entry 2781 (class 2606 OID 17462)
-- Name: phone_type phone_type_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.phone_type
    ADD CONSTRAINT phone_type_type_key UNIQUE (type);


--
-- TOC entry 2799 (class 2606 OID 17526)
-- Name: tax_payment tax_payment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_payment
    ADD CONSTRAINT tax_payment_pkey PRIMARY KEY (payment_id);


--
-- TOC entry 2802 (class 2606 OID 17537)
-- Name: tax_type tax_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_type
    ADD CONSTRAINT tax_type_pkey PRIMARY KEY (tax_type_id);


--
-- TOC entry 2804 (class 2606 OID 17539)
-- Name: tax_type tax_type_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_type
    ADD CONSTRAINT tax_type_type_key UNIQUE (type);


--
-- TOC entry 2776 (class 2606 OID 17449)
-- Name: taxpayer_phone_number taxpayer_phone_number_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taxpayer_phone_number
    ADD CONSTRAINT taxpayer_phone_number_pkey PRIMARY KEY (rel_id);


--
-- TOC entry 2774 (class 2606 OID 17438)
-- Name: taxpayer taxpayer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taxpayer
    ADD CONSTRAINT taxpayer_pkey PRIMARY KEY (taxpayer_id);


--
-- TOC entry 2797 (class 1259 OID 17597)
-- Name: agency_phone_number_u_1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX agency_phone_number_u_1 ON public.agency_phone_number USING btree (agency_id, phone_number);


--
-- TOC entry 2790 (class 1259 OID 17596)
-- Name: own_rel_u_1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX own_rel_u_1 ON public.own_rel USING btree (individual_id, company_id);


--
-- TOC entry 2800 (class 1259 OID 17598)
-- Name: tax_payment_u_1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX tax_payment_u_1 ON public.tax_payment USING btree (agency_id, taxpayer_id, payment_date, tax_type_id);


--
-- TOC entry 2777 (class 1259 OID 17595)
-- Name: taxpayer_phone_number_u_1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX taxpayer_phone_number_u_1 ON public.taxpayer_phone_number USING btree (taxpayer_id, phone_number);


--
-- TOC entry 2811 (class 2606 OID 17570)
-- Name: agency_phone_number agency_phone_number_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agency_phone_number
    ADD CONSTRAINT agency_phone_number_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agency(agency_id);


--
-- TOC entry 2812 (class 2606 OID 17575)
-- Name: agency_phone_number agency_phone_number_phone_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agency_phone_number
    ADD CONSTRAINT agency_phone_number_phone_type_id_fkey FOREIGN KEY (phone_type_id) REFERENCES public.phone_type(phone_type_id);


--
-- TOC entry 2808 (class 2606 OID 17555)
-- Name: company company_taxpayer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT company_taxpayer_id_fkey FOREIGN KEY (taxpayer_id) REFERENCES public.taxpayer(taxpayer_id);


--
-- TOC entry 2807 (class 2606 OID 17550)
-- Name: individual individual_taxpayer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individual
    ADD CONSTRAINT individual_taxpayer_id_fkey FOREIGN KEY (taxpayer_id) REFERENCES public.taxpayer(taxpayer_id);


--
-- TOC entry 2810 (class 2606 OID 17565)
-- Name: own_rel own_rel_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.own_rel
    ADD CONSTRAINT own_rel_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.taxpayer(taxpayer_id);


--
-- TOC entry 2809 (class 2606 OID 17560)
-- Name: own_rel own_rel_individual_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.own_rel
    ADD CONSTRAINT own_rel_individual_id_fkey FOREIGN KEY (individual_id) REFERENCES public.taxpayer(taxpayer_id);


--
-- TOC entry 2813 (class 2606 OID 17580)
-- Name: tax_payment tax_payment_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_payment
    ADD CONSTRAINT tax_payment_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agency(agency_id);


--
-- TOC entry 2815 (class 2606 OID 17590)
-- Name: tax_payment tax_payment_tax_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_payment
    ADD CONSTRAINT tax_payment_tax_type_id_fkey FOREIGN KEY (tax_type_id) REFERENCES public.tax_type(tax_type_id);


--
-- TOC entry 2814 (class 2606 OID 17585)
-- Name: tax_payment tax_payment_taxpayer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_payment
    ADD CONSTRAINT tax_payment_taxpayer_id_fkey FOREIGN KEY (taxpayer_id) REFERENCES public.taxpayer(taxpayer_id);


--
-- TOC entry 2806 (class 2606 OID 17545)
-- Name: taxpayer_phone_number taxpayer_phone_number_phone_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taxpayer_phone_number
    ADD CONSTRAINT taxpayer_phone_number_phone_type_id_fkey FOREIGN KEY (phone_type_id) REFERENCES public.phone_type(phone_type_id);


--
-- TOC entry 2805 (class 2606 OID 17540)
-- Name: taxpayer_phone_number taxpayer_phone_number_taxpayer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taxpayer_phone_number
    ADD CONSTRAINT taxpayer_phone_number_taxpayer_id_fkey FOREIGN KEY (taxpayer_id) REFERENCES public.taxpayer(taxpayer_id);


--
-- TOC entry 2937 (class 6104 OID 17631)
-- Name: pub_taxes_collection; Type: PUBLICATION; Schema: -; Owner: postgres
--

CREATE PUBLICATION pub_taxes_collection WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION pub_taxes_collection OWNER TO postgres;

--
-- TOC entry 2944 (class 6106 OID 17632)
-- Name: pub_taxes_collection agency; Type: PUBLICATION TABLE; Schema: public; Owner: 
--

ALTER PUBLICATION pub_taxes_collection ADD TABLE ONLY public.agency;


--
-- TOC entry 2945 (class 6106 OID 17635)
-- Name: pub_taxes_collection agency_phone_number; Type: PUBLICATION TABLE; Schema: public; Owner: 
--

ALTER PUBLICATION pub_taxes_collection ADD TABLE ONLY public.agency_phone_number;


--
-- TOC entry 2942 (class 6106 OID 17636)
-- Name: pub_taxes_collection company; Type: PUBLICATION TABLE; Schema: public; Owner: 
--

ALTER PUBLICATION pub_taxes_collection ADD TABLE ONLY public.company;


--
-- TOC entry 2941 (class 6106 OID 17637)
-- Name: pub_taxes_collection individual; Type: PUBLICATION TABLE; Schema: public; Owner: 
--

ALTER PUBLICATION pub_taxes_collection ADD TABLE ONLY public.individual;


--
-- TOC entry 2943 (class 6106 OID 17638)
-- Name: pub_taxes_collection own_rel; Type: PUBLICATION TABLE; Schema: public; Owner: 
--

ALTER PUBLICATION pub_taxes_collection ADD TABLE ONLY public.own_rel;


--
-- TOC entry 2940 (class 6106 OID 17639)
-- Name: pub_taxes_collection phone_type; Type: PUBLICATION TABLE; Schema: public; Owner: 
--

ALTER PUBLICATION pub_taxes_collection ADD TABLE ONLY public.phone_type;


--
-- TOC entry 2946 (class 6106 OID 17640)
-- Name: pub_taxes_collection tax_payment; Type: PUBLICATION TABLE; Schema: public; Owner: 
--

ALTER PUBLICATION pub_taxes_collection ADD TABLE ONLY public.tax_payment;


--
-- TOC entry 2947 (class 6106 OID 17634)
-- Name: pub_taxes_collection tax_type; Type: PUBLICATION TABLE; Schema: public; Owner: 
--

ALTER PUBLICATION pub_taxes_collection ADD TABLE ONLY public.tax_type;


--
-- TOC entry 2938 (class 6106 OID 17633)
-- Name: pub_taxes_collection taxpayer; Type: PUBLICATION TABLE; Schema: public; Owner: 
--

ALTER PUBLICATION pub_taxes_collection ADD TABLE ONLY public.taxpayer;


--
-- TOC entry 2939 (class 6106 OID 17641)
-- Name: pub_taxes_collection taxpayer_phone_number; Type: PUBLICATION TABLE; Schema: public; Owner: 
--

ALTER PUBLICATION pub_taxes_collection ADD TABLE ONLY public.taxpayer_phone_number;


--
-- TOC entry 2973 (class 0 OID 0)
-- Dependencies: 207
-- Name: TABLE agency; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.agency TO rep;


--
-- TOC entry 2975 (class 0 OID 0)
-- Dependencies: 209
-- Name: TABLE agency_phone_number; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.agency_phone_number TO rep;


--
-- TOC entry 2977 (class 0 OID 0)
-- Dependencies: 203
-- Name: TABLE company; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.company TO rep;


--
-- TOC entry 2978 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE individual; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.individual TO rep;


--
-- TOC entry 2979 (class 0 OID 0)
-- Dependencies: 205
-- Name: TABLE own_rel; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.own_rel TO rep;


--
-- TOC entry 2981 (class 0 OID 0)
-- Dependencies: 201
-- Name: TABLE phone_type; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.phone_type TO rep;


--
-- TOC entry 2983 (class 0 OID 0)
-- Dependencies: 211
-- Name: TABLE tax_payment; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.tax_payment TO rep;


--
-- TOC entry 2985 (class 0 OID 0)
-- Dependencies: 213
-- Name: TABLE tax_type; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.tax_type TO rep;


--
-- TOC entry 2987 (class 0 OID 0)
-- Dependencies: 197
-- Name: TABLE taxpayer; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.taxpayer TO rep;


--
-- TOC entry 2988 (class 0 OID 0)
-- Dependencies: 199
-- Name: TABLE taxpayer_phone_number; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.taxpayer_phone_number TO rep;


-- Completed on 2019-09-11 16:07:06

--
-- PostgreSQL database dump complete
--

