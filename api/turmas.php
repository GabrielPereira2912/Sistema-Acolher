<?php
// =====================================================
// GET api/turmas.php — lista as turmas do ano letivo atual
// Usada para preencher o <select> de Turma no cadastro.
// =====================================================
require __DIR__ . '/conexao.php';

$stmt = $pdo->prepare(
    'SELECT id, nome, turno, etapa_ensino
       FROM turmas
      WHERE ano_letivo = ?
      ORDER BY etapa_ensino, nome'
);
$stmt->execute([date('Y')]);

responder($stmt->fetchAll());
