--
-- PostgreSQL database dump
--

\restrict NYqrRFqfbOzzgpme3suMw0kR4zDQRDTfgIr30VSCTLI23L6glKnRTQSz0zGIwEU

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

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
-- Name: casamentos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.casamentos (
    id integer NOT NULL,
    marido_id integer NOT NULL,
    esposa_id integer NOT NULL,
    observacao text
);


--
-- Name: casamentos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.casamentos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: casamentos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.casamentos_id_seq OWNED BY public.casamentos.id;


--
-- Name: config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.config (
    chave text NOT NULL,
    valor text NOT NULL
);


--
-- Name: curiosidades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.curiosidades (
    id integer NOT NULL,
    pessoa_id integer NOT NULL,
    texto text NOT NULL,
    ordem integer DEFAULT 0 NOT NULL
);


--
-- Name: curiosidades_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.curiosidades_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: curiosidades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.curiosidades_id_seq OWNED BY public.curiosidades.id;


--
-- Name: filiacoes_alternativas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.filiacoes_alternativas (
    id integer NOT NULL,
    filho_id integer NOT NULL,
    pai_id integer NOT NULL,
    fonte text NOT NULL,
    observacao text,
    CONSTRAINT filiacoes_alternativas_check CHECK ((filho_id <> pai_id))
);


--
-- Name: filiacoes_alternativas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.filiacoes_alternativas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: filiacoes_alternativas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.filiacoes_alternativas_id_seq OWNED BY public.filiacoes_alternativas.id;


--
-- Name: links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.links (
    id integer NOT NULL,
    pessoa_id integer NOT NULL,
    titulo text NOT NULL,
    url text NOT NULL,
    ordem integer DEFAULT 0 NOT NULL
);


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.links_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.links_id_seq OWNED BY public.links.id;


--
-- Name: livros; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.livros (
    codigo text NOT NULL,
    nome text NOT NULL,
    abrev text NOT NULL,
    nome_en text NOT NULL,
    ordem integer NOT NULL,
    testamento character(2) NOT NULL,
    CONSTRAINT livros_testamento_check CHECK ((testamento = ANY (ARRAY['AT'::bpchar, 'NT'::bpchar])))
);


--
-- Name: papeis; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.papeis (
    id integer NOT NULL,
    pessoa_id integer NOT NULL,
    papel text NOT NULL,
    inicio integer,
    fim integer,
    local text,
    observacao text,
    CONSTRAINT papeis_check CHECK (((fim IS NULL) OR (inicio IS NULL) OR (fim >= inicio)))
);


--
-- Name: papeis_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.papeis_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: papeis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.papeis_id_seq OWNED BY public.papeis.id;


--
-- Name: pessoas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pessoas (
    id integer NOT NULL,
    nome text NOT NULL,
    sexo character(1) NOT NULL,
    significado_nome text,
    ano_nascimento integer,
    nascimento_aprox boolean DEFAULT false NOT NULL,
    ano_morte integer,
    morte_aprox boolean DEFAULT false NOT NULL,
    idade_morte integer,
    pai_id integer,
    mae_id integer,
    sem_nome boolean DEFAULT false NOT NULL,
    resumo text,
    historia text,
    criado_em timestamp with time zone DEFAULT now() NOT NULL,
    atualizado_em timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT pessoas_check CHECK (((pai_id IS NULL) OR (pai_id <> id))),
    CONSTRAINT pessoas_check1 CHECK (((mae_id IS NULL) OR (mae_id <> id))),
    CONSTRAINT pessoas_sexo_check CHECK ((sexo = ANY (ARRAY['M'::bpchar, 'F'::bpchar])))
);


--
-- Name: pessoas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pessoas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pessoas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pessoas_id_seq OWNED BY public.pessoas.id;


--
-- Name: referencias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.referencias (
    id integer NOT NULL,
    pessoa_id integer NOT NULL,
    livro text NOT NULL,
    capitulo integer NOT NULL,
    versiculo_inicio integer,
    capitulo_fim integer,
    versiculo_fim integer,
    descricao text,
    ordem integer DEFAULT 0 NOT NULL
);


--
-- Name: referencias_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.referencias_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: referencias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.referencias_id_seq OWNED BY public.referencias.id;


--
-- Name: reinados; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reinados (
    id integer NOT NULL,
    pessoa_id integer NOT NULL,
    reino text NOT NULL,
    inicio integer NOT NULL,
    fim integer NOT NULL,
    observacao text,
    CONSTRAINT reinados_check CHECK ((fim >= inicio))
);


--
-- Name: reinados_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reinados_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reinados_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reinados_id_seq OWNED BY public.reinados.id;


--
-- Name: casamentos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.casamentos ALTER COLUMN id SET DEFAULT nextval('public.casamentos_id_seq'::regclass);


--
-- Name: curiosidades id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.curiosidades ALTER COLUMN id SET DEFAULT nextval('public.curiosidades_id_seq'::regclass);


--
-- Name: filiacoes_alternativas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filiacoes_alternativas ALTER COLUMN id SET DEFAULT nextval('public.filiacoes_alternativas_id_seq'::regclass);


--
-- Name: links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.links ALTER COLUMN id SET DEFAULT nextval('public.links_id_seq'::regclass);


--
-- Name: papeis id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.papeis ALTER COLUMN id SET DEFAULT nextval('public.papeis_id_seq'::regclass);


--
-- Name: pessoas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pessoas ALTER COLUMN id SET DEFAULT nextval('public.pessoas_id_seq'::regclass);


--
-- Name: referencias id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.referencias ALTER COLUMN id SET DEFAULT nextval('public.referencias_id_seq'::regclass);


--
-- Name: reinados id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reinados ALTER COLUMN id SET DEFAULT nextval('public.reinados_id_seq'::regclass);


--
-- Data for Name: casamentos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.casamentos (id, marido_id, esposa_id, observacao) FROM stdin;
1	1	2	\N
2	9	10	\N
3	9	11	\N
4	50	51	\N
5	55	56	\N
6	55	57	Concubina, dada por Sara
7	59	62	\N
8	64	65	\N
9	64	66	\N
10	64	67	Concubina
11	64	68	Concubina
12	80	82	\N
13	78	85	\N
14	78	89	\N
15	86	89	Primeiro marido
16	96	97	\N
17	99	100	\N
18	101	103	Primeiro marido
19	98	103	\N
20	111	110	\N
21	111	112	\N
22	111	113	\N
23	111	114	\N
24	111	115	\N
25	111	116	\N
26	117	116	Primeiro marido
27	123	125	\N
28	126	127	\N
29	155	156	\N
30	141	195	\N
31	198	199	\N
32	207	208	\N
33	131	211	\N
34	229	230	\N
35	233	235	\N
36	232	238	\N
37	275	277	\N
38	279	280	\N
39	304	305	\N
40	319	320	\N
41	345	346	\N
\.


--
-- Data for Name: config; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.config (chave, valor) FROM stdin;
ano_criacao	-4026
\.


