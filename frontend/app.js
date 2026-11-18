"use strict";
/* Árvore Genealógica Bíblica — frontend (JS puro + SVG)
 *
 * Calendário cristão (a.C./d.C., sem ano zero). No banco: a.C. = negativo, d.C. = positivo.
 * Eixo vertical: ano de nascimento.  Eixo horizontal: calculado empacotando as subárvores
 * de forma que nenhum card se sobreponha a outro no mesmo período.
 */

const SVGNS = "http://www.w3.org/2000/svg";
const CARD_W = 156, CARD_H = 44, COL = CARD_W + 22, FOLGA_Y = 5, TOPO = 60, MARGEM_X = 300;

// Marcos da linha do tempo. {am}: anos desde a criação (segue a data-base do banco);
// {ano}: ano civil fixo (negativo = a.C.), usado a partir da monarquia.
const MARCOS = [
  { am: 0, nome: "Criação" }, { am: 1656, nome: "Dilúvio" }, { am: 2083, nome: "Chamado de Abraão" },
  { am: 2298, nome: "Jacó desce ao Egito" }, { am: 2513, nome: "Êxodo" }, { am: 2553, nome: "Entrada em Canaã" },
  { ano: -1010, nome: "Davi rei" }, { ano: -966, nome: "Templo de Salomão" }, { ano: -931, nome: "Divisão do reino" },
  { ano: -722, nome: "Queda de Samaria" }, { ano: -586, nome: "Queda de Jerusalém / exílio" },
  { ano: -538, nome: "Retorno do exílio" }, { ano: -4, nome: "Nascimento de Jesus (aprox.)" },
];

const estado = {
  pessoas: new Map(), casamentos: [], filiacoes: [], reinados: [], papeis: [], livros: [], anoCriacao: -4026,
  escala: 3, tx: 0, ty: 0, k: 1, pos: new Map(), selecionado: null,
};

const $ = (s) => document.querySelector(s);
const el = (tag, attrs = {}, pai) => {
  const e = document.createElementNS(SVGNS, tag);
  for (const [k, v] of Object.entries(attrs)) e.setAttribute(k, v);
  if (pai) pai.appendChild(e);
  return e;
};
const esc = (s) => String(s ?? "").replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));

// ---------------------------------------------------------------- calendário
/** ano civil (sem zero) -> número contínuo (com zero), para medir distâncias */
const continuo = (ano) => (ano < 0 ? ano + 1 : ano);
const deContinuo = (t) => (t <= 0 ? t - 1 : t);
const fmtAno = (ano, aprox) => ano == null ? "?" : `${aprox ? "~" : ""}${Math.abs(ano)} ${ano < 0 ? "a.C." : "d.C."}`;
/** anos civis "redondos" (múltiplos de passo; 1 d.C. no lugar do inexistente ano 0) entre dois valores contínuos */
function anosRedondos(t0, t1, passo) {
  const out = [];
  for (let c = Math.ceil(deContinuo(Math.floor(t0)) / passo) * passo; continuo(c || 1) <= t1; c += passo) {
    const ano = c === 0 ? 1 : c;
    if (continuo(ano) >= t0) out.push(ano);
  }
  return out;
}
/** "1858–1711 a.C." quando as duas datas são da mesma era; senão, cada uma com a sua */
function fmtIntervalo(p) {
  const n = p.ano_nascimento, m = p.ano_morte;
  if (m == null) return fmtAno(n, p.nascimento_aprox);
  if ((n < 0) === (m < 0)) return `${p.nascimento_aprox ? "~" : ""}${Math.abs(n)}–${p.morte_aprox ? "~" : ""}${Math.abs(m)} ${m < 0 ? "a.C." : "d.C."}`;
  return `${fmtAno(n, p.nascimento_aprox)} – ${fmtAno(m, p.morte_aprox)}`;
}
const anoDesdeCriacao = (n) => deContinuo(continuo(estado.anoCriacao) + n);

// ---------------------------------------------------------------- API
async function api(metodo, url, corpo) {
  const r = await fetch(url, {
    method: metodo,
    headers: corpo ? { "Content-Type": "application/json" } : {},
    body: corpo ? JSON.stringify(corpo) : undefined,
  });
  if (!r.ok) {
    let msg = r.statusText;
    try { const j = await r.json(); msg = typeof j.detail === "string" ? j.detail : JSON.stringify(j.detail); } catch {}
    throw new Error(msg);
  }
  return r.json();
}

async function carregar() {
  const [cfg, arv] = await Promise.all([api("GET", "/api/config"), api("GET", "/api/arvore")]);
  estado.anoCriacao = parseInt(cfg.ano_criacao, 10);
  estado.pessoas = new Map(arv.pessoas.map((p) => [p.id, p]));
  estado.casamentos = arv.casamentos;
  estado.filiacoes = arv.filiacoes || [];
  estado.reinados = arv.reinados || [];
  estado.papeis = arv.papeis || [];
  atualizarOpcoesDestaque();
  if (!estado.livros.length) estado.livros = await api("GET", "/api/livros");
  $("#lista-nomes").innerHTML = [...estado.pessoas.values()]
    .sort((a, b) => a.nome.localeCompare(b.nome, "pt"))
    .map((p) => `<option value="${esc(p.nome)}">`).join("");
  desenhar();
}

// ---------------------------------------------------------------- layout
/** Ano usado para posicionar: o informado ou uma estimativa a partir de pais/filhos/cônjuge. */
function anosEfetivos() {
  const P = estado.pessoas, ano = new Map(), estimado = new Set();
  for (const p of P.values()) if (p.ano_nascimento != null) ano.set(p.id, continuo(p.ano_nascimento));
  const conj = conjugesPorPessoa();
  for (let volta = 0; volta < 20; volta++) {
    let mudou = false;
    for (const p of P.values()) {
      if (ano.has(p.id)) continue;
      let v = null;
      for (const pid of [p.pai_id, p.mae_id]) if (pid && ano.has(pid)) v = Math.max(v ?? -1e9, ano.get(pid) + 25);
      if (v == null) {
        const filhos = [...P.values()].filter((f) => (f.pai_id === p.id || f.mae_id === p.id) && ano.has(f.id));
        if (filhos.length) v = Math.min(...filhos.map((f) => ano.get(f.id))) - 25;
      }
      if (v == null) for (const c of conj.get(p.id) || []) if (ano.has(c)) { v = ano.get(c); break; }
      if (v != null) { ano.set(p.id, v); estimado.add(p.id); mudou = true; }
    }
    if (!mudou) break;
  }
  for (const p of P.values()) if (!ano.has(p.id)) { ano.set(p.id, continuo(estado.anoCriacao)); estimado.add(p.id); }
  return { ano, estimado };
}

