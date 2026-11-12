// =====================================================
// cadastro.js — lógica da tela "Cadastro do Estudante"
// Fluxo: carrega turmas -> usuário preenche -> valida -> envia JSON para o PHP
// =====================================================

// (API, TURNOS, ETAPAS, dataBR... e mostrarAviso() vêm do comum.js)
const TELA_TRIAGEM = 'triagem-demandas.html';
const IR_PARA_TRIAGEM = false;             // mude para true quando a tela de triagem existir

// ---------- Elementos da página ----------
const form = document.getElementById('form-estudante');
const campoTurma = document.getElementById('turma_id');
const campoTurno = document.getElementById('turno');
const campoEtapa = document.getElementById('etapa');
const campoIdade = document.getElementById('idade');
const campoNascimento = document.getElementById('data_nascimento');
const btnSalvar = document.getElementById('btn-salvar');

let turmas = []; // guarda as turmas vindas do banco

// ---------- 1) Turmas ----------
// Busca as turmas no PHP e monta as opções do <select>
async function carregarTurmas() {
  try {
    const resp = await fetch(API + 'turmas.php');
    if (!resp.ok) throw new Error();
    turmas = await resp.json();

    turmas.forEach((t) => {
      const opcao = document.createElement('option');
      opcao.value = t.id;
      opcao.textContent = `${t.nome} · ${TURNOS[t.turno]}`;
      campoTurma.appendChild(opcao);
    });
  } catch (e) {
    mostrarAviso('Não foi possível carregar as turmas.', false);
  }
}

// Ao escolher a turma, Turno e Etapa são preenchidos sozinhos
campoTurma.addEventListener('change', () => {
  const turma = turmas.find((t) => t.id == campoTurma.value);
  campoTurno.value = turma ? TURNOS[turma.turno] : 'Automático';
  campoEtapa.value = turma ? ETAPAS[turma.etapa_ensino] : 'Automático';
});

// ---------- 2) Idade (calculada, nunca salva no banco) ----------
campoNascimento.max = hojeISO(); // bloqueia datas futuras

campoNascimento.addEventListener('change', () => {
  if (!campoNascimento.value) { campoIdade.value = '—'; return; }
  const idade = calcularIdade(campoNascimento.value);
  campoIdade.value = idade >= 0 ? `${idade} anos` : '—';
});

// ---------- 3) Máscaras (formatam enquanto digita) ----------
// Matrícula: 0000-00000
document.getElementById('matricula').addEventListener('input', (e) => {
  const n = e.target.value.replace(/\D/g, '').slice(0, 9);
  e.target.value = n.length > 4 ? `${n.slice(0, 4)}-${n.slice(4)}` : n;
});

// Telefone: (00) 00000-0000 (aceita fixo de 10 dígitos também)
document.getElementById('responsavel_telefone').addEventListener('input', (e) => {
  const n = e.target.value.replace(/\D/g, '').slice(0, 11);
  let t = n;
  if (n.length > 10) t = `(${n.slice(0, 2)}) ${n.slice(2, 7)}-${n.slice(7)}`;
  else if (n.length > 6) t = `(${n.slice(0, 2)}) ${n.slice(2, 6)}-${n.slice(6)}`;
  else if (n.length > 2) t = `(${n.slice(0, 2)}) ${n.slice(2)}`;
  e.target.value = t;
});

// ---------- 4) Erros e avisos: funções prontas no comum.js ----------
ligarLimpezaDeErros(form);

// ---------- 5) Envio do formulário ----------
form.addEventListener('submit', async (e) => {
  e.preventDefault(); // não deixa a página recarregar
  limparErros(form);

  // Junta todos os campos que têm "name" em um objeto { nome: valor }
  const dados = Object.fromEntries(new FormData(form));

  // Validação rápida no navegador: campos obrigatórios vazios
  const erros = checarObrigatorios(form);
  if (Object.keys(erros).length) {
    mostrarErros(form, erros);
    return;
  }

  btnSalvar.disabled = true; // evita clique duplo
  try {
    const resp = await fetch(API + 'estudantes.php', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(dados),
    });
    const json = await resp.json();

    if (resp.ok) {
      mostrarAviso('Estudante cadastrado com sucesso!');
      if (IR_PARA_TRIAGEM) {
        window.location.href = `${TELA_TRIAGEM}?estudante=${json.id}`;
      } else {
        limparFormulario();
      }
    } else if (json.erros) {
      mostrarErros(form, json.erros); // erros de validação vindos do PHP
    } else {
      mostrarAviso(json.erro || 'Erro ao salvar.', false);
    }
  } catch (err) {
    mostrarAviso('Falha de comunicação com o servidor.', false);
  } finally {
    btnSalvar.disabled = false;
  }
});

// ---------- 6) Cancelar / limpar ----------
function limparFormulario() {
  form.reset();
  campoIdade.value = '—';
  campoTurno.value = 'Automático';
  campoEtapa.value = 'Automático';
  limparErros(form);
}
document.getElementById('btn-cancelar').addEventListener('click', limparFormulario);

// ---------- Início ----------
carregarUsuario(); // menu lateral
carregarTurmas();
