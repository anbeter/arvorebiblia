"""Popula o banco com livros da Bíblia e os personagens iniciais.

Uso:  python db/seed.py [--forcar]   (recria o schema e insere tudo; --forcar se já houver dados)

Calendário: cristão (Anno Domini), a.C./d.C., sem ano zero (1 a.C. é seguido de 1 d.C.).
No banco, anos a.C. são negativos (-4026 = 4026 a.C.) e anos d.C. positivos.

Para facilitar a cronologia de Gênesis, os nascimentos aqui são escritos em "anos desde
a criação de Adão" e convertidos para a.C./d.C. usando ANO_CRIACAO (padrão -4026).
Nos textos, o marcador {AM:930} vira o ano correspondente (ex.: "3096 a.C.").
Para mudar a data-base, basta alterar ANO_CRIACAO no .env e rodar de novo.
Cronologia: Gn 5 e 11 (texto massorético); Abraão nasce com Terá aos 130 anos (At 7:4),
seguindo a mesma harmonização de Ussher, apenas deslocada para a base 4026 a.C.
"""
import os
import re
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "backend"))
from db import cursor  # noqa: E402

ANO_CRIACAO = int(os.getenv("ANO_CRIACAO", "-4026"))

LIVROS = [  # codigo, nome, abrev, nome_en
    ("GEN", "Gênesis", "Gn", "Genesis"), ("EXO", "Êxodo", "Êx", "Exodus"),
    ("LEV", "Levítico", "Lv", "Leviticus"), ("NUM", "Números", "Nm", "Numbers"),
    ("DEU", "Deuteronômio", "Dt", "Deuteronomy"), ("JOS", "Josué", "Js", "Joshua"),
    ("JUI", "Juízes", "Jz", "Judges"), ("RUT", "Rute", "Rt", "Ruth"),
    ("1SA", "1 Samuel", "1Sm", "1 Samuel"), ("2SA", "2 Samuel", "2Sm", "2 Samuel"),
    ("1RE", "1 Reis", "1Rs", "1 Kings"), ("2RE", "2 Reis", "2Rs", "2 Kings"),
    ("1CR", "1 Crônicas", "1Cr", "1 Chronicles"), ("2CR", "2 Crônicas", "2Cr", "2 Chronicles"),
    ("ESD", "Esdras", "Ed", "Ezra"), ("NEE", "Neemias", "Ne", "Nehemiah"),
    ("EST", "Ester", "Et", "Esther"), ("JO", "Jó", "Jó", "Job"),
    ("SAL", "Salmos", "Sl", "Psalms"), ("PRO", "Provérbios", "Pv", "Proverbs"),
    ("ECL", "Eclesiastes", "Ec", "Ecclesiastes"), ("CNT", "Cânticos", "Ct", "Song of Songs"),
    ("ISA", "Isaías", "Is", "Isaiah"), ("JER", "Jeremias", "Jr", "Jeremiah"),
    ("LAM", "Lamentações", "Lm", "Lamentations"), ("EZE", "Ezequiel", "Ez", "Ezekiel"),
    ("DAN", "Daniel", "Dn", "Daniel"), ("OSE", "Oséias", "Os", "Hosea"),
    ("JOE", "Joel", "Jl", "Joel"), ("AMO", "Amós", "Am", "Amos"),
    ("OBA", "Obadias", "Ob", "Obadiah"), ("JON", "Jonas", "Jn", "Jonah"),
    ("MIQ", "Miquéias", "Mq", "Micah"), ("NAU", "Naum", "Na", "Nahum"),
    ("HAB", "Habacuque", "Hc", "Habakkuk"), ("SOF", "Sofonias", "Sf", "Zephaniah"),
    ("AGE", "Ageu", "Ag", "Haggai"), ("ZAC", "Zacarias", "Zc", "Zechariah"),
    ("MAL", "Malaquias", "Ml", "Malachi"),
    ("MAT", "Mateus", "Mt", "Matthew"), ("MAR", "Marcos", "Mc", "Mark"),
    ("LUC", "Lucas", "Lc", "Luke"), ("JOA", "João", "Jo", "John"),
    ("ATO", "Atos", "At", "Acts"), ("ROM", "Romanos", "Rm", "Romans"),
    ("1CO", "1 Coríntios", "1Co", "1 Corinthians"), ("2CO", "2 Coríntios", "2Co", "2 Corinthians"),
    ("GAL", "Gálatas", "Gl", "Galatians"), ("EFE", "Efésios", "Ef", "Ephesians"),
    ("FIL", "Filipenses", "Fp", "Philippians"), ("COL", "Colossenses", "Cl", "Colossians"),
    ("1TS", "1 Tessalonicenses", "1Ts", "1 Thessalonians"), ("2TS", "2 Tessalonicenses", "2Ts", "2 Thessalonians"),
    ("1TI", "1 Timóteo", "1Tm", "1 Timothy"), ("2TI", "2 Timóteo", "2Tm", "2 Timothy"),
    ("TIT", "Tito", "Tt", "Titus"), ("FLM", "Filemom", "Fm", "Philemon"),
    ("HEB", "Hebreus", "Hb", "Hebrews"), ("TIA", "Tiago", "Tg", "James"),
    ("1PE", "1 Pedro", "1Pe", "1 Peter"), ("2PE", "2 Pedro", "2Pe", "2 Peter"),
    ("1JO", "1 João", "1Jo", "1 John"), ("2JO", "2 João", "2Jo", "2 John"),
    ("3JO", "3 João", "3Jo", "3 John"), ("JUD", "Judas", "Jd", "Jude"),
    ("APO", "Apocalipse", "Ap", "Revelation"),
]

def am_para_ano(am):
    """Anos desde a criação -> ano a.C. (negativo) / d.C. (positivo), sem ano zero."""
    if am is None:
        return None
    ano = ANO_CRIACAO + am
    return ano + 1 if ano >= 0 else ano


def somar_anos(ano, n):
    """soma n anos a um ano civil, pulando o inexistente ano zero"""
    c = (ano + 1 if ano < 0 else ano) + n
    return c - 1 if c <= 0 else c


def fmt_ano(ano):
    return f"{-ano} a.C." if ano < 0 else f"{ano} d.C."


def txt(s):
    return None if s is None else re.sub(r"\{AM:(\d+)\}", lambda m: fmt_ano(am_para_ano(int(m.group(1)))), s)


PESSOAS = []
CASAMENTOS = []


def P(chave, nome, sexo, am=None, aprox=False, idade=None, morte_am=None, morte_aprox=None,
      pai=None, mae=None, sig=None, resumo=None, historia=None, refs=(), cur=(), links=(),
      ano=None, morte=None, sem_nome=False):
    """am = nascimento em anos desde Adão; ano = nascimento já em a.C./d.C. (negativo = a.C.).
    idade = anos vividos (calcula a morte quando ela não é informada)."""
    nasc = ano if ano is not None else am_para_ano(am)
    if morte is None and morte_am is not None:
        morte = am_para_ano(morte_am)
    if morte is None and idade is not None and nasc is not None:
        morte = somar_anos(nasc, idade)
    if morte_aprox is None:
        morte_aprox = aprox
    PESSOAS.append(dict(chave=chave, nome=nome, sexo=sexo, nasc=nasc, sem_nome=sem_nome, aprox=aprox, idade=idade,
                        morte=morte, morte_aprox=morte_aprox, pai=pai, mae=mae, sig=sig,
                        resumo=resumo, historia=historia, refs=refs, cur=cur, links=links))


def C(marido, esposa, obs=None):
    CASAMENTOS.append((marido, esposa, obs))


REF_RE = re.compile(r"^(\w+) (\d+)(?::(\d+))?(?:-(\d+)(?::(\d+))?)?$")


def parse_ref(s):
    """'GEN 5:1-5|descrição', 'GEN 6:1-9:29', 'GEN 3'."""
    txt, _, desc = s.partition("|")
    m = REF_RE.match(txt.strip())
    if not m:
        raise ValueError(f"Referência inválida: {s}")
    livro, cap, vi, a, b = m.groups()
    cap = int(cap)
    vi = int(vi) if vi else None
    cap_fim = vf = None
    if b:            # cap:v-cap2:v2
        cap_fim, vf = int(a), int(b)
    elif a:          # cap:v-v2  (ou cap-cap2 quando não há versículo)
        if vi is None:
            cap_fim = int(a)
        else:
            vf = int(a)
    return livro, cap, vi, cap_fim, vf, (desc.strip() or None)


# =============================================================================
# Da criação ao dilúvio
# =============================================================================
P("adao", "Adão", "M", 0, idade=930,
  sig="“Homem”; ligado a ’adamah, “terra”, “solo”.",
  resumo="O primeiro homem, formado do pó da terra.",
  historia="Formado por Deus do pó da terra e animado pelo fôlego de vida (Gn 2:7), Adão foi colocado no jardim do Éden para cultivá-lo e guardá-lo. Deu nome aos animais e recebeu Eva como auxiliadora idônea.\n\nAo comer do fruto da árvore do conhecimento do bem e do mal, junto com Eva, trouxe o pecado e a morte à humanidade, e o casal foi expulso do Éden. Gerou Caim, Abel, Sete e “outros filhos e filhas” (Gn 5:4), vivendo 930 anos.\n\nNo Novo Testamento, Paulo apresenta Cristo como “o último Adão”, aquele que reverte o que entrou no mundo pelo primeiro.",
  refs=["GEN 1:26-31|Criação do homem à imagem de Deus", "GEN 2:7-25|Formação de Adão e o jardim do Éden",
        "GEN 3|A queda", "GEN 5:1-5|Genealogia e morte", "LUC 3:38|Na genealogia de Jesus",
        "ROM 5:12-21|Adão e Cristo", "1CO 15:45-49|“O último Adão”"],
  cur=["Pela cronologia adotada, Adão ainda vivia quando Lameque, pai de Noé, nasceu ({AM:874}); Adão morreu em {AM:930}",
       "Gênesis 5:3 diz que Sete foi gerado “à semelhança e conforme a imagem” de Adão, eco de Gn 1:26.",
       "Lucas 3:38 encerra a genealogia de Jesus em “Adão, filho de Deus”."])
P("eva", "Eva", "F", 0,
  sig="“Vivente”, “vida”: “mãe de todos os viventes” (Gn 3:20).",
  resumo="A primeira mulher, mãe de todos os viventes.",
  historia="Formada por Deus a partir da costela de Adão (Gn 2:21-22), Eva foi apresentada a ele como companheira; Adão a reconheceu como “osso dos meus ossos e carne da minha carne”.\n\nEnganada pela serpente, comeu do fruto proibido e o deu a Adão. No juízo que se seguiu, Deus anunciou que a descendência da mulher feriria a cabeça da serpente (Gn 3:15), a primeira promessa de redenção. Foi mãe de Caim, Abel e Sete.",
  refs=["GEN 2:18-25|Criação da mulher", "GEN 3:1-20|A tentação e a queda", "GEN 4:1-2|Nascimento de Caim e Abel",
        "GEN 4:25|Nascimento de Sete", "2CO 11:3|O engano da serpente", "1TI 2:13-14"],
  cur=["Gn 3:15 é chamado de “protoevangelho”, a primeira promessa do Redentor.",
       "Antes da queda ela é chamada apenas ’ishah, “varoa”/“mulher” (Gn 2:23); o nome Eva só é dado em Gn 3:20.",
       "A Bíblia não registra a idade nem a morte de Eva."])
P("caim", "Caim", "M", 26, aprox=True, pai="adao", mae="eva",
  sig="“Adquirido”: “Adquiri um varão com o auxílio do Senhor” (Gn 4:1).",
  resumo="Primogênito de Adão; matou o irmão Abel.",
  historia="Lavrador, Caim trouxe ao Senhor uma oferta do fruto da terra, que não foi aceita, enquanto a de Abel foi. Irado, matou o irmão no campo, o primeiro homicídio da Bíblia.\n\nCondenado a ser fugitivo e errante, recebeu de Deus um sinal de proteção e habitou na terra de Node, ao oriente do Éden, onde edificou uma cidade e lhe deu o nome do filho, Enoque.",
  refs=["GEN 4:1-17|Oferta, homicídio e exílio", "HEB 11:4", "1JO 3:12|“Não como Caim, que era do maligno”", "JUD 1:11|“O caminho de Caim”"],
  cur=["A primeira cidade mencionada na Bíblia foi edificada por Caim (Gn 4:17).",
       "A “marca de Caim” era um sinal de proteção, para que ninguém o matasse (Gn 4:15).",
       "Ano de nascimento aproximado: a Bíblia não informa o intervalo entre a criação e o nascimento de Caim."])
P("abel", "Abel", "M", 28, aprox=True, morte_am=129, morte_aprox=True, pai="adao", mae="eva",
  sig="“Sopro”, “vapor” (hebel).",
  resumo="Pastor de ovelhas, o primeiro justo assassinado.",
  historia="Pastor de ovelhas, Abel ofereceu ao Senhor as primícias do seu rebanho e da gordura deste, e a oferta foi aceita. Foi morto pelo irmão Caim por inveja.\n\nHebreus o coloca como o primeiro da galeria da fé: “pela fé Abel ofereceu a Deus mais excelente sacrifício do que Caim” e, “depois de morto, ainda fala”.",
  refs=["GEN 4:2-10|Oferta e morte", "MAT 23:35|“Desde o sangue de Abel, o justo”", "HEB 11:4", "HEB 12:24|O sangue de Jesus fala melhor que o de Abel"],
  cur=["Hebel é a mesma palavra traduzida como “vaidade” em Eclesiastes (“vaidade de vaidades”).",
       "Jesus cita Abel como o primeiro justo assassinado da história (Mt 23:35).",
       "A data da morte é estimada: antes do nascimento de Sete ({AM:130}), dado “em lugar de Abel” (Gn 4:25)."])

# Linhagem de Caim (anos aproximados: Gn 4 não traz idades)
P("enoque_caim", "Enoque (filho de Caim)", "M", 90, aprox=True, pai="caim",
  resumo="Filho de Caim; deu nome à primeira cidade.", refs=["GEN 4:17-18"],
  cur=["Não confundir com Enoque, o sétimo depois de Adão, que andou com Deus (Gn 5:18-24)."])
P("irade", "Irade", "M", 150, aprox=True, pai="enoque_caim", resumo="Neto de Caim.", refs=["GEN 4:18"])
P("meujael", "Meujael", "M", 210, aprox=True, pai="irade", resumo="Descendente de Caim.", refs=["GEN 4:18"])
P("metusael", "Metusael", "M", 270, aprox=True, pai="meujael", resumo="Pai de Lameque, da linhagem de Caim.", refs=["GEN 4:18"])
P("lameque_caim", "Lameque (de Caim)", "M", 340, aprox=True, pai="metusael",
  resumo="Primeiro polígamo registrado; autor do “cântico da espada”.",
  historia="Descendente de Caim na quinta geração, Lameque tomou duas mulheres, Ada e Zilá, o primeiro caso de poligamia na Bíblia. Seu poema às esposas (Gn 4:23-24) celebra a vingança: “se Caim há de ser vingado sete vezes, Lameque, setenta vezes sete”.",
  refs=["GEN 4:18-24"],
  cur=["Jesus inverte a lógica de Lameque ao mandar perdoar “setenta vezes sete” (Mt 18:22).",
       "Não confundir com Lameque, pai de Noé (Gn 5:25-31)."])
P("ada", "Ada", "F", 345, aprox=True, resumo="Esposa de Lameque; mãe de Jabal e Jubal.", refs=["GEN 4:19-21"])
P("zila", "Zilá", "F", 350, aprox=True, resumo="Esposa de Lameque; mãe de Tubalcaim e Naamá.", refs=["GEN 4:19", "GEN 4:22-23"])
P("jabal", "Jabal", "M", 410, aprox=True, pai="lameque_caim", mae="ada",
  resumo="Pai dos que habitam em tendas e criam gado.", refs=["GEN 4:20"])
P("jubal", "Jubal", "M", 412, aprox=True, pai="lameque_caim", mae="ada",
  resumo="Pai dos que tocam harpa e flauta.", refs=["GEN 4:21"],
  cur=["É o primeiro músico citado na Bíblia."])
P("tubalcaim", "Tubalcaim", "M", 415, aprox=True, pai="lameque_caim", mae="zila",
  resumo="Artífice de instrumentos de bronze e ferro.", refs=["GEN 4:22"])
P("naama_caim", "Naamá (irmã de Tubalcaim)", "F", 418, aprox=True, pai="lameque_caim", mae="zila",
  resumo="Uma das poucas mulheres nomeadas antes do dilúvio.", refs=["GEN 4:22"])
C("adao", "eva")
C("lameque_caim", "ada")
C("lameque_caim", "zila")

# Linhagem de Sete (Gn 5)
P("sete", "Sete", "M", 130, idade=912, pai="adao", mae="eva",
  sig="“Designado”, “concedido”: “Deus me deu outro descendente em lugar de Abel” (Gn 4:25).",
  resumo="Filho dado a Adão e Eva em lugar de Abel.",
  historia="Nascido quando Adão tinha 130 anos, Sete foi visto por Eva como um substituto de Abel. Dele descende a linhagem que chega a Noé e, através de Sem e Abraão, ao Messias.",
  refs=["GEN 4:25-26", "GEN 5:3-8|Genealogia", "1CR 1:1", "LUC 3:38"],
  cur=["É o único filho de Adão, além de Caim e Abel, cujo nome a Bíblia registra."])
P("enos", "Enos", "M", 235, idade=905, pai="sete", sig="“Homem” (no sentido de mortal, frágil).",
  resumo="Em seus dias começou-se a invocar o nome do Senhor.",
  refs=["GEN 4:26", "GEN 5:6-11", "LUC 3:38"],
  cur=["“Então se começou a invocar o nome do Senhor” (Gn 4:26): o primeiro registro de culto público."])
P("caina", "Cainã", "M", 325, idade=910, pai="enos", resumo="Filho de Enos.", refs=["GEN 5:9-14", "LUC 3:37"])
P("maalalel", "Maalalel", "M", 395, idade=895, pai="caina", sig="“Louvor de Deus”.",
  resumo="Filho de Cainã.", refs=["GEN 5:12-17", "LUC 3:37"])
P("jarede", "Jarede", "M", 460, idade=962, pai="maalalel", sig="“Descida”.",
  resumo="Pai de Enoque; o segundo mais longevo da Bíblia.", refs=["GEN 5:15-20", "LUC 3:37"],
  cur=["Viveu 962 anos, perdendo apenas para o neto Metusalém (969)."])
P("enoque", "Enoque", "M", 622, idade=365, pai="jarede", sig="“Consagrado”, “dedicado”.",
  resumo="Andou com Deus e foi tomado sem ver a morte.",
  historia="O sétimo a partir de Adão, Enoque “andou com Deus” por trezentos anos depois de gerar Metusalém. Não morreu: “não apareceu mais, porquanto Deus para si o tomou” (Gn 5:24).\n\nHebreus o cita como exemplo de fé que agradou a Deus, e Judas registra uma profecia sua sobre o juízo vindouro.",
  refs=["GEN 5:18-24", "HEB 11:5|Trasladado pela fé", "JUD 1:14-15|Profecia de Enoque", "LUC 3:37"],
  cur=["O ano de “morte” indica quando foi tomado por Deus, não uma morte.",
       "Viveu 365 anos, o mesmo número de dias do ano solar.",
       "Junto com Elias (2Rs 2:11), é um dos dois homens que, segundo a Bíblia, não passaram pela morte."])
P("metusalem", "Metusalém", "M", 687, idade=969, pai="enoque",
  sig="Tradicionalmente “homem do dardo”; uma leitura popular sugere “quando ele morrer, virá”.",
  resumo="O homem mais longevo da Bíblia: 969 anos.", refs=["GEN 5:21-27", "LUC 3:37"],
  cur=["É a pessoa mais longeva registrada na Bíblia (Gn 5:27).",
       "Somando as idades de Gn 5, Metusalém morreu no próprio ano do dilúvio ({AM:1656})."])
P("lameque", "Lameque", "M", 874, idade=777, pai="metusalem", resumo="Pai de Noé.",
  refs=["GEN 5:25-31", "LUC 3:36"],
  cur=["Chamou o filho de Noé dizendo: “Este nos consolará acerca de nossas obras” (Gn 5:29).",
       "Morreu cinco anos antes do dilúvio, aos 777 anos."])
P("noe", "Noé", "M", 1056, idade=950, pai="lameque", sig="“Descanso”, “consolo”.",
  resumo="Justo em sua geração; construiu a arca e sobreviveu ao dilúvio.",
  historia="Em meio a uma humanidade corrompida, “Noé achou graça aos olhos do Senhor” (Gn 6:8). Por ordem de Deus construiu a arca, na qual entrou com a esposa, os três filhos, as noras e os animais.\n\nO dilúvio veio quando Noé tinha 600 anos. Ao sair da arca, ofereceu sacrifício, e Deus estabeleceu com ele e com toda a terra a aliança do arco-íris. Depois plantou uma vinha e se embriagou, episódio que levou à maldição de Canaã. Viveu 350 anos após o dilúvio.",
  refs=["GEN 5:28-32", "GEN 6:1-9:29|Dilúvio e aliança", "MAT 24:37-39|“Como nos dias de Noé”",
        "HEB 11:7", "1PE 3:20", "2PE 2:5|“Pregador da justiça”"],
  cur=["A arca media 300 × 50 × 30 côvados, cerca de 135 × 22 × 13 metros (Gn 6:15).",
       "Pela cronologia adotada, o dilúvio ocorreu em {AM:1656}",
       "Noé morreu em {AM:2006}, apenas dois anos antes do nascimento de Abraão."])
P("jafe", "Jafé", "M", 1556, aprox=True, pai="noe", sig="“Ampliação”: “Alargue Deus a Jafé” (Gn 9:27).",
  resumo="Filho de Noé; pai dos povos do norte e das ilhas.", refs=["GEN 5:32", "GEN 9:18-27", "GEN 10:2-5"],
  cur=["A tradição associa seus descendentes aos povos da Ásia Menor e da Europa."])
P("sem", "Sem", "M", 1558, idade=600, pai="noe", sig="“Nome”, “renome”.",
  resumo="Filho de Noé; ancestral de Abraão e de Israel.",
  historia="Sem e Jafé cobriram a nudez do pai com respeito, e Noé o abençoou: “Bendito seja o Senhor, Deus de Sem” (Gn 9:26). Dele vêm os povos semitas, entre eles os hebreus.",
  refs=["GEN 9:18-27", "GEN 10:21-31", "GEN 11:10-11", "LUC 3:36"],
  cur=["Dele vem o termo “semita”.",
       "Pela cronologia de Gn 11, Sem viveu até {AM:2158}: foi contemporâneo de Abraão por 150 anos."])
