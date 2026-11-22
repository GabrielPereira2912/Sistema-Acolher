<?php
// =====================================================
// api/usuarios.php — gestão de usuários (SOMENTE ADMIN)
//   GET  -> lista todos os usuários
//   POST -> { acao: 'criar' | 'situacao' | 'senha', ... }
// Nunca devolve senha_hash. Usuário nunca é apagado: só desativado.
// =====================================================
require __DIR__ . '/conexao.php';

$usuario = usuarioLogado($pdo);
if ($usuario['perfil'] !== 'ADMIN') {
    responder(['erro' => 'Apenas administradores podem gerenciar usuários.'], 403);
}

// ---------- GET: lista ----------
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    responder($pdo->query(
        "SELECT u.id, u.nome, u.email, u.perfil, u.registro_classe, u.ativo, u.criado_em,
                (SELECT MAX(l.criado_em) FROM log_acessos l
                  WHERE l.usuario_id = u.id AND l.acao = 'LOGIN') AS ultimo_acesso
           FROM usuarios u ORDER BY u.ativo DESC, u.nome"
    )->fetchAll());
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    responder(['erro' => 'Método não permitido.'], 405);
}

$d = json_decode(file_get_contents('php://input'), true);
if (!is_array($d)) {
    responder(['erro' => 'Dados inválidos.'], 400);
}

// Regra de senha (a mesma para criar e redefinir).
// Máximo de 72 bytes: o bcrypt ignora o que passa disso.
function erroDeSenha($senha, $confirmacao)
{
    if (strlen($senha) < 8) return 'A senha precisa ter pelo menos 8 caracteres.';
    if (strlen($senha) > 72) return 'A senha pode ter no máximo 72 caracteres.';
    if ($senha !== $confirmacao) return 'As senhas não conferem.';
    return null;
}

// Validação dos dados cadastrais (a mesma para criar e editar). Devolve a lista de erros por campo.
function errosDeCadastro($nome, $email, $perfil, $registro)
{
    $erros = [];
    if (mb_strlen($nome) < 3 || mb_strlen($nome) > 120) $erros['nome'] = 'Informe o nome completo.';
    if (!filter_var($email, FILTER_VALIDATE_EMAIL) || mb_strlen($email) > 120) $erros['email'] = 'Informe um e-mail válido.';
    if (!in_array($perfil, ['ADMIN', 'PSICOLOGO', 'ASSISTENTE_SOCIAL'], true)) $erros['perfil'] = 'Selecione o perfil.';
    if (in_array($perfil, ['PSICOLOGO', 'ASSISTENTE_SOCIAL'], true)) { // profissional precisa de registro de classe
        if ($registro === '') $erros['registro_classe'] = 'Informe o registro (CRP/CRESS).';
        elseif (mb_strlen($registro) > 30) $erros['registro_classe'] = 'No máximo 30 caracteres.';
    }
    return $erros;
}

$acao = $d['acao'] ?? '';

// ---------- Criar usuário ----------
if ($acao === 'criar') {
    $nome     = trim($d['nome'] ?? '');
    $email    = mb_strtolower(trim($d['email'] ?? ''));
    $perfil   = $d['perfil'] ?? '';
    $registro = trim($d['registro_classe'] ?? '');
    $senha    = (string) ($d['senha'] ?? '');
    $confirma = (string) ($d['confirmacao'] ?? '');

    $erros = errosDeCadastro($nome, $email, $perfil, $registro);
    if ($msg = erroDeSenha($senha, $confirma)) $erros['senha'] = $msg;
    if ($erros) responder(['erros' => $erros], 422);

    $stmt = $pdo->prepare('SELECT 1 FROM usuarios WHERE email = ?');
    $stmt->execute([$email]);
    if ($stmt->fetch()) responder(['erros' => ['email' => 'Já existe um usuário com este e-mail.']], 409);

    $pdo->prepare('INSERT INTO usuarios (nome, email, senha_hash, perfil, registro_classe) VALUES (?, ?, ?, ?, ?)')
        ->execute([$nome, $email, password_hash($senha, PASSWORD_DEFAULT), $perfil, $perfil === 'ADMIN' ? null : $registro]);

    responder(['ok' => true, 'id' => (int) $pdo->lastInsertId()], 201);
}

