<?php
// =====================================================
// conexao.php — conexão com o MySQL + funções de apoio
// Todos os arquivos da pasta api/ fazem: require 'conexao.php';
// =====================================================

// Dados padrão do XAMPP (usuário root, sem senha). Ajuste se o seu for diferente.
$host    = 'localhost';
$banco   = 'acolher';
$usuario = 'root';
$senha   = '';

// TEMPORÁRIO: enquanto não existe a tela de login, todo registro é feito
// como o usuário 1 (Marina Lopes, dos dados de teste).
// Quando o login existir, trocar por $_SESSION['usuario_id'].
define('USUARIO_LOGADO_ID', 1);

// Toda resposta da API é JSON
header('Content-Type: application/json; charset=utf-8');

// Envia a resposta em JSON e encerra o script
function responder($dados, $codigoHttp = 200)
{
    http_response_code($codigoHttp);
    echo json_encode($dados, JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    $pdo = new PDO(
        "mysql:host=$host;dbname=$banco;charset=utf8mb4",
        $usuario,
        $senha,
        [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,   // erros viram exceções
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,         // resultados como array associativo
            PDO::ATTR_EMULATE_PREPARES   => false,                    // prepared statements de verdade
        ]
    );
} catch (PDOException $e) {
    error_log($e->getMessage()); // o detalhe vai para o log, não para o usuário
    responder(['erro' => 'Não foi possível conectar ao banco de dados.'], 500);
}