P("cam", "Cam", "M", 1560, aprox=True, pai="noe", sig="“Quente”.",
  resumo="Filho mais novo de Noé; pai de Cuxe, Mizraim, Pute e Canaã.", refs=["GEN 9:18-27", "GEN 10:6-20"],
  cur=["Na poesia dos Salmos, o Egito é chamado de “terra de Cam” (Sl 105:23)."])

# =============================================================================
# Tábua das nações (Gn 10) — datas aproximadas
# =============================================================================
for i, (ch, nome, res) in enumerate([
    ("gomer", "Gômer", "Associado aos cimérios."), ("magogue", "Magogue", "Citado em Ez 38-39 e Ap 20:8."),
    ("madai", "Madai", "Ancestral dos medos."), ("java", "Javã", "Ancestral dos gregos (jônios)."),
    ("tubal", "Tubal", "Povo da Ásia Menor."), ("meseque", "Meseque", "Povo da Ásia Menor."),
    ("tiras", "Tiras", "Filho de Jafé.")]):
    P(ch, nome, "M", 1658 + i * 2, aprox=True, pai="jafe", resumo=res, refs=["GEN 10:2", "1CR 1:5"])
P("cuxe", "Cuxe", "M", 1660, aprox=True, pai="cam", resumo="Ancestral dos etíopes; pai de Ninrode.", refs=["GEN 10:6-8"])
P("mizraim", "Mizraim", "M", 1662, aprox=True, pai="cam", resumo="Ancestral dos egípcios.", refs=["GEN 10:6", "GEN 10:13-14"],
  cur=["Mizraim é o nome hebraico do Egito em todo o Antigo Testamento."])
P("pute", "Pute", "M", 1664, aprox=True, pai="cam", resumo="Associado à Líbia.", refs=["GEN 10:6"])
P("canaa", "Canaã", "M", 1666, aprox=True, pai="cam", resumo="Ancestral dos cananeus.",
  refs=["GEN 9:20-27|A maldição de Canaã", "GEN 10:15-19"],
  cur=["A terra prometida a Abraão leva o nome deste neto de Noé."])
P("ninrode", "Ninrode", "M", 1700, aprox=True, pai="cuxe",
  resumo="“Poderoso caçador diante do Senhor”; fundador de Babel e Nínive.",
  historia="Ninrode foi “o primeiro a ser poderoso na terra”. O princípio do seu reino foi Babel, Ereque, Acade e Calné, na terra de Sinar; dali saiu para a Assíria, onde edificou Nínive (Gn 10:8-12).",
  refs=["GEN 10:8-12", "1CR 1:10", "MIQ 5:6|“A terra de Ninrode”"],
  cur=["A tradição judaica o liga à construção da Torre de Babel, embora Gn 11 não o cite."])

# =============================================================================
# De Sem a Abraão (Gn 11)
# =============================================================================
P("arfaxade", "Arfaxade", "M", 1658, idade=438, pai="sem", resumo="Nascido dois anos após o dilúvio.",
  refs=["GEN 11:10-13", "LUC 3:36"],
  cur=["Lucas 3:36 inclui um Cainã entre Arfaxade e Selá, seguindo a Septuaginta."])
P("sela", "Selá", "M", 1693, idade=433, pai="arfaxade", resumo="Filho de Arfaxade.", refs=["GEN 11:12-15", "LUC 3:35"])
P("heber", "Héber", "M", 1723, idade=464, pai="sela", resumo="Ancestral epônimo dos hebreus.",
  refs=["GEN 10:21", "GEN 10:24-25", "GEN 11:14-17", "LUC 3:35"],
  cur=["É a provável origem do termo “hebreu” (‘ibri).",
       "Pela cronologia de Gn 11, Héber morreu em {AM:2187}, depois do próprio Abraão."])
P("pelegue", "Pelegue", "M", 1757, idade=239, pai="heber", sig="“Divisão”.",
  resumo="“Nos seus dias se repartiu a terra.”", refs=["GEN 10:25", "GEN 11:16-19", "LUC 3:35"],
  cur=["A divisão da terra em seus dias é ligada por muitos intérpretes à dispersão de Babel (Gn 11:1-9)."])
P("jocta", "Joctã", "M", 1760, aprox=True, pai="heber", resumo="Irmão de Pelegue; pai de 13 povos da Arábia.",
  refs=["GEN 10:25-30"])
P("reu", "Reú", "M", 1787, idade=239, pai="pelegue", resumo="Filho de Pelegue.", refs=["GEN 11:18-21", "LUC 3:35"])
P("serugue", "Serugue", "M", 1819, idade=230, pai="reu", resumo="Filho de Reú.", refs=["GEN 11:20-23", "LUC 3:35"])
P("naor_avo", "Naor (avô de Abraão)", "M", 1849, idade=148, pai="serugue", resumo="Pai de Terá.", refs=["GEN 11:22-25", "LUC 3:34"])
P("tera", "Terá", "M", 1878, idade=205, pai="naor_avo", resumo="Pai de Abraão, Naor e Harã; saiu de Ur rumo a Canaã.",
  historia="Terá vivia em Ur dos caldeus. Com o filho Abrão, a nora Sarai e o neto Ló, partiu em direção a Canaã, mas se estabeleceu em Harã, onde morreu aos 205 anos.",
  refs=["GEN 11:24-32", "JOS 24:2|“Serviram a outros deuses”", "ATO 7:2-4"],
  cur=["Josué 24:2 afirma que Terá servia a outros deuses além do rio.",
       "Gn 11:26 diz que Terá tinha 70 anos quando “gerou Abrão, Naor e Harã”. Como At 7:4 diz que Abraão saiu de Harã após a morte do pai, a cronologia adotada considera Abraão nascido quando Terá tinha 130 anos."])
P("hara", "Harã", "M", 1948, aprox=True, pai="tera", resumo="Irmão de Abraão; pai de Ló e Milca. Morreu em Ur.",
  refs=["GEN 11:26-31"], cur=["É a primeira morte registrada de um filho antes do pai (Gn 11:28)."])
P("naor", "Naor (irmão de Abraão)", "M", 1950, aprox=True, pai="tera", resumo="Avô de Rebeca e bisavô de Lia e Raquel.",
  refs=["GEN 11:26-29", "GEN 22:20-24", "GEN 24:15"])
P("milca", "Milca", "F", 1985, aprox=True, pai="hara", resumo="Esposa de Naor; avó de Rebeca.", refs=["GEN 11:29", "GEN 22:20-23"],
  cur=["Casou-se com o próprio tio, Naor."])
P("lo", "Ló", "M", 1990, aprox=True, pai="hara", resumo="Sobrinho de Abraão; escapou da destruição de Sodoma.",
  historia="Ló acompanhou Abraão de Harã a Canaã. Quando os rebanhos cresceram demais, escolheu a planície do Jordão e foi morar em Sodoma. Abraão o resgatou de uma coalizão de reis e intercedeu pela cidade.\n\nNa destruição de Sodoma e Gomorra, anjos o tiraram da cidade; sua mulher olhou para trás e virou uma estátua de sal. De suas filhas nasceram Moabe e Ben-Ami, pais dos moabitas e amonitas.",
  refs=["GEN 13:1-13|Separação de Abraão", "GEN 14:12-16|Resgatado por Abraão", "GEN 19|Sodoma e Gomorra",
        "LUC 17:28-32|“Lembrai-vos da mulher de Ló”", "2PE 2:7-8|“O justo Ló”"],
  cur=["Pedro o chama de “justo Ló”, que se afligia com a conduta dos sodomitas (2Pe 2:7)."])
P("moabe", "Moabe", "M", 2110, aprox=True, pai="lo", mae="irma_lo_velha", resumo="Pai dos moabitas.", refs=["GEN 19:36-37"],
  cur=["Rute, bisavó de Davi, era moabita."])
P("benami", "Ben-Ami", "M", 2111, aprox=True, pai="lo", mae="irma_lo_nova", resumo="Pai dos amonitas.", refs=["GEN 19:38"],
  cur=["Naamá, mãe do rei Roboão, era amonita (1Rs 14:21)."])
C("naor", "milca")

# =============================================================================
# Patriarcas
# =============================================================================
P("abraao", "Abraão", "M", 2008, idade=175, pai="tera",
  sig="Abrão = “pai exaltado”; Abraão = “pai de uma multidão” (Gn 17:5).",
  resumo="Pai da fé; chamado por Deus para sair de Ur rumo a Canaã.",
  historia="Chamado por Deus aos 75 anos para deixar sua terra e sua parentela, Abrão recebeu a promessa de se tornar uma grande nação e de que nele seriam benditas todas as famílias da terra (Gn 12:1-3).\n\nDeus fez aliança com ele, mudou seu nome para Abraão e instituiu a circuncisão. Teve Ismael com Agar e, aos 100 anos, Isaque com Sara, o filho da promessa. Sua fé foi provada no monte Moriá, quando se dispôs a oferecer Isaque. Morreu aos 175 anos e foi sepultado na caverna de Macpela.",
  refs=["GEN 11:26-12:9|Chamado", "GEN 15|Aliança e justificação pela fé", "GEN 17|Circuncisão e mudança de nome",
        "GEN 22:1-19|O sacrifício de Isaque", "GEN 25:7-10|Morte", "ROM 4|Justificado pela fé",
        "GAL 3:6-9", "HEB 11:8-19", "TIA 2:21-23|“Amigo de Deus”"],
  cur=["É chamado de “amigo de Deus” (2Cr 20:7; Is 41:8; Tg 2:23).",
       "Judeus, cristãos e muçulmanos o reconhecem como patriarca.",
       "“Creu Abrão no Senhor, e isso lhe foi imputado como justiça” (Gn 15:6) é citado três vezes no NT."])
P("sara", "Sara", "F", 2018, idade=127, pai="tera",
  sig="Sarai/Sara = “princesa”.",
  resumo="Esposa e meia-irmã de Abraão; mãe de Isaque aos 90 anos.",
  historia="Estéril por muitos anos, Sarai deu sua serva Agar a Abrão para ter filhos por meio dela. Deus, porém, prometeu que a própria Sara seria mãe de nações. Ela riu ao ouvir a promessa, mas aos 90 anos deu à luz Isaque, cujo nome significa “riso”. Morreu aos 127 anos em Hebrom.",
  refs=["GEN 11:29-31", "GEN 12:10-20", "GEN 16|Agar", "GEN 18:9-15|O riso de Sara", "GEN 21:1-7|Nascimento de Isaque",
        "GEN 23|Morte e sepultura", "HEB 11:11", "1PE 3:6"],
  cur=["Era meia-irmã de Abraão, filha de Terá com outra mulher (Gn 20:12).",
       "É a única mulher na Bíblia cuja idade ao morrer é registrada (127 anos, Gn 23:1)."])
P("agar", "Agar", "F", 2060, aprox=True, resumo="Serva egípcia de Sara; mãe de Ismael.",
  historia="Serva egípcia de Sara, Agar foi dada a Abrão como concubina e concebeu Ismael. Fugindo de Sara, foi encontrada pelo Anjo do Senhor no deserto, e chamou a Deus de “El-Roi”, o Deus que me vê. Mais tarde foi despedida com o filho, e Deus os sustentou no deserto.",
  refs=["GEN 16|“O Deus que me vê”", "GEN 21:8-21|Despedida", "GAL 4:21-31|Alegoria das duas alianças"],
  cur=["É a primeira pessoa na Bíblia a dar um nome a Deus: El-Roi (Gn 16:13)."])
P("ismael", "Ismael", "M", 2094, idade=137, pai="abraao", mae="agar", sig="“Deus ouve”.",
  resumo="Primogênito de Abraão; pai de doze príncipes.", refs=["GEN 16:11-16", "GEN 17:18-26", "GEN 21:9-21", "GEN 25:12-18"],
  cur=["Assim como Jacó, teve doze filhos que se tornaram chefes de tribos (Gn 25:16).",
       "Ismael e Isaque sepultaram juntos o pai Abraão (Gn 25:9)."])
P("isaque", "Isaque", "M", 2108, idade=180, pai="abraao", mae="sara", sig="“Ele ri”.",
  resumo="Filho da promessa; quase sacrificado no monte Moriá.",
  historia="Nascido quando Abraão tinha 100 anos e Sara 90, Isaque foi o herdeiro da aliança. Ainda jovem, foi levado ao monte Moriá, onde Deus proveu um carneiro em seu lugar. Casou-se aos 40 anos com Rebeca e, vinte anos depois, foi pai dos gêmeos Esaú e Jacó.",
  refs=["GEN 21:1-7", "GEN 22:1-19", "GEN 24|Casamento com Rebeca", "GEN 26", "GEN 27|A bênção roubada", "GEN 35:28-29|Morte", "HEB 11:17-20"],
  cur=["Foi o patriarca que viveu mais tempo (180 anos) e o que menos se afastou de Canaã.",
       "Gálatas 4:28 apresenta os cristãos como “filhos da promessa, como Isaque”."])
P("betuel", "Betuel", "M", 2040, aprox=True, pai="naor", mae="milca", resumo="Pai de Rebeca e Labão.", refs=["GEN 22:22-23", "GEN 24:15", "GEN 24:50"])
P("labao", "Labão", "M", 2120, aprox=True, pai="betuel", resumo="Irmão de Rebeca; sogro de Jacó.",
  refs=["GEN 24:29-31", "GEN 29:1-30|Jacó serve por Raquel", "GEN 31|Separação de Jacó"],
  cur=["Enganou Jacó dando-lhe Lia no lugar de Raquel, e mudou seu salário dez vezes (Gn 31:7)."])
P("rebeca", "Rebeca", "F", 2128, aprox=True, pai="betuel", resumo="Esposa de Isaque; mãe de Esaú e Jacó.",
  historia="O servo de Abraão a encontrou junto ao poço, quando ela se ofereceu para dar água também aos seus camelos, sinal que ele havia pedido a Deus. Aceitou ir para Canaã e casar-se com Isaque. Grávida de gêmeos, recebeu o oráculo de que “o mais velho servirá ao mais moço”, e mais tarde ajudou Jacó a obter a bênção de Isaque.",
  refs=["GEN 24|O servo e o poço", "GEN 25:20-28", "GEN 27|A bênção", "ROM 9:10-13"],
  cur=["Para dar água a dez camelos ela pode ter carregado centenas de litros do poço."])
P("esau", "Esaú", "M", 2168, pai="isaque", mae="rebeca", sig="“Peludo”; também chamado Edom, “vermelho”.",
  resumo="Gêmeo de Jacó; vendeu a primogenitura; pai dos edomitas.",
  refs=["GEN 25:24-34|Venda da primogenitura", "GEN 27", "GEN 33|Reconciliação com Jacó", "GEN 36", "HEB 12:16-17"],
  cur=["Vendeu a primogenitura por um prato de guisado vermelho (Gn 25:30-34).",
       "Herodes, o Grande, era idumeu, descendente de Edom."])
P("jaco", "Jacó (Israel)", "M", 2168, idade=147, pai="isaque", mae="rebeca",
  sig="Jacó = “segura o calcanhar”/“suplantador”; Israel = “luta com Deus” (Gn 32:28).",
  resumo="Pai das doze tribos; recebeu o nome Israel.",
  historia="Nasceu segurando o calcanhar de Esaú. Obteve a primogenitura e a bênção paterna, e fugiu para Harã, tendo no caminho o sonho da escada em Betel. Serviu a Labão vinte anos e casou-se com Lia e Raquel; com elas e as servas Bila e Zilpa teve doze filhos e uma filha.\n\nNo retorno, lutou com Deus em Peniel e recebeu o nome Israel. Na velhice desceu ao Egito para reencontrar José, onde morreu aos 147 anos.",
  refs=["GEN 25:19-34", "GEN 27-28|A bênção e Betel", "GEN 29-30|Casamentos e filhos", "GEN 32:22-32|Luta em Peniel",
        "GEN 46-49|Descida ao Egito e bênçãos", "HEB 11:21"],
  cur=["Serviu catorze anos por Raquel, “e lhe pareceram como poucos dias, pelo muito que a amava” (Gn 29:20).",
       "Desceu ao Egito com 130 anos (Gn 47:9), em {AM:2298} pela cronologia adotada."])
C("abraao", "sara")
C("abraao", "agar", "Concubina, dada por Sara")
C("isaque", "rebeca")

# Esposas e filhos de Jacó
P("lia", "Lia", "F", 2215, aprox=True, pai="labao", resumo="Primeira esposa de Jacó; mãe de Levi e Judá.",
  refs=["GEN 29:16-35", "GEN 30:9-21", "GEN 49:31|Sepultada em Macpela", "RUT 4:11"],
  cur=["Embora menos amada, foi mãe da tribo sacerdotal (Levi) e da tribo real (Judá)."])
P("raquel", "Raquel", "F", 2220, aprox=True, morte_am=2275, pai="labao", resumo="Esposa amada de Jacó; mãe de José e Benjamim.",
  refs=["GEN 29:9-30", "GEN 30:22-24", "GEN 35:16-20|Morte no parto de Benjamim", "JER 31:15", "MAT 2:18|“Raquel chora por seus filhos”"],
  cur=["Morreu ao dar à luz Benjamim, a caminho de Belém, e foi sepultada ali (Gn 35:19)."])
P("bila", "Bila", "F", 2220, aprox=True, resumo="Serva de Raquel; mãe de Dã e Naftali.", refs=["GEN 29:29", "GEN 30:3-8"])
P("zilpa", "Zilpa", "F", 2220, aprox=True, resumo="Serva de Lia; mãe de Gade e Aser.", refs=["GEN 29:24", "GEN 30:9-13"])
C("jaco", "lia")
C("jaco", "raquel")
C("jaco", "bila", "Concubina")
C("jaco", "zilpa", "Concubina")
for ch, nome, am, mae, sig, ref in [
    ("ruben", "Rúben", 2252, "lia", "“Vede, um filho”", "GEN 29:32"),
    ("simeao", "Simeão", 2253, "lia", "“Ouvido”", "GEN 29:33"),
    ("da", "Dã", 2254, "bila", "“Juiz”", "GEN 30:6"),
    ("gade", "Gade", 2255, "zilpa", "“Sorte”, “fortuna”", "GEN 30:11"),
    ("naftali", "Naftali", 2256, "bila", "“Minha luta”", "GEN 30:8"),
    ("aser", "Aser", 2257, "zilpa", "“Feliz”", "GEN 30:13"),
    ("issacar", "Issacar", 2257, "lia", "“Recompensa”", "GEN 30:18"),
    ("zebulom", "Zebulom", 2258, "lia", "“Morada”", "GEN 30:20"),
]:
    P(ch, nome, "M", am, aprox=True, pai="jaco", mae=mae, sig=sig, resumo="Filho de Jacó; patriarca de uma das tribos de Israel.",
      refs=[ref, "GEN 49|Bênção de Jacó"])
P("levi", "Levi", "M", 2254, aprox=True, idade=137, pai="jaco", mae="lia", sig="“Unido”",
  resumo="Patriarca da tribo sacerdotal.", refs=["GEN 29:34", "GEN 34:25-31|Vingança de Siquém", "EXO 6:16", "GEN 49:5-7"],
  cur=["Seus descendentes não receberam território: “o Senhor é a sua herança” (Dt 10:9)."])
P("juda", "Judá", "M", 2255, aprox=True, pai="jaco", mae="lia", sig="“Louvor”",
  resumo="Patriarca da tribo real, de Davi e do Messias.",
  historia="Quarto filho de Lia, Judá propôs vender José aos ismaelitas em vez de matá-lo. Mais tarde, no episódio com Tamar, reconheceu: “Mais justa é ela do que eu”. No Egito, ofereceu-se como escravo no lugar de Benjamim, mostrando arrependimento. Jacó profetizou que o cetro não se arredaria de Judá.",
  refs=["GEN 29:35", "GEN 37:26-27", "GEN 38|Judá e Tamar", "GEN 44:18-34|Intercede por Benjamim", "GEN 49:8-12|“O cetro não se arredará”", "APO 5:5|“O Leão da tribo de Judá”"],
  cur=["O termo “judeu” vem do seu nome."])
P("dina", "Diná", "F", 2258, aprox=True, pai="jaco", mae="lia", sig="“Julgada”", resumo="Única filha de Jacó cujo nome é registrado.",
  refs=["GEN 30:21", "GEN 34"])
P("jose", "José", "M", 2259, idade=110, pai="jaco", mae="raquel", sig="“Que Ele acrescente”",
  resumo="Vendido pelos irmãos, tornou-se governador do Egito.",
  historia="Filho amado de Jacó, recebeu uma túnica especial e teve sonhos de que os irmãos se curvariam diante dele. Por inveja, foi vendido como escravo e levado ao Egito, onde serviu na casa de Potifar e foi preso injustamente.\n\nAo interpretar os sonhos do faraó, foi feito governador de todo o Egito aos 30 anos e administrou os sete anos de fartura e os sete de fome. Reencontrou os irmãos, perdoou-os e trouxe toda a família ao Egito: “Vós intentastes o mal contra mim; porém Deus o tornou em bem” (Gn 50:20).",
  refs=["GEN 37|Sonhos e venda", "GEN 39-41|Potifar, prisão e governo", "GEN 42-45|Os irmãos no Egito", "GEN 50:15-26|Perdão e morte", "HEB 11:22", "ATO 7:9-16"],
  cur=["Pediu que seus ossos fossem levados a Canaã; Moisés os levou no Êxodo e eles foram sepultados em Siquém (Js 24:32).",
       "Recebeu do faraó o nome egípcio Zafenate-Paneia (Gn 41:45)."])
P("benjamim", "Benjamim", "M", 2275, aprox=True, pai="jaco", mae="raquel", sig="“Filho da mão direita”",
  resumo="Caçula de Jacó; Raquel morreu no seu parto.", refs=["GEN 35:16-18", "GEN 42-45", "GEN 49:27"],
  cur=["Raquel o chamou de Benoni, “filho da minha dor”; Jacó mudou o nome para Benjamim.",
       "O rei Saul e o apóstolo Paulo eram da tribo de Benjamim (Fp 3:5)."])

P("asenate", "Asenate", "F", 2270, aprox=True, resumo="Esposa egípcia de José, filha de Potífera, sacerdote de Om.", refs=["GEN 41:45-50"])
C("jose", "asenate")
P("manasses", "Manassés", "M", 2290, aprox=True, pai="jose", mae="asenate", sig="“Que faz esquecer”",
  resumo="Primogênito de José.", refs=["GEN 41:51", "GEN 48|Jacó abençoa os filhos de José"])
