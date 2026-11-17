<?php
// =====================================================
// POST api/acolhimentos.php — registra a triagem (acolhimento inicial) de um estudante
// Grava: 1 acolhimento + as demandas marcadas (seleção múltipla).
// O profissional é sempre o usuário logado e a data é sempre "hoje".
// =====================================================
require __DIR__ . '/conexao.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    responder(['erro' => 'Método não permitido.'], 405);
}

$d = json_decode(file_get_contents('php://input'), true);
if (!is_array($d)) {
    responder(['erro' => 'Dados inválidos.'], 400);
}

// Só Psicólogo e Assistente Social registram triagem (Admin não)
$usuario = usuarioLogado($pdo);
if (!in_array($usuario['perfil'], ['PSICOLOGO', 'ASSISTENTE_SOCIAL'], true)) {
    responder(['erro' => 'Seu perfil não pode registrar triagens.'], 403);
}

// ---------- 1) Limpar ----------
$estudanteId = (int) ($d['estudante_id'] ?? 0);
$descricao   = trim($d['descricao_complementar'] ?? '');
$outras      = trim($d['outras_especificacao'] ?? '');

// Lista de ids das categorias marcadas: só números > 0, sem repetir
$ids = is_array($d['categorias'] ?? null) ? $d['categorias'] : [];
$ids = array_values(array_unique(array_filter(array_map('intval', $ids), function ($n) { return $n > 0; })));

// ---------- 2) Validar ----------
$erros = [];
$exigeEspecificacao = false;

if (!$ids) {
    $erros['categorias'] = 'Selecione ao menos uma demanda.';
} else {
    // Todas as categorias marcadas existem e estão ativas?
    $marcas = implode(',', array_fill(0, count($ids), '?'));
    $stmt = $pdo->prepare("SELECT id, exige_especificacao FROM categorias_demanda WHERE ativo = 1 AND id IN ($marcas)");
    $stmt->execute($ids);
    $encontradas = $stmt->fetchAll();

    if (count($encontradas) !== count($ids)) {
        $erros['categorias'] = 'Há uma demanda inválida na seleção.';
    }
    foreach ($encontradas as $c) {
        if ((int) $c['exige_especificacao'] === 1) {
            $exigeEspecificacao = true;   // marcou "Outras"
        }
    }
}

if ($exigeEspecificacao && mb_strlen($outras) < 3) {
    $erros['outras_especificacao'] = 'Especifique a demanda "Outras".';
}
if (mb_strlen($descricao) < 5) {
    $erros['descricao_complementar'] = 'Descreva a situação inicial.';
}
if ($erros) {
    responder(['erros' => $erros], 422);
}
if (!$exigeEspecificacao) {
    $outras = '';   // sem "Outras" marcada, a especificação não é guardada
}

// ---------- 3) Regras que dependem do banco ----------
$stmt = $pdo->prepare('SELECT id FROM estudantes WHERE id = ?');
$stmt->execute([$estudanteId]);
if (!$stmt->fetch()) {
    responder(['erros' => ['estudante_id' => 'Selecione o estudante.']], 422);
}

// Um estudante tem uma única triagem inicial; as ações seguintes são atendimentos
$stmt = $pdo->prepare('SELECT id FROM acolhimentos WHERE estudante_id = ?');
$stmt->execute([$estudanteId]);
if ($stmt->fetch()) {
    responder(['erros' => ['estudante_id' => 'Este estudante já tem triagem registrada. Use o prontuário para novos atendimentos.']], 409);
}

// ---------- 4) Gravar (tudo ou nada) ----------
try {
    $pdo->beginTransaction();

    $stmt = $pdo->prepare(
        'INSERT INTO acolhimentos
            (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao)
         VALUES (?, ?, ?, ?, ?)'
    );
    $stmt->execute([
        $estudanteId, $usuario['id'], date('Y-m-d'), $descricao,
        $outras !== '' ? $outras : null,
    ]);
    $acolhimentoId = (int) $pdo->lastInsertId();

    // Uma linha por demanda marcada (tabela N:N)
    $stmt = $pdo->prepare('INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id) VALUES (?, ?)');
    foreach ($ids as $categoriaId) {
        $stmt->execute([$acolhimentoId, $categoriaId]);
    }

    $pdo->prepare("INSERT INTO log_acessos (usuario_id, acao, estudante_id) VALUES (?, 'CRIOU', ?)")
        ->execute([$usuario['id'], $estudanteId]);

    $pdo->commit();
} catch (Throwable $e) {
    $pdo->rollBack();
    error_log($e->getMessage());
    responder(['erro' => 'Erro ao registrar a triagem. Tente novamente.'], 500);
}

responder(['ok' => true, 'id' => $acolhimentoId, 'estudante_id' => $estudanteId], 201);