// As duas ações abaixo mexem em um usuário que já existe
$id = (int) ($d['id'] ?? 0);
$stmt = $pdo->prepare('SELECT id, perfil, ativo FROM usuarios WHERE id = ?');
$stmt->execute([$id]);
$alvo = $stmt->fetch();
if (!$alvo) responder(['erro' => 'Usuário não encontrado.'], 404);

// ---------- Editar dados do usuário (a senha tem ação própria) ----------
if ($acao === 'editar') {
    $nome     = trim($d['nome'] ?? '');
    $email    = mb_strtolower(trim($d['email'] ?? ''));
    $perfil   = $d['perfil'] ?? '';
    $registro = trim($d['registro_classe'] ?? '');

    $erros = errosDeCadastro($nome, $email, $perfil, $registro);

    if ($perfil !== $alvo['perfil']) {
        // Ninguém muda o próprio perfil (evita o administrador se trancar para fora do sistema)
        if ((int) $alvo['id'] === (int) $usuario['id']) {
            $erros['perfil'] = 'Você não pode alterar o seu próprio perfil.';
        }
        // Sempre deve sobrar pelo menos um administrador ativo
        if ($alvo['perfil'] === 'ADMIN' && (int) $alvo['ativo'] === 1) {
            $outros = $pdo->prepare("SELECT COUNT(*) FROM usuarios WHERE perfil = 'ADMIN' AND ativo = 1 AND id <> ?");
            $outros->execute([$alvo['id']]);
            if ((int) $outros->fetchColumn() === 0) {
                $erros['perfil'] = 'Não é possível mudar o perfil do único administrador ativo.';
            }
        }
    }
    if ($erros) responder(['erros' => $erros], 422);

    // E-mail já usado por OUTRO usuário?
    $stmt = $pdo->prepare('SELECT 1 FROM usuarios WHERE email = ? AND id <> ?');
    $stmt->execute([$email, $alvo['id']]);
    if ($stmt->fetch()) responder(['erros' => ['email' => 'Já existe um usuário com este e-mail.']], 409);

    $pdo->prepare('UPDATE usuarios SET nome = ?, email = ?, perfil = ?, registro_classe = ? WHERE id = ?')
        ->execute([$nome, $email, $perfil, $perfil === 'ADMIN' ? null : $registro, $alvo['id']]);

    // O perfil novo vale já na próxima requisição da pessoa (o login confere o banco a cada chamada)
    responder(['ok' => true]);
}

// ---------- Ativar / desativar ----------
if ($acao === 'situacao') {
    $ativar = !empty($d['ativo']) ? 1 : 0;

    if (!$ativar) {
        if ((int) $alvo['id'] === (int) $usuario['id']) {
            responder(['erro' => 'Você não pode desativar o seu próprio usuário.'], 422);
        }
        // Sempre deve sobrar pelo menos um administrador ativo
        if ($alvo['perfil'] === 'ADMIN' && (int) $alvo['ativo'] === 1) {
            $outros = $pdo->prepare("SELECT COUNT(*) FROM usuarios WHERE perfil = 'ADMIN' AND ativo = 1 AND id <> ?");
            $outros->execute([$alvo['id']]);
            if ((int) $outros->fetchColumn() === 0) {
                responder(['erro' => 'Não é possível desativar o único administrador ativo.'], 422);
            }
        }
    }

    $pdo->prepare('UPDATE usuarios SET ativo = ? WHERE id = ?')->execute([$ativar, $alvo['id']]);
    responder(['ok' => true, 'ativo' => $ativar]); // quem for desativado perde o acesso na próxima requisição
}

// ---------- Redefinir senha de outro usuário ----------
if ($acao === 'senha') {
    $senha = (string) ($d['senha'] ?? '');
    if ($msg = erroDeSenha($senha, (string) ($d['confirmacao'] ?? ''))) {
        responder(['erros' => ['senha' => $msg]], 422);
    }
    $pdo->prepare('UPDATE usuarios SET senha_hash = ? WHERE id = ?')
        ->execute([password_hash($senha, PASSWORD_DEFAULT), $alvo['id']]);
    responder(['ok' => true]);
}

responder(['erro' => 'Ação inválida.'], 400);
