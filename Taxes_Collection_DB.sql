--
-- PostgreSQL database dump
--

-- Dumped from database version 11.4
-- Dumped by pg_dump version 11.4

-- Started on 2019-09-06 15:36:10

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
-- TOC entry 2908 (class 1262 OID 16867)
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

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 202 (class 1259 OID 17126)
-- Name: agency; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.agency (
    agency_id character varying NOT NULL,
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
-- TOC entry 203 (class 1259 OID 17136)
-- Name: agency_phone_number; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.agency_phone_number (
    rel_id character varying NOT NULL,
    agency_id character varying,
    phone_number character varying NOT NULL,
    phone_type_id character varying,
    created_at timestamp without time zone NOT NULL,
    created_by character varying NOT NULL,
    last_upd_by character varying NOT NULL
);


ALTER TABLE public.agency_phone_number OWNER TO postgres;

--
-- TOC entry 200 (class 1259 OID 17108)
-- Name: company; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.company (
    taxpayer_id character varying NOT NULL,
    cuit_number character varying NOT NULL,
    comencement_date date NOT NULL,
    website character varying,
    created_at timestamp without time zone NOT NULL,
    created_by character varying NOT NULL,
    last_upd_by character varying NOT NULL
);


ALTER TABLE public.company OWNER TO postgres;

--
-- TOC entry 199 (class 1259 OID 17100)
-- Name: individual; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.individual (
    taxpayer_id character varying NOT NULL,
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
-- TOC entry 201 (class 1259 OID 17118)
-- Name: own_rel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.own_rel (
    rel_id character varying NOT NULL,
    individual_id character varying,
    company_id character varying,
    start_date timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    created_by character varying NOT NULL,
    last_upd_by character varying NOT NULL
);


ALTER TABLE public.own_rel OWNER TO postgres;

--
-- TOC entry 198 (class 1259 OID 17090)
-- Name: phone_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.phone_type (
    phone_type_id character varying NOT NULL,
    type character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    created_by character varying NOT NULL,
    last_upd_by character varying NOT NULL
);


ALTER TABLE public.phone_type OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 17144)
-- Name: tax_payment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tax_payment (
    payment_id character varying NOT NULL,
    agency_id character varying,
    taxpayer_id character varying,
    amount numeric NOT NULL,
    payment_date timestamp without time zone NOT NULL,
    tax_type_id character varying,
    created_at timestamp without time zone NOT NULL,
    created_by character varying NOT NULL,
    last_upd_by character varying NOT NULL
);


ALTER TABLE public.tax_payment OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 17152)
-- Name: tax_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tax_type (
    tax_type_id character varying NOT NULL,
    type character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    created_by character varying NOT NULL,
    last_upd_by character varying NOT NULL
);


ALTER TABLE public.tax_type OWNER TO postgres;

--
-- TOC entry 196 (class 1259 OID 17074)
-- Name: taxpayer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.taxpayer (
    taxpayer_id character varying NOT NULL,
    type character varying NOT NULL,
    email character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    created_by character varying NOT NULL,
    last_upd_by character varying NOT NULL
);


ALTER TABLE public.taxpayer OWNER TO postgres;

--
-- TOC entry 197 (class 1259 OID 17082)
-- Name: taxpayer_phone_number; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.taxpayer_phone_number (
    rel_id character varying NOT NULL,
    taxpayer_id character varying,
    phone_number character varying NOT NULL,
    phone_type_id character varying,
    created_at timestamp without time zone NOT NULL,
    created_by character varying NOT NULL,
    last_upd_by character varying NOT NULL
);


ALTER TABLE public.taxpayer_phone_number OWNER TO postgres;

--
-- TOC entry 2899 (class 0 OID 17126)
-- Dependencies: 202
-- Data for Name: agency; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.agency (agency_id, number, address, person_in_charge, number_of_emp, created_at, created_by, last_upd_by) VALUES ('A1', '1', '5th Av. 400', 'Dana Harris', 10, '2019-09-06 15:17:53.849998', 'postgres', 'postgres');
INSERT INTO public.agency (agency_id, number, address, person_in_charge, number_of_emp, created_at, created_by, last_upd_by) VALUES ('A2', '2', 'Jacksonville 2323', 'Jack Craig', 15, '2019-09-06 15:19:14.05966', 'postgres', 'postgres');


