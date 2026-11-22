// =====================================================
// usuarios.js — gestão de usuários (tela só para ADMIN)
// Fluxo: carrega a lista -> cadastra novo usuário -> ativa/desativa -> redefine senha
// (funções como criar(), mostrarErros() e carregarUsuario() vêm do comum.js)
// =====================================================
const form = document.getElementById('form-usuario');
const corpo = document.getElementById('lista-usuarios');
const campoPerfil = document.getElementById('perfil');
const campoRegistro = document.getElementById('registro_classe');
const btnCriar = document.getElementById('btn-criar');
const campoBusca = document.getElementById('busca');
const filtroSituacao = document.getElementById('filtro-situacao');

const dialogo = document.getElementById('dlg-senha');
const formRedefinir = document.getElementById('form-redefinir');

let todos = [];         // lista completa vinda do banco
let eu = null;          // usuário logado (para não deixar desativar a si mesmo)
let idRedefinir = null; // usuário que está tendo a senha redefinida

// Chamada POST em JSON. Devolve { resp, json }.
async function enviar(dados) {
  const resp = await fetch(API + 'usuarios.php', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(dados),
  });
  const json = await resp.json().catch(() => ({}));
  return { resp, json };
}

// ---------- Início ----------
async function iniciar() {
  eu = await carregarUsuario();
  if (!eu) return;
  if (eu.perfil !== 'ADMIN') { // quem não é administrador não tem o que fazer aqui
    location.replace('index.html');
    return;
  }
  carregarLista();
}

// ---------- Lista ----------
async function carregarLista() {
  try {
    const resp = await fetch(API + 'usuarios.php');
    if (!resp.ok) throw new Error();
    todos = await resp.json();
    desenharResumo();
    aplicarFiltros();
  } catch (e) {
    const tr = criar('tr');
    const td = criar('td', 'vazio', 'Não foi possível carregar os usuários.');
    td.colSpan = 6;
    tr.appendChild(td);
    corpo.replaceChildren(tr);
  }
}

function celula(rotulo, conteudo) {
  const td = criar('td', '');
  td.dataset.label = rotulo;
  if (typeof conteudo === 'string') td.textContent = conteudo; else td.appendChild(conteudo);
  return td;
}

// Cards do topo: só contam usuários ATIVOS
function desenharResumo() {
  const ativos = todos.filter((u) => Number(u.ativo) === 1);
  const conta = (perfil) => ativos.filter((u) => u.perfil === perfil).length;
  document.getElementById('resumo-ativos').textContent = ativos.length;
  document.getElementById('resumo-psicologos').textContent = conta('PSICOLOGO');
  document.getElementById('resumo-assistentes').textContent = conta('ASSISTENTE_SOCIAL');
  document.getElementById('resumo-admins').textContent = conta('ADMIN');
  const desativados = todos.length - ativos.length;
  document.getElementById('resumo-desativados').textContent =
    desativados ? `${desativados} desativado${desativados > 1 ? 's' : ''}` : '';
}

// "2026-11-18 09:30:00" -> "18/11/2026 às 09:30" (ou "Nunca acessou")
function acessoBR(valor) {
  if (!valor) return 'Nunca acessou';
  return `${dataBR(valor)} às ${valor.slice(11, 16)}`;
}

