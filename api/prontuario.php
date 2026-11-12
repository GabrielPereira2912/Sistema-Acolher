<?php
// =====================================================
// GET api/prontuario.php?id=N — tudo que a tela de Prontuário precisa:
// ficha do estudante, linha do tempo, encaminhamentos e listas dos selects.
// =====================================================
require __DIR__ . '/conexao.php';

$id = (int) ($_GET['id'] ?? 0);
if ($id <= 0) {
    responder(['erro' => 'Estudante não informado.'], 400);
}

$usuario = usuarioLogado($pdo);

// ---------- 1) Ficha do estudante (+ turma, que tem turno e etapa) ----------
$stmt = $pdo->prepare(
    'SELECT e.id, e.nome_completo, e.matricula, e.data_nascimento, e.status,
            e.composicao_familiar, e.necessidades_apoio,
            t.nome AS turma, t.turno, t.etapa_ensino
       FROM estudantes e
       JOIN turmas t ON t.id = e.turma_id
      WHERE e.id = ?'
);
$stmt->execute([$id]);
$estudante = $stmt->fetch();
if (!$estudante) {
    responder(['erro' => 'Estudante não encontrado.'], 404);
}

// Responsável principal (o marcado como principal vem primeiro)
$stmt = $pdo->prepare(
    'SELECT nome, parentesco, telefone FROM responsaveis
      WHERE estudante_id = ? ORDER BY principal DESC, id LIMIT 1'
);
$stmt->execute([$id]);
$estudante['responsavel'] = $stmt->fetch() ?: null;

// Profissional responsável: vem da view painel_estudantes (último atendimento ou quem cadastrou)
$stmt = $pdo->prepare('SELECT profissional FROM painel_estudantes WHERE estudante_id = ?');
$stmt->execute([$id]);
$estudante['profissional'] = $stmt->fetchColumn();

// ---------- 2) Linha do tempo (view que junta acolhimentos + atendimentos) ----------
$stmt = $pdo->prepare(
    'SELECT data, titulo, profissional, cargo, descricao, modalidade
       FROM linha_do_tempo
      WHERE estudante_id = ?
      ORDER BY data DESC, criado_em DESC'
);
$stmt->execute([$id]);
$linha = $stmt->fetchAll();

// ---------- 3) Encaminhamentos do estudante (abertos primeiro) ----------
$stmt = $pdo->prepare(
    "SELECT d.nome AS destino, d.natureza, en.prazo, en.status, u.nome AS responsavel
       FROM encaminhamentos en
       JOIN atendimentos a              ON a.id = en.atendimento_id
       JOIN destinos_encaminhamento d   ON d.id = en.destino_id
       JOIN usuarios u                  ON u.id = en.responsavel_id
      WHERE a.estudante_id = ?
      ORDER BY (en.status = 'ABERTO') DESC, en.prazo"
);
$stmt->execute([$id]);
$encaminhamentos = $stmt->fetchAll();

// ---------- 4) Listas fixas para os selects do formulário ----------
$tipos    = $pdo->query('SELECT id, nome FROM tipos_acao WHERE ativo = 1 ORDER BY id')->fetchAll();
$destinos = $pdo->query('SELECT id, nome, natureza FROM destinos_encaminhamento WHERE ativo = 1 ORDER BY id')->fetchAll();

// ---------- 5) Auditoria: registra quem abriu o prontuário ----------
// (recarga=1 é usada pela própria tela após salvar; aí não registramos de novo)
if (empty($_GET['recarga'])) {
    $stmt = $pdo->prepare("INSERT INTO log_acessos (usuario_id, acao, estudante_id) VALUES (?, 'VISUALIZOU', ?)");
    $stmt->execute([$usuario['id'], $id]);
}

responder([
    'estudante'       => $estudante,
    'linha_do_tempo'  => $linha,
    'encaminhamentos' => $encaminhamentos,
    'tipos_acao'      => $tipos,
    'destinos'        => $destinos,
]);