function conjugesPorPessoa() {
  const m = new Map();
  for (const c of estado.casamentos) {
    if (!estado.pessoas.has(c.marido_id) || !estado.pessoas.has(c.esposa_id)) continue;
    (m.get(c.marido_id) || m.set(c.marido_id, []).get(c.marido_id)).push(c.esposa_id);
    (m.get(c.esposa_id) || m.set(c.esposa_id, []).get(c.esposa_id)).push(c.marido_id);
  }
  return m;
}

function calcularLayout() {
  const P = estado.pessoas;
  const { ano, estimado } = anosEfetivos();
  const conj = conjugesPorPessoa();
  const tMin = Math.min(...ano.values(), continuo(estado.anoCriacao));
  const y = (id) => TOPO + (ano.get(id) - tMin) * estado.escala;

  const primario = (p) => (p.pai_id && P.has(p.pai_id) ? p.pai_id : p.mae_id && P.has(p.mae_id) ? p.mae_id : null);
  const filhosEmComum = (a, b) => [...P.values()].filter((f) =>
    (f.pai_id === a && f.mae_id === b) || (f.pai_id === b && f.mae_id === a)).length;

  // "anexar" pessoas ao lado do cônjuge: esposas sempre; homens só se não tiverem pais na árvore
  const anexadoA = new Map();
  const escolheConjuge = (id) => {
    const cs = conj.get(id) || [];
    return cs.slice().sort((a, b) => filhosEmComum(id, b) - filhosEmComum(id, a) || b - a)[0];
  };
  for (const p of P.values()) if (p.sexo === "F" && conj.has(p.id)) {
    const alvo = escolheConjuge(p.id);
    // evita ciclo: se o marido não tem pais e só tem ela, quem fica "na raiz" é ele
    anexadoA.set(p.id, alvo);
  }
  for (const p of P.values()) if (p.sexo === "M" && conj.has(p.id) && !primario(p)) {
    const alvo = escolheConjuge(p.id);
    if (anexadoA.get(alvo) !== p.id) anexadoA.set(p.id, alvo);
  }
  // quebra ciclos residuais (ex.: dois anexados entre si)
  for (const id of [...anexadoA.keys()]) {
    const vistos = new Set([id]); let a = anexadoA.get(id);
    while (a != null && anexadoA.has(a)) { if (vistos.has(a)) { anexadoA.delete(id); break; } vistos.add(a); a = anexadoA.get(a); }
  }
  const anexos = new Map();
  for (const [id, alvo] of anexadoA) (anexos.get(alvo) || anexos.set(alvo, []).get(alvo)).push(id);
  const membros = (id) => {   // grupo: a pessoa + quem está anexado a ela (recursivo), ordenado por ano
    const out = [id];
    const extras = (anexos.get(id) || []).slice().sort((a, b) => ano.get(a) - ano.get(b));
    for (const e of extras) out.push(...membros(e));
    return out;
  };

  const filhosDoGrupo = new Map();
  for (const p of P.values()) {
    if (anexadoA.has(p.id)) continue;
    const pr = primario(p);
    if (pr == null) continue;
    let dono = pr;                       // sobe até a "cabeça" do grupo
    while (anexadoA.has(dono)) dono = anexadoA.get(dono);
    (filhosDoGrupo.get(dono) || filhosDoGrupo.set(dono, []).get(dono)).push(p.id);
  }

  // ocupação: coluna -> lista de intervalos [y0,y1]
  const intervalo = (id) => [y(id) - FOLGA_Y, y(id) + CARD_H + FOLGA_Y];
  const livre = (ocup, col, [a, b]) => !(ocup.get(col) || []).some(([c, d]) => a < d && c < b);
  const ocupar = (ocup, col, iv) => (ocup.get(col) || ocup.set(col, []).get(col)).push(iv);

  /** devolve {nos: Map(id->col relativa), ocup: Map(col->intervalos)} */
  function montar(cabeca) {
    const grupo = membros(cabeca);
    const filhos = (filhosDoGrupo.get(cabeca) || []).slice().sort((a, b) => ano.get(a) - ano.get(b) || a - b);
    const nos = new Map(), ocup = new Map();
    let minimo = 0;
    const centros = [];
    for (const f of filhos) {
      const sub = montar(f);
      let d = minimo;
      while (true) {
        let ok = true;
        for (const [col, ivs] of sub.ocup) { for (const iv of ivs) if (!livre(ocup, col + d, iv)) { ok = false; break; } if (!ok) break; }
        if (ok) break;
        d++;
      }
      for (const [id, col] of sub.nos) nos.set(id, col + d);
      for (const [col, ivs] of sub.ocup) for (const iv of ivs) ocupar(ocup, col + d, iv);
      centros.push(nos.get(f));
      minimo = nos.get(f) + membros(f).length;   // mantém a ordem dos irmãos
    }
    // posiciona o grupo acima do primeiro filho (o mais velho), ou no lugar livre mais próximo
    const desejado = centros.length ? centros[0] : 0;
    const cabe = (x0) => grupo.every((id, i) => livre(ocup, x0 + i, intervalo(id)));
    let x0 = desejado;
    for (let k = 0; k < 500; k++) {
      if (cabe(desejado + k)) { x0 = desejado + k; break; }
      if (k && cabe(desejado - k)) { x0 = desejado - k; break; }
    }
    grupo.forEach((id, i) => { nos.set(id, x0 + i); ocupar(ocup, x0 + i, intervalo(id)); });
    // normaliza para começar na coluna 0
    const minCol = Math.min(...nos.values());
    if (minCol !== 0) {
      const n2 = new Map([...nos].map(([id, c]) => [id, c - minCol]));
      const o2 = new Map([...ocup].map(([c, ivs]) => [c - minCol, ivs]));
      return { nos: n2, ocup: o2 };
    }
    return { nos, ocup };
  }

  // raízes: sem pai/mãe na árvore e não anexadas. A maior árvore primeiro.
  const raizes = [...P.values()].filter((p) => !anexadoA.has(p.id) && primario(p) == null).map((p) => p.id);
  const arvores = raizes.map((r) => ({ r, ...montar(r) })).sort((a, b) => b.nos.size - a.nos.size || ano.get(a.r) - ano.get(b.r));

  // A árvore principal fica na coluna 0; as menores (ex.: Jetro, Quis) são ancoradas perto
  // de um parente já posicionado (filho, pai ou cônjuge), procurando o espaço livre mais próximo.
  const colGlobal = new Map(), ocupGlobal = new Map();
  const vizinhosReino = new Map();
  const porReino = new Map();
  for (const r of estado.reinados) (porReino.get(r.reino) || porReino.set(r.reino, []).get(r.reino)).push(r.pessoa_id);
  for (const lista of porReino.values()) lista.forEach((id, i) => {
    const v = vizinhosReino.get(id) || vizinhosReino.set(id, []).get(id);
    if (i > 0) v.push(lista[i - 1]);
    if (i < lista.length - 1) v.push(lista[i + 1]);
  });
  // papel com período e local (ex.: profeta em Judá a partir de 740 a.C.) -> rei que reinava então
  const reiDaEpoca = new Map();
  for (const pp of estado.papeis) {
    if (pp.inicio == null || reiDaEpoca.has(pp.pessoa_id)) continue;
    const r = estado.reinados.find((r) => (!pp.local || r.reino === pp.local) && r.inicio <= pp.inicio && pp.inicio <= r.fim && r.pessoa_id !== pp.pessoa_id);
    if (r) reiDaEpoca.set(pp.pessoa_id, r.pessoa_id);
  }
  const vizinhos = (id) => {
    const p = P.get(id), out = [p.pai_id, p.mae_id, ...(conj.get(id) || []), ...(vizinhosReino.get(id) || [])];
    if (reiDaEpoca.has(id)) out.push(reiDaEpoca.get(id));
    for (const f of P.values()) if (f.pai_id === id || f.mae_id === id) out.push(f.id);
    return out.filter((v) => v != null);
  };
  const cabeArvore = (arv, d) => {
    for (const [col, ivs] of arv.ocup) for (const iv of ivs) if (!livre(ocupGlobal, col + d, iv)) return false;
    return true;
  };
  // ordem: a maior árvore primeiro; depois, sempre a maior entre as que já têm um parente
  // (ou rei vizinho) posicionado — assim nenhuma dinastia cai longe por ter sido posta antes do vizinho
  const ancora = (arv) => {
    for (const [id, col] of arv.nos) {
      const v = vizinhos(id).find((n) => colGlobal.has(n));
      if (v != null) return colGlobal.get(v) - col;
    }
    return null;
  };
  const pendentes = arvores.slice();
  while (pendentes.length) {
    let i = colGlobal.size ? pendentes.findIndex((a) => ancora(a) != null) : 0;
    if (i < 0) i = 0;
    const arv = pendentes.splice(i, 1)[0];
    let alvo = ancora(arv);
    if (alvo == null && colGlobal.size) {
      // sem parente nem rei da época: perto de quem nasceu no ano mais próximo
      let melhor = null;
      for (const id of colGlobal.keys()) if (!melhor || Math.abs(ano.get(id) - ano.get(arv.r)) < Math.abs(ano.get(melhor) - ano.get(arv.r))) melhor = id;
      alvo = colGlobal.get(melhor) - arv.nos.get(arv.r);
    }
    alvo = alvo ?? 0;
    let d = alvo;
    for (let k = 0; k < 2000; k++) {
      if (cabeArvore(arv, alvo + k)) { d = alvo + k; break; }
      if (k && cabeArvore(arv, alvo - k)) { d = alvo - k; break; }
    }
    for (const [col, ivs] of arv.ocup) for (const iv of ivs) ocupar(ocupGlobal, col + d, iv);
    for (const [id, col] of arv.nos) colGlobal.set(id, col + d);
  }
  const minCol = Math.min(...colGlobal.values());
  const pos = new Map();
  for (const [id, col] of colGlobal) pos.set(id, { x: MARGEM_X + (col - minCol) * COL, y: y(id) });
  return { pos, tMin, tMax: Math.max(...ano.values()), estimado };
}

