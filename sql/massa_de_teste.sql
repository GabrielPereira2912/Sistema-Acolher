-- =====================================================
-- MASSA DE DADOS DE TESTE — cobre todas as telas e regras do sistema
-- Ordem de importação (phpMyAdmin): banco_acolher_v3.sql -> dados_teste.sql -> este arquivo.
-- Para repetir: rode limpar_massa_de_teste.sql antes. O roteiro está em LEIAME_massa_de_teste.md.
--
-- Tudo é FICTÍCIO. Matrículas começam com 8888-; e-mails extras terminam em @massa.test.
-- As datas são relativas a HOJE (CURDATE/NOW): "vencido" e "no mês" continuam valendo em qualquer dia.
-- Senha de todos os usuários de teste: teste123
-- =====================================================
USE acolher;

-- ---------- Usuários extras (senha teste123) ----------
INSERT INTO usuarios (nome, email, senha_hash, perfil, registro_classe, ativo, criado_em) VALUES ('Camila Torres', 'camila.torres@massa.test', '$2y$10$3jbHeboi6xuMKKx99cSWvO/3AIABGsEkm2AfwLP1zax6VbZulm85q', 'PSICOLOGO', 'CRP 06/23456', 1, DATE_SUB(NOW(), INTERVAL 420 DAY));
INSERT INTO usuarios (nome, email, senha_hash, perfil, registro_classe, ativo, criado_em) VALUES ('Paulo Mendes', 'paulo.mendes@massa.test', '$2y$10$3jbHeboi6xuMKKx99cSWvO/3AIABGsEkm2AfwLP1zax6VbZulm85q', 'ASSISTENTE_SOCIAL', 'CRESS 23456', 1, DATE_SUB(NOW(), INTERVAL 420 DAY));
INSERT INTO usuarios (nome, email, senha_hash, perfil, registro_classe, ativo, criado_em) VALUES ('Fernanda Lima', 'fernanda.lima@massa.test', '$2y$10$3jbHeboi6xuMKKx99cSWvO/3AIABGsEkm2AfwLP1zax6VbZulm85q', 'PSICOLOGO', 'CRP 06/34567', 1, DATE_SUB(NOW(), INTERVAL 420 DAY));
INSERT INTO usuarios (nome, email, senha_hash, perfil, registro_classe, ativo, criado_em) VALUES ('Helena Rocha', 'helena.rocha@massa.test', '$2y$10$3jbHeboi6xuMKKx99cSWvO/3AIABGsEkm2AfwLP1zax6VbZulm85q', 'ASSISTENTE_SOCIAL', 'CRESS 34567', 0, DATE_SUB(NOW(), INTERVAL 420 DAY));
INSERT INTO usuarios (nome, email, senha_hash, perfil, registro_classe, ativo, criado_em) VALUES ('Coordenação Geral', 'coordenacao@massa.test', '$2y$10$3jbHeboi6xuMKKx99cSWvO/3AIABGsEkm2AfwLP1zax6VbZulm85q', 'ADMIN', NULL, 1, DATE_SUB(NOW(), INTERVAL 420 DAY));

-- ---------- Turmas extras (inclui uma turma do ANO ANTERIOR) ----------
INSERT INTO turmas (nome, turno, etapa_ensino, ano_letivo) VALUES ('6º B', 'TARDE', 'FUNDAMENTAL_II', YEAR(CURDATE()));
INSERT INTO turmas (nome, turno, etapa_ensino, ano_letivo) VALUES ('3º EM C', 'NOITE', 'ENSINO_MEDIO', YEAR(CURDATE()));
INSERT INTO turmas (nome, turno, etapa_ensino, ano_letivo) VALUES ('3º A', 'MANHA', 'FUNDAMENTAL_I', YEAR(CURDATE()));
INSERT INTO turmas (nome, turno, etapa_ensino, ano_letivo) VALUES ('9º A', 'MANHA', 'FUNDAMENTAL_II', YEAR(CURDATE()) - 1);

-- ===== Ana Clara Ferreira Lima (EM_ACOMPANHAMENTO) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Ana Clara Ferreira Lima', '8888-00001', '2013-05-20', t.id, 'Mora com a mãe e o pai. Dois irmãos: um mais velho e um mais novo.', 'Beneficiário(a) de programa de transferência de renda. Utiliza transporte escolar.', 'EM_ACOMPANHAMENTO', u.id, DATE_SUB(NOW(), INTERVAL 120 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '7º A' AND t.turno = 'MANHA' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'marina@escola.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Patrícia Ferreira Lima', 'mãe', '(31) 98123-4501', 1 FROM estudantes e WHERE e.matricula = '8888-00001';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Roberto Lima', 'pai', '(31) 97123-4502', 0 FROM estudantes e WHERE e.matricula = '8888-00001';
INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 110 DAY), 'Encaminhamento da professora regente: Ana tem dificuldade de acompanhar os conteúdos e baixo rendimento nas últimas avaliações. Diz que "não entende a explicação" e evita pedir ajuda. Família comunicada.', NULL, DATE_SUB(NOW(), INTERVAL 110 DAY)
  FROM estudantes e, usuarios u WHERE e.matricula = '8888-00001' AND u.email = 'marina@escola.test';
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN ('Dificuldades de aprendizagem e adaptação escolar', 'Faltas frequentes, risco de evasão e abandono escolar', 'Sofrimento emocional e dificuldades comportamentais') WHERE e.matricula = '8888-00001';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 100 DAY), 'INDIVIDUAL', ta.id, 'Ana procurou a equipe espontaneamente após a aula. Recebeu escuta e orientação sobre como pedir ajuda aos professores.', DATE_SUB(NOW(), INTERVAL 100 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00001' AND u.email = 'marina@escola.test' AND ta.nome = 'Escuta / acolhimento';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 90 DAY), 'TELEFONE', ta.id, 'Contato telefônico com a responsável para devolutiva do acompanhamento e alinhamento de combinados em casa. Família receptiva.', DATE_SUB(NOW(), INTERVAL 90 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00001' AND u.email = 'ricardo@escola.test' AND ta.nome = 'Contato com a família';
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Inclusão da família nos serviços de assistência social e revisão do cadastro.', DATE_SUB(CURDATE(), INTERVAL 62 DAY), u.id, 'CONCLUIDO', DATE_SUB(CURDATE(), INTERVAL 65 DAY)
  FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id JOIN tipos_acao ta ON ta.id = a.tipo_acao_id,
       destinos_encaminhamento d, usuarios u
 WHERE e.matricula = '8888-00001' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 90 DAY) AND ta.nome = 'Contato com a família'
   AND d.nome = 'CRAS' AND u.email = 'ricardo@escola.test';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 75 DAY), 'PROFESSORES', ta.id, 'Conselho de classe com foco em Ana. Registradas observações sobre participação, frequência e relacionamento com colegas.', DATE_SUB(NOW(), INTERVAL 75 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00001' AND u.email = 'marina@escola.test' AND ta.nome = 'Reunião com professores';
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Solicitado plano de acompanhamento pedagógico e retorno da coordenação.', DATE_SUB(CURDATE(), INTERVAL 45 DAY), u.id, 'CONCLUIDO', DATE_SUB(CURDATE(), INTERVAL 50 DAY)
  FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id JOIN tipos_acao ta ON ta.id = a.tipo_acao_id,
       destinos_encaminhamento d, usuarios u
 WHERE e.matricula = '8888-00001' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 75 DAY) AND ta.nome = 'Reunião com professores'
   AND d.nome = 'Coordenação pedagógica' AND u.email = 'marina@escola.test';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 50 DAY), 'INDIVIDUAL', ta.id, 'Conversa orientativa sobre projeto de vida e escolhas após o ensino regular. Ana demonstrou interesse por cursos técnicos.', DATE_SUB(NOW(), INTERVAL 50 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00001' AND u.email = 'marina@escola.test' AND ta.nome = 'Orientação ao estudante';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 30 DAY), 'FAMILIA', ta.id, 'Visita realizada em conjunto com a equipe da rede para articular o atendimento da família no CRAS.', DATE_SUB(NOW(), INTERVAL 30 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00001' AND u.email = 'ricardo@escola.test' AND ta.nome = 'Visita domiciliar';
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Consulta de rotina e avaliação de saúde na unidade básica.', DATE_SUB(CURDATE(), INTERVAL 8 DAY), u.id, 'ABERTO', NULL
  FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id JOIN tipos_acao ta ON ta.id = a.tipo_acao_id,
       destinos_encaminhamento d, usuarios u
 WHERE e.matricula = '8888-00001' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 30 DAY) AND ta.nome = 'Visita domiciliar'
   AND d.nome = 'UBS / Rede de saúde' AND u.email = 'ricardo@escola.test';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 12 DAY), 'GRUPO', ta.id, 'Reavaliação do plano de acompanhamento: observados avanços em frequência e participação. Mantido acompanhamento quinzenal.', DATE_SUB(NOW(), INTERVAL 12 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00001' AND u.email = 'marina@escola.test' AND ta.nome = 'Reavaliação';
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Avaliação em serviço de saúde mental da rede, com ciência e consentimento da família.', DATE_ADD(CURDATE(), INTERVAL 15 DAY), u.id, 'ABERTO', NULL
  FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id JOIN tipos_acao ta ON ta.id = a.tipo_acao_id,
       destinos_encaminhamento d, usuarios u
 WHERE e.matricula = '8888-00001' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 12 DAY) AND ta.nome = 'Reavaliação'
   AND d.nome = 'CAPS' AND u.email = 'marina@escola.test';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 2 DAY), 'INDIVIDUAL', ta.id, 'Conversa acolhedora na sala de atendimento. Ana demonstrou mais abertura que no encontro anterior e relatou melhora no sono.', DATE_SUB(NOW(), INTERVAL 2 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00001' AND u.email = 'marina@escola.test' AND ta.nome = 'Escuta / acolhimento';

-- ===== Pedro Henrique Souza Matos (EM_ACOMPANHAMENTO) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Pedro Henrique Souza Matos', '8888-00002', '2011-09-02', t.id, 'Mora com a mãe e a avó materna. O pai não convive com a família.', NULL, 'EM_ACOMPANHAMENTO', u.id, DATE_SUB(NOW(), INTERVAL 90 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '9º B' AND t.turno = 'TARDE' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'ricardo@escola.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Cristina Souza Matos', 'mãe', '(31) 98234-5601', 1 FROM estudantes e WHERE e.matricula = '8888-00002';
INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 85 DAY), 'A coordenação identificou faltas seguidas sem justificativa no último mês. Em conversa, Pedro falou de desmotivação e dificuldade para acordar cedo. Família contatada por telefone.', NULL, DATE_SUB(NOW(), INTERVAL 85 DAY)
  FROM estudantes e, usuarios u WHERE e.matricula = '8888-00002' AND u.email = 'ricardo@escola.test';
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN ('Faltas frequentes, risco de evasão e abandono escolar', 'Conflitos familiares e dificuldades de convivência') WHERE e.matricula = '8888-00002';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 80 DAY), 'TELEFONE', ta.id, 'Ligação para confirmar presença em reunião e reforçar a importância da frequência. Responsável relatou dificuldade de horário.', DATE_SUB(NOW(), INTERVAL 80 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00002' AND u.email = 'ricardo@escola.test' AND ta.nome = 'Contato com a família';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 60 DAY), 'INDIVIDUAL', ta.id, 'Orientação sobre frequência: combinado aviso prévio à escola em caso de falta e acompanhamento do diário.', DATE_SUB(NOW(), INTERVAL 60 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00002' AND u.email = 'ricardo@escola.test' AND ta.nome = 'Orientação ao estudante';
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Inclusão da família nos serviços de assistência social e revisão do cadastro.', DATE_SUB(CURDATE(), INTERVAL 20 DAY), u.id, 'ABERTO', NULL
  FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id JOIN tipos_acao ta ON ta.id = a.tipo_acao_id,
       destinos_encaminhamento d, usuarios u
 WHERE e.matricula = '8888-00002' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 60 DAY) AND ta.nome = 'Orientação ao estudante'
   AND d.nome = 'CRAS' AND u.email = 'ricardo@escola.test';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 35 DAY), 'PROFESSORES', ta.id, 'Reunião com os professores da turma para alinhar estratégias: atividades em dupla, retomada de conteúdos e devolutiva semanal.', DATE_SUB(NOW(), INTERVAL 35 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00002' AND u.email = 'camila.torres@massa.test' AND ta.nome = 'Reunião com professores';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 9 DAY), 'FAMILIA', ta.id, 'Reavaliação com Pedro e a família. Metas do período em grande parte atingidas; definidas novas metas para o bimestre.', DATE_SUB(NOW(), INTERVAL 9 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00002' AND u.email = 'ricardo@escola.test' AND ta.nome = 'Reavaliação';
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Solicitado plano de acompanhamento pedagógico e retorno da coordenação.', DATE_ADD(CURDATE(), INTERVAL 6 DAY), u.id, 'ABERTO', NULL
  FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id JOIN tipos_acao ta ON ta.id = a.tipo_acao_id,
       destinos_encaminhamento d, usuarios u
 WHERE e.matricula = '8888-00002' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 9 DAY) AND ta.nome = 'Reavaliação'
   AND d.nome = 'Coordenação pedagógica' AND u.email = 'ricardo@escola.test';