P("efraim", "Efraim", "M", 2292, aprox=True, pai="jose", mae="asenate", sig="“Frutífero”",
  resumo="Filho de José; abençoado acima do irmão mais velho.", refs=["GEN 41:52", "GEN 48:13-20"],
  cur=["Jacó cruzou as mãos e pôs a direita sobre Efraim, o mais novo (Gn 48:14)."])

# =============================================================================
# Linhagem de Judá até Davi e Salomão
# =============================================================================
P("batsua", "Bate-Sua", "F", 2255, aprox=True, resumo="Esposa cananeia de Judá, filha de Sua.", refs=["GEN 38:2-5", "GEN 38:12", "1CR 2:3"])
P("er", "Er", "M", 2272, aprox=True, pai="juda", mae="batsua", resumo="Primogênito de Judá; mau aos olhos do Senhor.", refs=["GEN 38:3-7"])
P("ona", "Onã", "M", 2274, aprox=True, pai="juda", mae="batsua", resumo="Filho de Judá; recusou dar descendência ao irmão.", refs=["GEN 38:4", "GEN 38:8-10"])
P("sela_juda", "Selá (filho de Judá)", "M", 2276, aprox=True, pai="juda", mae="batsua", resumo="Terceiro filho de Judá.", refs=["GEN 38:5", "GEN 38:11-14"])
P("tamar", "Tamar", "F", 2280, aprox=True, resumo="Nora de Judá; mãe de Perez e Zerá.",
  historia="Viúva de Er e depois de Onã, Tamar foi deixada sem o filho prometido. Disfarçada, concebeu do próprio sogro Judá, que, confrontado com seu selo e cajado, reconheceu: “Mais justa é ela do que eu” (Gn 38:26). Teve os gêmeos Perez e Zerá.",
  refs=["GEN 38", "RUT 4:12", "MAT 1:3|Na genealogia de Jesus"],
  cur=["É uma das quatro mulheres citadas na genealogia de Jesus em Mateus, ao lado de Raabe, Rute e “a que fora mulher de Urias”."])
C("juda", "batsua")
C("juda", "tamar")
C("er", "tamar", "Primeiro marido")
P("perez", "Perez", "M", 2297, aprox=True, pai="juda", mae="tamar", sig="“Rompimento”",
  resumo="Gêmeo que “rompeu” à frente do irmão; ancestral de Davi.", refs=["GEN 38:27-30", "RUT 4:18", "MAT 1:3"])
P("zera", "Zerá", "M", 2297, aprox=True, pai="juda", mae="tamar", sig="“Brilho”", resumo="Gêmeo de Perez.", refs=["GEN 38:27-30"],
  cur=["A parteira amarrou um fio escarlate em sua mão, mas Perez nasceu primeiro (Gn 38:28-30)."])
P("hezrom", "Hezrom", "M", 2320, aprox=True, pai="perez", resumo="Neto de Judá.", refs=["GEN 46:12", "RUT 4:18-19", "1CR 2:5", "MAT 1:3"])
P("rao", "Rão", "M", 2360, aprox=True, pai="hezrom", resumo="Ancestral de Davi.", refs=["RUT 4:19", "1CR 2:9-10", "MAT 1:3-4"])
P("aminadabe", "Aminadabe", "M", 2400, aprox=True, pai="rao", resumo="Pai de Naassom e de Eliseba, esposa de Arão.",
  refs=["RUT 4:19-20", "EXO 6:23", "MAT 1:4"])
P("naassom", "Naassom", "M", 2440, aprox=True, pai="aminadabe", resumo="Príncipe da tribo de Judá no deserto.",
  refs=["NUM 1:7", "NUM 7:12-17|Primeira oferta do altar", "RUT 4:20", "MAT 1:4"],
  cur=["Foi o primeiro líder tribal a apresentar oferta na dedicação do altar (Nm 7:12)."])
P("salmom", "Salmom", "M", 2510, aprox=True, pai="naassom", resumo="Marido de Raabe; pai de Boaz.", refs=["RUT 4:20-21", "MAT 1:4-5"])
P("raabe", "Raabe", "F", 2525, aprox=True, resumo="Cananeia de Jericó que escondeu os espias de Israel.",
  historia="Moradora de Jericó, Raabe escondeu os dois espias enviados por Josué, confessando que o Senhor era Deus “em cima nos céus e embaixo na terra” (Js 2:11). Um cordão escarlate em sua janela poupou ela e sua família na queda da cidade. Integrou-se a Israel e tornou-se ancestral de Davi.",
  refs=["JOS 2|Os espias", "JOS 6:22-25|Poupada na queda de Jericó", "MAT 1:5", "HEB 11:31", "TIA 2:25"],
  cur=["É citada tanto em Hebreus 11 (pela fé) quanto em Tiago 2 (pelas obras)."])
C("salmom", "raabe")
P("boaz", "Boaz", "M", 2570, aprox=True, pai="salmom", mae="raabe", sig="“Nele há força”",
  resumo="Parente-resgatador que se casou com Rute.",
  historia="Rico proprietário de Belém, Boaz acolheu Rute em seus campos na época da colheita. Como parente-resgatador (go’el), resgatou a herança de Elimeleque e casou-se com Rute, tornando-se pai de Obede, avô de Davi.",
  refs=["RUT 2|Rute nos campos de Boaz", "RUT 3", "RUT 4|O resgate", "MAT 1:5"],
  cur=["É um dos exemplos bíblicos do “resgatador”, figura usada para falar de Cristo.",
       "Uma das colunas do templo de Salomão recebeu o nome de Boaz (1Rs 7:21)."])
P("elimeleque", "Elimeleque", "M", 2560, aprox=True, sig="“Meu Deus é rei”", resumo="Marido de Noemi; morreu em Moabe.", refs=["RUT 1:1-3"])
P("noemi", "Noemi", "F", 2565, aprox=True, sig="“Agradável”", resumo="Sogra de Rute.", refs=["RUT 1", "RUT 4:14-17"],
  cur=["De volta a Belém, pediu: “Não me chameis Noemi; chamai-me Mara (amarga)” (Rt 1:20)."])
C("elimeleque", "noemi")
P("malom", "Malom", "M", 2590, aprox=True, pai="elimeleque", mae="noemi", resumo="Primeiro marido de Rute; morreu em Moabe.", refs=["RUT 1:2-5", "RUT 4:10"])
P("quiliom", "Quiliom", "M", 2592, aprox=True, pai="elimeleque", mae="noemi", resumo="Filho de Noemi; marido de Orfa.", refs=["RUT 1:2-5"])
P("rute", "Rute", "F", 2610, aprox=True, sig="Possivelmente “amizade”, “companheira”.",
  resumo="Moabita fiel à sogra; bisavó do rei Davi.",
  historia="Viúva de Malom, a moabita Rute recusou-se a deixar a sogra Noemi: “o teu povo é o meu povo, e o teu Deus é o meu Deus” (Rt 1:16). Em Belém, recolheu espigas nos campos de Boaz, que a resgatou e se casou com ela. Seu filho Obede foi avô de Davi.",
  refs=["RUT 1:16-17|“Aonde quer que fores, irei eu”", "RUT 2-4", "MAT 1:5"],
  cur=["É uma das duas mulheres que dão nome a um livro da Bíblia (a outra é Ester).",
       "Sendo moabita, descendia de Ló, sobrinho de Abraão."])
C("malom", "rute", "Primeiro marido")
C("boaz", "rute")
P("obede", "Obede", "M", 2640, aprox=True, pai="boaz", mae="rute", sig="“Servo”", resumo="Avô de Davi.",
  refs=["RUT 4:13-17", "RUT 4:21-22", "MAT 1:5"],
  cur=["As vizinhas de Noemi é que lhe deram o nome (Rt 4:17)."])
P("jesse", "Jessé", "M", ano=-1100, aprox=True, pai="obede", resumo="Pai do rei Davi, de Belém.",
  refs=["RUT 4:22", "1SA 16|Unção de Davi", "ISA 11:1|“Um rebento do tronco de Jessé”", "MAT 1:5-6"],
  cur=["Entre Salmom (época de Josué) e Davi há quase 500 anos e apenas quatro gerações listadas; muitos estudiosos entendem que a genealogia de Rute 4 omite gerações. Por isso os anos de Boaz, Obede e Jessé são apenas estimativas.",
       "Costura da cronologia: até os Juízes, as datas vêm da soma das idades bíblicas a partir de Adão (4026 a.C.); de Saul em diante, seguem a cronologia histórica convencional (Davi rei em 1010 a.C., divisão do reino em 931 a.C., queda de Jerusalém em 586 a.C.). A diferença entre os dois sistemas fica absorvida aqui, no período dos Juízes."])

# Saul
P("quis", "Quis", "M", ano=-1110, aprox=True, resumo="Benjamita, pai do rei Saul.", refs=["1SA 9:1-3"])
P("saul", "Saul", "M", ano=-1080, aprox=True, morte=-1010, pai="quis", sig="“Pedido”",
  resumo="Primeiro rei de Israel, da tribo de Benjamim.",
  historia="Escolhido e ungido por Samuel quando o povo pediu um rei, Saul começou bem, mas desobedeceu a Deus em Gilgal e na guerra contra os amalequitas, e foi rejeitado como rei. Perseguiu Davi por anos por ciúmes. Morreu com três filhos, entre eles Jônatas, na batalha do monte Gilboa.",
  refs=["1SA 9-10|Unção", "1SA 13:8-14", "1SA 15|Rejeição", "1SA 18-26|Perseguição a Davi", "1SA 28|A médium de En-Dor", "1SA 31|Morte em Gilboa", "ATO 13:21"],
  cur=["Era “mais alto do que todo o povo, dos ombros para cima” (1Sm 9:2).",
       "Paulo, cujo nome hebraico também era Saulo, era da mesma tribo de Benjamim."])
P("jonatas", "Jônatas", "M", ano=-1050, aprox=True, morte=-1010, pai="saul", sig="“O Senhor deu”",
  resumo="Filho de Saul e amigo fiel de Davi.", refs=["1SA 14|Vitória em Micmás", "1SA 18:1-4|Aliança com Davi", "1SA 20", "2SA 1:17-27|Lamento de Davi"],
  cur=["Embora herdeiro do trono, reconheceu que Davi seria rei (1Sm 23:17)."])
P("mefibosete", "Mefibosete", "M", ano=-1015, aprox=True, pai="jonatas", resumo="Filho de Jônatas, aleijado dos pés, acolhido por Davi.",
  refs=["2SA 4:4", "2SA 9|À mesa do rei"], cur=["Tinha cinco anos quando caiu do colo da ama ao fugir após a morte de Saul e Jônatas (2Sm 4:4)."])
P("mical", "Mical", "F", ano=-1045, aprox=True, pai="saul", resumo="Filha de Saul; primeira esposa de Davi.",
  refs=["1SA 18:20-28", "1SA 19:11-17|Salva Davi", "2SA 6:16-23"])

# Davi
P("davi", "Davi", "M", ano=-1040, aprox=True, idade=70, pai="jesse", sig="“Amado”",
  resumo="Rei de Israel, “homem segundo o coração de Deus”.",
  historia="O mais novo dos filhos de Jessé, pastor em Belém, foi ungido por Samuel ainda jovem. Venceu o gigante Golias, serviu na corte de Saul e foi perseguido por ele durante anos.\n\nReinou sete anos e meio em Hebrom e 33 em Jerusalém, que conquistou e fez capital, para onde levou a arca. Deus prometeu-lhe uma dinastia eterna (2Sm 7). Pecou com Bate-Seba e mandou matar Urias, arrependeu-se (Sl 51) e sofreu as consequências em sua casa. Compôs boa parte dos Salmos. O Messias é chamado “Filho de Davi”.",
  refs=["1SA 16|Unção", "1SA 17|Davi e Golias", "2SA 5|Rei sobre todo Israel", "2SA 7|A aliança davídica",
        "2SA 11-12|Bate-Seba e Natã", "1RE 2:10-12|Morte", "SAL 51|Salmo de arrependimento", "ATO 13:22", "MAT 1:1"],
  cur=["Reinou 40 anos: 7 em Hebrom e 33 em Jerusalém (2Sm 5:4-5).",
       "Cerca de 73 salmos levam seu nome no título.",
       "Jesus é chamado “Filho de Davi” 17 vezes nos evangelhos."])
P("ainoa", "Ainoã (de Jezreel)", "F", ano=-1040, aprox=True, resumo="Esposa de Davi; mãe de Amnom.", refs=["1SA 25:43", "2SA 3:2"])
P("abigail", "Abigail", "F", ano=-1040, aprox=True, resumo="Mulher sensata que apaziguou Davi; depois sua esposa.",
  refs=["1SA 25|Abigail e Nabal", "2SA 3:3"], cur=["Descrita como “sensata e formosa” (1Sm 25:3)."])
P("maaca", "Maaca", "F", ano=-1035, aprox=True, resumo="Filha de Talmai, rei de Gesur; mãe de Absalão e Tamar.", refs=["2SA 3:3"])
P("hagite", "Hagite", "F", ano=-1035, aprox=True, resumo="Esposa de Davi; mãe de Adonias.", refs=["2SA 3:4"])
P("bateseba", "Bate-Seba", "F", ano=-1020, aprox=True, sig="“Filha do juramento”",
  resumo="Esposa de Urias e depois de Davi; mãe de Salomão.",
  historia="Filha de Eliã e esposa de Urias, o heteu, foi tomada por Davi enquanto o marido estava na guerra. Após a morte de Urias, tornou-se esposa de Davi. O primeiro filho morreu; o segundo foi Salomão. Na velhice de Davi, garantiu, com o profeta Natã, que Salomão fosse o sucessor.",
  refs=["2SA 11-12", "1RE 1:11-31|Salomão como sucessor", "1RE 2:13-25", "MAT 1:6|“A que fora mulher de Urias”"],
  cur=["Mateus 1:6 não diz seu nome, mas a chama de “a que fora mulher de Urias”."])
P("urias", "Urias, o heteu", "M", ano=-1030, aprox=True, morte=-992, resumo="Soldado fiel de Davi, morto por ordem do rei.",
  refs=["2SA 11", "2SA 23:39|Entre os valentes de Davi"],
  cur=["Recusou-se a ir para casa enquanto a arca e o exército estavam em campanha (2Sm 11:11).",
       "Ele mesmo levou a Joabe a carta com a ordem de sua morte."])
for ch in ("mical", "ainoa", "abigail", "maaca", "hagite", "bateseba"):
    C("davi", ch)
C("urias", "bateseba", "Primeiro marido")
P("amnom", "Amnom", "M", ano=-1009, aprox=True, pai="davi", mae="ainoa", resumo="Primogênito de Davi; morto por Absalão.", refs=["2SA 3:2", "2SA 13"])
P("quileabe", "Quileabe", "M", ano=-1008, aprox=True, pai="davi", mae="abigail", resumo="Filho de Davi com Abigail (também chamado Daniel).", refs=["2SA 3:3", "1CR 3:1"])
P("absalao", "Absalão", "M", ano=-1007, aprox=True, pai="davi", mae="maaca", sig="“Pai da paz”",
  resumo="Filho de Davi que se rebelou contra o pai.", refs=["2SA 13-18", "2SA 18:33|“Meu filho Absalão!”"],
  cur=["Famoso pela beleza e pela cabeleira; ficou preso pelos cabelos num carvalho na batalha (2Sm 18:9)."])
P("tamar_davi", "Tamar (filha de Davi)", "F", ano=-1006, aprox=True, pai="davi", mae="maaca", resumo="Irmã de Absalão.", refs=["2SA 13"])
P("adonias", "Adonias", "M", ano=-1005, aprox=True, pai="davi", mae="hagite", resumo="Filho de Davi que tentou tomar o trono.", refs=["2SA 3:4", "1RE 1-2"])
P("salomao", "Salomão", "M", ano=-990, aprox=True, morte=-931, pai="davi", mae="bateseba", sig="“Pacífico”; também Jedidias, “amado do Senhor”.",
  resumo="Rei sábio que construiu o templo de Jerusalém.",
  historia="Filho de Davi e Bate-Seba, sucedeu o pai no trono. Pediu a Deus sabedoria para governar e recebeu também riquezas e glória. Construiu o templo em Jerusalém e levou Israel ao auge de prosperidade.\n\nNa velhice, suas muitas mulheres estrangeiras desviaram seu coração para outros deuses, e Deus anunciou a divisão do reino após sua morte. A tradição lhe atribui Provérbios, Eclesiastes e Cânticos.",
  refs=["2SA 12:24-25", "1RE 3|O pedido de sabedoria", "1RE 6-8|O templo", "1RE 10|A rainha de Sabá", "1RE 11|Apostasia e morte", "MAT 6:29", "MAT 12:42"],
  cur=["Teve 700 mulheres e 300 concubinas (1Rs 11:3).",
       "Compôs 3.000 provérbios e 1.005 cânticos (1Rs 4:32).",
       "Jesus disse que nem Salomão, em toda a sua glória, se vestiu como os lírios do campo (Mt 6:29)."])
P("nata", "Natã (filho de Davi)", "M", ano=-988, aprox=True, pai="davi", mae="bateseba", resumo="Filho de Davi; pela linhagem dele Lucas traça a genealogia de Jesus.",
  refs=["2SA 5:14", "1CR 3:5", "LUC 3:31"],
  cur=["Não confundir com o profeta Natã. Mateus segue a linhagem de Salomão; Lucas, a de Natã."])
P("naama", "Naamá (amonita)", "F", ano=-990, aprox=True, resumo="Esposa amonita de Salomão; mãe de Roboão.", refs=["1RE 14:21", "1RE 14:31"])
C("salomao", "naama")
P("roboao", "Roboão", "M", ano=-972, aprox=True, idade=58, pai="salomao", mae="naama", resumo="Filho de Salomão; em seu reinado o reino se dividiu.",
  refs=["1RE 12:1-24|A divisão do reino", "1RE 14:21-31", "2CR 10-12"],
  cur=["Seguindo o conselho dos jovens, endureceu os impostos e dez tribos se separaram (1Rs 12)."])

# =============================================================================
# Genealogia de Jesus segundo Mateus 1 (de Roboão a Jesus)
# Reis de Judá: cronologia de Thiele (anos aproximados); nascimento = início do reinado − idade
# ao assumir. Mateus organiza a lista em 3 × 14 gerações e omite alguns reis; eles foram
# incluídos aqui para a árvore refletir a linhagem real, com a omissão anotada.
# =============================================================================
OMITIDO_MT = "Mateus 1:8 salta de Jorão para Uzias, omitindo Acazias, Joás e Amazias, provavelmente para manter o esquema de 14 gerações (Mt 1:17)."

P("maaca_absalao", "Maaca (filha de Absalão)", "F", ano=-985, aprox=True, pai="absalao",
  resumo="Esposa preferida de Roboão; mãe do rei Abias.", refs=["1RE 15:2", "2CR 11:20-22"],
  cur=["Roboão a amava mais que todas as suas 18 mulheres e 60 concubinas (2Cr 11:21).",
       "Seu neto Asa a destituiu da posição de rainha-mãe por ter feito um ídolo a Aserá (1Rs 15:13)."])
C("roboao", "maaca_absalao")
P("abias", "Abias", "M", ano=-950, aprox=True, morte=-911, pai="roboao", mae="maaca_absalao", sig="“Meu pai é o Senhor”",
  resumo="Rei de Judá (913–911 a.C.).", refs=["MAT 1:7", "1RE 15:1-8", "2CR 13|Discurso no monte Zemaraim"],
  cur=["Em 1 Reis é chamado Abião.", "Em 2Cr 13 discursa ao exército de Israel lembrando a aliança de Deus com Davi, e vence a batalha."])
P("asa", "Asa", "M", ano=-930, aprox=True, morte=-870, pai="abias", resumo="Rei de Judá (911–870 a.C.); promoveu reformas religiosas.",
  refs=["MAT 1:7-8", "1RE 15:9-24", "2CR 14-16"],
  cur=["Reinou 41 anos. No fim da vida, doente dos pés, “não buscou ao Senhor, mas aos médicos” (2Cr 16:12)."])
P("josafa", "Josafá", "M", ano=-908, aprox=True, idade=60, pai="asa", sig="“O Senhor julga”",
  resumo="Rei de Judá (870–848 a.C.); fortaleceu o ensino da Lei.", refs=["MAT 1:8", "1RE 22:41-50", "2CR 17-20"],
  cur=["Na guerra contra Moabe e Amom, pôs cantores à frente do exército (2Cr 20:21-22)."])
P("jorao", "Jorão (rei de Judá)", "M", ano=-880, aprox=True, idade=40, pai="josafa", resumo="Rei de Judá (848–841 a.C.); casou-se com Atalia, filha de Acabe.",
  refs=["MAT 1:8", "2RE 8:16-24", "2CR 21"],
  cur=["Matou todos os seus irmãos ao assumir o trono (2Cr 21:4).", "Morreu de uma doença intestinal, “e se foi sem deixar de si saudades” (2Cr 21:20)."])
P("acazias", "Acazias (rei de Judá)", "M", ano=-863, aprox=True, idade=23, pai="jorao", mae="atalia", resumo="Rei de Judá por um ano (841 a.C.). Omitido por Mateus.",
  refs=["2RE 8:25-29", "2RE 9:27-29", "2CR 22:1-9"],
  cur=[OMITIDO_MT, "Foi morto por ordem de Jeú, junto com Jorão, rei de Israel."])
P("joas", "Joás (rei de Judá)", "M", ano=-842, aprox=True, idade=47, pai="acazias", resumo="Rei de Judá (835–796 a.C.); escondido no templo quando criança. Omitido por Mateus.",
  refs=["2RE 11-12", "2CR 22:10-24:27"],
  cur=[OMITIDO_MT, "Foi salvo do massacre de Atalia, escondido no templo por seis anos, e coroado aos 7 anos (2Rs 11)."])
P("amazias", "Amazias", "M", ano=-821, aprox=True, idade=54, pai="joas", resumo="Rei de Judá (796–767 a.C.). Omitido por Mateus.",
  refs=["2RE 14:1-20", "2CR 25"], cur=[OMITIDO_MT])
P("uzias", "Uzias (Azarias)", "M", ano=-808, aprox=True, idade=68, pai="amazias", sig="“O Senhor é a minha força”",
  resumo="Rei de Judá (792–740 a.C.); ficou leproso ao invadir o templo.", refs=["MAT 1:8-9", "2RE 15:1-7", "2CR 26", "ISA 6:1|“No ano da morte do rei Uzias…”"],
  cur=[OMITIDO_MT + " Por isso, em Mateus, Uzias aparece como “filho” de Jorão, que na verdade era seu trisavô.",
       "Ao queimar incenso no templo, função dos sacerdotes, foi ferido de lepra até a morte (2Cr 26:16-21)."])