// ---------------------------------------------------------------- desenho
let layout = null;

function desenhar() {
  layout = calcularLayout();
  estado.pos = layout.pos;
  desenharGrade();
  desenharLinhas();
  desenharCards();
  aplicarTransform();
  aplicarFiltroDestaque();
  if (estado.selecionado) destacar(estado.selecionado);
}

const yDoAno = (t) => TOPO + (t - layout.tMin) * estado.escala;

function desenharGrade() {
  const g = $("#camada-grade");
  g.innerHTML = "";
  const xs = [...layout.pos.values()].map((p) => p.x);
  const x1 = Math.max(...xs, 0) + CARD_W + 400;
  const grade = el("g", { class: "grade" }, g);
  for (const ano of anosRedondos(layout.tMin, layout.tMax + 100, 100)) {
    const yy = yDoAno(continuo(ano));
    el("line", { x1: -100000, x2: x1 + 100000, y1: yy, y2: yy }, grade);
  }
  if ($("#mostrar-anos").checked) desenharAnosDosCards(g, x1);
  if (!$("#mostrar-eventos").checked) return;
  const ev = el("g", { class: "evento" }, g);
  for (const m of MARCOS) {
    const ano = m.ano ?? anoDesdeCriacao(m.am), yy = yDoAno(continuo(ano)), nome = m.nome;
    el("line", { x1: -100000, x2: x1 + 100000, y1: yy, y2: yy }, ev);
    const t = el("text", { x: MARGEM_X - 16, y: yy + 4, "text-anchor": "end" }, ev);
    t.textContent = `${nome} · ${fmtAno(ano)}`;
  }
}

/** linha pontilhada na altura de cada card (ano de nascimento) + o ano escrito junto ao card */
function desenharAnosDosCards(g, x1) {
  const linhas = el("g", { class: "anos-cards" }, g);
  const feitas = new Set();
  for (const p of estado.pessoas.values()) {
    const pos = layout.pos.get(p.id);
    if (!pos) continue;
    const yy = Math.round(pos.y);
    if (!feitas.has(yy)) {
      feitas.add(yy);
      el("line", { x1: -100000, x2: x1 + 100000, y1: yy, y2: yy }, linhas);
    }
    const t = el("text", { x: pos.x + 3, y: yy - 3 }, linhas);
    t.textContent = p.ano_nascimento == null ? "?" : fmtAno(p.ano_nascimento, p.nascimento_aprox);
  }
}

function caminho(x1, y1, x2, y2) {
  const my = (y1 + y2) / 2;
  return `M${x1},${y1} C${x1},${my} ${x2},${my} ${x2},${y2}`;
}