-- ===== Maria Eduarda Nogueira (EM_ACOMPANHAMENTO) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Maria Eduarda Nogueira', '8888-00003', '2010-11-30', t.id, 'Mora com o pai e a madrasta. Passa os fins de semana com a mãe (guarda compartilhada).', 'Usa óculos; senta nas primeiras carteiras.', 'EM_ACOMPANHAMENTO', u.id, DATE_SUB(NOW(), INTERVAL 70 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '1º EM A' AND t.turno = 'MANHA' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'camila.torres@massa.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Sandra Nogueira', 'mãe', '(31) 99345-6701', 1 FROM estudantes e WHERE e.matricula = '8888-00003';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Paulo Nogueira', 'pai', '(31) 98345-6702', 0 FROM estudantes e WHERE e.matricula = '8888-00003';
INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 65 DAY), 'Maria apresenta choro frequente em sala e isolamento nos intervalos desde a perda de um familiar. Procurou a equipe por conta própria.', NULL, DATE_SUB(NOW(), INTERVAL 65 DAY)
  FROM estudantes e, usuarios u WHERE e.matricula = '8888-00003' AND u.email = 'camila.torres@massa.test';
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN ('Sofrimento emocional e dificuldades comportamentais', 'Bullying, discriminação e conflitos interpessoais') WHERE e.matricula = '8888-00003';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 60 DAY), 'INDIVIDUAL', ta.id, 'Escuta livre sobre os acontecimentos da semana. Maria citou um conflito pontual com colegas, já resolvido com mediação.', DATE_SUB(NOW(), INTERVAL 60 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00003' AND u.email = 'camila.torres@massa.test' AND ta.nome = 'Escuta / acolhimento';
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Avaliação em serviço de saúde mental da rede, com ciência e consentimento da família.', DATE_SUB(CURDATE(), INTERVAL 30 DAY), u.id, 'ABERTO', NULL
  FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id JOIN tipos_acao ta ON ta.id = a.tipo_acao_id,
       destinos_encaminhamento d, usuarios u
 WHERE e.matricula = '8888-00003' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 60 DAY) AND ta.nome = 'Escuta / acolhimento'
   AND d.nome = 'CAPS' AND u.email = 'camila.torres@massa.test';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 45 DAY), 'INDIVIDUAL', ta.id, 'Maria procurou a equipe espontaneamente após a aula. Recebeu escuta e orientação sobre como pedir ajuda aos professores.', DATE_SUB(NOW(), INTERVAL 45 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00003' AND u.email = 'camila.torres@massa.test' AND ta.nome = 'Escuta / acolhimento';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 30 DAY), 'INDIVIDUAL', ta.id, 'Orientação sobre organização dos estudos e rotina de sono. Maria montou com o(a) profissional um quadro semanal de atividades.', DATE_SUB(NOW(), INTERVAL 30 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00003' AND u.email = 'camila.torres@massa.test' AND ta.nome = 'Orientação ao estudante';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 14 DAY), 'GRUPO', ta.id, 'Conversa acolhedora na sala de atendimento. Maria demonstrou mais abertura que no encontro anterior e relatou melhora no sono.', DATE_SUB(NOW(), INTERVAL 14 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00003' AND u.email = 'camila.torres@massa.test' AND ta.nome = 'Escuta / acolhimento';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_ADD(CURDATE(), INTERVAL 0 DAY), 'INDIVIDUAL', ta.id, 'Revisão dos encaminhamentos em aberto e atualização do plano. Pendências registradas para a próxima reunião de equipe.', DATE_SUB(NOW(), INTERVAL 0 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00003' AND u.email = 'camila.torres@massa.test' AND ta.nome = 'Reavaliação';

-- ===== Gabriel Santos Oliveira (EM_ACOMPANHAMENTO) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Gabriel Santos Oliveira', '8888-00004', '2015-02-11', t.id, 'Mora com os avós paternos, que são os responsáveis legais.', 'Alimentação reforçada na escola. Material escolar fornecido pela coordenação.', 'EM_ACOMPANHAMENTO', u.id, DATE_SUB(NOW(), INTERVAL 50 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '5º C' AND t.turno = 'MANHA' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'paulo.mendes@massa.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Josiane Santos', 'mãe', '(31) 98456-7801', 1 FROM estudantes e WHERE e.matricula = '8888-00004';
INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 45 DAY), 'Encaminhamento da professora regente: Gabriel tem dificuldade de acompanhar os conteúdos e baixo rendimento nas últimas avaliações. Diz que "não entende a explicação" e evita pedir ajuda. Família comunicada.', NULL, DATE_SUB(NOW(), INTERVAL 45 DAY)
  FROM estudantes e, usuarios u WHERE e.matricula = '8888-00004' AND u.email = 'paulo.mendes@massa.test';
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN ('Dificuldades de aprendizagem e adaptação escolar') WHERE e.matricula = '8888-00004';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 40 DAY), 'FAMILIA', ta.id, 'A família atualizou endereço e telefones. Conversa sobre a rotina de Gabriel e a rede de apoio disponível.', DATE_SUB(NOW(), INTERVAL 40 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00004' AND u.email = 'paulo.mendes@massa.test' AND ta.nome = 'Contato com a família';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 22 DAY), 'TELEFONE', ta.id, 'Contato telefônico com a responsável para devolutiva do acompanhamento e alinhamento de combinados em casa. Família receptiva.', DATE_SUB(NOW(), INTERVAL 22 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00004' AND u.email = 'paulo.mendes@massa.test' AND ta.nome = 'Contato com a família';
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Consulta de rotina e avaliação de saúde na unidade básica.', DATE_ADD(CURDATE(), INTERVAL 0 DAY), u.id, 'ABERTO', NULL
  FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id JOIN tipos_acao ta ON ta.id = a.tipo_acao_id,
       destinos_encaminhamento d, usuarios u
 WHERE e.matricula = '8888-00004' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 22 DAY) AND ta.nome = 'Contato com a família'
   AND d.nome = 'UBS / Rede de saúde' AND u.email = 'paulo.mendes@massa.test';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 6 DAY), 'PROFESSORES', ta.id, 'Conselho de classe com foco em Gabriel. Registradas observações sobre participação, frequência e relacionamento com colegas.', DATE_SUB(NOW(), INTERVAL 6 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00004' AND u.email = 'marina@escola.test' AND ta.nome = 'Reunião com professores';
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Solicitado plano de acompanhamento pedagógico e retorno da coordenação.', DATE_ADD(CURDATE(), INTERVAL 20 DAY), u.id, 'ABERTO', NULL
  FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id JOIN tipos_acao ta ON ta.id = a.tipo_acao_id,
       destinos_encaminhamento d, usuarios u
 WHERE e.matricula = '8888-00004' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 6 DAY) AND ta.nome = 'Reunião com professores'
   AND d.nome = 'Coordenação pedagógica' AND u.email = 'marina@escola.test';