P("jotao", "Jotão", "M", ano=-775, aprox=True, idade=41, pai="uzias", resumo="Rei de Judá (750–735 a.C.).",
  refs=["MAT 1:9", "2RE 15:32-38", "2CR 27"], cur=["Governou como corregente enquanto o pai estava leproso (2Rs 15:5)."])
P("acaz", "Acaz", "M", ano=-755, aprox=True, idade=36, pai="jotao", resumo="Rei de Judá (735–715 a.C.); idólatra.",
  refs=["MAT 1:9", "2RE 16", "2CR 28", "ISA 7:1-14|O sinal do Emanuel"],
  cur=["A profecia “a virgem conceberá… Emanuel” (Is 7:14), citada em Mt 1:23, foi dada primeiramente a Acaz.",
       "Fez passar o próprio filho pelo fogo (2Rs 16:3)."])
P("ezequias", "Ezequias", "M", ano=-740, aprox=True, idade=54, pai="acaz", sig="“O Senhor fortalece”",
  resumo="Rei de Judá (715–686 a.C.); reformador, livrado da Assíria.",
  refs=["MAT 1:9-10", "2RE 18-20", "2CR 29-32", "ISA 36-39"],
  cur=["Deus lhe acrescentou 15 anos de vida, e a sombra do relógio de sol voltou dez graus (2Rs 20:1-11).",
       "O túnel de Ezequias, que levava água à cidade, existe até hoje em Jerusalém (2Rs 20:20)."])
P("manasses_rei", "Manassés (rei de Judá)", "M", ano=-709, aprox=True, idade=67, pai="ezequias",
  resumo="Rei de Judá (697–642 a.C.); o reinado mais longo, marcado pela idolatria.", refs=["MAT 1:10", "2RE 21:1-18", "2CR 33:1-20"],
  cur=["Reinou 55 anos, o mais longo dos reis de Judá.", "Levado preso à Babilônia, humilhou-se e foi restaurado (2Cr 33:11-13)."])
P("amom", "Amom", "M", ano=-664, aprox=True, idade=24, pai="manasses_rei", resumo="Rei de Judá (642–640 a.C.); assassinado pelos servos.",
  refs=["MAT 1:10", "2RE 21:19-26", "2CR 33:21-25"])
P("josias", "Josias", "M", ano=-648, aprox=True, idade=39, pai="amom", sig="“O Senhor sustenta”",
  resumo="Rei de Judá (640–609 a.C.); restaurou a Lei e a Páscoa.", refs=["MAT 1:10-11", "2RE 22-23", "2CR 34-35"],
  cur=["Tornou-se rei aos 8 anos.", "Durante a reforma do templo foi encontrado o “livro da Lei” (2Rs 22:8).",
       "Morreu em Megido, lutando contra o faraó Neco (2Rs 23:29)."])
P("jeoaquim", "Jeoaquim", "M", ano=-634, aprox=True, idade=36, pai="josias", resumo="Rei de Judá (609–598 a.C.). Omitido por Mateus.",
  refs=["2RE 23:34-24:6", "2CR 36:4-8", "JER 36|Queima o rolo de Jeremias"],
  cur=["Mateus 1:11 diz que Josias “gerou Jeconias e seus irmãos”, pulando Jeoaquim, pai de Jeconias.",
       "Cortou e queimou o rolo com as profecias de Jeremias (Jr 36:23)."])
P("jeconias", "Jeconias (Joaquim)", "M", ano=-616, aprox=True, pai="jeoaquim",
  resumo="Rei de Judá por três meses (598/597 a.C.); levado cativo para a Babilônia.",
  refs=["MAT 1:11-12", "2RE 24:8-17", "2RE 25:27-30|Libertado na Babilônia", "JER 22:24-30", "1CR 3:16-17"],
  cur=["Também chamado Joaquim e Conias.",
       "Jeremias 22:30 declara que nenhum descendente seu se assentaria no trono de Davi. Como Jesus não descende de Jeconias pelo sangue (José era pai legal), muitos veem aqui uma razão para Lucas traçar a linhagem por Natã.",
       "Na contagem de Mateus, Jeconias encerra o segundo bloco e abre o terceiro (Mt 1:17)."])
P("salatiel", "Salatiel", "M", ano=-595, aprox=True, pai="jeconias", sig="“Pedi a Deus”",
  resumo="Filho de Jeconias, nascido no exílio.", refs=["MAT 1:12", "1CR 3:17", "ESD 3:2", "LUC 3:27"],
  cur=["Aparece nas duas genealogias, mas Lucas o chama “filho de Neri” (Lc 3:27), não de Jeconias."])
P("zorobabel", "Zorobabel", "M", ano=-570, aprox=True, pai="salatiel", sig="“Semente da Babilônia”",
  resumo="Governador de Judá que liderou o retorno e reconstruiu o templo.",
  refs=["MAT 1:12-13", "ESD 3:8-13|Fundamentos do templo", "AGE 2:20-23|“Como anel de selar”", "ZAC 4:6-10", "LUC 3:27"],
  cur=["1 Crônicas 3:19 o apresenta como filho de Pedaías, irmão de Salatiel; uma explicação é o casamento de levirato.",
       "Em Ageu 2:23 Deus o faz “como anel de selar”, revertendo a imagem usada contra Jeconias em Jr 22:24."])
POS_EXILIO = "Conhecido apenas pela genealogia de Mateus. Os anos são distribuídos por igual entre Zorobabel e José, pois a Bíblia não informa os intervalos; com só 10 nomes para cerca de 550 anos, é provável que haja gerações omitidas."
for i, (ch, nome, pai_, v) in enumerate([
    ("abiude", "Abiúde", "zorobabel", "MAT 1:13"), ("eliaquim", "Eliaquim", "abiude", "MAT 1:13"),
    ("azor", "Azor", "eliaquim", "MAT 1:13-14"), ("sadoque", "Sadoque", "azor", "MAT 1:14"),
    ("aquim", "Aquim", "sadoque", "MAT 1:14"), ("eliude", "Eliúde", "aquim", "MAT 1:14-15"),
    ("eleazar_mt", "Eleazar (pai de Matã)", "eliude", "MAT 1:15"), ("mata", "Matã", "eleazar_mt", "MAT 1:15"),
]):
    P(ch, nome, "M", ano=-540 + i * 57, aprox=True, pai=pai_, resumo="Ascendente de José na genealogia de Mateus.",
      refs=[v], cur=[POS_EXILIO])
P("jaco_mt", "Jacó (pai de José)", "M", ano=-84, aprox=True, pai="mata", resumo="Pai de José, segundo Mateus.",
  refs=["MAT 1:15-16"], cur=[POS_EXILIO, "Lucas 3:23 chama o pai de José de Eli, não de Jacó."])
P("jose_nt", "José (marido de Maria)", "M", ano=-30, aprox=True, pai="jaco_mt", resumo="Carpinteiro de Nazaré, descendente de Davi; pai legal de Jesus.",
  historia="Descendente de Davi pela linhagem real, José estava desposado com Maria quando ela concebeu pelo Espírito Santo. Homem justo, pensava deixá-la secretamente, mas um anjo, em sonho, o mandou recebê-la e dar ao menino o nome de Jesus.\n\nLevou a família a Belém para o recenseamento, fugiu com ela para o Egito diante da ameaça de Herodes e depois se estabeleceu em Nazaré. A última menção a ele é na visita ao templo, quando Jesus tinha 12 anos.",
  refs=["MAT 1:16-25", "MAT 2:13-23|Fuga para o Egito", "LUC 1:27", "LUC 2:1-7", "LUC 2:41-52|Jesus aos 12 anos no templo", "MAT 13:55|“O filho do carpinteiro”"],
  cur=["Assim como José do Egito, também filho de um Jacó, recebeu de Deus orientações por sonhos (Mt 1:20; 2:13; 2:19; 2:22).",
       "Mateus 1:16 diz que seu pai era Jacó; Lucas 3:23, que era Eli.",
       "Não há registro dele durante o ministério de Jesus; muitos supõem que já tinha morrido."])
P("maria", "Maria", "F", ano=-20, aprox=True, sig="Do hebraico Miriam (mesmo nome de Miriã, irmã de Moisés).",
  resumo="Mãe de Jesus; concebeu pelo Espírito Santo.",
  historia="Jovem de Nazaré desposada com José, recebeu do anjo Gabriel o anúncio de que conceberia pelo Espírito Santo e daria à luz o Filho do Altíssimo, e respondeu: “Eis aqui a serva do Senhor”. Visitou a parente Isabel e entoou o Magnificat.\n\nAcompanhou Jesus desde Belém até a cruz, onde foi confiada ao discípulo João, e está entre os que oravam no cenáculo antes do Pentecostes.",
  refs=["MAT 1:16-25", "LUC 1:26-38|A anunciação", "LUC 1:39-56|Visita a Isabel e o Magnificat", "LUC 2", "JOA 2:1-11|Bodas de Caná", "JOA 19:25-27|Ao pé da cruz", "ATO 1:14"],
  cur=["Maria é a quinta mulher citada na genealogia de Mateus, depois de Tamar, Raabe, Rute e “a mulher de Urias”.",
       "Era parente de Isabel, mãe de João Batista (Lc 1:36).",
       "A tradição (Protoevangelho de Tiago, séc. II) chama seus pais de Joaquim e Ana; a Bíblia não os nomeia.",
       "Uma interpretação antiga vê em Lucas 3 a genealogia de Maria, sendo Eli seu pai e sogro de José."])
C("jose_nt", "maria")
P("jesus", "Jesus", "M", ano=-4, aprox=True, idade=33, morte=30, mae="maria",
  sig="Do hebraico Yehoshua, “o Senhor salva” (Mt 1:21). Cristo = “Ungido” (Messias).",
  resumo="O Messias, Filho de Deus, “filho de Davi, filho de Abraão” (Mt 1:1).",
  historia="Mateus abre seu evangelho com a “genealogia de Jesus Cristo, filho de Davi, filho de Abraão”, mostrando-o como herdeiro das promessas feitas a Abraão e do trono de Davi. Concebido pelo Espírito Santo, nasceu da virgem Maria em Belém, nos dias do rei Herodes; José, descendente de Davi, foi seu pai legal.\n\nPor volta dos 30 anos iniciou seu ministério na Galileia e na Judeia, pregando o Reino de Deus. Foi crucificado em Jerusalém sob Pôncio Pilatos e, segundo os evangelhos, ressuscitou ao terceiro dia.",
  refs=["MAT 1:1-17|Genealogia segundo Mateus", "MAT 1:18-25|Nascimento", "MAT 2|Os magos e a fuga para o Egito",
        "LUC 2:1-20|Nascimento em Belém", "LUC 3:23-38|Genealogia segundo Lucas", "JOA 1:1-14|O Verbo se fez carne",
        "MAT 27-28|Crucificação e ressurreição", "ROM 1:3-4|Da descendência de Davi segundo a carne", "1CO 15:3-8"],
  cur=["O calendário a.C./d.C. foi calculado no séc. VI por Dionísio, o Exíguo, que errou alguns anos: como Herodes morreu em 4 a.C. (Mt 2:19), Jesus nasceu por volta de 6–4 a.C.",
       "A idade de 33 anos é a estimativa tradicional: “cerca de 30 anos” no início do ministério (Lc 3:23) mais cerca de três anos de ministério.",
       "Mateus 1:16 quebra o padrão “fulano gerou fulano”: “José, marido de Maria, da qual nasceu Jesus”. No grego, “da qual” é feminino, indicando que José não o gerou.",
       "Lucas 3:23 diz que Jesus era “filho, como se supunha, de José”.",
       "Mateus organiza a genealogia em 3 × 14 gerações (Mt 1:17). Em hebraico, as letras de Davi (DWD) somam 4 + 6 + 4 = 14.",
       "Não há linha de pai no card: Jesus está ligado a Maria e posicionado sob José, seu pai legal.",
       "Os evangelhos citam quatro irmãos (Tiago, José, Simão e Judas) e irmãs não nomeadas (Mt 13:55-56). Lc 2:7 chama Jesus de “primogênito” de Maria, e Mt 1:25 diz que José “não a conheceu até que deu à luz”. A forma como esses textos são lidos varia entre as tradições cristãs."])

# =============================================================================
# Genealogia de Jesus segundo Lucas 3:23-38 (ramo paralelo)
# Lucas vai de Davi a Jesus por Natã (não por Salomão). Os ramos se tocam em Salatiel e
# Zorobabel e se reencontram em José. Onde Lucas dá outro pai a alguém que já está na árvore
# (Salatiel e José), isso é registrado como filiação alternativa (linha tracejada).
# Os anos são distribuídos por igual entre os pontos fixos, pois Lucas não traz idades.
# =============================================================================
LUCAS_NOTA = "Conhecido apenas pela genealogia de Lucas. Ano estimado: as gerações foram distribuídas por igual entre os pontos conhecidos."


def ramo_lucas(pai_inicial, nomes, ano_inicio, ano_fim):
    """nomes: lista (chave, nome, versículo); os anos vão de ano_inicio a ano_fim (exclusivos)."""
    passo = (ano_fim - ano_inicio) / (len(nomes) + 1)
    pai_ = pai_inicial
    for i, (ch, nome, v, *extra) in enumerate(nomes, 1):
        P(ch, nome, "M", ano=round(ano_inicio + i * passo), aprox=True, pai=pai_,
          resumo="Ascendente de Jesus na genealogia de Lucas.",
          refs=[f"LUC 3:{v}"], cur=[LUCAS_NOTA, *extra])
        pai_ = ch


# De Natã (filho de Davi) até Neri, pai de Salatiel segundo Lucas
ramo_lucas("nata", [
    ("matata", "Matatá", 31), ("mena", "Mená", 31), ("melea", "Meleá", 31),
    ("eliaquim_lc", "Eliaquim (Lc 3:30)", 30, "Não confundir com Eliaquim, filho de Abiúde, da lista de Mateus (Mt 1:13)."),
    ("jona", "Jonã", 30), ("jose_lc30", "José (Lc 3:30)", 30), ("juda_lc", "Judá (Lc 3:30)", 30),
    ("simeao_lc", "Simeão (Lc 3:30)", 30), ("levi_lc29", "Levi (Lc 3:29)", 29), ("matate_lc29", "Matate (Lc 3:29)", 29),
    ("jorim", "Jorim", 29), ("eliezer_lc", "Eliézer (Lc 3:29)", 29), ("josue_lc", "Josué (Lc 3:29)", 29),
    ("er_lc", "Er (Lc 3:28)", 28), ("elmada", "Elmadã", 28), ("cosa", "Cosã", 28), ("adi", "Adi", 28),
    ("melqui_lc28", "Melqui (Lc 3:28)", 28),
    ("neri", "Neri", 27, "Segundo Lucas, é o pai de Salatiel; segundo Mateus (e 1Cr 3:17), o pai de Salatiel é o rei Jeconias. Uma explicação é que Salatiel seria filho biológico de Neri e herdeiro legal de Jeconias, ou vice-versa (levirato/adoção)."),
], -988, -595)

# De Zorobabel até Eli, pai de José segundo Lucas
ramo_lucas("zorobabel", [
    ("resa", "Resa", 27, "Não aparece entre os filhos de Zorobabel em 1Cr 3:19-20. Alguns estudiosos sugerem que “Resa” seja o aramaico rēšā’, “príncipe”, um título de Zorobabel lido como nome."),
    ("joana", "Joanã", 27), ("joda", "Jodá", 26), ("joseque", "Joseque", 26), ("semei", "Semei", 26),
    ("matatias_lc26", "Matatias (Lc 3:26)", 26), ("maate", "Maate", 26), ("nagai", "Nagaí", 25), ("esli", "Esli", 25),
    ("naum_lc", "Naum (Lc 3:25)", 25, "Não confundir com o profeta Naum."), ("amos_lc", "Amós (Lc 3:25)", 25, "Não confundir com o profeta Amós."),
    ("matatias_lc25", "Matatias (Lc 3:25)", 25), ("jose_lc24", "José (Lc 3:24)", 24), ("janai", "Janai", 24),
    ("melqui_lc24", "Melqui (Lc 3:24)", 24), ("levi_lc24", "Levi (Lc 3:24)", 24), ("matate_lc24", "Matate (Lc 3:24)", 24),
    ("eli", "Eli", 23,
     "Segundo Lucas 3:23, é o pai de José; segundo Mateus 1:16, o pai de José é Jacó.",
     "Três explicações tradicionais: (1) Eli seria pai de Maria e sogro de José, e Lucas traria a linhagem de Maria; (2) Júlio Africano (séc. III, citado por Eusébio): Jacó e Eli eram meio-irmãos, Eli morreu sem filhos e Jacó gerou José em seu nome (levirato); (3) Mateus traz a linha legal/real e Lucas a natural."),
], -570, -30)

FILIACOES = [
    ("salatiel", "neri", "Lucas 3:27", "Mateus 1:12 e 1Cr 3:17 dão Jeconias como pai."),
    ("jose_nt", "eli", "Lucas 3:23", "Mateus 1:16 dá Jacó como pai."),
]

# =============================================================================
# Últimos reis de Judá que faltavam (filhos de Josias com Hamutal)
# =============================================================================
P("hamutal", "Hamutal", "F", ano=-650, aprox=True, resumo="Esposa de Josias; mãe dos reis Jeoacaz e Zedequias.",
  refs=["2RE 23:31", "2RE 24:18"], cur=["Filha de Jeremias de Libna, não o profeta (2Rs 23:31)."])
C("josias", "hamutal")
P("jeoacaz_juda", "Jeoacaz (rei de Judá)", "M", ano=-632, aprox=True, pai="josias", mae="hamutal",
  resumo="Rei de Judá por três meses (609 a.C.); levado ao Egito pelo faraó Neco.",
  refs=["2RE 23:30-34", "2CR 36:1-4", "JER 22:10-12"],
  cur=["Também chamado Salum (Jr 22:11).", "Foi o primeiro rei de Judá a morrer no exílio, no Egito."])
P("zedequias", "Zedequias", "M", ano=-618, aprox=True, pai="josias", mae="hamutal", sig="“Justiça do Senhor”",
  resumo="Último rei de Judá (597–586 a.C.); viu a destruição de Jerusalém.",
  refs=["2RE 24:17-25:7", "2CR 36:10-21", "JER 37-39", "JER 52:1-11"],
  cur=["Seu nome original era Matanias; Nabucodonosor o mudou para Zedequias (2Rs 24:17).",
       "Viu os filhos serem mortos, teve os olhos vazados e foi levado acorrentado à Babilônia (2Rs 25:7).",
       "Consultava Jeremias às escondidas, mas não seguia o seu conselho (Jr 37:17; 38:14-28)."])

# =============================================================================
# Reis de Israel (reino do norte), 931–722 a.C. Cronologia de Thiele.
# A Bíblia não informa a idade dos reis de Israel ao assumir: os nascimentos são estimativas.
# =============================================================================
NASC_ISRAEL = "A Bíblia não informa a idade dos reis de Israel ao assumir o trono; o ano de nascimento é uma estimativa."
PECADO_JEROBOAO = "Como quase todos os reis de Israel, “não se apartou dos pecados de Jeroboão”, o culto aos bezerros de ouro em Betel e Dã."

P("nebate", "Nebate", "M", ano=-995, aprox=True, resumo="Efraimita, pai de Jeroboão I.", refs=["1RE 11:26"])
P("zerua", "Zerua", "F", ano=-990, aprox=True, resumo="Viúva, mãe de Jeroboão I.", refs=["1RE 11:26"])
C("nebate", "zerua")
P("jeroboao1", "Jeroboão I", "M", ano=-965, aprox=True, morte=-910, pai="nebate", mae="zerua", sig="“Que o povo se multiplique”",
  resumo="Primeiro rei de Israel (931–910 a.C.); instituiu os bezerros de ouro.",
  historia="Oficial de Salomão encarregado dos trabalhos forçados da casa de José, Jeroboão recebeu do profeta Aías a promessa de reinar sobre dez tribos. Fugiu para o Egito e voltou após a morte de Salomão. Quando Roboão endureceu o jugo, as tribos do norte o fizeram rei.\n\nPara que o povo não subisse a Jerusalém, fez dois bezerros de ouro, em Betel e em Dã, e instituiu sacerdotes e festas próprias. Esse “pecado de Jeroboão” passou a ser a medida de quase todos os reis de Israel depois dele.",
  refs=["1RE 11:26-40|A capa rasgada em 12 pedaços", "1RE 12:1-20|A divisão do reino", "1RE 12:25-33|Os bezerros de Betel e Dã",
        "1RE 13|O homem de Deus de Judá", "1RE 14:1-20"],
  cur=["O profeta Aías rasgou a própria capa em 12 pedaços e deu-lhe 10 (1Rs 11:29-31).",
       "Sua mão secou quando a estendeu contra um profeta, e foi restaurada pela oração deste (1Rs 13:4-6).",
       NASC_ISRAEL])
P("nadabe_isr", "Nadabe (rei de Israel)", "M", ano=-945, aprox=True, morte=-909, pai="jeroboao1",
  resumo="Rei de Israel (910–909 a.C.); assassinado por Baasa.", refs=["1RE 14:20", "1RE 15:25-31"],
  cur=["Baasa matou toda a casa de Jeroboão, cumprindo a profecia de Aías (1Rs 15:29).", NASC_ISRAEL])
P("aias_baasa", "Aías (pai de Baasa)", "M", ano=-970, aprox=True, resumo="Da tribo de Issacar; pai do rei Baasa.", refs=["1RE 15:27"],
  cur=["Não confundir com o profeta Aías, o silonita."])
P("baasa", "Baasa", "M", ano=-945, aprox=True, morte=-886, pai="aias_baasa", resumo="Rei de Israel (909–886 a.C.); fundou a segunda dinastia.",
  refs=["1RE 15:16-22", "1RE 15:27-16:7", "2CR 16:1-6"],
  cur=["Fortificou Ramá para bloquear Judá; Asa pagou a Síria para atacá-lo (1Rs 15:17-21).", PECADO_JEROBOAO, NASC_ISRAEL])
P("ela_isr", "Elá (rei de Israel)", "M", ano=-915, aprox=True, morte=-885, pai="baasa", resumo="Rei de Israel (886–885 a.C.).",
  refs=["1RE 16:6-14"], cur=["Foi assassinado por Zinri enquanto se embriagava na casa do mordomo (1Rs 16:9-10).", NASC_ISRAEL])
