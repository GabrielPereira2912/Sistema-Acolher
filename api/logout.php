<?php
// =====================================================
// POST api/logout.php — encerra a sessão (botão "Sair")
// =====================================================
require __DIR__ . '/conexao.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    responder(['erro' => 'Método não permitido.'], 405);
}

encerrarSessao();
responder(['ok' => true]);
