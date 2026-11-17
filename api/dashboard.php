<?php
// =====================================================
// GET api/dashboard.php — dados da tela inicial:
//   - 4 números dos cards
//   - lista de estudantes (view painel_estudantes)
// =====================================================
require __DIR__ . '/conexao.php';

usuarioLogado($pdo); // exige login

// ---------- Cards ----------
// Estudantes em acompanhamento (conta por status)
$acompanhados = (int) $pdo->query("SELECT COUNT(*) FROM estudantes WHERE status = 'EM_ACOMPANHAMENTO'")->fetchColumn();

// Triagens pendentes = estudantes que AINDA NÃO têm triagem (acolhimento) registrada.
// Quem já foi triado e espera o 1º atendimento não entra nesta conta.
$triagens = (int) $pdo->query(
    "SELECT COUNT(*) FROM estudantes e
      WHERE e.status = 'TRIAGEM'
        AND NOT EXISTS (SELECT 1 FROM acolhimentos a WHERE a.estudante_id = e.id)"
)->fetchColumn();

// Aguardando 1º atendimento = já passou pela triagem, mas ainda não teve nenhum atendimento.
// (Quando o 1º atendimento é registrado, o status muda para EM_ACOMPANHAMENTO e sai desta conta.)
$aguardando = (int) $pdo->query(
    "SELECT COUNT(*) FROM estudantes e
      WHERE e.status = 'TRIAGEM'
        AND EXISTS     (SELECT 1 FROM acolhimentos a  WHERE a.estudante_id = e.id)
        AND NOT EXISTS (SELECT 1 FROM atendimentos t  WHERE t.estudante_id = e.id)"
)->fetchColumn();

// Atendimentos do mês atual: do dia 1 ao último dia (BETWEEN usa o índice da data)
$stmt = $pdo->prepare('SELECT COUNT(*) FROM atendimentos WHERE data_atendimento BETWEEN ? AND ?');
$stmt->execute([date('Y-m-01'), date('Y-m-t')]);
$atendimentosMes = (int) $stmt->fetchColumn();

// Encaminhamentos abertos e, dentre eles, os de prazo vencido
$encAbertos = (int) $pdo->query("SELECT COUNT(*) FROM encaminhamentos WHERE status = 'ABERTO'")->fetchColumn();

$stmt = $pdo->prepare("SELECT COUNT(*) FROM encaminhamentos WHERE status = 'ABERTO' AND prazo < ?");
$stmt->execute([date('Y-m-d')]);
$encVencidos = (int) $stmt->fetchColumn();

// ---------- Lista de estudantes ----------
// A view já traz turma, data do último registro e profissional responsável.
$estudantes = $pdo->query(
    'SELECT estudante_id, nome_completo, status, turma, ultimo_atendimento, profissional
       FROM painel_estudantes
      ORDER BY ultimo_atendimento DESC, nome_completo'
)->fetchAll();

responder([
    'cards' => [
        'acompanhados'      => $acompanhados,
        'triagens'          => $triagens,
        'aguardando'        => $aguardando,
        'atendimentos_mes'  => $atendimentosMes,
        'enc_abertos'       => $encAbertos,
        'enc_vencidos'      => $encVencidos,
    ],
    'estudantes' => $estudantes,
]);
