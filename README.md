# Árvore Genealógica Bíblica

Árvore genealógica de personagens bíblicos, posicionados verticalmente pelo ano de nascimento
(calendário cristão, a.C./d.C.). Homens em azul claro, mulheres em rosa claro.

- **Backend:** Python (FastAPI) em Docker, porta **8090**
- **Banco:** PostgreSQL do notebook (fora do Docker), banco/usuário `arvorebiblia`
- **Frontend:** JavaScript puro + SVG (sem build), servido pelo próprio backend

## Instalar

```bash
cp .env.example .env              # e defina DB_PASSWORD
# criar usuário e banco no PostgreSQL local:
sudo -u postgres psql -c "CREATE ROLE arvorebiblia LOGIN PASSWORD 'a-senha-do-.env';"
sudo -u postgres psql -c "CREATE DATABASE arvorebiblia OWNER arvorebiblia;"
# carregar os dados: a cópia do banco (inclui edições feitas pela interface)…
psql -h 127.0.0.1 -U arvorebiblia -d arvorebiblia -f db/dump/arvorebiblia.sql
# …ou gerar tudo do zero pelo seed
python db/seed.py
```

O `pg_hba.conf` precisa aceitar conexões da sub-rede do Docker (veja `docker-compose.yml`).

## Rodar

```bash
docker compose up -d --build      # http://localhost:8090
docker compose logs -f            # logs
docker compose down               # parar
```

Depois de alterar arquivos em `backend/` ou `frontend/`, rode `docker compose up -d --build` de novo.

## Banco de dados

Credenciais em `.env`, que não é versionado (modelo em `.env.example`). O container acessa o Postgres do host via
`host.docker.internal`, numa rede Docker fixa `172.21.0.0/16`, já liberada no `pg_hba.conf`.

Recriar tudo a partir do seed (**apaga as edições feitas pela interface**):

```bash
docker compose exec app python db/seed.py --forcar
```

### Cópia do banco (`db/dump/arvorebiblia.sql`)

Os dados são públicos e ficam versionados no repositório. Depois de editar pela interface,
atualize a cópia antes de fazer commit:

```bash
sudo -u postgres pg_dump --no-owner --no-privileges --no-comments -d arvorebiblia > db/dump/arvorebiblia.sql
```

(`--no-owner --no-privileges` deixa o arquivo sem nomes de usuário e permissões do servidor local.)

### Tabelas
| tabela | conteúdo |
|---|---|
| `pessoas` | nome, sexo, anos (negativo = a.C.), pai/mãe, significado do nome, resumo, história |
| `casamentos` | marido × esposa (+ observação: concubina, primeiro marido…) |
| `referencias` | livro/capítulo/versículos → link gerado para o BibleGateway |
| `curiosidades` | itens de curiosidade por pessoa |
| `links` | links externos por pessoa |
| `papeis` | Profeta, Profetisa, Juiz…: período de atuação e local (reino); usado no seletor "Destacar" e para posicionar a pessoa perto do rei da época |
| `reinados` | reino (reino unido, Judá, Israel do norte), início, fim e observação; antecessor e sucessor são calculados |
| `filiacoes_alternativas` | pai segundo outra fonte (ex.: Lucas 3), com a fonte; linha tracejada |
| `livros` | os 66 livros (nome, abreviação, nome em inglês para o link) |
| `config` | `ano_criacao` (-4026) |

## Cronologia adotada

- Adão e Eva: **4026 a.C.**
- Gn 5 e Gn 11 (texto massorético) somados ano a ano.
- Abraão nasce com Terá aos 130 anos (harmonização de At 7:4, a mesma de Ussher).
- **De Saul em diante** (monarquia, reis de Judá, exílio, Jesus): cronologia histórica convencional
  (Thiele), com Davi rei em 1010 a.C., divisão do reino em 931 a.C., queda de Jerusalém em 586 a.C.
  e Jesus por volta de 4 a.C. A diferença entre os dois sistemas fica absorvida no período dos
  Juízes (entre Obede e Jessé), onde a genealogia de Rute 4 já tem gerações omitidas.
- Genealogia de Jesus segundo **Mateus 1** (linha principal) e **Lucas 3** (ramo paralelo, por Natã).
  Quando Lucas dá outro pai a alguém (Salatiel ← Neri; José ← Eli), isso fica em
  `filiacoes_alternativas` e aparece como linha tracejada verde. Os reis que Mateus omite (Acazias, Joás, Amazias e
  Jeoaquim) estão na árvore, com nota explicando a omissão.
- Reis de Judá e de Israel com os reinados de Thiele. A Bíblia não dá a idade dos reis de Israel
  ao assumir, então o nascimento deles é estimado.
- Datas sem base direta no texto são marcadas com `~` (aproximadas).
- Sem ano zero: 1 a.C. é seguido de 1 d.C.

No `db/seed.py` os nascimentos até os Juízes são escritos em "anos desde Adão" (`am=`) e convertidos;
a partir da monarquia usam o ano civil direto (`ano=`, negativo = a.C.).
Para mudar a data-base, altere `ANO_CRIACAO` no `.env` e rode o seed com `--forcar`.

## Uso

- Arrastar move a árvore; a roda do mouse dá zoom; o controle **Escala do tempo** estica ou
  comprime o eixo vertical (px por ano).
- Clique num card para ver detalhes, referências (abrem no BibleGateway, versão ARC), história e
  curiosidades. No painel: editar, adicionar filho(a), cônjuge, referências, curiosidades e links.
- **Destacar** (no topo) realça profetas, juízes ou reis e rainhas na linha do tempo.
- A versão da Bíblia nos links pode ser trocada com a variável `VERSAO_BIBLIA` (ex.: `NVI-PT`).
- Os marcos da linha do tempo (Dilúvio, Êxodo…) ficam em `MARCOS`, no início de `frontend/app.js`.