function desenharLinhas() {
  const g = $("#camada-linhas");
  g.innerHTML = "";
  const pos = layout.pos;
  for (const c of estado.casamentos) {
    const a = pos.get(c.marido_id), b = pos.get(c.esposa_id);
    if (!a || !b) continue;
    const [e, d] = a.x <= b.x ? [a, b] : [b, a];
    const x1 = e.x + CARD_W, y1 = e.y + CARD_H / 2, x2 = d.x, y2 = d.y + CARD_H / 2;
    el("path", { class: "lig casal", d: `M${x1},${y1} C${(x1 + x2) / 2},${y1} ${(x1 + x2) / 2},${y2} ${x2},${y2}`,
      "data-a": c.marido_id, "data-b": c.esposa_id }, g);
  }
  for (const p of estado.pessoas.values()) {
    const filho = pos.get(p.id);
    for (const [pid, tipo] of [[p.pai_id, "pai"], [p.mae_id, "mae"]]) {
      const pp = pid && pos.get(pid);
      if (!pp) continue;
      el("path", { class: `lig ${tipo}`, d: caminho(pp.x + CARD_W / 2, pp.y + CARD_H, filho.x + CARD_W / 2, filho.y),
        "data-a": pid, "data-b": p.id }, g);
    }
  }
  // filiação segundo outra fonte (ex.: Lucas): tracejada, com a fonte escrita perto do filho
  for (const f of estado.filiacoes) {
    const pp = pos.get(f.pai_id), filho = pos.get(f.filho_id);
    if (!pp || !filho) continue;
    const x1 = pp.x + CARD_W / 2, y1 = pp.y + CARD_H, x2 = filho.x + CARD_W / 2, y2 = filho.y;
    el("path", { class: "lig alt", d: caminho(x1, y1, x2, y2), "data-a": f.pai_id, "data-b": f.filho_id }, g);
    const t = el("text", { class: "rotulo-alt", x: (x1 + x2) / 2, y: (y1 + y2) / 2 - 5,
      "text-anchor": "middle", "data-a": f.pai_id, "data-b": f.filho_id }, g);
    t.textContent = f.fonte;
  }
}

function desenharCards() {
  const g = $("#camada-cards");
  g.innerHTML = "";
  for (const p of estado.pessoas.values()) {
    const { x, y } = layout.pos.get(p.id);
    const c = el("g", { class: `card ${p.sexo}${p.sem_nome ? " sem-nome" : ""}`, transform: `translate(${x},${y})`, "data-id": p.id }, g);
    el("rect", { class: "corpo", width: CARD_W, height: CARD_H, rx: 8 }, c);
    const temIdade = p.idade_morte != null;
    const nome = el("text", { class: "nome", x: CARD_W / 2, y: temIdade ? 19 : 27, "text-anchor": "middle" }, c);
    nome.textContent = p.nome;
    nome.setAttribute("font-size", Math.min(14, (CARD_W - 12) / (p.nome.length * 0.56)).toFixed(1));
    if (temIdade) {
      const idade = el("text", { class: "idade", x: CARD_W / 2, y: 35, "text-anchor": "middle" }, c);
      idade.textContent = `(\u2020 ${p.idade_morte})`;
    }
    const tip = el("title", {}, c);
    const anos = p.ano_nascimento == null ? "ano desconhecido" : fmtIntervalo(p);
    tip.textContent = `${p.nome}\n${anos}${p.resumo ? "\n" + p.resumo : ""}`;
  }
}

function desenharRegua() {
  const g = $("#regua");
  g.innerHTML = "";
  const alt = $("#tela").clientHeight;
  el("rect", { class: "fundo", x: 0, y: 0, width: 88, height: alt }, g);
  el("line", { x1: 88, x2: 88, y1: 0, y2: alt }, g);
  if (!layout) return;
  // passo adaptado ao zoom, para manter ~60px entre marcas
  const pxAno = estado.escala * estado.k;
  const passo = [10, 25, 50, 100, 250, 500, 1000].find((s) => s * pxAno >= 60) || 1000;
  const tDaTela = (sy) => (sy - estado.ty) / estado.k;
  const t0 = layout.tMin + (tDaTela(0) - TOPO) / estado.escala;
  const t1 = layout.tMin + (tDaTela(alt) - TOPO) / estado.escala;
  for (const ano of anosRedondos(t0, t1, passo)) {
    const sy = yDoAno(continuo(ano)) * estado.k + estado.ty;
    el("line", { x1: 74, x2: 88, y1: sy, y2: sy }, g);
    const tx = el("text", { x: 70, y: sy + 4, "text-anchor": "end" }, g);
    tx.textContent = ano === 1 ? "1 d.C." : fmtAno(ano);
  }
}

function aplicarTransform() {
  $("#mundo").setAttribute("transform", `translate(${estado.tx},${estado.ty}) scale(${estado.k})`);
  desenharRegua();
}

function destacar(id) {
  estado.selecionado = id;
  const p = estado.pessoas.get(id);
  const rel = new Set([id]);
  if (p) {
    for (const x of [p.pai_id, p.mae_id]) if (x) rel.add(x);
    for (const f of estado.pessoas.values()) if (f.pai_id === id || f.mae_id === id) rel.add(f.id);
    for (const c of estado.casamentos) {
      if (c.marido_id === id) rel.add(c.esposa_id);
      if (c.esposa_id === id) rel.add(c.marido_id);
    }
    for (const f of estado.filiacoes) {
      if (f.filho_id === id) rel.add(f.pai_id);
      if (f.pai_id === id) rel.add(f.filho_id);
    }
  }
  document.querySelectorAll(".card").forEach((c) => {
    const cid = +c.dataset.id;
    c.classList.toggle("selecionado", cid === id);
    c.classList.toggle("esmaecido", p && !rel.has(cid));
  });
  document.querySelectorAll(".lig, .rotulo-alt").forEach((l) => {
    const toca = +l.dataset.a === id || +l.dataset.b === id;
    l.classList.toggle("destaque", !!p && toca);
    l.classList.toggle("esmaecido", !!p && !toca);
  });
}

/** grupos do seletor "Destacar": Profetas, Juízes, Reis e rainhas, e outros papéis cadastrados */
function grupoDoPapel(papel) {
  if (/^profet/i.test(papel)) return "Profetas";
  if (/^ju[ií]z/i.test(papel)) return "Juízes";
  if (/^ap[oó]stol/i.test(papel)) return "Apóstolos";
  return papel;
}
function gruposDestaque() {
  const g = new Map();
  const add = (nome, id) => (g.get(nome) || g.set(nome, new Set()).get(nome)).add(id);
  for (const r of estado.papeis) add(grupoDoPapel(r.papel), r.pessoa_id);
  for (const r of estado.reinados) add("Reis e rainhas", r.pessoa_id);
  return g;
}
function atualizarOpcoesDestaque() {
  const sel = $("#destacar"), atual = sel.value || lerPref("destacar", "");
  const nomes = [...gruposDestaque().keys()].sort((a, b) => a.localeCompare(b, "pt"));
  sel.innerHTML = `<option value="">—</option>` + nomes.map((n) => `<option value="${esc(n)}">${esc(n)}</option>`).join("");
  sel.value = nomes.includes(atual) ? atual : "";
}
function aplicarFiltroDestaque() {
  const nome = $("#destacar").value;
  const ids = nome ? gruposDestaque().get(nome) || new Set() : null;
  document.querySelectorAll(".card").forEach((c) => {
    const dentro = ids && ids.has(+c.dataset.id);
    c.classList.toggle("no-filtro", !!dentro);
    c.classList.toggle("fora-filtro", !!ids && !dentro);
  });
}
function lerPref(k, padrao) { try { return localStorage.getItem(k) ?? padrao; } catch { return padrao; } }
function gravarPref(k, v) { try { localStorage.setItem(k, v); } catch {} }

