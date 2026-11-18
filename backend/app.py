"""API da Árvore Genealógica Bíblica."""
import os
from typing import Optional
from urllib.parse import quote_plus

from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, Field

from db import cursor

FRONTEND = os.path.join(os.path.dirname(__file__), "..", "frontend")
VERSAO_BIBLIA = os.getenv("VERSAO_BIBLIA", "ARC")  # ARC, NVI-PT, NTLH, OL...

app = FastAPI(title="Árvore Genealógica Bíblica")


# ---------------------------------------------------------------- modelos
class PessoaIn(BaseModel):
    nome: str = Field(min_length=1)
    sexo: str = Field(pattern="^[MF]$")
    significado_nome: Optional[str] = None
    ano_nascimento: Optional[int] = None
    nascimento_aprox: bool = False
    ano_morte: Optional[int] = None
    morte_aprox: bool = False
    idade_morte: Optional[int] = None
    sem_nome: bool = False
    pai_id: Optional[int] = None
    mae_id: Optional[int] = None
    resumo: Optional[str] = None
    historia: Optional[str] = None


class CasamentoIn(BaseModel):
    marido_id: int
    esposa_id: int
    observacao: Optional[str] = None


class FiliacaoIn(BaseModel):
    filho_id: int
    pai_id: int
    fonte: str = Field(min_length=1)
    observacao: Optional[str] = None


class ReinadoIn(BaseModel):
    reino: str = Field(min_length=1)
    inicio: int
    fim: int
    observacao: Optional[str] = None


class PapelIn(BaseModel):
    papel: str = Field(min_length=1)
    inicio: Optional[int] = None
    fim: Optional[int] = None
    local: Optional[str] = None
    observacao: Optional[str] = None


class ReferenciaIn(BaseModel):
    livro: str
    capitulo: int
    versiculo_inicio: Optional[int] = None
    capitulo_fim: Optional[int] = None
    versiculo_fim: Optional[int] = None
    descricao: Optional[str] = None
    ordem: int = 0


class CuriosidadeIn(BaseModel):
    texto: str = Field(min_length=1)
    ordem: int = 0


class LinkIn(BaseModel):
    titulo: str = Field(min_length=1)
    url: str = Field(min_length=1)
    ordem: int = 0


# ---------------------------------------------------------------- util
def texto_ref(r: dict) -> str:
    s = f"{r['abrev']} {r['capitulo']}"
    if r.get("versiculo_inicio"):
        s += f":{r['versiculo_inicio']}"
    if r.get("capitulo_fim") and r["capitulo_fim"] != r["capitulo"]:
        s += f"–{r['capitulo_fim']}"
        if r.get("versiculo_fim"):
            s += f":{r['versiculo_fim']}"
    elif r.get("versiculo_fim") and r["versiculo_fim"] != r.get("versiculo_inicio"):
        s += f"-{r['versiculo_fim']}"
    return s


def url_ref(r: dict) -> str:
    q = f"{r['nome_en']} {r['capitulo']}"
    if r.get("versiculo_inicio"):
        q += f":{r['versiculo_inicio']}"
    if r.get("capitulo_fim") and r["capitulo_fim"] != r["capitulo"]:
        q += f"-{r['capitulo_fim']}"
        if r.get("versiculo_fim"):
            q += f":{r['versiculo_fim']}"
    elif r.get("versiculo_fim"):
        q += f"-{r['versiculo_fim']}"
    return f"https://www.biblegateway.com/passage/?search={quote_plus(q)}&version={VERSAO_BIBLIA}"


def existe(cur, tabela: str, id_: int):
    cur.execute(f"SELECT 1 FROM {tabela} WHERE id=%s", (id_,))
    if not cur.fetchone():
        raise HTTPException(404, f"{tabela} {id_} não encontrado")


def valida_pais(cur, p: PessoaIn, id_: Optional[int] = None):
    for campo, sexo in (("pai_id", "M"), ("mae_id", "F")):
        v = getattr(p, campo)
        if v is None:
            continue
        if id_ is not None and v == id_:
            raise HTTPException(400, "Uma pessoa não pode ser pai/mãe de si mesma")
        cur.execute("SELECT sexo FROM pessoas WHERE id=%s", (v,))
        row = cur.fetchone()
        if not row:
            raise HTTPException(400, f"{campo}={v} não existe")
        if row["sexo"] != sexo:
            raise HTTPException(400, f"{campo} deve ser do sexo {sexo}")


