--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: postgres; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: adminpack; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS adminpack WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION adminpack; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION adminpack IS 'administrative functions for PostgreSQL';


SET search_path = public, pg_catalog;

--
-- Name: hibernate_sequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE hibernate_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.hibernate_sequence OWNER TO postgres;

--
-- Name: hibernate_sequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('hibernate_sequence', 44, true);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: routes; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE routes (
    id_route numeric NOT NULL,
    description character(30),
    cost double precision
);


ALTER TABLE public.routes OWNER TO postgres;

--
-- Name: routevalues; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE routevalues (
    id_route numeric NOT NULL,
    pos numeric NOT NULL,
    x double precision,
    y double precision
);


ALTER TABLE public.routevalues OWNER TO postgres;

--
-- Name: userroutes; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE userroutes (
    id_user numeric NOT NULL,
    id_route numeric NOT NULL
);


ALTER TABLE public.userroutes OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE users (
    id_user numeric NOT NULL,
    first_name character(30),
    last_name character(30),
    e_mail character(30)
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: routes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY routes (id_route, description, cost) FROM stdin;
1	Sights                        	0
2	Impressionism                 	0
3	French_Revolution             	5
4	Russian_Emigration            	10
5	Theatres                      	7
6	Middle_Ages                   	6
7	Transport                     	8
\.


--
-- Data for Name: routevalues; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY routevalues (id_route, pos, x, y) FROM stdin;
1	1	48.859922252927717	2.2681403160095215
1	2	48.85560224934877	2.3149394989013672
1	3	48.860642217277437	2.3255610466003418
1	4	48.860148125211126	2.3529624938964844
1	5	48.859131691908949	2.3621892929077148
2	1	48.857328177859067	2.3521685600280762
2	2	48.856212860716944	2.3465681076049805
2	3	48.862604420477275	2.3248100280761719
2	4	48.853805667518657	2.312396764755249
2	5	48.804722416109335	2.1238803863525391
3	1	48.832894926647285	2.3162698745727539
3	2	48.85615285877072	2.2976875305175781
3	3	48.862777344771928	2.3352706432342529
3	4	48.874337213533956	2.2954022884368896
3	5	48.88742882058753	2.3397445678710938
4	1	48.630335000000002	2.343788
4	2	48.644705999999999	2.3398590000000001
4	3	48.800673000000003	2.258327
4	4	48.837662000000002	2.3493330000000001
4	5	48.839807999999998	2.345942
5	1	48.878264000000001	2.3371550000000001
5	2	48.870176999999998	2.3324669999999998
5	3	48.865476999999998	2.3030050000000002
5	4	48.864376	2.3359540000000001
5	5	48.852376	2.370447
6	1	48.850074999999997	2.3443329999999998
6	2	48.851416999999998	2.3431670000000002
6	3	48.853889000000002	2.334444
6	4	48.886944	2.3411110000000002
6	5	48.857599999999998	2.361453
6	6	48.852778000000001	2.3500000000000001
7	1	48.871389000000001	2.2766670000000002
7	2	48.869722000000003	2.2850000000000001
7	3	48.844721999999997	2.3736109999999999
7	4	48.876944000000002	2.3591669999999998
7	5	48.876944000000002	2.3244440000000002
7	5	48.876944000000002	2.3244440000000002
\.


--
-- Data for Name: userroutes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY userroutes (id_user, id_route) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY users (id_user, first_name, last_name, e_mail) FROM stdin;
\.


--
-- Name: routes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY routes
    ADD CONSTRAINT routes_pkey PRIMARY KEY (id_route);


--
-- Name: userroutes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY userroutes
    ADD CONSTRAINT userroutes_pkey PRIMARY KEY (id_user, id_route);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id_user);


--
-- Name: userroutes_id_route_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY routevalues
    ADD CONSTRAINT userroutes_id_route_fkey FOREIGN KEY (id_route) REFERENCES routes(id_route);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