--
-- Data for Name: curiosidades; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.curiosidades (id, pessoa_id, texto, ordem) FROM stdin;
1	1	Pela cronologia adotada, Adão ainda vivia quando Lameque, pai de Noé, nasceu (3152 a.C.); Adão morreu em 3096 a.C.	0
2	1	Gênesis 5:3 diz que Sete foi gerado “à semelhança e conforme a imagem” de Adão, eco de Gn 1:26.	1
3	1	Lucas 3:38 encerra a genealogia de Jesus em “Adão, filho de Deus”.	2
4	2	Gn 3:15 é chamado de “protoevangelho”, a primeira promessa do Redentor.	0
5	2	Antes da queda ela é chamada apenas ’ishah, “varoa”/“mulher” (Gn 2:23); o nome Eva só é dado em Gn 3:20.	1
6	2	A Bíblia não registra a idade nem a morte de Eva.	2
7	3	A primeira cidade mencionada na Bíblia foi edificada por Caim (Gn 4:17).	0
8	3	A “marca de Caim” era um sinal de proteção, para que ninguém o matasse (Gn 4:15).	1
9	3	Ano de nascimento aproximado: a Bíblia não informa o intervalo entre a criação e o nascimento de Caim.	2
10	4	Hebel é a mesma palavra traduzida como “vaidade” em Eclesiastes (“vaidade de vaidades”).	0
11	4	Jesus cita Abel como o primeiro justo assassinado da história (Mt 23:35).	1
12	4	A data da morte é estimada: antes do nascimento de Sete (3896 a.C.), dado “em lugar de Abel” (Gn 4:25).	2
13	5	Não confundir com Enoque, o sétimo depois de Adão, que andou com Deus (Gn 5:18-24).	0
14	9	Jesus inverte a lógica de Lameque ao mandar perdoar “setenta vezes sete” (Mt 18:22).	0
15	9	Não confundir com Lameque, pai de Noé (Gn 5:25-31).	1
16	13	É o primeiro músico citado na Bíblia.	0
17	16	É o único filho de Adão, além de Caim e Abel, cujo nome a Bíblia registra.	0
18	17	“Então se começou a invocar o nome do Senhor” (Gn 4:26): o primeiro registro de culto público.	0
19	20	Viveu 962 anos, perdendo apenas para o neto Metusalém (969).	0
20	21	O ano de “morte” indica quando foi tomado por Deus, não uma morte.	0
21	21	Viveu 365 anos, o mesmo número de dias do ano solar.	1
22	21	Junto com Elias (2Rs 2:11), é um dos dois homens que, segundo a Bíblia, não passaram pela morte.	2
23	22	É a pessoa mais longeva registrada na Bíblia (Gn 5:27).	0
24	22	Somando as idades de Gn 5, Metusalém morreu no próprio ano do dilúvio (2370 a.C.).	1
25	23	Chamou o filho de Noé dizendo: “Este nos consolará acerca de nossas obras” (Gn 5:29).	0
26	23	Morreu cinco anos antes do dilúvio, aos 777 anos.	1
27	24	A arca media 300 × 50 × 30 côvados, cerca de 135 × 22 × 13 metros (Gn 6:15).	0
28	24	Pela cronologia adotada, o dilúvio ocorreu em 2370 a.C.	1
29	24	Noé morreu em 2020 a.C., apenas dois anos antes do nascimento de Abraão.	2
30	25	A tradição associa seus descendentes aos povos da Ásia Menor e da Europa.	0
31	26	Dele vem o termo “semita”.	0
32	26	Pela cronologia de Gn 11, Sem viveu até 1868 a.C.: foi contemporâneo de Abraão por 150 anos.	1
33	27	Na poesia dos Salmos, o Egito é chamado de “terra de Cam” (Sl 105:23).	0
34	36	Mizraim é o nome hebraico do Egito em todo o Antigo Testamento.	0
35	38	A terra prometida a Abraão leva o nome deste neto de Noé.	0
36	39	A tradição judaica o liga à construção da Torre de Babel, embora Gn 11 não o cite.	0
37	40	Lucas 3:36 inclui um Cainã entre Arfaxade e Selá, seguindo a Septuaginta.	0
38	42	É a provável origem do termo “hebreu” (‘ibri).	0
39	42	Pela cronologia de Gn 11, Héber morreu em 1839 a.C., depois do próprio Abraão.	1
40	43	A divisão da terra em seus dias é ligada por muitos intérpretes à dispersão de Babel (Gn 11:1-9).	0
41	48	Josué 24:2 afirma que Terá servia a outros deuses além do rio.	0
42	48	Gn 11:26 diz que Terá tinha 70 anos quando “gerou Abrão, Naor e Harã”. Como At 7:4 diz que Abraão saiu de Harã após a morte do pai, a cronologia adotada considera Abraão nascido quando Terá tinha 130 anos.	1
43	49	É a primeira morte registrada de um filho antes do pai (Gn 11:28).	0
44	51	Casou-se com o próprio tio, Naor.	0
45	52	Pedro o chama de “justo Ló”, que se afligia com a conduta dos sodomitas (2Pe 2:7).	0
46	53	Rute, bisavó de Davi, era moabita.	0
47	54	Naamá, mãe do rei Roboão, era amonita (1Rs 14:21).	0
48	55	É chamado de “amigo de Deus” (2Cr 20:7; Is 41:8; Tg 2:23).	0
49	55	Judeus, cristãos e muçulmanos o reconhecem como patriarca.	1
50	55	“Creu Abrão no Senhor, e isso lhe foi imputado como justiça” (Gn 15:6) é citado três vezes no NT.	2
51	56	Era meia-irmã de Abraão, filha de Terá com outra mulher (Gn 20:12).	0
52	56	É a única mulher na Bíblia cuja idade ao morrer é registrada (127 anos, Gn 23:1).	1
53	57	É a primeira pessoa na Bíblia a dar um nome a Deus: El-Roi (Gn 16:13).	0
54	58	Assim como Jacó, teve doze filhos que se tornaram chefes de tribos (Gn 25:16).	0
55	58	Ismael e Isaque sepultaram juntos o pai Abraão (Gn 25:9).	1
56	59	Foi o patriarca que viveu mais tempo (180 anos) e o que menos se afastou de Canaã.	0
57	59	Gálatas 4:28 apresenta os cristãos como “filhos da promessa, como Isaque”.	1
58	61	Enganou Jacó dando-lhe Lia no lugar de Raquel, e mudou seu salário dez vezes (Gn 31:7).	0
59	62	Para dar água a dez camelos ela pode ter carregado centenas de litros do poço.	0
60	63	Vendeu a primogenitura por um prato de guisado vermelho (Gn 25:30-34).	0
61	63	Herodes, o Grande, era idumeu, descendente de Edom.	1
62	64	Serviu catorze anos por Raquel, “e lhe pareceram como poucos dias, pelo muito que a amava” (Gn 29:20).	0
63	64	Desceu ao Egito com 130 anos (Gn 47:9), em 1728 a.C. pela cronologia adotada.	1
64	65	Embora menos amada, foi mãe da tribo sacerdotal (Levi) e da tribo real (Judá).	0
65	66	Morreu ao dar à luz Benjamim, a caminho de Belém, e foi sepultada ali (Gn 35:19).	0
66	77	Seus descendentes não receberam território: “o Senhor é a sua herança” (Dt 10:9).	0
67	78	O termo “judeu” vem do seu nome.	0
68	80	Pediu que seus ossos fossem levados a Canaã; Moisés os levou no Êxodo e eles foram sepultados em Siquém (Js 24:32).	0
69	80	Recebeu do faraó o nome egípcio Zafenate-Paneia (Gn 41:45).	1
70	81	Raquel o chamou de Benoni, “filho da minha dor”; Jacó mudou o nome para Benjamim.	0
71	81	O rei Saul e o apóstolo Paulo eram da tribo de Benjamim (Fp 3:5).	1
72	84	Jacó cruzou as mãos e pôs a direita sobre Efraim, o mais novo (Gn 48:14).	0
73	89	É uma das quatro mulheres citadas na genealogia de Jesus em Mateus, ao lado de Raabe, Rute e “a que fora mulher de Urias”.	0
74	91	A parteira amarrou um fio escarlate em sua mão, mas Perez nasceu primeiro (Gn 38:28-30).	0
75	95	Foi o primeiro líder tribal a apresentar oferta na dedicação do altar (Nm 7:12).	0
76	97	É citada tanto em Hebreus 11 (pela fé) quanto em Tiago 2 (pelas obras).	0
77	98	É um dos exemplos bíblicos do “resgatador”, figura usada para falar de Cristo.	0
78	98	Uma das colunas do templo de Salomão recebeu o nome de Boaz (1Rs 7:21).	1
79	100	De volta a Belém, pediu: “Não me chameis Noemi; chamai-me Mara (amarga)” (Rt 1:20).	0
80	103	É uma das duas mulheres que dão nome a um livro da Bíblia (a outra é Ester).	0
81	103	Sendo moabita, descendia de Ló, sobrinho de Abraão.	1
82	104	As vizinhas de Noemi é que lhe deram o nome (Rt 4:17).	0
83	105	Entre Salmom (época de Josué) e Davi há quase 500 anos e apenas quatro gerações listadas; muitos estudiosos entendem que a genealogia de Rute 4 omite gerações. Por isso os anos de Boaz, Obede e Jessé são apenas estimativas.	0
84	105	Costura da cronologia: até os Juízes, as datas vêm da soma das idades bíblicas a partir de Adão (4026 a.C.); de Saul em diante, seguem a cronologia histórica convencional (Davi rei em 1010 a.C., divisão do reino em 931 a.C., queda de Jerusalém em 586 a.C.). A diferença entre os dois sistemas fica absorvida aqui, no período dos Juízes.	1
85	107	Era “mais alto do que todo o povo, dos ombros para cima” (1Sm 9:2).	0
86	107	Paulo, cujo nome hebraico também era Saulo, era da mesma tribo de Benjamim.	1
87	108	Embora herdeiro do trono, reconheceu que Davi seria rei (1Sm 23:17).	0
88	109	Tinha cinco anos quando caiu do colo da ama ao fugir após a morte de Saul e Jônatas (2Sm 4:4).	0
89	111	Reinou 40 anos: 7 em Hebrom e 33 em Jerusalém (2Sm 5:4-5).	0
90	111	Cerca de 73 salmos levam seu nome no título.	1
91	111	Jesus é chamado “Filho de Davi” 17 vezes nos evangelhos.	2
92	113	Descrita como “sensata e formosa” (1Sm 25:3).	0
93	116	Mateus 1:6 não diz seu nome, mas a chama de “a que fora mulher de Urias”.	0
94	117	Recusou-se a ir para casa enquanto a arca e o exército estavam em campanha (2Sm 11:11).	0
95	117	Ele mesmo levou a Joabe a carta com a ordem de sua morte.	1
96	120	Famoso pela beleza e pela cabeleira; ficou preso pelos cabelos num carvalho na batalha (2Sm 18:9).	0
97	123	Teve 700 mulheres e 300 concubinas (1Rs 11:3).	0
98	123	Compôs 3.000 provérbios e 1.005 cânticos (1Rs 4:32).	1
99	123	Jesus disse que nem Salomão, em toda a sua glória, se vestiu como os lírios do campo (Mt 6:29).	2
100	124	Não confundir com o profeta Natã. Mateus segue a linhagem de Salomão; Lucas, a de Natã.	0
101	126	Seguindo o conselho dos jovens, endureceu os impostos e dez tribos se separaram (1Rs 12).	0
102	127	Roboão a amava mais que todas as suas 18 mulheres e 60 concubinas (2Cr 11:21).	0
103	127	Seu neto Asa a destituiu da posição de rainha-mãe por ter feito um ídolo a Aserá (1Rs 15:13).	1
104	128	Em 1 Reis é chamado Abião.	0
105	128	Em 2Cr 13 discursa ao exército de Israel lembrando a aliança de Deus com Davi, e vence a batalha.	1
106	129	Reinou 41 anos. No fim da vida, doente dos pés, “não buscou ao Senhor, mas aos médicos” (2Cr 16:12).	0
107	130	Na guerra contra Moabe e Amom, pôs cantores à frente do exército (2Cr 20:21-22).	0
108	131	Matou todos os seus irmãos ao assumir o trono (2Cr 21:4).	0
109	131	Morreu de uma doença intestinal, “e se foi sem deixar de si saudades” (2Cr 21:20).	1
110	132	Mateus 1:8 salta de Jorão para Uzias, omitindo Acazias, Joás e Amazias, provavelmente para manter o esquema de 14 gerações (Mt 1:17).	0
111	132	Foi morto por ordem de Jeú, junto com Jorão, rei de Israel.	1
112	133	Mateus 1:8 salta de Jorão para Uzias, omitindo Acazias, Joás e Amazias, provavelmente para manter o esquema de 14 gerações (Mt 1:17).	0
113	133	Foi salvo do massacre de Atalia, escondido no templo por seis anos, e coroado aos 7 anos (2Rs 11).	1
114	134	Mateus 1:8 salta de Jorão para Uzias, omitindo Acazias, Joás e Amazias, provavelmente para manter o esquema de 14 gerações (Mt 1:17).	0
115	135	Mateus 1:8 salta de Jorão para Uzias, omitindo Acazias, Joás e Amazias, provavelmente para manter o esquema de 14 gerações (Mt 1:17). Por isso, em Mateus, Uzias aparece como “filho” de Jorão, que na verdade era seu trisavô.	0
116	135	Ao queimar incenso no templo, função dos sacerdotes, foi ferido de lepra até a morte (2Cr 26:16-21).	1
117	136	Governou como corregente enquanto o pai estava leproso (2Rs 15:5).	0
118	137	A profecia “a virgem conceberá… Emanuel” (Is 7:14), citada em Mt 1:23, foi dada primeiramente a Acaz.	0
119	137	Fez passar o próprio filho pelo fogo (2Rs 16:3).	1
120	138	Deus lhe acrescentou 15 anos de vida, e a sombra do relógio de sol voltou dez graus (2Rs 20:1-11).	0
121	138	O túnel de Ezequias, que levava água à cidade, existe até hoje em Jerusalém (2Rs 20:20).	1
122	139	Reinou 55 anos, o mais longo dos reis de Judá.	0
123	139	Levado preso à Babilônia, humilhou-se e foi restaurado (2Cr 33:11-13).	1
124	141	Tornou-se rei aos 8 anos.	0
125	141	Durante a reforma do templo foi encontrado o “livro da Lei” (2Rs 22:8).	1
126	141	Morreu em Megido, lutando contra o faraó Neco (2Rs 23:29).	2
127	142	Mateus 1:11 diz que Josias “gerou Jeconias e seus irmãos”, pulando Jeoaquim, pai de Jeconias.	0
128	142	Cortou e queimou o rolo com as profecias de Jeremias (Jr 36:23).	1
129	143	Também chamado Joaquim e Conias.	0
130	143	Jeremias 22:30 declara que nenhum descendente seu se assentaria no trono de Davi. Como Jesus não descende de Jeconias pelo sangue (José era pai legal), muitos veem aqui uma razão para Lucas traçar a linhagem por Natã.	1
131	143	Na contagem de Mateus, Jeconias encerra o segundo bloco e abre o terceiro (Mt 1:17).	2
132	144	Aparece nas duas genealogias, mas Lucas o chama “filho de Neri” (Lc 3:27), não de Jeconias.	0
133	145	1 Crônicas 3:19 o apresenta como filho de Pedaías, irmão de Salatiel; uma explicação é o casamento de levirato.	0
134	145	Em Ageu 2:23 Deus o faz “como anel de selar”, revertendo a imagem usada contra Jeconias em Jr 22:24.	1
135	146	Conhecido apenas pela genealogia de Mateus. Os anos são distribuídos por igual entre Zorobabel e José, pois a Bíblia não informa os intervalos; com só 10 nomes para cerca de 550 anos, é provável que haja gerações omitidas.	0
136	147	Conhecido apenas pela genealogia de Mateus. Os anos são distribuídos por igual entre Zorobabel e José, pois a Bíblia não informa os intervalos; com só 10 nomes para cerca de 550 anos, é provável que haja gerações omitidas.	0
137	148	Conhecido apenas pela genealogia de Mateus. Os anos são distribuídos por igual entre Zorobabel e José, pois a Bíblia não informa os intervalos; com só 10 nomes para cerca de 550 anos, é provável que haja gerações omitidas.	0
138	149	Conhecido apenas pela genealogia de Mateus. Os anos são distribuídos por igual entre Zorobabel e José, pois a Bíblia não informa os intervalos; com só 10 nomes para cerca de 550 anos, é provável que haja gerações omitidas.	0
139	150	Conhecido apenas pela genealogia de Mateus. Os anos são distribuídos por igual entre Zorobabel e José, pois a Bíblia não informa os intervalos; com só 10 nomes para cerca de 550 anos, é provável que haja gerações omitidas.	0
140	151	Conhecido apenas pela genealogia de Mateus. Os anos são distribuídos por igual entre Zorobabel e José, pois a Bíblia não informa os intervalos; com só 10 nomes para cerca de 550 anos, é provável que haja gerações omitidas.	0
141	152	Conhecido apenas pela genealogia de Mateus. Os anos são distribuídos por igual entre Zorobabel e José, pois a Bíblia não informa os intervalos; com só 10 nomes para cerca de 550 anos, é provável que haja gerações omitidas.	0
142	153	Conhecido apenas pela genealogia de Mateus. Os anos são distribuídos por igual entre Zorobabel e José, pois a Bíblia não informa os intervalos; com só 10 nomes para cerca de 550 anos, é provável que haja gerações omitidas.	0
143	154	Conhecido apenas pela genealogia de Mateus. Os anos são distribuídos por igual entre Zorobabel e José, pois a Bíblia não informa os intervalos; com só 10 nomes para cerca de 550 anos, é provável que haja gerações omitidas.	0
144	154	Lucas 3:23 chama o pai de José de Eli, não de Jacó.	1
145	155	Assim como José do Egito, também filho de um Jacó, recebeu de Deus orientações por sonhos (Mt 1:20; 2:13; 2:19; 2:22).	0
146	155	Mateus 1:16 diz que seu pai era Jacó; Lucas 3:23, que era Eli.	1
147	155	Não há registro dele durante o ministério de Jesus; muitos supõem que já tinha morrido.	2
148	156	Maria é a quinta mulher citada na genealogia de Mateus, depois de Tamar, Raabe, Rute e “a mulher de Urias”.	0
149	156	Era parente de Isabel, mãe de João Batista (Lc 1:36).	1
150	156	A tradição (Protoevangelho de Tiago, séc. II) chama seus pais de Joaquim e Ana; a Bíblia não os nomeia.	2
151	156	Uma interpretação antiga vê em Lucas 3 a genealogia de Maria, sendo Eli seu pai e sogro de José.	3
152	157	O calendário a.C./d.C. foi calculado no séc. VI por Dionísio, o Exíguo, que errou alguns anos: como Herodes morreu em 4 a.C. (Mt 2:19), Jesus nasceu por volta de 6–4 a.C.	0
153	157	A idade de 33 anos é a estimativa tradicional: “cerca de 30 anos” no início do ministério (Lc 3:23) mais cerca de três anos de ministério.	1
154	157	Mateus 1:16 quebra o padrão “fulano gerou fulano”: “José, marido de Maria, da qual nasceu Jesus”. No grego, “da qual” é feminino, indicando que José não o gerou.	2
155	157	Lucas 3:23 diz que Jesus era “filho, como se supunha, de José”.	3
156	157	Mateus organiza a genealogia em 3 × 14 gerações (Mt 1:17). Em hebraico, as letras de Davi (DWD) somam 4 + 6 + 4 = 14.	4
157	157	Não há linha de pai no card: Jesus está ligado a Maria e posicionado sob José, seu pai legal.	5
158	157	Os evangelhos citam quatro irmãos (Tiago, José, Simão e Judas) e irmãs não nomeadas (Mt 13:55-56). Lc 2:7 chama Jesus de “primogênito” de Maria, e Mt 1:25 diz que José “não a conheceu até que deu à luz”. A forma como esses textos são lidos varia entre as tradições cristãs.	6
159	158	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
160	159	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
161	160	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
162	161	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
163	161	Não confundir com Eliaquim, filho de Abiúde, da lista de Mateus (Mt 1:13).	1
164	162	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
165	163	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
166	164	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
167	165	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
168	166	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
169	167	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
170	168	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
171	169	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
172	170	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
173	171	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
174	172	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
175	173	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
176	174	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
177	175	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
178	176	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
179	176	Segundo Lucas, é o pai de Salatiel; segundo Mateus (e 1Cr 3:17), o pai de Salatiel é o rei Jeconias. Uma explicação é que Salatiel seria filho biológico de Neri e herdeiro legal de Jeconias, ou vice-versa (levirato/adoção).	1
180	177	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
181	177	Não aparece entre os filhos de Zorobabel em 1Cr 3:19-20. Alguns estudiosos sugerem que “Resa” seja o aramaico rēšā’, “príncipe”, um título de Zorobabel lido como nome.	1
182	178	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
183	179	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
184	180	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
185	181	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
186	182	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
187	183	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
188	184	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
189	185	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
190	186	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
191	186	Não confundir com o profeta Naum.	1
192	187	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
193	187	Não confundir com o profeta Amós.	1
194	188	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
195	189	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
196	190	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
197	191	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
198	192	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
199	193	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
200	194	Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos.	0
201	194	Segundo Lucas 3:23, é o pai de José; segundo Mateus 1:16, o pai de José é Jacó.	1
202	194	Três explicações tradicionais: (1) Eli seria pai de Maria e sogro de José, e Lucas traria a linhagem de Maria; (2) Júlio Africano (séc. III, citado por Eusébio): Jacó e Eli eram meio-irmãos, Eli morreu sem filhos e Jacó gerou José em seu nome (levirato); (3) Mateus traz a linha legal/real e Lucas a natural.	2
203	195	Filha de Jeremias de Libna, não o profeta (2Rs 23:31).	0
204	196	Também chamado Salum (Jr 22:11).	0
205	196	Foi o primeiro rei de Judá a morrer no exílio, no Egito.	1
206	197	Seu nome original era Matanias; Nabucodonosor o mudou para Zedequias (2Rs 24:17).	0
207	197	Viu os filhos serem mortos, teve os olhos vazados e foi levado acorrentado à Babilônia (2Rs 25:7).	1
208	197	Consultava Jeremias às escondidas, mas não seguia o seu conselho (Jr 37:17; 38:14-28).	2
209	200	O profeta Aías rasgou a própria capa em 12 pedaços e deu-lhe 10 (1Rs 11:29-31).	0
210	200	Sua mão secou quando a estendeu contra um profeta, e foi restaurada pela oração deste (1Rs 13:4-6).	1
211	200	A Bíblia não informa a idade dos reis de Israel ao assumir o trono; o ano de nascimento é uma estimativa.	2
212	201	Baasa matou toda a casa de Jeroboão, cumprindo a profecia de Aías (1Rs 15:29).	0
213	201	A Bíblia não informa a idade dos reis de Israel ao assumir o trono; o ano de nascimento é uma estimativa.	1
214	202	Não confundir com o profeta Aías, o silonita.	0
215	203	Fortificou Ramá para bloquear Judá; Asa pagou a Síria para atacá-lo (1Rs 15:17-21).	0
216	203	Como quase todos os reis de Israel, “não se apartou dos pecados de Jeroboão”, o culto aos bezerros de ouro em Betel e Dã.	1
217	203	A Bíblia não informa a idade dos reis de Israel ao assumir o trono; o ano de nascimento é uma estimativa.	2
218	204	Foi assassinado por Zinri enquanto se embriagava na casa do mordomo (1Rs 16:9-10).	0
219	204	A Bíblia não informa a idade dos reis de Israel ao assumir o trono; o ano de nascimento é uma estimativa.	1
220	205	Reinou só sete dias; cercado por Onri, incendiou o palácio com ele dentro (1Rs 16:18).	0
221	205	Jezabel chamou Jeú de “Zinri, assassino do seu senhor” (2Rs 9:31).	1
222	205	A Bíblia não informa a idade dos reis de Israel ao assumir o trono; o ano de nascimento é uma estimativa.	2
223	206	Comprou o monte de Samaria por dois talentos de prata e ali fundou a nova capital (1Rs 16:24).	0
224	206	Disputou o trono com Tibni por cerca de cinco anos (1Rs 16:21-22).	1
225	206	Mais de um século depois, documentos assírios ainda chamavam Israel de “casa de Onri”; a Pedra Moabita também o cita.	2
226	206	A Bíblia não informa a idade dos reis de Israel ao assumir o trono; o ano de nascimento é uma estimativa.	3
227	207	“Fez muito mais para irritar o Senhor do que todos os reis de Israel antes dele” (1Rs 16:33).	0
228	207	O Monólito de Kurkh, assírio, registra “Acabe, o israelita” com 2.000 carros na batalha de Qarqar (853 a.C.).	1
229	207	Morreu por uma flecha atirada “ao acaso” (1Rs 22:34), e os cães lamberam o seu sangue, como Elias dissera.	2
230	207	A Bíblia não informa a idade dos reis de Israel ao assumir o trono; o ano de nascimento é uma estimativa.	3
231	208	Filha de Etbaal, rei dos sidônios (1Rs 16:31).	0
232	208	Mandou matar os profetas do Senhor e ameaçou Elias, que fugiu para o deserto (1Rs 19:2-3).	1
233	208	Foi lançada da janela por ordem de Jeú (2Rs 9:33).	2
234	208	Em Apocalipse 2:20, seu nome é usado como símbolo de falsa profetisa.	3
235	209	Caiu pelas grades de um quarto alto e mandou consultar Baal-Zebube; Elias anunciou a sua morte (2Rs 1).	0
236	209	A Bíblia não informa a idade dos reis de Israel ao assumir o trono; o ano de nascimento é uma estimativa.	1
237	210	Também chamado Jeorão.	0
238	210	Foi morto por uma flecha de Jeú e lançado na antiga vinha de Nabote (2Rs 9:24-26).	1
239	210	Cunhado de Jorão de Judá: os dois reis de Israel e Judá tinham o mesmo nome na mesma época.	2
240	210	A Bíblia não informa a idade dos reis de Israel ao assumir o trono; o ano de nascimento é uma estimativa.	3
241	211	Liga as duas dinastias: neta de Onri (Israel) e mãe e avó de reis de Judá. Assim, descendentes de Acabe entraram na linhagem de Davi.	0
242	211	2Rs 8:26 a chama “filha de Onri” no sentido de neta.	1
243	211	A Bíblia não diz que era filha de Jezabel, embora muitos o suponham.	2
244	211	Por isso alguns estudiosos explicam a omissão de Acazias, Joás e Amazias em Mt 1:8: seriam as gerações “contaminadas” pela casa de Acabe (cf. 1Rs 21:21).	3
245	212	Jeú é chamado tanto “filho de Josafá, filho de Ninsi” quanto simplesmente “filho de Ninsi”.	0
246	213	Não confundir com Josafá, rei de Judá.	0
247	214	“O guiar é como o de Jeú… porque guia furiosamente” (2Rs 9:20).	0
248	214	O Obelisco Negro de Salmanasar III mostra Jeú (ou um enviado seu) prostrado diante do rei assírio: a única imagem contemporânea conhecida de um rei de Israel.	1
249	214	Oseias 1:4 anuncia castigo sobre a casa de Jeú pelo sangue derramado em Jezreel.	2
250	214	A Bíblia não informa a idade dos reis de Israel ao assumir o trono; o ano de nascimento é uma estimativa.	3
251	215	A Síria deixou-lhe apenas 50 cavaleiros, 10 carros e 10.000 soldados de infantaria (2Rs 13:7).	0
252	215	A Bíblia não informa a idade dos reis de Israel ao assumir o trono; o ano de nascimento é uma estimativa.	1
253	216	Visitou Eliseu no leito de morte e bateu as flechas no chão só três vezes, e por isso só venceria a Síria três vezes (2Rs 13:14-19).	0
254	216	Derrotou Amazias de Judá, derrubou parte do muro de Jerusalém e saqueou o templo (2Rs 14:13-14).	1
255	216	A Bíblia não informa a idade dos reis de Israel ao assumir o trono; o ano de nascimento é uma estimativa.	2
256	217	Restaurou as fronteiras de Israel “conforme a palavra… de Jonas, filho de Amitai” (2Rs 14:25): o mesmo Jonas de Nínive.	0
257	217	Foi a época dos profetas Amós e Oseias, que denunciaram o luxo e a injustiça social.	1
258	217	A Bíblia não informa a idade dos reis de Israel ao assumir o trono; o ano de nascimento é uma estimativa.	2
259	218	Último da dinastia de Jeú, cumprindo a promessa de quatro gerações (2Rs 10:30; 15:12).	0
260	218	A Bíblia não informa a idade dos reis de Israel ao assumir o trono; o ano de nascimento é uma estimativa.	1
261	220	Matou Zacarias e foi morto por Menaém um mês depois.	0
262	220	A Bíblia não informa a idade dos reis de Israel ao assumir o trono; o ano de nascimento é uma estimativa.	1
263	222	Pagou mil talentos de prata a Pul (Tiglate-Pileser III), cobrando 50 siclos de cada homem rico (2Rs 15:19-20).	0
264	222	A Bíblia não informa a idade dos reis de Israel ao assumir o trono; o ano de nascimento é uma estimativa.	1
265	223	A Bíblia não informa a idade dos reis de Israel ao assumir o trono; o ano de nascimento é uma estimativa.	0
266	224	Isaías se refere a Peca com desdém como “o filho de Remalias” (Is 7:4-9).	0
267	225	Aliou-se a Rezim, da Síria, contra Acaz de Judá. É nesse contexto que Isaías dá o sinal do Emanuel (Is 7:14).	0
268	225	Segundo Thiele, governou em Gileade desde 752 a.C., em paralelo a Menaém e Pecaías.	1
269	225	A Bíblia não informa a idade dos reis de Israel ao assumir o trono; o ano de nascimento é uma estimativa.	2
270	226	Não confundir com Elá, filho de Baasa, rei de Israel.	0
271	227	Deixou de pagar tributo à Assíria e buscou apoio do Egito; foi preso, e Samaria caiu após três anos de cerco, em 722 a.C.	0
272	227	Não confundir com o profeta Oseias, seu contemporâneo.	1
273	227	A Bíblia não informa a idade dos reis de Israel ao assumir o trono; o ano de nascimento é uma estimativa.	2
274	230	Era tia do marido Anrão (Êx 6:20).	0
275	230	Foi contratada pela filha do faraó para amamentar o próprio filho (Êx 2:9).	1
276	231	É a primeira mulher chamada de profetisa na Bíblia (Êx 15:20).	0
277	232	Sua vara floresceu e deu amêndoas em uma noite (Nm 17:8).	0
278	232	Tinha 83 anos quando falou com o faraó (Êx 7:7).	1
279	233	Sua vida se divide em três períodos de 40 anos: Egito, Midiã e deserto (At 7:23,30,36).	0
280	233	Deuteronômio 34:7 diz que aos 120 anos “os seus olhos nunca se escureceram”.	1
281	233	Apareceu com Elias na transfiguração de Jesus (Mt 17:3).	2
282	233	Pela cronologia adotada, o Êxodo ocorreu em 1513 a.C.	3
283	234	Aconselhou Moisés a delegar o julgamento do povo a chefes de mil, cem, cinquenta e dez (Êx 18).	0
284	238	Seu casamento une a linhagem sacerdotal (Levi) à real (Judá).	0
285	244	Paulo o chama “Tiago, irmão do Senhor” e o conta entre as “colunas” da igreja, com Pedro e João (Gl 1:19; 2:9).	0
286	244	Flávio Josefo (Antiguidades 20.9.1) registra a sua morte: “o irmão de Jesus, chamado Cristo, cujo nome era Tiago”. É uma das menções a Jesus fora da Bíblia.	1
287	244	A tradição o chama “Tiago, o Justo”; Hegesipo conta que seus joelhos eram calejados como os de um camelo, de tanto orar.	2
288	244	Não confundir com os apóstolos Tiago, filho de Zebedeu, e Tiago, filho de Alfeu.	3
289	244	Há três leituras tradicionais sobre os “irmãos” de Jesus: (1) filhos de José e Maria nascidos depois de Jesus (Helvídio, séc. IV; a maioria dos protestantes); (2) filhos de José de um casamento anterior (Epifânio; tradição ortodoxa); (3) primos ou parentes próximos, pois o hebraico e o aramaico usam “irmão” em sentido amplo (Jerônimo; tradição católica). Aqui foi seguida a primeira; o pai e a mãe podem ser alterados pela interface.	4
290	244	Ano de nascimento estimado: depois de Jesus, na ordem em que são listados em Mt 13:55.	5
291	245	Marcos 6:3 o chama Joset (em grego Iōsēs), forma abreviada de José.	0
292	245	Tinha o mesmo nome do pai, José.	1
293	245	Há três leituras tradicionais sobre os “irmãos” de Jesus: (1) filhos de José e Maria nascidos depois de Jesus (Helvídio, séc. IV; a maioria dos protestantes); (2) filhos de José de um casamento anterior (Epifânio; tradição ortodoxa); (3) primos ou parentes próximos, pois o hebraico e o aramaico usam “irmão” em sentido amplo (Jerônimo; tradição católica). Aqui foi seguida a primeira; o pai e a mãe podem ser alterados pela interface.	2
294	245	Ano de nascimento estimado: depois de Jesus, na ordem em que são listados em Mt 13:55.	3
295	246	Não confundir com Simão Pedro, nem com Simão, o zelote.	0
296	246	Não confundir com Simeão, filho de Clopas, primo de Jesus que, segundo Hegesipo, sucedeu Tiago em Jerusalém.	1
297	246	Há três leituras tradicionais sobre os “irmãos” de Jesus: (1) filhos de José e Maria nascidos depois de Jesus (Helvídio, séc. IV; a maioria dos protestantes); (2) filhos de José de um casamento anterior (Epifânio; tradição ortodoxa); (3) primos ou parentes próximos, pois o hebraico e o aramaico usam “irmão” em sentido amplo (Jerônimo; tradição católica). Aqui foi seguida a primeira; o pai e a mãe podem ser alterados pela interface.	2
298	246	Ano de nascimento estimado: depois de Jesus, na ordem em que são listados em Mt 13:55.	3
299	247	A epístola de Judas se apresenta como de “Judas, irmão de Tiago” (Jd 1), e a tradição o identifica com este irmão de Jesus.	0
300	247	Hegesipo, citado por Eusébio, conta que seus netos foram levados ao imperador Domiciano por serem da família de Davi, e soltos por serem simples lavradores.	1
301	247	1Co 9:5 indica que os irmãos do Senhor viajavam acompanhados das esposas.	2
302	247	Não confundir com Judas Iscariotes, nem com o apóstolo Judas, filho de Tiago.	3
303	247	Há três leituras tradicionais sobre os “irmãos” de Jesus: (1) filhos de José e Maria nascidos depois de Jesus (Helvídio, séc. IV; a maioria dos protestantes); (2) filhos de José de um casamento anterior (Epifânio; tradição ortodoxa); (3) primos ou parentes próximos, pois o hebraico e o aramaico usam “irmão” em sentido amplo (Jerônimo; tradição católica). Aqui foi seguida a primeira; o pai e a mãe podem ser alterados pela interface.	4
304	247	Ano de nascimento estimado: depois de Jesus, na ordem em que são listados em Mt 13:55.	5
305	248	O texto fala em “irmãs”, no plural, e “todas”, o que sugere pelo menos duas ou três.	0
306	248	Epifânio (séc. IV) dá a elas os nomes de Maria e Salomé; a Bíblia não as nomeia.	1
307	248	Este card representa o grupo, não uma única pessoa.	2
308	248	Há três leituras tradicionais sobre os “irmãos” de Jesus: (1) filhos de José e Maria nascidos depois de Jesus (Helvídio, séc. IV; a maioria dos protestantes); (2) filhos de José de um casamento anterior (Epifânio; tradição ortodoxa); (3) primos ou parentes próximos, pois o hebraico e o aramaico usam “irmão” em sentido amplo (Jerônimo; tradição católica). Aqui foi seguida a primeira; o pai e a mãe podem ser alterados pela interface.	3
309	249	A Bíblia menciona estas filhas sem dar seus nomes. O card representa o grupo; o ano é uma estimativa (logo depois do irmão citado).	0
310	250	A Bíblia menciona estas filhas sem dar seus nomes. O card representa o grupo; o ano é uma estimativa (logo depois do irmão citado).	0
311	251	A Bíblia menciona estas filhas sem dar seus nomes. O card representa o grupo; o ano é uma estimativa (logo depois do irmão citado).	0
312	252	A Bíblia menciona estas filhas sem dar seus nomes. O card representa o grupo; o ano é uma estimativa (logo depois do irmão citado).	0
313	253	A Bíblia menciona estas filhas sem dar seus nomes. O card representa o grupo; o ano é uma estimativa (logo depois do irmão citado).	0
314	254	A Bíblia menciona estas filhas sem dar seus nomes. O card representa o grupo; o ano é uma estimativa (logo depois do irmão citado).	0
315	255	A Bíblia menciona estas filhas sem dar seus nomes. O card representa o grupo; o ano é uma estimativa (logo depois do irmão citado).	0
316	256	A Bíblia menciona estas filhas sem dar seus nomes. O card representa o grupo; o ano é uma estimativa (logo depois do irmão citado).	0
317	257	A Bíblia menciona estas filhas sem dar seus nomes. O card representa o grupo; o ano é uma estimativa (logo depois do irmão citado).	0
318	258	A Bíblia menciona estas filhas sem dar seus nomes. O card representa o grupo; o ano é uma estimativa (logo depois do irmão citado).	0
319	259	A Bíblia menciona estas filhas sem dar seus nomes. O card representa o grupo; o ano é uma estimativa (logo depois do irmão citado).	0
320	260	A Bíblia menciona estas filhas sem dar seus nomes. O card representa o grupo; o ano é uma estimativa (logo depois do irmão citado).	0
321	261	A Bíblia menciona estas filhas sem dar seus nomes. O card representa o grupo; o ano é uma estimativa (logo depois do irmão citado).	0
322	262	A Bíblia menciona estas filhas sem dar seus nomes. O card representa o grupo; o ano é uma estimativa (logo depois do irmão citado).	0
323	263	A Bíblia menciona estas filhas sem dar seus nomes. O card representa o grupo; o ano é uma estimativa (logo depois do irmão citado).	0
324	264	A Bíblia menciona estas filhas sem dar seus nomes. O card representa o grupo; o ano é uma estimativa (logo depois do irmão citado).	0
325	265	A Bíblia menciona estas filhas sem dar seus nomes. O card representa o grupo; o ano é uma estimativa (logo depois do irmão citado).	0
326	266	Diná é a única filha de Jacó nomeada. O plural “filhas” (Gn 37:35; 46:7) pode indicar outras filhas, ou incluir as noras e netas.	0
327	266	A Bíblia menciona estas filhas sem dar seus nomes. O card representa o grupo; o ano é uma estimativa (logo depois do irmão citado).	1
328	267	Escapou de Sodoma com o pai e a irmã. Na caverna, as duas conceberam do próprio pai (Gn 19:30-38).	0
329	267	Gn 19:14 fala de “genros” de Ló que ficaram em Sodoma, o que sugere que ele tinha outras filhas casadas.	1
330	267	A Bíblia menciona estas filhas sem dar seus nomes. O card representa o grupo; o ano é uma estimativa (logo depois do irmão citado).	2
331	268	Mãe de Ben-Ami, pai dos amonitas (Gn 19:38).	0
332	268	A Bíblia menciona estas filhas sem dar seus nomes. O card representa o grupo; o ano é uma estimativa (logo depois do irmão citado).	1
333	269	Os três irmãos de Samuel também não são nomeados.	0
334	269	A Bíblia menciona estas filhas sem dar seus nomes. O card representa o grupo; o ano é uma estimativa (logo depois do irmão citado).	1
335	270	Tamar é a única filha de Davi nomeada (1Cr 3:9).	0
336	270	A Bíblia menciona estas filhas sem dar seus nomes. O card representa o grupo; o ano é uma estimativa (logo depois do irmão citado).	1
337	271	Roboão teve 18 mulheres e 60 concubinas, e “gerou vinte e oito filhos e sessenta filhas” (2Cr 11:21).	0
338	271	A Bíblia menciona estas filhas sem dar seus nomes. O card representa o grupo; o ano é uma estimativa (logo depois do irmão citado).	1
339	272	Abias teve 14 mulheres e “gerou vinte e dois filhos e dezesseis filhas” (2Cr 13:21).	0
340	272	A Bíblia menciona estas filhas sem dar seus nomes. O card representa o grupo; o ano é uma estimativa (logo depois do irmão citado).	1
341	273	Os filhos de Zedequias foram mortos diante dele (2Rs 25:7); as filhas ficaram em Judá sob Gedalias e foram levadas ao Egito com Jeremias (Jr 41:10; 43:6).	0
342	273	A Bíblia menciona estas filhas sem dar seus nomes. O card representa o grupo; o ano é uma estimativa (logo depois do irmão citado).	1
343	274	Mateus o chama Jonas (“Barjonas” = filho de Jonas); João, de João. Podem ser formas do mesmo nome.	0
344	275	Era casado: Jesus curou a sua sogra (Mt 8:14-15), e a esposa o acompanhava nas viagens missionárias (1Co 9:5).	0
345	275	Negou Jesus três vezes e foi restaurado com três perguntas: “Tu me amas?” (Jo 21:15-17).	1
346	275	Segundo a tradição, foi crucificado de cabeça para baixo em Roma, sob Nero, por volta de 64–67 d.C.	2
347	275	O ano de nascimento é uma estimativa: a Bíblia não informa a idade dos apóstolos.	3
348	276	Curada por Jesus em Cafarnaum, “levantou-se e passou a servi-los” (Mc 1:31).	0
349	276	A Bíblia não dá o seu nome.	1
350	277	Paulo indica que ela acompanhava Pedro (Cefas) nas viagens (1Co 9:5).	0
351	277	Clemente de Alexandria conta que ela foi martirizada antes de Pedro, e que ele a encorajou: “Lembra-te do Senhor”.	1
352	278	Era discípulo de João Batista antes de seguir Jesus, e foi ele quem levou o irmão Simão a Jesus (Jo 1:40-41).	0
353	278	A tradição diz que foi crucificado em Patras, na Grécia, numa cruz em forma de X, a “cruz de Santo André”.	1
354	278	É o padroeiro da Escócia, da Grécia e da Rússia.	2
355	278	O ano e a forma da morte vêm da tradição da Igreja antiga, não da Bíblia.	3
356	278	O ano de nascimento é uma estimativa: a Bíblia não informa a idade dos apóstolos.	4
357	279	Tinha empregados (Mc 1:20): ficou no barco com eles quando os filhos deixaram tudo para seguir Jesus.	0
358	280	Pediu a Jesus que os filhos se sentassem à sua direita e à sua esquerda no Reino (Mt 20:21).	0
359	280	A identificação da “mãe dos filhos de Zebedeu” (Mt 27:56) com Salomé (Mc 15:40) vem da comparação entre os evangelhos.	1
360	280	Alguns leem João 19:25 como dizendo que ela era irmã de Maria, mãe de Jesus. Nesse caso, Tiago e João seriam primos de Jesus.	2
361	281	Jesus chamou Tiago e João de Boanerges, “filhos do trovão” (Mc 3:17).	0
362	281	Foi o primeiro dos Doze a ser martirizado, morto à espada por Herodes Agripa I em 44 d.C. (At 12:2).	1
363	281	A tradição liga o seu sepulcro a Santiago de Compostela, na Espanha.	2
364	281	O ano de nascimento é uma estimativa: a Bíblia não informa a idade dos apóstolos.	3
365	282	Recebeu Maria, mãe de Jesus, aos seus cuidados (Jo 19:27).	0
366	282	Segundo a tradição, foi o único dos Doze a não morrer como mártir, falecendo idoso em Éfeso, por volta de 100 d.C.	1
367	282	Provavelmente era o mais jovem dos Doze.	2
368	282	O ano e a forma da morte vêm da tradição da Igreja antiga, não da Bíblia.	3
369	282	O ano de nascimento é uma estimativa: a Bíblia não informa a idade dos apóstolos.	4
370	283	Era de Betsaida, a cidade de André e Pedro (Jo 1:44).	0
371	283	Não confundir com Filipe, o evangelista, um dos sete diáconos (At 6:5; 8:26-40; 21:8).	1
372	283	O ano de nascimento é uma estimativa: a Bíblia não informa a idade dos apóstolos.	2
373	284	Seu nome é um patronímico: “filho de Tolmai”.	0
374	284	É identificado com Natanael porque aparece junto de Filipe nas listas dos Doze, e Natanael não aparece nos outros evangelhos.	1
375	284	Jesus disse de Natanael: “Eis um verdadeiro israelita, em quem não há dolo” (Jo 1:47).	2
376	284	O ano de nascimento é uma estimativa: a Bíblia não informa a idade dos apóstolos.	3
377	285	Era chamado Dídimo, “gêmeo” (Jo 11:16), mas o irmão ou a irmã gêmea não é mencionado.	0
378	285	Sua confissão “Senhor meu e Deus meu!” (Jo 20:28) é uma das mais fortes declarações sobre Jesus nos evangelhos.	1
379	285	A tradição diz que levou o evangelho à Índia; os “cristãos de São Tomé”, em Kerala, o consideram seu fundador.	2
380	285	O ano e a forma da morte vêm da tradição da Igreja antiga, não da Bíblia.	3
381	285	O ano de nascimento é uma estimativa: a Bíblia não informa a idade dos apóstolos.	4
382	286	Tem o mesmo nome do pai de Tiago (Mc 3:18); a Bíblia não diz se é a mesma pessoa.	0
383	287	Era publicano, cobrador de impostos em Cafarnaum, função desprezada pelos judeus.	0
384	287	Marcos e Lucas o chamam de Levi; Mateus, pelo próprio nome Mateus.	1
385	287	A tradição lhe atribui o Evangelho de Mateus, de onde vem a genealogia de Jesus desta árvore.	2
386	287	O ano de nascimento é uma estimativa: a Bíblia não informa a idade dos apóstolos.	3
387	288	Alguns o identificam com Clopas, marido de uma das Marias que estavam junto à cruz (Jo 19:25).	0
388	288	Pode ser o mesmo Alfeu pai de Mateus (Mc 2:14); a Bíblia não diz.	1
389	289	É frequentemente identificado com “Tiago, o menor” (Mc 15:40), cuja mãe, Maria, esteve na crucificação.	0
390	289	Não confundir com Tiago, filho de Zebedeu, nem com Tiago, irmão de Jesus.	1
391	289	O ano de nascimento é uma estimativa: a Bíblia não informa a idade dos apóstolos.	2
392	290	Lucas diz “Judas de Tiago”. A maioria das traduções lê “filho de Tiago”; algumas antigas, “irmão de Tiago”.	0
393	291	É chamado Tadeu em Mateus e Marcos, e “Judas, filho de Tiago” em Lucas e Atos.	0
394	291	João faz questão de distingui-lo: “Judas, não o Iscariotes” (Jo 14:22).	1
395	291	A tradição às vezes o confunde com Judas, irmão de Jesus, autor da epístola de Judas.	2
396	291	O ano de nascimento é uma estimativa: a Bíblia não informa a idade dos apóstolos.	3
397	292	“Cananeu” (Mt 10:4) vem do aramaico qan’ana, “zeloso”, e não se refere a Canaã.	0
398	292	“Zelote” pode indicar ligação com o movimento nacionalista contra Roma. No mesmo grupo estava Mateus, que cobrava impostos para Roma.	1
399	292	O ano de nascimento é uma estimativa: a Bíblia não informa a idade dos apóstolos.	2
400	294	Era o tesoureiro do grupo e “tirava o que nele se lançava” (Jo 12:6).	0
401	294	As 30 moedas de prata e o campo do oleiro ligam-se a Zacarias 11:12-13 (Mt 27:9-10).	1
402	294	“Iscariotes” talvez signifique “homem de Queriote”, uma cidade da Judeia; seria o único dos Doze que não era galileu.	2
403	294	O ano de nascimento é uma estimativa: a Bíblia não informa a idade dos apóstolos.	3
404	295	Foi escolhido por sorteio entre ele e José Barsabás, depois de oração (At 1:23-26).	0
405	295	Tinha acompanhado Jesus desde o batismo de João até a ascensão (At 1:21-22).	1
406	295	O ano de nascimento é uma estimativa: a Bíblia não informa a idade dos apóstolos.	2
407	296	Paulo diz ser “filho de fariseus” (At 23:6), da tribo de Benjamim (Fp 3:5).	0
408	296	Como Paulo nasceu cidadão romano (At 22:28), o pai já tinha a cidadania, algo raro entre judeus da época.	1
409	296	A Bíblia não dá o seu nome.	2
410	297	Tinha o nome hebraico do rei Saul, também da tribo de Benjamim (Fp 3:5).	0
411	297	Era cidadão romano de nascimento (At 22:28) e fabricava tendas (At 18:3).	1
412	297	Escreveu 13 das 27 obras do Novo Testamento.	2
413	297	Em Romanos 16 cita vários “parentes”: Andrônico, Júnias, Herodião, Lúcio, Jasom e Sosípatro.	3
414	297	O ano e a forma da morte vêm da tradição da Igreja antiga, não da Bíblia.	4
415	297	O ano de nascimento é uma estimativa: a Bíblia não informa a idade dos apóstolos.	5
416	298	É a única parente próxima de Paulo citada na Bíblia, e não tem nome.	0
417	299	Descobriu que mais de 40 homens haviam jurado não comer nem beber até matar Paulo, e avisou o tio e o comandante romano (At 23:12-22).	0
418	300	Seu nome era José; os apóstolos o apelidaram de Barnabé (At 4:36).	0
419	300	Era primo de João Marcos (Cl 4:10); separou-se de Paulo justamente por causa de Marcos (At 15:37-39).	1
420	300	Foi ele quem apresentou o recém-convertido Saulo aos apóstolos, que tinham medo dele (At 9:26-27).	2
421	300	O ano de nascimento é uma estimativa: a Bíblia não informa a idade dos apóstolos.	3
422	301	A igreja orava em sua casa quando Pedro foi libertado da prisão por um anjo; a serva Rode atendeu à porta e, de alegria, esqueceu de abri-la (At 12:13-16).	0
423	302	Segundo Papias (séc. II), escreveu o seu evangelho a partir da pregação de Pedro, que o chama “meu filho” (1Pe 5:13).	0
424	302	Talvez seja o jovem que fugiu nu na prisão de Jesus, no Getsêmani (Mc 14:51-52).	1
425	302	Abandonou Paulo na primeira viagem; anos depois, Paulo pediu: “toma contigo Marcos, porque me é muito útil” (2Tm 4:11).	2
426	302	Era primo de Barnabé (Cl 4:10).	3
427	303	É a única mulher entre os juízes de Israel.	0
428	303	O Cântico de Débora (Jz 5) é considerado um dos textos mais antigos da Bíblia.	1
429	303	A cronologia do período dos juízes é incerta; o ano é uma estimativa.	2
430	305	O Cântico de Ana (1Sm 2:1-10) tem muitos paralelos com o Magnificat de Maria (Lc 1:46-55).	0
431	305	Orava tão intensamente, só movendo os lábios, que o sacerdote Eli pensou que estivesse embriagada (1Sm 1:13).	1
432	306	Respondeu ao chamado noturno: “Fala, porque o teu servo ouve” (1Sm 3:10).	0
433	306	Ungiu os dois primeiros reis de Israel: Saul e Davi.	1
434	306	Os livros de 1 e 2 Samuel levam o seu nome, embora ele morra em 1Sm 25.	2
435	307	Não confundir com Gade, filho de Jacó.	0
436	307	Registrou a história de Davi, junto com Samuel e Natã (1Cr 29:29).	1
437	307	O ano de nascimento é uma estimativa a partir da época em que profetizou.	2
438	308	Não confundir com Natã, filho de Davi.	0
439	308	Deu a Salomão o nome Jedidias, “amado do Senhor” (2Sm 12:25).	1
440	308	O ano de nascimento é uma estimativa a partir da época em que profetizou.	2
441	309	Rasgou a própria capa nova em 12 pedaços e deu 10 a Jeroboão (1Rs 11:30-31).	0
442	309	Já cego pela idade, reconheceu a mulher de Jeroboão, que veio disfarçada (1Rs 14:4-6).	1
443	309	O ano de nascimento é uma estimativa a partir da época em que profetizou.	2
444	310	Não morreu: foi levado ao céu num redemoinho (2Rs 2:11). O ano de “morte” é o do arrebatamento.	0
445	310	Malaquias 4:5 promete a sua volta; Jesus identificou João Batista como o “Elias que havia de vir” (Mt 11:14).	1
446	310	Apareceu com Moisés na transfiguração de Jesus.	2
447	310	O ano de nascimento é uma estimativa a partir da época em que profetizou.	3
448	311	Filho de Inlá. Foi o único a contradizer os 400 profetas de Acabe, e por isso foi preso (1Rs 22:27).	0
449	311	O ano de nascimento é uma estimativa a partir da época em que profetizou.	1
450	313	Pediu porção dobrada do espírito de Elias; a Bíblia registra quase o dobro de milagres para ele.	0
451	313	Depois de morto, um cadáver lançado em seu sepulcro reviveu ao tocar os seus ossos (2Rs 13:21).	1
452	313	O ano de nascimento é uma estimativa a partir da época em que profetizou.	2
453	315	Profetizou também a restauração das fronteiras de Israel sob Jeroboão II (2Rs 14:25).	0
454	315	Jesus usou os três dias e três noites no ventre do peixe como sinal da sua ressurreição (Mt 12:40).	1
455	315	É o único profeta enviado a pregar arrependimento a uma nação estrangeira.	2
456	315	O ano de nascimento é uma estimativa a partir da época em que profetizou.	3
457	316	Filho de Petuel.	0
458	316	Pedro citou Joel 2:28-32 no dia de Pentecostes (At 2:16-21).	1
459	316	A data é incerta: estudiosos a situam entre os séculos IX e IV a.C. Aqui foi adotada a data antiga, no reinado de Joás.	2
460	316	O ano de nascimento é uma estimativa a partir da época em que profetizou.	3
461	317	Era de Judá, “boieiro e colhedor de sicômoros”, mas foi enviado a profetizar em Israel (Am 7:14-15).	0
462	317	Datou sua profecia “dois anos antes do terremoto” (Am 1:1), lembrado séculos depois em Zc 14:5.	1
463	317	“Corra o juízo como as águas, e a justiça como o ribeiro perene” (Am 5:24) foi citado por Martin Luther King Jr.	2
464	317	O ano de nascimento é uma estimativa a partir da época em que profetizou.	3
465	319	Não confundir com Oseias, último rei de Israel, seu contemporâneo.	0
466	319	Os 11:1 é citado em Mt 2:15 a respeito da volta de Jesus do Egito.	1
467	319	O ano de nascimento é uma estimativa a partir da época em que profetizou.	2
468	320	Filha de Diblaim.	0
469	320	Oseias a resgatou por quinze siclos de prata e uma medida e meia de cevada (Os 3:2).	1
470	321	Em Os 2:23 os nomes são revertidos: “compadecer-me-ei da Desfavorecida… e direi a Não-Meu-Povo: Tu és o meu povo”; Paulo cita isso em Rm 9:25.	0
471	322	Em Os 2:23 os nomes são revertidos: “compadecer-me-ei da Desfavorecida… e direi a Não-Meu-Povo: Tu és o meu povo”; Paulo cita isso em Rm 9:25.	0
472	323	Em Os 2:23 os nomes são revertidos: “compadecer-me-ei da Desfavorecida… e direi a Não-Meu-Povo: Tu és o meu povo”; Paulo cita isso em Rm 9:25.	0
473	324	Não confundir com o profeta Amós; em hebraico os nomes são diferentes.	0
474	325	É o profeta mais citado no Novo Testamento.	0
475	325	O Grande Rolo de Isaías, dos Manuscritos do Mar Morto, tem cerca de 2.100 anos e traz o livro completo.	1
476	325	A tradição judaica diz que foi serrado ao meio sob Manassés; Hb 11:37 pode aludir a isso.	2
477	325	O ano de nascimento é uma estimativa a partir da época em que profetizou.	3
478	326	Os escribas citaram Mq 5:2 a Herodes para indicar onde o Messias nasceria (Mt 2:5-6).	0
479	326	Um século depois, a lembrança de sua profecia salvou a vida de Jeremias (Jr 26:17-19).	1
480	326	O ano de nascimento é uma estimativa a partir da época em que profetizou.	2
481	327	Nínive caiu em 612 a.C., cerca de um século e meio depois do arrependimento no tempo de Jonas.	0
482	327	Não confundir com Naum, ascendente de Jesus em Lucas 3:25.	1
483	327	O ano de nascimento é uma estimativa a partir da época em que profetizou.	2
484	331	Sf 1:1 traça sua genealogia por quatro gerações até Ezequias, muito provavelmente o rei, o que faria dele um profeta de sangue real.	0
485	331	Sf 1:14-18 inspirou o hino medieval “Dies irae”.	1
486	331	O ano de nascimento é uma estimativa a partir da época em que profetizou.	2
487	332	Mesmo com Jeremias e Sofonias atuando na época, foi ela a consultada sobre o livro da Lei encontrado no templo.	0
488	332	Esposa de Salum, guarda das vestimentas.	1
489	332	O ano de nascimento é uma estimativa a partir da época em que profetizou.	2
490	333	Hc 2:4 é citado três vezes no Novo Testamento e foi central para a Reforma de Lutero.	0
491	333	O livro é um diálogo: o profeta pergunta, e Deus responde.	1
492	333	O ano de nascimento é uma estimativa a partir da época em que profetizou.	2
493	334	Alguns o identificam com o sumo sacerdote Hilquias, que encontrou o livro da Lei (2Rs 22:8), mas a maioria entende que são pessoas diferentes.	0
494	335	Respondeu ao chamado: “Ah! Senhor Deus! Eis que não sei falar; porque sou uma criança” (Jr 1:6).	0
495	335	Deus o proibiu de se casar, como sinal ao povo (Jr 16:2).	1
496	335	A promessa da nova aliança (Jr 31:31-34) é a passagem mais longa do AT citada no NT (Hb 8:8-12).	2
497	335	A tradição lhe atribui o livro de Lamentações.	3
498	335	O ano de nascimento é uma estimativa a partir da época em que profetizou.	4
499	336	É o livro mais curto do Antigo Testamento: 21 versículos.	0
500	336	Condena Edom, descendente de Esaú, por ter se alegrado com a queda de Jerusalém.	1
501	336	A data é incerta; aqui foi adotada a época logo após 586 a.C.	2
502	336	O ano de nascimento é uma estimativa a partir da época em que profetizou.	3
503	337	Recebeu o nome babilônio Beltessazar (Dn 1:7).	0
504	337	Ezequiel o cita, ainda em vida, ao lado de Noé e Jó como exemplo de justiça (Ez 14:14).	1
505	337	Parte do livro (Dn 2:4–7:28) está escrita em aramaico.	2
506	337	O ano de nascimento é uma estimativa a partir da época em que profetizou.	3
507	339	Foi levado à Babilônia em 597 a.C., com o rei Jeconias.	0
508	339	Deus o proibiu de prantear a morte da esposa, como sinal ao povo (Ez 24:15-18).	1
509	339	É chamado de “filho do homem” cerca de 90 vezes no livro.	2
510	339	O ano de nascimento é uma estimativa a partir da época em que profetizou.	3
511	340	Todas as suas profecias são datadas num intervalo de quatro meses, em 520 a.C.	0
512	340	Ag 2:3 sugere que ele talvez tivesse visto o primeiro templo, antes de 586 a.C.	1
513	340	O ano de nascimento é uma estimativa a partir da época em que profetizou.	2
514	343	Zc 9:9 é citado na entrada triunfal de Jesus em Jerusalém (Mt 21:5).	0
515	343	Em Mt 23:35 Jesus fala de “Zacarias, filho de Baraquias”, morto entre o santuário e o altar; a morte narrada em 2Cr 24:20-22 é de Zacarias, filho de Joiada, uma questão muito discutida.	1
516	343	Era de família sacerdotal (Ne 12:16).	2
517	343	O ano de nascimento é uma estimativa a partir da época em que profetizou.	3
518	344	Depois dele, segundo a tradição judaica, a profecia cessou por cerca de 400 anos, até João Batista.	0
519	344	Como o nome significa “meu mensageiro”, alguns pensam que é um título, não um nome.	1
520	344	Ml 3:1 e 4:5 são aplicados a João Batista nos evangelhos.	2
521	344	O ano de nascimento é uma estimativa a partir da época em que profetizou.	3
522	345	Ficou mudo por não crer no anúncio do anjo Gabriel, até o nascimento do filho (Lc 1:20, 64).	0
523	345	Seu cântico, o Benedictus (Lc 1:68-79), é uma profecia (Lc 1:67).	1
524	346	Era descendente de Arão (Lc 1:5).	0
525	346	Concebeu já idosa; o bebê saltou em seu ventre quando Maria a visitou (Lc 1:41).	1
526	346	Era parente de Maria (Lc 1:36), mas a Bíblia não diz em que grau.	2
527	347	Jesus disse que, entre os nascidos de mulher, não surgiu ninguém maior que João (Mt 11:11).	0
528	347	Comia gafanhotos e mel silvestre (Mt 3:4).	1
529	347	O historiador judeu Flávio Josefo também registra sua pregação e sua execução por Herodes Antipas.	2
530	347	Ano de nascimento: seis meses antes de Jesus (Lc 1:26, 36).	3
531	348	Filha de Fanuel, da tribo de Aser, uma das tribos do norte.	0
532	348	Viúva, “não se afastava do templo, servindo a Deus em jejuns e orações, de noite e de dia” (Lc 2:37).	1
533	348	Lc 2:37 pode significar que tinha 84 anos ou que era viúva havia 84 anos; aqui foi adotada a primeira leitura.	2
\.