function limparDestaque() {
  estado.selecionado = null;
  document.querySelectorAll(".esmaecido,.selecionado,.destaque").forEach((e) => e.classList.remove("esmaecido", "selecionado", "destaque"));
}

function centralizar(id, zoom) {
  const p = estado.pos.get(id);
  if (!p) return;
  const tela = $("#tela");
  if (zoom) estado.k = zoom;
  const larguraUtil = tela.clientWidth - ($("#painel").hidden ? 0 : $("#painel").clientWidth);
  estado.tx = larguraUtil / 2 - (p.x + CARD_W / 2) * estado.k;
  estado.ty = tela.clientHeight / 3 - p.y * estado.k;
  aplicarTransform();
}

// ---------------------------------------------------------------- interação (pan/zoom)
function configurarNavegacao() {
  const tela = $("#tela");
  let arrasto = null;
  tela.addEventListener("pointerdown", (e) => {
    arrasto = { x: e.clientX, y: e.clientY, tx: estado.tx, ty: estado.ty, moveu: false };
    tela.setPointerCapture(e.pointerId);
  });
  tela.addEventListener("pointermove", (e) => {
    if (!arrasto) return;
    const dx = e.clientX - arrasto.x, dy = e.clientY - arrasto.y;
    if (Math.abs(dx) + Math.abs(dy) > 3) { arrasto.moveu = true; tela.classList.add("arrastando"); }
    estado.tx = arrasto.tx + dx; estado.ty = arrasto.ty + dy;
    aplicarTransform();
  });
  tela.addEventListener("pointerup", (e) => {
    const a = arrasto; arrasto = null; tela.classList.remove("arrastando");
    if (a && !a.moveu) {
      const alvo = document.elementFromPoint(e.clientX, e.clientY)?.closest(".card");
      if (alvo) abrirPessoa(+alvo.dataset.id);
      else { limparDestaque(); fecharPainel(); }
    }
  });
  tela.addEventListener("wheel", (e) => {
    e.preventDefault();
    const r = tela.getBoundingClientRect();
    const mx = e.clientX - r.left, my = e.clientY - r.top;
    const f = Math.exp(-e.deltaY * 0.0015);
    const k = Math.min(3, Math.max(0.08, estado.k * f));
    estado.tx = mx - (mx - estado.tx) * (k / estado.k);
    estado.ty = my - (my - estado.ty) * (k / estado.k);
    estado.k = k;
    aplicarTransform();
  }, { passive: false });
  window.addEventListener("resize", desenharRegua);
}

// ---------------------------------------------------------------- painel de detalhes
const painel = () => $("#painel-conteudo");
function fecharPainel() { $("#painel").hidden = true; }
function linkPessoa(p) { return `<a class="pessoa ${p.sexo}" data-ir="${p.id}">${esc(p.nome)}</a>`; }

