<?php
// =====================================================
// api/estudantes_gestao.php — correção de dados dos estudantes (SOMENTE ADMIN)
//   GET  -> lista para a tela "Estudantes" (identificação, turma e responsável)
//   POST -> { id, nome_completo, matricula, data_nascimento, turma_id, responsavel_* }
//
// PRIVACIDADE: o administrador NÃO lê prontuário. Por isso esta API nunca devolve
// nem altera composição familiar, necessidades de apoio, status, triagem ou atendimentos.
// =====================================================
require __DIR__ . '/conexao.php';
require __DIR__ . '/regras_estudante.php';

$usuario = usuarioLogado($pdo);
if ($usuario['perfil'] !== 'ADMIN') {
    responder(['erro' => 'Apenas administradores podem corrigir dados de estudantes.'], 403);
}

// ---------- GET: lista ----------
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // O responsável principal é o marcado como principal (ou o primeiro cadastrado)
    responder($pdo->query(
        'SELECT e.id, e.nome_completo, e.matricula, e.data_nascimento, e.status,
                t.id AS turma_id, t.nome AS turma, t.turno, t.ano_letivo,
                r.nome AS responsavel_nome, r.parentesco AS responsavel_parentesco,
                r.telefone AS responsavel_telefone
           FROM estudantes e
           JOIN turmas t ON t.id = e.turma_id
           LEFT JOIN responsaveis r ON r.id = (
                SELECT r2.id FROM responsaveis r2
                 WHERE r2.estudante_id = e.id ORDER BY r2.principal DESC, r2.id LIMIT 1)
          ORDER BY e.nome_completo'
    )->fetchAll());
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    responder(['erro' => 'Método não permitido.'], 405);
}

$d = json_decode(file_get_contents('php://input'), true);
if (!is_array($d)) {
    responder(['erro' => 'Dados inválidos.'], 400);
}

// ---------- Editar ----------
$id = (int) ($d['id'] ?? 0);
$stmt = $pdo->prepare('SELECT id FROM estudantes WHERE id = ?');
$stmt->execute([$id]);
if (!$stmt->fetch()) {
    responder(['erro' => 'Estudante não encontrado.'], 404);
}

$e = lerDadosEstudante($d);
$erros = validarDadosEstudante($e);
if ($erros) {
    responder(['erros' => $erros], 422);
}

// A turma escolhida existe?
$stmt = $pdo->prepare('SELECT id FROM turmas WHERE id = ?');
$stmt->execute([$e['turmaId']]);
if (!$stmt->fetch()) {
    responder(['erros' => ['turma_id' => 'Turma não encontrada.']], 422);
}

// Matrícula já usada por OUTRO estudante?
$stmt = $pdo->prepare('SELECT id FROM estudantes WHERE matricula = ? AND id <> ?');
$stmt->execute([$e['matricula'], $id]);
if ($stmt->fetch()) {
    responder(['erros' => ['matricula' => 'Esta matrícula já está cadastrada em outro estudante.']], 409);
}

$telefone = telefoneFormatado($e['respTel']);

// Transação: estudante + responsável + log, tudo ou nada
try {
    $pdo->beginTransaction();

    $pdo->prepare('UPDATE estudantes SET nome_completo = ?, matricula = ?, data_nascimento = ?, turma_id = ? WHERE id = ?')
        ->execute([$e['nome'], $e['matricula'], $e['nascimento'], $e['turmaId'], $id]);

    // Atualiza o responsável principal; se o estudante não tinha nenhum, cria
    $stmt = $pdo->prepare('SELECT id FROM responsaveis WHERE estudante_id = ? ORDER BY principal DESC, id LIMIT 1');
    $stmt->execute([$id]);
    $respId = $stmt->fetchColumn();
    if ($respId) {
        $pdo->prepare('UPDATE responsaveis SET nome = ?, parentesco = ?, telefone = ? WHERE id = ?')
            ->execute([$e['respNome'], $e['respParent'], $telefone, $respId]);
    } else {
        $pdo->prepare('INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal) VALUES (?, ?, ?, ?, 1)')
            ->execute([$id, $e['respNome'], $e['respParent'], $telefone]);
    }

    // Auditoria: quem corrigiu o cadastro
    $pdo->prepare("INSERT INTO log_acessos (usuario_id, acao, estudante_id) VALUES (?, 'EDITOU', ?)")
        ->execute([$usuario['id'], $id]);

    $pdo->commit();
} catch (Throwable $ex) {
    $pdo->rollBack();
    error_log($ex->getMessage());
    responder(['erro' => 'Não foi possível salvar. Tente novamente.'], 500);
}

responder(['ok' => true]);
