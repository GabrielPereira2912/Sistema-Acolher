<?php
// =====================================================
// regras_estudante.php — regras de validação dos dados do estudante,
// usadas por estudantes.php (cadastro) e estudantes_gestao.php (edição pelo ADMIN).
// Assim a mesma regra vale nos dois lugares.
// =====================================================

// Lê os campos comuns do corpo da requisição, já limpos
function lerDadosEstudante($d)
{
    return [
        'nome'       => trim($d['nome_completo'] ?? ''),
        'matricula'  => trim($d['matricula'] ?? ''),
        'nascimento' => trim($d['data_nascimento'] ?? ''),
        'turmaId'    => (int) ($d['turma_id'] ?? 0),
        'respNome'   => trim($d['responsavel_nome'] ?? ''),
        'respParent' => trim($d['responsavel_parentesco'] ?? ''),
        'respTel'    => preg_replace('/\D/', '', $d['responsavel_telefone'] ?? ''), // só números
    ];
}

// Valida o FORMATO dos campos. Devolve a lista de erros por campo (vazia = tudo certo).
function validarDadosEstudante($e)
{
    $erros = [];

    if (mb_strlen($e['nome']) < 3) {
        $erros['nome_completo'] = 'Informe o nome completo.';
    }
    if (!preg_match('/^\d{4}-\d{5}$/', $e['matricula'])) {
        $erros['matricula'] = 'Use o formato 0000-00000.';
    }

    $data = DateTime::createFromFormat('Y-m-d', $e['nascimento']);
    if (!$data || $data->format('Y-m-d') !== $e['nascimento']) {
        $erros['data_nascimento'] = 'Informe uma data válida.';
    } elseif ($data > new DateTime('today')) {
        $erros['data_nascimento'] = 'A data não pode ser no futuro.';
    }

    if ($e['turmaId'] <= 0) {
        $erros['turma_id'] = 'Selecione a turma.';
    }
    if (mb_strlen($e['respNome']) < 3) {
        $erros['responsavel_nome'] = 'Informe o nome do responsável.';
    }
    if ($e['respParent'] === '') {
        $erros['responsavel_parentesco'] = 'Informe o parentesco.';
    }
    if (strlen($e['respTel']) < 10 || strlen($e['respTel']) > 11) {
        $erros['responsavel_telefone'] = 'Informe um telefone com DDD.';
    }
    return $erros;
}

// Telefone no formato (00) 00000-0000 para guardar e exibir
function telefoneFormatado($digitos)
{
    return strlen($digitos) === 11
        ? sprintf('(%s) %s-%s', substr($digitos, 0, 2), substr($digitos, 2, 5), substr($digitos, 7))
        : sprintf('(%s) %s-%s', substr($digitos, 0, 2), substr($digitos, 2, 4), substr($digitos, 6));
}
