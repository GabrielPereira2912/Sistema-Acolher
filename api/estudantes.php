<?php
// =====================================================
// GET  api/estudantes.php — lista de estudantes
// POST api/estudantes.php — cadastra um estudante + responsável principal
// Recebe JSON do front-end, valida, grava no banco e devolve JSON.
// =====================================================
require __DIR__ . '/conexao.php';
require __DIR__ . '/regras_estudante.php';

$usuario = usuarioLogado($pdo); // exige login (e dá o id de quem está cadastrando)

// GET: lista simples de estudantes (usada para escolher qual prontuário abrir)
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Esta lista serve só para escolher prontuário/triagem: o administrador não usa
    if ($usuario['perfil'] === 'ADMIN') {
        responder(['erro' => 'Seu perfil não tem acesso a esta lista.'], 403);
    }
    // tem_acolhimento = 1 se o estudante já passou pela triagem (usado na tela de Triagem)
    responder($pdo->query(
        'SELECT e.id, e.nome_completo, e.matricula,
                CASE WHEN EXISTS (SELECT 1 FROM acolhimentos a WHERE a.estudante_id = e.id) THEN 1 ELSE 0 END AS tem_acolhimento
           FROM estudantes e
          ORDER BY e.nome_completo'
    )->fetchAll());
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
// Os campos comuns (nome, matrícula, turma, responsável...) e as regras deles
// ficam em regras_estudante.php, porque a edição do ADMIN usa as mesmas.
$e = lerDadosEstudante($d);
$nome       = $e['nome'];
$matricula  = $e['matricula'];
$nascimento = $e['nascimento'];
$turmaId    = $e['turmaId'];
$respNome   = $e['respNome'];
$respParent = $e['respParent'];
$respTel    = $e['respTel'];
$composicao = trim($d['composicao_familiar'] ?? '');
$apoio      = trim($d['necessidades_apoio'] ?? '');

// ---------- 2) Validar (o front valida por conforto; AQUI é a validação que vale) ----------
$erros = validarDadosEstudante($e);
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

$telefone = telefoneFormatado($respTel);

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
        $usuario['id'],
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
    $stmt->execute([$usuario['id'], $estudanteId]);

    $pdo->commit();
} catch (Throwable $e) {
    $pdo->rollBack();
    error_log($e->getMessage());
    responder(['erro' => 'Erro ao salvar o estudante. Tente novamente.'], 500);
}

responder(['ok' => true, 'id' => $estudanteId], 201);
