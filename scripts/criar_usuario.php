<?php
// =====================================================
// scripts/criar_usuario.php — cria um usuário (use para o primeiro ADMIN)
// Rode pelo TERMINAL, na pasta do projeto:
//     C:\\xampp\\php\\php.exe scripts\\criar_usuario.php      (Windows/XAMPP)
//     php scripts/criar_usuario.php                            (Linux/Mac)
// A senha é digitada aqui e guardada só como hash (password_hash): nunca fica em texto no SQL.
// =====================================================
if (PHP_SAPI !== 'cli') {
    http_response_code(403);
    exit('Este script só roda pelo terminal.');
}
require __DIR__ . '/../api/conexao.php';

// Faz uma pergunta e devolve o que foi digitado
function perguntar($texto)
{
    echo $texto . ' ';
    return trim((string) fgets(STDIN));
}

echo "=== Novo usuário do sistema Acolher ===\n";

$nome = perguntar('Nome completo:');
$email = mb_strtolower(perguntar('E-mail (será o login):'));
$perfil = strtoupper(perguntar('Perfil (ADMIN, PSICOLOGO ou ASSISTENTE_SOCIAL):'));
$registro = '';
if ($perfil !== 'ADMIN') {
    $registro = perguntar('Registro de classe (CRP/CRESS):');
}

// Validações
if (mb_strlen($nome) < 3) exit("Nome inválido.\n");
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) exit("E-mail inválido.\n");
if (!in_array($perfil, ['ADMIN', 'PSICOLOGO', 'ASSISTENTE_SOCIAL'], true)) exit("Perfil inválido.\n");
if ($perfil !== 'ADMIN' && $registro === '') exit("O registro de classe é obrigatório para profissionais.\n");

$stmt = $pdo->prepare('SELECT id FROM usuarios WHERE email = ?');
$stmt->execute([$email]);
if ($stmt->fetch()) exit("Já existe um usuário com este e-mail.\n");

// Senha (aparece na tela enquanto digita no Windows; no Linux/Mac fica escondida)
$esconder = DIRECTORY_SEPARATOR === '/' && function_exists('posix_isatty') && posix_isatty(STDIN);
if ($esconder) shell_exec('stty -echo');
$senha = perguntar('Senha (mínimo 8 caracteres):');
if ($esconder) echo "\n";
$confirma = perguntar('Repita a senha:');
if ($esconder) { shell_exec('stty echo'); echo "\n"; }

if (mb_strlen($senha) < 8) exit("A senha precisa ter pelo menos 8 caracteres.\n");
if ($senha !== $confirma) exit("As senhas não conferem.\n");

$pdo->prepare('INSERT INTO usuarios (nome, email, senha_hash, perfil, registro_classe) VALUES (?, ?, ?, ?, ?)')
    ->execute([$nome, $email, password_hash($senha, PASSWORD_DEFAULT), $perfil, $registro !== '' ? $registro : null]);

echo "Usuário criado com sucesso: $email ($perfil)\n";
