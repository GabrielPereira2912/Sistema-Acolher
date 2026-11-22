// Modo escuro: roda no <head>, antes da página aparecer, para não piscar o tema errado.
// Escolha salva no navegador (localStorage); sem escolha, segue o tema do sistema.
(function () {
  var CHAVE = 'acolher-tema';
  var raiz = document.documentElement;
  var sistema = window.matchMedia ? window.matchMedia('(prefers-color-scheme: dark)') : null;

  function salvo() {
    try { var v = localStorage.getItem(CHAVE); return v === 'claro' || v === 'escuro' ? v : null; }
    catch (e) { return null; } // localStorage pode estar bloqueado
  }
  function aplicar(tema) { raiz.setAttribute('data-tema', tema); }
  function atual() { return salvo() || (sistema && sistema.matches ? 'escuro' : 'claro'); }

  aplicar(atual());

  // Sem escolha salva, acompanha mudanças do sistema
  if (sistema && sistema.addEventListener) {
    sistema.addEventListener('change', function () { if (!salvo()) aplicar(atual()); });
  }

  // Ícones (lua = ir para escuro, sol = ir para claro); o CSS mostra um deles
  var ICONES =
    '<svg class="icone i-lua" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8z"/></svg>' +
    '<svg class="icone i-sol" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/></svg>';

  function rotulo(btn) {
    var escuro = raiz.getAttribute('data-tema') === 'escuro';
    var t = escuro ? 'Mudar para o modo claro' : 'Mudar para o modo escuro';
    btn.title = t; btn.setAttribute('aria-label', t);
  }

  function criarBotao() {
    var btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'tema-btn';
    btn.innerHTML = ICONES;
    rotulo(btn);
    btn.addEventListener('click', function () {
      var novo = raiz.getAttribute('data-tema') === 'escuro' ? 'claro' : 'escuro';
      try { localStorage.setItem(CHAVE, novo); } catch (e) {}
      aplicar(novo);
      rotulo(btn);
    });
    return btn;
  }

  document.addEventListener('DOMContentLoaded', function () {
    var btn = criarBotao();
    var usuario = document.querySelector('.usuario');
    var sair = usuario && usuario.querySelector('.sair');
    if (sair) usuario.insertBefore(btn, sair);        // páginas internas
    else { btn.classList.add('tema-flutuante'); document.body.appendChild(btn); } // login
  });
})();
