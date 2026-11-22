<?php
// =====================================================
// scripts/redefinir_senha.php — recuperação de senha (ninguém sabe a senha do ADMIN)
// Rode pelo TERMINAL, no computador onde o sistema está instalado, na pasta do projeto:
//     C:\xampp\php\php.exe scripts\redefinir_senha.php      (Windows/XAMPP)
//     php scripts/redefinir_senha.php                       (Linux/Mac)
// A "chave" da recuperação é ter acesso ao servidor: quem não tem não consegue usar.
// A nova senha vira hash (password_hash); nunca fica em texto no banco.
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

echo "=== Recuperar senha — sistema Acolher ===\n";

$email = mb_strtolower(perguntar('E-mail do usuário:'));
$stmt = $pdo->prepare('SELECT id, nome, perfil, ativo FROM usuarios WHERE email = ?');
$stmt->execute([$email]);
$u = $stmt->fetch();
if (!$u) exit("Nenhum usuário com este e-mail.\n");

echo "Usuário: {$u['nome']} ({$u['perfil']})" . ((int) $u['ativo'] === 1 ? '' : ' — DESATIVADO') . "\n";

// Se estiver desativado, pergunta se quer reativar (senão a nova senha não adiantaria)
$reativar = false;
if ((int) $u['ativo'] !== 1) {
    $reativar = strtolower(perguntar('Este usuário está desativado. Reativar também? (s/n):')) === 's';
}

// Senha (escondida no Linux/Mac; no Windows aparece enquanto digita)
$esconder = DIRECTORY_SEPARATOR === '/' && function_exists('posix_isatty') && posix_isatty(STDIN);
if ($esconder) shell_exec('stty -echo');
$senha = perguntar('Nova senha (8 a 72 caracteres):');
if ($esconder) echo "\n";
$confirma = perguntar('Repita a nova senha:');
if ($esconder) { shell_exec('stty echo'); echo "\n"; }

if (strlen($senha) < 8) exit("A senha precisa ter pelo menos 8 caracteres.\n");
if (strlen($senha) > 72) exit("A senha pode ter no máximo 72 caracteres.\n");
if ($senha !== $confirma) exit("As senhas não conferem.\n");

$pdo->prepare('UPDATE usuarios SET senha_hash = ?, ativo = ? WHERE id = ?')
    ->execute([password_hash($senha, PASSWORD_DEFAULT), $reativar ? 1 : $u['ativo'], $u['id']]);

echo "Senha redefinida com sucesso para {$email}" . ($reativar ? ' (usuário reativado)' : '') . ".\n";
echo "Sessões já abertas dessa pessoa expiram sozinhas em até 30 minutos parada.\n";
