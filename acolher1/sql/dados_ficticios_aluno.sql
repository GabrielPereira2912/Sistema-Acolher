-- =====================================================
-- DADOS FICTÍCIOS PARA TESTAR O PRONTUÁRIO
-- Rodar DEPOIS de banco_acolher_v3.sql e dados_teste.sql
-- (precisa dos usuários Marina e Ricardo e das turmas 7º A e 9º B).
--
-- Todos os nomes são inventados. As matrículas começam com 9999-
-- para ficar fácil achar e apagar (veja limpar_dados_ficticios.sql).
-- As datas são relativas a HOJE, então "vencido" continua valendo
-- em qualquer dia em que você rodar o teste.
-- Para rodar de novo: execute limpar_dados_ficticios.sql primeiro.
-- =====================================================
USE acolher;

-- =====================================================
-- ALUNA 1: Beatriz Helena Duarte Carvalho (usa TODOS os recursos)
-- =====================================================
INSERT INTO estudantes
  (nome_completo, matricula, data_nascimento, turma_id,
   composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Beatriz Helena Duarte Carvalho', '9999-00001', '2013-03-14', t.id,
       'Mora com a mãe (Cláudia), o padrasto (Marcos) e dois irmãos mais novos, de 8 e 5 anos. A avó materna mora na mesma rua e ajuda nos cuidados.',
       'Beneficiária do Bolsa Família. Usa óculos e aguarda consulta oftalmológica. Depende de transporte escolar. Alimentação reforçada na escola.',
       'EM_ACOMPANHAMENTO', u.id, DATE_SUB(NOW(), INTERVAL 60 DAY)
  FROM turmas t, usuarios u
 WHERE t.nome = '7º A' AND t.ano_letivo = YEAR(CURDATE())
   AND u.email = 'marina@escola.test';

-- Responsáveis: um principal e dois secundários
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Cláudia Duarte Carvalho', 'mãe', '(31) 98888-7777', 1 FROM estudantes e WHERE e.matricula = '9999-00001';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Marcos Oliveira', 'padrasto', '(31) 97777-6666', 0 FROM estudantes e WHERE e.matricula = '9999-00001';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Helena Duarte', 'avó materna', '(31) 3333-4444', 0 FROM estudantes e WHERE e.matricula = '9999-00001';

-- ---------- Acolhimento inicial (há 60 dias) ----------
INSERT INTO acolhimentos
  (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 60 DAY),
       'Estudante encaminhada pela professora de Português após queda de rendimento e faltas seguidas. Relata cansaço e dificuldade de se enturmar depois da mudança de bairro. A mãe foi comunicada e compareceu à escola.',
       'Mudança recente de bairro e de escola',
       DATE_SUB(NOW(), INTERVAL 60 DAY)
  FROM estudantes e, usuarios u
 WHERE e.matricula = '9999-00001' AND u.email = 'marina@escola.test';

-- Demandas marcadas no acolhimento (seleção múltipla, inclui "Outras")
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id
  FROM acolhimentos a
  JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN (
         'Dificuldades de aprendizagem e adaptação escolar',
         'Faltas frequentes, risco de evasão e abandono escolar',
         'Conflitos familiares e dificuldades de convivência',
         'Sofrimento emocional e dificuldades comportamentais',
         'Outras')
 WHERE e.matricula = '9999-00001';

-- ---------- Atendimentos (do mais antigo ao mais novo) ----------
-- Modelo: INSERT ... SELECT busca os ids pelo NOME, sem depender de números fixos.

-- 1) há 55 dias · Psicóloga · INDIVIDUAL · Escuta / acolhimento (sem encaminhamento)
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 55 DAY), 'INDIVIDUAL', ta.id,
       'Primeira sessão individual. Beatriz falou pouco, mas relatou saudade da escola anterior e dificuldade para dormir. Combinado retorno semanal.'
  FROM estudantes e, usuarios u, tipos_acao ta
 WHERE e.matricula = '9999-00001' AND u.email = 'marina@escola.test' AND ta.nome = 'Escuta / acolhimento';

-- 2) há 48 dias · Assistente social · TELEFONE · Contato com a família  -> CRAS (CONCLUÍDO)
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 48 DAY), 'TELEFONE', ta.id,
       'Conversa com a mãe sobre as faltas. Ela informou desemprego recente do padrasto e dificuldade com o transporte. Orientada sobre atualização do cadastro no CRAS.'
  FROM estudantes e, usuarios u, tipos_acao ta
 WHERE e.matricula = '9999-00001' AND u.email = 'ricardo@escola.test' AND ta.nome = 'Contato com a família';