--
-- Data for Name: filiacoes_alternativas; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.filiacoes_alternativas (id, filho_id, pai_id, fonte, observacao) FROM stdin;
1	144	176	Lucas 3:27	Mateus 1:12 e 1Cr 3:17 dão Jeconias como pai.
2	155	194	Lucas 3:23	Mateus 1:16 dá Jacó como pai.
\.


--
-- Data for Name: links; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.links (id, pessoa_id, titulo, url, ordem) FROM stdin;
\.


--
-- Data for Name: livros; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.livros (codigo, nome, abrev, nome_en, ordem, testamento) FROM stdin;
GEN	Gênesis	Gn	Genesis	1	AT
EXO	Êxodo	Êx	Exodus	2	AT
LEV	Levítico	Lv	Leviticus	3	AT
NUM	Números	Nm	Numbers	4	AT
DEU	Deuteronômio	Dt	Deuteronomy	5	AT
JOS	Josué	Js	Joshua	6	AT
JUI	Juízes	Jz	Judges	7	AT
RUT	Rute	Rt	Ruth	8	AT
1SA	1 Samuel	1Sm	1 Samuel	9	AT
2SA	2 Samuel	2Sm	2 Samuel	10	AT
1RE	1 Reis	1Rs	1 Kings	11	AT
2RE	2 Reis	2Rs	2 Kings	12	AT
1CR	1 Crônicas	1Cr	1 Chronicles	13	AT
2CR	2 Crônicas	2Cr	2 Chronicles	14	AT
ESD	Esdras	Ed	Ezra	15	AT
NEE	Neemias	Ne	Nehemiah	16	AT
EST	Ester	Et	Esther	17	AT
JO	Jó	Jó	Job	18	AT
SAL	Salmos	Sl	Psalms	19	AT
PRO	Provérbios	Pv	Proverbs	20	AT
ECL	Eclesiastes	Ec	Ecclesiastes	21	AT
CNT	Cânticos	Ct	Song of Songs	22	AT
ISA	Isaías	Is	Isaiah	23	AT
JER	Jeremias	Jr	Jeremiah	24	AT
LAM	Lamentações	Lm	Lamentations	25	AT
EZE	Ezequiel	Ez	Ezekiel	26	AT
DAN	Daniel	Dn	Daniel	27	AT
OSE	Oséias	Os	Hosea	28	AT
JOE	Joel	Jl	Joel	29	AT
AMO	Amós	Am	Amos	30	AT
OBA	Obadias	Ob	Obadiah	31	AT
JON	Jonas	Jn	Jonah	32	AT
MIQ	Miquéias	Mq	Micah	33	AT
NAU	Naum	Na	Nahum	34	AT
HAB	Habacuque	Hc	Habakkuk	35	AT
SOF	Sofonias	Sf	Zephaniah	36	AT
AGE	Ageu	Ag	Haggai	37	AT
ZAC	Zacarias	Zc	Zechariah	38	AT
MAL	Malaquias	Ml	Malachi	39	AT
MAT	Mateus	Mt	Matthew	40	NT
MAR	Marcos	Mc	Mark	41	NT
LUC	Lucas	Lc	Luke	42	NT
JOA	João	Jo	John	43	NT
ATO	Atos	At	Acts	44	NT
ROM	Romanos	Rm	Romans	45	NT
1CO	1 Coríntios	1Co	1 Corinthians	46	NT
2CO	2 Coríntios	2Co	2 Corinthians	47	NT
GAL	Gálatas	Gl	Galatians	48	NT
EFE	Efésios	Ef	Ephesians	49	NT
FIL	Filipenses	Fp	Philippians	50	NT
COL	Colossenses	Cl	Colossians	51	NT
1TS	1 Tessalonicenses	1Ts	1 Thessalonians	52	NT
2TS	2 Tessalonicenses	2Ts	2 Thessalonians	53	NT
1TI	1 Timóteo	1Tm	1 Timothy	54	NT
2TI	2 Timóteo	2Tm	2 Timothy	55	NT
TIT	Tito	Tt	Titus	56	NT
FLM	Filemom	Fm	Philemon	57	NT
HEB	Hebreus	Hb	Hebrews	58	NT
TIA	Tiago	Tg	James	59	NT
1PE	1 Pedro	1Pe	1 Peter	60	NT
2PE	2 Pedro	2Pe	2 Peter	61	NT
1JO	1 João	1Jo	1 John	62	NT
2JO	2 João	2Jo	2 John	63	NT
3JO	3 João	3Jo	3 John	64	NT
JUD	Judas	Jd	Jude	65	NT
APO	Apocalipse	Ap	Revelation	66	NT
\.


--
-- Data for Name: papeis; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.papeis (id, pessoa_id, papel, inicio, fim, local, observacao) FROM stdin;
1	244	Líder da igreja de Jerusalém	44	62	\N	At 12:17; 15:13; Gl 2:9
2	275	Apóstolo	28	64	\N	um dos Doze
3	278	Apóstolo	28	60	\N	um dos Doze
4	281	Apóstolo	28	44	\N	um dos Doze
5	282	Apóstolo	28	100	\N	um dos Doze
6	283	Apóstolo	28	\N	\N	um dos Doze
7	284	Apóstolo	28	\N	\N	um dos Doze
8	285	Apóstolo	28	72	\N	um dos Doze
9	287	Apóstolo	28	\N	\N	um dos Doze
10	289	Apóstolo	28	\N	\N	um dos Doze
11	291	Apóstolo	28	\N	\N	um dos Doze
12	292	Apóstolo	28	\N	\N	um dos Doze
13	294	Apóstolo	28	30	\N	um dos Doze; traidor
14	295	Apóstolo	30	\N	\N	substituto de Judas
15	297	Apóstolo	34	67	\N	apóstolo dos gentios
16	300	Apóstolo	45	\N	\N	At 14:14
17	21	Profeta	\N	\N	\N	“Profetizou Enoque, o sétimo depois de Adão” (Jd 14)
18	55	Profeta	\N	\N	\N	Chamado profeta por Deus em Gn 20:7
19	233	Profeta	-1513	-1473	\N	“Nunca mais se levantou em Israel profeta algum como Moisés” (Dt 34:10)
20	232	Profeta	-1513	-1474	\N	“Arão, teu irmão, será o teu profeta” (Êx 7:1)
21	231	Profetisa	\N	\N	\N	Êx 15:20
22	111	Profeta	\N	\N	\N	“Sendo, pois, ele profeta…” (At 2:30)
23	303	Profetisa	-1220	-1180	\N	data incerta
24	303	Juíza	-1220	-1180	\N	\N
25	306	Profeta	-1080	-1015	\N	também juiz
26	306	Juiz	-1080	-1050	\N	\N
27	307	Profeta	-1020	-975	Israel (reino unido)	\N
28	308	Profeta	-1005	-970	Israel (reino unido)	\N
29	309	Profeta	-935	-910	Israel (reino do norte)	\N
30	310	Profeta	-870	-848	Israel (reino do norte)	\N
31	311	Profeta	-853	-853	Israel (reino do norte)	\N
32	313	Profeta	-850	-795	Israel (reino do norte)	\N
33	315	Profeta	-785	-760	Israel (reino do norte)	\N
34	316	Profeta	-835	-796	Judá	data incerta
35	317	Profeta	-760	-750	Israel (reino do norte)	\N
36	319	Profeta	-755	-715	Israel (reino do norte)	\N
37	325	Profeta	-740	-681	Judá	\N
38	326	Profeta	-735	-700	Judá	\N
39	327	Profeta	-660	-630	Judá	\N
40	331	Profeta	-630	-620	Judá	\N
41	332	Profetisa	-622	-622	Judá	\N
42	333	Profeta	-609	-598	Judá	\N
43	335	Profeta	-627	-580	Judá	\N
44	336	Profeta	-586	-580	Judá	data incerta
45	337	Profeta	-605	-536	Judá	na Babilônia
46	339	Profeta	-593	-571	Judá	na Babilônia
47	340	Profeta	-520	-520	Judá	após o exílio
48	343	Profeta	-520	-480	Judá	após o exílio
49	344	Profeta	-435	-420	Judá	após o exílio
50	345	Profeta	-5	-5	\N	“cheio do Espírito Santo, profetizou” (Lc 1:67)
51	347	Profeta	27	29	\N	Lc 1:76; Mt 11:9
52	348	Profetisa	-4	-4	\N	\N
\.