-- ===== Júlia Almeida Costa (EM_ACOMPANHAMENTO) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Júlia Almeida Costa', '8888-00005', '2013-08-08', t.id, 'Mora com a mãe e três irmãos. A mãe é a única provedora da casa.', 'Necessita de tempo adicional em avaliações (documento apresentado pela família).', 'EM_ACOMPANHAMENTO', u.id, DATE_SUB(NOW(), INTERVAL 200 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '7º A' AND t.turno = 'MANHA' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'marina@escola.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Fátima Almeida', 'mãe', '(31) 98567-8901', 1 FROM estudantes e WHERE e.matricula = '8888-00005';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Antônio Costa', 'pai', '(31) 97567-8902', 0 FROM estudantes e WHERE e.matricula = '8888-00005';
INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 190 DAY), 'A família procurou a escola preocupada com discussões frequentes em casa após a separação dos pais. Júlia demonstra tristeza ao falar do assunto e pediu para conversar.', NULL, DATE_SUB(NOW(), INTERVAL 190 DAY)
  FROM estudantes e, usuarios u WHERE e.matricula = '8888-00005' AND u.email = 'marina@escola.test';
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN ('Conflitos familiares e dificuldades de convivência', 'Sofrimento emocional e dificuldades comportamentais') WHERE e.matricula = '8888-00005';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 170 DAY), 'INDIVIDUAL', ta.id, 'Júlia procurou a equipe espontaneamente após a aula. Recebeu escuta e orientação sobre como pedir ajuda aos professores.', DATE_SUB(NOW(), INTERVAL 170 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00005' AND u.email = 'marina@escola.test' AND ta.nome = 'Escuta / acolhimento';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 140 DAY), 'TELEFONE', ta.id, 'Contato telefônico com a responsável para devolutiva do acompanhamento e alinhamento de combinados em casa. Família receptiva.', DATE_SUB(NOW(), INTERVAL 140 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00005' AND u.email = 'ricardo@escola.test' AND ta.nome = 'Contato com a família';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 100 DAY), 'INDIVIDUAL', ta.id, 'Orientação sobre convivência e comunicação respeitosa. Treinadas formas de pedir um tempo quando se sentir sobrecarregado(a).', DATE_SUB(NOW(), INTERVAL 100 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00005' AND u.email = 'marina@escola.test' AND ta.nome = 'Orientação ao estudante';
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Avaliação em serviço de saúde mental da rede, com ciência e consentimento da família.', DATE_SUB(CURDATE(), INTERVAL 70 DAY), u.id, 'CONCLUIDO', DATE_SUB(CURDATE(), INTERVAL 75 DAY)
  FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id JOIN tipos_acao ta ON ta.id = a.tipo_acao_id,
       destinos_encaminhamento d, usuarios u
 WHERE e.matricula = '8888-00005' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 100 DAY) AND ta.nome = 'Orientação ao estudante'
   AND d.nome = 'CAPS' AND u.email = 'marina@escola.test';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 60 DAY), 'TELEFONE', ta.id, 'Envio de relatório objetivo ao serviço de referência e confirmação de recebimento. Aguardando retorno.', DATE_SUB(NOW(), INTERVAL 60 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00005' AND u.email = 'ricardo@escola.test' AND ta.nome = 'Articulação com a rede';
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Família optou por não participar neste momento.', DATE_SUB(CURDATE(), INTERVAL 30 DAY), u.id, 'CANCELADO', NULL
  FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id JOIN tipos_acao ta ON ta.id = a.tipo_acao_id,
       destinos_encaminhamento d, usuarios u
 WHERE e.matricula = '8888-00005' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 60 DAY) AND ta.nome = 'Articulação com a rede'
   AND d.nome = 'CRAS' AND u.email = 'ricardo@escola.test';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 25 DAY), 'INDIVIDUAL', ta.id, 'Reavaliação ao final do período: situação estável. Recomendado encerramento do acompanhamento, com monitoramento pela coordenação.', DATE_SUB(NOW(), INTERVAL 25 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00005' AND u.email = 'marina@escola.test' AND ta.nome = 'Reavaliação';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 3 DAY), 'INDIVIDUAL', ta.id, 'Sessão de escuta individual. Júlia falou sobre a rotina escolar e os sentimentos em relação à turma. Combinado novo encontro.', DATE_SUB(NOW(), INTERVAL 3 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00005' AND u.email = 'marina@escola.test' AND ta.nome = 'Escuta / acolhimento';

-- ===== Lucas Gabriel Rocha Pinto (EM_ACOMPANHAMENTO) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Lucas Gabriel Rocha Pinto', '8888-00006', '2009-12-15', t.id, 'Mora com o pai, que trabalha em turnos noturnos; à noite fica sob os cuidados da tia.', 'Acompanhamento fonoaudiológico semanal fora da escola.', 'EM_ACOMPANHAMENTO', u.id, DATE_SUB(NOW(), INTERVAL 80 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '2º EM B' AND t.turno = 'TARDE' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'ricardo@escola.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Marta Rocha', 'tia (responsável legal)', '(31) 98678-9001', 1 FROM estudantes e WHERE e.matricula = '8888-00006';
INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 75 DAY), 'A coordenação identificou faltas seguidas sem justificativa no último mês. Em conversa, Lucas falou de desmotivação e dificuldade para acordar cedo. Família contatada por telefone.', 'Dificuldade para conciliar trabalho e estudos', DATE_SUB(NOW(), INTERVAL 75 DAY)
  FROM estudantes e, usuarios u WHERE e.matricula = '8888-00006' AND u.email = 'ricardo@escola.test';
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN ('Faltas frequentes, risco de evasão e abandono escolar', 'Sofrimento emocional e dificuldades comportamentais', 'Outras') WHERE e.matricula = '8888-00006';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 70 DAY), 'TELEFONE', ta.id, 'Reunião breve com a família na escola. Apresentadas as observações da equipe e discutidas estratégias de apoio em casa.', DATE_SUB(NOW(), INTERVAL 70 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00006' AND u.email = 'ricardo@escola.test' AND ta.nome = 'Contato com a família';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 50 DAY), 'INDIVIDUAL', ta.id, 'Conversa orientativa sobre projeto de vida e escolhas após o ensino regular. Lucas demonstrou interesse por cursos técnicos.', DATE_SUB(NOW(), INTERVAL 50 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00006' AND u.email = 'ricardo@escola.test' AND ta.nome = 'Orientação ao estudante';
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Solicitado plano de acompanhamento pedagógico e retorno da coordenação.', DATE_SUB(CURDATE(), INTERVAL 15 DAY), u.id, 'ABERTO', NULL
  FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id JOIN tipos_acao ta ON ta.id = a.tipo_acao_id,
       destinos_encaminhamento d, usuarios u
 WHERE e.matricula = '8888-00006' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 50 DAY) AND ta.nome = 'Orientação ao estudante'
   AND d.nome = 'Coordenação pedagógica' AND u.email = 'ricardo@escola.test';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 28 DAY), 'INDIVIDUAL', ta.id, 'Lucas procurou a equipe espontaneamente após a aula. Recebeu escuta e orientação sobre como pedir ajuda aos professores.', DATE_SUB(NOW(), INTERVAL 28 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00006' AND u.email = 'camila.torres@massa.test' AND ta.nome = 'Escuta / acolhimento';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 5 DAY), 'FAMILIA', ta.id, 'Visita à residência com autorização da família. Ambiente organizado e acolhedor; a família demonstrou abertura ao diálogo.', DATE_SUB(NOW(), INTERVAL 5 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00006' AND u.email = 'ricardo@escola.test' AND ta.nome = 'Visita domiciliar';
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Inclusão da família nos serviços de assistência social e revisão do cadastro.', DATE_ADD(CURDATE(), INTERVAL 25 DAY), u.id, 'ABERTO', NULL
  FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id JOIN tipos_acao ta ON ta.id = a.tipo_acao_id,
       destinos_encaminhamento d, usuarios u
 WHERE e.matricula = '8888-00006' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 5 DAY) AND ta.nome = 'Visita domiciliar'
   AND d.nome = 'CRAS' AND u.email = 'ricardo@escola.test';

-- ===== Isabela Martins Barbosa (EM_ACOMPANHAMENTO) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Isabela Martins Barbosa', '8888-00007', '2014-04-04', t.id, 'Mora com a mãe, o padrasto e um meio-irmão de 3 anos.', NULL, 'EM_ACOMPANHAMENTO', u.id, DATE_SUB(NOW(), INTERVAL 40 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '6º B' AND t.turno = 'TARDE' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'camila.torres@massa.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Luciana Martins', 'mãe', '(31) 98789-0101', 1 FROM estudantes e WHERE e.matricula = '8888-00007';
INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 35 DAY), 'Isabela relatou apelidos ofensivos e exclusão em grupos da turma. Houve conversa inicial com o(a) estudante e aviso à coordenação. Responsáveis informados.', NULL, DATE_SUB(NOW(), INTERVAL 35 DAY)
  FROM estudantes e, usuarios u WHERE e.matricula = '8888-00007' AND u.email = 'camila.torres@massa.test';
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN ('Bullying, discriminação e conflitos interpessoais') WHERE e.matricula = '8888-00007';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 30 DAY), 'INDIVIDUAL', ta.id, 'Isabela procurou a equipe espontaneamente após a aula. Recebeu escuta e orientação sobre como pedir ajuda aos professores.', DATE_SUB(NOW(), INTERVAL 30 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00007' AND u.email = 'camila.torres@massa.test' AND ta.nome = 'Escuta / acolhimento';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 16 DAY), 'GRUPO', ta.id, 'Orientação sobre organização dos estudos e rotina de sono. Isabela montou com o(a) profissional um quadro semanal de atividades.', DATE_SUB(NOW(), INTERVAL 16 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00007' AND u.email = 'camila.torres@massa.test' AND ta.nome = 'Orientação ao estudante';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 4 DAY), 'PROFESSORES', ta.id, 'Conselho de classe com foco em Isabela. Registradas observações sobre participação, frequência e relacionamento com colegas.', DATE_SUB(NOW(), INTERVAL 4 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00007' AND u.email = 'camila.torres@massa.test' AND ta.nome = 'Reunião com professores';
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Solicitado plano de acompanhamento pedagógico e retorno da coordenação.', DATE_ADD(CURDATE(), INTERVAL 10 DAY), u.id, 'ABERTO', NULL
  FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id JOIN tipos_acao ta ON ta.id = a.tipo_acao_id,
       destinos_encaminhamento d, usuarios u
 WHERE e.matricula = '8888-00007' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 4 DAY) AND ta.nome = 'Reunião com professores'
   AND d.nome = 'Coordenação pedagógica' AND u.email = 'camila.torres@massa.test';

