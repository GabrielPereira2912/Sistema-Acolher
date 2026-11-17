// =====================================================
// dashboard.js — lógica da tela inicial (Dashboard)
// Fluxo: busca números e estudantes no PHP -> desenha cards e tabela
//        -> a busca filtra e a paginação mostra 10 estudantes por vez
// (funções como criar(), dataBR() e carregarUsuario() vêm do comum.js)
// =====================================================

const POR_PAGINA = 10; // quantos estudantes aparecem por página

const corpoTabela = document.getElementById('lista-estudantes');
const campoBusca = document.getElementById('busca');
const rodapePag = document.getElementById('paginacao');
const btnAnterior = document.getElementById('pag-anterior');
const btnProximo = document.getElementById('pag-proximo');

let estudantes = [];  // lista completa vinda do banco
let filtrados = [];   // lista depois da busca
let pagina = 1;       // página atual (começa em 1)

// ---------- Início ----------
async function iniciar() {
  carregarUsuario(); // menu lateral

  try {
    const resp = await fetch(API + 'dashboard.php');
    if (!resp.ok) throw new Error();
    const dados = await resp.json();

    desenharCards(dados.cards);
    estudantes = dados.estudantes;
    aplicarBusca();
  } catch (e) {
    mostrarErroDeCarga();
  }
}

// Falhou? Mostra a mensagem com um botão para tentar de novo (sem recarregar a página)
function mostrarErroDeCarga() {
  rodapePag.hidden = true;
  const tr = criar('tr');
  const td = criar('td', 'vazio', 'Não foi possível carregar os dados. ');
  td.colSpan = 5;
  const botao = criar('button', 'btn btn-claro', 'Tentar novamente');
  botao.type = 'button';
  botao.addEventListener('click', () => {
    corpoTabela.replaceChildren(linhaMensagem('Carregando...'));
    iniciar();
  });
  td.appendChild(botao);
  tr.appendChild(td);
  corpoTabela.replaceChildren(tr);
}

// ---------- 1) Cards ----------
function desenharCards(c) {
  document.getElementById('card-acompanhados').textContent = c.acompanhados;
  document.getElementById('card-triagens').textContent = c.triagens;
  document.getElementById('card-aguardando').textContent = c.aguardando;
  document.getElementById('card-atendimentos').textContent = c.atendimentos_mes;
  document.getElementById('card-enc-abertos').textContent = c.enc_abertos;

  // Destaque: encaminhamentos abertos com prazo vencido (some se não houver)
  const alerta = document.getElementById('card-enc-vencidos');
  alerta.hidden = c.enc_vencidos <= 0;
  if (c.enc_vencidos > 0) {
    alerta.textContent = c.enc_vencidos === 1 ? '1 com prazo vencido' : `${c.enc_vencidos} com prazo vencido`;
  }
}

// ---------- 2) Tabela de estudantes ----------
function linhaMensagem(texto) {
  const tr = criar('tr');
  const td = criar('td', 'vazio', texto);
  td.colSpan = 5;
  tr.appendChild(td);
  return tr;
}

// Cria uma célula; o data-label é o título da coluna que aparece no celular
function celula(rotulo, texto) {
  const td = criar('td', '', texto);
  td.dataset.label = rotulo;
  return td;
}

function desenharTabela() {
  corpoTabela.replaceChildren();

  if (!filtrados.length) {
    corpoTabela.appendChild(linhaMensagem(
      estudantes.length ? 'Nenhum estudante encontrado para essa busca.' : 'Nenhum estudante cadastrado ainda.'
    ));
    return;
  }

  // Só os estudantes da página atual
  const inicio = (pagina - 1) * POR_PAGINA;
  filtrados.slice(inicio, inicio + POR_PAGINA).forEach((e) => {
    const destino = `prontuario.html?id=${e.estudante_id}`;
    const tr = criar('tr', 'linha-clicavel');

    // Coluna 1: nome (link, para funcionar com teclado) + selo do status
    const tdNome = criar('td', 'nome-aluno');
    const link = criar('a', '', e.nome_completo);
    link.href = destino;
    tdNome.append(link, criar('span', `selo selo-${e.status.toLowerCase()}`, STATUS_ESTUDANTE[e.status]));

    const tdSeta = criar('td', 'col-seta');
    tdSeta.innerHTML = '<svg class="icone"><use href="#i-chevron"/></svg>'; // ícone fixo nosso (sem dados do usuário)

    tr.append(
      tdNome,
      celula('Turma', e.turma),
      celula('Último atendimento', dataBR(e.ultimo_atendimento)),
      celula('Profissional', e.profissional || '—'),
      tdSeta
    );

    // A linha inteira é clicável (o link cobre quem usa teclado ou abre em nova aba)
    tr.addEventListener('click', (ev) => {
      if (!ev.target.closest('a')) location.href = destino;
    });
    corpoTabela.appendChild(tr);
  });
}

// ---------- 3) Paginação ----------
function desenharPaginacao() {
  const total = filtrados.length;
  const totalPaginas = Math.max(1, Math.ceil(total / POR_PAGINA));

  rodapePag.hidden = total <= POR_PAGINA; // cabe tudo em uma página: esconde o rodapé
  if (rodapePag.hidden) return;

  const primeiro = (pagina - 1) * POR_PAGINA + 1;
  const ultimo = Math.min(pagina * POR_PAGINA, total);
  document.getElementById('pag-info').textContent = `Mostrando ${primeiro}–${ultimo} de ${total} estudantes`;
  document.getElementById('pag-numero').textContent = `Página ${pagina} de ${totalPaginas}`;
  btnAnterior.disabled = pagina <= 1;
  btnProximo.disabled = pagina >= totalPaginas;
}

function irParaPagina(nova) {
  pagina = nova;
  desenharTabela();
  desenharPaginacao();
}
btnAnterior.addEventListener('click', () => irParaPagina(pagina - 1));
btnProximo.addEventListener('click', () => irParaPagina(pagina + 1));

// ---------- 4) Busca ----------
// Tira acentos e maiúsculas: "julia" encontra "Júlia"
function normalizar(texto) {
  return (texto || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase();
}

// Filtra a lista e volta para a página 1 (senão a página atual poderia nem existir mais)
function aplicarBusca() {
  const termo = normalizar(campoBusca.value.trim());
  filtrados = estudantes.filter((e) =>
    normalizar(`${e.nome_completo} ${e.turma} ${e.profissional}`).includes(termo)
  );
  irParaPagina(1);
}
campoBusca.addEventListener('input', aplicarBusca);

iniciar();