--
-- Data for Name: pessoas; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.pessoas (id, nome, sexo, significado_nome, ano_nascimento, nascimento_aprox, ano_morte, morte_aprox, idade_morte, pai_id, mae_id, sem_nome, resumo, historia, criado_em, atualizado_em) FROM stdin;
38	Canaã	M	\N	-2360	t	\N	t	\N	27	\N	f	Ancestral dos cananeus.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
85	Bate-Sua	F	\N	-1771	t	\N	t	\N	\N	\N	f	Esposa cananeia de Judá, filha de Sua.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
159	Mená	M	\N	-949	t	\N	t	\N	158	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
212	Ninsi	M	\N	-940	t	\N	t	\N	\N	\N	f	Avô de Jeú.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
59	Isaque	M	“Ele ri”.	-1918	f	-1738	f	180	55	56	f	Filho da promessa; quase sacrificado no monte Moriá.	Nascido quando Abraão tinha 100 anos e Sara 90, Isaque foi o herdeiro da aliança. Ainda jovem, foi levado ao monte Moriá, onde Deus proveu um carneiro em seu lugar. Casou-se aos 40 anos com Rebeca e, vinte anos depois, foi pai dos gêmeos Esaú e Jacó.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
1	Adão	M	“Homem”; ligado a ’adamah, “terra”, “solo”.	-4026	f	-3096	f	930	\N	\N	f	O primeiro homem, formado do pó da terra.	Formado por Deus do pó da terra e animado pelo fôlego de vida (Gn 2:7), Adão foi colocado no jardim do Éden para cultivá-lo e guardá-lo. Deu nome aos animais e recebeu Eva como auxiliadora idônea.\n\nAo comer do fruto da árvore do conhecimento do bem e do mal, junto com Eva, trouxe o pecado e a morte à humanidade, e o casal foi expulso do Éden. Gerou Caim, Abel, Sete e “outros filhos e filhas” (Gn 5:4), vivendo 930 anos.\n\nNo Novo Testamento, Paulo apresenta Cristo como “o último Adão”, aquele que reverte o que entrou no mundo pelo primeiro.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
2	Eva	F	“Vivente”, “vida”: “mãe de todos os viventes” (Gn 3:20).	-4026	f	\N	f	\N	\N	\N	f	A primeira mulher, mãe de todos os viventes.	Formada por Deus a partir da costela de Adão (Gn 2:21-22), Eva foi apresentada a ele como companheira; Adão a reconheceu como “osso dos meus ossos e carne da minha carne”.\n\nEnganada pela serpente, comeu do fruto proibido e o deu a Adão. No juízo que se seguiu, Deus anunciou que a descendência da mulher feriria a cabeça da serpente (Gn 3:15), a primeira promessa de redenção. Foi mãe de Caim, Abel e Sete.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
3	Caim	M	“Adquirido”: “Adquiri um varão com o auxílio do Senhor” (Gn 4:1).	-4000	t	\N	t	\N	1	2	f	Primogênito de Adão; matou o irmão Abel.	Lavrador, Caim trouxe ao Senhor uma oferta do fruto da terra, que não foi aceita, enquanto a de Abel foi. Irado, matou o irmão no campo, o primeiro homicídio da Bíblia.\n\nCondenado a ser fugitivo e errante, recebeu de Deus um sinal de proteção e habitou na terra de Node, ao oriente do Éden, onde edificou uma cidade e lhe deu o nome do filho, Enoque.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
4	Abel	M	“Sopro”, “vapor” (hebel).	-3998	t	-3897	t	\N	1	2	f	Pastor de ovelhas, o primeiro justo assassinado.	Pastor de ovelhas, Abel ofereceu ao Senhor as primícias do seu rebanho e da gordura deste, e a oferta foi aceita. Foi morto pelo irmão Caim por inveja.\n\nHebreus o coloca como o primeiro da galeria da fé: “pela fé Abel ofereceu a Deus mais excelente sacrifício do que Caim” e, “depois de morto, ainda fala”.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
5	Enoque (filho de Caim)	M	\N	-3936	t	\N	t	\N	3	\N	f	Filho de Caim; deu nome à primeira cidade.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
6	Irade	M	\N	-3876	t	\N	t	\N	5	\N	f	Neto de Caim.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
7	Meujael	M	\N	-3816	t	\N	t	\N	6	\N	f	Descendente de Caim.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
8	Metusael	M	\N	-3756	t	\N	t	\N	7	\N	f	Pai de Lameque, da linhagem de Caim.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
9	Lameque (de Caim)	M	\N	-3686	t	\N	t	\N	8	\N	f	Primeiro polígamo registrado; autor do “cântico da espada”.	Descendente de Caim na quinta geração, Lameque tomou duas mulheres, Ada e Zilá, o primeiro caso de poligamia na Bíblia. Seu poema às esposas (Gn 4:23-24) celebra a vingança: “se Caim há de ser vingado sete vezes, Lameque, setenta vezes sete”.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
10	Ada	F	\N	-3681	t	\N	t	\N	\N	\N	f	Esposa de Lameque; mãe de Jabal e Jubal.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
11	Zilá	F	\N	-3676	t	\N	t	\N	\N	\N	f	Esposa de Lameque; mãe de Tubalcaim e Naamá.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
12	Jabal	M	\N	-3616	t	\N	t	\N	9	10	f	Pai dos que habitam em tendas e criam gado.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
13	Jubal	M	\N	-3614	t	\N	t	\N	9	10	f	Pai dos que tocam harpa e flauta.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
14	Tubalcaim	M	\N	-3611	t	\N	t	\N	9	11	f	Artífice de instrumentos de bronze e ferro.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
15	Naamá (irmã de Tubalcaim)	F	\N	-3608	t	\N	t	\N	9	11	f	Uma das poucas mulheres nomeadas antes do dilúvio.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
16	Sete	M	“Designado”, “concedido”: “Deus me deu outro descendente em lugar de Abel” (Gn 4:25).	-3896	f	-2984	f	912	1	2	f	Filho dado a Adão e Eva em lugar de Abel.	Nascido quando Adão tinha 130 anos, Sete foi visto por Eva como um substituto de Abel. Dele descende a linhagem que chega a Noé e, através de Sem e Abraão, ao Messias.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
17	Enos	M	“Homem” (no sentido de mortal, frágil).	-3791	f	-2886	f	905	16	\N	f	Em seus dias começou-se a invocar o nome do Senhor.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
18	Cainã	M	\N	-3701	f	-2791	f	910	17	\N	f	Filho de Enos.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
19	Maalalel	M	“Louvor de Deus”.	-3631	f	-2736	f	895	18	\N	f	Filho de Cainã.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
20	Jarede	M	“Descida”.	-3566	f	-2604	f	962	19	\N	f	Pai de Enoque; o segundo mais longevo da Bíblia.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
60	Betuel	M	\N	-1986	t	\N	t	\N	50	51	f	Pai de Rebeca e Labão.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
61	Labão	M	\N	-1906	t	\N	t	\N	60	\N	f	Irmão de Rebeca; sogro de Jacó.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
148	Azor	M	\N	-426	t	\N	t	\N	147	\N	f	Ascendente de José na genealogia de Mateus.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
21	Enoque	M	“Consagrado”, “dedicado”.	-3404	f	-3039	f	365	20	\N	f	Andou com Deus e foi tomado sem ver a morte.	O sétimo a partir de Adão, Enoque “andou com Deus” por trezentos anos depois de gerar Metusalém. Não morreu: “não apareceu mais, porquanto Deus para si o tomou” (Gn 5:24).\n\nHebreus o cita como exemplo de fé que agradou a Deus, e Judas registra uma profecia sua sobre o juízo vindouro.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
22	Metusalém	M	Tradicionalmente “homem do dardo”; uma leitura popular sugere “quando ele morrer, virá”.	-3339	f	-2370	f	969	21	\N	f	O homem mais longevo da Bíblia: 969 anos.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
23	Lameque	M	\N	-3152	f	-2375	f	777	22	\N	f	Pai de Noé.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
24	Noé	M	“Descanso”, “consolo”.	-2970	f	-2020	f	950	23	\N	f	Justo em sua geração; construiu a arca e sobreviveu ao dilúvio.	Em meio a uma humanidade corrompida, “Noé achou graça aos olhos do Senhor” (Gn 6:8). Por ordem de Deus construiu a arca, na qual entrou com a esposa, os três filhos, as noras e os animais.\n\nO dilúvio veio quando Noé tinha 600 anos. Ao sair da arca, ofereceu sacrifício, e Deus estabeleceu com ele e com toda a terra a aliança do arco-íris. Depois plantou uma vinha e se embriagou, episódio que levou à maldição de Canaã. Viveu 350 anos após o dilúvio.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
25	Jafé	M	“Ampliação”: “Alargue Deus a Jafé” (Gn 9:27).	-2470	t	\N	t	\N	24	\N	f	Filho de Noé; pai dos povos do norte e das ilhas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
26	Sem	M	“Nome”, “renome”.	-2468	f	-1868	f	600	24	\N	f	Filho de Noé; ancestral de Abraão e de Israel.	Sem e Jafé cobriram a nudez do pai com respeito, e Noé o abençoou: “Bendito seja o Senhor, Deus de Sem” (Gn 9:26). Dele vêm os povos semitas, entre eles os hebreus.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
27	Cam	M	“Quente”.	-2466	t	\N	t	\N	24	\N	f	Filho mais novo de Noé; pai de Cuxe, Mizraim, Pute e Canaã.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
28	Gômer	M	\N	-2368	t	\N	t	\N	25	\N	f	Associado aos cimérios.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
29	Magogue	M	\N	-2366	t	\N	t	\N	25	\N	f	Citado em Ez 38-39 e Ap 20:8.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
30	Madai	M	\N	-2364	t	\N	t	\N	25	\N	f	Ancestral dos medos.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
31	Javã	M	\N	-2362	t	\N	t	\N	25	\N	f	Ancestral dos gregos (jônios).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
32	Tubal	M	\N	-2360	t	\N	t	\N	25	\N	f	Povo da Ásia Menor.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
33	Meseque	M	\N	-2358	t	\N	t	\N	25	\N	f	Povo da Ásia Menor.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
34	Tiras	M	\N	-2356	t	\N	t	\N	25	\N	f	Filho de Jafé.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
35	Cuxe	M	\N	-2366	t	\N	t	\N	27	\N	f	Ancestral dos etíopes; pai de Ninrode.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
36	Mizraim	M	\N	-2364	t	\N	t	\N	27	\N	f	Ancestral dos egípcios.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
37	Pute	M	\N	-2362	t	\N	t	\N	27	\N	f	Associado à Líbia.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
39	Ninrode	M	\N	-2326	t	\N	t	\N	35	\N	f	“Poderoso caçador diante do Senhor”; fundador de Babel e Nínive.	Ninrode foi “o primeiro a ser poderoso na terra”. O princípio do seu reino foi Babel, Ereque, Acade e Calné, na terra de Sinar; dali saiu para a Assíria, onde edificou Nínive (Gn 10:8-12).	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
40	Arfaxade	M	\N	-2368	f	-1930	f	438	26	\N	f	Nascido dois anos após o dilúvio.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
41	Selá	M	\N	-2333	f	-1900	f	433	40	\N	f	Filho de Arfaxade.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
42	Héber	M	\N	-2303	f	-1839	f	464	41	\N	f	Ancestral epônimo dos hebreus.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
43	Pelegue	M	“Divisão”.	-2269	f	-2030	f	239	42	\N	f	“Nos seus dias se repartiu a terra.”	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
44	Joctã	M	\N	-2266	t	\N	t	\N	42	\N	f	Irmão de Pelegue; pai de 13 povos da Arábia.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
45	Reú	M	\N	-2239	f	-2000	f	239	43	\N	f	Filho de Pelegue.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
46	Serugue	M	\N	-2207	f	-1977	f	230	45	\N	f	Filho de Reú.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
47	Naor (avô de Abraão)	M	\N	-2177	f	-2029	f	148	46	\N	f	Pai de Terá.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
48	Terá	M	\N	-2148	f	-1943	f	205	47	\N	f	Pai de Abraão, Naor e Harã; saiu de Ur rumo a Canaã.	Terá vivia em Ur dos caldeus. Com o filho Abrão, a nora Sarai e o neto Ló, partiu em direção a Canaã, mas se estabeleceu em Harã, onde morreu aos 205 anos.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
49	Harã	M	\N	-2078	t	\N	t	\N	48	\N	f	Irmão de Abraão; pai de Ló e Milca. Morreu em Ur.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
50	Naor (irmão de Abraão)	M	\N	-2076	t	\N	t	\N	48	\N	f	Avô de Rebeca e bisavô de Lia e Raquel.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
51	Milca	F	\N	-2041	t	\N	t	\N	49	\N	f	Esposa de Naor; avó de Rebeca.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
52	Ló	M	\N	-2036	t	\N	t	\N	49	\N	f	Sobrinho de Abraão; escapou da destruição de Sodoma.	Ló acompanhou Abraão de Harã a Canaã. Quando os rebanhos cresceram demais, escolheu a planície do Jordão e foi morar em Sodoma. Abraão o resgatou de uma coalizão de reis e intercedeu pela cidade.\n\nNa destruição de Sodoma e Gomorra, anjos o tiraram da cidade; sua mulher olhou para trás e virou uma estátua de sal. De suas filhas nasceram Moabe e Ben-Ami, pais dos moabitas e amonitas.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
53	Moabe	M	\N	-1916	t	\N	t	\N	52	267	f	Pai dos moabitas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
54	Ben-Ami	M	\N	-1915	t	\N	t	\N	52	268	f	Pai dos amonitas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
55	Abraão	M	Abrão = “pai exaltado”; Abraão = “pai de uma multidão” (Gn 17:5).	-2018	f	-1843	f	175	48	\N	f	Pai da fé; chamado por Deus para sair de Ur rumo a Canaã.	Chamado por Deus aos 75 anos para deixar sua terra e sua parentela, Abrão recebeu a promessa de se tornar uma grande nação e de que nele seriam benditas todas as famílias da terra (Gn 12:1-3).\n\nDeus fez aliança com ele, mudou seu nome para Abraão e instituiu a circuncisão. Teve Ismael com Agar e, aos 100 anos, Isaque com Sara, o filho da promessa. Sua fé foi provada no monte Moriá, quando se dispôs a oferecer Isaque. Morreu aos 175 anos e foi sepultado na caverna de Macpela.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
56	Sara	F	Sarai/Sara = “princesa”.	-2008	f	-1881	f	127	48	\N	f	Esposa e meia-irmã de Abraão; mãe de Isaque aos 90 anos.	Estéril por muitos anos, Sarai deu sua serva Agar a Abrão para ter filhos por meio dela. Deus, porém, prometeu que a própria Sara seria mãe de nações. Ela riu ao ouvir a promessa, mas aos 90 anos deu à luz Isaque, cujo nome significa “riso”. Morreu aos 127 anos em Hebrom.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
57	Agar	F	\N	-1966	t	\N	t	\N	\N	\N	f	Serva egípcia de Sara; mãe de Ismael.	Serva egípcia de Sara, Agar foi dada a Abrão como concubina e concebeu Ismael. Fugindo de Sara, foi encontrada pelo Anjo do Senhor no deserto, e chamou a Deus de “El-Roi”, o Deus que me vê. Mais tarde foi despedida com o filho, e Deus os sustentou no deserto.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
58	Ismael	M	“Deus ouve”.	-1932	f	-1795	f	137	55	57	f	Primogênito de Abraão; pai de doze príncipes.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
145	Zorobabel	M	“Semente da Babilônia”	-570	t	\N	t	\N	144	\N	f	Governador de Judá que liderou o retorno e reconstruiu o templo.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
146	Abiúde	M	\N	-540	t	\N	t	\N	145	\N	f	Ascendente de José na genealogia de Mateus.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
62	Rebeca	F	\N	-1898	t	\N	t	\N	60	\N	f	Esposa de Isaque; mãe de Esaú e Jacó.	O servo de Abraão a encontrou junto ao poço, quando ela se ofereceu para dar água também aos seus camelos, sinal que ele havia pedido a Deus. Aceitou ir para Canaã e casar-se com Isaque. Grávida de gêmeos, recebeu o oráculo de que “o mais velho servirá ao mais moço”, e mais tarde ajudou Jacó a obter a bênção de Isaque.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
63	Esaú	M	“Peludo”; também chamado Edom, “vermelho”.	-1858	f	\N	f	\N	59	62	f	Gêmeo de Jacó; vendeu a primogenitura; pai dos edomitas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
64	Jacó (Israel)	M	Jacó = “segura o calcanhar”/“suplantador”; Israel = “luta com Deus” (Gn 32:28).	-1858	f	-1711	f	147	59	62	f	Pai das doze tribos; recebeu o nome Israel.	Nasceu segurando o calcanhar de Esaú. Obteve a primogenitura e a bênção paterna, e fugiu para Harã, tendo no caminho o sonho da escada em Betel. Serviu a Labão vinte anos e casou-se com Lia e Raquel; com elas e as servas Bila e Zilpa teve doze filhos e uma filha.\n\nNo retorno, lutou com Deus em Peniel e recebeu o nome Israel. Na velhice desceu ao Egito para reencontrar José, onde morreu aos 147 anos.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
65	Lia	F	\N	-1811	t	\N	t	\N	61	\N	f	Primeira esposa de Jacó; mãe de Levi e Judá.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
66	Raquel	F	\N	-1806	t	-1751	t	\N	61	\N	f	Esposa amada de Jacó; mãe de José e Benjamim.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
67	Bila	F	\N	-1806	t	\N	t	\N	\N	\N	f	Serva de Raquel; mãe de Dã e Naftali.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
68	Zilpa	F	\N	-1806	t	\N	t	\N	\N	\N	f	Serva de Lia; mãe de Gade e Aser.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
69	Rúben	M	“Vede, um filho”	-1774	t	\N	t	\N	64	65	f	Filho de Jacó; patriarca de uma das tribos de Israel.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
70	Simeão	M	“Ouvido”	-1773	t	\N	t	\N	64	65	f	Filho de Jacó; patriarca de uma das tribos de Israel.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
71	Dã	M	“Juiz”	-1772	t	\N	t	\N	64	67	f	Filho de Jacó; patriarca de uma das tribos de Israel.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
72	Gade	M	“Sorte”, “fortuna”	-1771	t	\N	t	\N	64	68	f	Filho de Jacó; patriarca de uma das tribos de Israel.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
73	Naftali	M	“Minha luta”	-1770	t	\N	t	\N	64	67	f	Filho de Jacó; patriarca de uma das tribos de Israel.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
74	Aser	M	“Feliz”	-1769	t	\N	t	\N	64	68	f	Filho de Jacó; patriarca de uma das tribos de Israel.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
75	Issacar	M	“Recompensa”	-1769	t	\N	t	\N	64	65	f	Filho de Jacó; patriarca de uma das tribos de Israel.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
76	Zebulom	M	“Morada”	-1768	t	\N	t	\N	64	65	f	Filho de Jacó; patriarca de uma das tribos de Israel.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
77	Levi	M	“Unido”	-1772	t	-1635	t	137	64	65	f	Patriarca da tribo sacerdotal.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
78	Judá	M	“Louvor”	-1771	t	\N	t	\N	64	65	f	Patriarca da tribo real, de Davi e do Messias.	Quarto filho de Lia, Judá propôs vender José aos ismaelitas em vez de matá-lo. Mais tarde, no episódio com Tamar, reconheceu: “Mais justa é ela do que eu”. No Egito, ofereceu-se como escravo no lugar de Benjamim, mostrando arrependimento. Jacó profetizou que o cetro não se arredaria de Judá.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
79	Diná	F	“Julgada”	-1768	t	\N	t	\N	64	65	f	Única filha de Jacó cujo nome é registrado.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
80	José	M	“Que Ele acrescente”	-1767	f	-1657	f	110	64	66	f	Vendido pelos irmãos, tornou-se governador do Egito.	Filho amado de Jacó, recebeu uma túnica especial e teve sonhos de que os irmãos se curvariam diante dele. Por inveja, foi vendido como escravo e levado ao Egito, onde serviu na casa de Potifar e foi preso injustamente.\n\nAo interpretar os sonhos do faraó, foi feito governador de todo o Egito aos 30 anos e administrou os sete anos de fartura e os sete de fome. Reencontrou os irmãos, perdoou-os e trouxe toda a família ao Egito: “Vós intentastes o mal contra mim; porém Deus o tornou em bem” (Gn 50:20).	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
81	Benjamim	M	“Filho da mão direita”	-1751	t	\N	t	\N	64	66	f	Caçula de Jacó; Raquel morreu no seu parto.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
82	Asenate	F	\N	-1756	t	\N	t	\N	\N	\N	f	Esposa egípcia de José, filha de Potífera, sacerdote de Om.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
83	Manassés	M	“Que faz esquecer”	-1736	t	\N	t	\N	80	82	f	Primogênito de José.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
84	Efraim	M	“Frutífero”	-1734	t	\N	t	\N	80	82	f	Filho de José; abençoado acima do irmão mais velho.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
86	Er	M	\N	-1754	t	\N	t	\N	78	85	f	Primogênito de Judá; mau aos olhos do Senhor.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
87	Onã	M	\N	-1752	t	\N	t	\N	78	85	f	Filho de Judá; recusou dar descendência ao irmão.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
88	Selá (filho de Judá)	M	\N	-1750	t	\N	t	\N	78	85	f	Terceiro filho de Judá.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
89	Tamar	F	\N	-1746	t	\N	t	\N	\N	\N	f	Nora de Judá; mãe de Perez e Zerá.	Viúva de Er e depois de Onã, Tamar foi deixada sem o filho prometido. Disfarçada, concebeu do próprio sogro Judá, que, confrontado com seu selo e cajado, reconheceu: “Mais justa é ela do que eu” (Gn 38:26). Teve os gêmeos Perez e Zerá.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
90	Perez	M	“Rompimento”	-1729	t	\N	t	\N	78	89	f	Gêmeo que “rompeu” à frente do irmão; ancestral de Davi.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
91	Zerá	M	“Brilho”	-1729	t	\N	t	\N	78	89	f	Gêmeo de Perez.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
92	Hezrom	M	\N	-1706	t	\N	t	\N	90	\N	f	Neto de Judá.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
93	Rão	M	\N	-1666	t	\N	t	\N	92	\N	f	Ancestral de Davi.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
94	Aminadabe	M	\N	-1626	t	\N	t	\N	93	\N	f	Pai de Naassom e de Eliseba, esposa de Arão.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
95	Naassom	M	\N	-1586	t	\N	t	\N	94	\N	f	Príncipe da tribo de Judá no deserto.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
96	Salmom	M	\N	-1516	t	\N	t	\N	95	\N	f	Marido de Raabe; pai de Boaz.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
97	Raabe	F	\N	-1501	t	\N	t	\N	\N	\N	f	Cananeia de Jericó que escondeu os espias de Israel.	Moradora de Jericó, Raabe escondeu os dois espias enviados por Josué, confessando que o Senhor era Deus “em cima nos céus e embaixo na terra” (Js 2:11). Um cordão escarlate em sua janela poupou ela e sua família na queda da cidade. Integrou-se a Israel e tornou-se ancestral de Davi.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
98	Boaz	M	“Nele há força”	-1456	t	\N	t	\N	96	97	f	Parente-resgatador que se casou com Rute.	Rico proprietário de Belém, Boaz acolheu Rute em seus campos na época da colheita. Como parente-resgatador (go’el), resgatou a herança de Elimeleque e casou-se com Rute, tornando-se pai de Obede, avô de Davi.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
99	Elimeleque	M	“Meu Deus é rei”	-1466	t	\N	t	\N	\N	\N	f	Marido de Noemi; morreu em Moabe.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
100	Noemi	F	“Agradável”	-1461	t	\N	t	\N	\N	\N	f	Sogra de Rute.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
101	Malom	M	\N	-1436	t	\N	t	\N	99	100	f	Primeiro marido de Rute; morreu em Moabe.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
102	Quiliom	M	\N	-1434	t	\N	t	\N	99	100	f	Filho de Noemi; marido de Orfa.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
147	Eliaquim	M	\N	-483	t	\N	t	\N	146	\N	f	Ascendente de José na genealogia de Mateus.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
103	Rute	F	Possivelmente “amizade”, “companheira”.	-1416	t	\N	t	\N	\N	\N	f	Moabita fiel à sogra; bisavó do rei Davi.	Viúva de Malom, a moabita Rute recusou-se a deixar a sogra Noemi: “o teu povo é o meu povo, e o teu Deus é o meu Deus” (Rt 1:16). Em Belém, recolheu espigas nos campos de Boaz, que a resgatou e se casou com ela. Seu filho Obede foi avô de Davi.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
104	Obede	M	“Servo”	-1386	t	\N	t	\N	98	103	f	Avô de Davi.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
105	Jessé	M	\N	-1100	t	\N	t	\N	104	\N	f	Pai do rei Davi, de Belém.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
106	Quis	M	\N	-1110	t	\N	t	\N	\N	\N	f	Benjamita, pai do rei Saul.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
107	Saul	M	“Pedido”	-1080	t	-1010	t	\N	106	\N	f	Primeiro rei de Israel, da tribo de Benjamim.	Escolhido e ungido por Samuel quando o povo pediu um rei, Saul começou bem, mas desobedeceu a Deus em Gilgal e na guerra contra os amalequitas, e foi rejeitado como rei. Perseguiu Davi por anos por ciúmes. Morreu com três filhos, entre eles Jônatas, na batalha do monte Gilboa.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
108	Jônatas	M	“O Senhor deu”	-1050	t	-1010	t	\N	107	\N	f	Filho de Saul e amigo fiel de Davi.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
109	Mefibosete	M	\N	-1015	t	\N	t	\N	108	\N	f	Filho de Jônatas, aleijado dos pés, acolhido por Davi.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
110	Mical	F	\N	-1045	t	\N	t	\N	107	\N	f	Filha de Saul; primeira esposa de Davi.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
111	Davi	M	“Amado”	-1040	t	-970	t	70	105	\N	f	Rei de Israel, “homem segundo o coração de Deus”.	O mais novo dos filhos de Jessé, pastor em Belém, foi ungido por Samuel ainda jovem. Venceu o gigante Golias, serviu na corte de Saul e foi perseguido por ele durante anos.\n\nReinou sete anos e meio em Hebrom e 33 em Jerusalém, que conquistou e fez capital, para onde levou a arca. Deus prometeu-lhe uma dinastia eterna (2Sm 7). Pecou com Bate-Seba e mandou matar Urias, arrependeu-se (Sl 51) e sofreu as consequências em sua casa. Compôs boa parte dos Salmos. O Messias é chamado “Filho de Davi”.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
112	Ainoã (de Jezreel)	F	\N	-1040	t	\N	t	\N	\N	\N	f	Esposa de Davi; mãe de Amnom.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
113	Abigail	F	\N	-1040	t	\N	t	\N	\N	\N	f	Mulher sensata que apaziguou Davi; depois sua esposa.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
114	Maaca	F	\N	-1035	t	\N	t	\N	\N	\N	f	Filha de Talmai, rei de Gesur; mãe de Absalão e Tamar.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
115	Hagite	F	\N	-1035	t	\N	t	\N	\N	\N	f	Esposa de Davi; mãe de Adonias.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
116	Bate-Seba	F	“Filha do juramento”	-1020	t	\N	t	\N	\N	\N	f	Esposa de Urias e depois de Davi; mãe de Salomão.	Filha de Eliã e esposa de Urias, o heteu, foi tomada por Davi enquanto o marido estava na guerra. Após a morte de Urias, tornou-se esposa de Davi. O primeiro filho morreu; o segundo foi Salomão. Na velhice de Davi, garantiu, com o profeta Natã, que Salomão fosse o sucessor.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
117	Urias, o heteu	M	\N	-1030	t	-992	t	\N	\N	\N	f	Soldado fiel de Davi, morto por ordem do rei.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
118	Amnom	M	\N	-1009	t	\N	t	\N	111	112	f	Primogênito de Davi; morto por Absalão.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
119	Quileabe	M	\N	-1008	t	\N	t	\N	111	113	f	Filho de Davi com Abigail (também chamado Daniel).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
120	Absalão	M	“Pai da paz”	-1007	t	\N	t	\N	111	114	f	Filho de Davi que se rebelou contra o pai.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
121	Tamar (filha de Davi)	F	\N	-1006	t	\N	t	\N	111	114	f	Irmã de Absalão.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
122	Adonias	M	\N	-1005	t	\N	t	\N	111	115	f	Filho de Davi que tentou tomar o trono.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
123	Salomão	M	“Pacífico”; também Jedidias, “amado do Senhor”.	-990	t	-931	t	\N	111	116	f	Rei sábio que construiu o templo de Jerusalém.	Filho de Davi e Bate-Seba, sucedeu o pai no trono. Pediu a Deus sabedoria para governar e recebeu também riquezas e glória. Construiu o templo em Jerusalém e levou Israel ao auge de prosperidade.\n\nNa velhice, suas muitas mulheres estrangeiras desviaram seu coração para outros deuses, e Deus anunciou a divisão do reino após sua morte. A tradição lhe atribui Provérbios, Eclesiastes e Cânticos.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
124	Natã (filho de Davi)	M	\N	-988	t	\N	t	\N	111	116	f	Filho de Davi; pela linhagem dele Lucas traça a genealogia de Jesus.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
125	Naamá (amonita)	F	\N	-990	t	\N	t	\N	\N	\N	f	Esposa amonita de Salomão; mãe de Roboão.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
126	Roboão	M	\N	-972	t	-914	t	58	123	125	f	Filho de Salomão; em seu reinado o reino se dividiu.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
127	Maaca (filha de Absalão)	F	\N	-985	t	\N	t	\N	120	\N	f	Esposa preferida de Roboão; mãe do rei Abias.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
128	Abias	M	“Meu pai é o Senhor”	-950	t	-911	t	\N	126	127	f	Rei de Judá (913–911 a.C.).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
129	Asa	M	\N	-930	t	-870	t	\N	128	\N	f	Rei de Judá (911–870 a.C.); promoveu reformas religiosas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
130	Josafá	M	“O Senhor julga”	-908	t	-848	t	60	129	\N	f	Rei de Judá (870–848 a.C.); fortaleceu o ensino da Lei.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
131	Jorão (rei de Judá)	M	\N	-880	t	-840	t	40	130	\N	f	Rei de Judá (848–841 a.C.); casou-se com Atalia, filha de Acabe.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
132	Acazias (rei de Judá)	M	\N	-863	t	-840	t	23	131	211	f	Rei de Judá por um ano (841 a.C.). Omitido por Mateus.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
133	Joás (rei de Judá)	M	\N	-842	t	-795	t	47	132	\N	f	Rei de Judá (835–796 a.C.); escondido no templo quando criança. Omitido por Mateus.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
134	Amazias	M	\N	-821	t	-767	t	54	133	\N	f	Rei de Judá (796–767 a.C.). Omitido por Mateus.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
135	Uzias (Azarias)	M	“O Senhor é a minha força”	-808	t	-740	t	68	134	\N	f	Rei de Judá (792–740 a.C.); ficou leproso ao invadir o templo.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
136	Jotão	M	\N	-775	t	-734	t	41	135	\N	f	Rei de Judá (750–735 a.C.).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
137	Acaz	M	\N	-755	t	-719	t	36	136	\N	f	Rei de Judá (735–715 a.C.); idólatra.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
138	Ezequias	M	“O Senhor fortalece”	-740	t	-686	t	54	137	\N	f	Rei de Judá (715–686 a.C.); reformador, livrado da Assíria.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
139	Manassés (rei de Judá)	M	\N	-709	t	-642	t	67	138	\N	f	Rei de Judá (697–642 a.C.); o reinado mais longo, marcado pela idolatria.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
140	Amom	M	\N	-664	t	-640	t	24	139	\N	f	Rei de Judá (642–640 a.C.); assassinado pelos servos.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
141	Josias	M	“O Senhor sustenta”	-648	t	-609	t	39	140	\N	f	Rei de Judá (640–609 a.C.); restaurou a Lei e a Páscoa.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
142	Jeoaquim	M	\N	-634	t	-598	t	36	141	\N	f	Rei de Judá (609–598 a.C.). Omitido por Mateus.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
143	Jeconias (Joaquim)	M	\N	-616	t	\N	t	\N	142	\N	f	Rei de Judá por três meses (598/597 a.C.); levado cativo para a Babilônia.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
144	Salatiel	M	“Pedi a Deus”	-595	t	\N	t	\N	143	\N	f	Filho de Jeconias, nascido no exílio.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
199	Zerua	F	\N	-990	t	\N	t	\N	\N	\N	f	Viúva, mãe de Jeroboão I.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
149	Sadoque	M	\N	-369	t	\N	t	\N	148	\N	f	Ascendente de José na genealogia de Mateus.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
150	Aquim	M	\N	-312	t	\N	t	\N	149	\N	f	Ascendente de José na genealogia de Mateus.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
151	Eliúde	M	\N	-255	t	\N	t	\N	150	\N	f	Ascendente de José na genealogia de Mateus.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
152	Eleazar (pai de Matã)	M	\N	-198	t	\N	t	\N	151	\N	f	Ascendente de José na genealogia de Mateus.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
153	Matã	M	\N	-141	t	\N	t	\N	152	\N	f	Ascendente de José na genealogia de Mateus.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
154	Jacó (pai de José)	M	\N	-84	t	\N	t	\N	153	\N	f	Pai de José, segundo Mateus.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
155	José (marido de Maria)	M	\N	-30	t	\N	t	\N	154	\N	f	Carpinteiro de Nazaré, descendente de Davi; pai legal de Jesus.	Descendente de Davi pela linhagem real, José estava desposado com Maria quando ela concebeu pelo Espírito Santo. Homem justo, pensava deixá-la secretamente, mas um anjo, em sonho, o mandou recebê-la e dar ao menino o nome de Jesus.\n\nLevou a família a Belém para o recenseamento, fugiu com ela para o Egito diante da ameaça de Herodes e depois se estabeleceu em Nazaré. A última menção a ele é na visita ao templo, quando Jesus tinha 12 anos.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
156	Maria	F	Do hebraico Miriam (mesmo nome de Miriã, irmã de Moisés).	-20	t	\N	t	\N	\N	\N	f	Mãe de Jesus; concebeu pelo Espírito Santo.	Jovem de Nazaré desposada com José, recebeu do anjo Gabriel o anúncio de que conceberia pelo Espírito Santo e daria à luz o Filho do Altíssimo, e respondeu: “Eis aqui a serva do Senhor”. Visitou a parente Isabel e entoou o Magnificat.\n\nAcompanhou Jesus desde Belém até a cruz, onde foi confiada ao discípulo João, e está entre os que oravam no cenáculo antes do Pentecostes.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
157	Jesus	M	Do hebraico Yehoshua, “o Senhor salva” (Mt 1:21). Cristo = “Ungido” (Messias).	-4	t	30	t	33	\N	156	f	O Messias, Filho de Deus, “filho de Davi, filho de Abraão” (Mt 1:1).	Mateus abre seu evangelho com a “genealogia de Jesus Cristo, filho de Davi, filho de Abraão”, mostrando-o como herdeiro das promessas feitas a Abraão e do trono de Davi. Concebido pelo Espírito Santo, nasceu da virgem Maria em Belém, nos dias do rei Herodes; José, descendente de Davi, foi seu pai legal.\n\nPor volta dos 30 anos iniciou seu ministério na Galileia e na Judeia, pregando o Reino de Deus. Foi crucificado em Jerusalém sob Pôncio Pilatos e, segundo os evangelhos, ressuscitou ao terceiro dia.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
158	Matatá	M	\N	-968	t	\N	t	\N	124	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
160	Meleá	M	\N	-929	t	\N	t	\N	159	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
161	Eliaquim (Lc 3:30)	M	\N	-909	t	\N	t	\N	160	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
162	Jonã	M	\N	-890	t	\N	t	\N	161	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
163	José (Lc 3:30)	M	\N	-870	t	\N	t	\N	162	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
164	Judá (Lc 3:30)	M	\N	-850	t	\N	t	\N	163	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
165	Simeão (Lc 3:30)	M	\N	-831	t	\N	t	\N	164	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
166	Levi (Lc 3:29)	M	\N	-811	t	\N	t	\N	165	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
167	Matate (Lc 3:29)	M	\N	-792	t	\N	t	\N	166	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
168	Jorim	M	\N	-772	t	\N	t	\N	167	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
169	Eliézer (Lc 3:29)	M	\N	-752	t	\N	t	\N	168	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
170	Josué (Lc 3:29)	M	\N	-733	t	\N	t	\N	169	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
171	Er (Lc 3:28)	M	\N	-713	t	\N	t	\N	170	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
172	Elmadã	M	\N	-693	t	\N	t	\N	171	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
173	Cosã	M	\N	-674	t	\N	t	\N	172	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
174	Adi	M	\N	-654	t	\N	t	\N	173	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
175	Melqui (Lc 3:28)	M	\N	-634	t	\N	t	\N	174	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
176	Neri	M	\N	-615	t	\N	t	\N	175	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
177	Resa	M	\N	-542	t	\N	t	\N	145	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
178	Joanã	M	\N	-513	t	\N	t	\N	177	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
179	Jodá	M	\N	-485	t	\N	t	\N	178	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
180	Joseque	M	\N	-456	t	\N	t	\N	179	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
181	Semei	M	\N	-428	t	\N	t	\N	180	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
182	Matatias (Lc 3:26)	M	\N	-399	t	\N	t	\N	181	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
183	Maate	M	\N	-371	t	\N	t	\N	182	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
184	Nagaí	M	\N	-343	t	\N	t	\N	183	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
185	Esli	M	\N	-314	t	\N	t	\N	184	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
186	Naum (Lc 3:25)	M	\N	-286	t	\N	t	\N	185	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
187	Amós (Lc 3:25)	M	\N	-257	t	\N	t	\N	186	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
188	Matatias (Lc 3:25)	M	\N	-229	t	\N	t	\N	187	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
189	José (Lc 3:24)	M	\N	-201	t	\N	t	\N	188	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
190	Janai	M	\N	-172	t	\N	t	\N	189	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
191	Melqui (Lc 3:24)	M	\N	-144	t	\N	t	\N	190	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
192	Levi (Lc 3:24)	M	\N	-115	t	\N	t	\N	191	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
193	Matate (Lc 3:24)	M	\N	-87	t	\N	t	\N	192	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
194	Eli	M	\N	-58	t	\N	t	\N	193	\N	f	Ascendente de Jesus na genealogia de Lucas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
195	Hamutal	F	\N	-650	t	\N	t	\N	\N	\N	f	Esposa de Josias; mãe dos reis Jeoacaz e Zedequias.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
196	Jeoacaz (rei de Judá)	M	\N	-632	t	\N	t	\N	141	195	f	Rei de Judá por três meses (609 a.C.); levado ao Egito pelo faraó Neco.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
197	Zedequias	M	“Justiça do Senhor”	-618	t	\N	t	\N	141	195	f	Último rei de Judá (597–586 a.C.); viu a destruição de Jerusalém.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
198	Nebate	M	\N	-995	t	\N	t	\N	\N	\N	f	Efraimita, pai de Jeroboão I.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
200	Jeroboão I	M	“Que o povo se multiplique”	-965	t	-910	t	\N	198	199	f	Primeiro rei de Israel (931–910 a.C.); instituiu os bezerros de ouro.	Oficial de Salomão encarregado dos trabalhos forçados da casa de José, Jeroboão recebeu do profeta Aías a promessa de reinar sobre dez tribos. Fugiu para o Egito e voltou após a morte de Salomão. Quando Roboão endureceu o jugo, as tribos do norte o fizeram rei.\n\nPara que o povo não subisse a Jerusalém, fez dois bezerros de ouro, em Betel e em Dã, e instituiu sacerdotes e festas próprias. Esse “pecado de Jeroboão” passou a ser a medida de quase todos os reis de Israel depois dele.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
201	Nadabe (rei de Israel)	M	\N	-945	t	-909	t	\N	200	\N	f	Rei de Israel (910–909 a.C.); assassinado por Baasa.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
202	Aías (pai de Baasa)	M	\N	-970	t	\N	t	\N	\N	\N	f	Da tribo de Issacar; pai do rei Baasa.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
203	Baasa	M	\N	-945	t	-886	t	\N	202	\N	f	Rei de Israel (909–886 a.C.); fundou a segunda dinastia.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
204	Elá (rei de Israel)	M	\N	-915	t	-885	t	\N	203	\N	f	Rei de Israel (886–885 a.C.).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
205	Zinri	M	\N	-920	t	-885	t	\N	\N	\N	f	Rei de Israel por sete dias (885 a.C.).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
206	Onri	M	\N	-920	t	-874	t	\N	\N	\N	f	Rei de Israel (885–874 a.C.); fundou Samaria.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
207	Acabe	M	\N	-905	t	-853	t	\N	206	\N	f	Rei de Israel (874–853 a.C.); marido de Jezabel, adversário de Elias.	Filho de Onri, casou-se com Jezabel, filha do rei de Sidom, e introduziu oficialmente o culto a Baal em Samaria. Em seu reinado o profeta Elias anunciou a seca, desafiou os profetas de Baal no monte Carmelo e o confrontou pelo assassinato de Nabote, cuja vinha Acabe cobiçava.\n\nFoi também um rei militarmente forte. Morreu na batalha de Ramote-Gileade, ferido por uma flecha atirada a esmo, apesar de ter ido disfarçado.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
208	Jezabel	F	\N	-895	t	-841	t	\N	\N	\N	f	Rainha fenícia, esposa de Acabe; perseguidora dos profetas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
209	Acazias (rei de Israel)	M	\N	-875	t	-852	t	\N	207	208	f	Rei de Israel (853–852 a.C.).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
210	Jorão (rei de Israel)	M	\N	-873	t	-841	t	\N	207	208	f	Rei de Israel (852–841 a.C.); último da dinastia de Onri.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
211	Atalia	F	\N	-883	t	-835	t	\N	207	\N	f	Filha de Acabe; rainha de Judá (841–835 a.C.), a única mulher a reinar sobre Judá.	Filha de Acabe, foi dada em casamento a Jorão, rei de Judá, selando uma aliança entre os dois reinos. Influenciou o marido e o filho Acazias a seguirem os caminhos da casa de Acabe.\n\nQuando Acazias foi morto por Jeú, Atalia exterminou a descendência real e tomou o trono. O pequeno Joás, porém, foi escondido no templo pela tia Jeoseba e pelo sacerdote Joiada, que seis anos depois o coroou. Atalia foi morta.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
213	Josafá (pai de Jeú)	M	\N	-910	t	\N	t	\N	212	\N	f	Pai de Jeú.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
214	Jeú	M	\N	-880	t	-814	t	\N	213	\N	f	Rei de Israel (841–814 a.C.); exterminou a casa de Acabe e o culto a Baal.	Comandante do exército, foi ungido rei por um discípulo de Eliseu, cumprindo uma ordem dada a Elias. Num único dia matou Jorão de Israel e Acazias de Judá, e mandou lançar Jezabel da janela. Em seguida exterminou a casa de Acabe e os adoradores de Baal.\n\nNo entanto, manteve os bezerros de ouro de Jeroboão. Deus prometeu-lhe descendentes no trono até a quarta geração.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
215	Jeoacaz (rei de Israel)	M	\N	-850	t	-798	t	\N	214	\N	f	Rei de Israel (814–798 a.C.); oprimido pela Síria.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
216	Jeoás (rei de Israel)	M	\N	-830	t	-782	t	\N	215	\N	f	Rei de Israel (798–782 a.C.).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
217	Jeroboão II	M	\N	-810	t	-753	t	\N	216	\N	f	Rei de Israel (793–753 a.C.); o reinado mais longo e próspero do norte.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
218	Zacarias (rei de Israel)	M	\N	-785	t	-752	t	\N	217	\N	f	Rei de Israel por seis meses (753 a.C.).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
219	Jabes	M	\N	-815	t	\N	t	\N	\N	\N	f	Pai do rei Salum.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
220	Salum	M	\N	-790	t	-752	t	\N	219	\N	f	Rei de Israel por um mês (752 a.C.).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
221	Gadi	M	\N	-815	t	\N	t	\N	\N	\N	f	Pai do rei Menaém.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
222	Menaém	M	\N	-790	t	-742	t	\N	221	\N	f	Rei de Israel (752–742 a.C.); tributário da Assíria.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
223	Pecaías	M	\N	-770	t	-740	t	\N	222	\N	f	Rei de Israel (742–740 a.C.); assassinado por Peca.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
224	Remalias	M	\N	-805	t	\N	t	\N	\N	\N	f	Pai do rei Peca.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
225	Peca	M	\N	-780	t	-732	t	\N	224	\N	f	Rei de Israel (752/740–732 a.C.); aliado da Síria contra Judá.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
226	Elá (pai de Oseias)	M	\N	-795	t	\N	t	\N	\N	\N	f	Pai do rei Oseias.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
227	Oseias (rei de Israel)	M	\N	-770	t	\N	t	\N	226	\N	f	Último rei de Israel (732–722 a.C.).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
228	Coate	M	\N	-1736	t	-1603	t	133	77	\N	f	Filho de Levi; avô de Moisés.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
229	Anrão	M	\N	-1666	t	-1529	t	137	228	\N	f	Pai de Moisés, Arão e Miriã.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
230	Joquebede	F	“O Senhor é glória”	-1641	t	\N	t	\N	77	\N	f	Mãe de Moisés; escondeu o filho num cesto no Nilo.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
231	Miriã	F	\N	-1603	t	\N	t	\N	229	230	f	Profetisa, irmã de Moisés e Arão.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
232	Arão	M	\N	-1596	f	-1473	f	123	229	230	f	Primeiro sumo sacerdote de Israel.	Irmão mais velho de Moisés, foi seu porta-voz diante do faraó. Foi consagrado como o primeiro sumo sacerdote e seus filhos como sacerdotes. Fraquejou ao fazer o bezerro de ouro. Morreu no monte Hor aos 123 anos, e Eleazar o sucedeu.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
233	Moisés	M	“Tirado das águas” (Êx 2:10).	-1593	f	-1473	f	120	229	230	f	Libertador de Israel do Egito e mediador da Lei.	Nascido quando o faraó mandava matar os meninos hebreus, foi escondido num cesto no Nilo e criado pela filha do faraó. Aos 40 anos fugiu para Midiã, onde se casou com Zípora e foi pastor por 40 anos.\n\nNa sarça ardente, Deus o enviou para libertar Israel. Após as dez pragas, conduziu o povo pelo mar Vermelho, recebeu a Lei no Sinai e liderou Israel 40 anos no deserto. Morreu no monte Nebo, vendo a terra prometida de longe, aos 120 anos.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
234	Jetro	M	\N	-1626	t	\N	t	\N	\N	\N	f	Sacerdote de Midiã, sogro de Moisés (também chamado Reuel).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
235	Zípora	F	“Pássaro”	-1576	t	\N	t	\N	234	\N	f	Esposa midianita de Moisés.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
236	Gérson	M	“Peregrino ali”	-1551	t	\N	t	\N	233	235	f	Primogênito de Moisés.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
237	Eliézer	M	“Meu Deus é auxílio”	-1546	t	\N	t	\N	233	235	f	Filho de Moisés.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
238	Eliseba	F	\N	-1591	t	\N	t	\N	94	\N	f	Esposa de Arão; irmã de Naassom, da tribo de Judá.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
239	Nadabe	M	\N	-1566	t	\N	t	\N	232	238	f	Filho de Arão; morto por oferecer fogo estranho.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
240	Abiú	M	\N	-1564	t	\N	t	\N	232	238	f	Filho de Arão; morto por oferecer fogo estranho.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
241	Eleazar	M	\N	-1562	t	\N	t	\N	232	238	f	Sucessor de Arão como sumo sacerdote.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
242	Itamar	M	\N	-1560	t	\N	t	\N	232	238	f	Filho de Arão; supervisionou o tabernáculo.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
243	Fineias	M	\N	-1526	t	\N	t	\N	241	\N	f	Sacerdote zeloso; recebeu a aliança de um sacerdócio perpétuo.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
244	Tiago (irmão de Jesus)	M	\N	-2	t	62	t	\N	155	156	f	“O irmão do Senhor”; líder da igreja de Jerusalém.	Durante o ministério de Jesus, seus irmãos não criam nele (Jo 7:5). Depois da ressurreição, Jesus apareceu a Tiago (1Co 15:7), e ele passou a fazer parte da comunidade em Jerusalém.\n\nTornou-se o principal líder da igreja de Jerusalém. Presidiu o concílio que decidiu não impor a circuncisão aos gentios (At 15) e recebeu Paulo em suas visitas. A tradição lhe atribui a epístola de Tiago. Segundo o historiador Flávio Josefo, foi apedrejado por ordem do sumo sacerdote Anano em 62 d.C.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
245	José (irmão de Jesus)	M	\N	1	t	\N	t	\N	155	156	f	Irmão de Jesus; conhecido só pelo nome.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
246	Simão (irmão de Jesus)	M	\N	3	t	\N	t	\N	155	156	f	Irmão de Jesus; conhecido só pelo nome.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
247	Judas (irmão de Jesus)	M	\N	5	t	\N	t	\N	155	156	f	Irmão de Jesus; tradicionalmente o autor da epístola de Judas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
248	Irmãs	F	\N	7	t	\N	t	\N	155	156	t	Irmãs de Jesus, citadas sem nome (“não estão entre nós todas as suas irmãs?”).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
249	Irmãs	F	\N	-3886	t	\N	t	\N	1	2	t	Irmãs de Sete, sem nome: “gerou filhos e filhas” (Gn 5:4).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
250	Irmãs	F	\N	-3781	t	\N	t	\N	16	\N	t	Irmãs de Enos, sem nome: “gerou filhos e filhas” (Gn 5:7).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
251	Irmãs	F	\N	-3691	t	\N	t	\N	17	\N	t	Irmãs de Cainã, sem nome: “gerou filhos e filhas” (Gn 5:10).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
252	Irmãs	F	\N	-3621	t	\N	t	\N	18	\N	t	Irmãs de Maalalel, sem nome: “gerou filhos e filhas” (Gn 5:13).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
253	Irmãs	F	\N	-3556	t	\N	t	\N	19	\N	t	Irmãs de Jarede, sem nome: “gerou filhos e filhas” (Gn 5:16).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
254	Irmãs	F	\N	-3394	t	\N	t	\N	20	\N	t	Irmãs de Enoque, sem nome: “gerou filhos e filhas” (Gn 5:19).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
255	Irmãs	F	\N	-3329	t	\N	t	\N	21	\N	t	Irmãs de Metusalém, sem nome: “gerou filhos e filhas” (Gn 5:22).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
256	Irmãs	F	\N	-3142	t	\N	t	\N	22	\N	t	Irmãs de Lameque, sem nome: “gerou filhos e filhas” (Gn 5:26).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
257	Irmãs	F	\N	-2960	t	\N	t	\N	23	\N	t	Irmãs de Noé, sem nome: “gerou filhos e filhas” (Gn 5:30).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
258	Irmãs	F	\N	-2358	t	\N	t	\N	26	\N	t	Irmãs de Arfaxade, sem nome: “gerou filhos e filhas” (Gn 11:11).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
259	Irmãs	F	\N	-2323	t	\N	t	\N	40	\N	t	Irmãs de Selá, sem nome: “gerou filhos e filhas” (Gn 11:13).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
260	Irmãs	F	\N	-2293	t	\N	t	\N	41	\N	t	Irmãs de Héber, sem nome: “gerou filhos e filhas” (Gn 11:15).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
261	Irmãs	F	\N	-2259	t	\N	t	\N	42	\N	t	Irmãs de Pelegue, sem nome: “gerou filhos e filhas” (Gn 11:17).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
262	Irmãs	F	\N	-2229	t	\N	t	\N	43	\N	t	Irmãs de Reú, sem nome: “gerou filhos e filhas” (Gn 11:19).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
263	Irmãs	F	\N	-2197	t	\N	t	\N	45	\N	t	Irmãs de Serugue, sem nome: “gerou filhos e filhas” (Gn 11:21).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
264	Irmãs	F	\N	-2167	t	\N	t	\N	46	\N	t	Irmãs de Naor, sem nome: “gerou filhos e filhas” (Gn 11:23).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
265	Irmãs	F	\N	-2138	t	\N	t	\N	47	\N	t	Irmãs de Terá, sem nome: “gerou filhos e filhas” (Gn 11:25).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
266	Irmãs	F	\N	-1757	t	\N	t	\N	64	\N	t	Filhas de Jacó além de Diná: “todos os seus filhos e todas as suas filhas” (Gn 37:35).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
267	Irmã	F	\N	-1938	t	\N	t	\N	52	\N	t	Filha mais velha de Ló, sem nome; mãe de Moabe.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
268	Irmã	F	\N	-1936	t	\N	t	\N	52	\N	t	Filha mais nova de Ló, sem nome; mãe de Ben-Ami.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
269	Irmãs	F	\N	-1095	t	\N	t	\N	304	305	t	Duas irmãs de Samuel, sem nome: Ana “teve três filhos e duas filhas” (1Sm 2:21).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
270	Irmãs	F	\N	-980	t	\N	t	\N	111	\N	t	Filhas de Davi além de Tamar: “nasceram a Davi mais filhos e filhas” (2Sm 5:13).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
271	Irmãs	F	\N	-940	t	\N	t	\N	126	\N	t	As 60 filhas de Roboão, sem nome (2Cr 11:21).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
272	Irmãs	F	\N	-920	t	\N	t	\N	128	\N	t	As 16 filhas de Abias, sem nome (2Cr 13:21).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
273	Irmãs	F	\N	-590	t	\N	t	\N	197	\N	t	As filhas do rei Zedequias, sem nome.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
274	Jonas (pai de Pedro)	M	\N	-30	t	\N	t	\N	\N	\N	f	Pai de Simão Pedro e de André.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
275	Simão Pedro	M	Cefas (aramaico) / Pedro (grego) = “pedra”	1	t	64	t	\N	274	\N	f	Pescador da Galileia; o principal dos Doze e líder da igreja primitiva.	Pescador de Betsaida que morava em Cafarnaum, foi levado a Jesus pelo irmão André e recebeu o nome Cefas, “pedra”. Fez parte do círculo íntimo com Tiago e João e confessou: “Tu és o Cristo, o Filho do Deus vivo”.\n\nNegou Jesus três vezes na noite da prisão e foi restaurado depois da ressurreição. No Pentecostes pregou o primeiro sermão da igreja, e mais tarde abriu as portas aos gentios na casa de Cornélio. A tradição diz que foi crucificado em Roma sob Nero.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
276	Sogra	F	\N	-25	t	\N	t	\N	\N	\N	t	Sogra de Pedro, sem nome; curada de febre por Jesus.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
277	Esposa	F	\N	3	t	\N	t	\N	\N	276	t	Esposa de Pedro, sem nome.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
278	André	M	“Varonil”	5	t	60	t	\N	274	\N	f	Pescador, irmão de Pedro; o primeiro chamado.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
279	Zebedeu	M	\N	-25	t	\N	t	\N	\N	\N	f	Pescador da Galileia; pai de Tiago e João.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
280	Salomé (mãe de Tiago e João)	F	\N	-20	t	\N	t	\N	\N	\N	f	Mãe dos filhos de Zebedeu; seguiu Jesus até a cruz.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
281	Tiago (filho de Zebedeu)	M	\N	5	t	44	t	\N	279	280	f	Pescador, irmão de João; o primeiro apóstolo martirizado.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
282	João (apóstolo)	M	“O Senhor é gracioso”	10	t	100	t	\N	279	280	f	Irmão de Tiago; tradicionalmente o “discípulo amado”.	Pescador, filho de Zebedeu, foi chamado com o irmão Tiago e fez parte do círculo íntimo de Jesus. Na cruz, Jesus lhe confiou sua mãe, Maria.\n\nDepois da ressurreição, foi uma das “colunas” da igreja de Jerusalém, ao lado de Pedro e Tiago, irmão do Senhor. A tradição lhe atribui o Evangelho de João, três epístolas e o Apocalipse, escrito no exílio na ilha de Patmos, e diz que morreu idoso em Éfeso.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
283	Filipe (apóstolo)	M	“Amigo de cavalos”	5	t	\N	t	\N	\N	\N	f	Apóstolo de Betsaida; levou Natanael a Jesus.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
284	Bartolomeu (Natanael)	M	Bar-Tolmai = “filho de Tolmai”	5	t	\N	t	\N	\N	\N	f	Apóstolo; tradicionalmente identificado com Natanael de Caná.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
285	Tomé	M	“Gêmeo” (aramaico), Dídimo em grego	5	t	72	t	\N	\N	\N	f	Apóstolo que duvidou e depois confessou: “Senhor meu e Deus meu!”	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
286	Alfeu (pai de Mateus)	M	\N	-30	t	\N	t	\N	\N	\N	f	Pai de Levi (Mateus).	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
287	Mateus (Levi)	M	“Dom do Senhor”	1	t	\N	t	\N	286	\N	f	Cobrador de impostos chamado por Jesus; tradicionalmente autor do primeiro evangelho.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
288	Alfeu (pai de Tiago)	M	\N	-30	t	\N	t	\N	\N	\N	f	Pai do apóstolo Tiago, o menor.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
289	Tiago (filho de Alfeu)	M	\N	5	t	\N	t	\N	288	\N	f	Apóstolo; geralmente identificado com “Tiago, o menor”.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
290	Tiago (pai de Judas Tadeu)	M	\N	-25	t	\N	t	\N	\N	\N	f	Pai do apóstolo Judas Tadeu.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
291	Judas Tadeu	M	\N	5	t	\N	t	\N	290	\N	f	Apóstolo; “Judas, não o Iscariotes”.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
292	Simão, o zelote	M	\N	1	t	\N	t	\N	\N	\N	f	Apóstolo chamado “zelote” ou “cananeu”.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
293	Simão Iscariotes	M	\N	-30	t	\N	t	\N	\N	\N	f	Pai de Judas Iscariotes.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
294	Judas Iscariotes	M	\N	1	t	30	t	\N	293	\N	f	Apóstolo que traiu Jesus por trinta moedas de prata.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
295	Matias	M	“Dom de Deus”	1	t	\N	t	\N	\N	\N	f	Escolhido para substituir Judas Iscariotes entre os Doze.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
296	Pai	M	\N	-25	t	\N	t	\N	\N	\N	t	Pai de Paulo, sem nome; fariseu e cidadão romano.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
297	Paulo (Saulo de Tarso)	M	Saulo (hebraico) / Paulo (latim, “pequeno”)	5	t	67	t	\N	296	\N	f	Fariseu perseguidor convertido no caminho de Damasco; o apóstolo dos gentios.	Nascido em Tarso, na Cilícia, judeu da tribo de Benjamim e cidadão romano, Saulo foi educado em Jerusalém aos pés de Gamaliel. Perseguiu a igreja e consentiu na morte de Estêvão.\n\nNo caminho de Damasco encontrou Jesus ressuscitado e tornou-se o grande missionário aos gentios. Em três viagens fundou igrejas pela Ásia Menor e pela Grécia, e escreveu 13 epístolas do Novo Testamento. Preso em Jerusalém, apelou a César e foi levado a Roma, onde a tradição diz que foi decapitado sob Nero.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
298	Irmã	F	\N	8	t	\N	t	\N	296	\N	t	Irmã de Paulo, sem nome; mãe do sobrinho que o salvou de uma emboscada.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
299	Sobrinho	M	\N	30	t	\N	t	\N	\N	298	t	Sobrinho de Paulo, sem nome; avisou-o de um plano para matá-lo.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
300	Barnabé	M	“Filho de consolação” (At 4:36)	1	t	\N	t	\N	\N	\N	f	Levita de Chipre; companheiro de Paulo, chamado apóstolo em Atos 14:14.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
301	Maria (mãe de Marcos)	F	\N	-10	t	\N	t	\N	\N	\N	f	Mãe de João Marcos; em sua casa a igreja de Jerusalém se reunia.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
302	João Marcos	M	\N	20	t	\N	t	\N	\N	301	f	Primo de Barnabé; tradicionalmente autor do Evangelho de Marcos.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
303	Débora	F	“Abelha”	-1260	t	\N	t	\N	\N	\N	f	Profetisa e juíza de Israel; liderou a vitória sobre Sísera.	Profetisa, esposa de Lapidote, Débora julgava Israel debaixo de uma palmeira entre Ramá e Betel. Convocou Baraque para enfrentar Sísera, comandante de Jabim, rei de Canaã, e foi com ele à batalha. Sísera foi morto por Jael. O Cântico de Débora (Jz 5) celebra a vitória.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
304	Elcana	M	\N	-1140	t	\N	t	\N	\N	\N	f	Efraimita de Ramá; pai de Samuel.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
305	Ana (mãe de Samuel)	F	“Graça”	-1130	t	\N	t	\N	\N	\N	f	Mãe de Samuel; orou pedindo um filho e o dedicou ao Senhor.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
306	Samuel	M	“Pedido a Deus” / “ouvido por Deus”	-1105	t	-1015	t	\N	304	305	f	Último juiz e primeiro dos grandes profetas; ungiu Saul e Davi.	Filho da oração de Ana, foi entregue ainda menino ao serviço do tabernáculo em Siló, sob o sacerdote Eli. Ali ouviu o chamado de Deus durante a noite.\n\nComo juiz e profeta, conduziu Israel ao arrependimento e à vitória sobre os filisteus em Mispá. Quando o povo pediu um rei, ungiu Saul e, depois da rejeição deste, ungiu o jovem Davi em Belém. Morreu antes de Saul e foi pranteado por todo Israel.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
307	Gade (vidente)	M	\N	-1060	t	\N	t	\N	\N	\N	f	Profeta e vidente do rei Davi.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
308	Natã (profeta)	M	\N	-1040	t	\N	t	\N	\N	\N	f	Profeta da corte de Davi; anunciou a aliança davídica e o repreendeu.	Natã comunicou a Davi a promessa de uma dinastia eterna (2Sm 7). Depois do adultério com Bate-Seba e da morte de Urias, confrontou o rei com a parábola da cordeirinha do pobre e declarou: “Tu és este homem”. Mais tarde, garantiu com Bate-Seba que Salomão fosse ungido rei.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
309	Aías, o silonita	M	\N	-990	t	\N	t	\N	\N	\N	f	Profeta que anunciou a Jeroboão o reino das dez tribos.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
310	Elias	M	“Meu Deus é o Senhor”	-900	t	-848	t	\N	\N	\N	f	Profeta de Israel contra o culto a Baal; levado ao céu num redemoinho.	Elias, o tisbita, anunciou a Acabe uma seca de três anos e meio e foi sustentado por corvos e por uma viúva de Sarepta, cujo filho ressuscitou. No monte Carmelo desafiou 450 profetas de Baal, e o fogo do Senhor consumiu o seu sacrifício.\n\nAmeaçado por Jezabel, fugiu ao monte Horebe, onde Deus lhe falou num “cicio tranquilo e suave”. Ungiu Eliseu como sucessor e foi levado ao céu num redemoinho, com carro e cavalos de fogo.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
311	Micaías	M	\N	-900	t	\N	t	\N	\N	\N	f	Profeta que anunciou a derrota de Acabe contra 400 profetas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
312	Safate	M	\N	-905	t	\N	t	\N	\N	\N	f	Pai do profeta Eliseu, de Abel-Meolá.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
313	Eliseu	M	“Deus é salvação”	-880	t	-795	t	\N	312	\N	f	Sucessor de Elias; profeta de muitos milagres em Israel.	Eliseu arava com doze juntas de bois quando Elias lançou sobre ele a sua capa. Seguiu-o e, ao vê-lo subir ao céu, recebeu a “porção dobrada” do seu espírito.\n\nSeu ministério de mais de 50 anos foi marcado por milagres: a multiplicação do azeite da viúva, a ressurreição do filho da sunamita, a cura de Naamã, o machado que flutuou. Teve influência sobre os reis de Israel, de Jorão a Jeoás.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
314	Amitai	M	\N	-830	t	\N	t	\N	\N	\N	f	Pai do profeta Jonas, de Gate-Hefer.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
315	Jonas	M	“Pomba”	-800	t	\N	t	\N	314	\N	f	Profeta enviado a Nínive; passou três dias no ventre de um grande peixe.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
316	Joel	M	“O Senhor é Deus”	-860	t	\N	t	\N	\N	\N	f	Profeta do “dia do Senhor” e do derramamento do Espírito.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
317	Amós	M	“Carregado”	-790	t	\N	t	\N	\N	\N	f	Vaqueiro de Tecoa que profetizou contra a injustiça em Israel.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
318	Beeri	M	\N	-805	t	\N	t	\N	\N	\N	f	Pai do profeta Oseias.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
319	Oseias (profeta)	M	“Salvação”	-780	t	\N	t	\N	318	\N	f	Profeta de Israel; seu casamento com Gômer simbolizou a infidelidade do povo.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
320	Gômer (esposa de Oseias)	F	\N	-775	t	\N	t	\N	\N	\N	f	Esposa infiel de Oseias, imagem de Israel.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
321	Jezreel	M	“Deus semeia”: anúncio de juízo sobre a casa de Jeú	-755	t	\N	t	\N	319	320	f	Filho de Oseias e Gômer, com nome simbólico.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
322	Lo-Ruama	F	“Não amada”	-752	t	\N	t	\N	319	320	f	Filho de Oseias e Gômer, com nome simbólico.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
323	Lo-Ami	M	“Não meu povo”	-749	t	\N	t	\N	319	320	f	Filho de Oseias e Gômer, com nome simbólico.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
324	Amoz	M	\N	-790	t	\N	t	\N	\N	\N	f	Pai do profeta Isaías.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
325	Isaías	M	“O Senhor é salvação”	-765	t	\N	t	\N	324	\N	f	Profeta de Judá; o profeta mais citado no Novo Testamento.	Isaías recebeu sua visão de chamado “no ano da morte do rei Uzias”, quando viu o Senhor num alto e sublime trono e ouviu os serafins: “Santo, santo, santo”. Profetizou sob Jotão, Acaz e Ezequias.\n\nAnunciou a Acaz o sinal do Emanuel, apoiou Ezequias durante o cerco assírio de Senaqueribe e anunciou a sua cura. Suas profecias sobre o Servo sofredor (Is 53) e o Messias são das mais citadas do Novo Testamento.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
326	Miqueias	M	“Quem é como o Senhor?”	-760	t	\N	t	\N	\N	\N	f	Profeta de Judá que anunciou o nascimento do Messias em Belém.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
327	Naum	M	“Consolo”	-680	t	\N	t	\N	\N	\N	f	Profeta que anunciou a queda de Nínive.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
328	Amarias (filho de Ezequias)	M	\N	-712	t	\N	t	\N	138	\N	f	Trisavô do profeta Sofonias.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
329	Gedalias (avô de Sofonias)	M	\N	-688	t	\N	t	\N	328	\N	f	Avô do profeta Sofonias.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
330	Cusi	M	\N	-670	t	\N	t	\N	329	\N	f	Pai do profeta Sofonias.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
331	Sofonias	M	“O Senhor esconde/protege”	-652	t	\N	t	\N	330	\N	f	Profeta de Judá nos dias de Josias; descendente do rei Ezequias.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
332	Hulda	F	\N	-680	t	\N	t	\N	\N	\N	f	Profetisa consultada pelo rei Josias sobre o livro da Lei.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
333	Habacuque	M	\N	-640	t	\N	t	\N	\N	\N	f	Profeta que questionou Deus sobre o mal; “o justo viverá pela fé”.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
334	Hilquias (pai de Jeremias)	M	\N	-675	t	\N	t	\N	\N	\N	f	Sacerdote de Anatote, pai de Jeremias.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
335	Jeremias	M	“O Senhor exalta”	-645	t	\N	t	\N	334	\N	f	O “profeta chorão”, que testemunhou a queda de Jerusalém.	Chamado ainda jovem, no 13º ano de Josias, Jeremias profetizou durante os últimos reis de Judá, anunciando o juízo pela Babilônia e chamando o povo ao arrependimento. Foi perseguido, preso, lançado numa cisterna e acusado de traição.\n\nViu a destruição de Jerusalém em 586 a.C. e anunciou uma “nova aliança”, escrita no coração. Depois do assassinato de Gedalias, foi levado à força para o Egito, onde a tradição diz que morreu.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
336	Obadias	M	“Servo do Senhor”	-620	t	\N	t	\N	\N	\N	f	Profeta contra Edom; autor do livro mais curto do AT.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
337	Daniel	M	“Deus é meu juiz”	-620	t	\N	t	\N	\N	\N	f	Exilado na Babilônia; intérprete de sonhos e profeta das visões apocalípticas.	Levado à Babilônia ainda jovem em 605 a.C., Daniel foi educado na corte de Nabucodonosor, mas recusou-se a se contaminar com a comida do rei. Interpretou os sonhos de Nabucodonosor e a escrita na parede no banquete de Belsazar.\n\nSob Dario, foi lançado na cova dos leões por continuar orando ao seu Deus e saiu ileso. Recebeu visões sobre os reinos do mundo e as “setenta semanas”. Serviu a reis babilônios e persas por cerca de 70 anos.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
338	Buzi	M	\N	-650	t	\N	t	\N	\N	\N	f	Sacerdote, pai do profeta Ezequiel.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
339	Ezequiel	M	“Deus fortalece”	-623	t	\N	t	\N	338	\N	f	Sacerdote e profeta entre os exilados na Babilônia.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
340	Ageu	M	“Festivo”	-590	t	\N	t	\N	\N	\N	f	Profeta que exortou os repatriados a reconstruir o templo.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
341	Ido	M	\N	-590	t	\N	t	\N	\N	\N	f	Sacerdote que voltou do exílio com Zorobabel; avô do profeta Zacarias.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
342	Baraquias	M	\N	-565	t	\N	t	\N	341	\N	f	Pai do profeta Zacarias.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
343	Zacarias (profeta)	M	“O Senhor se lembra”	-545	t	\N	t	\N	342	\N	f	Profeta e sacerdote do pós-exílio; visões messiânicas.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
344	Malaquias	M	“Meu mensageiro”	-460	t	\N	t	\N	\N	\N	f	Último profeta do Antigo Testamento.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
345	Zacarias (pai de João Batista)	M	“O Senhor se lembra”	-50	t	\N	t	\N	\N	\N	f	Sacerdote do turno de Abias; pai de João Batista.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
346	Isabel	F	“Deus é juramento”	-48	t	\N	t	\N	\N	\N	f	Mãe de João Batista; parente de Maria.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
347	João Batista	M	“O Senhor é gracioso”	-5	t	29	t	\N	345	346	f	Precursor de Jesus; pregou o arrependimento e batizou no Jordão.	Filho de pais idosos, nasceu cerca de seis meses antes de Jesus. Viveu no deserto, vestido de pelos de camelo, e pregava o arrependimento e o batismo para remissão de pecados, anunciando “aquele que vem depois de mim”.\n\nBatizou Jesus no rio Jordão e o apontou como “o Cordeiro de Deus”. Preso por denunciar o casamento de Herodes Antipas com Herodias, foi decapitado a pedido de Salomé.	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
348	Ana (profetisa)	F	\N	-88	t	\N	t	\N	\N	\N	f	Profetisa idosa que reconheceu o menino Jesus no templo.	\N	2026-11-18 00:28:32.407361-03	2026-11-18 00:28:32.407361-03
\.