// Tira acentos e maiúsculas: "joao" encontra "João"
function normalizar(texto) {
  return (texto || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase();
}

// Aplica busca + filtro de situação e redesenha a tabela
function aplicarFiltros() {
  const termo = normalizar(campoBusca.value.trim());
  const situacao = filtroSituacao.value;
  const lista = todos.filter((u) => {
    const ativo = Number(u.ativo) === 1;
    if (situacao === 'ativos' && !ativo) return false;
    if (situacao === 'desativados' && ativo) return false;
    return normalizar(`${u.nome} ${u.email}`).includes(termo);
  });
  desenharLista(lista);
}
campoBusca.addEventListener('input', aplicarFiltros);
filtroSituacao.addEventListener('change', aplicarFiltros);

function desenharLista(lista) {
  document.getElementById('usuarios-contagem').textContent =
    lista.length === todos.length ? `${todos.length} cadastrado(s)` : `${lista.length} de ${todos.length} cadastrado(s)`;

  corpo.replaceChildren();
  if (!lista.length) {
    const tr = criar('tr');
    const td = criar('td', 'vazio', todos.length ? 'Nenhum usuário encontrado.' : 'Nenhum usuário cadastrado.');
    td.colSpan = 6;
    tr.appendChild(td);
    corpo.appendChild(tr);
    return;
  }
  lista.forEach((u) => {
    const ativo = Number(u.ativo) === 1;
    const tr = criar('tr', ativo ? '' : 'linha-inativa');

    // Nome + e-mail
    const tdNome = criar('td', 'nome-aluno');
    tdNome.append(criar('strong', 'usuario-nome-lista', u.nome), criar('span', 'usuario-email', u.email));

    const selo = criar('span', ativo ? 'selo' : 'selo selo-alerta', ativo ? 'Ativo' : 'Desativado');

    // Ações: redefinir senha e ativar/desativar
    const acoes = criar('div', 'acoes-linha');
    const btnEditar = criar('button', 'btn btn-claro', 'Editar');
    btnEditar.type = 'button';
    btnEditar.addEventListener('click', () => abrirEditar(u));
    acoes.appendChild(btnEditar);
    const btnSenha = criar('button', 'btn btn-claro', 'Redefinir senha');
    btnSenha.type = 'button';
    btnSenha.addEventListener('click', () => abrirRedefinir(u));
    acoes.appendChild(btnSenha);

    if (Number(u.id) !== Number(eu.id)) { // não se desativa o próprio usuário
      const btnSit = criar('button', 'btn btn-claro', ativo ? 'Desativar' : 'Reativar');
      btnSit.type = 'button';
      btnSit.addEventListener('click', () => mudarSituacao(u, !ativo));
      acoes.appendChild(btnSit);
    } else {
      acoes.appendChild(criar('span', 'dica', 'Este é você'));
    }

    tr.append(tdNome, celula('Perfil', CARGOS[u.perfil]), celula('Registro', u.registro_classe || '—'),
      celula('Situação', selo), celula('Último acesso', acessoBR(u.ultimo_acesso)), celula('Ações', acoes));
    corpo.appendChild(tr);
  });
}

// ---------- Ativar / desativar ----------
async function mudarSituacao(u, ativar) {
  if (!ativar && !confirm(`Desativar ${u.nome}? A pessoa perde o acesso imediatamente (o histórico dela é mantido).`)) return;
  const { resp, json } = await enviar({ acao: 'situacao', id: u.id, ativo: ativar });
  if (!resp.ok) { mostrarAviso(json.erro || 'Não foi possível alterar.', false); return; }
  mostrarAviso(ativar ? 'Usuário reativado.' : 'Usuário desativado.');
  carregarLista();
}

// ---------- Novo usuário ----------
// Administrador não tem registro de classe: o campo só liga para profissionais
function ajustarRegistro(selectPerfil, campo) {
  const profissional = selectPerfil.value === 'PSICOLOGO' || selectPerfil.value === 'ASSISTENTE_SOCIAL';
  campo.disabled = !profissional;
  campo.required = profissional;
  if (!profissional) campo.value = '';
  campo.placeholder = selectPerfil.value === 'ASSISTENTE_SOCIAL' ? 'Ex.: CRESS 12345' : 'Ex.: CRP 06/12345';
}
campoPerfil.addEventListener('change', () => ajustarRegistro(campoPerfil, campoRegistro));

ligarLimpezaDeErros(form);

form.addEventListener('submit', async (ev) => {
  ev.preventDefault();
  limparErros(form);

  const erros = checarObrigatorios(form);
  const dados = Object.fromEntries(new FormData(form));
  if (!erros.senha && dados.senha.length < 8) erros.senha = 'A senha precisa ter pelo menos 8 caracteres.';
  if (!erros.confirmacao && dados.senha !== dados.confirmacao) erros.confirmacao = 'As senhas não conferem.';
  if (Object.keys(erros).length) { mostrarErros(form, erros); return; }

  btnCriar.disabled = true;
  try {
    const { resp, json } = await enviar({ acao: 'criar', ...dados });
    if (resp.ok) {
      mostrarAviso('Usuário cadastrado com sucesso.');
      form.reset();
      campoPerfil.dispatchEvent(new Event('change'));
      carregarLista();
    } else if (json.erros) {
      mostrarErros(form, json.erros);
    } else {
      mostrarAviso(json.erro || 'Não foi possível cadastrar.', false);
    }
  } catch (e) {
    mostrarAviso('Sem conexão com o servidor.', false);
  } finally {
    btnCriar.disabled = false;
  }
});

// ---------- Editar usuário (janela) ----------
const dlgEditar = document.getElementById('dlg-editar');
const formEditar = document.getElementById('form-editar');
const edPerfil = document.getElementById('ed_perfil');
const edRegistro = document.getElementById('ed_registro');
let editando = null; // usuário que está sendo editado

function abrirEditar(u) {
  editando = u;
  limparErros(formEditar);
  document.getElementById('ed_nome').value = u.nome;
  document.getElementById('ed_email').value = u.email;
  edPerfil.value = u.perfil;
  edRegistro.value = u.registro_classe || '';
  ajustarRegistro(edPerfil, edRegistro);
  edRegistro.value = u.registro_classe || ''; // ajustarRegistro limpa o campo de administrador

  // O próprio perfil não pode ser alterado (evita o administrador se trancar para fora)
  const proprio = Number(u.id) === Number(eu.id);
  edPerfil.disabled = proprio;
  document.getElementById('ed-dica-perfil').textContent = proprio ? 'Você não pode alterar o seu próprio perfil.' : '';
  dlgEditar.showModal();
  document.getElementById('ed_nome').focus();
}
edPerfil.addEventListener('change', () => ajustarRegistro(edPerfil, edRegistro));
document.getElementById('ed-cancelar').addEventListener('click', () => dlgEditar.close());
ligarLimpezaDeErros(formEditar);

formEditar.addEventListener('submit', async (ev) => {
  ev.preventDefault();
  limparErros(formEditar);

  const dados = {
    acao: 'editar',
    id: editando.id,
    nome: document.getElementById('ed_nome').value.trim(),
    email: document.getElementById('ed_email').value.trim(),
    perfil: edPerfil.value, // o select desligado não entra no FormData, por isso lemos direto
    registro_classe: edRegistro.value.trim(),
  };
  const erros = checarObrigatorios(formEditar);
  if (Object.keys(erros).length) { mostrarErros(formEditar, erros); return; }

  // Mudar o perfil muda o que a pessoa pode acessar (vale na hora): pede confirmação
  if (dados.perfil !== editando.perfil &&
      !confirm(`Mudar o perfil de ${editando.nome}? As permissões mudam imediatamente.`)) return;

  const botao = document.getElementById('ed-salvar');
  botao.disabled = true;
  try {
    const { resp, json } = await enviar(dados);
    if (resp.ok) {
      dlgEditar.close();
      mostrarAviso('Dados do usuário atualizados.');
      carregarLista();
    } else if (json.erros) {
      mostrarErros(formEditar, json.erros);
    } else {
      mostrarAviso(json.erro || 'Não foi possível salvar.', false);
    }
  } catch (e) {
    mostrarAviso('Sem conexão com o servidor.', false);
  } finally {
    botao.disabled = false;
  }
});

// ---------- Redefinir senha (janela) ----------
function abrirRedefinir(u) {
  idRedefinir = u.id;
  limparErros(formRedefinir);
  formRedefinir.reset();
  document.getElementById('dlg-nome').textContent = `Usuário: ${u.nome}`;
  dialogo.showModal();
  document.getElementById('nova_senha').focus();
}
document.getElementById('dlg-cancelar').addEventListener('click', () => dialogo.close());
ligarLimpezaDeErros(formRedefinir);

formRedefinir.addEventListener('submit', async (ev) => {
  ev.preventDefault();
  limparErros(formRedefinir);
  const dados = Object.fromEntries(new FormData(formRedefinir));
  const erros = checarObrigatorios(formRedefinir);
  if (!erros.senha && dados.senha.length < 8) erros.senha = 'A senha precisa ter pelo menos 8 caracteres.';
  if (!erros.confirmacao && dados.senha !== dados.confirmacao) erros.confirmacao = 'As senhas não conferem.';
  if (Object.keys(erros).length) { mostrarErros(formRedefinir, erros); return; }

  const { resp, json } = await enviar({ acao: 'senha', id: idRedefinir, ...dados });
  if (resp.ok) {
    dialogo.close();
    mostrarAviso('Senha redefinida.');
  } else if (json.erros) {
    mostrarErros(formRedefinir, json.erros);
  } else {
    mostrarAviso(json.erro || 'Não foi possível redefinir.', false);
  }
});

iniciar();
