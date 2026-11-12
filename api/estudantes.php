<?php
// =====================================================
// GET  api/estudantes.php — lista de estudantes
// POST api/estudantes.php — cadastra um estudante + responsável principal
// Recebe JSON do front-end, valida, grava no banco e devolve JSON.
// =====================================================
require __DIR__ . '/conexao.php';

// GET: lista simples de estudantes (usada para escolher qual prontuário abrir)
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    responder($pdo->query('SELECT id, nome_completo, matricula FROM estudantes ORDER BY nome_completo')->fetchAll());
}

// Daqui para baixo: só aceita POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    responder(['erro' => 'Método não permitido.'], 405);
}

// Lê o corpo da requisição (JSON enviado pelo fetch)
$d = json_decode(file_get_contents('php://input'), true);
if (!is_array($d)) {
    responder(['erro' => 'Dados inválidos.'], 400);
}

// ---------- 1) Limpar os dados recebidos ----------
$nome       = trim($d['nome_completo'] ?? '');
$matricula  = trim($d['matricula'] ?? '');
$nascimento = trim($d['data_nascimento'] ?? '');
$turmaId    = (int) ($d['turma_id'] ?? 0);
$respNome   = trim($d['responsavel_nome'] ?? '');
$respParent = trim($d['responsavel_parentesco'] ?? '');
$respTel    = preg_replace('/\D/', '', $d['responsavel_telefone'] ?? ''); // só números
$composicao = trim($d['composicao_familiar'] ?? '');
$apoio      = trim($d['necessidades_apoio'] ?? '');

// ---------- 2) Validar (o front valida por conforto; AQUI é a validação que vale) ----------
$erros = [];

if (mb_strlen($nome) < 3) {
    $erros['nome_completo'] = 'Informe o nome completo.';
}

if (!preg_match('/^\d{4}-\d{5}$/', $matricula)) {
    $erros['matricula'] = 'Use o formato 0000-00000.';
}

$data = DateTime::createFromFormat('Y-m-d', $nascimento);
if (!$data || $data->format('Y-m-d') !== $nascimento) {
    $erros['data_nascimento'] = 'Informe uma data válida.';
} elseif ($data > new DateTime('today')) {
    $erros['data_nascimento'] = 'A data não pode ser no futuro.';
}

if ($turmaId <= 0) {
    $erros['turma_id'] = 'Selecione a turma.';
}

if (mb_strlen($respNome) < 3) {
    $erros['responsavel_nome'] = 'Informe o nome do responsável.';
}
if ($respParent === '') {
    $erros['responsavel_parentesco'] = 'Informe o parentesco.';
}
if (strlen($respTel) < 10 || strlen($respTel) > 11) {
    $erros['responsavel_telefone'] = 'Informe um telefone com DDD.';
}

if ($erros) {
    responder(['erros' => $erros], 422);
}

// ---------- 3) Regras que dependem do banco ----------
// A turma escolhida existe?
$stmt = $pdo->prepare('SELECT id FROM turmas WHERE id = ?');
$stmt->execute([$turmaId]);
if (!$stmt->fetch()) {
    responder(['erros' => ['turma_id' => 'Turma não encontrada.']], 422);
}

// Matrícula já cadastrada? (a coluna é UNIQUE, mas assim damos uma mensagem amigável)
$stmt = $pdo->prepare('SELECT id FROM estudantes WHERE matricula = ?');
$stmt->execute([$matricula]);
if ($stmt->fetch()) {
    responder(['erros' => ['matricula' => 'Esta matrícula já está cadastrada.']], 409);
}

// Telefone no formato (00) 00000-0000 para guardar e exibir
$telefone = strlen($respTel) === 11
    ? sprintf('(%s) %s-%s', substr($respTel, 0, 2), substr($respTel, 2, 5), substr($respTel, 7))
    : sprintf('(%s) %s-%s', substr($respTel, 0, 2), substr($respTel, 2, 4), substr($respTel, 6));

// ---------- 4) Gravar ----------
// Transação: ou grava tudo (estudante + responsável + log), ou não grava nada.
try {
    $pdo->beginTransaction();

    // Status não é informado: o banco usa o padrão 'TRIAGEM'
    $stmt = $pdo->prepare(
        'INSERT INTO estudantes
            (nome_completo, matricula, data_nascimento, turma_id,
             composicao_familiar, necessidades_apoio, criado_por)
         VALUES (?, ?, ?, ?, ?, ?, ?)'
    );
    $stmt->execute([
        $nome, $matricula, $nascimento, $turmaId,
        $composicao !== '' ? $composicao : null,   // campos opcionais vazios viram NULL
        $apoio      !== '' ? $apoio      : null,
        USUARIO_LOGADO_ID,
    ]);
    $estudanteId = (int) $pdo->lastInsertId();

    // O responsável informado no formulário é o principal
    $stmt = $pdo->prepare(
        'INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
         VALUES (?, ?, ?, ?, 1)'
    );
    $stmt->execute([$estudanteId, $respNome, $respParent, $telefone]);

    // Registro de auditoria: quem criou este prontuário
    $stmt = $pdo->prepare(
        "INSERT INTO log_acessos (usuario_id, acao, estudante_id) VALUES (?, 'CRIOU', ?)"
    );
    $stmt->execute([USUARIO_LOGADO_ID, $estudanteId]);

    $pdo->commit();
} catch (Throwable $e) {
    $pdo->rollBack();
    error_log($e->getMessage());
    responder(['erro' => 'Erro ao salvar o estudante. Tente novamente.'], 500);
}

responder(['ok' => true, 'id' => $estudanteId], 201);