P("zinri", "Zinri", "M", ano=-920, aprox=True, morte=-885, resumo="Rei de Israel por sete dias (885 a.C.).",
  refs=["1RE 16:9-20", "2RE 9:31"],
  cur=["Reinou só sete dias; cercado por Onri, incendiou o palácio com ele dentro (1Rs 16:18).",
       "Jezabel chamou Jeú de “Zinri, assassino do seu senhor” (2Rs 9:31).", NASC_ISRAEL])
P("onri", "Onri", "M", ano=-920, aprox=True, morte=-874, resumo="Rei de Israel (885–874 a.C.); fundou Samaria.",
  refs=["1RE 16:16-28", "MIQ 6:16|“Os estatutos de Onri”"],
  cur=["Comprou o monte de Samaria por dois talentos de prata e ali fundou a nova capital (1Rs 16:24).",
       "Disputou o trono com Tibni por cerca de cinco anos (1Rs 16:21-22).",
       "Mais de um século depois, documentos assírios ainda chamavam Israel de “casa de Onri”; a Pedra Moabita também o cita.",
       NASC_ISRAEL])
P("acabe", "Acabe", "M", ano=-905, aprox=True, morte=-853, pai="onri", resumo="Rei de Israel (874–853 a.C.); marido de Jezabel, adversário de Elias.",
  historia="Filho de Onri, casou-se com Jezabel, filha do rei de Sidom, e introduziu oficialmente o culto a Baal em Samaria. Em seu reinado o profeta Elias anunciou a seca, desafiou os profetas de Baal no monte Carmelo e o confrontou pelo assassinato de Nabote, cuja vinha Acabe cobiçava.\n\nFoi também um rei militarmente forte. Morreu na batalha de Ramote-Gileade, ferido por uma flecha atirada a esmo, apesar de ter ido disfarçado.",
  refs=["1RE 16:29-34", "1RE 18|Elias no monte Carmelo", "1RE 20", "1RE 21|A vinha de Nabote", "1RE 22:1-40|Morte em Ramote-Gileade"],
  cur=["“Fez muito mais para irritar o Senhor do que todos os reis de Israel antes dele” (1Rs 16:33).",
       "O Monólito de Kurkh, assírio, registra “Acabe, o israelita” com 2.000 carros na batalha de Qarqar (853 a.C.).",
       "Morreu por uma flecha atirada “ao acaso” (1Rs 22:34), e os cães lamberam o seu sangue, como Elias dissera.",
       NASC_ISRAEL])
P("jezabel", "Jezabel", "F", ano=-895, aprox=True, morte=-841, resumo="Rainha fenícia, esposa de Acabe; perseguidora dos profetas.",
  refs=["1RE 16:31", "1RE 18:4", "1RE 19:1-3|Ameaça a Elias", "1RE 21:5-16|A morte de Nabote", "2RE 9:30-37|Sua morte", "APO 2:20"],
  cur=["Filha de Etbaal, rei dos sidônios (1Rs 16:31).", "Mandou matar os profetas do Senhor e ameaçou Elias, que fugiu para o deserto (1Rs 19:2-3).",
       "Foi lançada da janela por ordem de Jeú (2Rs 9:33).", "Em Apocalipse 2:20, seu nome é usado como símbolo de falsa profetisa."])
C("acabe", "jezabel")
P("acazias_isr", "Acazias (rei de Israel)", "M", ano=-875, aprox=True, morte=-852, pai="acabe", mae="jezabel",
  resumo="Rei de Israel (853–852 a.C.).", refs=["1RE 22:51-53", "2RE 1"],
  cur=["Caiu pelas grades de um quarto alto e mandou consultar Baal-Zebube; Elias anunciou a sua morte (2Rs 1).", NASC_ISRAEL])
P("jorao_isr", "Jorão (rei de Israel)", "M", ano=-873, aprox=True, morte=-841, pai="acabe", mae="jezabel",
  resumo="Rei de Israel (852–841 a.C.); último da dinastia de Onri.", refs=["2RE 3|Guerra contra Moabe", "2RE 6-7", "2RE 9:14-26|Morto por Jeú"],
  cur=["Também chamado Jeorão.", "Foi morto por uma flecha de Jeú e lançado na antiga vinha de Nabote (2Rs 9:24-26).",
       "Cunhado de Jorão de Judá: os dois reis de Israel e Judá tinham o mesmo nome na mesma época.", NASC_ISRAEL])
P("atalia", "Atalia", "F", ano=-883, aprox=True, morte=-835, pai="acabe",
  resumo="Filha de Acabe; rainha de Judá (841–835 a.C.), a única mulher a reinar sobre Judá.",
  historia="Filha de Acabe, foi dada em casamento a Jorão, rei de Judá, selando uma aliança entre os dois reinos. Influenciou o marido e o filho Acazias a seguirem os caminhos da casa de Acabe.\n\nQuando Acazias foi morto por Jeú, Atalia exterminou a descendência real e tomou o trono. O pequeno Joás, porém, foi escondido no templo pela tia Jeoseba e pelo sacerdote Joiada, que seis anos depois o coroou. Atalia foi morta.",
  refs=["2RE 8:18", "2RE 8:26", "2RE 11|Usurpação e morte", "2CR 22:10-23:21"],
  cur=["Liga as duas dinastias: neta de Onri (Israel) e mãe e avó de reis de Judá. Assim, descendentes de Acabe entraram na linhagem de Davi.",
       "2Rs 8:26 a chama “filha de Onri” no sentido de neta.",
       "A Bíblia não diz que era filha de Jezabel, embora muitos o suponham.",
       "Por isso alguns estudiosos explicam a omissão de Acazias, Joás e Amazias em Mt 1:8: seriam as gerações “contaminadas” pela casa de Acabe (cf. 1Rs 21:21)."])
C("jorao", "atalia")
P("ninsi", "Ninsi", "M", ano=-940, aprox=True, resumo="Avô de Jeú.", refs=["2RE 9:2", "1RE 19:16"],
  cur=["Jeú é chamado tanto “filho de Josafá, filho de Ninsi” quanto simplesmente “filho de Ninsi”."])
P("josafa_jeu", "Josafá (pai de Jeú)", "M", ano=-910, aprox=True, pai="ninsi", resumo="Pai de Jeú.", refs=["2RE 9:2", "2RE 9:14"],
  cur=["Não confundir com Josafá, rei de Judá."])
P("jeu", "Jeú", "M", ano=-880, aprox=True, morte=-814, pai="josafa_jeu", resumo="Rei de Israel (841–814 a.C.); exterminou a casa de Acabe e o culto a Baal.",
  historia="Comandante do exército, foi ungido rei por um discípulo de Eliseu, cumprindo uma ordem dada a Elias. Num único dia matou Jorão de Israel e Acazias de Judá, e mandou lançar Jezabel da janela. Em seguida exterminou a casa de Acabe e os adoradores de Baal.\n\nNo entanto, manteve os bezerros de ouro de Jeroboão. Deus prometeu-lhe descendentes no trono até a quarta geração.",
  refs=["1RE 19:16", "2RE 9-10", "OSE 1:4"],
  cur=["“O guiar é como o de Jeú… porque guia furiosamente” (2Rs 9:20).",
       "O Obelisco Negro de Salmanasar III mostra Jeú (ou um enviado seu) prostrado diante do rei assírio: a única imagem contemporânea conhecida de um rei de Israel.",
       "Oseias 1:4 anuncia castigo sobre a casa de Jeú pelo sangue derramado em Jezreel.", NASC_ISRAEL])
P("jeoacaz_isr", "Jeoacaz (rei de Israel)", "M", ano=-850, aprox=True, morte=-798, pai="jeu", resumo="Rei de Israel (814–798 a.C.); oprimido pela Síria.",
  refs=["2RE 13:1-9"], cur=["A Síria deixou-lhe apenas 50 cavaleiros, 10 carros e 10.000 soldados de infantaria (2Rs 13:7).", NASC_ISRAEL])
P("jeoas_isr", "Jeoás (rei de Israel)", "M", ano=-830, aprox=True, morte=-782, pai="jeoacaz_isr", resumo="Rei de Israel (798–782 a.C.).",
  refs=["2RE 13:10-25", "2RE 14:8-16|Vence Amazias de Judá"],
  cur=["Visitou Eliseu no leito de morte e bateu as flechas no chão só três vezes, e por isso só venceria a Síria três vezes (2Rs 13:14-19).",
       "Derrotou Amazias de Judá, derrubou parte do muro de Jerusalém e saqueou o templo (2Rs 14:13-14).", NASC_ISRAEL])
P("jeroboao2", "Jeroboão II", "M", ano=-810, aprox=True, morte=-753, pai="jeoas_isr", resumo="Rei de Israel (793–753 a.C.); o reinado mais longo e próspero do norte.",
  refs=["2RE 14:23-29", "AMO 7:9-11", "OSE 1:1"],
  cur=["Restaurou as fronteiras de Israel “conforme a palavra… de Jonas, filho de Amitai” (2Rs 14:25): o mesmo Jonas de Nínive.",
       "Foi a época dos profetas Amós e Oseias, que denunciaram o luxo e a injustiça social.", NASC_ISRAEL])
P("zacarias_isr", "Zacarias (rei de Israel)", "M", ano=-785, aprox=True, morte=-752, pai="jeroboao2", resumo="Rei de Israel por seis meses (753 a.C.).",
  refs=["2RE 14:29", "2RE 15:8-12"],
  cur=["Último da dinastia de Jeú, cumprindo a promessa de quatro gerações (2Rs 10:30; 15:12).", NASC_ISRAEL])
P("jabes", "Jabes", "M", ano=-815, aprox=True, resumo="Pai do rei Salum.", refs=["2RE 15:10"])
P("salum", "Salum", "M", ano=-790, aprox=True, morte=-752, pai="jabes", resumo="Rei de Israel por um mês (752 a.C.).",
  refs=["2RE 15:10-15"], cur=["Matou Zacarias e foi morto por Menaém um mês depois.", NASC_ISRAEL])
P("gadi", "Gadi", "M", ano=-815, aprox=True, resumo="Pai do rei Menaém.", refs=["2RE 15:14"])
P("menaem", "Menaém", "M", ano=-790, aprox=True, morte=-742, pai="gadi", resumo="Rei de Israel (752–742 a.C.); tributário da Assíria.",
  refs=["2RE 15:14-22"],
  cur=["Pagou mil talentos de prata a Pul (Tiglate-Pileser III), cobrando 50 siclos de cada homem rico (2Rs 15:19-20).", NASC_ISRAEL])
P("pecaias", "Pecaías", "M", ano=-770, aprox=True, morte=-740, pai="menaem", resumo="Rei de Israel (742–740 a.C.); assassinado por Peca.",
  refs=["2RE 15:22-26"], cur=[NASC_ISRAEL])
P("remalias", "Remalias", "M", ano=-805, aprox=True, resumo="Pai do rei Peca.", refs=["2RE 15:25", "ISA 7:4-9"],
  cur=["Isaías se refere a Peca com desdém como “o filho de Remalias” (Is 7:4-9)."])
P("peca", "Peca", "M", ano=-780, aprox=True, morte=-732, pai="remalias", resumo="Rei de Israel (752/740–732 a.C.); aliado da Síria contra Judá.",
  refs=["2RE 15:25-31", "2RE 16:5", "ISA 7:1-9|A guerra siro-efraimita"],
  cur=["Aliou-se a Rezim, da Síria, contra Acaz de Judá. É nesse contexto que Isaías dá o sinal do Emanuel (Is 7:14).",
       "Segundo Thiele, governou em Gileade desde 752 a.C., em paralelo a Menaém e Pecaías.", NASC_ISRAEL])
P("ela_oseias", "Elá (pai de Oseias)", "M", ano=-795, aprox=True, resumo="Pai do rei Oseias.", refs=["2RE 15:30"],
  cur=["Não confundir com Elá, filho de Baasa, rei de Israel."])
P("oseias_rei", "Oseias (rei de Israel)", "M", ano=-770, aprox=True, pai="ela_oseias", resumo="Último rei de Israel (732–722 a.C.).",
  refs=["2RE 15:30", "2RE 17:1-6|A queda de Samaria", "2RE 17:7-23|Por que Israel caiu"],
  cur=["Deixou de pagar tributo à Assíria e buscou apoio do Egito; foi preso, e Samaria caiu após três anos de cerco, em 722 a.C.",
       "Não confundir com o profeta Oseias, seu contemporâneo.", NASC_ISRAEL])

# Reinados: (chave, reino, início, fim, observação)
UNIDO, JUDA, ISRAEL = "Israel (reino unido)", "Judá", "Israel (reino do norte)"
REINADOS = [
    ("saul", UNIDO, -1050, -1010, None), ("davi", UNIDO, -1010, -970, "7 anos e meio em Hebrom, 33 em Jerusalém"),
    ("salomao", UNIDO, -970, -931, None),
    ("roboao", JUDA, -931, -913, None), ("abias", JUDA, -913, -911, None), ("asa", JUDA, -911, -870, None),
    ("josafa", JUDA, -873, -848, "corregência com Asa desde 873"), ("jorao", JUDA, -853, -841, "corregência desde 853; sozinho desde 848"),
    ("acazias", JUDA, -841, -841, None), ("atalia", JUDA, -841, -835, "usurpadora"),
    ("joas", JUDA, -835, -796, None), ("amazias", JUDA, -796, -767, None),
    ("uzias", JUDA, -792, -740, "corregência desde 792"), ("jotao", JUDA, -750, -735, "corregente durante a lepra de Uzias"),
    ("acaz", JUDA, -735, -715, None), ("ezequias", JUDA, -715, -686, None),
    ("manasses_rei", JUDA, -697, -642, "corregência desde 697"), ("amom", JUDA, -642, -640, None),
    ("josias", JUDA, -640, -609, None), ("jeoacaz_juda", JUDA, -609, -609, "três meses"),
    ("jeoaquim", JUDA, -609, -598, None), ("jeconias", JUDA, -598, -597, "três meses"),
    ("zedequias", JUDA, -597, -586, None),
    ("jeroboao1", ISRAEL, -931, -910, None), ("nadabe_isr", ISRAEL, -910, -909, None), ("baasa", ISRAEL, -909, -886, None),
    ("ela_isr", ISRAEL, -886, -885, None), ("zinri", ISRAEL, -885, -885, "sete dias"),
    ("onri", ISRAEL, -885, -874, "disputou o trono com Tibni até 880"), ("acabe", ISRAEL, -874, -853, None),
    ("acazias_isr", ISRAEL, -853, -852, None), ("jorao_isr", ISRAEL, -852, -841, None), ("jeu", ISRAEL, -841, -814, None),
    ("jeoacaz_isr", ISRAEL, -814, -798, None), ("jeoas_isr", ISRAEL, -798, -782, None),
    ("jeroboao2", ISRAEL, -793, -753, "corregência desde 793"), ("zacarias_isr", ISRAEL, -753, -753, "seis meses"),
    ("salum", ISRAEL, -752, -752, "um mês"), ("menaem", ISRAEL, -752, -742, None), ("pecaias", ISRAEL, -742, -740, None),
    ("peca", ISRAEL, -752, -732, "em Gileade desde 752; sobre todo Israel desde 740"), ("oseias_rei", ISRAEL, -732, -722, None),
]

# =============================================================================
# Linhagem de Levi até Moisés e Arão
# =============================================================================
P("coate", "Coate", "M", 2290, aprox=True, idade=133, pai="levi", resumo="Filho de Levi; avô de Moisés.", refs=["GEN 46:11", "EXO 6:16-18"])
P("anrao", "Anrão", "M", 2360, aprox=True, idade=137, pai="coate", resumo="Pai de Moisés, Arão e Miriã.", refs=["EXO 6:18-20", "NUM 26:58-59"])
P("joquebede", "Joquebede", "F", 2385, aprox=True, pai="levi", sig="“O Senhor é glória”",
  resumo="Mãe de Moisés; escondeu o filho num cesto no Nilo.", refs=["EXO 2:1-10", "EXO 6:20", "NUM 26:59", "HEB 11:23"],
  cur=["Era tia do marido Anrão (Êx 6:20).",
       "Foi contratada pela filha do faraó para amamentar o próprio filho (Êx 2:9)."])
C("anrao", "joquebede")
P("miria", "Miriã", "F", 2423, aprox=True, pai="anrao", mae="joquebede", resumo="Profetisa, irmã de Moisés e Arão.",
  refs=["EXO 2:4-8", "EXO 15:20-21|Cântico após o mar", "NUM 12|Repreendida com lepra", "NUM 20:1|Morte em Cades", "MIQ 6:4"],
  cur=["É a primeira mulher chamada de profetisa na Bíblia (Êx 15:20)."])
P("arao", "Arão", "M", 2430, idade=123, pai="anrao", mae="joquebede", resumo="Primeiro sumo sacerdote de Israel.",
  historia="Irmão mais velho de Moisés, foi seu porta-voz diante do faraó. Foi consagrado como o primeiro sumo sacerdote e seus filhos como sacerdotes. Fraquejou ao fazer o bezerro de ouro. Morreu no monte Hor aos 123 anos, e Eleazar o sucedeu.",
  refs=["EXO 4:14-16", "EXO 7:7", "EXO 28-29|Vestes e consagração", "EXO 32|O bezerro de ouro", "NUM 17|A vara que floresceu", "NUM 20:22-29|Morte no monte Hor", "HEB 5:4"],
  cur=["Sua vara floresceu e deu amêndoas em uma noite (Nm 17:8).", "Tinha 83 anos quando falou com o faraó (Êx 7:7)."])
P("moises", "Moisés", "M", 2433, idade=120, pai="anrao", mae="joquebede", sig="“Tirado das águas” (Êx 2:10).",
  resumo="Libertador de Israel do Egito e mediador da Lei.",
  historia="Nascido quando o faraó mandava matar os meninos hebreus, foi escondido num cesto no Nilo e criado pela filha do faraó. Aos 40 anos fugiu para Midiã, onde se casou com Zípora e foi pastor por 40 anos.\n\nNa sarça ardente, Deus o enviou para libertar Israel. Após as dez pragas, conduziu o povo pelo mar Vermelho, recebeu a Lei no Sinai e liderou Israel 40 anos no deserto. Morreu no monte Nebo, vendo a terra prometida de longe, aos 120 anos.",
  refs=["EXO 2|Nascimento e fuga", "EXO 3-4|A sarça ardente", "EXO 7-12|As pragas e a Páscoa", "EXO 14|O mar Vermelho",
        "EXO 19-20|O Sinai e os Dez Mandamentos", "DEU 34|Morte no Nebo", "ATO 7:20-44", "HEB 11:23-29"],
  cur=["Sua vida se divide em três períodos de 40 anos: Egito, Midiã e deserto (At 7:23,30,36).",
       "Deuteronômio 34:7 diz que aos 120 anos “os seus olhos nunca se escureceram”.",
       "Apareceu com Elias na transfiguração de Jesus (Mt 17:3).",
       "Pela cronologia adotada, o Êxodo ocorreu em {AM:2513}"])
P("jetro", "Jetro", "M", 2400, aprox=True, resumo="Sacerdote de Midiã, sogro de Moisés (também chamado Reuel).",
  refs=["EXO 2:16-21", "EXO 18|O conselho a Moisés"],
  cur=["Aconselhou Moisés a delegar o julgamento do povo a chefes de mil, cem, cinquenta e dez (Êx 18)."])
P("zipora", "Zípora", "F", 2450, aprox=True, pai="jetro", sig="“Pássaro”", resumo="Esposa midianita de Moisés.", refs=["EXO 2:21-22", "EXO 4:24-26", "EXO 18:2-6"])
C("moises", "zipora")
P("gersom", "Gérson", "M", 2475, aprox=True, pai="moises", mae="zipora", sig="“Peregrino ali”", resumo="Primogênito de Moisés.", refs=["EXO 2:22", "EXO 18:3"])
P("eliezer", "Eliézer", "M", 2480, aprox=True, pai="moises", mae="zipora", sig="“Meu Deus é auxílio”", resumo="Filho de Moisés.", refs=["EXO 18:4"])
P("eliseba", "Eliseba", "F", 2435, aprox=True, pai="aminadabe", resumo="Esposa de Arão; irmã de Naassom, da tribo de Judá.", refs=["EXO 6:23"],
  cur=["Seu casamento une a linhagem sacerdotal (Levi) à real (Judá)."])
C("arao", "eliseba")
for ch, nome, am, res, refs in [
    ("nadabe", "Nadabe", 2460, "Filho de Arão; morto por oferecer fogo estranho.", ["EXO 6:23", "LEV 10:1-2"]),
    ("abiu", "Abiú", 2462, "Filho de Arão; morto por oferecer fogo estranho.", ["EXO 6:23", "LEV 10:1-2"]),
    ("eleazar", "Eleazar", 2464, "Sucessor de Arão como sumo sacerdote.", ["EXO 6:23", "NUM 20:25-28", "JOS 14:1"]),
    ("itamar", "Itamar", 2466, "Filho de Arão; supervisionou o tabernáculo.", ["EXO 6:23", "EXO 38:21"]),
]:
    P(ch, nome, "M", am, aprox=True, pai="arao", mae="eliseba", resumo=res, refs=refs)
P("fineias", "Fineias", "M", 2500, aprox=True, pai="eleazar", resumo="Sacerdote zeloso; recebeu a aliança de um sacerdócio perpétuo.",
  refs=["EXO 6:25", "NUM 25:7-13", "SAL 106:30-31"])


# =============================================================================


# =============================================================================
# Profetas
# Datas de nascimento estimadas a partir do período de atuação (Thiele para os reis da época).
# PAPEIS: (chave, papel, início, fim, local, observação). "local" = reino onde atuou.
# =============================================================================
PAPEIS = []


def PP(chave, papel, inicio=None, fim=None, local=None, obs=None):
    PAPEIS.append((chave, papel, inicio, fim, local, obs))


NASC_PROFETA = "O ano de nascimento é uma estimativa a partir da época em que profetizou."

# =============================================================================
# Irmãos de Jesus (Mt 13:55-56; Mc 6:3)
# Ligados aqui como filhos de José e Maria, nascidos depois de Jesus (leitura direta do texto).
# As outras interpretações tradicionais ficam registradas nas curiosidades.
# =============================================================================
IRMAOS_VISOES = ("Há três leituras tradicionais sobre os “irmãos” de Jesus: (1) filhos de José e Maria nascidos depois de Jesus "
                 "(Helvídio, séc. IV; a maioria dos protestantes); (2) filhos de José de um casamento anterior "
                 "(Epifânio; tradição ortodoxa); (3) primos ou parentes próximos, pois o hebraico e o aramaico usam “irmão” "
                 "em sentido amplo (Jerônimo; tradição católica). Aqui foi seguida a primeira; o pai e a mãe podem ser alterados pela interface.")
