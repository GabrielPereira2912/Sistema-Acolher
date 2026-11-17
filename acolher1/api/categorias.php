<?php
// =====================================================
// GET api/categorias.php — categorias de demanda para os checkboxes da triagem
// (lista fixa do banco; serve só para organizar e filtrar, nunca para diagnóstico)
// =====================================================
require __DIR__ . '/conexao.php';

responder(
    $pdo->query('SELECT id, nome, exige_especificacao FROM categorias_demanda WHERE ativo = 1 ORDER BY id')->fetchAll()
);