--
-- Data for Name: referencias; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.referencias (id, pessoa_id, livro, capitulo, versiculo_inicio, capitulo_fim, versiculo_fim, descricao, ordem) FROM stdin;
1	1	GEN	1	26	\N	31	Criação do homem à imagem de Deus	0
2	1	GEN	2	7	\N	25	Formação de Adão e o jardim do Éden	1
3	1	GEN	3	\N	\N	\N	A queda	2
4	1	GEN	5	1	\N	5	Genealogia e morte	3
5	1	LUC	3	38	\N	\N	Na genealogia de Jesus	4
6	1	ROM	5	12	\N	21	Adão e Cristo	5
7	1	1CO	15	45	\N	49	“O último Adão”	6
8	2	GEN	2	18	\N	25	Criação da mulher	0
9	2	GEN	3	1	\N	20	A tentação e a queda	1
10	2	GEN	4	1	\N	2	Nascimento de Caim e Abel	2
11	2	GEN	4	25	\N	\N	Nascimento de Sete	3
12	2	2CO	11	3	\N	\N	O engano da serpente	4
13	2	1TI	2	13	\N	14	\N	5
14	3	GEN	4	1	\N	17	Oferta, homicídio e exílio	0
15	3	HEB	11	4	\N	\N	\N	1
16	3	1JO	3	12	\N	\N	“Não como Caim, que era do maligno”	2
17	3	JUD	1	11	\N	\N	“O caminho de Caim”	3
18	4	GEN	4	2	\N	10	Oferta e morte	0
19	4	MAT	23	35	\N	\N	“Desde o sangue de Abel, o justo”	1
20	4	HEB	11	4	\N	\N	\N	2
21	4	HEB	12	24	\N	\N	O sangue de Jesus fala melhor que o de Abel	3
22	5	GEN	4	17	\N	18	\N	0
23	6	GEN	4	18	\N	\N	\N	0
24	7	GEN	4	18	\N	\N	\N	0
25	8	GEN	4	18	\N	\N	\N	0
26	9	GEN	4	18	\N	24	\N	0
27	10	GEN	4	19	\N	21	\N	0
28	11	GEN	4	19	\N	\N	\N	0
29	11	GEN	4	22	\N	23	\N	1
30	12	GEN	4	20	\N	\N	\N	0
31	13	GEN	4	21	\N	\N	\N	0
32	14	GEN	4	22	\N	\N	\N	0
33	15	GEN	4	22	\N	\N	\N	0
34	16	GEN	4	25	\N	26	\N	0
35	16	GEN	5	3	\N	8	Genealogia	1
36	16	1CR	1	1	\N	\N	\N	2
37	16	LUC	3	38	\N	\N	\N	3
38	17	GEN	4	26	\N	\N	\N	0
39	17	GEN	5	6	\N	11	\N	1
40	17	LUC	3	38	\N	\N	\N	2
41	18	GEN	5	9	\N	14	\N	0
42	18	LUC	3	37	\N	\N	\N	1
43	19	GEN	5	12	\N	17	\N	0
44	19	LUC	3	37	\N	\N	\N	1
45	20	GEN	5	15	\N	20	\N	0
46	20	LUC	3	37	\N	\N	\N	1
47	21	GEN	5	18	\N	24	\N	0
48	21	HEB	11	5	\N	\N	Trasladado pela fé	1
49	21	JUD	1	14	\N	15	Profecia de Enoque	2
50	21	LUC	3	37	\N	\N	\N	3
51	22	GEN	5	21	\N	27	\N	0
52	22	LUC	3	37	\N	\N	\N	1
53	23	GEN	5	25	\N	31	\N	0
54	23	LUC	3	36	\N	\N	\N	1
55	24	GEN	5	28	\N	32	\N	0
56	24	GEN	6	1	9	29	Dilúvio e aliança	1
57	24	MAT	24	37	\N	39	“Como nos dias de Noé”	2
58	24	HEB	11	7	\N	\N	\N	3
59	24	1PE	3	20	\N	\N	\N	4
60	24	2PE	2	5	\N	\N	“Pregador da justiça”	5
61	25	GEN	5	32	\N	\N	\N	0
62	25	GEN	9	18	\N	27	\N	1
63	25	GEN	10	2	\N	5	\N	2
64	26	GEN	9	18	\N	27	\N	0
65	26	GEN	10	21	\N	31	\N	1
66	26	GEN	11	10	\N	11	\N	2
67	26	LUC	3	36	\N	\N	\N	3
68	27	GEN	9	18	\N	27	\N	0
69	27	GEN	10	6	\N	20	\N	1
70	28	GEN	10	2	\N	\N	\N	0
71	28	1CR	1	5	\N	\N	\N	1
72	29	GEN	10	2	\N	\N	\N	0
73	29	1CR	1	5	\N	\N	\N	1
74	30	GEN	10	2	\N	\N	\N	0
75	30	1CR	1	5	\N	\N	\N	1
76	31	GEN	10	2	\N	\N	\N	0
77	31	1CR	1	5	\N	\N	\N	1
78	32	GEN	10	2	\N	\N	\N	0
79	32	1CR	1	5	\N	\N	\N	1
80	33	GEN	10	2	\N	\N	\N	0
81	33	1CR	1	5	\N	\N	\N	1
82	34	GEN	10	2	\N	\N	\N	0
83	34	1CR	1	5	\N	\N	\N	1
84	35	GEN	10	6	\N	8	\N	0
85	36	GEN	10	6	\N	\N	\N	0
86	36	GEN	10	13	\N	14	\N	1
87	37	GEN	10	6	\N	\N	\N	0
88	38	GEN	9	20	\N	27	A maldição de Canaã	0
89	38	GEN	10	15	\N	19	\N	1
90	39	GEN	10	8	\N	12	\N	0
91	39	1CR	1	10	\N	\N	\N	1
92	39	MIQ	5	6	\N	\N	“A terra de Ninrode”	2
93	40	GEN	11	10	\N	13	\N	0
94	40	LUC	3	36	\N	\N	\N	1
95	41	GEN	11	12	\N	15	\N	0
96	41	LUC	3	35	\N	\N	\N	1
97	42	GEN	10	21	\N	\N	\N	0
98	42	GEN	10	24	\N	25	\N	1
99	42	GEN	11	14	\N	17	\N	2
100	42	LUC	3	35	\N	\N	\N	3
101	43	GEN	10	25	\N	\N	\N	0
102	43	GEN	11	16	\N	19	\N	1
103	43	LUC	3	35	\N	\N	\N	2
104	44	GEN	10	25	\N	30	\N	0
105	45	GEN	11	18	\N	21	\N	0
106	45	LUC	3	35	\N	\N	\N	1
107	46	GEN	11	20	\N	23	\N	0
108	46	LUC	3	35	\N	\N	\N	1
109	47	GEN	11	22	\N	25	\N	0
110	47	LUC	3	34	\N	\N	\N	1
111	48	GEN	11	24	\N	32	\N	0
112	48	JOS	24	2	\N	\N	“Serviram a outros deuses”	1
113	48	ATO	7	2	\N	4	\N	2
114	49	GEN	11	26	\N	31	\N	0
115	50	GEN	11	26	\N	29	\N	0
116	50	GEN	22	20	\N	24	\N	1
117	50	GEN	24	15	\N	\N	\N	2
118	51	GEN	11	29	\N	\N	\N	0
119	51	GEN	22	20	\N	23	\N	1
120	52	GEN	13	1	\N	13	Separação de Abraão	0
121	52	GEN	14	12	\N	16	Resgatado por Abraão	1
122	52	GEN	19	\N	\N	\N	Sodoma e Gomorra	2
123	52	LUC	17	28	\N	32	“Lembrai-vos da mulher de Ló”	3
124	52	2PE	2	7	\N	8	“O justo Ló”	4
125	53	GEN	19	36	\N	37	\N	0
126	54	GEN	19	38	\N	\N	\N	0
127	55	GEN	11	26	12	9	Chamado	0
128	55	GEN	15	\N	\N	\N	Aliança e justificação pela fé	1
129	55	GEN	17	\N	\N	\N	Circuncisão e mudança de nome	2
130	55	GEN	22	1	\N	19	O sacrifício de Isaque	3
131	55	GEN	25	7	\N	10	Morte	4
132	55	ROM	4	\N	\N	\N	Justificado pela fé	5
133	55	GAL	3	6	\N	9	\N	6
134	55	HEB	11	8	\N	19	\N	7
135	55	TIA	2	21	\N	23	“Amigo de Deus”	8
136	56	GEN	11	29	\N	31	\N	0
137	56	GEN	12	10	\N	20	\N	1
138	56	GEN	16	\N	\N	\N	Agar	2
139	56	GEN	18	9	\N	15	O riso de Sara	3
140	56	GEN	21	1	\N	7	Nascimento de Isaque	4
141	56	GEN	23	\N	\N	\N	Morte e sepultura	5
142	56	HEB	11	11	\N	\N	\N	6
143	56	1PE	3	6	\N	\N	\N	7
144	57	GEN	16	\N	\N	\N	“O Deus que me vê”	0
145	57	GEN	21	8	\N	21	Despedida	1
146	57	GAL	4	21	\N	31	Alegoria das duas alianças	2
147	58	GEN	16	11	\N	16	\N	0
148	58	GEN	17	18	\N	26	\N	1
149	58	GEN	21	9	\N	21	\N	2
150	58	GEN	25	12	\N	18	\N	3
151	59	GEN	21	1	\N	7	\N	0
152	59	GEN	22	1	\N	19	\N	1
153	59	GEN	24	\N	\N	\N	Casamento com Rebeca	2
154	59	GEN	26	\N	\N	\N	\N	3
155	59	GEN	27	\N	\N	\N	A bênção roubada	4
156	59	GEN	35	28	\N	29	Morte	5
157	59	HEB	11	17	\N	20	\N	6
158	60	GEN	22	22	\N	23	\N	0
159	60	GEN	24	15	\N	\N	\N	1
160	60	GEN	24	50	\N	\N	\N	2
161	61	GEN	24	29	\N	31	\N	0
162	61	GEN	29	1	\N	30	Jacó serve por Raquel	1
163	61	GEN	31	\N	\N	\N	Separação de Jacó	2
164	62	GEN	24	\N	\N	\N	O servo e o poço	0
165	62	GEN	25	20	\N	28	\N	1
166	62	GEN	27	\N	\N	\N	A bênção	2
167	62	ROM	9	10	\N	13	\N	3
168	63	GEN	25	24	\N	34	Venda da primogenitura	0
169	63	GEN	27	\N	\N	\N	\N	1
170	63	GEN	33	\N	\N	\N	Reconciliação com Jacó	2
171	63	GEN	36	\N	\N	\N	\N	3
172	63	HEB	12	16	\N	17	\N	4
173	64	GEN	25	19	\N	34	\N	0
174	64	GEN	27	\N	28	\N	A bênção e Betel	1
175	64	GEN	29	\N	30	\N	Casamentos e filhos	2
176	64	GEN	32	22	\N	32	Luta em Peniel	3
177	64	GEN	46	\N	49	\N	Descida ao Egito e bênçãos	4
178	64	HEB	11	21	\N	\N	\N	5
179	65	GEN	29	16	\N	35	\N	0
180	65	GEN	30	9	\N	21	\N	1
181	65	GEN	49	31	\N	\N	Sepultada em Macpela	2
182	65	RUT	4	11	\N	\N	\N	3
183	66	GEN	29	9	\N	30	\N	0
184	66	GEN	30	22	\N	24	\N	1
185	66	GEN	35	16	\N	20	Morte no parto de Benjamim	2
186	66	JER	31	15	\N	\N	\N	3
187	66	MAT	2	18	\N	\N	“Raquel chora por seus filhos”	4
188	67	GEN	29	29	\N	\N	\N	0
189	67	GEN	30	3	\N	8	\N	1
190	68	GEN	29	24	\N	\N	\N	0
191	68	GEN	30	9	\N	13	\N	1
192	69	GEN	29	32	\N	\N	\N	0
193	69	GEN	49	\N	\N	\N	Bênção de Jacó	1
194	70	GEN	29	33	\N	\N	\N	0
195	70	GEN	49	\N	\N	\N	Bênção de Jacó	1
196	71	GEN	30	6	\N	\N	\N	0
197	71	GEN	49	\N	\N	\N	Bênção de Jacó	1
198	72	GEN	30	11	\N	\N	\N	0
199	72	GEN	49	\N	\N	\N	Bênção de Jacó	1
200	73	GEN	30	8	\N	\N	\N	0
201	73	GEN	49	\N	\N	\N	Bênção de Jacó	1
202	74	GEN	30	13	\N	\N	\N	0
203	74	GEN	49	\N	\N	\N	Bênção de Jacó	1
204	75	GEN	30	18	\N	\N	\N	0
205	75	GEN	49	\N	\N	\N	Bênção de Jacó	1
206	76	GEN	30	20	\N	\N	\N	0
207	76	GEN	49	\N	\N	\N	Bênção de Jacó	1
208	77	GEN	29	34	\N	\N	\N	0
209	77	GEN	34	25	\N	31	Vingança de Siquém	1
210	77	EXO	6	16	\N	\N	\N	2
211	77	GEN	49	5	\N	7	\N	3
212	78	GEN	29	35	\N	\N	\N	0
213	78	GEN	37	26	\N	27	\N	1
214	78	GEN	38	\N	\N	\N	Judá e Tamar	2
215	78	GEN	44	18	\N	34	Intercede por Benjamim	3
216	78	GEN	49	8	\N	12	“O cetro não se arredará”	4
217	78	APO	5	5	\N	\N	“O Leão da tribo de Judá”	5
218	79	GEN	30	21	\N	\N	\N	0
219	79	GEN	34	\N	\N	\N	\N	1
220	80	GEN	37	\N	\N	\N	Sonhos e venda	0
221	80	GEN	39	\N	41	\N	Potifar, prisão e governo	1
222	80	GEN	42	\N	45	\N	Os irmãos no Egito	2
223	80	GEN	50	15	\N	26	Perdão e morte	3
224	80	HEB	11	22	\N	\N	\N	4
225	80	ATO	7	9	\N	16	\N	5
226	81	GEN	35	16	\N	18	\N	0
227	81	GEN	42	\N	45	\N	\N	1
228	81	GEN	49	27	\N	\N	\N	2
229	82	GEN	41	45	\N	50	\N	0
230	83	GEN	41	51	\N	\N	\N	0
231	83	GEN	48	\N	\N	\N	Jacó abençoa os filhos de José	1
232	84	GEN	41	52	\N	\N	\N	0
233	84	GEN	48	13	\N	20	\N	1
234	85	GEN	38	2	\N	5	\N	0
235	85	GEN	38	12	\N	\N	\N	1
236	85	1CR	2	3	\N	\N	\N	2
237	86	GEN	38	3	\N	7	\N	0
238	87	GEN	38	4	\N	\N	\N	0
239	87	GEN	38	8	\N	10	\N	1
240	88	GEN	38	5	\N	\N	\N	0
241	88	GEN	38	11	\N	14	\N	1
242	89	GEN	38	\N	\N	\N	\N	0
243	89	RUT	4	12	\N	\N	\N	1
244	89	MAT	1	3	\N	\N	Na genealogia de Jesus	2
245	90	GEN	38	27	\N	30	\N	0
246	90	RUT	4	18	\N	\N	\N	1
247	90	MAT	1	3	\N	\N	\N	2
248	91	GEN	38	27	\N	30	\N	0
249	92	GEN	46	12	\N	\N	\N	0
250	92	RUT	4	18	\N	19	\N	1
251	92	1CR	2	5	\N	\N	\N	2
252	92	MAT	1	3	\N	\N	\N	3
253	93	RUT	4	19	\N	\N	\N	0
254	93	1CR	2	9	\N	10	\N	1
255	93	MAT	1	3	\N	4	\N	2
256	94	RUT	4	19	\N	20	\N	0
257	94	EXO	6	23	\N	\N	\N	1
258	94	MAT	1	4	\N	\N	\N	2
259	95	NUM	1	7	\N	\N	\N	0
260	95	NUM	7	12	\N	17	Primeira oferta do altar	1
261	95	RUT	4	20	\N	\N	\N	2
262	95	MAT	1	4	\N	\N	\N	3
263	96	RUT	4	20	\N	21	\N	0
264	96	MAT	1	4	\N	5	\N	1
265	97	JOS	2	\N	\N	\N	Os espias	0
266	97	JOS	6	22	\N	25	Poupada na queda de Jericó	1
267	97	MAT	1	5	\N	\N	\N	2
268	97	HEB	11	31	\N	\N	\N	3
269	97	TIA	2	25	\N	\N	\N	4
270	98	RUT	2	\N	\N	\N	Rute nos campos de Boaz	0
271	98	RUT	3	\N	\N	\N	\N	1
272	98	RUT	4	\N	\N	\N	O resgate	2
273	98	MAT	1	5	\N	\N	\N	3
274	99	RUT	1	1	\N	3	\N	0
275	100	RUT	1	\N	\N	\N	\N	0
276	100	RUT	4	14	\N	17	\N	1
277	101	RUT	1	2	\N	5	\N	0
278	101	RUT	4	10	\N	\N	\N	1
279	102	RUT	1	2	\N	5	\N	0
280	103	RUT	1	16	\N	17	“Aonde quer que fores, irei eu”	0
281	103	RUT	2	\N	4	\N	\N	1
282	103	MAT	1	5	\N	\N	\N	2
283	104	RUT	4	13	\N	17	\N	0
284	104	RUT	4	21	\N	22	\N	1
285	104	MAT	1	5	\N	\N	\N	2
286	105	RUT	4	22	\N	\N	\N	0
287	105	1SA	16	\N	\N	\N	Unção de Davi	1
288	105	ISA	11	1	\N	\N	“Um rebento do tronco de Jessé”	2
289	105	MAT	1	5	\N	6	\N	3
290	106	1SA	9	1	\N	3	\N	0
291	107	1SA	9	\N	10	\N	Unção	0
292	107	1SA	13	8	\N	14	\N	1
293	107	1SA	15	\N	\N	\N	Rejeição	2
294	107	1SA	18	\N	26	\N	Perseguição a Davi	3
295	107	1SA	28	\N	\N	\N	A médium de En-Dor	4
296	107	1SA	31	\N	\N	\N	Morte em Gilboa	5
297	107	ATO	13	21	\N	\N	\N	6
298	108	1SA	14	\N	\N	\N	Vitória em Micmás	0
299	108	1SA	18	1	\N	4	Aliança com Davi	1
300	108	1SA	20	\N	\N	\N	\N	2
301	108	2SA	1	17	\N	27	Lamento de Davi	3
302	109	2SA	4	4	\N	\N	\N	0
303	109	2SA	9	\N	\N	\N	À mesa do rei	1
304	110	1SA	18	20	\N	28	\N	0
305	110	1SA	19	11	\N	17	Salva Davi	1
306	110	2SA	6	16	\N	23	\N	2
307	111	1SA	16	\N	\N	\N	Unção	0
308	111	1SA	17	\N	\N	\N	Davi e Golias	1
309	111	2SA	5	\N	\N	\N	Rei sobre todo Israel	2
310	111	2SA	7	\N	\N	\N	A aliança davídica	3
311	111	2SA	11	\N	12	\N	Bate-Seba e Natã	4
312	111	1RE	2	10	\N	12	Morte	5
313	111	SAL	51	\N	\N	\N	Salmo de arrependimento	6
314	111	ATO	13	22	\N	\N	\N	7
315	111	MAT	1	1	\N	\N	\N	8
316	112	1SA	25	43	\N	\N	\N	0
317	112	2SA	3	2	\N	\N	\N	1
318	113	1SA	25	\N	\N	\N	Abigail e Nabal	0
319	113	2SA	3	3	\N	\N	\N	1
320	114	2SA	3	3	\N	\N	\N	0
321	115	2SA	3	4	\N	\N	\N	0
322	116	2SA	11	\N	12	\N	\N	0
323	116	1RE	1	11	\N	31	Salomão como sucessor	1
324	116	1RE	2	13	\N	25	\N	2
325	116	MAT	1	6	\N	\N	“A que fora mulher de Urias”	3
326	117	2SA	11	\N	\N	\N	\N	0
327	117	2SA	23	39	\N	\N	Entre os valentes de Davi	1
328	118	2SA	3	2	\N	\N	\N	0
329	118	2SA	13	\N	\N	\N	\N	1
330	119	2SA	3	3	\N	\N	\N	0
331	119	1CR	3	1	\N	\N	\N	1
332	120	2SA	13	\N	18	\N	\N	0
333	120	2SA	18	33	\N	\N	“Meu filho Absalão!”	1
334	121	2SA	13	\N	\N	\N	\N	0
335	122	2SA	3	4	\N	\N	\N	0
336	122	1RE	1	\N	2	\N	\N	1
337	123	2SA	12	24	\N	25	\N	0
338	123	1RE	3	\N	\N	\N	O pedido de sabedoria	1
339	123	1RE	6	\N	8	\N	O templo	2
340	123	1RE	10	\N	\N	\N	A rainha de Sabá	3
341	123	1RE	11	\N	\N	\N	Apostasia e morte	4
342	123	MAT	6	29	\N	\N	\N	5
343	123	MAT	12	42	\N	\N	\N	6
344	124	2SA	5	14	\N	\N	\N	0
345	124	1CR	3	5	\N	\N	\N	1
346	124	LUC	3	31	\N	\N	\N	2
347	125	1RE	14	21	\N	\N	\N	0
348	125	1RE	14	31	\N	\N	\N	1
349	126	1RE	12	1	\N	24	A divisão do reino	0
350	126	1RE	14	21	\N	31	\N	1
351	126	2CR	10	\N	12	\N	\N	2
352	127	1RE	15	2	\N	\N	\N	0
353	127	2CR	11	20	\N	22	\N	1
354	128	MAT	1	7	\N	\N	\N	0
355	128	1RE	15	1	\N	8	\N	1
356	128	2CR	13	\N	\N	\N	Discurso no monte Zemaraim	2
357	129	MAT	1	7	\N	8	\N	0
358	129	1RE	15	9	\N	24	\N	1
359	129	2CR	14	\N	16	\N	\N	2
360	130	MAT	1	8	\N	\N	\N	0
361	130	1RE	22	41	\N	50	\N	1
362	130	2CR	17	\N	20	\N	\N	2
363	131	MAT	1	8	\N	\N	\N	0
364	131	2RE	8	16	\N	24	\N	1
365	131	2CR	21	\N	\N	\N	\N	2
366	132	2RE	8	25	\N	29	\N	0
367	132	2RE	9	27	\N	29	\N	1
368	132	2CR	22	1	\N	9	\N	2
369	133	2RE	11	\N	12	\N	\N	0
370	133	2CR	22	10	24	27	\N	1
371	134	2RE	14	1	\N	20	\N	0
372	134	2CR	25	\N	\N	\N	\N	1
373	135	MAT	1	8	\N	9	\N	0
374	135	2RE	15	1	\N	7	\N	1
375	135	2CR	26	\N	\N	\N	\N	2
376	135	ISA	6	1	\N	\N	“No ano da morte do rei Uzias…”	3
377	136	MAT	1	9	\N	\N	\N	0
378	136	2RE	15	32	\N	38	\N	1
379	136	2CR	27	\N	\N	\N	\N	2
380	137	MAT	1	9	\N	\N	\N	0
381	137	2RE	16	\N	\N	\N	\N	1
382	137	2CR	28	\N	\N	\N	\N	2
383	137	ISA	7	1	\N	14	O sinal do Emanuel	3
384	138	MAT	1	9	\N	10	\N	0
385	138	2RE	18	\N	20	\N	\N	1
386	138	2CR	29	\N	32	\N	\N	2
387	138	ISA	36	\N	39	\N	\N	3
388	139	MAT	1	10	\N	\N	\N	0
389	139	2RE	21	1	\N	18	\N	1
390	139	2CR	33	1	\N	20	\N	2
391	140	MAT	1	10	\N	\N	\N	0
392	140	2RE	21	19	\N	26	\N	1
393	140	2CR	33	21	\N	25	\N	2
394	141	MAT	1	10	\N	11	\N	0
395	141	2RE	22	\N	23	\N	\N	1
396	141	2CR	34	\N	35	\N	\N	2
397	142	2RE	23	34	24	6	\N	0
398	142	2CR	36	4	\N	8	\N	1
399	142	JER	36	\N	\N	\N	Queima o rolo de Jeremias	2
400	143	MAT	1	11	\N	12	\N	0
401	143	2RE	24	8	\N	17	\N	1
402	143	2RE	25	27	\N	30	Libertado na Babilônia	2
403	143	JER	22	24	\N	30	\N	3
404	143	1CR	3	16	\N	17	\N	4
405	144	MAT	1	12	\N	\N	\N	0
406	144	1CR	3	17	\N	\N	\N	1
407	144	ESD	3	2	\N	\N	\N	2
408	144	LUC	3	27	\N	\N	\N	3
409	145	MAT	1	12	\N	13	\N	0
410	145	ESD	3	8	\N	13	Fundamentos do templo	1
411	145	AGE	2	20	\N	23	“Como anel de selar”	2
412	145	ZAC	4	6	\N	10	\N	3
413	145	LUC	3	27	\N	\N	\N	4
414	146	MAT	1	13	\N	\N	\N	0
415	147	MAT	1	13	\N	\N	\N	0
416	148	MAT	1	13	\N	14	\N	0
417	149	MAT	1	14	\N	\N	\N	0
418	150	MAT	1	14	\N	\N	\N	0
419	151	MAT	1	14	\N	15	\N	0
420	152	MAT	1	15	\N	\N	\N	0
421	153	MAT	1	15	\N	\N	\N	0
422	154	MAT	1	15	\N	16	\N	0
423	155	MAT	1	16	\N	25	\N	0
424	155	MAT	2	13	\N	23	Fuga para o Egito	1
425	155	LUC	1	27	\N	\N	\N	2
426	155	LUC	2	1	\N	7	\N	3
427	155	LUC	2	41	\N	52	Jesus aos 12 anos no templo	4
428	155	MAT	13	55	\N	\N	“O filho do carpinteiro”	5
429	156	MAT	1	16	\N	25	\N	0
430	156	LUC	1	26	\N	38	A anunciação	1
431	156	LUC	1	39	\N	56	Visita a Isabel e o Magnificat	2
432	156	LUC	2	\N	\N	\N	\N	3
433	156	JOA	2	1	\N	11	Bodas de Caná	4
434	156	JOA	19	25	\N	27	Ao pé da cruz	5
435	156	ATO	1	14	\N	\N	\N	6
436	157	MAT	1	1	\N	17	Genealogia segundo Mateus	0
437	157	MAT	1	18	\N	25	Nascimento	1
438	157	MAT	2	\N	\N	\N	Os magos e a fuga para o Egito	2
439	157	LUC	2	1	\N	20	Nascimento em Belém	3
440	157	LUC	3	23	\N	38	Genealogia segundo Lucas	4
441	157	JOA	1	1	\N	14	O Verbo se fez carne	5
442	157	MAT	27	\N	28	\N	Crucificação e ressurreição	6
443	157	ROM	1	3	\N	4	Da descendência de Davi segundo a carne	7
444	157	1CO	15	3	\N	8	\N	8
445	158	LUC	3	31	\N	\N	\N	0
446	159	LUC	3	31	\N	\N	\N	0
447	160	LUC	3	31	\N	\N	\N	0
448	161	LUC	3	30	\N	\N	\N	0
449	162	LUC	3	30	\N	\N	\N	0
450	163	LUC	3	30	\N	\N	\N	0
451	164	LUC	3	30	\N	\N	\N	0
452	165	LUC	3	30	\N	\N	\N	0
453	166	LUC	3	29	\N	\N	\N	0
454	167	LUC	3	29	\N	\N	\N	0
455	168	LUC	3	29	\N	\N	\N	0
456	169	LUC	3	29	\N	\N	\N	0
457	170	LUC	3	29	\N	\N	\N	0
458	171	LUC	3	28	\N	\N	\N	0
459	172	LUC	3	28	\N	\N	\N	0
460	173	LUC	3	28	\N	\N	\N	0
461	174	LUC	3	28	\N	\N	\N	0
462	175	LUC	3	28	\N	\N	\N	0
463	176	LUC	3	27	\N	\N	\N	0
464	177	LUC	3	27	\N	\N	\N	0
465	178	LUC	3	27	\N	\N	\N	0
466	179	LUC	3	26	\N	\N	\N	0
467	180	LUC	3	26	\N	\N	\N	0
468	181	LUC	3	26	\N	\N	\N	0
469	182	LUC	3	26	\N	\N	\N	0
470	183	LUC	3	26	\N	\N	\N	0
471	184	LUC	3	25	\N	\N	\N	0
472	185	LUC	3	25	\N	\N	\N	0
473	186	LUC	3	25	\N	\N	\N	0
474	187	LUC	3	25	\N	\N	\N	0
475	188	LUC	3	25	\N	\N	\N	0
476	189	LUC	3	24	\N	\N	\N	0
477	190	LUC	3	24	\N	\N	\N	0
478	191	LUC	3	24	\N	\N	\N	0
479	192	LUC	3	24	\N	\N	\N	0
480	193	LUC	3	24	\N	\N	\N	0
481	194	LUC	3	23	\N	\N	\N	0
482	195	2RE	23	31	\N	\N	\N	0
483	195	2RE	24	18	\N	\N	\N	1
484	196	2RE	23	30	\N	34	\N	0
485	196	2CR	36	1	\N	4	\N	1
486	196	JER	22	10	\N	12	\N	2
487	197	2RE	24	17	25	7	\N	0
488	197	2CR	36	10	\N	21	\N	1
489	197	JER	37	\N	39	\N	\N	2
490	197	JER	52	1	\N	11	\N	3
491	198	1RE	11	26	\N	\N	\N	0
492	199	1RE	11	26	\N	\N	\N	0
493	200	1RE	11	26	\N	40	A capa rasgada em 12 pedaços	0
494	200	1RE	12	1	\N	20	A divisão do reino	1
495	200	1RE	12	25	\N	33	Os bezerros de Betel e Dã	2
496	200	1RE	13	\N	\N	\N	O homem de Deus de Judá	3
497	200	1RE	14	1	\N	20	\N	4
498	201	1RE	14	20	\N	\N	\N	0
499	201	1RE	15	25	\N	31	\N	1
500	202	1RE	15	27	\N	\N	\N	0
501	203	1RE	15	16	\N	22	\N	0
502	203	1RE	15	27	16	7	\N	1
503	203	2CR	16	1	\N	6	\N	2
504	204	1RE	16	6	\N	14	\N	0
505	205	1RE	16	9	\N	20	\N	0
506	205	2RE	9	31	\N	\N	\N	1
507	206	1RE	16	16	\N	28	\N	0
508	206	MIQ	6	16	\N	\N	“Os estatutos de Onri”	1
509	207	1RE	16	29	\N	34	\N	0
510	207	1RE	18	\N	\N	\N	Elias no monte Carmelo	1
511	207	1RE	20	\N	\N	\N	\N	2
512	207	1RE	21	\N	\N	\N	A vinha de Nabote	3
513	207	1RE	22	1	\N	40	Morte em Ramote-Gileade	4
514	208	1RE	16	31	\N	\N	\N	0
515	208	1RE	18	4	\N	\N	\N	1
516	208	1RE	19	1	\N	3	Ameaça a Elias	2
517	208	1RE	21	5	\N	16	A morte de Nabote	3
518	208	2RE	9	30	\N	37	Sua morte	4
519	208	APO	2	20	\N	\N	\N	5
520	209	1RE	22	51	\N	53	\N	0
521	209	2RE	1	\N	\N	\N	\N	1
522	210	2RE	3	\N	\N	\N	Guerra contra Moabe	0
523	210	2RE	6	\N	7	\N	\N	1
524	210	2RE	9	14	\N	26	Morto por Jeú	2
525	211	2RE	8	18	\N	\N	\N	0
526	211	2RE	8	26	\N	\N	\N	1
527	211	2RE	11	\N	\N	\N	Usurpação e morte	2
528	211	2CR	22	10	23	21	\N	3
529	212	2RE	9	2	\N	\N	\N	0
530	212	1RE	19	16	\N	\N	\N	1
531	213	2RE	9	2	\N	\N	\N	0
532	213	2RE	9	14	\N	\N	\N	1
533	214	1RE	19	16	\N	\N	\N	0
534	214	2RE	9	\N	10	\N	\N	1
535	214	OSE	1	4	\N	\N	\N	2
536	215	2RE	13	1	\N	9	\N	0
537	216	2RE	13	10	\N	25	\N	0
538	216	2RE	14	8	\N	16	Vence Amazias de Judá	1
539	217	2RE	14	23	\N	29	\N	0
540	217	AMO	7	9	\N	11	\N	1
541	217	OSE	1	1	\N	\N	\N	2
542	218	2RE	14	29	\N	\N	\N	0
543	218	2RE	15	8	\N	12	\N	1
544	219	2RE	15	10	\N	\N	\N	0
545	220	2RE	15	10	\N	15	\N	0
546	221	2RE	15	14	\N	\N	\N	0
547	222	2RE	15	14	\N	22	\N	0
548	223	2RE	15	22	\N	26	\N	0
549	224	2RE	15	25	\N	\N	\N	0
550	224	ISA	7	4	\N	9	\N	1
551	225	2RE	15	25	\N	31	\N	0
552	225	2RE	16	5	\N	\N	\N	1
553	225	ISA	7	1	\N	9	A guerra siro-efraimita	2
554	226	2RE	15	30	\N	\N	\N	0
555	227	2RE	15	30	\N	\N	\N	0
556	227	2RE	17	1	\N	6	A queda de Samaria	1
557	227	2RE	17	7	\N	23	Por que Israel caiu	2
558	228	GEN	46	11	\N	\N	\N	0
559	228	EXO	6	16	\N	18	\N	1
560	229	EXO	6	18	\N	20	\N	0
561	229	NUM	26	58	\N	59	\N	1
562	230	EXO	2	1	\N	10	\N	0
563	230	EXO	6	20	\N	\N	\N	1
564	230	NUM	26	59	\N	\N	\N	2
565	230	HEB	11	23	\N	\N	\N	3
566	231	EXO	2	4	\N	8	\N	0
567	231	EXO	15	20	\N	21	Cântico após o mar	1
568	231	NUM	12	\N	\N	\N	Repreendida com lepra	2
569	231	NUM	20	1	\N	\N	Morte em Cades	3
570	231	MIQ	6	4	\N	\N	\N	4
571	232	EXO	4	14	\N	16	\N	0
572	232	EXO	7	7	\N	\N	\N	1
573	232	EXO	28	\N	29	\N	Vestes e consagração	2
574	232	EXO	32	\N	\N	\N	O bezerro de ouro	3
575	232	NUM	17	\N	\N	\N	A vara que floresceu	4
576	232	NUM	20	22	\N	29	Morte no monte Hor	5
577	232	HEB	5	4	\N	\N	\N	6
578	233	EXO	2	\N	\N	\N	Nascimento e fuga	0
579	233	EXO	3	\N	4	\N	A sarça ardente	1
580	233	EXO	7	\N	12	\N	As pragas e a Páscoa	2
581	233	EXO	14	\N	\N	\N	O mar Vermelho	3
582	233	EXO	19	\N	20	\N	O Sinai e os Dez Mandamentos	4
583	233	DEU	34	\N	\N	\N	Morte no Nebo	5
584	233	ATO	7	20	\N	44	\N	6
585	233	HEB	11	23	\N	29	\N	7
586	234	EXO	2	16	\N	21	\N	0
587	234	EXO	18	\N	\N	\N	O conselho a Moisés	1
588	235	EXO	2	21	\N	22	\N	0
589	235	EXO	4	24	\N	26	\N	1
590	235	EXO	18	2	\N	6	\N	2
591	236	EXO	2	22	\N	\N	\N	0
592	236	EXO	18	3	\N	\N	\N	1
593	237	EXO	18	4	\N	\N	\N	0
594	238	EXO	6	23	\N	\N	\N	0
595	239	EXO	6	23	\N	\N	\N	0
596	239	LEV	10	1	\N	2	\N	1
597	240	EXO	6	23	\N	\N	\N	0
598	240	LEV	10	1	\N	2	\N	1
599	241	EXO	6	23	\N	\N	\N	0
600	241	NUM	20	25	\N	28	\N	1
601	241	JOS	14	1	\N	\N	\N	2
602	242	EXO	6	23	\N	\N	\N	0
603	242	EXO	38	21	\N	\N	\N	1
604	243	EXO	6	25	\N	\N	\N	0
605	243	NUM	25	7	\N	13	\N	1
606	243	SAL	106	30	\N	31	\N	2
607	244	MAT	13	55	\N	\N	\N	0
608	244	MAR	6	3	\N	\N	\N	1
609	244	JOA	7	3	\N	5	Os irmãos não criam nele	2
610	244	1CO	15	7	\N	\N	Jesus lhe aparece	3
611	244	GAL	1	19	\N	\N	“Tiago, irmão do Senhor”	4
612	244	ATO	12	17	\N	\N	\N	5
613	244	ATO	15	13	\N	21	O concílio de Jerusalém	6
614	244	ATO	21	18	\N	\N	\N	7
615	244	GAL	2	9	\N	\N	Uma das “colunas”	8
616	244	TIA	1	1	\N	\N	\N	9
617	245	MAT	13	55	\N	\N	\N	0
618	245	MAR	6	3	\N	\N	\N	1
619	246	MAT	13	55	\N	\N	\N	0
620	246	MAR	6	3	\N	\N	\N	1
621	247	MAT	13	55	\N	\N	\N	0
622	247	MAR	6	3	\N	\N	\N	1
623	247	JUD	1	1	\N	\N	“Judas, servo de Jesus Cristo e irmão de Tiago”	2
624	247	1CO	9	5	\N	\N	\N	3
625	248	MAT	13	56	\N	\N	\N	0
626	248	MAR	6	3	\N	\N	\N	1
627	249	GEN	5	4	\N	\N	\N	0
628	250	GEN	5	7	\N	\N	\N	0
629	251	GEN	5	10	\N	\N	\N	0
630	252	GEN	5	13	\N	\N	\N	0
631	253	GEN	5	16	\N	\N	\N	0
632	254	GEN	5	19	\N	\N	\N	0
633	255	GEN	5	22	\N	\N	\N	0
634	256	GEN	5	26	\N	\N	\N	0
635	257	GEN	5	30	\N	\N	\N	0
636	258	GEN	11	11	\N	\N	\N	0
637	259	GEN	11	13	\N	\N	\N	0
638	260	GEN	11	15	\N	\N	\N	0
639	261	GEN	11	17	\N	\N	\N	0
640	262	GEN	11	19	\N	\N	\N	0
641	263	GEN	11	21	\N	\N	\N	0
642	264	GEN	11	23	\N	\N	\N	0
643	265	GEN	11	25	\N	\N	\N	0
644	266	GEN	37	35	\N	\N	\N	0
645	266	GEN	46	7	\N	\N	\N	1
646	266	GEN	46	15	\N	\N	\N	2
647	267	GEN	19	8	\N	\N	\N	0
648	267	GEN	19	15	\N	16	\N	1
649	267	GEN	19	30	\N	37	\N	2
650	268	GEN	19	8	\N	\N	\N	0
651	268	GEN	19	15	\N	16	\N	1
652	268	GEN	19	30	\N	38	\N	2
653	269	1SA	2	21	\N	\N	\N	0
654	270	2SA	5	13	\N	\N	\N	0
655	270	1CR	14	3	\N	\N	\N	1
656	270	1CR	3	9	\N	\N	\N	2
657	271	2CR	11	21	\N	\N	\N	0
658	272	2CR	13	21	\N	\N	\N	0
659	273	2RE	25	7	\N	\N	\N	0
660	273	JER	41	10	\N	\N	\N	1
661	273	JER	43	6	\N	\N	\N	2
662	274	MAT	16	17	\N	\N	“Simão Barjonas”	0
663	274	JOA	1	42	\N	\N	“Simão, filho de João”	1
664	274	JOA	21	15	\N	17	\N	2
665	275	MAT	4	18	\N	20	O chamado	0
666	275	JOA	1	40	\N	42	“Tu serás chamado Cefas”	1
667	275	MAT	16	13	\N	19	A confissão	2
668	275	MAT	26	69	\N	75	A negação	3
669	275	JOA	21	15	\N	19	“Tu me amas?”	4
670	275	ATO	2	14	\N	41	O sermão de Pentecostes	5
671	275	ATO	10	\N	\N	\N	Cornélio	6
672	275	GAL	2	11	\N	14	\N	7
673	275	1PE	1	1	\N	\N	\N	8
674	276	MAT	8	14	\N	15	\N	0
675	276	MAR	1	29	\N	31	\N	1
676	276	LUC	4	38	\N	39	\N	2
677	277	1CO	9	5	\N	\N	“Não temos direito de levar conosco uma esposa crente…?”	0
678	277	MAT	8	14	\N	\N	\N	1
679	278	JOA	1	35	\N	42	Leva Pedro a Jesus	0
680	278	MAT	4	18	\N	20	\N	1
681	278	JOA	6	8	\N	9	O menino dos pães	2
682	278	JOA	12	20	\N	22	\N	3
683	279	MAT	4	21	\N	22	\N	0
684	279	MAR	1	19	\N	20	\N	1
685	280	MAT	20	20	\N	23	O pedido pelos filhos	0
686	280	MAT	27	56	\N	\N	\N	1
687	280	MAR	15	40	\N	\N	\N	2
688	280	MAR	16	1	\N	2	No sepulcro	3
689	281	MAT	4	21	\N	22	\N	0
690	281	MAR	3	17	\N	\N	Boanerges	1
691	281	MAR	5	37	\N	\N	\N	2
692	281	MAT	17	1	\N	\N	Na transfiguração	3
693	281	MAR	14	33	\N	\N	No Getsêmani	4
694	281	ATO	12	1	\N	2	Morte	5
695	282	MAR	1	19	\N	20	\N	0
696	282	LUC	9	54	\N	\N	“Filhos do trovão”	1
697	282	JOA	13	23	\N	\N	O discípulo amado	2
698	282	JOA	19	26	\N	27	Recebe Maria	3
699	282	JOA	21	20	\N	24	\N	4
700	282	ATO	3	1	\N	11	\N	5
701	282	GAL	2	9	\N	\N	\N	6
702	282	APO	1	9	\N	\N	Em Patmos	7
703	283	JOA	1	43	\N	46	\N	0
704	283	JOA	6	5	\N	7	\N	1
705	283	JOA	12	21	\N	22	\N	2
706	283	JOA	14	8	\N	9	“Mostra-nos o Pai”	3
707	283	MAT	10	3	\N	\N	\N	4
708	284	MAT	10	3	\N	\N	\N	0
709	284	ATO	1	13	\N	\N	\N	1
710	284	JOA	1	45	\N	51	Natanael	2
711	284	JOA	21	2	\N	\N	\N	3
712	285	JOA	11	16	\N	\N	“Vamos também nós, para morrermos com ele”	0
713	285	JOA	14	5	\N	\N	\N	1
714	285	JOA	20	24	\N	29	A dúvida e a confissão	2
715	285	JOA	21	2	\N	\N	\N	3
716	286	MAR	2	14	\N	\N	\N	0
717	287	MAT	9	9	\N	13	O chamado	0
718	287	MAR	2	14	\N	17	\N	1
719	287	LUC	5	27	\N	32	O banquete na casa de Levi	2
720	287	MAT	10	3	\N	\N	\N	3
721	288	MAT	10	3	\N	\N	\N	0
722	288	MAR	3	18	\N	\N	\N	1
723	289	MAT	10	3	\N	\N	\N	0
724	289	MAR	3	18	\N	\N	\N	1
725	289	ATO	1	13	\N	\N	\N	2
726	289	MAR	15	40	\N	\N	“Tiago, o menor”	3
727	290	LUC	6	16	\N	\N	\N	0
728	290	ATO	1	13	\N	\N	\N	1
729	291	MAT	10	3	\N	\N	Tadeu	0
730	291	MAR	3	18	\N	\N	\N	1
731	291	LUC	6	16	\N	\N	“Judas, filho de Tiago”	2
732	291	ATO	1	13	\N	\N	\N	3
733	291	JOA	14	22	\N	\N	\N	4
734	292	MAT	10	4	\N	\N	\N	0
735	292	LUC	6	15	\N	\N	\N	1
736	292	ATO	1	13	\N	\N	\N	2
737	293	JOA	6	71	\N	\N	\N	0
738	293	JOA	13	2	\N	\N	\N	1
739	293	JOA	13	26	\N	\N	\N	2
740	294	MAT	26	14	\N	16	O acordo	0
741	294	MAT	26	47	\N	50	O beijo	1
742	294	MAT	27	3	\N	10	Remorso e morte	2
743	294	JOA	12	4	\N	6	\N	3
744	294	JOA	13	21	\N	30	\N	4
745	294	ATO	1	16	\N	20	\N	5
746	295	ATO	1	21	\N	26	\N	0
747	296	ATO	23	6	\N	\N	“Eu sou fariseu, filho de fariseus”	0
748	296	ATO	22	25	\N	28	Cidadão romano de nascimento	1
749	297	ATO	7	58	8	3	Perseguidor	0
750	297	ATO	9	1	\N	22	A conversão	1
751	297	ATO	13	\N	14	\N	Primeira viagem	2
752	297	ATO	22	3	\N	\N	Aos pés de Gamaliel	3
753	297	ATO	23	16	\N	\N	O sobrinho	4
754	297	ROM	1	1	\N	\N	\N	5
755	297	2CO	11	22	\N	33	Seus sofrimentos	6
756	297	FIL	3	4	\N	6	“Da tribo de Benjamim”	7
757	297	2TI	4	6	\N	8	\N	8
758	298	ATO	23	16	\N	\N	\N	0
759	299	ATO	23	16	\N	22	\N	0
760	300	ATO	4	36	\N	37	\N	0
761	300	ATO	9	27	\N	\N	Apresenta Paulo aos apóstolos	1
762	300	ATO	11	22	\N	26	Em Antioquia	2
763	300	ATO	13	1	\N	3	\N	3
764	300	ATO	14	14	\N	\N	\N	4
765	300	ATO	15	36	\N	40	Separação de Paulo	5
766	300	COL	4	10	\N	\N	\N	6
767	301	ATO	12	12	\N	17	\N	0
768	302	ATO	12	12	\N	\N	\N	0
769	302	ATO	12	25	\N	\N	\N	1
770	302	ATO	13	13	\N	\N	\N	2
771	302	ATO	15	37	\N	39	\N	3
772	302	COL	4	10	\N	\N	\N	4
773	302	2TI	4	11	\N	\N	\N	5
774	302	1PE	5	13	\N	\N	“Marcos, meu filho”	6
775	303	JUI	4	\N	\N	\N	A vitória sobre Sísera	0
776	303	JUI	5	\N	\N	\N	O Cântico de Débora	1
777	303	HEB	11	32	\N	\N	\N	2
778	304	1SA	1	1	\N	8	\N	0
779	304	1SA	2	11	\N	\N	\N	1
780	304	1SA	2	20	\N	\N	\N	2
781	305	1SA	1	\N	\N	\N	Oração em Siló	0
782	305	1SA	2	1	\N	10	O Cântico de Ana	1
783	305	1SA	2	18	\N	21	\N	2
784	306	1SA	1	20	\N	28	Nascimento	0
785	306	1SA	3	\N	\N	\N	O chamado de Samuel	1
786	306	1SA	7	\N	\N	\N	Juiz em Mispá	2
787	306	1SA	8	\N	\N	\N	O povo pede um rei	3
788	306	1SA	10	1	\N	\N	Unção de Saul	4
789	306	1SA	16	1	\N	13	Unção de Davi	5
790	306	1SA	25	1	\N	\N	Morte	6
791	306	ATO	3	24	\N	\N	\N	7
792	306	HEB	11	32	\N	\N	\N	8
793	307	1SA	22	5	\N	\N	\N	0
794	307	2SA	24	11	\N	19	O censo de Davi	1
795	307	1CR	29	29	\N	\N	\N	2
796	307	2CR	29	25	\N	\N	\N	3
797	308	2SA	7	\N	\N	\N	A aliança com Davi	0
798	308	2SA	12	1	\N	15	“Tu és este homem”	1
799	308	1RE	1	11	\N	45	Salomão ungido	2
800	308	1CR	29	29	\N	\N	\N	3
801	309	1RE	11	29	\N	39	A capa rasgada	0
802	309	1RE	14	1	\N	18	Condena a casa de Jeroboão	1
803	309	2CR	9	29	\N	\N	\N	2
804	310	1RE	17	\N	\N	\N	A seca e a viúva de Sarepta	0
805	310	1RE	18	\N	\N	\N	O monte Carmelo	1
806	310	1RE	19	\N	\N	\N	No Horebe	2
807	310	1RE	21	17	\N	29	Condena Acabe	3
808	310	2RE	1	\N	\N	\N	\N	4
809	310	2RE	2	1	\N	11	Levado ao céu	5
810	310	MAL	4	5	\N	6	\N	6
811	310	MAT	17	1	\N	13	Na transfiguração	7
812	310	TIA	5	17	\N	18	\N	8
813	311	1RE	22	8	\N	28	\N	0
814	311	2CR	18	\N	\N	\N	\N	1
815	312	1RE	19	16	\N	\N	\N	0
816	312	1RE	19	19	\N	\N	\N	1
817	313	1RE	19	16	\N	21	O chamado	0
818	313	2RE	2	\N	\N	\N	A porção dobrada	1
819	313	2RE	4	\N	\N	\N	A viúva e a sunamita	2
820	313	2RE	5	\N	\N	\N	A cura de Naamã	3
821	313	2RE	6	\N	\N	\N	\N	4
822	313	2RE	13	14	\N	21	Morte	5
823	313	LUC	4	27	\N	\N	\N	6
824	314	2RE	14	25	\N	\N	\N	0
825	314	JON	1	1	\N	\N	\N	1
826	315	2RE	14	25	\N	\N	Profecia sob Jeroboão II	0
827	315	JON	1	\N	2	\N	A fuga e o grande peixe	1
828	315	JON	3	\N	4	\N	Nínive se arrepende	2
829	315	MAT	12	39	\N	41	“O sinal de Jonas”	3
830	316	JOE	1	1	\N	12	A praga de gafanhotos	0
831	316	JOE	2	28	\N	32	“Derramarei o meu Espírito”	1
832	316	ATO	2	16	\N	21	\N	2
833	317	AMO	1	1	\N	\N	\N	0
834	317	AMO	5	21	\N	24	“Corra o juízo como as águas”	1
835	317	AMO	7	10	\N	17	Contra Amazias de Betel	2
836	317	AMO	9	11	\N	12	\N	3
837	317	ATO	15	16	\N	17	\N	4
838	318	OSE	1	1	\N	\N	\N	0
839	319	OSE	1	\N	3	\N	O casamento com Gômer	0
840	319	OSE	6	6	\N	\N	“Misericórdia quero, e não sacrifício”	1
841	319	OSE	11	1	\N	\N	“Do Egito chamei o meu filho”	2
842	319	MAT	2	15	\N	\N	\N	3
843	319	MAT	9	13	\N	\N	\N	4
844	319	ROM	9	25	\N	26	\N	5
845	320	OSE	1	2	\N	9	\N	0
846	320	OSE	3	1	\N	3	\N	1
847	321	OSE	1	3	\N	9	\N	0
848	321	OSE	2	23	\N	\N	\N	1
849	322	OSE	1	3	\N	9	\N	0
850	322	OSE	2	23	\N	\N	\N	1
851	323	OSE	1	3	\N	9	\N	0
852	323	OSE	2	23	\N	\N	\N	1
853	324	ISA	1	1	\N	\N	\N	0
854	325	ISA	1	1	\N	\N	\N	0
855	325	ISA	6	\N	\N	\N	O chamado	1
856	325	ISA	7	14	\N	\N	O Emanuel	2
857	325	ISA	9	6	\N	7	“Um menino nos nasceu”	3
858	325	ISA	36	\N	39	\N	Ezequias e Senaqueribe	4
859	325	ISA	53	\N	\N	\N	O Servo sofredor	5
860	325	LUC	4	16	\N	21	\N	6
861	325	JOA	12	38	\N	41	\N	7
862	326	MIQ	1	1	\N	\N	\N	0
863	326	MIQ	5	2	\N	\N	“E tu, Belém Efrata…”	1
864	326	MIQ	6	8	\N	\N	“Que pratiques a justiça…”	2
865	326	JER	26	18	\N	19	\N	3
866	326	MAT	2	5	\N	6	\N	4
867	327	NAU	1	1	\N	\N	\N	0
868	327	NAU	1	15	\N	\N	\N	1
869	327	NAU	3	\N	\N	\N	\N	2
870	328	SOF	1	1	\N	\N	\N	0
871	329	SOF	1	1	\N	\N	\N	0
872	330	SOF	1	1	\N	\N	\N	0
873	331	SOF	1	1	\N	\N	\N	0
874	331	SOF	1	14	\N	18	O dia do Senhor	1
875	331	SOF	3	17	\N	\N	“Ele se deleitará em ti com alegria”	2
876	332	2RE	22	14	\N	20	\N	0
877	332	2CR	34	22	\N	28	\N	1
878	333	HAB	1	1	\N	4	\N	0
879	333	HAB	2	4	\N	\N	“O justo viverá pela sua fé”	1
880	333	HAB	3	17	\N	19	\N	2
881	333	ROM	1	17	\N	\N	\N	3
882	333	GAL	3	11	\N	\N	\N	4
883	333	HEB	10	38	\N	\N	\N	5
884	334	JER	1	1	\N	\N	\N	0
885	335	JER	1	1	\N	10	O chamado	0
886	335	JER	18	1	\N	6	O oleiro	1
887	335	JER	31	31	\N	34	A nova aliança	2
888	335	JER	36	\N	\N	\N	O rolo queimado	3
889	335	JER	38	1	\N	13	Na cisterna	4
890	335	JER	43	1	\N	7	Levado ao Egito	5
891	335	MAT	16	14	\N	\N	\N	6
892	335	HEB	8	8	\N	12	\N	7
893	336	OBA	1	1	\N	21	\N	0
894	337	DAN	1	\N	\N	\N	Na corte da Babilônia	0
895	337	DAN	2	\N	\N	\N	O sonho da estátua	1
896	337	DAN	5	\N	\N	\N	A escrita na parede	2
897	337	DAN	6	\N	\N	\N	A cova dos leões	3
898	337	DAN	7	\N	\N	\N	As quatro feras e o Filho do Homem	4
899	337	DAN	9	24	\N	27	As setenta semanas	5
900	337	EZE	14	14	\N	\N	\N	6
901	337	MAT	24	15	\N	\N	\N	7
902	338	EZE	1	3	\N	\N	\N	0
903	339	EZE	1	1	\N	3	A visão junto ao rio Quebar	0
904	339	EZE	2	\N	3	\N	O chamado	1
905	339	EZE	24	15	\N	18	A morte da esposa	2
906	339	EZE	37	1	\N	14	O vale de ossos secos	3
907	339	EZE	40	\N	48	\N	O novo templo	4
908	340	AGE	1	1	\N	15	\N	0
909	340	AGE	2	20	\N	23	Zorobabel como anel de selar	1
910	340	ESD	5	1	\N	\N	\N	2
911	340	ESD	6	14	\N	\N	\N	3
912	341	NEE	12	4	\N	\N	\N	0
913	341	ZAC	1	1	\N	\N	\N	1
914	342	ZAC	1	1	\N	\N	\N	0
915	343	ZAC	1	1	\N	\N	\N	0
916	343	ZAC	4	6	\N	\N	“Não por força nem por violência”	1
917	343	ZAC	9	9	\N	\N	O rei montado num jumento	2
918	343	ZAC	12	10	\N	\N	\N	3
919	343	MAT	21	4	\N	5	\N	4
920	343	MAT	23	35	\N	\N	\N	5
921	344	MAL	1	1	\N	\N	\N	0
922	344	MAL	3	1	\N	\N	“Eis que eu envio o meu anjo”	1
923	344	MAL	3	8	\N	10	\N	2
924	344	MAL	4	5	\N	6	A volta de Elias	3
925	344	MAR	1	2	\N	\N	\N	4
926	345	LUC	1	5	\N	25	O anúncio no templo	0
927	345	LUC	1	57	\N	66	\N	1
928	345	LUC	1	67	\N	79	O Benedictus	2
929	346	LUC	1	5	\N	7	\N	0
930	346	LUC	1	24	\N	25	\N	1
931	346	LUC	1	39	\N	45	Visita de Maria	2
932	346	LUC	1	57	\N	60	\N	3
933	347	LUC	1	57	\N	80	Nascimento	0
934	347	MAT	3	\N	\N	\N	Pregação e batismo de Jesus	1
935	347	JOA	1	19	\N	36	“Eis o Cordeiro de Deus”	2
936	347	MAT	11	7	\N	15	“Este é o Elias que havia de vir”	3
937	347	MAT	14	1	\N	12	Morte	4
938	348	LUC	2	36	\N	38	\N	0
\.