-- ===== Mateus Ribeiro Araújo (EM_ACOMPANHAMENTO) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Mateus Ribeiro Araújo', '8888-00008', '2008-07-19', t.id, 'Mora com os avós paternos, que são os responsáveis legais.', 'Beneficiário(a) de programa de transferência de renda. Utiliza transporte escolar.', 'EM_ACOMPANHAMENTO', u.id, DATE_SUB(NOW(), INTERVAL 100 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '3º EM C' AND t.turno = 'NOITE' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'paulo.mendes@massa.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Raimunda Araújo', 'avó', '(31) 3222-3301', 1 FROM estudantes e WHERE e.matricula = '8888-00008';
INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 95 DAY), 'A coordenação identificou faltas seguidas sem justificativa no último mês. Em conversa, Mateus falou de desmotivação e dificuldade para acordar cedo. Família contatada por telefone.', NULL, DATE_SUB(NOW(), INTERVAL 95 DAY)
  FROM estudantes e, usuarios u WHERE e.matricula = '8888-00008' AND u.email = 'paulo.mendes@massa.test';
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN ('Faltas frequentes, risco de evasão e abandono escolar', 'Dificuldades de aprendizagem e adaptação escolar') WHERE e.matricula = '8888-00008';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 88 DAY), 'TELEFONE', ta.id, 'Reunião breve com a família na escola. Apresentadas as observações da equipe e discutidas estratégias de apoio em casa.', DATE_SUB(NOW(), INTERVAL 88 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00008' AND u.email = 'paulo.mendes@massa.test' AND ta.nome = 'Contato com a família';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 70 DAY), 'FAMILIA', ta.id, 'Visita à casa do responsável legal. Conversa sobre rotina, alimentação e acompanhamento escolar.', DATE_SUB(NOW(), INTERVAL 70 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00008' AND u.email = 'paulo.mendes@massa.test' AND ta.nome = 'Visita domiciliar';
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Inclusão da família nos serviços de assistência social e revisão do cadastro.', DATE_SUB(CURDATE(), INTERVAL 40 DAY), u.id, 'CONCLUIDO', DATE_SUB(CURDATE(), INTERVAL 44 DAY)
  FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id JOIN tipos_acao ta ON ta.id = a.tipo_acao_id,
       destinos_encaminhamento d, usuarios u
 WHERE e.matricula = '8888-00008' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 70 DAY) AND ta.nome = 'Visita domiciliar'
   AND d.nome = 'CRAS' AND u.email = 'paulo.mendes@massa.test';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 40 DAY), 'INDIVIDUAL', ta.id, 'Orientação sobre frequência: combinado aviso prévio à escola em caso de falta e acompanhamento do diário.', DATE_SUB(NOW(), INTERVAL 40 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00008' AND u.email = 'paulo.mendes@massa.test' AND ta.nome = 'Orientação ao estudante';
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Consulta de rotina e avaliação de saúde na unidade básica.', DATE_SUB(CURDATE(), INTERVAL 12 DAY), u.id, 'ABERTO', NULL
  FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id JOIN tipos_acao ta ON ta.id = a.tipo_acao_id,
       destinos_encaminhamento d, usuarios u
 WHERE e.matricula = '8888-00008' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 40 DAY) AND ta.nome = 'Orientação ao estudante'
   AND d.nome = 'UBS / Rede de saúde' AND u.email = 'paulo.mendes@massa.test';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 11 DAY), 'INDIVIDUAL', ta.id, 'Reavaliação do plano de acompanhamento: observados avanços em frequência e participação. Mantido acompanhamento quinzenal.', DATE_SUB(NOW(), INTERVAL 11 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00008' AND u.email = 'paulo.mendes@massa.test' AND ta.nome = 'Reavaliação';

-- ===== Larissa Fernandes Teixeira (EM_ACOMPANHAMENTO) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Larissa Fernandes Teixeira', '8888-00009', '2011-03-27', t.id, 'Família numerosa (sete pessoas na mesma casa), incluindo primos e tios.', NULL, 'EM_ACOMPANHAMENTO', u.id, DATE_SUB(NOW(), INTERVAL 55 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '9º B' AND t.turno = 'TARDE' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'marina@escola.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Simone Fernandes', 'mãe', '(31) 98890-1201', 1 FROM estudantes e WHERE e.matricula = '8888-00009';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Carlos Teixeira', 'pai', '(31) 98890-1202', 0 FROM estudantes e WHERE e.matricula = '8888-00009';
INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 50 DAY), 'Professores observaram retraimento e um relato preocupante sobre a situação em casa. Realizada escuta cuidadosa, sem induzir respostas. O caso será discutido com a equipe para definir os encaminhamentos necessários.', NULL, DATE_SUB(NOW(), INTERVAL 50 DAY)
  FROM estudantes e, usuarios u WHERE e.matricula = '8888-00009' AND u.email = 'marina@escola.test';
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN ('Violência, negligência ou suspeita de violação de direitos', 'Sofrimento emocional e dificuldades comportamentais') WHERE e.matricula = '8888-00009';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 45 DAY), 'INDIVIDUAL', ta.id, 'Escuta livre sobre os acontecimentos da semana. Larissa citou um conflito pontual com colegas, já resolvido com mediação.', DATE_SUB(NOW(), INTERVAL 45 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00009' AND u.email = 'marina@escola.test' AND ta.nome = 'Escuta / acolhimento';
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Comunicação formal à rede de proteção para avaliação do caso.', DATE_SUB(CURDATE(), INTERVAL 30 DAY), u.id, 'CONCLUIDO', DATE_SUB(CURDATE(), INTERVAL 33 DAY)
  FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id JOIN tipos_acao ta ON ta.id = a.tipo_acao_id,
       destinos_encaminhamento d, usuarios u
 WHERE e.matricula = '8888-00009' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 45 DAY) AND ta.nome = 'Escuta / acolhimento'
   AND d.nome = 'Conselho Tutelar' AND u.email = 'marina@escola.test';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 33 DAY), 'FAMILIA', ta.id, 'Visita realizada em conjunto com a equipe da rede para articular o atendimento da família no CRAS.', DATE_SUB(NOW(), INTERVAL 33 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00009' AND u.email = 'ricardo@escola.test' AND ta.nome = 'Visita domiciliar';
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Inclusão da família nos serviços de assistência social e revisão do cadastro.', DATE_SUB(CURDATE(), INTERVAL 5 DAY), u.id, 'ABERTO', NULL
  FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id JOIN tipos_acao ta ON ta.id = a.tipo_acao_id,
       destinos_encaminhamento d, usuarios u
 WHERE e.matricula = '8888-00009' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 33 DAY) AND ta.nome = 'Visita domiciliar'
   AND d.nome = 'CRAS' AND u.email = 'ricardo@escola.test';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 18 DAY), 'INDIVIDUAL', ta.id, 'Sessão de escuta individual. Larissa falou sobre a rotina escolar e os sentimentos em relação à turma. Combinado novo encontro.', DATE_SUB(NOW(), INTERVAL 18 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00009' AND u.email = 'marina@escola.test' AND ta.nome = 'Escuta / acolhimento';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'INDIVIDUAL', ta.id, 'Conversa acolhedora na sala de atendimento. Larissa demonstrou mais abertura que no encontro anterior e relatou melhora no sono.', DATE_SUB(NOW(), INTERVAL 1 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00009' AND u.email = 'marina@escola.test' AND ta.nome = 'Escuta / acolhimento';
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Avaliação em serviço de saúde mental da rede, com ciência e consentimento da família.', DATE_ADD(CURDATE(), INTERVAL 30 DAY), u.id, 'ABERTO', NULL
  FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id JOIN tipos_acao ta ON ta.id = a.tipo_acao_id,
       destinos_encaminhamento d, usuarios u
 WHERE e.matricula = '8888-00009' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 1 DAY) AND ta.nome = 'Escuta / acolhimento'
   AND d.nome = 'CAPS' AND u.email = 'marina@escola.test';

-- ===== João Pedro D'Ávila de Albuquerque e Silva Júnior (EM_ACOMPANHAMENTO) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'João Pedro D''Ávila de Albuquerque e Silva Júnior', '8888-00010', '2010-01-09', t.id, 'Mora com a mãe e a irmã mais velha, que trabalha e ajuda nas despesas.', 'Usa óculos; senta nas primeiras carteiras.', 'EM_ACOMPANHAMENTO', u.id, DATE_SUB(NOW(), INTERVAL 65 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '1º EM A' AND t.turno = 'MANHA' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'ricardo@escola.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Maria das Graças D''Ávila de Albuquerque e Silva', 'mãe', '(31) 98901-2301', 1 FROM estudantes e WHERE e.matricula = '8888-00010';
INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 60 DAY), 'Encaminhamento da professora regente: João tem dificuldade de acompanhar os conteúdos e baixo rendimento nas últimas avaliações. Diz que "não entende a explicação" e evita pedir ajuda. Família comunicada.', NULL, DATE_SUB(NOW(), INTERVAL 60 DAY)
  FROM estudantes e, usuarios u WHERE e.matricula = '8888-00010' AND u.email = 'ricardo@escola.test';
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN ('Dificuldades de aprendizagem e adaptação escolar', 'Bullying, discriminação e conflitos interpessoais') WHERE e.matricula = '8888-00010';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 55 DAY), 'INDIVIDUAL', ta.id, 'Sessão de escuta individual. João falou sobre a rotina escolar e os sentimentos em relação à turma. Combinado novo encontro.', DATE_SUB(NOW(), INTERVAL 55 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00010' AND u.email = 'ricardo@escola.test' AND ta.nome = 'Escuta / acolhimento';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 31 DAY), 'INDIVIDUAL', ta.id, 'Orientação sobre convivência e comunicação respeitosa. Treinadas formas de pedir um tempo quando se sentir sobrecarregado(a).', DATE_SUB(NOW(), INTERVAL 31 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00010' AND u.email = 'ricardo@escola.test' AND ta.nome = 'Orientação ao estudante';
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Solicitado plano de acompanhamento pedagógico e retorno da coordenação.', DATE_SUB(CURDATE(), INTERVAL 3 DAY), u.id, 'ABERTO', NULL
  FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id JOIN tipos_acao ta ON ta.id = a.tipo_acao_id,
       destinos_encaminhamento d, usuarios u
 WHERE e.matricula = '8888-00010' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 31 DAY) AND ta.nome = 'Orientação ao estudante'
   AND d.nome = 'Coordenação pedagógica' AND u.email = 'ricardo@escola.test';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 8 DAY), 'PROFESSORES', ta.id, 'Reunião com a coordenação pedagógica e dois professores. Definido plano de adaptação de avaliações e acompanhamento quinzenal.', DATE_SUB(NOW(), INTERVAL 8 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00010' AND u.email = 'ricardo@escola.test' AND ta.nome = 'Reunião com professores';

-- ===== Sofia Cardoso-Nascimento (EM_ACOMPANHAMENTO) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Sofia Cardoso-Nascimento', '8888-00011', '2017-10-21', t.id, 'Mora com a mãe e o pai. Dois irmãos: um mais velho e um mais novo.', NULL, 'EM_ACOMPANHAMENTO', u.id, DATE_SUB(NOW(), INTERVAL 30 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '3º A' AND t.turno = 'MANHA' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'camila.torres@massa.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Elaine Cardoso', 'mãe', '(31) 99012-3401', 1 FROM estudantes e WHERE e.matricula = '8888-00011';
INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 26 DAY), 'Solicitação da família para apoio na transição de escola e na adaptação à nova rotina.', 'Adaptação após mudança de cidade', DATE_SUB(NOW(), INTERVAL 26 DAY)
  FROM estudantes e, usuarios u WHERE e.matricula = '8888-00011' AND u.email = 'camila.torres@massa.test';
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN ('Outras') WHERE e.matricula = '8888-00011';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 20 DAY), 'FAMILIA', ta.id, 'Contato telefônico com a responsável para devolutiva do acompanhamento e alinhamento de combinados em casa. Família receptiva.', DATE_SUB(NOW(), INTERVAL 20 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00011' AND u.email = 'camila.torres@massa.test' AND ta.nome = 'Contato com a família';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 7 DAY), 'INDIVIDUAL', ta.id, 'Conversa acolhedora na sala de atendimento. Sofia demonstrou mais abertura que no encontro anterior e relatou melhora no sono.', DATE_SUB(NOW(), INTERVAL 7 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00011' AND u.email = 'camila.torres@massa.test' AND ta.nome = 'Escuta / acolhimento';

-- ===== Davi Lucca Moreira (EM_ACOMPANHAMENTO) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Davi Lucca Moreira', '8888-00012', '2013-06-13', t.id, 'Mora com a mãe e a avó materna. O pai não convive com a família.', 'Alimentação reforçada na escola. Material escolar fornecido pela coordenação.', 'EM_ACOMPANHAMENTO', u.id, DATE_SUB(NOW(), INTERVAL 45 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '7º A' AND t.turno = 'MANHA' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'paulo.mendes@massa.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Rosana Moreira', 'mãe', '(31) 98123-5501', 1 FROM estudantes e WHERE e.matricula = '8888-00012';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Jorge Moreira', 'pai', '(31) 98123-5502', 0 FROM estudantes e WHERE e.matricula = '8888-00012';
INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 40 DAY), 'A família procurou a escola preocupada com discussões frequentes em casa após a separação dos pais. Davi demonstra tristeza ao falar do assunto e pediu para conversar.', NULL, DATE_SUB(NOW(), INTERVAL 40 DAY)
  FROM estudantes e, usuarios u WHERE e.matricula = '8888-00012' AND u.email = 'paulo.mendes@massa.test';
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN ('Conflitos familiares e dificuldades de convivência') WHERE e.matricula = '8888-00012';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 35 DAY), 'TELEFONE', ta.id, 'Ligação para confirmar presença em reunião e reforçar a importância da frequência. Responsável relatou dificuldade de horário.', DATE_SUB(NOW(), INTERVAL 35 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00012' AND u.email = 'paulo.mendes@massa.test' AND ta.nome = 'Contato com a família';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 10 DAY), 'FAMILIA', ta.id, 'Visita realizada em conjunto com a equipe da rede para articular o atendimento da família no CRAS.', DATE_SUB(NOW(), INTERVAL 10 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00012' AND u.email = 'paulo.mendes@massa.test' AND ta.nome = 'Visita domiciliar';
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Inclusão da família nos serviços de assistência social e revisão do cadastro.', DATE_ADD(CURDATE(), INTERVAL 3 DAY), u.id, 'ABERTO', NULL
  FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id JOIN tipos_acao ta ON ta.id = a.tipo_acao_id,
       destinos_encaminhamento d, usuarios u
 WHERE e.matricula = '8888-00012' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 10 DAY) AND ta.nome = 'Visita domiciliar'
   AND d.nome = 'CRAS' AND u.email = 'paulo.mendes@massa.test';