--
-- TOC entry 2900 (class 0 OID 17136)
-- Dependencies: 203
-- Data for Name: agency_phone_number; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.agency_phone_number (rel_id, agency_id, phone_number, phone_type_id, created_at, created_by, last_upd_by) VALUES ('1', 'A1', '47474747', '1', '2019-09-06 15:21:27.14357', 'postgres', 'postgres');
INSERT INTO public.agency_phone_number (rel_id, agency_id, phone_number, phone_type_id, created_at, created_by, last_upd_by) VALUES ('2', 'A1', '57575757', '2', '2019-09-06 15:21:27.14357', 'postgres', 'postgres');
INSERT INTO public.agency_phone_number (rel_id, agency_id, phone_number, phone_type_id, created_at, created_by, last_upd_by) VALUES ('3', 'A2', '71717171', '1', '2019-09-06 15:21:27.14357', 'postgres', 'postgres');


--
-- TOC entry 2897 (class 0 OID 17108)
-- Dependencies: 200
-- Data for Name: company; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.company (taxpayer_id, cuit_number, comencement_date, website, created_at, created_by, last_upd_by) VALUES ('2', '4781010', '2005-07-22', 'www.newcompany.com', '2019-09-06 15:13:44.241408', 'postgres', 'postgres');


--
-- TOC entry 2896 (class 0 OID 17100)
-- Dependencies: 199
-- Data for Name: individual; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.individual (taxpayer_id, doc_number, first_name, last_name, date_of_birth, home_address, created_at, created_by, last_upd_by) VALUES ('1', '12345678', 'John', 'Jackson', '1997-10-10', 'Newark Ave. 132', '2019-09-06 15:10:45.251463', 'postgres', 'postgres');


--
-- TOC entry 2898 (class 0 OID 17118)
-- Dependencies: 201
-- Data for Name: own_rel; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.own_rel (rel_id, individual_id, company_id, start_date, created_at, created_by, last_upd_by) VALUES ('1', '1', '2', '2005-07-22 00:00:00', '2019-09-06 15:15:21.577144', 'postgres', 'postgres');


--
-- TOC entry 2895 (class 0 OID 17090)
-- Dependencies: 198
-- Data for Name: phone_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.phone_type (phone_type_id, type, created_at, created_by, last_upd_by) VALUES ('1', 'Landline', '2019-09-06 15:01:00.045838', 'postgres', 'postgres');
INSERT INTO public.phone_type (phone_type_id, type, created_at, created_by, last_upd_by) VALUES ('2', 'Mobile', '2019-09-06 15:01:00.045838', 'postgres', 'postgres');
INSERT INTO public.phone_type (phone_type_id, type, created_at, created_by, last_upd_by) VALUES ('3', 'Fax', '2019-09-06 15:01:00.045838', 'postgres', 'postgres');


--
-- TOC entry 2901 (class 0 OID 17144)
-- Dependencies: 204
-- Data for Name: tax_payment; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by, last_upd_by) VALUES ('1', 'A1', '1', 170, '2019-03-14 00:00:00', '1', '2019-09-06 15:27:48.347083', 'postgres', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by, last_upd_by) VALUES ('2', 'A1', '1', 2500, '2019-04-17 00:00:00', '3', '2019-09-06 15:27:48.347083', 'postgres', 'postgres');
INSERT INTO public.tax_payment (payment_id, agency_id, taxpayer_id, amount, payment_date, tax_type_id, created_at, created_by, last_upd_by) VALUES ('3', 'A2', '2', 17000, '2019-04-20 00:00:00', '4', '2019-09-06 15:27:48.347083', 'postgres', 'postgres');


--
-- TOC entry 2902 (class 0 OID 17152)
-- Dependencies: 205
-- Data for Name: tax_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tax_type (tax_type_id, type, created_at, created_by, last_upd_by) VALUES ('1', 'Stamp Duty', '2019-09-06 15:24:17.83752', 'postgres', 'postgres');
INSERT INTO public.tax_type (tax_type_id, type, created_at, created_by, last_upd_by) VALUES ('2', 'Real Estate', '2019-09-06 15:24:17.83752', 'postgres', 'postgres');
INSERT INTO public.tax_type (tax_type_id, type, created_at, created_by, last_upd_by) VALUES ('3', 'Automotive Patent', '2019-09-06 15:24:17.83752', 'postgres', 'postgres');
INSERT INTO public.tax_type (tax_type_id, type, created_at, created_by, last_upd_by) VALUES ('4', 'Gross Income', '2019-09-06 15:24:17.83752', 'postgres', 'postgres');


