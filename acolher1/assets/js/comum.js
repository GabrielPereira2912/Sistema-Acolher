// =====================================================
// comum.js — funções usadas por TODAS as telas
// Carregue este arquivo antes do script da própria tela.
// =====================================================

const API = 'api/'; // pasta dos arquivos PHP

// ---------- Tradução dos valores do banco (ENUM) para texto bonito ----------
const TURNOS = { MANHA: 'Manhã', TARDE: 'Tarde', NOITE: 'Noite' };
const ETAPAS = {
  FUNDAMENTAL_I: 'Ensino Fundamental I',
  FUNDAMENTAL_II: 'Ensino Fundamental II',
  ENSINO_MEDIO: 'Ensino Médio',
};
const MODALIDADES = {
  INDIVIDUAL: 'Individual', GRUPO: 'Grupo', FAMILIA: 'Família',
  PROFESSORES: 'Professores', TELEFONE: 'Telefone',
};
const CARGOS = {
  PSICOLOGO: 'Psicólogo(a)', ASSISTENTE_SOCIAL: 'Assistente social', ADMIN: 'Administrador(a)',
};
const STATUS_ESTUDANTE = {
  TRIAGEM: 'Triagem', EM_ACOMPANHAMENTO: 'Em acompanhamento', ENCERRADO: 'Encerrado',
};

// ---------- Datas ----------
// O banco entrega AAAA-MM-DD; a tela mostra DD/MM/AAAA.
// (Separamos o texto na mão para o fuso horário não "mudar o dia".)
function dataBR(iso) {
  if (!iso) return '—';
  const [a, m, d] = iso.slice(0, 10).split('-');
  return `${d}/${m}/${a}`;
}

// Data de hoje no formato AAAA-MM-DD (horário local)
function hojeISO() {
  const h = new Date();
  return `${h.getFullYear()}-${String(h.getMonth() + 1).padStart(2, '0')}-${String(h.getDate()).padStart(2, '0')}`;
}

// Idade em anos a partir de AAAA-MM-DD (nunca salva no banco)
function calcularIdade(iso) {
  const [ano, mes, dia] = iso.split('-').map(Number);
  const hoje = new Date();
  let idade = hoje.getFullYear() - ano;
  // ainda não fez aniversário este ano? tira 1
  if (hoje.getMonth() + 1 < mes || (hoje.getMonth() + 1 === mes && hoje.getDate() < dia)) idade--;
  return idade;
}

// "Ana Beatriz Souza" -> "AS"
function iniciais(nome) {
  const p = nome.trim().split(/\s+/);
  return (p[0][0] + (p.length > 1 ? p[p.length - 1][0] : '')).toUpperCase();
}

// ---------- Criar elementos sem risco de XSS ----------
// Usa textContent (nunca innerHTML) para texto vindo do banco.
function criar(tag, classe, texto) {
  const el = document.createElement(tag);
  if (classe) el.className = classe;
  if (texto !== undefined) el.textContent = texto;
  return el;
}

// ---------- Aviso rápido (sucesso/erro) no canto da tela ----------
let temporizadorAviso;
function mostrarAviso(texto, sucesso = true) {
  const aviso = document.getElementById('aviso');
  aviso.textContent = texto;
  aviso.className = `aviso visivel ${sucesso ? 'ok' : 'falha'}`;
  clearTimeout(temporizadorAviso);
  temporizadorAviso = setTimeout(() => aviso.classList.remove('visivel'), 4000);
}

// ---------- Erros embaixo dos campos de um formulário ----------
function limparErros(form) {
  form.querySelectorAll('[data-erro]').forEach((el) => (el.textContent = ''));
  form.querySelectorAll('.com-erro').forEach((el) => el.classList.remove('com-erro'));
}

// Recebe { campo: 'mensagem' } e escreve embaixo de cada campo
function mostrarErros(form, erros) {
  Object.entries(erros).forEach(([campo, mensagem]) => {
    const alvo = form.querySelector(`[data-erro="${campo}"]`);
    if (alvo) {
      alvo.textContent = mensagem;
      alvo.closest('.campo').classList.add('com-erro');
    }
  });
  // leva o foco ao primeiro campo com problema
  const primeiro = form.querySelector('.com-erro input, .com-erro select, .com-erro textarea');
  if (primeiro) primeiro.focus();
}

// Quando o usuário mexe em um campo, o erro daquele campo some
function ligarLimpezaDeErros(form) {
  const limpar = (e) => {
    const campo = e.target.closest('.campo');
    if (!campo) return;
    campo.classList.remove('com-erro');
    const msg = campo.querySelector('[data-erro]');
    if (msg) msg.textContent = '';
  };
  form.addEventListener('input', limpar);
  form.addEventListener('change', limpar);
}

// Marca como "Campo obrigatório." todo [required] vazio. Devolve os erros achados.
function checarObrigatorios(form) {
  const erros = {};
  form.querySelectorAll('[required]').forEach((campo) => {
    if (!campo.value.trim()) erros[campo.name] = 'Campo obrigatório.';
  });
  return erros;
}

// ---------- Usuário logado (menu lateral) ----------
// Preenche nome/cargo no rodapé do menu e devolve o usuário.
async function carregarUsuario() {
  try {
    const resp = await fetch(API + 'usuario.php');
    if (!resp.ok) throw new Error();
    const u = await resp.json();
    document.getElementById('usuario-avatar').textContent = iniciais(u.nome);
    document.getElementById('usuario-nome').textContent = u.nome;
    const cargo = CARGOS[u.perfil] + (u.registro_classe ? ` · ${u.registro_classe}` : '');
    const campoCargo = document.getElementById('usuario-cargo');
    campoCargo.textContent = cargo;
    campoCargo.title = cargo; // mostra completo ao passar o mouse (o texto pode ser cortado com ...)
    return u;
  } catch (e) {
    mostrarAviso('Não foi possível identificar o usuário.', false);
    return null;
  }
}
