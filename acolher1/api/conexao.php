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

// O XAMPP costuma vir com outro fuso horário: fixamos o do Brasil.
// Sem isso, "hoje" no PHP pode ser diferente de "hoje" no navegador.
date_default_timezone_set('America/Sao_Paulo');

// Erros do PHP NÃO podem aparecer na resposta (quebrariam o JSON).
// Eles ficam no log do Apache: xampp/apache/logs/error.log
ini_set('display_errors', '0');

// Toda resposta da API é JSON e não deve ficar guardada em cache (dados sensíveis)
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store');

// Envia a resposta em JSON e encerra o script
function responder($dados, $codigoHttp = 200)
{
    http_response_code($codigoHttp);
    echo json_encode($dados, JSON_UNESCAPED_UNICODE);
    exit;
}

// Qualquer erro inesperado vira uma resposta JSON em vez de uma página quebrada
set_exception_handler(function ($e) {
    error_log($e->getMessage());
    responder(['erro' => 'Erro interno do servidor.'], 500);
});

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

// Devolve o usuário logado (nome, perfil, registro de classe).
// Quando existir login, só muda a constante USUARIO_LOGADO_ID.
function usuarioLogado($pdo)
{
    $stmt = $pdo->prepare('SELECT id, nome, perfil, registro_classe FROM usuarios WHERE id = ? AND ativo = 1');
    $stmt->execute([USUARIO_LOGADO_ID]);
    $usuario = $stmt->fetch();
    if (!$usuario) {
        responder(['erro' => 'Usuário não encontrado.'], 401);
    }
    return $usuario;
}

// Confere se um texto é uma data AAAA-MM-DD válida
function dataValida($texto)
{
    $d = DateTime::createFromFormat('Y-m-d', $texto);
    return $d && $d->format('Y-m-d') === $texto;
}