--
-- TOC entry 2893 (class 0 OID 17074)
-- Dependencies: 196
-- Data for Name: taxpayer; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by, last_upd_by) VALUES ('1', 'I', 'taxpayer1@gmail.com', '2019-09-06 15:03:54.864715', 'postgres', 'postgres');
INSERT INTO public.taxpayer (taxpayer_id, type, email, created_at, created_by, last_upd_by) VALUES ('2', 'C', 'taxpayer2@gmail.com', '2019-09-06 15:03:54.864715', 'postgres', 'postgres');


--
-- TOC entry 2894 (class 0 OID 17082)
-- Dependencies: 197
-- Data for Name: taxpayer_phone_number; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by, last_upd_by) VALUES ('1', '1', '11111111', '1', '2019-09-06 15:07:05.054228', 'postgres', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by, last_upd_by) VALUES ('2', '1', '22222222', '2', '2019-09-06 15:07:05.054228', 'postgres', 'postgres');
INSERT INTO public.taxpayer_phone_number (rel_id, taxpayer_id, phone_number, phone_type_id, created_at, created_by, last_upd_by) VALUES ('3', '2', '33333333', '1', '2019-09-06 15:07:05.054228', 'postgres', 'postgres');


--
-- TOC entry 2748 (class 2606 OID 17135)
-- Name: agency agency_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agency
    ADD CONSTRAINT agency_number_key UNIQUE (number);


--
-- TOC entry 2752 (class 2606 OID 17143)
-- Name: agency_phone_number agency_phone_number_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agency_phone_number
    ADD CONSTRAINT agency_phone_number_pkey PRIMARY KEY (rel_id);


--
-- TOC entry 2750 (class 2606 OID 17133)
-- Name: agency agency_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agency
    ADD CONSTRAINT agency_pkey PRIMARY KEY (agency_id);


--
-- TOC entry 2741 (class 2606 OID 17117)
-- Name: company company_cuit_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT company_cuit_number_key UNIQUE (cuit_number);


--
-- TOC entry 2743 (class 2606 OID 17115)
-- Name: company company_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT company_pkey PRIMARY KEY (taxpayer_id);


--
-- TOC entry 2739 (class 2606 OID 17107)
-- Name: individual individual_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individual
    ADD CONSTRAINT individual_pkey PRIMARY KEY (taxpayer_id);


--
-- TOC entry 2745 (class 2606 OID 17125)
-- Name: own_rel own_rel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.own_rel
    ADD CONSTRAINT own_rel_pkey PRIMARY KEY (rel_id);


--
-- TOC entry 2735 (class 2606 OID 17097)
-- Name: phone_type phone_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.phone_type
    ADD CONSTRAINT phone_type_pkey PRIMARY KEY (phone_type_id);


--
-- TOC entry 2737 (class 2606 OID 17099)
-- Name: phone_type phone_type_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.phone_type
    ADD CONSTRAINT phone_type_type_key UNIQUE (type);


--
-- TOC entry 2755 (class 2606 OID 17151)
-- Name: tax_payment tax_payment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_payment
    ADD CONSTRAINT tax_payment_pkey PRIMARY KEY (payment_id);


--
-- TOC entry 2758 (class 2606 OID 17159)
-- Name: tax_type tax_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_type
    ADD CONSTRAINT tax_type_pkey PRIMARY KEY (tax_type_id);


--
-- TOC entry 2760 (class 2606 OID 17161)
-- Name: tax_type tax_type_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_type
    ADD CONSTRAINT tax_type_type_key UNIQUE (type);


--
-- TOC entry 2732 (class 2606 OID 17089)
-- Name: taxpayer_phone_number taxpayer_phone_number_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taxpayer_phone_number
    ADD CONSTRAINT taxpayer_phone_number_pkey PRIMARY KEY (rel_id);