ANOS_IRMAOS = "Ano de nascimento estimado: depois de Jesus, na ordem em que são listados em Mt 13:55."
P("tiago_irmao", "Tiago (irmão de Jesus)", "M", ano=-2, aprox=True, morte=62, pai="jose_nt", mae="maria",
  resumo="“O irmão do Senhor”; líder da igreja de Jerusalém.",
  historia="Durante o ministério de Jesus, seus irmãos não criam nele (Jo 7:5). Depois da ressurreição, Jesus apareceu a Tiago (1Co 15:7), e ele passou a fazer parte da comunidade em Jerusalém.\n\nTornou-se o principal líder da igreja de Jerusalém. Presidiu o concílio que decidiu não impor a circuncisão aos gentios (At 15) e recebeu Paulo em suas visitas. A tradição lhe atribui a epístola de Tiago. Segundo o historiador Flávio Josefo, foi apedrejado por ordem do sumo sacerdote Anano em 62 d.C.",
  refs=["MAT 13:55", "MAR 6:3", "JOA 7:3-5|Os irmãos não criam nele", "1CO 15:7|Jesus lhe aparece", "GAL 1:19|“Tiago, irmão do Senhor”",
        "ATO 12:17", "ATO 15:13-21|O concílio de Jerusalém", "ATO 21:18", "GAL 2:9|Uma das “colunas”", "TIA 1:1"],
  cur=["Paulo o chama “Tiago, irmão do Senhor” e o conta entre as “colunas” da igreja, com Pedro e João (Gl 1:19; 2:9).",
       "Flávio Josefo (Antiguidades 20.9.1) registra a sua morte: “o irmão de Jesus, chamado Cristo, cujo nome era Tiago”. É uma das menções a Jesus fora da Bíblia.",
       "A tradição o chama “Tiago, o Justo”; Hegesipo conta que seus joelhos eram calejados como os de um camelo, de tanto orar.",
       "Não confundir com os apóstolos Tiago, filho de Zebedeu, e Tiago, filho de Alfeu.",
       IRMAOS_VISOES, ANOS_IRMAOS])
PP("tiago_irmao", "Líder da igreja de Jerusalém", 44, 62, None, "At 12:17; 15:13; Gl 2:9")
P("jose_irmao", "José (irmão de Jesus)", "M", ano=1, aprox=True, pai="jose_nt", mae="maria",
  resumo="Irmão de Jesus; conhecido só pelo nome.", refs=["MAT 13:55", "MAR 6:3"],
  cur=["Marcos 6:3 o chama Joset (em grego Iōsēs), forma abreviada de José.",
       "Tinha o mesmo nome do pai, José.", IRMAOS_VISOES, ANOS_IRMAOS])
P("simao_irmao", "Simão (irmão de Jesus)", "M", ano=3, aprox=True, pai="jose_nt", mae="maria",
  resumo="Irmão de Jesus; conhecido só pelo nome.", refs=["MAT 13:55", "MAR 6:3"],
  cur=["Não confundir com Simão Pedro, nem com Simão, o zelote.",
       "Não confundir com Simeão, filho de Clopas, primo de Jesus que, segundo Hegesipo, sucedeu Tiago em Jerusalém.",
       IRMAOS_VISOES, ANOS_IRMAOS])
P("judas_irmao", "Judas (irmão de Jesus)", "M", ano=5, aprox=True, pai="jose_nt", mae="maria",
  resumo="Irmão de Jesus; tradicionalmente o autor da epístola de Judas.",
  refs=["MAT 13:55", "MAR 6:3", "JUD 1:1|“Judas, servo de Jesus Cristo e irmão de Tiago”", "1CO 9:5"],
  cur=["A epístola de Judas se apresenta como de “Judas, irmão de Tiago” (Jd 1), e a tradição o identifica com este irmão de Jesus.",
       "Hegesipo, citado por Eusébio, conta que seus netos foram levados ao imperador Domiciano por serem da família de Davi, e soltos por serem simples lavradores.",
       "1Co 9:5 indica que os irmãos do Senhor viajavam acompanhados das esposas.",
       "Não confundir com Judas Iscariotes, nem com o apóstolo Judas, filho de Tiago.", IRMAOS_VISOES, ANOS_IRMAOS])
P("irmas_jesus", "Irmãs", "F", ano=7, aprox=True, pai="jose_nt", mae="maria", sem_nome=True,
  resumo="Irmãs de Jesus, citadas sem nome (“não estão entre nós todas as suas irmãs?”).",
  refs=["MAT 13:56", "MAR 6:3"],
  cur=["O texto fala em “irmãs”, no plural, e “todas”, o que sugere pelo menos duas ou três.",
       "Epifânio (séc. IV) dá a elas os nomes de Maria e Salomé; a Bíblia não as nomeia.",
       "Este card representa o grupo, não uma única pessoa.", IRMAOS_VISOES])

# =============================================================================
# Irmãs sem nome: onde a Bíblia menciona filhas/irmãs sem nomeá-las, um card "Irmãs"
# (ou "Irmã") fica ao lado dos irmãos, com cor própria (sem_nome=True).
# =============================================================================
SEM_NOME = "A Bíblia menciona estas filhas sem dar seus nomes. O card representa o grupo; o ano é uma estimativa (logo depois do irmão citado)."


def IRMAS(chave, pai, irmao_am=None, irmao_ano=None, mae=None, refs=(), resumo=None, cur=(), nome="Irmãs"):
    """card de irmãs sem nome, nascido ~10 anos depois do irmão citado"""
    kw = dict(am=irmao_am + 10) if irmao_am is not None else dict(ano=irmao_ano + 10)
    P(chave, nome, "F", aprox=True, pai=pai, mae=mae, sem_nome=True, refs=refs, cur=[*cur, SEM_NOME],
      resumo=resumo or "Filhas não nomeadas: “gerou filhos e filhas”.", **kw)


# Gênesis 5: "e gerou filhos e filhas" (depois do filho citado)
for pai_, mae_, irmao, am_irmao, v in [
    ("adao", "eva", "Sete", 130, 4), ("sete", None, "Enos", 235, 7), ("enos", None, "Cainã", 325, 10),
    ("caina", None, "Maalalel", 395, 13), ("maalalel", None, "Jarede", 460, 16), ("jarede", None, "Enoque", 622, 19),
    ("enoque", None, "Metusalém", 687, 22), ("metusalem", None, "Lameque", 874, 26), ("lameque", None, "Noé", 1056, 30)]:
    IRMAS(f"irmas_{pai_}", pai_, irmao_am=am_irmao, mae=mae_, refs=[f"GEN 5:{v}"],
          resumo=f"Irmãs de {irmao}, sem nome: “gerou filhos e filhas” (Gn 5:{v}).")
# Gênesis 11
for pai_, irmao, am_irmao, v in [
    ("sem", "Arfaxade", 1658, 11), ("arfaxade", "Selá", 1693, 13), ("sela", "Héber", 1723, 15),
    ("heber", "Pelegue", 1757, 17), ("pelegue", "Reú", 1787, 19), ("reu", "Serugue", 1819, 21),
    ("serugue", "Naor", 1849, 23), ("naor_avo", "Terá", 1878, 25)]:
    IRMAS(f"irmas_{pai_}", pai_, irmao_am=am_irmao, refs=[f"GEN 11:{v}"],
          resumo=f"Irmãs de {irmao}, sem nome: “gerou filhos e filhas” (Gn 11:{v}).")
IRMAS("irmas_jaco", "jaco", irmao_am=2259, refs=["GEN 37:35", "GEN 46:7", "GEN 46:15"],
      resumo="Filhas de Jacó além de Diná: “todos os seus filhos e todas as suas filhas” (Gn 37:35).",
      cur=["Diná é a única filha de Jacó nomeada. O plural “filhas” (Gn 37:35; 46:7) pode indicar outras filhas, ou incluir as noras e netas."])
IRMAS("irma_lo_velha", "lo", irmao_am=2078, nome="Irmã", refs=["GEN 19:8", "GEN 19:15-16", "GEN 19:30-37"],
      resumo="Filha mais velha de Ló, sem nome; mãe de Moabe.",
      cur=["Escapou de Sodoma com o pai e a irmã. Na caverna, as duas conceberam do próprio pai (Gn 19:30-38).",
           "Gn 19:14 fala de “genros” de Ló que ficaram em Sodoma, o que sugere que ele tinha outras filhas casadas."])
IRMAS("irma_lo_nova", "lo", irmao_am=2080, nome="Irmã", refs=["GEN 19:8", "GEN 19:15-16", "GEN 19:30-38"],
      resumo="Filha mais nova de Ló, sem nome; mãe de Ben-Ami.",
      cur=["Mãe de Ben-Ami, pai dos amonitas (Gn 19:38)."])
IRMAS("irmas_samuel", "elcana", irmao_ano=-1105, mae="ana_samuel", refs=["1SA 2:21"],
      resumo="Duas irmãs de Samuel, sem nome: Ana “teve três filhos e duas filhas” (1Sm 2:21).",
      cur=["Os três irmãos de Samuel também não são nomeados."])
IRMAS("irmas_davi", "davi", irmao_ano=-990, refs=["2SA 5:13", "1CR 14:3", "1CR 3:9"],
      resumo="Filhas de Davi além de Tamar: “nasceram a Davi mais filhos e filhas” (2Sm 5:13).",
      cur=["Tamar é a única filha de Davi nomeada (1Cr 3:9)."])
IRMAS("irmas_roboao", "roboao", irmao_ano=-950, refs=["2CR 11:21"],
      resumo="As 60 filhas de Roboão, sem nome (2Cr 11:21).",
      cur=["Roboão teve 18 mulheres e 60 concubinas, e “gerou vinte e oito filhos e sessenta filhas” (2Cr 11:21)."])
IRMAS("irmas_abias", "abias", irmao_ano=-930, refs=["2CR 13:21"],
      resumo="As 16 filhas de Abias, sem nome (2Cr 13:21).",
      cur=["Abias teve 14 mulheres e “gerou vinte e dois filhos e dezesseis filhas” (2Cr 13:21)."])
IRMAS("irmas_zedequias", "zedequias", irmao_ano=-600, refs=["2RE 25:7", "JER 41:10", "JER 43:6"],
      resumo="As filhas do rei Zedequias, sem nome.",
      cur=["Os filhos de Zedequias foram mortos diante dele (2Rs 25:7); as filhas ficaram em Judá sob Gedalias e foram levadas ao Egito com Jeremias (Jr 41:10; 43:6)."])

# =============================================================================
# Apóstolos (os Doze, Matias, Paulo e Barnabé) e familiares citados
# Anos de nascimento estimados (contemporâneos de Jesus). Mortes: tradição, quando indicada.
# =============================================================================
NASC_APOSTOLO = "O ano de nascimento é uma estimativa: a Bíblia não informa a idade dos apóstolos."
TRADICAO_MORTE = "O ano e a forma da morte vêm da tradição da Igreja antiga, não da Bíblia."

# --- Pedro e André
P("jonas_pedro", "Jonas (pai de Pedro)", "M", ano=-30, aprox=True, resumo="Pai de Simão Pedro e de André.",
  refs=["MAT 16:17|“Simão Barjonas”", "JOA 1:42|“Simão, filho de João”", "JOA 21:15-17"],
  cur=["Mateus o chama Jonas (“Barjonas” = filho de Jonas); João, de João. Podem ser formas do mesmo nome."])
P("pedro", "Simão Pedro", "M", ano=1, aprox=True, morte=64, morte_aprox=True, pai="jonas_pedro", sig="Cefas (aramaico) / Pedro (grego) = “pedra”",
  resumo="Pescador da Galileia; o principal dos Doze e líder da igreja primitiva.",
  historia="Pescador de Betsaida que morava em Cafarnaum, foi levado a Jesus pelo irmão André e recebeu o nome Cefas, “pedra”. Fez parte do círculo íntimo com Tiago e João e confessou: “Tu és o Cristo, o Filho do Deus vivo”.\n\nNegou Jesus três vezes na noite da prisão e foi restaurado depois da ressurreição. No Pentecostes pregou o primeiro sermão da igreja, e mais tarde abriu as portas aos gentios na casa de Cornélio. A tradição diz que foi crucificado em Roma sob Nero.",
  refs=["MAT 4:18-20|O chamado", "JOA 1:40-42|“Tu serás chamado Cefas”", "MAT 16:13-19|A confissão", "MAT 26:69-75|A negação",
        "JOA 21:15-19|“Tu me amas?”", "ATO 2:14-41|O sermão de Pentecostes", "ATO 10|Cornélio", "GAL 2:11-14", "1PE 1:1"],
  cur=["Era casado: Jesus curou a sua sogra (Mt 8:14-15), e a esposa o acompanhava nas viagens missionárias (1Co 9:5).",
       "Negou Jesus três vezes e foi restaurado com três perguntas: “Tu me amas?” (Jo 21:15-17).",
       "Segundo a tradição, foi crucificado de cabeça para baixo em Roma, sob Nero, por volta de 64–67 d.C.",
       NASC_APOSTOLO])
PP("pedro", "Apóstolo", 28, 64, None, "um dos Doze")
P("sogra_pedro", "Sogra", "F", ano=-25, aprox=True, sem_nome=True, resumo="Sogra de Pedro, sem nome; curada de febre por Jesus.",
  refs=["MAT 8:14-15", "MAR 1:29-31", "LUC 4:38-39"],
  cur=["Curada por Jesus em Cafarnaum, “levantou-se e passou a servi-los” (Mc 1:31).", "A Bíblia não dá o seu nome."])
P("esposa_pedro", "Esposa", "F", ano=3, aprox=True, sem_nome=True, mae="sogra_pedro", resumo="Esposa de Pedro, sem nome.",
  refs=["1CO 9:5|“Não temos direito de levar conosco uma esposa crente…?”", "MAT 8:14"],
  cur=["Paulo indica que ela acompanhava Pedro (Cefas) nas viagens (1Co 9:5).",
       "Clemente de Alexandria conta que ela foi martirizada antes de Pedro, e que ele a encorajou: “Lembra-te do Senhor”."])
C("pedro", "esposa_pedro")
P("andre", "André", "M", ano=5, aprox=True, morte=60, morte_aprox=True, pai="jonas_pedro", sig="“Varonil”",
  resumo="Pescador, irmão de Pedro; o primeiro chamado.",
  refs=["JOA 1:35-42|Leva Pedro a Jesus", "MAT 4:18-20", "JOA 6:8-9|O menino dos pães", "JOA 12:20-22"],
  cur=["Era discípulo de João Batista antes de seguir Jesus, e foi ele quem levou o irmão Simão a Jesus (Jo 1:40-41).",
       "A tradição diz que foi crucificado em Patras, na Grécia, numa cruz em forma de X, a “cruz de Santo André”.",
       "É o padroeiro da Escócia, da Grécia e da Rússia.", TRADICAO_MORTE, NASC_APOSTOLO])
PP("andre", "Apóstolo", 28, 60, None, "um dos Doze")

# --- Tiago e João, filhos de Zebedeu
P("zebedeu", "Zebedeu", "M", ano=-25, aprox=True, resumo="Pescador da Galileia; pai de Tiago e João.",
  refs=["MAT 4:21-22", "MAR 1:19-20"],
  cur=["Tinha empregados (Mc 1:20): ficou no barco com eles quando os filhos deixaram tudo para seguir Jesus."])
P("salome", "Salomé (mãe de Tiago e João)", "F", ano=-20, aprox=True, resumo="Mãe dos filhos de Zebedeu; seguiu Jesus até a cruz.",
  refs=["MAT 20:20-23|O pedido pelos filhos", "MAT 27:56", "MAR 15:40", "MAR 16:1-2|No sepulcro"],
  cur=["Pediu a Jesus que os filhos se sentassem à sua direita e à sua esquerda no Reino (Mt 20:21).",
       "A identificação da “mãe dos filhos de Zebedeu” (Mt 27:56) com Salomé (Mc 15:40) vem da comparação entre os evangelhos.",
       "Alguns leem João 19:25 como dizendo que ela era irmã de Maria, mãe de Jesus. Nesse caso, Tiago e João seriam primos de Jesus."])
C("zebedeu", "salome")
P("tiago_zebedeu", "Tiago (filho de Zebedeu)", "M", ano=5, aprox=True, morte=44, pai="zebedeu", mae="salome",
  resumo="Pescador, irmão de João; o primeiro apóstolo martirizado.",
  refs=["MAT 4:21-22", "MAR 3:17|Boanerges", "MAR 5:37", "MAT 17:1|Na transfiguração", "MAR 14:33|No Getsêmani", "ATO 12:1-2|Morte"],
  cur=["Jesus chamou Tiago e João de Boanerges, “filhos do trovão” (Mc 3:17).",
       "Foi o primeiro dos Doze a ser martirizado, morto à espada por Herodes Agripa I em 44 d.C. (At 12:2).",
       "A tradição liga o seu sepulcro a Santiago de Compostela, na Espanha.", NASC_APOSTOLO])
PP("tiago_zebedeu", "Apóstolo", 28, 44, None, "um dos Doze")
P("joao_apostolo", "João (apóstolo)", "M", ano=10, aprox=True, morte=100, morte_aprox=True, pai="zebedeu", mae="salome",
  sig="“O Senhor é gracioso”", resumo="Irmão de Tiago; tradicionalmente o “discípulo amado”.",
  historia="Pescador, filho de Zebedeu, foi chamado com o irmão Tiago e fez parte do círculo íntimo de Jesus. Na cruz, Jesus lhe confiou sua mãe, Maria.\n\nDepois da ressurreição, foi uma das “colunas” da igreja de Jerusalém, ao lado de Pedro e Tiago, irmão do Senhor. A tradição lhe atribui o Evangelho de João, três epístolas e o Apocalipse, escrito no exílio na ilha de Patmos, e diz que morreu idoso em Éfeso.",
  refs=["MAR 1:19-20", "LUC 9:54|“Filhos do trovão”", "JOA 13:23|O discípulo amado", "JOA 19:26-27|Recebe Maria",
        "JOA 21:20-24", "ATO 3:1-11", "GAL 2:9", "APO 1:9|Em Patmos"],
  cur=["Recebeu Maria, mãe de Jesus, aos seus cuidados (Jo 19:27).",
       "Segundo a tradição, foi o único dos Doze a não morrer como mártir, falecendo idoso em Éfeso, por volta de 100 d.C.",
       "Provavelmente era o mais jovem dos Doze.", TRADICAO_MORTE, NASC_APOSTOLO])
PP("joao_apostolo", "Apóstolo", 28, 100, None, "um dos Doze")

# --- Filipe, Bartolomeu, Tomé
P("filipe", "Filipe (apóstolo)", "M", ano=5, aprox=True, sig="“Amigo de cavalos”", resumo="Apóstolo de Betsaida; levou Natanael a Jesus.",
  refs=["JOA 1:43-46", "JOA 6:5-7", "JOA 12:21-22", "JOA 14:8-9|“Mostra-nos o Pai”", "MAT 10:3"],
  cur=["Era de Betsaida, a cidade de André e Pedro (Jo 1:44).",
       "Não confundir com Filipe, o evangelista, um dos sete diáconos (At 6:5; 8:26-40; 21:8).", NASC_APOSTOLO])
PP("filipe", "Apóstolo", 28, None, None, "um dos Doze")
P("bartolomeu", "Bartolomeu (Natanael)", "M", ano=5, aprox=True, sig="Bar-Tolmai = “filho de Tolmai”",
  resumo="Apóstolo; tradicionalmente identificado com Natanael de Caná.",
  refs=["MAT 10:3", "ATO 1:13", "JOA 1:45-51|Natanael", "JOA 21:2"],
  cur=["Seu nome é um patronímico: “filho de Tolmai”.",
       "É identificado com Natanael porque aparece junto de Filipe nas listas dos Doze, e Natanael não aparece nos outros evangelhos.",
       "Jesus disse de Natanael: “Eis um verdadeiro israelita, em quem não há dolo” (Jo 1:47).", NASC_APOSTOLO])
PP("bartolomeu", "Apóstolo", 28, None, None, "um dos Doze")
P("tome", "Tomé", "M", ano=5, aprox=True, morte=72, morte_aprox=True, sig="“Gêmeo” (aramaico), Dídimo em grego",
  resumo="Apóstolo que duvidou e depois confessou: “Senhor meu e Deus meu!”",
  refs=["JOA 11:16|“Vamos também nós, para morrermos com ele”", "JOA 14:5", "JOA 20:24-29|A dúvida e a confissão", "JOA 21:2"],
  cur=["Era chamado Dídimo, “gêmeo” (Jo 11:16), mas o irmão ou a irmã gêmea não é mencionado.",
       "Sua confissão “Senhor meu e Deus meu!” (Jo 20:28) é uma das mais fortes declarações sobre Jesus nos evangelhos.",
       "A tradição diz que levou o evangelho à Índia; os “cristãos de São Tomé”, em Kerala, o consideram seu fundador.",
       TRADICAO_MORTE, NASC_APOSTOLO])
PP("tome", "Apóstolo", 28, 72, None, "um dos Doze")

# --- Mateus e Tiago, filhos de Alfeu
P("alfeu_mateus", "Alfeu (pai de Mateus)", "M", ano=-30, aprox=True, resumo="Pai de Levi (Mateus).", refs=["MAR 2:14"],
  cur=["Tem o mesmo nome do pai de Tiago (Mc 3:18); a Bíblia não diz se é a mesma pessoa."])
P("mateus", "Mateus (Levi)", "M", ano=1, aprox=True, pai="alfeu_mateus", sig="“Dom do Senhor”",
  resumo="Cobrador de impostos chamado por Jesus; tradicionalmente autor do primeiro evangelho.",
  refs=["MAT 9:9-13|O chamado", "MAR 2:14-17", "LUC 5:27-32|O banquete na casa de Levi", "MAT 10:3"],
  cur=["Era publicano, cobrador de impostos em Cafarnaum, função desprezada pelos judeus.",
       "Marcos e Lucas o chamam de Levi; Mateus, pelo próprio nome Mateus.",
       "A tradição lhe atribui o Evangelho de Mateus, de onde vem a genealogia de Jesus desta árvore.", NASC_APOSTOLO])
