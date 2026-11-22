// =====================================================
// triagem.js — lógica da tela "Triagem de Demandas"
// Endereço: triagem-demandas.html?estudante=NUMERO (o ?estudante é opcional;
// o cadastro já abre a tela com o aluno recém-cadastrado escolhido).
// Fluxo: carrega estudantes e categorias -> marca demandas -> valida -> envia JSON ao PHP
// (funções como criar(), mostrarAviso(), mostrarErros() vêm do comum.js)
// =====================================================

// ---------- Elementos da página ----------
const form = document.getElementById('form-triagem');
const seletor = document.getElementById('estudante_id');
const areaOpcoes = document.getElementById('opcoes');
const campoOutras = document.getElementById('campo-outras');
const inputOutras = document.getElementById('outras_especificacao');
const contador = document.getElementById('contador');
const notaTriado = document.getElementById('nota-triado');
const cardDemandas = document.getElementById('card-demandas');
const btnSalvar = document.getElementById('btn-salvar');

let categorias = []; // categorias vindas do banco

// ---------- Início ----------
async function iniciar() {
  const usuario = await carregarUsuario(); // menu lateral

  // A triagem é da equipe técnica: o administrador volta para o Dashboard
  if (bloquearAdmin(usuario)) return;

  await Promise.all([carregarEstudantes(), carregarCategorias()]);

  // Veio do cadastro (?estudante=N)? Já deixa o aluno escolhido.
  const idInicial = new URLSearchParams(location.search).get('estudante');
  if (idInicial && [...seletor.options].some((o) => o.value === idInicial)) {
    seletor.value = idInicial;
    verificarEstudante();
  }
}

// ---------- 1) Estudantes ----------
async function carregarEstudantes() {
  try {
    const resp = await fetch(API + 'estudantes.php');
    if (!resp.ok) throw new Error();
    const lista = await resp.json();

    lista.forEach((e) => {
      const triado = Number(e.tem_acolhimento) === 1; // o banco pode devolver "0"/"1" como texto
      const op = criar('option', '', `${e.nome_completo} (${e.matricula})${triado ? ' · já triado' : ''}`);
      op.value = e.id;
      op.dataset.triado = triado ? '1' : '0';
      seletor.appendChild(op);
    });
  } catch (e) {
    mostrarAviso('Não foi possível carregar os estudantes.', false);
  }
}

// Se o estudante escolhido já foi triado, mostra o aviso e esconde o formulário
function verificarEstudante() {
  const op = seletor.selectedOptions[0];
  const triado = !!op && op.dataset.triado === '1';

  notaTriado.hidden = !triado;
  cardDemandas.hidden = triado;
  btnSalvar.disabled = triado;
  document.getElementById('link-prontuario').href = `prontuario.html?id=${seletor.value}`;
}
seletor.addEventListener('change', verificarEstudante);

// ---------- 2) Categorias (checkboxes) ----------
async function carregarCategorias() {
  try {
    const resp = await fetch(API + 'categorias.php');
    if (!resp.ok) throw new Error();
    categorias = await resp.json();

    categorias.forEach((c) => {
      // <label class="opcao"><input type="checkbox"> texto</label>
      const caixa = criar('input');
      caixa.type = 'checkbox';
      caixa.name = 'categoria';
      caixa.value = c.id;
      caixa.dataset.exige = Number(c.exige_especificacao) === 1 ? '1' : '0';

      const rotulo = criar('label', 'opcao');
      rotulo.append(caixa, criar('span', '', c.nome));
      areaOpcoes.appendChild(rotulo);
    });
    atualizarMarcadas();
  } catch (e) {
    mostrarAviso('Não foi possível carregar as categorias.', false);
  }
}

function caixasMarcadas() {
  return [...areaOpcoes.querySelectorAll('input:checked')];
}

// Atualiza o contador e mostra o campo "Outras" quando necessário
function atualizarMarcadas() {
  const marcadas = caixasMarcadas();
  contador.textContent = `Seleção múltipla · ${marcadas.length} de ${categorias.length} selecionadas`;

  const exige = marcadas.some((c) => c.dataset.exige === '1');
  campoOutras.hidden = !exige;
  if (!exige) inputOutras.value = '';
}
areaOpcoes.addEventListener('change', atualizarMarcadas);

// ---------- 3) Envio do formulário ----------
ligarLimpezaDeErros(form);

form.addEventListener('submit', async (e) => {
  e.preventDefault(); // não deixa a página recarregar
  limparErros(form);

  const marcadas = caixasMarcadas();
  const dados = {
    estudante_id: seletor.value,
    categorias: marcadas.map((c) => c.value),
    outras_especificacao: inputOutras.value.trim(),
    descricao_complementar: document.getElementById('descricao_complementar').value.trim(),
  };

  // Validação rápida no navegador (a do PHP é a que vale)
  const erros = {};
  if (!dados.estudante_id) erros.estudante_id = 'Selecione o estudante.';
  if (!marcadas.length) erros.categorias = 'Selecione ao menos uma demanda.';
  if (marcadas.some((c) => c.dataset.exige === '1') && !dados.outras_especificacao) {
    erros.outras_especificacao = 'Especifique a demanda "Outras".';
  }
  if (!dados.descricao_complementar) erros.descricao_complementar = 'Descreva a situação inicial.';
  if (Object.keys(erros).length) {
    mostrarErros(form, erros);
    return;
  }

  btnSalvar.disabled = true; // evita clique duplo
  let enviado = false;
  try {
    const resp = await fetch(API + 'acolhimentos.php', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(dados),
    });
    const json = await resp.json();

    if (resp.ok) {
      enviado = true;
      mostrarAviso('Triagem registrada com sucesso!');
      // Segue para o prontuário, onde começam os atendimentos
      setTimeout(() => (location.href = `prontuario.html?id=${json.estudante_id}`), 1200);
    } else if (json.erros) {
      mostrarErros(form, json.erros);
    } else {
      mostrarAviso(json.erro || 'Erro ao registrar.', false);
    }
  } catch (err) {
    mostrarAviso('Falha de comunicação com o servidor.', false);
  } finally {
    if (!enviado) btnSalvar.disabled = false; // se deu certo, mantém travado até trocar de tela
  }
});

// ---------- 4) Cancelar / limpar ----------
document.getElementById('btn-cancelar').addEventListener('click', () => {
  form.reset();
  limparErros(form);
  atualizarMarcadas();
  verificarEstudante();
});

iniciar();
