// =====================================================
// prontuario.js — lógica da tela "Prontuário"
// Endereço: prontuario.html?id=NUMERO_DO_ESTUDANTE
//   sem ?id  -> mostra a lista para escolher o estudante
//   com ?id  -> mostra ficha + linha do tempo + formulário de novo atendimento
// (funções como criar(), dataBR(), mostrarAviso() vêm do comum.js)
// =====================================================

const STATUS_ENCAMINHAMENTO = { ABERTO: 'Aberto', CONCLUIDO: 'Concluído', CANCELADO: 'Cancelado' };

// ---------- Elementos da página ----------
const estudanteId = new URLSearchParams(location.search).get('id');
const form = document.getElementById('form-atendimento');
const campoDestino = document.getElementById('destino_id');
const campoPrazo = document.getElementById('prazo');
const btnSalvar = document.getElementById('btn-salvar');

// ---------- Início ----------
async function iniciar() {
  const usuario = await carregarUsuario(); // preenche o menu lateral

  if (!estudanteId) {
    await mostrarSeletor();
    return;
  }

  // Admin não registra atendimento: esconde o formulário
  if (usuario) {
    // defaultValue: assim o form.reset() (botão Limpar) não apaga o nome
    document.getElementById('profissional').defaultValue = usuario.nome;
    if (usuario.perfil === 'ADMIN') document.getElementById('card-novo').hidden = true;
  }

  limparFormulario();
  await carregarProntuario();
}

// Mostra só uma das três áreas da tela
function mostrarArea(nome) {
  document.getElementById('area-seletor').hidden = nome !== 'seletor';
  document.getElementById('area-prontuario').hidden = nome !== 'prontuario';
  document.getElementById('area-erro').hidden = nome !== 'erro';
}

function mostrarErroTela(texto) {
  document.getElementById('area-erro').textContent = texto;
  mostrarArea('erro');
}

// ---------- 1) Sem ?id: lista de estudantes ----------
async function mostrarSeletor() {
  try {
    const resp = await fetch(API + 'estudantes.php');
    const lista = await resp.json();
    const seletor = document.getElementById('seletor-estudante');
    lista.forEach((e) => {
      const op = criar('option', '', `${e.nome_completo} (${e.matricula})`);
      op.value = e.id;
      seletor.appendChild(op);
    });
    // escolheu -> abre o prontuário dele
    seletor.addEventListener('change', () => {
      if (seletor.value) location.href = `prontuario.html?id=${seletor.value}`;
    });
    mostrarArea('seletor');
  } catch (e) {
    mostrarErroTela('Não foi possível carregar a lista de estudantes.');
  }
}

// ---------- 2) Com ?id: carregar o prontuário ----------
// recarga = true quando é só atualização após salvar (não registra nova visualização)
async function carregarProntuario(recarga = false) {
  try {
    const url = `${API}prontuario.php?id=${encodeURIComponent(estudanteId)}${recarga ? '&recarga=1' : ''}`;
    const resp = await fetch(url);
    const dados = await resp.json();
    if (!resp.ok) {
      mostrarErroTela(dados.erro || 'Não foi possível abrir o prontuário.');
      return;
    }

    desenharFicha(dados.estudante);
    desenharLinhaDoTempo(dados.linha_do_tempo);
    desenharEncaminhamentos(dados.encaminhamentos);
    preencherSelect('tipo_acao_id', dados.tipos_acao, 'Selecione');
    preencherSelect('destino_id', dados.destinos, 'Sem encaminhamento', (d) => `${d.nome} (${d.natureza === 'INTERNO' ? 'interno' : 'externo'})`);
    mostrarArea('prontuario');
  } catch (e) {
    mostrarErroTela('Falha de comunicação com o servidor.');
  }
}

// Cabeçalho com os dados do estudante
function desenharFicha(e) {
  const texto = (id, valor) => (document.getElementById(id).textContent = valor);

  texto('ficha-avatar', iniciais(e.nome_completo));
  texto('ficha-nome', e.nome_completo);
  texto('ficha-status', STATUS_ESTUDANTE[e.status]);
  texto('ficha-etapa', ETAPAS[e.etapa_ensino]);
  texto('ficha-matricula', e.matricula);
  texto('ficha-turma', `${e.turma} · ${TURNOS[e.turno]}`);
  texto('ficha-idade', `${calcularIdade(e.data_nascimento)} anos (${dataBR(e.data_nascimento)})`);
  texto('ficha-responsavel', e.responsavel ? `${e.responsavel.nome} (${e.responsavel.parentesco})` : '—');
  texto('ficha-profissional', e.profissional || '—');
  document.title = `${e.nome_completo} · Acolher`;
}