PP("mateus", "Apóstolo", 28, None, None, "um dos Doze")
P("alfeu_tiago", "Alfeu (pai de Tiago)", "M", ano=-30, aprox=True, resumo="Pai do apóstolo Tiago, o menor.", refs=["MAT 10:3", "MAR 3:18"],
  cur=["Alguns o identificam com Clopas, marido de uma das Marias que estavam junto à cruz (Jo 19:25).",
       "Pode ser o mesmo Alfeu pai de Mateus (Mc 2:14); a Bíblia não diz."])
P("tiago_alfeu", "Tiago (filho de Alfeu)", "M", ano=5, aprox=True, pai="alfeu_tiago", resumo="Apóstolo; geralmente identificado com “Tiago, o menor”.",
  refs=["MAT 10:3", "MAR 3:18", "ATO 1:13", "MAR 15:40|“Tiago, o menor”"],
  cur=["É frequentemente identificado com “Tiago, o menor” (Mc 15:40), cuja mãe, Maria, esteve na crucificação.",
       "Não confundir com Tiago, filho de Zebedeu, nem com Tiago, irmão de Jesus.", NASC_APOSTOLO])
PP("tiago_alfeu", "Apóstolo", 28, None, None, "um dos Doze")

# --- Judas Tadeu, Simão o zelote
P("tiago_pai_judas", "Tiago (pai de Judas Tadeu)", "M", ano=-25, aprox=True, resumo="Pai do apóstolo Judas Tadeu.", refs=["LUC 6:16", "ATO 1:13"],
  cur=["Lucas diz “Judas de Tiago”. A maioria das traduções lê “filho de Tiago”; algumas antigas, “irmão de Tiago”."])
P("judas_tadeu", "Judas Tadeu", "M", ano=5, aprox=True, pai="tiago_pai_judas", resumo="Apóstolo; “Judas, não o Iscariotes”.",
  refs=["MAT 10:3|Tadeu", "MAR 3:18", "LUC 6:16|“Judas, filho de Tiago”", "ATO 1:13", "JOA 14:22"],
  cur=["É chamado Tadeu em Mateus e Marcos, e “Judas, filho de Tiago” em Lucas e Atos.",
       "João faz questão de distingui-lo: “Judas, não o Iscariotes” (Jo 14:22).",
       "A tradição às vezes o confunde com Judas, irmão de Jesus, autor da epístola de Judas.", NASC_APOSTOLO])
PP("judas_tadeu", "Apóstolo", 28, None, None, "um dos Doze")
P("simao_zelote", "Simão, o zelote", "M", ano=1, aprox=True, resumo="Apóstolo chamado “zelote” ou “cananeu”.",
  refs=["MAT 10:4", "LUC 6:15", "ATO 1:13"],
  cur=["“Cananeu” (Mt 10:4) vem do aramaico qan’ana, “zeloso”, e não se refere a Canaã.",
       "“Zelote” pode indicar ligação com o movimento nacionalista contra Roma. No mesmo grupo estava Mateus, que cobrava impostos para Roma.",
       NASC_APOSTOLO])
PP("simao_zelote", "Apóstolo", 28, None, None, "um dos Doze")

# --- Judas Iscariotes e Matias
P("simao_iscariotes", "Simão Iscariotes", "M", ano=-30, aprox=True, resumo="Pai de Judas Iscariotes.", refs=["JOA 6:71", "JOA 13:2", "JOA 13:26"])
P("judas_iscariotes", "Judas Iscariotes", "M", ano=1, aprox=True, morte=30, morte_aprox=True, pai="simao_iscariotes",
  resumo="Apóstolo que traiu Jesus por trinta moedas de prata.",
  refs=["MAT 26:14-16|O acordo", "MAT 26:47-50|O beijo", "MAT 27:3-10|Remorso e morte", "JOA 12:4-6", "JOA 13:21-30", "ATO 1:16-20"],
  cur=["Era o tesoureiro do grupo e “tirava o que nele se lançava” (Jo 12:6).",
       "As 30 moedas de prata e o campo do oleiro ligam-se a Zacarias 11:12-13 (Mt 27:9-10).",
       "“Iscariotes” talvez signifique “homem de Queriote”, uma cidade da Judeia; seria o único dos Doze que não era galileu.",
       NASC_APOSTOLO])
PP("judas_iscariotes", "Apóstolo", 28, 30, None, "um dos Doze; traidor")
P("matias", "Matias", "M", ano=1, aprox=True, sig="“Dom de Deus”", resumo="Escolhido para substituir Judas Iscariotes entre os Doze.",
  refs=["ATO 1:21-26"],
  cur=["Foi escolhido por sorteio entre ele e José Barsabás, depois de oração (At 1:23-26).",
       "Tinha acompanhado Jesus desde o batismo de João até a ascensão (At 1:21-22).", NASC_APOSTOLO])
PP("matias", "Apóstolo", 30, None, None, "substituto de Judas")

# --- Paulo e família
P("pai_paulo", "Pai", "M", ano=-25, aprox=True, sem_nome=True, resumo="Pai de Paulo, sem nome; fariseu e cidadão romano.",
  refs=["ATO 23:6|“Eu sou fariseu, filho de fariseus”", "ATO 22:25-28|Cidadão romano de nascimento"],
  cur=["Paulo diz ser “filho de fariseus” (At 23:6), da tribo de Benjamim (Fp 3:5).",
       "Como Paulo nasceu cidadão romano (At 22:28), o pai já tinha a cidadania, algo raro entre judeus da época.",
       "A Bíblia não dá o seu nome."])
P("paulo", "Paulo (Saulo de Tarso)", "M", ano=5, aprox=True, morte=67, morte_aprox=True, pai="pai_paulo", sig="Saulo (hebraico) / Paulo (latim, “pequeno”)",
  resumo="Fariseu perseguidor convertido no caminho de Damasco; o apóstolo dos gentios.",
  historia="Nascido em Tarso, na Cilícia, judeu da tribo de Benjamim e cidadão romano, Saulo foi educado em Jerusalém aos pés de Gamaliel. Perseguiu a igreja e consentiu na morte de Estêvão.\n\nNo caminho de Damasco encontrou Jesus ressuscitado e tornou-se o grande missionário aos gentios. Em três viagens fundou igrejas pela Ásia Menor e pela Grécia, e escreveu 13 epístolas do Novo Testamento. Preso em Jerusalém, apelou a César e foi levado a Roma, onde a tradição diz que foi decapitado sob Nero.",
  refs=["ATO 7:58-8:3|Perseguidor", "ATO 9:1-22|A conversão", "ATO 13-14|Primeira viagem", "ATO 22:3|Aos pés de Gamaliel",
        "ATO 23:16|O sobrinho", "ROM 1:1", "2CO 11:22-33|Seus sofrimentos", "FIL 3:4-6|“Da tribo de Benjamim”", "2TI 4:6-8"],
  cur=["Tinha o nome hebraico do rei Saul, também da tribo de Benjamim (Fp 3:5).",
       "Era cidadão romano de nascimento (At 22:28) e fabricava tendas (At 18:3).",
       "Escreveu 13 das 27 obras do Novo Testamento.",
       "Em Romanos 16 cita vários “parentes”: Andrônico, Júnias, Herodião, Lúcio, Jasom e Sosípatro.",
       TRADICAO_MORTE, NASC_APOSTOLO])
PP("paulo", "Apóstolo", 34, 67, None, "apóstolo dos gentios")
P("irma_paulo", "Irmã", "F", ano=8, aprox=True, sem_nome=True, pai="pai_paulo", resumo="Irmã de Paulo, sem nome; mãe do sobrinho que o salvou de uma emboscada.",
  refs=["ATO 23:16"], cur=["É a única parente próxima de Paulo citada na Bíblia, e não tem nome."])
P("sobrinho_paulo", "Sobrinho", "M", ano=30, aprox=True, sem_nome=True, mae="irma_paulo",
  resumo="Sobrinho de Paulo, sem nome; avisou-o de um plano para matá-lo.",
  refs=["ATO 23:16-22"],
  cur=["Descobriu que mais de 40 homens haviam jurado não comer nem beber até matar Paulo, e avisou o tio e o comandante romano (At 23:12-22)."])

# --- Barnabé e Marcos
P("barnabe", "Barnabé", "M", ano=1, aprox=True, sig="“Filho de consolação” (At 4:36)",
  resumo="Levita de Chipre; companheiro de Paulo, chamado apóstolo em Atos 14:14.",
  refs=["ATO 4:36-37", "ATO 9:27|Apresenta Paulo aos apóstolos", "ATO 11:22-26|Em Antioquia", "ATO 13:1-3", "ATO 14:14",
        "ATO 15:36-40|Separação de Paulo", "COL 4:10"],
  cur=["Seu nome era José; os apóstolos o apelidaram de Barnabé (At 4:36).",
       "Era primo de João Marcos (Cl 4:10); separou-se de Paulo justamente por causa de Marcos (At 15:37-39).",
       "Foi ele quem apresentou o recém-convertido Saulo aos apóstolos, que tinham medo dele (At 9:26-27).", NASC_APOSTOLO])
PP("barnabe", "Apóstolo", 45, None, None, "At 14:14")
P("maria_marcos", "Maria (mãe de Marcos)", "F", ano=-10, aprox=True, resumo="Mãe de João Marcos; em sua casa a igreja de Jerusalém se reunia.",
  refs=["ATO 12:12-17"],
  cur=["A igreja orava em sua casa quando Pedro foi libertado da prisão por um anjo; a serva Rode atendeu à porta e, de alegria, esqueceu de abri-la (At 12:13-16)."])
P("marcos", "João Marcos", "M", ano=20, aprox=True, mae="maria_marcos", resumo="Primo de Barnabé; tradicionalmente autor do Evangelho de Marcos.",
  refs=["ATO 12:12", "ATO 12:25", "ATO 13:13", "ATO 15:37-39", "COL 4:10", "2TI 4:11", "1PE 5:13|“Marcos, meu filho”"],
  cur=["Segundo Papias (séc. II), escreveu o seu evangelho a partir da pregação de Pedro, que o chama “meu filho” (1Pe 5:13).",
       "Talvez seja o jovem que fugiu nu na prisão de Jesus, no Getsêmani (Mc 14:51-52).",
       "Abandonou Paulo na primeira viagem; anos depois, Paulo pediu: “toma contigo Marcos, porque me é muito útil” (2Tm 4:11).",
       "Era primo de Barnabé (Cl 4:10)."])

# --- personagens que já estavam na árvore
PP("enoque", "Profeta", obs="“Profetizou Enoque, o sétimo depois de Adão” (Jd 14)")
PP("abraao", "Profeta", obs="Chamado profeta por Deus em Gn 20:7")
PP("moises", "Profeta", -1513, -1473, None, "“Nunca mais se levantou em Israel profeta algum como Moisés” (Dt 34:10)")
PP("arao", "Profeta", -1513, -1474, None, "“Arão, teu irmão, será o teu profeta” (Êx 7:1)")
PP("miria", "Profetisa", obs="Êx 15:20")
PP("davi", "Profeta", obs="“Sendo, pois, ele profeta…” (At 2:30)")

# --- período dos juízes e monarquia unida
P("debora", "Débora", "F", ano=-1260, aprox=True, sig="“Abelha”",
  resumo="Profetisa e juíza de Israel; liderou a vitória sobre Sísera.",
  historia="Profetisa, esposa de Lapidote, Débora julgava Israel debaixo de uma palmeira entre Ramá e Betel. Convocou Baraque para enfrentar Sísera, comandante de Jabim, rei de Canaã, e foi com ele à batalha. Sísera foi morto por Jael. O Cântico de Débora (Jz 5) celebra a vitória.",
  refs=["JUI 4|A vitória sobre Sísera", "JUI 5|O Cântico de Débora", "HEB 11:32"],
  cur=["É a única mulher entre os juízes de Israel.", "O Cântico de Débora (Jz 5) é considerado um dos textos mais antigos da Bíblia.",
       "A cronologia do período dos juízes é incerta; o ano é uma estimativa."])
PP("debora", "Profetisa", -1220, -1180, None, "data incerta"); PP("debora", "Juíza", -1220, -1180)
P("elcana", "Elcana", "M", ano=-1140, aprox=True, resumo="Efraimita de Ramá; pai de Samuel.", refs=["1SA 1:1-8", "1SA 2:11", "1SA 2:20"])
P("ana_samuel", "Ana (mãe de Samuel)", "F", ano=-1130, aprox=True, sig="“Graça”",
  resumo="Mãe de Samuel; orou pedindo um filho e o dedicou ao Senhor.",
  refs=["1SA 1|Oração em Siló", "1SA 2:1-10|O Cântico de Ana", "1SA 2:18-21"],
  cur=["O Cântico de Ana (1Sm 2:1-10) tem muitos paralelos com o Magnificat de Maria (Lc 1:46-55).",
       "Orava tão intensamente, só movendo os lábios, que o sacerdote Eli pensou que estivesse embriagada (1Sm 1:13)."])
C("elcana", "ana_samuel")
P("samuel", "Samuel", "M", ano=-1105, aprox=True, morte=-1015, pai="elcana", mae="ana_samuel", sig="“Pedido a Deus” / “ouvido por Deus”",
  resumo="Último juiz e primeiro dos grandes profetas; ungiu Saul e Davi.",
  historia="Filho da oração de Ana, foi entregue ainda menino ao serviço do tabernáculo em Siló, sob o sacerdote Eli. Ali ouviu o chamado de Deus durante a noite.\n\nComo juiz e profeta, conduziu Israel ao arrependimento e à vitória sobre os filisteus em Mispá. Quando o povo pediu um rei, ungiu Saul e, depois da rejeição deste, ungiu o jovem Davi em Belém. Morreu antes de Saul e foi pranteado por todo Israel.",
  refs=["1SA 1:20-28|Nascimento", "1SA 3|O chamado de Samuel", "1SA 7|Juiz em Mispá", "1SA 8|O povo pede um rei",
        "1SA 10:1|Unção de Saul", "1SA 16:1-13|Unção de Davi", "1SA 25:1|Morte", "ATO 3:24", "HEB 11:32"],
  cur=["Respondeu ao chamado noturno: “Fala, porque o teu servo ouve” (1Sm 3:10).",
       "Ungiu os dois primeiros reis de Israel: Saul e Davi.", "Os livros de 1 e 2 Samuel levam o seu nome, embora ele morra em 1Sm 25."])
PP("samuel", "Profeta", -1080, -1015, None, "também juiz"); PP("samuel", "Juiz", -1080, -1050)
P("gade_vidente", "Gade (vidente)", "M", ano=-1060, aprox=True, resumo="Profeta e vidente do rei Davi.",
  refs=["1SA 22:5", "2SA 24:11-19|O censo de Davi", "1CR 29:29", "2CR 29:25"],
  cur=["Não confundir com Gade, filho de Jacó.", "Registrou a história de Davi, junto com Samuel e Natã (1Cr 29:29).", NASC_PROFETA])
PP("gade_vidente", "Profeta", -1020, -975, UNIDO)
P("nata_profeta", "Natã (profeta)", "M", ano=-1040, aprox=True, resumo="Profeta da corte de Davi; anunciou a aliança davídica e o repreendeu.",
  historia="Natã comunicou a Davi a promessa de uma dinastia eterna (2Sm 7). Depois do adultério com Bate-Seba e da morte de Urias, confrontou o rei com a parábola da cordeirinha do pobre e declarou: “Tu és este homem”. Mais tarde, garantiu com Bate-Seba que Salomão fosse ungido rei.",
  refs=["2SA 7|A aliança com Davi", "2SA 12:1-15|“Tu és este homem”", "1RE 1:11-45|Salomão ungido", "1CR 29:29"],
  cur=["Não confundir com Natã, filho de Davi.", "Deu a Salomão o nome Jedidias, “amado do Senhor” (2Sm 12:25).", NASC_PROFETA])
PP("nata_profeta", "Profeta", -1005, -970, UNIDO)

# --- reino dividido
P("aias_silonita", "Aías, o silonita", "M", ano=-990, aprox=True, resumo="Profeta que anunciou a Jeroboão o reino das dez tribos.",
  refs=["1RE 11:29-39|A capa rasgada", "1RE 14:1-18|Condena a casa de Jeroboão", "2CR 9:29"],
  cur=["Rasgou a própria capa nova em 12 pedaços e deu 10 a Jeroboão (1Rs 11:30-31).",
       "Já cego pela idade, reconheceu a mulher de Jeroboão, que veio disfarçada (1Rs 14:4-6).", NASC_PROFETA])
PP("aias_silonita", "Profeta", -935, -910, ISRAEL)
P("elias", "Elias", "M", ano=-900, aprox=True, morte=-848, morte_aprox=True, sig="“Meu Deus é o Senhor”",
  resumo="Profeta de Israel contra o culto a Baal; levado ao céu num redemoinho.",
  historia="Elias, o tisbita, anunciou a Acabe uma seca de três anos e meio e foi sustentado por corvos e por uma viúva de Sarepta, cujo filho ressuscitou. No monte Carmelo desafiou 450 profetas de Baal, e o fogo do Senhor consumiu o seu sacrifício.\n\nAmeaçado por Jezabel, fugiu ao monte Horebe, onde Deus lhe falou num “cicio tranquilo e suave”. Ungiu Eliseu como sucessor e foi levado ao céu num redemoinho, com carro e cavalos de fogo.",
  refs=["1RE 17|A seca e a viúva de Sarepta", "1RE 18|O monte Carmelo", "1RE 19|No Horebe", "1RE 21:17-29|Condena Acabe",
        "2RE 1", "2RE 2:1-11|Levado ao céu", "MAL 4:5-6", "MAT 17:1-13|Na transfiguração", "TIA 5:17-18"],
  cur=["Não morreu: foi levado ao céu num redemoinho (2Rs 2:11). O ano de “morte” é o do arrebatamento.",
       "Malaquias 4:5 promete a sua volta; Jesus identificou João Batista como o “Elias que havia de vir” (Mt 11:14).",
       "Apareceu com Moisés na transfiguração de Jesus.", NASC_PROFETA])
PP("elias", "Profeta", -870, -848, ISRAEL)
P("micaias", "Micaías", "M", ano=-900, aprox=True, resumo="Profeta que anunciou a derrota de Acabe contra 400 profetas.",
  refs=["1RE 22:8-28", "2CR 18"],
  cur=["Filho de Inlá. Foi o único a contradizer os 400 profetas de Acabe, e por isso foi preso (1Rs 22:27).", NASC_PROFETA])
PP("micaias", "Profeta", -853, -853, ISRAEL)
P("safate", "Safate", "M", ano=-905, aprox=True, resumo="Pai do profeta Eliseu, de Abel-Meolá.", refs=["1RE 19:16", "1RE 19:19"])
P("eliseu", "Eliseu", "M", ano=-880, aprox=True, morte=-795, pai="safate", sig="“Deus é salvação”",
  resumo="Sucessor de Elias; profeta de muitos milagres em Israel.",
  historia="Eliseu arava com doze juntas de bois quando Elias lançou sobre ele a sua capa. Seguiu-o e, ao vê-lo subir ao céu, recebeu a “porção dobrada” do seu espírito.\n\nSeu ministério de mais de 50 anos foi marcado por milagres: a multiplicação do azeite da viúva, a ressurreição do filho da sunamita, a cura de Naamã, o machado que flutuou. Teve influência sobre os reis de Israel, de Jorão a Jeoás.",
  refs=["1RE 19:16-21|O chamado", "2RE 2|A porção dobrada", "2RE 4|A viúva e a sunamita", "2RE 5|A cura de Naamã",
        "2RE 6", "2RE 13:14-21|Morte", "LUC 4:27"],
  cur=["Pediu porção dobrada do espírito de Elias; a Bíblia registra quase o dobro de milagres para ele.",
       "Depois de morto, um cadáver lançado em seu sepulcro reviveu ao tocar os seus ossos (2Rs 13:21).", NASC_PROFETA])
PP("eliseu", "Profeta", -850, -795, ISRAEL)
P("amitai", "Amitai", "M", ano=-830, aprox=True, resumo="Pai do profeta Jonas, de Gate-Hefer.", refs=["2RE 14:25", "JON 1:1"])
P("jonas", "Jonas", "M", ano=-800, aprox=True, pai="amitai", sig="“Pomba”",
  resumo="Profeta enviado a Nínive; passou três dias no ventre de um grande peixe.",
  refs=["2RE 14:25|Profecia sob Jeroboão II", "JON 1-2|A fuga e o grande peixe", "JON 3-4|Nínive se arrepende", "MAT 12:39-41|“O sinal de Jonas”"],
  cur=["Profetizou também a restauração das fronteiras de Israel sob Jeroboão II (2Rs 14:25).",
       "Jesus usou os três dias e três noites no ventre do peixe como sinal da sua ressurreição (Mt 12:40).",
       "É o único profeta enviado a pregar arrependimento a uma nação estrangeira.", NASC_PROFETA])
PP("jonas", "Profeta", -785, -760, ISRAEL)
P("joel", "Joel", "M", ano=-860, aprox=True, sig="“O Senhor é Deus”", resumo="Profeta do “dia do Senhor” e do derramamento do Espírito.",
  refs=["JOE 1:1-12|A praga de gafanhotos", "JOE 2:28-32|“Derramarei o meu Espírito”", "ATO 2:16-21"],
  cur=["Filho de Petuel.", "Pedro citou Joel 2:28-32 no dia de Pentecostes (At 2:16-21).",
       "A data é incerta: estudiosos a situam entre os séculos IX e IV a.C. Aqui foi adotada a data antiga, no reinado de Joás.", NASC_PROFETA])
PP("joel", "Profeta", -835, -796, JUDA, "data incerta")
P("amos", "Amós", "M", ano=-790, aprox=True, sig="“Carregado”", resumo="Vaqueiro de Tecoa que profetizou contra a injustiça em Israel.",
  refs=["AMO 1:1", "AMO 5:21-24|“Corra o juízo como as águas”", "AMO 7:10-17|Contra Amazias de Betel", "AMO 9:11-12", "ATO 15:16-17"],
  cur=["Era de Judá, “boieiro e colhedor de sicômoros”, mas foi enviado a profetizar em Israel (Am 7:14-15).",
       "Datou sua profecia “dois anos antes do terremoto” (Am 1:1), lembrado séculos depois em Zc 14:5.",
       "“Corra o juízo como as águas, e a justiça como o ribeiro perene” (Am 5:24) foi citado por Martin Luther King Jr.", NASC_PROFETA])