-- 3) há 40 dias · Psicóloga · PROFESSORES · Reunião com professores -> Coordenação (ABERTO e VENCIDO)
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 40 DAY), 'PROFESSORES', ta.id,
       'Reunião com os professores de Português, Matemática e Ciências. Alinhadas estratégias: atividades em dupla, retomada de conteúdos e retorno semanal sobre participação em sala.'
  FROM estudantes e, usuarios u, tipos_acao ta
 WHERE e.matricula = '9999-00001' AND u.email = 'marina@escola.test' AND ta.nome = 'Reunião com professores';

-- 4) há 33 dias · Assistente social · FAMILIA · Visita domiciliar -> Conselho Tutelar (CANCELADO)
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 33 DAY), 'FAMILIA', ta.id,
       'Visita à residência. Ambiente organizado, a família demonstrou abertura ao diálogo. Não foram identificados indícios de violação de direitos.'
  FROM estudantes e, usuarios u, tipos_acao ta
 WHERE e.matricula = '9999-00001' AND u.email = 'ricardo@escola.test' AND ta.nome = 'Visita domiciliar';

-- 5) há 25 dias · Psicóloga · GRUPO · Orientação ao estudante (sem encaminhamento)
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 25 DAY), 'GRUPO', ta.id,
       'Roda de conversa com a turma do 7º A sobre convivência e acolhimento de colegas novos. Beatriz participou e fez duas falas espontâneas.'
  FROM estudantes e, usuarios u, tipos_acao ta
 WHERE e.matricula = '9999-00001' AND u.email = 'marina@escola.test' AND ta.nome = 'Orientação ao estudante';

-- 6) há 18 dias · Assistente social · FAMILIA · Articulação com a rede -> UBS (ABERTO, no prazo)
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 18 DAY), 'FAMILIA', ta.id,
       'Reunião com a mãe e contato com a unidade de saúde do bairro para agendar consulta oftalmológica e avaliação do sono.'
  FROM estudantes e, usuarios u, tipos_acao ta
 WHERE e.matricula = '9999-00001' AND u.email = 'ricardo@escola.test' AND ta.nome = 'Articulação com a rede';

-- 7) há 10 dias · Psicóloga · INDIVIDUAL · Orientação ao estudante -> CAPS + Coordenação (2 ABERTOS)
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 10 DAY), 'INDIVIDUAL', ta.id,
       'Sessão sobre sentimentos de tristeza e medo de errar. Relata melhora no sono. Avaliada a necessidade de acompanhamento especializado complementar.'
  FROM estudantes e, usuarios u, tipos_acao ta
 WHERE e.matricula = '9999-00001' AND u.email = 'marina@escola.test' AND ta.nome = 'Orientação ao estudante';

-- 8) há 3 dias · Psicóloga · INDIVIDUAL · Reavaliação (sem encaminhamento)
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 3 DAY), 'INDIVIDUAL', ta.id,
       'Reavaliação do caso: frequência voltou a 90%, melhora nas notas de Português e maior interação com os colegas. Mantido o acompanhamento quinzenal.'
  FROM estudantes e, usuarios u, tipos_acao ta
 WHERE e.matricula = '9999-00001' AND u.email = 'marina@escola.test' AND ta.nome = 'Reavaliação';

-- ---------- Encaminhamentos (todos os destinos e todos os status) ----------
-- Atendimento 2 -> CRAS · CONCLUÍDO
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Atualização do CadÚnico e solicitação de auxílio transporte.',
       DATE_SUB(CURDATE(), INTERVAL 38 DAY), u.id, 'CONCLUIDO', DATE_SUB(CURDATE(), INTERVAL 40 DAY)
  FROM atendimentos a
  JOIN estudantes e ON e.id = a.estudante_id
  JOIN destinos_encaminhamento d ON d.nome = 'CRAS'
  JOIN usuarios u ON u.email = 'ricardo@escola.test'
 WHERE e.matricula = '9999-00001' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 48 DAY);

