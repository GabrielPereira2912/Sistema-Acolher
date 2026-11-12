<?php
// =====================================================
// POST api/atendimentos.php — registra um atendimento (e, se houver, 1 encaminhamento)
// O profissional NUNCA vem do formulário: é sempre o usuário logado.
// =====================================================
require __DIR__ . '/conexao.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    responder(['erro' => 'Método não permitido.'], 405);
}

$d = json_decode(file_get_contents('php://input'), true);
if (!is_array($d)) {
    responder(['erro' => 'Dados inválidos.'], 400);
}

// Só Psicólogo e Assistente Social registram atendimento (Admin não)
$usuario = usuarioLogado($pdo);
if (!in_array($usuario['perfil'], ['PSICOLOGO', 'ASSISTENTE_SOCIAL'], true)) {
    responder(['erro' => 'Seu perfil não pode registrar atendimentos.'], 403);
}

// ---------- 1) Limpar ----------
$estudanteId = (int) ($d['estudante_id'] ?? 0);
$data        = trim($d['data_atendimento'] ?? '');
$modalidade  = trim($d['modalidade'] ?? '');
$tipoId      = (int) ($d['tipo_acao_id'] ?? 0);
$descricao   = trim($d['descricao'] ?? '');
$destinoId   = (int) ($d['destino_id'] ?? 0);    // 0 = sem encaminhamento
$prazo       = trim($d['prazo'] ?? '');

// ---------- 2) Validar ----------
$erros = [];

if (!dataValida($data)) {
    $erros['data_atendimento'] = 'Informe uma data válida.';
} elseif ($data > date('Y-m-d')) {
    $erros['data_atendimento'] = 'A data não pode ser no futuro.';
}

if (!in_array($modalidade, ['INDIVIDUAL', 'GRUPO', 'FAMILIA', 'PROFESSORES', 'TELEFONE'], true)) {
    $erros['modalidade'] = 'Selecione a modalidade.';
}

if ($tipoId <= 0) {
    $erros['tipo_acao_id'] = 'Selecione o tipo de intervenção.';
}

if (mb_strlen($descricao) < 5) {
    $erros['descricao'] = 'Descreva a intervenção.';
}

if ($destinoId > 0) {
    if (!dataValida($prazo)) {
        $erros['prazo'] = 'Informe o prazo do encaminhamento.';
    } elseif (!isset($erros['data_atendimento']) && $prazo < $data) {
        $erros['prazo'] = 'O prazo não pode ser antes da data do atendimento.';
    }
}

if ($erros) {
    responder(['erros' => $erros], 422);
}

// ---------- 3) Conferir no banco se os itens escolhidos existem ----------
$stmt = $pdo->prepare('SELECT id, status FROM estudantes WHERE id = ?');
$stmt->execute([$estudanteId]);
$estudante = $stmt->fetch();
if (!$estudante) {
    responder(['erro' => 'Estudante não encontrado.'], 404);
}

$stmt = $pdo->prepare('SELECT id FROM tipos_acao WHERE id = ? AND ativo = 1');
$stmt->execute([$tipoId]);
if (!$stmt->fetch()) {
    responder(['erros' => ['tipo_acao_id' => 'Tipo de intervenção inválido.']], 422);
}

if ($destinoId > 0) {
    $stmt = $pdo->prepare('SELECT id FROM destinos_encaminhamento WHERE id = ? AND ativo = 1');
    $stmt->execute([$destinoId]);
    if (!$stmt->fetch()) {
        responder(['erros' => ['destino_id' => 'Destino inválido.']], 422);
    }
}

// ---------- 4) Gravar (tudo ou nada) ----------
try {
    $pdo->beginTransaction();

    // O cargo fica gravado no momento do registro (mesmo que o perfil mude depois)
    $stmt = $pdo->prepare(
        'INSERT INTO atendimentos
            (estudante_id, profissional_id, cargo_profissional, data_atendimento,
             modalidade, tipo_acao_id, descricao)
         VALUES (?, ?, ?, ?, ?, ?, ?)'
    );
    $stmt->execute([
        $estudanteId, $usuario['id'], $usuario['perfil'], $data,
        $modalidade, $tipoId, $descricao,
    ]);
    $atendimentoId = (int) $pdo->lastInsertId();

    // Encaminhamento (opcional). Quem acompanha o prazo é quem está registrando.
    if ($destinoId > 0) {
        $stmt = $pdo->prepare(
            'INSERT INTO encaminhamentos (atendimento_id, destino_id, prazo, responsavel_id)
             VALUES (?, ?, ?, ?)'
        );
        $stmt->execute([$atendimentoId, $destinoId, $prazo, $usuario['id']]);
    }

    // Atendimento registrado = estudante em acompanhamento
    // (tira da triagem e também reabre quem estava encerrado)
    if ($estudante['status'] !== 'EM_ACOMPANHAMENTO') {
        $pdo->prepare("UPDATE estudantes SET status = 'EM_ACOMPANHAMENTO' WHERE id = ?")
            ->execute([$estudanteId]);
    }

    $pdo->prepare("INSERT INTO log_acessos (usuario_id, acao, estudante_id) VALUES (?, 'CRIOU', ?)")
        ->execute([$usuario['id'], $estudanteId]);

    $pdo->commit();
} catch (Throwable $e) {
    $pdo->rollBack();
    error_log($e->getMessage());
    responder(['erro' => 'Erro ao registrar o atendimento. Tente novamente.'], 500);
}

responder(['ok' => true, 'id' => $atendimentoId], 201);