-- ===== Helena Vasconcelos Prado (EM_ACOMPANHAMENTO) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Helena Vasconcelos Prado', '8888-00013', '2010-02-02', t.id, 'Mora com os pais e a irmã gêmea.', 'Tem asma; a família pediu atenção nas aulas de Educação Física.', 'EM_ACOMPANHAMENTO', u.id, DATE_SUB(NOW(), INTERVAL 300 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '9º A' AND t.turno = 'MANHA' AND t.ano_letivo = YEAR(CURDATE()) - 1 AND u.email = 'marina@escola.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Denise Vasconcelos', 'mãe', '(31) 98234-6601', 1 FROM estudantes e WHERE e.matricula = '8888-00013';
INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 290 DAY), 'A coordenação identificou faltas seguidas sem justificativa no último mês. Em conversa, Helena falou de desmotivação e dificuldade para acordar cedo. Família contatada por telefone.', NULL, DATE_SUB(NOW(), INTERVAL 290 DAY)
  FROM estudantes e, usuarios u WHERE e.matricula = '8888-00013' AND u.email = 'marina@escola.test';
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN ('Faltas frequentes, risco de evasão e abandono escolar', 'Conflitos familiares e dificuldades de convivência') WHERE e.matricula = '8888-00013';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 280 DAY), 'INDIVIDUAL', ta.id, 'Sessão de escuta individual. Helena falou sobre a rotina escolar e os sentimentos em relação à turma. Combinado novo encontro.', DATE_SUB(NOW(), INTERVAL 280 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00013' AND u.email = 'marina@escola.test' AND ta.nome = 'Escuta / acolhimento';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 200 DAY), 'TELEFONE', ta.id, 'Reunião breve com a família na escola. Apresentadas as observações da equipe e discutidas estratégias de apoio em casa.', DATE_SUB(NOW(), INTERVAL 200 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00013' AND u.email = 'marina@escola.test' AND ta.nome = 'Contato com a família';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 120 DAY), 'INDIVIDUAL', ta.id, 'Revisão dos encaminhamentos em aberto e atualização do plano. Pendências registradas para a próxima reunião de equipe.', DATE_SUB(NOW(), INTERVAL 120 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00013' AND u.email = 'marina@escola.test' AND ta.nome = 'Reavaliação';
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Solicitado plano de acompanhamento pedagógico e retorno da coordenação.', DATE_SUB(CURDATE(), INTERVAL 100 DAY), u.id, 'CONCLUIDO', DATE_SUB(CURDATE(), INTERVAL 105 DAY)
  FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id JOIN tipos_acao ta ON ta.id = a.tipo_acao_id,
       destinos_encaminhamento d, usuarios u
 WHERE e.matricula = '8888-00013' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 120 DAY) AND ta.nome = 'Reavaliação'
   AND d.nome = 'Coordenação pedagógica' AND u.email = 'marina@escola.test';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 15 DAY), 'INDIVIDUAL', ta.id, 'Orientação sobre frequência: combinado aviso prévio à escola em caso de falta e acompanhamento do diário.', DATE_SUB(NOW(), INTERVAL 15 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00013' AND u.email = 'marina@escola.test' AND ta.nome = 'Orientação ao estudante';

-- ===== Rafael O'Connor Tavares (EM_ACOMPANHAMENTO) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Rafael O''Connor Tavares', '8888-00014', '2009-05-05', t.id, 'Mora com o pai, que trabalha em turnos noturnos; à noite fica sob os cuidados da tia.', NULL, 'EM_ACOMPANHAMENTO', u.id, DATE_SUB(NOW(), INTERVAL 25 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '2º EM B' AND t.turno = 'TARDE' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'fernanda.lima@massa.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Kevin O''Connor', 'pai', '(31) 99345-7701', 1 FROM estudantes e WHERE e.matricula = '8888-00014';
INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 20 DAY), 'Rafael relatou apelidos ofensivos e exclusão em grupos da turma. Houve conversa inicial com o(a) estudante e aviso à coordenação. Responsáveis informados.', NULL, DATE_SUB(NOW(), INTERVAL 20 DAY)
  FROM estudantes e, usuarios u WHERE e.matricula = '8888-00014' AND u.email = 'fernanda.lima@massa.test';
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN ('Bullying, discriminação e conflitos interpessoais', 'Sofrimento emocional e dificuldades comportamentais') WHERE e.matricula = '8888-00014';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 14 DAY), 'INDIVIDUAL', ta.id, 'Rafael procurou a equipe espontaneamente após a aula. Recebeu escuta e orientação sobre como pedir ajuda aos professores.', DATE_SUB(NOW(), INTERVAL 14 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00014' AND u.email = 'fernanda.lima@massa.test' AND ta.nome = 'Escuta / acolhimento';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 3 DAY), 'INDIVIDUAL', ta.id, 'Orientação sobre organização dos estudos e rotina de sono. Rafael montou com o(a) profissional um quadro semanal de atividades.', DATE_SUB(NOW(), INTERVAL 3 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00014' AND u.email = 'fernanda.lima@massa.test' AND ta.nome = 'Orientação ao estudante';
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Avaliação em serviço de saúde mental da rede, com ciência e consentimento da família.', DATE_ADD(CURDATE(), INTERVAL 40 DAY), u.id, 'ABERTO', NULL
  FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id JOIN tipos_acao ta ON ta.id = a.tipo_acao_id,
       destinos_encaminhamento d, usuarios u
 WHERE e.matricula = '8888-00014' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 3 DAY) AND ta.nome = 'Orientação ao estudante'
   AND d.nome = 'CAPS' AND u.email = 'fernanda.lima@massa.test';

-- ===== Valentina Gomes Carvalho (EM_ACOMPANHAMENTO) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Valentina Gomes Carvalho', '8888-00015', '2014-09-18', t.id, 'Mora com os avós paternos, que são os responsáveis legais.', 'Beneficiário(a) de programa de transferência de renda. Utiliza transporte escolar.', 'EM_ACOMPANHAMENTO', u.id, DATE_SUB(NOW(), INTERVAL 400 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '6º B' AND t.turno = 'TARDE' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'helena.rocha@massa.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Ivone Gomes', 'avó', '(31) 3333-8801', 1 FROM estudantes e WHERE e.matricula = '8888-00015';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Tiago Carvalho', 'tio', '(31) 98456-8802', 0 FROM estudantes e WHERE e.matricula = '8888-00015';
INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 390 DAY), 'Encaminhamento da professora regente: Valentina tem dificuldade de acompanhar os conteúdos e baixo rendimento nas últimas avaliações. Diz que "não entende a explicação" e evita pedir ajuda. Família comunicada.', NULL, DATE_SUB(NOW(), INTERVAL 390 DAY)
  FROM estudantes e, usuarios u WHERE e.matricula = '8888-00015' AND u.email = 'helena.rocha@massa.test';
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN ('Dificuldades de aprendizagem e adaptação escolar', 'Conflitos familiares e dificuldades de convivência') WHERE e.matricula = '8888-00015';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 380 DAY), 'TELEFONE', ta.id, 'Contato telefônico com a responsável para devolutiva do acompanhamento e alinhamento de combinados em casa. Família receptiva.', DATE_SUB(NOW(), INTERVAL 380 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00015' AND u.email = 'helena.rocha@massa.test' AND ta.nome = 'Contato com a família';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 330 DAY), 'FAMILIA', ta.id, 'Visita domiciliar para entender os motivos das faltas. A família relatou dificuldade com transporte e sobrecarga de trabalho.', DATE_SUB(NOW(), INTERVAL 330 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00015' AND u.email = 'helena.rocha@massa.test' AND ta.nome = 'Visita domiciliar';
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Inclusão da família nos serviços de assistência social e revisão do cadastro.', DATE_SUB(CURDATE(), INTERVAL 300 DAY), u.id, 'CONCLUIDO', DATE_SUB(CURDATE(), INTERVAL 310 DAY)
  FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id JOIN tipos_acao ta ON ta.id = a.tipo_acao_id,
       destinos_encaminhamento d, usuarios u
 WHERE e.matricula = '8888-00015' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 330 DAY) AND ta.nome = 'Visita domiciliar'
   AND d.nome = 'CRAS' AND u.email = 'helena.rocha@massa.test';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 250 DAY), 'INDIVIDUAL', ta.id, 'Conversa orientativa sobre projeto de vida e escolhas após o ensino regular. Valentina demonstrou interesse por cursos técnicos.', DATE_SUB(NOW(), INTERVAL 250 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00015' AND u.email = 'helena.rocha@massa.test' AND ta.nome = 'Orientação ao estudante';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 20 DAY), 'INDIVIDUAL', ta.id, 'Reavaliação ao final do período: situação estável. Recomendado encerramento do acompanhamento, com monitoramento pela coordenação.', DATE_SUB(NOW(), INTERVAL 20 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00015' AND u.email = 'camila.torres@massa.test' AND ta.nome = 'Reavaliação';

-- ===== Enzo Gabriel Campos (EM_ACOMPANHAMENTO) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Enzo Gabriel Campos', '8888-00016', '2015-12-01', t.id, 'Mora com a mãe, o padrasto e um meio-irmão de 3 anos.', NULL, 'EM_ACOMPANHAMENTO', u.id, DATE_SUB(NOW(), INTERVAL 3 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '5º C' AND t.turno = 'MANHA' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'marina@escola.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Michele Campos', 'mãe', '(31) 98567-9901', 1 FROM estudantes e WHERE e.matricula = '8888-00016';
INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 'Encaminhamento da professora regente: Enzo tem dificuldade de acompanhar os conteúdos e baixo rendimento nas últimas avaliações. Diz que "não entende a explicação" e evita pedir ajuda. Família comunicada.', NULL, DATE_SUB(NOW(), INTERVAL 2 DAY)
  FROM estudantes e, usuarios u WHERE e.matricula = '8888-00016' AND u.email = 'marina@escola.test';
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN ('Dificuldades de aprendizagem e adaptação escolar', 'Bullying, discriminação e conflitos interpessoais') WHERE e.matricula = '8888-00016';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_ADD(CURDATE(), INTERVAL 0 DAY), 'INDIVIDUAL', ta.id, 'Enzo procurou a equipe espontaneamente após a aula. Recebeu escuta e orientação sobre como pedir ajuda aos professores.', DATE_SUB(NOW(), INTERVAL 0 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00016' AND u.email = 'marina@escola.test' AND ta.nome = 'Escuta / acolhimento';

-- ===== Ana Beatriz Santos Lima (EM_ACOMPANHAMENTO) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Ana Beatriz Santos Lima', '8888-00017', '2015-06-30', t.id, 'Mora com a mãe e três irmãos. A mãe é a única provedora da casa.', 'Usa óculos; senta nas primeiras carteiras.', 'EM_ACOMPANHAMENTO', u.id, DATE_SUB(NOW(), INTERVAL 35 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '5º C' AND t.turno = 'MANHA' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'paulo.mendes@massa.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Vera Santos', 'mãe', '(31) 98678-0011', 1 FROM estudantes e WHERE e.matricula = '8888-00017';
INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 30 DAY), 'Ana apresenta choro frequente em sala e isolamento nos intervalos desde a perda de um familiar. Procurou a equipe por conta própria.', NULL, DATE_SUB(NOW(), INTERVAL 30 DAY)
  FROM estudantes e, usuarios u WHERE e.matricula = '8888-00017' AND u.email = 'paulo.mendes@massa.test';
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN ('Sofrimento emocional e dificuldades comportamentais') WHERE e.matricula = '8888-00017';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 25 DAY), 'INDIVIDUAL', ta.id, 'Ana procurou a equipe espontaneamente após a aula. Recebeu escuta e orientação sobre como pedir ajuda aos professores.', DATE_SUB(NOW(), INTERVAL 25 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00017' AND u.email = 'paulo.mendes@massa.test' AND ta.nome = 'Escuta / acolhimento';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 9 DAY), 'GRUPO', ta.id, 'Orientação sobre organização dos estudos e rotina de sono. Ana montou com o(a) profissional um quadro semanal de atividades.', DATE_SUB(NOW(), INTERVAL 9 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00017' AND u.email = 'paulo.mendes@massa.test' AND ta.nome = 'Orientação ao estudante';

-- ===== Beatriz Lemos Freitas (TRIAGEM) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Beatriz Lemos Freitas', '8888-00018', '2011-10-10', t.id, 'Mora com o pai e a madrasta. Passa os fins de semana com a mãe (guarda compartilhada).', NULL, 'TRIAGEM', u.id, DATE_SUB(NOW(), INTERVAL 2 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '9º B' AND t.turno = 'TARDE' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'marina@escola.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Andréa Lemos', 'mãe', '(31) 98789-1021', 1 FROM estudantes e WHERE e.matricula = '8888-00018';
INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'Encaminhamento da professora regente: Beatriz tem dificuldade de acompanhar os conteúdos e baixo rendimento nas últimas avaliações. Diz que "não entende a explicação" e evita pedir ajuda. Família comunicada.', NULL, DATE_SUB(NOW(), INTERVAL 1 DAY)
  FROM estudantes e, usuarios u WHERE e.matricula = '8888-00018' AND u.email = 'marina@escola.test';
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN ('Dificuldades de aprendizagem e adaptação escolar', 'Faltas frequentes, risco de evasão e abandono escolar') WHERE e.matricula = '8888-00018';

-- ===== Thiago Barros Cunha (TRIAGEM) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Thiago Barros Cunha', '8888-00019', '2010-04-22', t.id, 'Família numerosa (sete pessoas na mesma casa), incluindo primos e tios.', 'Necessita de tempo adicional em avaliações (documento apresentado pela família).', 'TRIAGEM', u.id, DATE_SUB(NOW(), INTERVAL 15 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '1º EM A' AND t.turno = 'MANHA' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'camila.torres@massa.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Wellington Cunha', 'pai', '(31) 98890-1131', 1 FROM estudantes e WHERE e.matricula = '8888-00019';
INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 12 DAY), 'Thiago relatou apelidos ofensivos e exclusão em grupos da turma. Houve conversa inicial com o(a) estudante e aviso à coordenação. Responsáveis informados.', NULL, DATE_SUB(NOW(), INTERVAL 12 DAY)
  FROM estudantes e, usuarios u WHERE e.matricula = '8888-00019' AND u.email = 'camila.torres@massa.test';
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN ('Bullying, discriminação e conflitos interpessoais') WHERE e.matricula = '8888-00019';