-- Atendimento 3 -> Coordenação pedagógica · ABERTO com prazo passado (aparece como VENCIDO)
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status)
SELECT a.id, d.id, 'Plano de reforço escolar em Matemática e Português.',
       DATE_SUB(CURDATE(), INTERVAL 25 DAY), u.id, 'ABERTO'
  FROM atendimentos a
  JOIN estudantes e ON e.id = a.estudante_id
  JOIN destinos_encaminhamento d ON d.nome = 'Coordenação pedagógica'
  JOIN usuarios u ON u.email = 'marina@escola.test'
 WHERE e.matricula = '9999-00001' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 40 DAY);

-- Atendimento 4 -> Conselho Tutelar · CANCELADO
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status)
SELECT a.id, d.id, 'Cancelado: a visita não identificou violação de direitos.',
       DATE_SUB(CURDATE(), INTERVAL 20 DAY), u.id, 'CANCELADO'
  FROM atendimentos a
  JOIN estudantes e ON e.id = a.estudante_id
  JOIN destinos_encaminhamento d ON d.nome = 'Conselho Tutelar'
  JOIN usuarios u ON u.email = 'ricardo@escola.test'
 WHERE e.matricula = '9999-00001' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 33 DAY);

-- Atendimento 6 -> UBS / Rede de saúde · ABERTO dentro do prazo
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status)
SELECT a.id, d.id, 'Consulta oftalmológica e avaliação do sono.',
       DATE_ADD(CURDATE(), INTERVAL 10 DAY), u.id, 'ABERTO'
  FROM atendimentos a
  JOIN estudantes e ON e.id = a.estudante_id
  JOIN destinos_encaminhamento d ON d.nome = 'UBS / Rede de saúde'
  JOIN usuarios u ON u.email = 'ricardo@escola.test'
 WHERE e.matricula = '9999-00001' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 18 DAY);

-- Atendimento 7 -> CAPS (ABERTO) e Coordenação pedagógica (ABERTO): um atendimento, dois encaminhamentos
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status)
SELECT a.id, d.id, 'Avaliação para acompanhamento psicológico especializado.',
       DATE_ADD(CURDATE(), INTERVAL 20 DAY), u.id, 'ABERTO'
  FROM atendimentos a
  JOIN estudantes e ON e.id = a.estudante_id
  JOIN destinos_encaminhamento d ON d.nome = 'CAPS'
  JOIN usuarios u ON u.email = 'marina@escola.test'
 WHERE e.matricula = '9999-00001' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 10 DAY);

INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status)
SELECT a.id, d.id, 'Acompanhar participação em sala e informar a psicóloga.',
       DATE_ADD(CURDATE(), INTERVAL 5 DAY), u.id, 'ABERTO'
  FROM atendimentos a
  JOIN estudantes e ON e.id = a.estudante_id
  JOIN destinos_encaminhamento d ON d.nome = 'Coordenação pedagógica'
  JOIN usuarios u ON u.email = 'marina@escola.test'
 WHERE e.matricula = '9999-00001' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 10 DAY);

-- Auditoria: quem criou e quem abriu o prontuário
INSERT INTO log_acessos (usuario_id, acao, estudante_id)
SELECT u.id, 'CRIOU', e.id FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '9999-00001';
INSERT INTO log_acessos (usuario_id, acao, estudante_id)
SELECT u.id, 'VISUALIZOU', e.id FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '9999-00001';

-- =====================================================
-- ALUNO 2: Lucas Ferreira Lima (EM TRIAGEM, só o acolhimento)
-- Serve para testar: registrar o 1º atendimento muda o status para
-- "Em acompanhamento".
-- =====================================================
INSERT INTO estudantes
  (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Lucas Ferreira Lima', '9999-00002', '2012-05-20', t.id,
       'Mora com o pai e uma irmã mais velha.', NULL, 'TRIAGEM', u.id, DATE_SUB(NOW(), INTERVAL 4 DAY)
  FROM turmas t, usuarios u
 WHERE t.nome = '9º B' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'ricardo@escola.test';

INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Paulo Lima', 'pai', '(31) 97766-5544', 1 FROM estudantes e WHERE e.matricula = '9999-00002';

INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 4 DAY),
       'Colegas relatam apelidos ofensivos dirigidos ao estudante no intervalo. Ele evita o refeitório.',
       DATE_SUB(NOW(), INTERVAL 4 DAY)
  FROM estudantes e, usuarios u
 WHERE e.matricula = '9999-00002' AND u.email = 'ricardo@escola.test';

INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id
  FROM acolhimentos a
  JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome = 'Bullying, discriminação e conflitos interpessoais'
 WHERE e.matricula = '9999-00002';