// Linha do tempo: um item por acolhimento/atendimento, do mais novo ao mais antigo
function desenharLinhaDoTempo(itens) {
  const lista = document.getElementById('linha-tempo');
  lista.replaceChildren();
  document.getElementById('linha-contagem').textContent =
    itens.length === 1 ? '1 registro' : `${itens.length} registros`;

  if (!itens.length) {
    lista.appendChild(criar('li', 'vazio', 'Nenhum registro ainda.'));
    return;
  }

  itens.forEach((i) => {
    const li = criar('li', 'item-tempo');
    li.append(
      criar('time', 'item-data', dataBR(i.data)),
      criar('strong', 'item-titulo', i.titulo),
      criar('span', 'item-autor', `${i.profissional} · ${CARGOS[i.cargo] || i.cargo}`),
      criar('p', 'item-texto', i.descricao || 'Sem descrição.')
    );
    if (i.modalidade) li.appendChild(criar('span', 'etiqueta', MODALIDADES[i.modalidade]));
    lista.appendChild(li);
  });
}

// Encaminhamentos: destaque para os abertos com prazo vencido
function desenharEncaminhamentos(itens) {
  const lista = document.getElementById('lista-enc');
  lista.replaceChildren();
  document.getElementById('enc-contagem').textContent =
    itens.length === 1 ? '1 encaminhamento' : `${itens.length} encaminhamentos`;

  if (!itens.length) {
    lista.appendChild(criar('li', 'vazio', 'Nenhum encaminhamento registrado.'));
    return;
  }

  itens.forEach((e) => {
    const vencido = e.status === 'ABERTO' && e.prazo < hojeISO();
    const li = criar('li', 'item-enc');

    const info = criar('div');
    info.append(
      criar('strong', '', e.destino),
      criar('span', 'item-autor', `Prazo ${dataBR(e.prazo)} · Responsável: ${e.responsavel}`)
    );

    const selo = criar('span', `selo ${vencido ? 'selo-alerta' : ''}`, vencido ? 'Vencido' : STATUS_ENCAMINHAMENTO[e.status]);
    li.append(info, selo);
    lista.appendChild(li);
  });
}

// Preenche um <select> com as opções do banco (refaz do zero para não duplicar)
function preencherSelect(idSelect, itens, textoInicial, rotulo = (i) => i.nome) {
  const select = document.getElementById(idSelect);
  const escolhido = select.value; // mantém a escolha se for recarga
  select.replaceChildren();
  const inicial = criar('option', '', textoInicial);
  inicial.value = '';
  select.appendChild(inicial);
  itens.forEach((i) => {
    const op = criar('option', '', rotulo(i));
    op.value = i.id;
    select.appendChild(op);
  });
  select.value = escolhido;
}

// ---------- 3) Formulário de novo atendimento ----------
ligarLimpezaDeErros(form);

// O prazo só faz sentido quando existe encaminhamento
campoDestino.addEventListener('change', () => {
  campoPrazo.disabled = !campoDestino.value;
  if (!campoDestino.value) campoPrazo.value = '';
});

// O calendário do prazo não deixa escolher dia anterior ao do atendimento
function ajustarPrazoMinimo() {
  const data = document.getElementById('data_atendimento').value;
  campoPrazo.min = data || '';
  if (data && campoPrazo.value && campoPrazo.value < data) campoPrazo.value = '';
}
document.getElementById('data_atendimento').addEventListener('change', ajustarPrazoMinimo);

function limparFormulario() {
  form.reset();
  limparErros(form);
  const data = document.getElementById('data_atendimento');
  data.max = hojeISO(); // não permite data futura
  data.value = hojeISO(); // padrão: hoje
  campoPrazo.disabled = true;
  ajustarPrazoMinimo();
}
document.getElementById('btn-limpar').addEventListener('click', limparFormulario);

form.addEventListener('submit', async (e) => {
  e.preventDefault(); // não deixa a página recarregar
  limparErros(form);

  const dados = Object.fromEntries(new FormData(form));
  dados.estudante_id = estudanteId;

  // Validação rápida no navegador (a do PHP é a que vale)
  const erros = checarObrigatorios(form);
  if (dados.destino_id && !dados.prazo) erros.prazo = 'Informe o prazo do encaminhamento.';
  if (Object.keys(erros).length) {
    mostrarErros(form, erros);
    return;
  }

  btnSalvar.disabled = true; // evita clique duplo
  try {
    const resp = await fetch(API + 'atendimentos.php', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(dados),
    });
    const json = await resp.json();

    if (resp.ok) {
      mostrarAviso('Atendimento registrado com sucesso!');
      limparFormulario();
      await carregarProntuario(true); // atualiza linha do tempo, status e encaminhamentos
    } else if (json.erros) {
      mostrarErros(form, json.erros);
    } else {
      mostrarAviso(json.erro || 'Erro ao registrar.', false);
    }
  } catch (err) {
    mostrarAviso('Falha de comunicação com o servidor.', false);
  } finally {
    btnSalvar.disabled = false;
  }
});

iniciar();
