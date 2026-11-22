<?php
// =====================================================
// POST api/minha_senha.php — o próprio usuário troca a sua senha
// Corpo: { senha_atual, nova_senha, confirmacao }
// =====================================================
require __DIR__ . '/conexao.php';

$usuario = usuarioLogado($pdo); // exige login

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    responder(['erro' => 'Método não permitido.'], 405);
}

$d = json_decode(file_get_contents('php://input'), true);
if (!is_array($d)) {
    responder(['erro' => 'Dados inválidos.'], 400);
}

$atual    = (string) ($d['senha_atual'] ?? '');
$nova     = (string) ($d['nova_senha'] ?? '');
$confirma = (string) ($d['confirmacao'] ?? '');

$erros = [];
if ($atual === '') $erros['senha_atual'] = 'Informe a senha atual.';
if (strlen($nova) < 8) $erros['nova_senha'] = 'A nova senha precisa ter pelo menos 8 caracteres.';
elseif (strlen($nova) > 72) $erros['nova_senha'] = 'A senha pode ter no máximo 72 caracteres.';
elseif ($nova === $atual) $erros['nova_senha'] = 'A nova senha deve ser diferente da atual.';
if ($nova !== $confirma) $erros['confirmacao'] = 'As senhas não conferem.';
if ($erros) responder(['erros' => $erros], 422);

// Confere a senha atual (impede que alguém use um computador deixado aberto para trocar a senha)
$stmt = $pdo->prepare('SELECT senha_hash FROM usuarios WHERE id = ?');
$stmt->execute([$usuario['id']]);
if (!password_verify($atual, $stmt->fetchColumn())) {
    usleep(400000);
    responder(['erros' => ['senha_atual' => 'Senha atual incorreta.']], 422);
}

$pdo->prepare('UPDATE usuarios SET senha_hash = ? WHERE id = ?')
    ->execute([password_hash($nova, PASSWORD_DEFAULT), $usuario['id']]);

session_regenerate_id(true); // novo ID de sessão depois de mudar credencial
responder(['ok' => true]);