--
-- TOC entry 2730 (class 2606 OID 17081)
-- Name: taxpayer taxpayer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taxpayer
    ADD CONSTRAINT taxpayer_pkey PRIMARY KEY (taxpayer_id);


--
-- TOC entry 2753 (class 1259 OID 17219)
-- Name: agency_phone_number_u_1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX agency_phone_number_u_1 ON public.agency_phone_number USING btree (agency_id, phone_number);


--
-- TOC entry 2746 (class 1259 OID 17218)
-- Name: own_rel_u_1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX own_rel_u_1 ON public.own_rel USING btree (individual_id, company_id);


--
-- TOC entry 2756 (class 1259 OID 17220)
-- Name: tax_payment_u_1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX tax_payment_u_1 ON public.tax_payment USING btree (agency_id, taxpayer_id, payment_date, tax_type_id);


--
-- TOC entry 2733 (class 1259 OID 17217)
-- Name: taxpayer_phone_number_u_1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX taxpayer_phone_number_u_1 ON public.taxpayer_phone_number USING btree (taxpayer_id, phone_number);


--
-- TOC entry 2767 (class 2606 OID 17192)
-- Name: agency_phone_number agency_phone_number_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agency_phone_number
    ADD CONSTRAINT agency_phone_number_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agency(agency_id);


--
-- TOC entry 2768 (class 2606 OID 17197)
-- Name: agency_phone_number agency_phone_number_phone_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agency_phone_number
    ADD CONSTRAINT agency_phone_number_phone_type_id_fkey FOREIGN KEY (phone_type_id) REFERENCES public.phone_type(phone_type_id);


--
-- TOC entry 2764 (class 2606 OID 17177)
-- Name: company company_taxpayer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT company_taxpayer_id_fkey FOREIGN KEY (taxpayer_id) REFERENCES public.taxpayer(taxpayer_id);


--
-- TOC entry 2763 (class 2606 OID 17172)
-- Name: individual individual_taxpayer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individual
    ADD CONSTRAINT individual_taxpayer_id_fkey FOREIGN KEY (taxpayer_id) REFERENCES public.taxpayer(taxpayer_id);


--
-- TOC entry 2766 (class 2606 OID 17187)
-- Name: own_rel own_rel_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.own_rel
    ADD CONSTRAINT own_rel_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.taxpayer(taxpayer_id);


--
-- TOC entry 2765 (class 2606 OID 17182)
-- Name: own_rel own_rel_individual_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.own_rel
    ADD CONSTRAINT own_rel_individual_id_fkey FOREIGN KEY (individual_id) REFERENCES public.taxpayer(taxpayer_id);


--
-- TOC entry 2769 (class 2606 OID 17202)
-- Name: tax_payment tax_payment_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_payment
    ADD CONSTRAINT tax_payment_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agency(agency_id);


--
-- TOC entry 2771 (class 2606 OID 17212)
-- Name: tax_payment tax_payment_tax_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_payment
    ADD CONSTRAINT tax_payment_tax_type_id_fkey FOREIGN KEY (tax_type_id) REFERENCES public.tax_type(tax_type_id);


--
-- TOC entry 2770 (class 2606 OID 17207)
-- Name: tax_payment tax_payment_taxpayer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_payment
    ADD CONSTRAINT tax_payment_taxpayer_id_fkey FOREIGN KEY (taxpayer_id) REFERENCES public.taxpayer(taxpayer_id);


--
-- TOC entry 2762 (class 2606 OID 17167)
-- Name: taxpayer_phone_number taxpayer_phone_number_phone_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taxpayer_phone_number
    ADD CONSTRAINT taxpayer_phone_number_phone_type_id_fkey FOREIGN KEY (phone_type_id) REFERENCES public.phone_type(phone_type_id);


--
-- TOC entry 2761 (class 2606 OID 17162)
-- Name: taxpayer_phone_number taxpayer_phone_number_taxpayer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taxpayer_phone_number
    ADD CONSTRAINT taxpayer_phone_number_taxpayer_id_fkey FOREIGN KEY (taxpayer_id) REFERENCES public.taxpayer(taxpayer_id);


-- Completed on 2019-09-06 15:36:10

--
-- PostgreSQL database dump complete
--