PP("amos", "Profeta", -760, -750, ISRAEL)
P("beeri", "Beeri", "M", ano=-805, aprox=True, resumo="Pai do profeta Oseias.", refs=["OSE 1:1"])
P("oseias_profeta", "Oseias (profeta)", "M", ano=-780, aprox=True, pai="beeri", sig="“Salvação”",
  resumo="Profeta de Israel; seu casamento com Gômer simbolizou a infidelidade do povo.",
  refs=["OSE 1-3|O casamento com Gômer", "OSE 6:6|“Misericórdia quero, e não sacrifício”", "OSE 11:1|“Do Egito chamei o meu filho”", "MAT 2:15", "MAT 9:13", "ROM 9:25-26"],
  cur=["Não confundir com Oseias, último rei de Israel, seu contemporâneo.",
       "Os 11:1 é citado em Mt 2:15 a respeito da volta de Jesus do Egito.", NASC_PROFETA])
PP("oseias_profeta", "Profeta", -755, -715, ISRAEL)
P("gomer_oseias", "Gômer (esposa de Oseias)", "F", ano=-775, aprox=True, resumo="Esposa infiel de Oseias, imagem de Israel.",
  refs=["OSE 1:2-9", "OSE 3:1-3"], cur=["Filha de Diblaim.", "Oseias a resgatou por quinze siclos de prata e uma medida e meia de cevada (Os 3:2)."])
C("oseias_profeta", "gomer_oseias")
for ch, nome, sexo, ano_, sig in [("jezreel", "Jezreel", "M", -755, "“Deus semeia”: anúncio de juízo sobre a casa de Jeú"),
                                  ("loruama", "Lo-Ruama", "F", -752, "“Não amada”"),
                                  ("loami", "Lo-Ami", "M", -749, "“Não meu povo”")]:
    P(ch, nome, sexo, ano=ano_, aprox=True, pai="oseias_profeta", mae="gomer_oseias", sig=sig,
      resumo="Filho de Oseias e Gômer, com nome simbólico.", refs=["OSE 1:3-9", "OSE 2:23"],
      cur=["Em Os 2:23 os nomes são revertidos: “compadecer-me-ei da Desfavorecida… e direi a Não-Meu-Povo: Tu és o meu povo”; Paulo cita isso em Rm 9:25."])
P("amoz", "Amoz", "M", ano=-790, aprox=True, resumo="Pai do profeta Isaías.", refs=["ISA 1:1"],
  cur=["Não confundir com o profeta Amós; em hebraico os nomes são diferentes."])
P("isaias", "Isaías", "M", ano=-765, aprox=True, pai="amoz", sig="“O Senhor é salvação”",
  resumo="Profeta de Judá; o profeta mais citado no Novo Testamento.",
  historia="Isaías recebeu sua visão de chamado “no ano da morte do rei Uzias”, quando viu o Senhor num alto e sublime trono e ouviu os serafins: “Santo, santo, santo”. Profetizou sob Jotão, Acaz e Ezequias.\n\nAnunciou a Acaz o sinal do Emanuel, apoiou Ezequias durante o cerco assírio de Senaqueribe e anunciou a sua cura. Suas profecias sobre o Servo sofredor (Is 53) e o Messias são das mais citadas do Novo Testamento.",
  refs=["ISA 1:1", "ISA 6|O chamado", "ISA 7:14|O Emanuel", "ISA 9:6-7|“Um menino nos nasceu”", "ISA 36-39|Ezequias e Senaqueribe",
        "ISA 53|O Servo sofredor", "LUC 4:16-21", "JOA 12:38-41"],
  cur=["É o profeta mais citado no Novo Testamento.",
       "O Grande Rolo de Isaías, dos Manuscritos do Mar Morto, tem cerca de 2.100 anos e traz o livro completo.",
       "A tradição judaica diz que foi serrado ao meio sob Manassés; Hb 11:37 pode aludir a isso.", NASC_PROFETA])
PP("isaias", "Profeta", -740, -681, JUDA)
P("miqueias", "Miqueias", "M", ano=-760, aprox=True, sig="“Quem é como o Senhor?”", resumo="Profeta de Judá que anunciou o nascimento do Messias em Belém.",
  refs=["MIQ 1:1", "MIQ 5:2|“E tu, Belém Efrata…”", "MIQ 6:8|“Que pratiques a justiça…”", "JER 26:18-19", "MAT 2:5-6"],
  cur=["Os escribas citaram Mq 5:2 a Herodes para indicar onde o Messias nasceria (Mt 2:5-6).",
       "Um século depois, a lembrança de sua profecia salvou a vida de Jeremias (Jr 26:17-19).", NASC_PROFETA])
PP("miqueias", "Profeta", -735, -700, JUDA)
P("naum", "Naum", "M", ano=-680, aprox=True, sig="“Consolo”", resumo="Profeta que anunciou a queda de Nínive.",
  refs=["NAU 1:1", "NAU 1:15", "NAU 3"],
  cur=["Nínive caiu em 612 a.C., cerca de um século e meio depois do arrependimento no tempo de Jonas.",
       "Não confundir com Naum, ascendente de Jesus em Lucas 3:25.", NASC_PROFETA])
PP("naum", "Profeta", -660, -630, JUDA)
P("amarias_sf", "Amarias (filho de Ezequias)", "M", ano=-712, aprox=True, pai="ezequias", resumo="Trisavô do profeta Sofonias.", refs=["SOF 1:1"])
P("gedalias_sf", "Gedalias (avô de Sofonias)", "M", ano=-688, aprox=True, pai="amarias_sf", resumo="Avô do profeta Sofonias.", refs=["SOF 1:1"])
P("cusi", "Cusi", "M", ano=-670, aprox=True, pai="gedalias_sf", resumo="Pai do profeta Sofonias.", refs=["SOF 1:1"])
P("sofonias", "Sofonias", "M", ano=-652, aprox=True, pai="cusi", sig="“O Senhor esconde/protege”",
  resumo="Profeta de Judá nos dias de Josias; descendente do rei Ezequias.",
  refs=["SOF 1:1", "SOF 1:14-18|O dia do Senhor", "SOF 3:17|“Ele se deleitará em ti com alegria”"],
  cur=["Sf 1:1 traça sua genealogia por quatro gerações até Ezequias, muito provavelmente o rei, o que faria dele um profeta de sangue real.",
       "Sf 1:14-18 inspirou o hino medieval “Dies irae”.", NASC_PROFETA])
PP("sofonias", "Profeta", -630, -620, JUDA)
P("hulda", "Hulda", "F", ano=-680, aprox=True, resumo="Profetisa consultada pelo rei Josias sobre o livro da Lei.",
  refs=["2RE 22:14-20", "2CR 34:22-28"],
  cur=["Mesmo com Jeremias e Sofonias atuando na época, foi ela a consultada sobre o livro da Lei encontrado no templo.",
       "Esposa de Salum, guarda das vestimentas.", NASC_PROFETA])
PP("hulda", "Profetisa", -622, -622, JUDA)
P("habacuque", "Habacuque", "M", ano=-640, aprox=True, resumo="Profeta que questionou Deus sobre o mal; “o justo viverá pela fé”.",
  refs=["HAB 1:1-4", "HAB 2:4|“O justo viverá pela sua fé”", "HAB 3:17-19", "ROM 1:17", "GAL 3:11", "HEB 10:38"],
  cur=["Hc 2:4 é citado três vezes no Novo Testamento e foi central para a Reforma de Lutero.",
       "O livro é um diálogo: o profeta pergunta, e Deus responde.", NASC_PROFETA])
PP("habacuque", "Profeta", -609, -598, JUDA)
P("hilquias_jr", "Hilquias (pai de Jeremias)", "M", ano=-675, aprox=True, resumo="Sacerdote de Anatote, pai de Jeremias.", refs=["JER 1:1"],
  cur=["Alguns o identificam com o sumo sacerdote Hilquias, que encontrou o livro da Lei (2Rs 22:8), mas a maioria entende que são pessoas diferentes."])
P("jeremias", "Jeremias", "M", ano=-645, aprox=True, pai="hilquias_jr", sig="“O Senhor exalta”",
  resumo="O “profeta chorão”, que testemunhou a queda de Jerusalém.",
  historia="Chamado ainda jovem, no 13º ano de Josias, Jeremias profetizou durante os últimos reis de Judá, anunciando o juízo pela Babilônia e chamando o povo ao arrependimento. Foi perseguido, preso, lançado numa cisterna e acusado de traição.\n\nViu a destruição de Jerusalém em 586 a.C. e anunciou uma “nova aliança”, escrita no coração. Depois do assassinato de Gedalias, foi levado à força para o Egito, onde a tradição diz que morreu.",
  refs=["JER 1:1-10|O chamado", "JER 18:1-6|O oleiro", "JER 31:31-34|A nova aliança", "JER 36|O rolo queimado",
        "JER 38:1-13|Na cisterna", "JER 43:1-7|Levado ao Egito", "MAT 16:14", "HEB 8:8-12"],
  cur=["Respondeu ao chamado: “Ah! Senhor Deus! Eis que não sei falar; porque sou uma criança” (Jr 1:6).",
       "Deus o proibiu de se casar, como sinal ao povo (Jr 16:2).",
       "A promessa da nova aliança (Jr 31:31-34) é a passagem mais longa do AT citada no NT (Hb 8:8-12).",
       "A tradição lhe atribui o livro de Lamentações.", NASC_PROFETA])
PP("jeremias", "Profeta", -627, -580, JUDA)
P("obadias", "Obadias", "M", ano=-620, aprox=True, sig="“Servo do Senhor”", resumo="Profeta contra Edom; autor do livro mais curto do AT.",
  refs=["OBA 1:1-21"],
  cur=["É o livro mais curto do Antigo Testamento: 21 versículos.",
       "Condena Edom, descendente de Esaú, por ter se alegrado com a queda de Jerusalém.",
       "A data é incerta; aqui foi adotada a época logo após 586 a.C.", NASC_PROFETA])
PP("obadias", "Profeta", -586, -580, JUDA, "data incerta")
P("daniel", "Daniel", "M", ano=-620, aprox=True, sig="“Deus é meu juiz”",
  resumo="Exilado na Babilônia; intérprete de sonhos e profeta das visões apocalípticas.",
  historia="Levado à Babilônia ainda jovem em 605 a.C., Daniel foi educado na corte de Nabucodonosor, mas recusou-se a se contaminar com a comida do rei. Interpretou os sonhos de Nabucodonosor e a escrita na parede no banquete de Belsazar.\n\nSob Dario, foi lançado na cova dos leões por continuar orando ao seu Deus e saiu ileso. Recebeu visões sobre os reinos do mundo e as “setenta semanas”. Serviu a reis babilônios e persas por cerca de 70 anos.",
  refs=["DAN 1|Na corte da Babilônia", "DAN 2|O sonho da estátua", "DAN 5|A escrita na parede", "DAN 6|A cova dos leões",
        "DAN 7|As quatro feras e o Filho do Homem", "DAN 9:24-27|As setenta semanas", "EZE 14:14", "MAT 24:15"],
  cur=["Recebeu o nome babilônio Beltessazar (Dn 1:7).",
       "Ezequiel o cita, ainda em vida, ao lado de Noé e Jó como exemplo de justiça (Ez 14:14).",
       "Parte do livro (Dn 2:4–7:28) está escrita em aramaico.", NASC_PROFETA])
PP("daniel", "Profeta", -605, -536, JUDA, "na Babilônia")
P("buzi", "Buzi", "M", ano=-650, aprox=True, resumo="Sacerdote, pai do profeta Ezequiel.", refs=["EZE 1:3"])
P("ezequiel", "Ezequiel", "M", ano=-623, aprox=True, pai="buzi", sig="“Deus fortalece”",
  resumo="Sacerdote e profeta entre os exilados na Babilônia.",
  refs=["EZE 1:1-3|A visão junto ao rio Quebar", "EZE 2-3|O chamado", "EZE 24:15-18|A morte da esposa", "EZE 37:1-14|O vale de ossos secos", "EZE 40-48|O novo templo"],
  cur=["Foi levado à Babilônia em 597 a.C., com o rei Jeconias.",
       "Deus o proibiu de prantear a morte da esposa, como sinal ao povo (Ez 24:15-18).",
       "É chamado de “filho do homem” cerca de 90 vezes no livro.", NASC_PROFETA])
PP("ezequiel", "Profeta", -593, -571, JUDA, "na Babilônia")

# --- pós-exílio
P("ageu", "Ageu", "M", ano=-590, aprox=True, sig="“Festivo”", resumo="Profeta que exortou os repatriados a reconstruir o templo.",
  refs=["AGE 1:1-15", "AGE 2:20-23|Zorobabel como anel de selar", "ESD 5:1", "ESD 6:14"],
  cur=["Todas as suas profecias são datadas num intervalo de quatro meses, em 520 a.C.",
       "Ag 2:3 sugere que ele talvez tivesse visto o primeiro templo, antes de 586 a.C.", NASC_PROFETA])
PP("ageu", "Profeta", -520, -520, JUDA, "após o exílio")
P("ido", "Ido", "M", ano=-590, aprox=True, resumo="Sacerdote que voltou do exílio com Zorobabel; avô do profeta Zacarias.", refs=["NEE 12:4", "ZAC 1:1"])
P("baraquias", "Baraquias", "M", ano=-565, aprox=True, pai="ido", resumo="Pai do profeta Zacarias.", refs=["ZAC 1:1"])
P("zacarias_profeta", "Zacarias (profeta)", "M", ano=-545, aprox=True, pai="baraquias", sig="“O Senhor se lembra”",
  resumo="Profeta e sacerdote do pós-exílio; visões messiânicas.",
  refs=["ZAC 1:1", "ZAC 4:6|“Não por força nem por violência”", "ZAC 9:9|O rei montado num jumento", "ZAC 12:10", "MAT 21:4-5", "MAT 23:35"],
  cur=["Zc 9:9 é citado na entrada triunfal de Jesus em Jerusalém (Mt 21:5).",
       "Em Mt 23:35 Jesus fala de “Zacarias, filho de Baraquias”, morto entre o santuário e o altar; a morte narrada em 2Cr 24:20-22 é de Zacarias, filho de Joiada, uma questão muito discutida.",
       "Era de família sacerdotal (Ne 12:16).", NASC_PROFETA])
PP("zacarias_profeta", "Profeta", -520, -480, JUDA, "após o exílio")
P("malaquias", "Malaquias", "M", ano=-460, aprox=True, sig="“Meu mensageiro”", resumo="Último profeta do Antigo Testamento.",
  refs=["MAL 1:1", "MAL 3:1|“Eis que eu envio o meu anjo”", "MAL 3:8-10", "MAL 4:5-6|A volta de Elias", "MAR 1:2"],
  cur=["Depois dele, segundo a tradição judaica, a profecia cessou por cerca de 400 anos, até João Batista.",
       "Como o nome significa “meu mensageiro”, alguns pensam que é um título, não um nome.",
       "Ml 3:1 e 4:5 são aplicados a João Batista nos evangelhos.", NASC_PROFETA])
PP("malaquias", "Profeta", -435, -420, JUDA, "após o exílio")

# --- Novo Testamento
P("zacarias_jb", "Zacarias (pai de João Batista)", "M", ano=-50, aprox=True, sig="“O Senhor se lembra”",
  resumo="Sacerdote do turno de Abias; pai de João Batista.",
  refs=["LUC 1:5-25|O anúncio no templo", "LUC 1:57-66", "LUC 1:67-79|O Benedictus"],
  cur=["Ficou mudo por não crer no anúncio do anjo Gabriel, até o nascimento do filho (Lc 1:20, 64).",
       "Seu cântico, o Benedictus (Lc 1:68-79), é uma profecia (Lc 1:67)."])
PP("zacarias_jb", "Profeta", -5, -5, None, "“cheio do Espírito Santo, profetizou” (Lc 1:67)")
P("isabel", "Isabel", "F", ano=-48, aprox=True, sig="“Deus é juramento”", resumo="Mãe de João Batista; parente de Maria.",
  refs=["LUC 1:5-7", "LUC 1:24-25", "LUC 1:39-45|Visita de Maria", "LUC 1:57-60"],
  cur=["Era descendente de Arão (Lc 1:5).", "Concebeu já idosa; o bebê saltou em seu ventre quando Maria a visitou (Lc 1:41).",
       "Era parente de Maria (Lc 1:36), mas a Bíblia não diz em que grau."])
C("zacarias_jb", "isabel")
P("joao_batista", "João Batista", "M", ano=-5, aprox=True, morte=29, pai="zacarias_jb", mae="isabel", sig="“O Senhor é gracioso”",
  resumo="Precursor de Jesus; pregou o arrependimento e batizou no Jordão.",
  historia="Filho de pais idosos, nasceu cerca de seis meses antes de Jesus. Viveu no deserto, vestido de pelos de camelo, e pregava o arrependimento e o batismo para remissão de pecados, anunciando “aquele que vem depois de mim”.\n\nBatizou Jesus no rio Jordão e o apontou como “o Cordeiro de Deus”. Preso por denunciar o casamento de Herodes Antipas com Herodias, foi decapitado a pedido de Salomé.",
  refs=["LUC 1:57-80|Nascimento", "MAT 3|Pregação e batismo de Jesus", "JOA 1:19-36|“Eis o Cordeiro de Deus”",
        "MAT 11:7-15|“Este é o Elias que havia de vir”", "MAT 14:1-12|Morte"],
  cur=["Jesus disse que, entre os nascidos de mulher, não surgiu ninguém maior que João (Mt 11:11).",
       "Comia gafanhotos e mel silvestre (Mt 3:4).",
       "O historiador judeu Flávio Josefo também registra sua pregação e sua execução por Herodes Antipas.",
       "Ano de nascimento: seis meses antes de Jesus (Lc 1:26, 36)."])
PP("joao_batista", "Profeta", 27, 29, None, "Lc 1:76; Mt 11:9")
P("ana_profetisa", "Ana (profetisa)", "F", ano=-88, aprox=True, resumo="Profetisa idosa que reconheceu o menino Jesus no templo.",
  refs=["LUC 2:36-38"],
  cur=["Filha de Fanuel, da tribo de Aser, uma das tribos do norte.",
       "Viúva, “não se afastava do templo, servindo a Deus em jejuns e orações, de noite e de dia” (Lc 2:37).",
       "Lc 2:37 pode significar que tinha 84 anos ou que era viúva havia 84 anos; aqui foi adotada a primeira leitura."])
PP("ana_profetisa", "Profetisa", -4, -4, None)


def main():
    forcar = "--forcar" in sys.argv
    with cursor() as cur:
        cur.execute("SELECT to_regclass('pessoas') IS NOT NULL AS existe")
        if cur.fetchone()["existe"] and not forcar:
            cur.execute("SELECT count(*) AS n FROM pessoas")
            n = cur.fetchone()["n"]
            if n:
                sys.exit(f"O banco já tem {n} pessoas. Rodar o seed APAGA tudo e recria.\n"
                         f"Se é isso mesmo, rode novamente com --forcar.")
    schema = open(os.path.join(os.path.dirname(__file__), "schema.sql")).read()
    chaves = [p["chave"] for p in PESSOAS]
    dup = {c for c in chaves if chaves.count(c) > 1}
    assert not dup, f"chaves duplicadas: {dup}"
    with cursor() as cur:
        cur.execute(schema)
        cur.execute("INSERT INTO config VALUES ('ano_criacao', %s)", (str(ANO_CRIACAO),))
        for i, (cod, nome, abrev, en) in enumerate(LIVROS, 1):
            cur.execute("INSERT INTO livros VALUES (%s,%s,%s,%s,%s,%s)", (cod, nome, abrev, en, i, "AT" if i <= 39 else "NT"))
        ids = {}
        for p in PESSOAS:  # 1ª passada: insere sem pais
            cur.execute(
                """INSERT INTO pessoas (nome, sexo, significado_nome, ano_nascimento, nascimento_aprox,
                                        ano_morte, morte_aprox, idade_morte, resumo, historia, sem_nome)
                   VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) RETURNING id""",
                (p["nome"], p["sexo"], p["sig"], p["nasc"], p["aprox"], p["morte"],
                 p["morte_aprox"], p["idade"], txt(p["resumo"]), txt(p["historia"]), p["sem_nome"]))
            ids[p["chave"]] = cur.fetchone()["id"]
        for p in PESSOAS:  # 2ª passada: pais, referências, curiosidades, links
            pid = ids[p["chave"]]
            cur.execute("UPDATE pessoas SET pai_id=%s, mae_id=%s WHERE id=%s",
                        (ids[p["pai"]] if p["pai"] else None, ids[p["mae"]] if p["mae"] else None, pid))
            for o, r in enumerate(p["refs"]):
                cur.execute("""INSERT INTO referencias (pessoa_id, livro, capitulo, versiculo_inicio, capitulo_fim,
                                                        versiculo_fim, descricao, ordem)
                               VALUES (%s,%s,%s,%s,%s,%s,%s,%s)""", (pid, *parse_ref(r), o))
            for o, t in enumerate(p["cur"]):
                cur.execute("INSERT INTO curiosidades (pessoa_id, texto, ordem) VALUES (%s,%s,%s)", (pid, txt(t), o))
            for o, (titulo, url) in enumerate(p["links"]):
                cur.execute("INSERT INTO links (pessoa_id, titulo, url, ordem) VALUES (%s,%s,%s,%s)", (pid, titulo, url, o))
        for m, e, obs in CASAMENTOS:
            cur.execute("INSERT INTO casamentos (marido_id, esposa_id, observacao) VALUES (%s,%s,%s)", (ids[m], ids[e], obs))
        for ch, reino, ini, fim, obs in REINADOS:
            cur.execute("INSERT INTO reinados (pessoa_id, reino, inicio, fim, observacao) VALUES (%s,%s,%s,%s,%s)",
                        (ids[ch], reino, ini, fim, obs))
        for ch, papel, ini, fim, local, obs in PAPEIS:
            cur.execute("INSERT INTO papeis (pessoa_id, papel, inicio, fim, local, observacao) VALUES (%s,%s,%s,%s,%s,%s)",
                        (ids[ch], papel, ini, fim, local, obs))
        for filho, pai_, fonte, obs in FILIACOES:
            cur.execute("INSERT INTO filiacoes_alternativas (filho_id, pai_id, fonte, observacao) VALUES (%s,%s,%s,%s)",
                        (ids[filho], ids[pai_], fonte, obs))
    print(f"{len(PESSOAS)} pessoas, {len(CASAMENTOS)} casamentos, {len(FILIACOES)} filiações alternativas, {len(REINADOS)} reinados, {len(PAPEIS)} papéis, {len(LIVROS)} livros (Adão = {-ANO_CRIACAO} a.C.)")


if __name__ == "__main__":
    main()
