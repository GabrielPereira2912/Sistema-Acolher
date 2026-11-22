// =====================================================
// estudantes.js — correção de dados dos estudantes (tela só para ADMIN)
// Fluxo: carrega estudantes e turmas -> busca/filtro/paginação -> janela de edição -> salva
// O administrador NÃO vê prontuário: aqui só há identificação, turma e responsável.
// (funções como criar(), dataBR() e carregarUsuario() vêm do comum.js)
// =====================================================
const POR_PAGINA = 10;

const corpo = document.getElementById('lista-estudantes');
const campoBusca = document.getElementById('busca');
const filtroTurma = document.getElementById('filtro-turma');
const rodapePag = document.getElementById('paginacao');

const dialogo = document.getElementById('dlg-estudante');
const form = document.getElementById('form-estudante-edicao');
const campoTurma = document.getElementById('ed_turma');

let estudantes = []; // lista completa
let filtrados = [];  // depois da busca/filtro
let turmas = [];     // turmas do ano letivo atual (para o select de edição)
let pagina = 1;
let editando = null; // estudante aberto na janela

// ---------- Início ----------
async function iniciar() {
  const usuario = await carregarUsuario();
  if (!usuario) return;
  if (usuario.perfil !== 'ADMIN') { location.replace('index.html'); return; } // tela só do administrador

  try {
    const [respEst, respTurmas] = await Promise.all([fetch(API + 'estudantes_gestao.php'), fetch(API + 'turmas.php')]);
    if (!respEst.ok || !respTurmas.ok) throw new Error();
    estudantes = await respEst.json();
    turmas = await respTurmas.json();
    montarFiltroDeTurmas();
    aplicarFiltros();
  } catch (e) {
    mostrarMensagem('Não foi possível carregar os estudantes.');
  }
}

function rotuloTurma(t) {
  return `${t.nome} · ${TURNOS[t.turno]}`;
}

// O filtro lista as turmas que realmente têm estudantes (sem repetir)
function montarFiltroDeTurmas() {
  const vistas = new Map();
  estudantes.forEach((e) => vistas.set(String(e.turma_id), rotuloTurma({ nome: e.turma, turno: e.turno })));
  [...vistas.entries()].sort((a, b) => a[1].localeCompare(b[1], 'pt-BR')).forEach(([id, texto]) => {
    const op = criar('option', '', texto);
    op.value = id;
    filtroTurma.appendChild(op);
  });
}

// ---------- Tabela ----------
function mostrarMensagem(texto) {
  rodapePag.hidden = true;
  const tr = criar('tr');
  const td = criar('td', 'vazio', texto);
  td.colSpan = 5;
  tr.appendChild(td);
  corpo.replaceChildren(tr);
}

function celula(rotulo, conteudo) {
  const td = criar('td', '');
  td.dataset.label = rotulo;
  if (typeof conteudo === 'string') td.textContent = conteudo; else td.appendChild(conteudo);
  return td;
}

function desenharTabela() {
  document.getElementById('estudantes-contagem').textContent =
    filtrados.length === estudantes.length ? `${estudantes.length} cadastrado(s)` : `${filtrados.length} de ${estudantes.length} cadastrado(s)`;

  if (!filtrados.length) {
    mostrarMensagem(estudantes.length ? 'Nenhum estudante encontrado.' : 'Nenhum estudante cadastrado ainda.');
    return;
  }

  corpo.replaceChildren();
  const inicio = (pagina - 1) * POR_PAGINA;
  filtrados.slice(inicio, inicio + POR_PAGINA).forEach((e) => {
    const tr = criar('tr');

    const tdNome = criar('td', 'nome-aluno');
    tdNome.append(criar('strong', 'nome-simples', e.nome_completo), criar('span', 'usuario-email', `Matrícula ${e.matricula}`));

    const resp = criar('div');
    resp.append(criar('span', 'usuario-nome-lista', e.responsavel_nome || '—'));
    if (e.responsavel_nome) resp.append(criar('span', 'usuario-email', `${e.responsavel_parentesco} · ${e.responsavel_telefone}`));

    const btn = criar('button', 'btn btn-claro', 'Editar');
    btn.type = 'button';
    btn.addEventListener('click', () => abrirEdicao(e));
    const acoes = criar('div', 'acoes-linha');
    acoes.appendChild(btn);

    tr.append(tdNome, celula('Turma', rotuloTurma({ nome: e.turma, turno: e.turno })),
      celula('Nascimento', dataBR(e.data_nascimento)), celula('Responsável', resp), celula('Ações', acoes));
    corpo.appendChild(tr);
  });
  desenharPaginacao();
}