--
-- Data for Name: reinados; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reinados (id, pessoa_id, reino, inicio, fim, observacao) FROM stdin;
1	107	Israel (reino unido)	-1050	-1010	\N
2	111	Israel (reino unido)	-1010	-970	7 anos e meio em Hebrom, 33 em Jerusalém
3	123	Israel (reino unido)	-970	-931	\N
4	126	Judá	-931	-913	\N
5	128	Judá	-913	-911	\N
6	129	Judá	-911	-870	\N
7	130	Judá	-873	-848	corregência com Asa desde 873
8	131	Judá	-853	-841	corregência desde 853; sozinho desde 848
9	132	Judá	-841	-841	\N
10	211	Judá	-841	-835	usurpadora
11	133	Judá	-835	-796	\N
12	134	Judá	-796	-767	\N
13	135	Judá	-792	-740	corregência desde 792
14	136	Judá	-750	-735	corregente durante a lepra de Uzias
15	137	Judá	-735	-715	\N
16	138	Judá	-715	-686	\N
17	139	Judá	-697	-642	corregência desde 697
18	140	Judá	-642	-640	\N
19	141	Judá	-640	-609	\N
20	196	Judá	-609	-609	três meses
21	142	Judá	-609	-598	\N
22	143	Judá	-598	-597	três meses
23	197	Judá	-597	-586	\N
24	200	Israel (reino do norte)	-931	-910	\N
25	201	Israel (reino do norte)	-910	-909	\N
26	203	Israel (reino do norte)	-909	-886	\N
27	204	Israel (reino do norte)	-886	-885	\N
28	205	Israel (reino do norte)	-885	-885	sete dias
29	206	Israel (reino do norte)	-885	-874	disputou o trono com Tibni até 880
30	207	Israel (reino do norte)	-874	-853	\N
31	209	Israel (reino do norte)	-853	-852	\N
32	210	Israel (reino do norte)	-852	-841	\N
33	214	Israel (reino do norte)	-841	-814	\N
34	215	Israel (reino do norte)	-814	-798	\N
35	216	Israel (reino do norte)	-798	-782	\N
36	217	Israel (reino do norte)	-793	-753	corregência desde 793
37	218	Israel (reino do norte)	-753	-753	seis meses
38	220	Israel (reino do norte)	-752	-752	um mês
39	222	Israel (reino do norte)	-752	-742	\N
40	223	Israel (reino do norte)	-742	-740	\N
41	225	Israel (reino do norte)	-752	-732	em Gileade desde 752; sobre todo Israel desde 740
42	227	Israel (reino do norte)	-732	-722	\N
\.


