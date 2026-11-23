<?php
// =====================================================
// POST api/encaminhamentos.php — conclui ou cancela um encaminhamento ABERTO
// Corpo JSON: { "id": 12, "acao": "concluir" | "cancelar" }
// Só Psicólogo e Assistente Social (o Admin não mexe em dado clínico).
// =====================================================
require __DIR__ . '/conexao.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    responder(['erro' => 'Método não permitido.'], 405);
}

$d = json_decode(file_get_contents('php://input'), true);
if (!is_array($d)) {
    responder(['erro' => 'Dados inválidos.'], 400);
}

$usuario = usuarioLogado($pdo);
if (!in_array($usuario['perfil'], ['PSICOLOGO', 'ASSISTENTE_SOCIAL'], true)) {
    responder(['erro' => 'Seu perfil não pode alterar encaminhamentos.'], 403);
}

$id   = (int) ($d['id'] ?? 0);
$acao = $d['acao'] ?? '';
if ($id <= 0 || !in_array($acao, ['concluir', 'cancelar'], true)) {
    responder(['erro' => 'Dados inválidos.'], 400);
}

// Descobre o estudante dono do encaminhamento (para o log) e o status atual
$stmt = $pdo->prepare(
    'SELECT en.status, a.estudante_id
       FROM encaminhamentos en
       JOIN atendimentos a ON a.id = en.atendimento_id
      WHERE en.id = ?'
);
$stmt->execute([$id]);
$enc = $stmt->fetch();
if (!$enc) {
    responder(['erro' => 'Encaminhamento não encontrado.'], 404);
}
if ($enc['status'] !== 'ABERTO') {
    responder(['erro' => 'Este encaminhamento já foi encerrado.'], 409);
}

// Concluído guarda a data de hoje; cancelado não tem data de conclusão
$novoStatus = $acao === 'concluir' ? 'CONCLUIDO' : 'CANCELADO';
$concluidoEm = $acao === 'concluir' ? date('Y-m-d') : null;

try {
    $pdo->beginTransaction();

    // "AND status = 'ABERTO'" evita encerrar duas vezes se dois cliques chegarem juntos
    $stmt = $pdo->prepare(
        "UPDATE encaminhamentos SET status = ?, concluido_em = ? WHERE id = ? AND status = 'ABERTO'"
    );
    $stmt->execute([$novoStatus, $concluidoEm, $id]);
    if ($stmt->rowCount() === 0) {
        $pdo->rollBack();
        responder(['erro' => 'Este encaminhamento já foi encerrado.'], 409);
    }

    $pdo->prepare("INSERT INTO log_acessos (usuario_id, acao, estudante_id) VALUES (?, 'EDITOU', ?)")
        ->execute([$usuario['id'], $enc['estudante_id']]);

    $pdo->commit();
} catch (Throwable $e) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    error_log($e->getMessage());
    responder(['erro' => 'Erro ao atualizar o encaminhamento. Tente novamente.'], 500);
}

responder(['ok' => true, 'status' => $novoStatus]);