async function abrirPessoa(id, { centralizar: centra = false } = {}) {
  destacar(id);
  $("#painel").hidden = false;
  if (centra) centralizar(id);
  painel().innerHTML = "<p>Carregando…</p>";
  let p;
  try { p = await api("GET", `/api/pessoas/${id}`); } catch (e) { painel().innerHTML = `<p class="erro">${esc(e.message)}</p>`; return; }
  const vida = [];
  for (const r of p.papeis || []) {
    let periodo = "";
    if (r.inicio != null) periodo = r.fim == null || r.fim === r.inicio ? `~${fmtAno(r.inicio)}` : `~${fmtIntervalo({ ano_nascimento: r.inicio, ano_morte: r.fim })}`;
    vida.push(`<dt>${esc(r.papel)}</dt><dd>${r.local ? `em ${esc(r.local)}` : ""}${r.local && periodo ? ", " : ""}${periodo}${!r.local && !periodo ? "—" : ""}${r.observacao ? ` <small>(${esc(r.observacao)})</small>` : ""}
      <button class="x" title="Remover papel" data-del="papeis/${r.id}">✕</button></dd>`);
  }
  for (const r of p.reinados || []) {
    const titulo = r.reino === "Judá" ? (p.sexo === "F" ? "Rainha de Judá" : "Rei de Judá")
      : r.reino.startsWith("Israel (reino unido") ? "Rei de Israel (reino unido)" : (p.sexo === "F" ? "Rainha de Israel" : "Rei de Israel (norte)");
    const periodo = r.inicio === r.fim ? fmtAno(r.inicio) : fmtIntervalo({ ano_nascimento: r.inicio, ano_morte: r.fim });
    vida.push(`<dt>Reinado</dt><dd><strong>${esc(titulo)}</strong>, ${periodo}${r.observacao ? ` <small>(${esc(r.observacao)})</small>` : ""}
      <button class="x" title="Remover reinado" data-del="reinados/${r.reinado_id}">✕</button>
      ${r.ant_id ? `<br><small>Antecessor:</small> ${linkPessoa({ id: r.ant_id, nome: r.ant_nome, sexo: r.ant_sexo })}` : ""}
      ${r.suc_id ? `<br><small>Sucessor:</small> ${linkPessoa({ id: r.suc_id, nome: r.suc_nome, sexo: r.suc_sexo })}` : ""}</dd>`);
  }
  vida.push(`<dt>Nascimento</dt><dd>${fmtAno(p.ano_nascimento, p.nascimento_aprox)}</dd>`);
  if (p.ano_morte != null) vida.push(`<dt>Morte</dt><dd>${fmtAno(p.ano_morte, p.morte_aprox)}</dd>`);
  if (p.idade_morte) vida.push(`<dt>Viveu</dt><dd>${p.idade_morte} anos</dd>`);
  if (p.pai_id) vida.push(`<dt>Pai</dt><dd>${linkPessoa({ id: p.pai_id, nome: p.pai_nome, sexo: "M" })}</dd>`);
  if (p.mae_id) vida.push(`<dt>Mãe</dt><dd>${linkPessoa({ id: p.mae_id, nome: p.mae_nome, sexo: "F" })}</dd>`);
  if (p.conjuges.length) vida.push(`<dt>${p.conjuges.length > 1 ? "Cônjuges" : "Cônjuge"}</dt><dd>${p.conjuges.map((c) =>
    `${linkPessoa(c)}${c.observacao ? ` <small>(${esc(c.observacao)})</small>` : ""} <button class="x" title="Remover casamento" data-del="casamentos/${c.casamento_id}">✕</button>`).join("<br>")}</dd>`);
  for (const a of p.pais_alternativos || []) vida.push(`<dt>Pai segundo ${esc(a.fonte)}</dt><dd>${linkPessoa(a)}${a.observacao ? `<br><small>${esc(a.observacao)}</small>` : ""}
    <button class="x" title="Remover filiação" data-del="filiacoes_alternativas/${a.filiacao_id}">✕</button></dd>`);
  if (p.filhos.length) vida.push(`<dt>Filhos</dt><dd>${p.filhos.map(linkPessoa).join(", ")}</dd>`);
  for (const a of p.filhos_alternativos || []) vida.push(`<dt>Filho segundo ${esc(a.fonte)}</dt><dd>${linkPessoa(a)}</dd>`);

  painel().innerHTML = `
    <h2>${esc(p.nome)}</h2>
    <span class="faixa ${p.sexo}">${p.sexo === "M" ? "Homem" : "Mulher"}</span>
    ${p.significado_nome ? `<p class="significado">${esc(p.significado_nome)}</p>` : ""}
    ${p.resumo ? `<p class="resumo">${esc(p.resumo)}</p>` : ""}
    <dl>${vida.join("")}</dl>

    ${p.historia ? `<h3>História</h3><div class="historia">${p.historia.split(/\n\s*\n/).map((x) => `<p>${esc(x)}</p>`).join("")}</div>` : ""}

    <h3>Referências bíblicas</h3>
    <ul class="refs">${p.referencias.map((r) => `<li><a href="${esc(r.url)}" target="_blank" rel="noopener">${esc(r.texto)}</a>${r.descricao ? ` <span>— ${esc(r.descricao)}</span>` : ""} <button class="x" title="Remover" data-del="referencias/${r.id}">✕</button></li>`).join("") || "<li><em>Nenhuma ainda</em></li>"}</ul>
    <form class="mini-form" id="f-ref">
      <select name="livro">${estado.livros.map((l) => `<option value="${l.codigo}">${esc(l.nome)}</option>`).join("")}</select>
      <input class="n" name="capitulo" type="number" min="1" placeholder="cap" required>
      <input class="n" name="versiculo_inicio" type="number" min="1" placeholder="v.">
      <input class="n" name="versiculo_fim" type="number" min="1" placeholder="até">
      <input class="txt" name="descricao" placeholder="descrição (opcional)">
      <button class="mini">Adicionar</button>
    </form>

    <h3>Curiosidades</h3>
    <ul>${p.curiosidades.map((c) => `<li>${esc(c.texto)} <button class="x" title="Remover" data-del="curiosidades/${c.id}">✕</button></li>`).join("") || "<li><em>Nenhuma ainda</em></li>"}</ul>
    <form class="mini-form" id="f-cur"><input class="txt" name="texto" placeholder="Nova curiosidade" required><button class="mini">Adicionar</button></form>

    <h3>Links</h3>
    <ul>${p.links.map((l) => `<li><a href="${esc(l.url)}" target="_blank" rel="noopener">${esc(l.titulo)}</a> <button class="x" title="Remover" data-del="links/${l.id}">✕</button></li>`).join("") || "<li><em>Nenhum ainda</em></li>"}</ul>
    <form class="mini-form" id="f-link">
      <input class="txt" name="titulo" placeholder="Título" required>
      <input class="txt" name="url" type="url" placeholder="https://…" required>
      <button class="mini">Adicionar</button>
    </form>

    <div class="acoes">
      <button id="b-editar" class="primario">Editar</button>
      <button id="b-filho">+ Filho(a)</button>
      <button id="b-conjuge">+ Cônjuge</button>
      <button id="b-filiacao" title="Pai segundo outra fonte (ex.: Lucas)">+ Pai (outra fonte)</button>
      <button id="b-reinado">+ Reinado</button>
      <button id="b-papel" title="Profeta, profetisa, juiz…">+ Papel</button>
      <button id="b-centralizar">Centralizar</button>
      <button id="b-excluir" class="perigo">Excluir</button>
    </div>
    <p class="erro" id="painel-erro"></p>`;

  const recarregar = async () => { await carregar(); abrirPessoa(id); };
  const erro = (e) => ($("#painel-erro").textContent = e.message);
  const dados = (f) => Object.fromEntries([...new FormData(f)].map(([k, v]) => [k, v === "" ? null : v]));

  $("#f-ref").onsubmit = async (e) => {
    e.preventDefault();
    const d = dados(e.target);
    for (const k of ["capitulo", "versiculo_inicio", "versiculo_fim"]) d[k] = d[k] == null ? null : +d[k];
    try { await api("POST", `/api/pessoas/${id}/referencias`, { ...d, ordem: p.referencias.length }); recarregar(); } catch (x) { erro(x); }
  };
  $("#f-cur").onsubmit = async (e) => {
    e.preventDefault();
    try { await api("POST", `/api/pessoas/${id}/curiosidades`, { ...dados(e.target), ordem: p.curiosidades.length }); recarregar(); } catch (x) { erro(x); }
  };
  $("#f-link").onsubmit = async (e) => {
    e.preventDefault();
    try { await api("POST", `/api/pessoas/${id}/links`, { ...dados(e.target), ordem: p.links.length }); recarregar(); } catch (x) { erro(x); }
  };
  painel().querySelectorAll("[data-del]").forEach((b) => (b.onclick = async () => {
    if (!confirm("Remover este item?")) return;
    try { await api("DELETE", `/api/${b.dataset.del}`); recarregar(); } catch (x) { erro(x); }
  }));
  painel().querySelectorAll("[data-ir]").forEach((a) => (a.onclick = () => abrirPessoa(+a.dataset.ir, { centralizar: true })));
  $("#b-editar").onclick = () => formularioPessoa(p);
  $("#b-filho").onclick = () => formularioPessoa(null, p.sexo === "M" ? { pai_id: p.id } : { mae_id: p.id });
  $("#b-conjuge").onclick = () => formularioConjuge(p);
  $("#b-filiacao").onclick = () => formularioFiliacao(p);
  $("#b-reinado").onclick = () => formularioReinado(p);
  $("#b-papel").onclick = () => formularioPapel(p);
  $("#b-centralizar").onclick = () => centralizar(id);
  $("#b-excluir").onclick = async () => {
    if (!confirm(`Excluir ${p.nome}? Referências, curiosidades e casamentos dessa pessoa também serão apagados.`)) return;
    try { await api("DELETE", `/api/pessoas/${id}`); fecharPainel(); limparDestaque(); carregar(); } catch (x) { erro(x); }
  };
}

// ---------------------------------------------------------------- formulários
function opcoesPessoas(sexo, selecionado, excluir) {
  return `<option value="">—</option>` + [...estado.pessoas.values()]
    .filter((x) => x.sexo === sexo && x.id !== excluir)
    .sort((a, b) => a.nome.localeCompare(b.nome, "pt"))
    .map((x) => `<option value="${x.id}" ${x.id === selecionado ? "selected" : ""}>${esc(x.nome)} (${fmtAno(x.ano_nascimento, x.nascimento_aprox)})</option>`).join("");
}

