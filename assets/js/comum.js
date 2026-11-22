// =====================================================
// comum.js — funções usadas por TODAS as telas
// Carregue este arquivo antes do script da própria tela.
// =====================================================

const API = 'api/'; // pasta dos arquivos PHP

// Envolve o fetch: se QUALQUER chamada da API responder 401 (sem login ou sessão expirada),
// manda para a tela de login e, depois de entrar, volta para a página em que estava.
const fetchOriginal = window.fetch.bind(window);
window.fetch = async (...args) => {
  const resp = await fetchOriginal(...args);
  if (resp.status === 401) {
    const atual = location.pathname.split('/').pop() + location.search;
    location.replace('login.html?next=' + encodeURIComponent(atual));
    return new Promise(() => {}); // não segue o código da página: ela já está saindo
  }
  return resp;
};

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
    ligarBotaoSair();
    ajustarMenu(u.perfil);
    return u;
  } catch (e) {
    mostrarAviso('Não foi possível identificar o usuário.', false);
    document.querySelector('.menu')?.classList.add('pronto');
    return null;
  }
}

// ---------- Botão Sair (menu lateral) ----------
function ligarBotaoSair() {
  const sair = document.querySelector('.sair');
  if (!sair) return;
  sair.addEventListener('click', async (ev) => {
    ev.preventDefault();
    try { await fetchOriginal(API + 'logout.php', { method: 'POST' }); } catch (e) { /* sai mesmo assim */ }
    location.replace('login.html');
  });
}

// ---------- Menu por perfil ----------
// ADMIN: Dashboard, Cadastro do Estudante, Estudantes, Usuários e Minha conta (não vê triagem nem prontuários).
// Profissionais: tudo, menos Estudantes e Usuários.
// O menu fica invisível (CSS) até este ajuste, para não "piscar" itens que o perfil não pode usar.
function ajustarMenu(perfil) {
  const ehAdmin = perfil === 'ADMIN';
  document.getElementById('menu-usuarios')?.toggleAttribute('hidden', !ehAdmin);
  document.getElementById('menu-estudantes')?.toggleAttribute('hidden', !ehAdmin);
  document.querySelectorAll('a[href="triagem-demandas.html"], a[href="prontuario.html"]')
    .forEach((a) => a.toggleAttribute('hidden', ehAdmin));
  document.querySelector('.menu')?.classList.add('pronto');
}

// Páginas só da equipe técnica chamam isto: o administrador volta para o Dashboard.
function bloquearAdmin(usuario) {
  if (usuario && usuario.perfil === 'ADMIN') {
    location.replace('index.html');
    return true;
  }
  return false;
}

// ---------- Máscaras de digitação (usadas no cadastro e na edição de estudante) ----------
// Matrícula: 0000-00000
function ligarMascaraMatricula(campo) {
  campo.addEventListener('input', () => {
    const n = campo.value.replace(/\D/g, '').slice(0, 9);
    campo.value = n.length > 4 ? `${n.slice(0, 4)}-${n.slice(4)}` : n;
  });
}

// Telefone: (00) 00000-0000 (aceita fixo de 10 dígitos também)
function formatarTelefone(texto) {
  const n = (texto || '').replace(/\D/g, '').slice(0, 11);
  if (n.length > 10) return `(${n.slice(0, 2)}) ${n.slice(2, 7)}-${n.slice(7)}`;
  if (n.length > 6) return `(${n.slice(0, 2)}) ${n.slice(2, 6)}-${n.slice(6)}`;
  if (n.length > 2) return `(${n.slice(0, 2)}) ${n.slice(2)}`;
  return n;
}
function ligarMascaraTelefone(campo) {
  campo.addEventListener('input', () => { campo.value = formatarTelefone(campo.value); });
}