# ---------------------------------------------------------------- config
@app.get("/api/config")
def config():
    with cursor() as cur:
        cur.execute("SELECT chave, valor FROM config")
        cfg = {r["chave"]: r["valor"] for r in cur.fetchall()}
    cfg.setdefault("ano_criacao", os.getenv("ANO_CRIACAO", "-4026"))
    cfg["versao_biblia"] = VERSAO_BIBLIA
    return cfg


@app.get("/api/livros")
def livros():
    with cursor() as cur:
        cur.execute("SELECT * FROM livros ORDER BY ordem")
        return cur.fetchall()


# ---------------------------------------------------------------- árvore
@app.get("/api/arvore")
def arvore():
    """Tudo o que o front precisa para desenhar a árvore, numa chamada só."""
    with cursor() as cur:
        cur.execute(
            """SELECT id, nome, sexo, ano_nascimento, nascimento_aprox, ano_morte,
                      morte_aprox, idade_morte, pai_id, mae_id, resumo, sem_nome
                 FROM pessoas ORDER BY ano_nascimento NULLS LAST, id"""
        )
        pessoas = cur.fetchall()
        cur.execute("SELECT id, marido_id, esposa_id FROM casamentos ORDER BY id")
        casamentos = cur.fetchall()
        cur.execute("SELECT id, filho_id, pai_id, fonte FROM filiacoes_alternativas ORDER BY id")
        filiacoes = cur.fetchall()
        cur.execute("SELECT id, pessoa_id, reino, inicio, fim FROM reinados ORDER BY reino, inicio, fim, id")
        reinados = cur.fetchall()
        cur.execute("SELECT id, pessoa_id, papel, inicio, fim, local FROM papeis ORDER BY id")
        papeis = cur.fetchall()
    return {"pessoas": pessoas, "casamentos": casamentos, "filiacoes": filiacoes, "reinados": reinados,
            "papeis": papeis}


# ---------------------------------------------------------------- pessoas
@app.get("/api/pessoas/{id_}")
def pessoa(id_: int):
    with cursor() as cur:
        cur.execute(
            """SELECT p.*, pai.nome AS pai_nome, mae.nome AS mae_nome
                 FROM pessoas p
                 LEFT JOIN pessoas pai ON pai.id = p.pai_id
                 LEFT JOIN pessoas mae ON mae.id = p.mae_id
                WHERE p.id=%s""",
            (id_,),
        )
        p = cur.fetchone()
        if not p:
            raise HTTPException(404, "Pessoa não encontrada")
        cur.execute(
            """SELECT r.*, l.abrev, l.nome AS livro_nome, l.nome_en
                 FROM referencias r JOIN livros l ON l.codigo = r.livro
                WHERE r.pessoa_id=%s ORDER BY r.ordem, l.ordem, r.capitulo, r.versiculo_inicio""",
            (id_,),
        )
        refs = cur.fetchall()
        for r in refs:
            r["texto"] = texto_ref(r)
            r["url"] = url_ref(r)
        cur.execute("SELECT * FROM curiosidades WHERE pessoa_id=%s ORDER BY ordem, id", (id_,))
        p["curiosidades"] = cur.fetchall()
        cur.execute("SELECT * FROM links WHERE pessoa_id=%s ORDER BY ordem, id", (id_,))
        p["links"] = cur.fetchall()
        cur.execute(
            """SELECT c.id AS casamento_id, c.observacao, o.id, o.nome, o.sexo
                 FROM casamentos c
                 JOIN pessoas o ON o.id = CASE WHEN c.marido_id=%(i)s THEN c.esposa_id ELSE c.marido_id END
                WHERE c.marido_id=%(i)s OR c.esposa_id=%(i)s ORDER BY c.id""",
            {"i": id_},
        )
        p["conjuges"] = cur.fetchall()
        cur.execute(
            """SELECT id, nome, sexo, ano_nascimento FROM pessoas
                WHERE pai_id=%(i)s OR mae_id=%(i)s ORDER BY ano_nascimento NULLS LAST, id""",
            {"i": id_},
        )
        p["filhos"] = cur.fetchall()
        cur.execute(
            """SELECT f.id AS filiacao_id, f.fonte, f.observacao, o.id, o.nome, o.sexo
                 FROM filiacoes_alternativas f JOIN pessoas o ON o.id = f.pai_id
                WHERE f.filho_id=%s ORDER BY f.id""",
            (id_,),
        )
        p["pais_alternativos"] = cur.fetchall()
        cur.execute(
            """SELECT f.id AS filiacao_id, f.fonte, o.id, o.nome, o.sexo
                 FROM filiacoes_alternativas f JOIN pessoas o ON o.id = f.filho_id
                WHERE f.pai_id=%s ORDER BY f.id""",
            (id_,),
        )
        p["filhos_alternativos"] = cur.fetchall()
        cur.execute(
            """WITH r AS (
                 SELECT r.*, LAG(r.pessoa_id) OVER w AS ant_id, LEAD(r.pessoa_id) OVER w AS suc_id
                   FROM reinados r WINDOW w AS (PARTITION BY r.reino ORDER BY r.inicio, r.fim, r.id))
               SELECT r.id AS reinado_id, r.reino, r.inicio, r.fim, r.observacao,
                      a.id AS ant_id, a.nome AS ant_nome, a.sexo AS ant_sexo,
                      s.id AS suc_id, s.nome AS suc_nome, s.sexo AS suc_sexo
                 FROM r LEFT JOIN pessoas a ON a.id = r.ant_id LEFT JOIN pessoas s ON s.id = r.suc_id
                WHERE r.pessoa_id=%s ORDER BY r.inicio""",
            (id_,),
        )
        p["reinados"] = cur.fetchall()
        cur.execute("SELECT * FROM papeis WHERE pessoa_id=%s ORDER BY inicio NULLS LAST, id", (id_,))
        p["papeis"] = cur.fetchall()
        p["referencias"] = refs
    return p


