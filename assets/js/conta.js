// =====================================================
// conta.js — "Minha conta": dados do usuário e troca de senha
// (funções como mostrarErros() e carregarUsuario() vêm do comum.js)
// =====================================================
const form = document.getElementById('form-senha');
const botao = document.getElementById('btn-trocar');

async function iniciar() {
  const u = await carregarUsuario(); // também preenche o menu
  if (!u) return;
  document.getElementById('conta-nome').textContent = u.nome;
  document.getElementById('conta-perfil').textContent = CARGOS[u.perfil];
  document.getElementById('conta-registro').textContent = u.registro_classe || '—';
}

ligarLimpezaDeErros(form);

form.addEventListener('submit', async (ev) => {
  ev.preventDefault();
  limparErros(form);

  const dados = Object.fromEntries(new FormData(form));
  const erros = checarObrigatorios(form);
  if (!erros.nova_senha && dados.nova_senha.length < 8) erros.nova_senha = 'A nova senha precisa ter pelo menos 8 caracteres.';
  if (!erros.nova_senha && dados.nova_senha === dados.senha_atual) erros.nova_senha = 'A nova senha deve ser diferente da atual.';
  if (!erros.confirmacao && dados.nova_senha !== dados.confirmacao) erros.confirmacao = 'As senhas não conferem.';
  if (Object.keys(erros).length) { mostrarErros(form, erros); return; }

  botao.disabled = true;
  try {
    const resp = await fetch(API + 'minha_senha.php', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(dados),
    });
    const json = await resp.json().catch(() => ({}));
    if (resp.ok) {
      mostrarAviso('Senha alterada com sucesso.');
      form.reset();
    } else if (json.erros) {
      mostrarErros(form, json.erros);
    } else {
      mostrarAviso(json.erro || 'Não foi possível alterar a senha.', false);
    }
  } catch (e) {
    mostrarAviso('Sem conexão com o servidor.', false);
  } finally {
    botao.disabled = false;
  }
});

iniciar();
