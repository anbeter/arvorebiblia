-- Árvore Genealógica Bíblica — schema
-- Convenção de anos: inteiro com sinal. Negativo = a.C. (ex.: -4026 = 4026 a.C.), positivo = d.C.

DROP TABLE IF EXISTS papeis, reinados, filiacoes_alternativas, links, curiosidades, referencias, casamentos, pessoas, livros, config CASCADE;

CREATE TABLE config (
    chave TEXT PRIMARY KEY,
    valor TEXT NOT NULL
);

CREATE TABLE livros (
    codigo      TEXT PRIMARY KEY,          -- ex.: GEN
    nome        TEXT NOT NULL,             -- Gênesis
    abrev       TEXT NOT NULL,             -- Gn
    nome_en     TEXT NOT NULL,             -- Genesis (usado nos links do BibleGateway)
    ordem       INT  NOT NULL UNIQUE,
    testamento  CHAR(2) NOT NULL CHECK (testamento IN ('AT','NT'))
);

CREATE TABLE pessoas (
    id                  SERIAL PRIMARY KEY,
    nome                TEXT NOT NULL,
    sexo                CHAR(1) NOT NULL CHECK (sexo IN ('M','F')),
    significado_nome    TEXT,
    ano_nascimento      INT,
    nascimento_aprox    BOOLEAN NOT NULL DEFAULT FALSE,
    ano_morte           INT,
    morte_aprox         BOOLEAN NOT NULL DEFAULT FALSE,
    idade_morte         INT,
    pai_id              INT REFERENCES pessoas(id) ON DELETE SET NULL,
    mae_id              INT REFERENCES pessoas(id) ON DELETE SET NULL,
    sem_nome            BOOLEAN NOT NULL DEFAULT FALSE,  -- card de grupo/anônimo (ex.: "Irmãs" sem nome)
    resumo              TEXT,                  -- uma linha, aparece no card/tooltip
    historia            TEXT,                  -- texto livre (parágrafos)
    criado_em           TIMESTAMPTZ NOT NULL DEFAULT now(),
    atualizado_em       TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (pai_id IS NULL OR pai_id <> id),
    CHECK (mae_id IS NULL OR mae_id <> id)
);
CREATE INDEX ON pessoas(pai_id);
CREATE INDEX ON pessoas(mae_id);

CREATE TABLE casamentos (
    id          SERIAL PRIMARY KEY,
    marido_id   INT NOT NULL REFERENCES pessoas(id) ON DELETE CASCADE,
    esposa_id   INT NOT NULL REFERENCES pessoas(id) ON DELETE CASCADE,
    observacao  TEXT,
    UNIQUE (marido_id, esposa_id)
);

CREATE TABLE referencias (
    id                  SERIAL PRIMARY KEY,
    pessoa_id           INT NOT NULL REFERENCES pessoas(id) ON DELETE CASCADE,
    livro               TEXT NOT NULL REFERENCES livros(codigo),
    capitulo            INT NOT NULL,
    versiculo_inicio    INT,
    capitulo_fim        INT,
    versiculo_fim       INT,
    descricao           TEXT,
    ordem               INT NOT NULL DEFAULT 0
);
CREATE INDEX ON referencias(pessoa_id);

CREATE TABLE curiosidades (
    id          SERIAL PRIMARY KEY,
    pessoa_id   INT NOT NULL REFERENCES pessoas(id) ON DELETE CASCADE,
    texto       TEXT NOT NULL,
    ordem       INT NOT NULL DEFAULT 0
);
CREATE INDEX ON curiosidades(pessoa_id);

CREATE TABLE links (
    id          SERIAL PRIMARY KEY,
    pessoa_id   INT NOT NULL REFERENCES pessoas(id) ON DELETE CASCADE,
    titulo      TEXT NOT NULL,
    url         TEXT NOT NULL,
    ordem       INT NOT NULL DEFAULT 0
);
CREATE INDEX ON links(pessoa_id);

-- Filiação segundo outra fonte (ex.: Lucas 3 dá a José o pai Eli; Mateus 1 dá Jacó).
-- O pai "principal" continua em pessoas.pai_id; aqui ficam as alternativas, com a fonte.
CREATE TABLE filiacoes_alternativas (
    id          SERIAL PRIMARY KEY,
    filho_id    INT NOT NULL REFERENCES pessoas(id) ON DELETE CASCADE,
    pai_id      INT NOT NULL REFERENCES pessoas(id) ON DELETE CASCADE,
    fonte       TEXT NOT NULL,             -- ex.: "Lucas 3:23"
    observacao  TEXT,
    UNIQUE (filho_id, pai_id),
    CHECK (filho_id <> pai_id)
);

-- Reinados (monarquia unida, Judá, Israel do norte). Anos com sinal (negativo = a.C.).
CREATE TABLE reinados (
    id          SERIAL PRIMARY KEY,
    pessoa_id   INT NOT NULL REFERENCES pessoas(id) ON DELETE CASCADE,
    reino       TEXT NOT NULL,             -- 'Israel (reino unido)', 'Judá', 'Israel (reino do norte)'
    inicio      INT NOT NULL,
    fim         INT NOT NULL,
    observacao  TEXT,
    CHECK (fim >= inicio)
);
CREATE INDEX ON reinados(pessoa_id);

-- Papéis/funções (Profeta, Profetisa, Juiz…), com período de atuação e local opcionais.
-- "local" usa os mesmos nomes de reino da tabela reinados (ex.: 'Judá'), o que permite
-- posicionar a pessoa perto do rei da época.
CREATE TABLE papeis (
    id          SERIAL PRIMARY KEY,
    pessoa_id   INT NOT NULL REFERENCES pessoas(id) ON DELETE CASCADE,
    papel       TEXT NOT NULL,
    inicio      INT,
    fim         INT,
    local       TEXT,
    observacao  TEXT,
    CHECK (fim IS NULL OR inicio IS NULL OR fim >= inicio)
);
CREATE INDEX ON papeis(pessoa_id);