--
-- Name: casamentos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.casamentos_id_seq', 41, true);


--
-- Name: curiosidades_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.curiosidades_id_seq', 533, true);


--
-- Name: filiacoes_alternativas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.filiacoes_alternativas_id_seq', 2, true);


--
-- Name: links_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.links_id_seq', 1, false);


--
-- Name: papeis_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.papeis_id_seq', 52, true);


--
-- Name: pessoas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.pessoas_id_seq', 348, true);


--
-- Name: referencias_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.referencias_id_seq', 938, true);


--
-- Name: reinados_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.reinados_id_seq', 42, true);


--
-- Name: casamentos casamentos_marido_id_esposa_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.casamentos
    ADD CONSTRAINT casamentos_marido_id_esposa_id_key UNIQUE (marido_id, esposa_id);


--
-- Name: casamentos casamentos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.casamentos
    ADD CONSTRAINT casamentos_pkey PRIMARY KEY (id);


--
-- Name: config config_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.config
    ADD CONSTRAINT config_pkey PRIMARY KEY (chave);


--
-- Name: curiosidades curiosidades_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.curiosidades
    ADD CONSTRAINT curiosidades_pkey PRIMARY KEY (id);


--
-- Name: filiacoes_alternativas filiacoes_alternativas_filho_id_pai_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filiacoes_alternativas
    ADD CONSTRAINT filiacoes_alternativas_filho_id_pai_id_key UNIQUE (filho_id, pai_id);


