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

// Tempo máximo sem usar o sistema: depois disso é preciso entrar de novo
// (importante em computador compartilhado da escola).
define('TEMPO_SESSAO', 1800); // 30 minutos, em segundos

// O XAMPP costuma vir com outro fuso horário: fixamos o do Brasil.
// Sem isso, "hoje" no PHP pode ser diferente de "hoje" no navegador.
date_default_timezone_set('America/Sao_Paulo');

// Erros do PHP NÃO podem aparecer na resposta (quebrariam o JSON).
// Eles ficam no log do Apache: xampp/apache/logs/error.log
ini_set('display_errors', '0');

// Sessão: guarda quem está logado no servidor. O cookie fica protegido:
//  - httponly: o JavaScript da página não consegue ler;
//  - samesite Lax: não é enviado em requisições vindas de outros sites.
if (PHP_SAPI !== 'cli') { // no terminal (scripts/criar_usuario.php) não há sessão
    session_name('ACOLHERSESS');
    session_set_cookie_params([
        'lifetime' => 0,                                  // some ao fechar o navegador
        'path'     => '/',
        'httponly' => true,
        'samesite' => 'Lax',
        'secure'   => !empty($_SERVER['HTTPS']),          // exige HTTPS quando o site usa HTTPS
    ]);
    session_start();
}

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
// TODA rota da API (menos login e logout) começa chamando esta função:
// sem login válido, ela responde 401 e o resto do arquivo nem executa.
function usuarioLogado($pdo)
{
    $id = $_SESSION['usuario_id'] ?? null;
    if (!$id) {
        responder(['erro' => 'Faça login para continuar.'], 401);
    }

    // Ficou parado tempo demais? Derruba a sessão.
    if (time() - ($_SESSION['ultimo_acesso'] ?? 0) > TEMPO_SESSAO) {
        encerrarSessao();
        responder(['erro' => 'Sua sessão expirou. Entre novamente.'], 401);
    }

    // Confere no banco a cada requisição: se o usuário foi desativado, perde o acesso na hora.
    $stmt = $pdo->prepare('SELECT id, nome, perfil, registro_classe FROM usuarios WHERE id = ? AND ativo = 1');
    $stmt->execute([$id]);
    $usuario = $stmt->fetch();
    if (!$usuario) {
        encerrarSessao();
        responder(['erro' => 'Faça login para continuar.'], 401);
    }

    $_SESSION['ultimo_acesso'] = time(); // usou agora: renova o relógio dos 30 minutos
    return $usuario;
}

// Apaga a sessão no servidor e o cookie no navegador (usada no logout e na expiração)
function encerrarSessao()
{
    $_SESSION = [];
    setcookie(session_name(), '', [
        'expires' => time() - 3600, 'path' => '/', 'httponly' => true, 'samesite' => 'Lax',
    ]);
    session_destroy();
}

// Confere se um texto é uma data AAAA-MM-DD válida
function dataValida($texto)
{
    $d = DateTime::createFromFormat('Y-m-d', $texto);
    return $d && $d->format('Y-m-d') === $texto;
}