@app.post("/api/pessoas", status_code=201)
def cria_pessoa(p: PessoaIn):
    with cursor() as cur:
        valida_pais(cur, p)
        d = p.model_dump()
        cols = ", ".join(d)
        vals = ", ".join(f"%({k})s" for k in d)
        cur.execute(f"INSERT INTO pessoas ({cols}) VALUES ({vals}) RETURNING id", d)
        return {"id": cur.fetchone()["id"]}


@app.put("/api/pessoas/{id_}")
def altera_pessoa(id_: int, p: PessoaIn):
    with cursor() as cur:
        existe(cur, "pessoas", id_)
        valida_pais(cur, p, id_)
        d = p.model_dump()
        sets = ", ".join(f"{k}=%({k})s" for k in d)
        d["id"] = id_
        cur.execute(f"UPDATE pessoas SET {sets}, atualizado_em=now() WHERE id=%(id)s", d)
    return {"id": id_}


@app.delete("/api/pessoas/{id_}")
def apaga_pessoa(id_: int):
    with cursor() as cur:
        existe(cur, "pessoas", id_)
        cur.execute("DELETE FROM pessoas WHERE id=%s", (id_,))
    return {"ok": True}


# ---------------------------------------------------------------- filhos de pessoa (refs, curiosidades, links)
@app.post("/api/pessoas/{id_}/referencias", status_code=201)
def cria_ref(id_: int, r: ReferenciaIn):
    with cursor() as cur:
        existe(cur, "pessoas", id_)
        cur.execute("SELECT 1 FROM livros WHERE codigo=%s", (r.livro,))
        if not cur.fetchone():
            raise HTTPException(400, "Livro inválido")
        d = r.model_dump() | {"pessoa_id": id_}
        cur.execute(
            """INSERT INTO referencias (pessoa_id, livro, capitulo, versiculo_inicio, capitulo_fim,
                                         versiculo_fim, descricao, ordem)
               VALUES (%(pessoa_id)s, %(livro)s, %(capitulo)s, %(versiculo_inicio)s, %(capitulo_fim)s,
                       %(versiculo_fim)s, %(descricao)s, %(ordem)s) RETURNING id""",
            d,
        )
        return {"id": cur.fetchone()["id"]}


@app.post("/api/pessoas/{id_}/reinados", status_code=201)
def cria_reinado(id_: int, r: ReinadoIn):
    if r.fim < r.inicio:
        raise HTTPException(400, "O fim do reinado não pode ser anterior ao início")
    with cursor() as cur:
        existe(cur, "pessoas", id_)
        cur.execute(
            "INSERT INTO reinados (pessoa_id, reino, inicio, fim, observacao) VALUES (%s,%s,%s,%s,%s) RETURNING id",
            (id_, r.reino, r.inicio, r.fim, r.observacao),
        )
        return {"id": cur.fetchone()["id"]}


