-- =====================================================
-- REMOVE a massa de teste (massa_de_teste.sql)
-- Apaga: estudantes com matrícula 8888-% (e tudo ligado a eles), os usuários @massa.test
-- e as turmas extras que ficaram vazias. NÃO mexe em estudantes de verdade nem nos usuários
-- marina/ricardo/admin do dados_teste.sql.
-- Obs.: um usuário @massa.test que tenha registrado algo em outro estudante (real) não é
-- apagado (o banco protege o histórico); desative-o na tela Usuários.
-- =====================================================
USE acolher;

DELETE FROM log_acessos
 WHERE estudante_id IN (SELECT id FROM estudantes WHERE matricula LIKE '8888-%');

DELETE FROM encaminhamentos
 WHERE atendimento_id IN (SELECT a.id FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id
                           WHERE e.matricula LIKE '8888-%');

DELETE FROM atendimentos
 WHERE estudante_id IN (SELECT id FROM estudantes WHERE matricula LIKE '8888-%');

DELETE FROM acolhimento_demandas
 WHERE acolhimento_id IN (SELECT a.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
                           WHERE e.matricula LIKE '8888-%');

DELETE FROM acolhimentos
 WHERE estudante_id IN (SELECT id FROM estudantes WHERE matricula LIKE '8888-%');

DELETE FROM responsaveis
 WHERE estudante_id IN (SELECT id FROM estudantes WHERE matricula LIKE '8888-%');

DELETE FROM estudantes WHERE matricula LIKE '8888-%';

-- Logins dos usuários extras e os próprios usuários (só os que não têm mais nenhum registro ligado)
DELETE FROM log_acessos
 WHERE usuario_id IN (SELECT id FROM usuarios WHERE email LIKE '%@massa.test');

DELETE FROM usuarios
 WHERE email LIKE '%@massa.test'
   AND NOT EXISTS (SELECT 1 FROM estudantes     x WHERE x.criado_por      = usuarios.id)
   AND NOT EXISTS (SELECT 1 FROM acolhimentos   x WHERE x.profissional_id = usuarios.id)
   AND NOT EXISTS (SELECT 1 FROM atendimentos   x WHERE x.profissional_id = usuarios.id)
   AND NOT EXISTS (SELECT 1 FROM encaminhamentos x WHERE x.responsavel_id = usuarios.id);

-- Turmas extras da massa (só se estiverem vazias)
DELETE FROM turmas
 WHERE ((nome = '6º B'  AND turno = 'TARDE' AND ano_letivo = YEAR(CURDATE()))
     OR (nome = '3º EM C' AND turno = 'NOITE' AND ano_letivo = YEAR(CURDATE()))
     OR (nome = '3º A'  AND turno = 'MANHA' AND ano_letivo = YEAR(CURDATE()))
     OR (nome = '9º A'  AND turno = 'MANHA' AND ano_letivo = YEAR(CURDATE()) - 1))
   AND NOT EXISTS (SELECT 1 FROM estudantes x WHERE x.turma_id = turmas.id);