--
-- Name: filiacoes_alternativas filiacoes_alternativas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filiacoes_alternativas
    ADD CONSTRAINT filiacoes_alternativas_pkey PRIMARY KEY (id);


--
-- Name: links links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: livros livros_ordem_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.livros
    ADD CONSTRAINT livros_ordem_key UNIQUE (ordem);


--
-- Name: livros livros_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.livros
    ADD CONSTRAINT livros_pkey PRIMARY KEY (codigo);


--
-- Name: papeis papeis_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.papeis
    ADD CONSTRAINT papeis_pkey PRIMARY KEY (id);


--
-- Name: pessoas pessoas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pessoas
    ADD CONSTRAINT pessoas_pkey PRIMARY KEY (id);


--
-- Name: referencias referencias_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.referencias
    ADD CONSTRAINT referencias_pkey PRIMARY KEY (id);


--
-- Name: reinados reinados_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reinados
    ADD CONSTRAINT reinados_pkey PRIMARY KEY (id);


--
-- Name: curiosidades_pessoa_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX curiosidades_pessoa_id_idx ON public.curiosidades USING btree (pessoa_id);


--
-- Name: links_pessoa_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX links_pessoa_id_idx ON public.links USING btree (pessoa_id);


--
-- Name: papeis_pessoa_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX papeis_pessoa_id_idx ON public.papeis USING btree (pessoa_id);


--
-- Name: pessoas_mae_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pessoas_mae_id_idx ON public.pessoas USING btree (mae_id);


--
-- Name: pessoas_pai_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pessoas_pai_id_idx ON public.pessoas USING btree (pai_id);


--
-- Name: referencias_pessoa_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX referencias_pessoa_id_idx ON public.referencias USING btree (pessoa_id);


--
-- Name: reinados_pessoa_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX reinados_pessoa_id_idx ON public.reinados USING btree (pessoa_id);


--
-- Name: casamentos casamentos_esposa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.casamentos
    ADD CONSTRAINT casamentos_esposa_id_fkey FOREIGN KEY (esposa_id) REFERENCES public.pessoas(id) ON DELETE CASCADE;


--
-- Name: casamentos casamentos_marido_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.casamentos
    ADD CONSTRAINT casamentos_marido_id_fkey FOREIGN KEY (marido_id) REFERENCES public.pessoas(id) ON DELETE CASCADE;


--
-- Name: curiosidades curiosidades_pessoa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.curiosidades
    ADD CONSTRAINT curiosidades_pessoa_id_fkey FOREIGN KEY (pessoa_id) REFERENCES public.pessoas(id) ON DELETE CASCADE;


--
-- Name: filiacoes_alternativas filiacoes_alternativas_filho_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filiacoes_alternativas
    ADD CONSTRAINT filiacoes_alternativas_filho_id_fkey FOREIGN KEY (filho_id) REFERENCES public.pessoas(id) ON DELETE CASCADE;


--
-- Name: filiacoes_alternativas filiacoes_alternativas_pai_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filiacoes_alternativas
    ADD CONSTRAINT filiacoes_alternativas_pai_id_fkey FOREIGN KEY (pai_id) REFERENCES public.pessoas(id) ON DELETE CASCADE;


--
-- Name: links links_pessoa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.links
    ADD CONSTRAINT links_pessoa_id_fkey FOREIGN KEY (pessoa_id) REFERENCES public.pessoas(id) ON DELETE CASCADE;


--
-- Name: papeis papeis_pessoa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.papeis
    ADD CONSTRAINT papeis_pessoa_id_fkey FOREIGN KEY (pessoa_id) REFERENCES public.pessoas(id) ON DELETE CASCADE;


--
-- Name: pessoas pessoas_mae_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pessoas
    ADD CONSTRAINT pessoas_mae_id_fkey FOREIGN KEY (mae_id) REFERENCES public.pessoas(id) ON DELETE SET NULL;


--
-- Name: pessoas pessoas_pai_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pessoas
    ADD CONSTRAINT pessoas_pai_id_fkey FOREIGN KEY (pai_id) REFERENCES public.pessoas(id) ON DELETE SET NULL;


--
-- Name: referencias referencias_livro_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.referencias
    ADD CONSTRAINT referencias_livro_fkey FOREIGN KEY (livro) REFERENCES public.livros(codigo);


--
-- Name: referencias referencias_pessoa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.referencias
    ADD CONSTRAINT referencias_pessoa_id_fkey FOREIGN KEY (pessoa_id) REFERENCES public.pessoas(id) ON DELETE CASCADE;


--
-- Name: reinados reinados_pessoa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reinados
    ADD CONSTRAINT reinados_pessoa_id_fkey FOREIGN KEY (pessoa_id) REFERENCES public.pessoas(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict NYqrRFqfbOzzgpme3suMw0kR4zDQRDTfgIr30VSCTLI23L6glKnRTQSz0zGIwEU