@app.post("/api/pessoas/{id_}/papeis", status_code=201)
def cria_papel(id_: int, r: PapelIn):
    if r.inicio is not None and r.fim is not None and r.fim < r.inicio:
        raise HTTPException(400, "O fim não pode ser anterior ao início")
    with cursor() as cur:
        existe(cur, "pessoas", id_)
        cur.execute(
            "INSERT INTO papeis (pessoa_id, papel, inicio, fim, local, observacao) VALUES (%s,%s,%s,%s,%s,%s) RETURNING id",
            (id_, r.papel, r.inicio, r.fim, r.local, r.observacao),
        )
        return {"id": cur.fetchone()["id"]}


@app.post("/api/pessoas/{id_}/curiosidades", status_code=201)
def cria_curiosidade(id_: int, c: CuriosidadeIn):
    with cursor() as cur:
        existe(cur, "pessoas", id_)
        cur.execute(
            "INSERT INTO curiosidades (pessoa_id, texto, ordem) VALUES (%s,%s,%s) RETURNING id",
            (id_, c.texto, c.ordem),
        )
        return {"id": cur.fetchone()["id"]}


@app.post("/api/pessoas/{id_}/links", status_code=201)
def cria_link(id_: int, l: LinkIn):
    with cursor() as cur:
        existe(cur, "pessoas", id_)
        cur.execute(
            "INSERT INTO links (pessoa_id, titulo, url, ordem) VALUES (%s,%s,%s,%s) RETURNING id",
            (id_, l.titulo, l.url, l.ordem),
        )
        return {"id": cur.fetchone()["id"]}


@app.post("/api/casamentos", status_code=201)
def cria_casamento(c: CasamentoIn):
    with cursor() as cur:
        for pid, sexo in ((c.marido_id, "M"), (c.esposa_id, "F")):
            cur.execute("SELECT sexo FROM pessoas WHERE id=%s", (pid,))
            row = cur.fetchone()
            if not row or row["sexo"] != sexo:
                raise HTTPException(400, "Casamento requer marido (M) e esposa (F) existentes")
        cur.execute(
            """INSERT INTO casamentos (marido_id, esposa_id, observacao) VALUES (%s,%s,%s)
               ON CONFLICT (marido_id, esposa_id) DO UPDATE SET observacao=EXCLUDED.observacao
               RETURNING id""",
            (c.marido_id, c.esposa_id, c.observacao),
        )
        return {"id": cur.fetchone()["id"]}


@app.post("/api/filiacoes", status_code=201)
def cria_filiacao(f: FiliacaoIn):
    if f.filho_id == f.pai_id:
        raise HTTPException(400, "Uma pessoa não pode ser pai/mãe de si mesma")
    with cursor() as cur:
        existe(cur, "pessoas", f.filho_id)
        existe(cur, "pessoas", f.pai_id)
        cur.execute(
            """INSERT INTO filiacoes_alternativas (filho_id, pai_id, fonte, observacao) VALUES (%s,%s,%s,%s)
               ON CONFLICT (filho_id, pai_id) DO UPDATE SET fonte=EXCLUDED.fonte, observacao=EXCLUDED.observacao
               RETURNING id""",
            (f.filho_id, f.pai_id, f.fonte, f.observacao),
        )
        return {"id": cur.fetchone()["id"]}


TABELAS_APAGAVEIS = {"referencias", "curiosidades", "links", "casamentos", "filiacoes_alternativas", "reinados", "papeis"}


@app.delete("/api/{tabela}/{id_}")
def apaga_item(tabela: str, id_: int):
    if tabela not in TABELAS_APAGAVEIS:
        raise HTTPException(404)
    with cursor() as cur:
        existe(cur, tabela, id_)
        cur.execute(f"DELETE FROM {tabela} WHERE id=%s", (id_,))
    return {"ok": True}


# ---------------------------------------------------------------- frontend
app.mount("/static", StaticFiles(directory=FRONTEND), name="static")


@app.get("/")
def index():
    return FileResponse(os.path.join(FRONTEND, "index.html"))