-- ===== Alice Monteiro Rezende (TRIAGEM) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Alice Monteiro Rezende', '8888-00020', '2014-01-29', t.id, 'Mora com a mãe e a avó materna. O pai não convive com a família.', 'Alimentação reforçada na escola. Material escolar fornecido pela coordenação.', 'TRIAGEM', u.id, DATE_SUB(NOW(), INTERVAL 8 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '6º B' AND t.turno = 'TARDE' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'ricardo@escola.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Karla Monteiro', 'mãe', '(31) 98901-1241', 1 FROM estudantes e WHERE e.matricula = '8888-00020';
INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 5 DAY), 'A família procurou a escola preocupada com discussões frequentes em casa após a separação dos pais. Alice demonstra tristeza ao falar do assunto e pediu para conversar.', NULL, DATE_SUB(NOW(), INTERVAL 5 DAY)
  FROM estudantes e, usuarios u WHERE e.matricula = '8888-00020' AND u.email = 'ricardo@escola.test';
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN ('Conflitos familiares e dificuldades de convivência', 'Sofrimento emocional e dificuldades comportamentais') WHERE e.matricula = '8888-00020';

-- ===== Heitor Pacheco Dias (TRIAGEM) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Heitor Pacheco Dias', '8888-00021', '2017-07-07', t.id, 'Mora com a mãe e o pai. Dois irmãos: um mais velho e um mais novo.', NULL, 'TRIAGEM', u.id, DATE_SUB(NOW(), INTERVAL 20 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '3º A' AND t.turno = 'MANHA' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'paulo.mendes@massa.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Débora Pacheco', 'mãe', '(31) 99012-1351', 1 FROM estudantes e WHERE e.matricula = '8888-00021';
INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 18 DAY), 'Encaminhamento da professora regente: Heitor tem dificuldade de acompanhar os conteúdos e baixo rendimento nas últimas avaliações. Diz que "não entende a explicação" e evita pedir ajuda. Família comunicada.', NULL, DATE_SUB(NOW(), INTERVAL 18 DAY)
  FROM estudantes e, usuarios u WHERE e.matricula = '8888-00021' AND u.email = 'paulo.mendes@massa.test';
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN ('Dificuldades de aprendizagem e adaptação escolar') WHERE e.matricula = '8888-00021';

-- ===== Laura Siqueira Neves (TRIAGEM) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Laura Siqueira Neves', '8888-00022', '2013-11-11', t.id, 'Mora com a mãe, o padrasto e um meio-irmão de 3 anos.', 'Beneficiário(a) de programa de transferência de renda. Utiliza transporte escolar.', 'TRIAGEM', u.id, DATE_SUB(NOW(), INTERVAL 10 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '7º A' AND t.turno = 'MANHA' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'marina@escola.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Renata Siqueira', 'mãe', '(31) 98123-1461', 1 FROM estudantes e WHERE e.matricula = '8888-00022';
INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 7 DAY), 'Encaminhamento da professora regente: Laura tem dificuldade de acompanhar os conteúdos e baixo rendimento nas últimas avaliações. Diz que "não entende a explicação" e evita pedir ajuda. Família comunicada.', 'Mudanças frequentes de cuidadores nos últimos meses', DATE_SUB(NOW(), INTERVAL 7 DAY)
  FROM estudantes e, usuarios u WHERE e.matricula = '8888-00022' AND u.email = 'marina@escola.test';
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN ('Dificuldades de aprendizagem e adaptação escolar', 'Faltas frequentes, risco de evasão e abandono escolar', 'Conflitos familiares e dificuldades de convivência', 'Violência, negligência ou suspeita de violação de direitos', 'Bullying, discriminação e conflitos interpessoais', 'Sofrimento emocional e dificuldades comportamentais', 'Outras') WHERE e.matricula = '8888-00022';

-- ===== Bernardo Vieira Castro (TRIAGEM) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Bernardo Vieira Castro', '8888-00023', '2009-03-03', t.id, 'Mora com o pai, que trabalha em turnos noturnos; à noite fica sob os cuidados da tia.', NULL, 'TRIAGEM', u.id, DATE_SUB(NOW(), INTERVAL 6 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '2º EM B' AND t.turno = 'TARDE' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'ricardo@escola.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Silvana Vieira', 'mãe', '(31) 98234-1571', 1 FROM estudantes e WHERE e.matricula = '8888-00023';
INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 3 DAY), NULL, NULL, DATE_SUB(NOW(), INTERVAL 3 DAY)
  FROM estudantes e, usuarios u WHERE e.matricula = '8888-00023' AND u.email = 'ricardo@escola.test';
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN ('Violência, negligência ou suspeita de violação de direitos') WHERE e.matricula = '8888-00023';

-- ===== Manuela Correia Andrade (TRIAGEM) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Manuela Correia Andrade', '8888-00024', '2015-08-14', t.id, 'Mora com a mãe e a avó materna. O pai não convive com a família.', NULL, 'TRIAGEM', u.id, DATE_SUB(NOW(), INTERVAL 0 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '5º C' AND t.turno = 'MANHA' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'marina@escola.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Cláudia Correia', 'mãe', '(31) 99345-1681', 1 FROM estudantes e WHERE e.matricula = '8888-00024';

-- ===== Samuel Duarte Pires (TRIAGEM) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Samuel Duarte Pires', '8888-00025', '2013-02-25', t.id, 'Mora com o pai e a madrasta. Passa os fins de semana com a mãe (guarda compartilhada).', NULL, 'TRIAGEM', u.id, DATE_SUB(NOW(), INTERVAL 1 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '7º A' AND t.turno = 'MANHA' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'admin@escola.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Marcelo Pires', 'pai', '(31) 98456-1791', 1 FROM estudantes e WHERE e.matricula = '8888-00025';

-- ===== Yasmin Farias Quintela (TRIAGEM) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Yasmin Farias Quintela', '8888-00026', '2011-12-12', t.id, 'Mora com a mãe e três irmãos. A mãe é a única provedora da casa.', 'Usa óculos; senta nas primeiras carteiras.', 'TRIAGEM', u.id, DATE_SUB(NOW(), INTERVAL 5 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '9º B' AND t.turno = 'TARDE' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'admin@escola.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Gisele Farias', 'mãe', '(31) 98567-1801', 1 FROM estudantes e WHERE e.matricula = '8888-00026';

-- ===== Nicolas Brandão Ramos (TRIAGEM) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Nicolas Brandão Ramos', '8888-00027', '2010-06-06', t.id, 'Mora com a mãe, o padrasto e um meio-irmão de 3 anos.', NULL, 'TRIAGEM', u.id, DATE_SUB(NOW(), INTERVAL 12 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '1º EM A' AND t.turno = 'MANHA' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'camila.torres@massa.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Adriana Brandão', 'mãe', '(31) 98678-1911', 1 FROM estudantes e WHERE e.matricula = '8888-00027';

-- ===== Luísa Machado Veiga (TRIAGEM) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Luísa Machado Veiga', '8888-00028', '2008-09-09', t.id, 'Família numerosa (sete pessoas na mesma casa), incluindo primos e tios.', 'Necessita de tempo adicional em avaliações (documento apresentado pela família).', 'TRIAGEM', u.id, DATE_SUB(NOW(), INTERVAL 3 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '3º EM C' AND t.turno = 'NOITE' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'paulo.mendes@massa.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Eduardo Veiga', 'pai', '(31) 98789-2021', 1 FROM estudantes e WHERE e.matricula = '8888-00028';

-- ===== Gustavo Henrique Lacerda (TRIAGEM) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Gustavo Henrique Lacerda', '8888-00029', '2014-11-23', t.id, 'Mora com a mãe e o pai. Dois irmãos: um mais velho e um mais novo.', NULL, 'TRIAGEM', u.id, DATE_SUB(NOW(), INTERVAL 4 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '6º B' AND t.turno = 'TARDE' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'ricardo@escola.test';

-- ===== Clara Mendonça Reis (TRIAGEM) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Clara Mendonça Reis', '8888-00030', '2017-03-19', t.id, 'Mora com os pais e a irmã gêmea.', NULL, 'TRIAGEM', u.id, DATE_SUB(NOW(), INTERVAL 40 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '3º A' AND t.turno = 'MANHA' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'camila.torres@massa.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Patrícia Mendonça', 'mãe', '(31) 98890-2131', 1 FROM estudantes e WHERE e.matricula = '8888-00030';