function campoAno(nome, rotulo, ano, aprox) {
  const era = ano != null && ano > 0 ? "dC" : "aC";
  return `<label>${rotulo}<div class="ano">
      <input name="${nome}" type="number" min="1" value="${ano == null ? "" : Math.abs(ano)}" placeholder="ano">
      <select name="${nome}_era"><option value="aC" ${era === "aC" ? "selected" : ""}>a.C.</option><option value="dC" ${era === "dC" ? "selected" : ""}>d.C.</option></select>
      <label class="check"><input type="checkbox" name="${nome}_aprox" ${aprox ? "checked" : ""}> aprox.</label>
    </div></label>`;
}

function formularioPessoa(p, pre = {}) {
  const novo = !p;
  p = p || { nome: "", sexo: "M", nascimento_aprox: false, morte_aprox: false, ...pre };
  $("#painel").hidden = false;
  painel().innerHTML = `
    <h2>${novo ? "Nova pessoa" : "Editar " + esc(p.nome)}</h2>
    <form class="edicao" id="f-pessoa">
      <label>Nome<input name="nome" required value="${esc(p.nome)}"></label>
      <div class="linha">
        <label>Sexo<select name="sexo"><option value="M" ${p.sexo === "M" ? "selected" : ""}>Homem</option><option value="F" ${p.sexo === "F" ? "selected" : ""}>Mulher</option></select></label>
        <label>Idade ao morrer<input name="idade_morte" type="number" min="0" value="${p.idade_morte ?? ""}"></label>
      </div>
      ${campoAno("ano_nascimento", "Nascimento", p.ano_nascimento, p.nascimento_aprox)}
      ${campoAno("ano_morte", "Morte", p.ano_morte, p.morte_aprox)}
      <div class="linha">
        <label>Pai<select name="pai_id">${opcoesPessoas("M", p.pai_id, p.id)}</select></label>
        <label>Mãe<select name="mae_id">${opcoesPessoas("F", p.mae_id, p.id)}</select></label>
      </div>
      <label class="check" style="flex-direction:row;gap:6px;align-items:center"><input type="checkbox" name="sem_nome" style="width:auto" ${p.sem_nome ? "checked" : ""}> Sem nome (card de grupo, ex.: “Irmãs”)</label>
      <label>Significado do nome<input name="significado_nome" value="${esc(p.significado_nome)}"></label>
      <label>Resumo (uma linha)<input name="resumo" value="${esc(p.resumo)}"></label>
      <label>História<textarea name="historia" rows="8">${esc(p.historia)}</textarea></label>
      <div class="acoes" style="margin-top:4px">
        <button class="primario">Salvar</button>
        <button type="button" id="b-cancelar">Cancelar</button>
      </div>
      <p class="erro" id="painel-erro"></p>
    </form>`;
  $("#b-cancelar").onclick = () => (novo ? fecharPainel() : abrirPessoa(p.id));
  $("#f-pessoa").onsubmit = async (e) => {
    e.preventDefault();
    const f = new FormData(e.target);
    const ano = (n) => {
      const v = f.get(n);
      if (!v) return null;
      return f.get(`${n}_era`) === "aC" ? -Math.abs(+v) : Math.abs(+v);
    };
    const opt = (n) => (f.get(n) ? f.get(n) : null);
    const corpo = {
      nome: f.get("nome").trim(), sexo: f.get("sexo"),
      ano_nascimento: ano("ano_nascimento"), nascimento_aprox: f.has("ano_nascimento_aprox"),
      ano_morte: ano("ano_morte"), morte_aprox: f.has("ano_morte_aprox"),
      idade_morte: f.get("idade_morte") ? +f.get("idade_morte") : null, sem_nome: f.has("sem_nome"),
      pai_id: opt("pai_id") ? +f.get("pai_id") : null, mae_id: opt("mae_id") ? +f.get("mae_id") : null,
      significado_nome: opt("significado_nome"), resumo: opt("resumo"), historia: opt("historia"),
    };
    try {
      const r = novo ? await api("POST", "/api/pessoas", corpo) : await api("PUT", `/api/pessoas/${p.id}`, corpo);
      await carregar();
      abrirPessoa(r.id, { centralizar: true });
    } catch (x) { $("#painel-erro").textContent = x.message; }
  };
}

function formularioPapel(p) {
  const papeis = [...new Set(["Profeta", "Profetisa", "Juiz", "Juíza", "Sacerdote", "Sumo sacerdote", "Apóstolo", ...estado.papeis.map((r) => r.papel)])];
  const locais = [...new Set(["Israel (reino unido)", "Judá", "Israel (reino do norte)", ...estado.reinados.map((r) => r.reino)])];
  painel().innerHTML = `
    <h2>Papel de ${esc(p.nome)}</h2>
    <form class="edicao" id="f-papel">
      <label>Papel<input name="papel" list="lista-papeis" required value="${p.sexo === "F" ? "Profetisa" : "Profeta"}"></label>
      <datalist id="lista-papeis">${papeis.map((r) => `<option value="${esc(r)}">`).join("")}</datalist>
      ${campoAno("inicio", "Início da atuação (opcional)", null, false).replace(/<label class="check">.*?<\/label>/s, "")}
      ${campoAno("fim", "Fim (opcional)", null, false).replace(/<label class="check">.*?<\/label>/s, "")}
      <label>Onde atuou (opcional; posiciona a pessoa perto do rei da época)<input name="local" list="lista-locais"></label>
      <datalist id="lista-locais">${locais.map((r) => `<option value="${esc(r)}">`).join("")}</datalist>
      <label>Observação<input name="observacao"></label>
      <div class="acoes" style="margin-top:4px"><button class="primario">Salvar</button><button type="button" id="b-cancelar">Cancelar</button></div>
      <p class="erro" id="painel-erro"></p>
    </form>`;
  $("#b-cancelar").onclick = () => abrirPessoa(p.id);
  $("#f-papel").onsubmit = async (e) => {
    e.preventDefault();
    const f = new FormData(e.target);
    const ano = (n) => (!f.get(n) ? null : f.get(`${n}_era`) === "aC" ? -Math.abs(+f.get(n)) : Math.abs(+f.get(n)));
    const corpo = { papel: f.get("papel").trim(), inicio: ano("inicio"), fim: ano("fim"),
      local: (f.get("local") || "").trim() || null, observacao: f.get("observacao") || null };
    try { await api("POST", `/api/pessoas/${p.id}/papeis`, corpo); await carregar(); abrirPessoa(p.id); } catch (x) { $("#painel-erro").textContent = x.message; }
  };
}

