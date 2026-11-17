// =====================================================
// login.js — tela de login
// Fluxo: digita e-mail/senha -> POST api/login.php -> vai para a tela pedida (ou o Dashboard)
// (esta página não usa o comum.js, para não redirecionar para si mesma)
// =====================================================
const form = document.getElementById('form-login');
const campoEmail = document.getElementById('email');
const campoSenha = document.getElementById('senha');
const botao = document.getElementById('btn-entrar');
const msgErro = document.getElementById('login-erro');

// Para onde ir depois de entrar: só aceita nome de página nossa (ex.: prontuario.html?id=3).
// Qualquer outra coisa (https://site-falso.com, //site, javascript:) é ignorada: evita "open redirect".
function destinoSeguro() {
  const next = new URLSearchParams(location.search).get('next') || '';
  return /^[a-z-]+\.html(\?[A-Za-z0-9=&_-]*)?$/.test(next) ? next : 'index.html';
}

function mostrarErro(texto) {
  msgErro.textContent = texto;
  msgErro.hidden = false;
}

// Já está logado? Então pula o login.
fetch('api/usuario.php').then((r) => { if (r.ok) location.replace(destinoSeguro()); }).catch(() => {});

form.addEventListener('submit', async (ev) => {
  ev.preventDefault();
  msgErro.hidden = true;

  const email = campoEmail.value.trim();
  const senha = campoSenha.value;
  if (!email || !senha) {
    mostrarErro('Informe o e-mail e a senha.');
    (email ? campoSenha : campoEmail).focus();
    return;
  }

  botao.disabled = true;
  botao.textContent = 'Entrando...';
  try {
    const resp = await fetch('api/login.php', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, senha }),
    });
    const dados = await resp.json().catch(() => ({}));
    if (!resp.ok) {
      mostrarErro(dados.erro || 'Não foi possível entrar. Tente novamente.');
      campoSenha.value = '';
      campoSenha.focus();
      return;
    }
    location.replace(destinoSeguro());
  } catch (e) {
    mostrarErro('Sem conexão com o servidor. Tente novamente.');
  } finally {
    botao.disabled = false;
    botao.textContent = 'Entrar';
  }
});
