<?php
// =====================================================
// POST api/login.php — confere e-mail e senha e abre a sessão
// =====================================================
require __DIR__ . '/conexao.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    responder(['erro' => 'Método não permitido.'], 405);
}

$d = json_decode(file_get_contents('php://input'), true);
if (!is_array($d)) {
    responder(['erro' => 'Dados inválidos.'], 400);
}

$email = mb_strtolower(trim($d['email'] ?? ''));
$senha = (string) ($d['senha'] ?? '');

if ($email === '' || $senha === '') {
    responder(['erro' => 'Informe o e-mail e a senha.'], 422);
}

$stmt = $pdo->prepare('SELECT id, nome, senha_hash, ativo FROM usuarios WHERE email = ?');
$stmt->execute([$email]);
$usuario = $stmt->fetch();

// Se o e-mail não existe, conferimos a senha contra um hash falso: assim a resposta demora
// o mesmo tempo e ninguém descobre quais e-mails estão cadastrados.
$hashFalso = '$2y$10$xiTwIoIWMCre2.FD2mwomOSRFrh.3.uGyrqjW/C0uc8StgmFQEt56';
$senhaOk = password_verify($senha, $usuario ? $usuario['senha_hash'] : $hashFalso);

// Mesma mensagem para e-mail inexistente, senha errada e usuário desativado
if (!$usuario || !$senhaOk || (int) $usuario['ativo'] !== 1) {
    usleep(400000); // 0,4 s de espera: atrapalha quem tenta adivinhar senhas em sequência
    responder(['erro' => 'E-mail ou senha incorretos.'], 401);
}

// Se o PHP passar a usar um algoritmo de hash mais novo, atualiza o hash guardado
if (password_needs_rehash($usuario['senha_hash'], PASSWORD_DEFAULT)) {
    $pdo->prepare('UPDATE usuarios SET senha_hash = ? WHERE id = ?')
        ->execute([password_hash($senha, PASSWORD_DEFAULT), $usuario['id']]);
}

// Novo ID de sessão a cada login (evita "fixação de sessão")
session_regenerate_id(true);
$_SESSION['usuario_id'] = (int) $usuario['id'];
$_SESSION['ultimo_acesso'] = time();

// Auditoria: registra o login
$pdo->prepare("INSERT INTO log_acessos (usuario_id, acao) VALUES (?, 'LOGIN')")->execute([$usuario['id']]);

responder(['ok' => true, 'nome' => $usuario['nome']]);