function formularioReinado(p) {
  const reinos = [...new Set(["Israel (reino unido)", "Judá", "Israel (reino do norte)", ...estado.reinados.map((r) => r.reino)])];
  painel().innerHTML = `
    <h2>Reinado de ${esc(p.nome)}</h2>
    <form class="edicao" id="f-rei">
      <label>Reino<input name="reino" list="lista-reinos" required value="Judá"></label>
      <datalist id="lista-reinos">${reinos.map((r) => `<option value="${esc(r)}">`).join("")}</datalist>
      ${campoAno("inicio", "Início", null, false).replace(/<label class="check">.*?<\/label>/s, "")}
      ${campoAno("fim", "Fim", null, false).replace(/<label class="check">.*?<\/label>/s, "")}
      <label>Observação (ex.: corregência)<input name="observacao"></label>
      <div class="acoes" style="margin-top:4px"><button class="primario">Salvar</button><button type="button" id="b-cancelar">Cancelar</button></div>
      <p class="erro" id="painel-erro"></p>
    </form>`;
  $("#b-cancelar").onclick = () => abrirPessoa(p.id);
  $("#f-rei").onsubmit = async (e) => {
    e.preventDefault();
    const f = new FormData(e.target);
    const ano = (n) => (f.get(`${n}_era`) === "aC" ? -Math.abs(+f.get(n)) : Math.abs(+f.get(n)));
    if (!f.get("inicio") || !f.get("fim")) { $("#painel-erro").textContent = "Informe início e fim."; return; }
    const corpo = { reino: f.get("reino").trim(), inicio: ano("inicio"), fim: ano("fim"), observacao: f.get("observacao") || null };
    try { await api("POST", `/api/pessoas/${p.id}/reinados`, corpo); await carregar(); abrirPessoa(p.id); } catch (x) { $("#painel-erro").textContent = x.message; }
  };
}

function formularioFiliacao(p) {
  painel().innerHTML = `
    <h2>Pai de ${esc(p.nome)} segundo outra fonte</h2>
    <p><small>Use quando um texto bíblico dá outro pai a esta pessoa (ex.: Lucas 3:23 dá Eli como pai de José;
    Mateus 1:16 dá Jacó). O pai principal continua o do cadastro; este aparece como linha tracejada.</small></p>
    <form class="edicao" id="f-fil">
      <label>Pai<select name="pai_id" required>${opcoesPessoas("M", null, p.id)}</select></label>
      <label>Fonte<input name="fonte" required placeholder="ex.: Lucas 3:23"></label>
      <label>Observação<input name="observacao"></label>
      <div class="acoes" style="margin-top:4px"><button class="primario">Salvar</button><button type="button" id="b-cancelar">Cancelar</button></div>
      <p class="erro" id="painel-erro"></p>
    </form>`;
  $("#b-cancelar").onclick = () => abrirPessoa(p.id);
  $("#f-fil").onsubmit = async (e) => {
    e.preventDefault();
    const f = new FormData(e.target);
    const corpo = { filho_id: p.id, pai_id: +f.get("pai_id"), fonte: f.get("fonte").trim(), observacao: f.get("observacao") || null };
    try { await api("POST", "/api/filiacoes", corpo); await carregar(); abrirPessoa(p.id); } catch (x) { $("#painel-erro").textContent = x.message; }
  };
}

function formularioConjuge(p) {
  const sexoOutro = p.sexo === "M" ? "F" : "M";
  painel().innerHTML = `
    <h2>Cônjuge de ${esc(p.nome)}</h2>
    <form class="edicao" id="f-conj">
      <label>${sexoOutro === "F" ? "Esposa" : "Marido"}<select name="outro" required>${opcoesPessoas(sexoOutro, null, p.id)}</select></label>
      <label>Observação (ex.: concubina, primeiro marido)<input name="observacao"></label>
      <div class="acoes" style="margin-top:4px"><button class="primario">Salvar</button><button type="button" id="b-cancelar">Cancelar</button></div>
      <p class="erro" id="painel-erro"></p>
    </form>
    <p><small>A pessoa ainda não existe? Cadastre-a primeiro em “+ Nova pessoa”.</small></p>`;
  $("#b-cancelar").onclick = () => abrirPessoa(p.id);
  $("#f-conj").onsubmit = async (e) => {
    e.preventDefault();
    const f = new FormData(e.target);
    const outro = +f.get("outro");
    const corpo = { marido_id: p.sexo === "M" ? p.id : outro, esposa_id: p.sexo === "F" ? p.id : outro, observacao: f.get("observacao") || null };
    try { await api("POST", "/api/casamentos", corpo); await carregar(); abrirPessoa(p.id); } catch (x) { $("#painel-erro").textContent = x.message; }
  };
}

// ---------------------------------------------------------------- inicialização
function atualizarRotuloEscala() {
  $("#escala-valor").textContent = `${estado.escala} px/ano`;
}

function irParaInicio() {
  const adao = [...estado.pessoas.values()].find((p) => p.pai_id == null && p.mae_id == null && p.sexo === "M" &&
    p.ano_nascimento === estado.anoCriacao) || [...estado.pessoas.values()][0];
  if (adao) centralizar(adao.id, 1);
}

async function iniciar() {
  configurarNavegacao();
  atualizarRotuloEscala();
  $("#fechar-painel").onclick = () => { fecharPainel(); limparDestaque(); };
  $("#btn-nova").onclick = () => formularioPessoa(null);
  $("#btn-ajustar").onclick = irParaInicio;
  $("#mostrar-eventos").onchange = desenhar;
  $("#destacar").onchange = (e) => { gravarPref("destacar", e.target.value); aplicarFiltroDestaque(); };
  try { const v = localStorage.getItem("mostrarAnos"); if (v != null) $("#mostrar-anos").checked = v === "1"; } catch {}
  $("#mostrar-anos").onchange = (e) => {
    try { localStorage.setItem("mostrarAnos", e.target.checked ? "1" : "0"); } catch {}
    desenhar();
  };
  $("#escala").oninput = (e) => {
    // mantém o centro da tela no mesmo ano ao mudar a escala
    const tela = $("#tela"), cy = tela.clientHeight / 2;
    const t = layout.tMin + ((cy - estado.ty) / estado.k - TOPO) / estado.escala;
    estado.escala = +e.target.value;
    atualizarRotuloEscala();
    desenhar();
    estado.ty = cy - yDoAno(t) * estado.k;
    aplicarTransform();
  };
  $("#busca").addEventListener("change", (e) => {
    const nome = e.target.value.trim().toLowerCase();
    const p = [...estado.pessoas.values()].find((x) => x.nome.toLowerCase() === nome)
      || [...estado.pessoas.values()].find((x) => x.nome.toLowerCase().includes(nome));
    if (p) abrirPessoa(p.id, { centralizar: true });
  });
  await carregar();
  irParaInicio();
}

iniciar().catch((e) => { document.body.insertAdjacentHTML("beforeend", `<p class="erro" style="position:fixed;top:60px;left:20px">${esc(e.message)}</p>`); });