function desenharPaginacao() {
  const total = filtrados.length;
  const totalPaginas = Math.max(1, Math.ceil(total / POR_PAGINA));
  rodapePag.hidden = total <= POR_PAGINA;
  if (rodapePag.hidden) return;
  const primeiro = (pagina - 1) * POR_PAGINA + 1;
  const ultimo = Math.min(pagina * POR_PAGINA, total);
  document.getElementById('pag-info').textContent = `Mostrando ${primeiro}–${ultimo} de ${total} estudantes`;
  document.getElementById('pag-numero').textContent = `Página ${pagina} de ${totalPaginas}`;
  document.getElementById('pag-anterior').disabled = pagina <= 1;
  document.getElementById('pag-proximo').disabled = pagina >= totalPaginas;
}
document.getElementById('pag-anterior').addEventListener('click', () => { pagina--; desenharTabela(); });
document.getElementById('pag-proximo').addEventListener('click', () => { pagina++; desenharTabela(); });

// ---------- Busca e filtro ----------
function normalizar(texto) {
  return (texto || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase();
}

function aplicarFiltros() {
  const termo = normalizar(campoBusca.value.trim());
  filtrados = estudantes.filter((e) =>
    (!filtroTurma.value || String(e.turma_id) === filtroTurma.value) &&
    normalizar(`${e.nome_completo} ${e.matricula} ${e.responsavel_nome}`).includes(termo)
  );
  pagina = 1; // volta para a primeira página (a atual poderia nem existir mais)
  desenharTabela();
}
campoBusca.addEventListener('input', aplicarFiltros);
filtroTurma.addEventListener('change', aplicarFiltros);

// ---------- Janela de edição ----------
ligarMascaraMatricula(document.getElementById('ed_matricula'));
ligarMascaraTelefone(document.getElementById('ed_resp_telefone'));
document.getElementById('ed_nascimento').max = hojeISO(); // bloqueia datas futuras
ligarLimpezaDeErros(form);

function abrirEdicao(e) {
  editando = e;
  limparErros(form);

  // Select de turma: turmas do ano atual + a turma atual do aluno (que pode ser de outro ano)
  campoTurma.replaceChildren(criar('option', '', 'Selecione a turma'));
  campoTurma.firstChild.value = '';
  const opcoes = turmas.map((t) => ({ id: t.id, texto: rotuloTurma(t) }));
  if (!opcoes.some((o) => Number(o.id) === Number(e.turma_id))) {
    opcoes.push({ id: e.turma_id, texto: `${rotuloTurma({ nome: e.turma, turno: e.turno })} (${e.ano_letivo})` });
  }
  opcoes.forEach((o) => {
    const op = criar('option', '', o.texto);
    op.value = o.id;
    campoTurma.appendChild(op);
  });

  document.getElementById('ed_nome').value = e.nome_completo;
  document.getElementById('ed_matricula').value = e.matricula;
  document.getElementById('ed_nascimento').value = (e.data_nascimento || '').slice(0, 10);
  campoTurma.value = e.turma_id;
  document.getElementById('ed_resp_nome').value = e.responsavel_nome || '';
  document.getElementById('ed_resp_parentesco').value = e.responsavel_parentesco || '';
  document.getElementById('ed_resp_telefone').value = formatarTelefone(e.responsavel_telefone || '');
  dialogo.showModal();
  document.getElementById('ed_nome').focus();
}
document.getElementById('ed-cancelar').addEventListener('click', () => dialogo.close());

form.addEventListener('submit', async (ev) => {
  ev.preventDefault();
  limparErros(form);

  const erros = checarObrigatorios(form);
  if (Object.keys(erros).length) { mostrarErros(form, erros); return; }
  const dados = { id: editando.id, ...Object.fromEntries(new FormData(form)) };

  // Mudou de turma? Confirma (é a correção mais sensível desta tela)
  if (Number(dados.turma_id) !== Number(editando.turma_id)) {
    const nova = campoTurma.options[campoTurma.selectedIndex].textContent;
    if (!confirm(`Mudar ${editando.nome_completo} para a turma ${nova}?`)) return;
  }

  const botao = document.getElementById('ed-salvar');
  botao.disabled = true;
  try {
    const resp = await fetch(API + 'estudantes_gestao.php', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(dados),
    });
    const json = await resp.json().catch(() => ({}));
    if (resp.ok) {
      dialogo.close();
      mostrarAviso('Dados do estudante atualizados.');
      const resp2 = await fetch(API + 'estudantes_gestao.php'); // recarrega para refletir a nova turma/nome
      if (resp2.ok) { estudantes = await resp2.json(); aplicarFiltros(); }
    } else if (json.erros) {
      mostrarErros(form, json.erros);
    } else {
      mostrarAviso(json.erro || 'Não foi possível salvar.', false);
    }
  } catch (e) {
    mostrarAviso('Sem conexão com o servidor.', false);
  } finally {
    botao.disabled = false;
  }
});

iniciar();
