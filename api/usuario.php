<?php
// =====================================================
// GET api/usuario.php — quem está logado (para o menu lateral e o formulário)
// =====================================================
require __DIR__ . '/conexao.php';

responder(usuarioLogado($pdo));