-- ===== Felipe Andrade Sampaio (ENCERRADO) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Felipe Andrade Sampaio', '8888-00031', '2011-01-17', t.id, 'Mora com a mãe e a avó materna. O pai não convive com a família.', NULL, 'ENCERRADO', u.id, DATE_SUB(NOW(), INTERVAL 250 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '9º B' AND t.turno = 'TARDE' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'marina@escola.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Lúcia Andrade', 'mãe', '(31) 98901-2241', 1 FROM estudantes e WHERE e.matricula = '8888-00031';
INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 245 DAY), 'A coordenação identificou faltas seguidas sem justificativa no último mês. Em conversa, Felipe falou de desmotivação e dificuldade para acordar cedo. Família contatada por telefone.', NULL, DATE_SUB(NOW(), INTERVAL 245 DAY)
  FROM estudantes e, usuarios u WHERE e.matricula = '8888-00031' AND u.email = 'marina@escola.test';
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN ('Faltas frequentes, risco de evasão e abandono escolar') WHERE e.matricula = '8888-00031';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 230 DAY), 'INDIVIDUAL', ta.id, 'Escuta livre sobre os acontecimentos da semana. Felipe citou um conflito pontual com colegas, já resolvido com mediação.', DATE_SUB(NOW(), INTERVAL 230 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00031' AND u.email = 'marina@escola.test' AND ta.nome = 'Escuta / acolhimento';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 200 DAY), 'TELEFONE', ta.id, 'A família atualizou endereço e telefones. Conversa sobre a rotina de Felipe e a rede de apoio disponível.', DATE_SUB(NOW(), INTERVAL 200 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00031' AND u.email = 'ricardo@escola.test' AND ta.nome = 'Contato com a família';
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Inclusão da família nos serviços de assistência social e revisão do cadastro.', DATE_SUB(CURDATE(), INTERVAL 150 DAY), u.id, 'CONCLUIDO', DATE_SUB(CURDATE(), INTERVAL 155 DAY)
  FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id JOIN tipos_acao ta ON ta.id = a.tipo_acao_id,
       destinos_encaminhamento d, usuarios u
 WHERE e.matricula = '8888-00031' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 200 DAY) AND ta.nome = 'Contato com a família'
   AND d.nome = 'CRAS' AND u.email = 'ricardo@escola.test';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 150 DAY), 'INDIVIDUAL', ta.id, 'Orientação sobre organização dos estudos e rotina de sono. Felipe montou com o(a) profissional um quadro semanal de atividades.', DATE_SUB(NOW(), INTERVAL 150 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00031' AND u.email = 'marina@escola.test' AND ta.nome = 'Orientação ao estudante';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 90 DAY), 'INDIVIDUAL', ta.id, 'Reavaliação com Felipe e a família. Metas do período em grande parte atingidas; definidas novas metas para o bimestre.', DATE_SUB(NOW(), INTERVAL 90 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00031' AND u.email = 'marina@escola.test' AND ta.nome = 'Reavaliação';

-- ===== Camila Rangel Moura (ENCERRADO) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Camila Rangel Moura', '8888-00032', '2008-02-14', t.id, 'Mora com a mãe e três irmãos. A mãe é a única provedora da casa.', 'Beneficiário(a) de programa de transferência de renda. Utiliza transporte escolar.', 'ENCERRADO', u.id, DATE_SUB(NOW(), INTERVAL 180 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '3º EM C' AND t.turno = 'NOITE' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'paulo.mendes@massa.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Neide Rangel', 'mãe', '(31) 99012-2351', 1 FROM estudantes e WHERE e.matricula = '8888-00032';
INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 175 DAY), 'Encaminhamento da professora regente: Camila tem dificuldade de acompanhar os conteúdos e baixo rendimento nas últimas avaliações. Diz que "não entende a explicação" e evita pedir ajuda. Família comunicada.', NULL, DATE_SUB(NOW(), INTERVAL 175 DAY)
  FROM estudantes e, usuarios u WHERE e.matricula = '8888-00032' AND u.email = 'paulo.mendes@massa.test';
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN ('Dificuldades de aprendizagem e adaptação escolar', 'Faltas frequentes, risco de evasão e abandono escolar') WHERE e.matricula = '8888-00032';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 160 DAY), 'INDIVIDUAL', ta.id, 'Camila procurou a equipe espontaneamente após a aula. Recebeu escuta e orientação sobre como pedir ajuda aos professores.', DATE_SUB(NOW(), INTERVAL 160 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00032' AND u.email = 'paulo.mendes@massa.test' AND ta.nome = 'Escuta / acolhimento';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 120 DAY), 'FAMILIA', ta.id, 'Visita à residência com autorização da família. Ambiente organizado e acolhedor; a família demonstrou abertura ao diálogo.', DATE_SUB(NOW(), INTERVAL 120 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00032' AND u.email = 'paulo.mendes@massa.test' AND ta.nome = 'Visita domiciliar';
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Inclusão da família nos serviços de assistência social e revisão do cadastro.', DATE_SUB(CURDATE(), INTERVAL 90 DAY), u.id, 'CONCLUIDO', DATE_SUB(CURDATE(), INTERVAL 95 DAY)
  FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id JOIN tipos_acao ta ON ta.id = a.tipo_acao_id,
       destinos_encaminhamento d, usuarios u
 WHERE e.matricula = '8888-00032' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 120 DAY) AND ta.nome = 'Visita domiciliar'
   AND d.nome = 'CRAS' AND u.email = 'paulo.mendes@massa.test';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 60 DAY), 'INDIVIDUAL', ta.id, 'Reavaliação com Camila e a família. Metas do período em grande parte atingidas; definidas novas metas para o bimestre.', DATE_SUB(NOW(), INTERVAL 60 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00032' AND u.email = 'paulo.mendes@massa.test' AND ta.nome = 'Reavaliação';

-- ===== Vinícius Alves Pacheco (ENCERRADO) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Vinícius Alves Pacheco', '8888-00033', '2009-10-30', t.id, 'Mora com o pai, que trabalha em turnos noturnos; à noite fica sob os cuidados da tia.', NULL, 'ENCERRADO', u.id, DATE_SUB(NOW(), INTERVAL 220 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '2º EM B' AND t.turno = 'TARDE' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'ricardo@escola.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Gilberto Alves', 'pai', '(31) 98123-2461', 1 FROM estudantes e WHERE e.matricula = '8888-00033';
INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 215 DAY), 'Vinícius relatou apelidos ofensivos e exclusão em grupos da turma. Houve conversa inicial com o(a) estudante e aviso à coordenação. Responsáveis informados.', NULL, DATE_SUB(NOW(), INTERVAL 215 DAY)
  FROM estudantes e, usuarios u WHERE e.matricula = '8888-00033' AND u.email = 'ricardo@escola.test';
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN ('Bullying, discriminação e conflitos interpessoais') WHERE e.matricula = '8888-00033';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 200 DAY), 'INDIVIDUAL', ta.id, 'Escuta livre sobre os acontecimentos da semana. Vinícius citou um conflito pontual com colegas, já resolvido com mediação.', DATE_SUB(NOW(), INTERVAL 200 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00033' AND u.email = 'ricardo@escola.test' AND ta.nome = 'Escuta / acolhimento';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 100 DAY), 'GRUPO', ta.id, 'Orientação sobre frequência: combinado aviso prévio à escola em caso de falta e acompanhamento do diário.', DATE_SUB(NOW(), INTERVAL 100 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00033' AND u.email = 'ricardo@escola.test' AND ta.nome = 'Orientação ao estudante';
INSERT INTO encaminhamentos (atendimento_id, destino_id, observacao, prazo, responsavel_id, status, concluido_em)
SELECT a.id, d.id, 'Encaminhamento dispensado pela coordenação.', DATE_SUB(CURDATE(), INTERVAL 60 DAY), u.id, 'CANCELADO', NULL
  FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id JOIN tipos_acao ta ON ta.id = a.tipo_acao_id,
       destinos_encaminhamento d, usuarios u
 WHERE e.matricula = '8888-00033' AND a.data_atendimento = DATE_SUB(CURDATE(), INTERVAL 100 DAY) AND ta.nome = 'Orientação ao estudante'
   AND d.nome = 'Coordenação pedagógica' AND u.email = 'ricardo@escola.test';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'ASSISTENTE_SOCIAL', DATE_SUB(CURDATE(), INTERVAL 45 DAY), 'INDIVIDUAL', ta.id, 'Reavaliação do plano de acompanhamento: observados avanços em frequência e participação. Mantido acompanhamento quinzenal.', DATE_SUB(NOW(), INTERVAL 45 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00033' AND u.email = 'ricardo@escola.test' AND ta.nome = 'Reavaliação';

-- ===== Emanuele Paiva Lobo (ENCERRADO) =====
INSERT INTO estudantes (nome_completo, matricula, data_nascimento, turma_id, composicao_familiar, necessidades_apoio, status, criado_por, criado_em)
SELECT 'Emanuele Paiva Lobo', '8888-00034', '2013-04-04', t.id, 'Mora com os avós paternos, que são os responsáveis legais.', 'Tem asma; a família pediu atenção nas aulas de Educação Física.', 'ENCERRADO', u.id, DATE_SUB(NOW(), INTERVAL 140 DAY)
  FROM turmas t, usuarios u WHERE t.nome = '7º A' AND t.turno = 'MANHA' AND t.ano_letivo = YEAR(CURDATE()) AND u.email = 'camila.torres@massa.test';
INSERT INTO responsaveis (estudante_id, nome, parentesco, telefone, principal)
SELECT e.id, 'Tereza Paiva', 'avó', '(31) 98234-2571', 1 FROM estudantes e WHERE e.matricula = '8888-00034';
INSERT INTO acolhimentos (estudante_id, profissional_id, data_acolhimento, descricao_complementar, outras_especificacao, criado_em)
SELECT e.id, u.id, DATE_SUB(CURDATE(), INTERVAL 135 DAY), 'A família procurou a escola preocupada com discussões frequentes em casa após a separação dos pais. Emanuele demonstra tristeza ao falar do assunto e pediu para conversar.', NULL, DATE_SUB(NOW(), INTERVAL 135 DAY)
  FROM estudantes e, usuarios u WHERE e.matricula = '8888-00034' AND u.email = 'camila.torres@massa.test';
INSERT INTO acolhimento_demandas (acolhimento_id, categoria_id)
SELECT a.id, c.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
  JOIN categorias_demanda c ON c.nome IN ('Conflitos familiares e dificuldades de convivência', 'Sofrimento emocional e dificuldades comportamentais') WHERE e.matricula = '8888-00034';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 120 DAY), 'INDIVIDUAL', ta.id, 'Emanuele procurou a equipe espontaneamente após a aula. Recebeu escuta e orientação sobre como pedir ajuda aos professores.', DATE_SUB(NOW(), INTERVAL 120 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00034' AND u.email = 'camila.torres@massa.test' AND ta.nome = 'Escuta / acolhimento';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 70 DAY), 'TELEFONE', ta.id, 'Contato telefônico com a responsável para devolutiva do acompanhamento e alinhamento de combinados em casa. Família receptiva.', DATE_SUB(NOW(), INTERVAL 70 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00034' AND u.email = 'camila.torres@massa.test' AND ta.nome = 'Contato com a família';
INSERT INTO atendimentos (estudante_id, profissional_id, cargo_profissional, data_atendimento, modalidade, tipo_acao_id, descricao, criado_em)
SELECT e.id, u.id, 'PSICOLOGO', DATE_SUB(CURDATE(), INTERVAL 20 DAY), 'INDIVIDUAL', ta.id, 'Reavaliação com Emanuele e a família. Metas do período em grande parte atingidas; definidas novas metas para o bimestre.', DATE_SUB(NOW(), INTERVAL 20 DAY)
  FROM estudantes e, usuarios u, tipos_acao ta WHERE e.matricula = '8888-00034' AND u.email = 'camila.torres@massa.test' AND ta.nome = 'Reavaliação';

-- ---------- Log de acessos (LOGIN / VISUALIZOU / CRIOU / EDITOU) ----------
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'LOGIN', NULL, DATE_SUB(NOW(), INTERVAL 0 DAY) FROM usuarios u WHERE u.email = 'marina@escola.test';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'LOGIN', NULL, DATE_SUB(NOW(), INTERVAL 1 DAY) FROM usuarios u WHERE u.email = 'marina@escola.test';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'LOGIN', NULL, DATE_SUB(NOW(), INTERVAL 2 DAY) FROM usuarios u WHERE u.email = 'marina@escola.test';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'LOGIN', NULL, DATE_SUB(NOW(), INTERVAL 3 DAY) FROM usuarios u WHERE u.email = 'marina@escola.test';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'LOGIN', NULL, DATE_SUB(NOW(), INTERVAL 5 DAY) FROM usuarios u WHERE u.email = 'marina@escola.test';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'LOGIN', NULL, DATE_SUB(NOW(), INTERVAL 8 DAY) FROM usuarios u WHERE u.email = 'marina@escola.test';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'LOGIN', NULL, DATE_SUB(NOW(), INTERVAL 12 DAY) FROM usuarios u WHERE u.email = 'marina@escola.test';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'LOGIN', NULL, DATE_SUB(NOW(), INTERVAL 20 DAY) FROM usuarios u WHERE u.email = 'marina@escola.test';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'LOGIN', NULL, DATE_SUB(NOW(), INTERVAL 1 DAY) FROM usuarios u WHERE u.email = 'ricardo@escola.test';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'LOGIN', NULL, DATE_SUB(NOW(), INTERVAL 2 DAY) FROM usuarios u WHERE u.email = 'ricardo@escola.test';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'LOGIN', NULL, DATE_SUB(NOW(), INTERVAL 4 DAY) FROM usuarios u WHERE u.email = 'ricardo@escola.test';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'LOGIN', NULL, DATE_SUB(NOW(), INTERVAL 9 DAY) FROM usuarios u WHERE u.email = 'ricardo@escola.test';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'LOGIN', NULL, DATE_SUB(NOW(), INTERVAL 3 DAY) FROM usuarios u WHERE u.email = 'camila.torres@massa.test';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'LOGIN', NULL, DATE_SUB(NOW(), INTERVAL 9 DAY) FROM usuarios u WHERE u.email = 'camila.torres@massa.test';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'LOGIN', NULL, DATE_SUB(NOW(), INTERVAL 15 DAY) FROM usuarios u WHERE u.email = 'camila.torres@massa.test';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'LOGIN', NULL, DATE_SUB(NOW(), INTERVAL 5 DAY) FROM usuarios u WHERE u.email = 'paulo.mendes@massa.test';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'LOGIN', NULL, DATE_SUB(NOW(), INTERVAL 20 DAY) FROM usuarios u WHERE u.email = 'paulo.mendes@massa.test';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'LOGIN', NULL, DATE_SUB(NOW(), INTERVAL 150 DAY) FROM usuarios u WHERE u.email = 'helena.rocha@massa.test';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'LOGIN', NULL, DATE_SUB(NOW(), INTERVAL 200 DAY) FROM usuarios u WHERE u.email = 'helena.rocha@massa.test';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'LOGIN', NULL, DATE_SUB(NOW(), INTERVAL 350 DAY) FROM usuarios u WHERE u.email = 'helena.rocha@massa.test';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'LOGIN', NULL, DATE_SUB(NOW(), INTERVAL 6 DAY) FROM usuarios u WHERE u.email = 'coordenacao@massa.test';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'LOGIN', NULL, DATE_SUB(NOW(), INTERVAL 1 DAY) FROM usuarios u WHERE u.email = 'admin@escola.test';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'LOGIN', NULL, DATE_SUB(NOW(), INTERVAL 7 DAY) FROM usuarios u WHERE u.email = 'admin@escola.test';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 120 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00001';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 110 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00001';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 100 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00001';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 90 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00001';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 75 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00001';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 50 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00001';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 30 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00001';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 12 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00001';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 2 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00001';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 2 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00001';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 0 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00001';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 3 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00001';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 1 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00001';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 90 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00002';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 85 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00002';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 80 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00002';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 60 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00002';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 35 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00002';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 9 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00002';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 9 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00002';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 0 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00002';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 10 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00002';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 1 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00002';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 70 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00003';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 65 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00003';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 60 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00003';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 45 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00003';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 30 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00003';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 14 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00003';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 0 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00003';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 0 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00003';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 0 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00003';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 50 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00004';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 45 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00004';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 40 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00004';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 22 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00004';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 6 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00004';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 6 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00004';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 0 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00004';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 7 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00004';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 1 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00004';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 200 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00005';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 190 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00005';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 170 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00005';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 140 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00005';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 100 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00005';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 60 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00005';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 25 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00005';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 3 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00005';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 3 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00005';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 0 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00005';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 4 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00005';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 1 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00005';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 80 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00006';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 75 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00006';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 70 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00006';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 50 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00006';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 28 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00006';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 5 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00006';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 5 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00006';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 0 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00006';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 6 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00006';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 1 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00006';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 40 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00007';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 35 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00007';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 30 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00007';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 16 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00007';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 4 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00007';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 4 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00007';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 0 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00007';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 100 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00008';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 95 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00008';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 88 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00008';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 70 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00008';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 40 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00008';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 11 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00008';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 11 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00008';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 0 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00008';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 55 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00009';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 50 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00009';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 45 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00009';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 33 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00009';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 18 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00009';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 1 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00009';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 1 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00009';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 0 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00009';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 2 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00009';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 1 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00009';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 65 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00010';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 60 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00010';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 55 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00010';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 31 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00010';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 8 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00010';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 8 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00010';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 0 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00010';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 30 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00011';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 26 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00011';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 20 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00011';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 7 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00011';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 7 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00011';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 0 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00011';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 45 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00012';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 40 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00012';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 35 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00012';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 10 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00012';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 10 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00012';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 0 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00012';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 300 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00013';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 290 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00013';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 280 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00013';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 200 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00013';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 120 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00013';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 15 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00013';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 15 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00013';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 0 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00013';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 25 DAY) FROM usuarios u, estudantes e WHERE u.email = 'fernanda.lima@massa.test' AND e.matricula = '8888-00014';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 20 DAY) FROM usuarios u, estudantes e WHERE u.email = 'fernanda.lima@massa.test' AND e.matricula = '8888-00014';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 14 DAY) FROM usuarios u, estudantes e WHERE u.email = 'fernanda.lima@massa.test' AND e.matricula = '8888-00014';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 3 DAY) FROM usuarios u, estudantes e WHERE u.email = 'fernanda.lima@massa.test' AND e.matricula = '8888-00014';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 3 DAY) FROM usuarios u, estudantes e WHERE u.email = 'fernanda.lima@massa.test' AND e.matricula = '8888-00014';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 0 DAY) FROM usuarios u, estudantes e WHERE u.email = 'fernanda.lima@massa.test' AND e.matricula = '8888-00014';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 400 DAY) FROM usuarios u, estudantes e WHERE u.email = 'helena.rocha@massa.test' AND e.matricula = '8888-00015';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 390 DAY) FROM usuarios u, estudantes e WHERE u.email = 'helena.rocha@massa.test' AND e.matricula = '8888-00015';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 380 DAY) FROM usuarios u, estudantes e WHERE u.email = 'helena.rocha@massa.test' AND e.matricula = '8888-00015';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 330 DAY) FROM usuarios u, estudantes e WHERE u.email = 'helena.rocha@massa.test' AND e.matricula = '8888-00015';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 250 DAY) FROM usuarios u, estudantes e WHERE u.email = 'helena.rocha@massa.test' AND e.matricula = '8888-00015';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 20 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00015';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 20 DAY) FROM usuarios u, estudantes e WHERE u.email = 'helena.rocha@massa.test' AND e.matricula = '8888-00015';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 0 DAY) FROM usuarios u, estudantes e WHERE u.email = 'helena.rocha@massa.test' AND e.matricula = '8888-00015';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 21 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00015';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 1 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00015';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 3 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00016';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 2 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00016';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 0 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00016';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 0 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00016';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 0 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00016';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 35 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00017';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 30 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00017';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 25 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00017';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 9 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00017';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 9 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00017';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 0 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00017';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 2 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00018';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 1 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00018';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 15 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00019';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 12 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00019';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 8 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00020';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 5 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00020';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 20 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00021';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 18 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00021';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 10 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00022';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 7 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00022';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 6 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00023';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 3 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00023';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 0 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00024';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 1 DAY) FROM usuarios u, estudantes e WHERE u.email = 'admin@escola.test' AND e.matricula = '8888-00025';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 5 DAY) FROM usuarios u, estudantes e WHERE u.email = 'admin@escola.test' AND e.matricula = '8888-00026';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 12 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00027';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 3 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00028';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 4 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00029';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 40 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00030';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 250 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00031';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 245 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00031';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 230 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00031';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 200 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00031';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 150 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00031';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 90 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00031';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 90 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00031';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 0 DAY) FROM usuarios u, estudantes e WHERE u.email = 'marina@escola.test' AND e.matricula = '8888-00031';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 91 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00031';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 1 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00031';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 180 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00032';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 175 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00032';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 160 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00032';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 120 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00032';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 60 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00032';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 60 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00032';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 0 DAY) FROM usuarios u, estudantes e WHERE u.email = 'paulo.mendes@massa.test' AND e.matricula = '8888-00032';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 220 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00033';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 215 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00033';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 200 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00033';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 100 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00033';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 45 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00033';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 45 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00033';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 0 DAY) FROM usuarios u, estudantes e WHERE u.email = 'ricardo@escola.test' AND e.matricula = '8888-00033';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 140 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00034';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 135 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00034';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 120 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00034';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 70 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00034';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'CRIOU', e.id, DATE_SUB(NOW(), INTERVAL 20 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00034';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 20 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00034';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'VISUALIZOU', e.id, DATE_SUB(NOW(), INTERVAL 0 DAY) FROM usuarios u, estudantes e WHERE u.email = 'camila.torres@massa.test' AND e.matricula = '8888-00034';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'EDITOU', e.id, DATE_SUB(NOW(), INTERVAL 20 DAY) FROM usuarios u, estudantes e WHERE u.email = 'admin@escola.test' AND e.matricula = '8888-00013';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'EDITOU', e.id, DATE_SUB(NOW(), INTERVAL 1 DAY) FROM usuarios u, estudantes e WHERE u.email = 'admin@escola.test' AND e.matricula = '8888-00025';
INSERT INTO log_acessos (usuario_id, acao, estudante_id, criado_em) SELECT u.id, 'EDITOU', e.id, DATE_SUB(NOW(), INTERVAL 9 DAY) FROM usuarios u, estudantes e WHERE u.email = 'coordenacao@massa.test' AND e.matricula = '8888-00030';
