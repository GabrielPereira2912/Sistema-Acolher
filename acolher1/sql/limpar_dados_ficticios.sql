-- =====================================================
-- REMOVE os dados fictícios (matrículas que começam com 9999-)
-- Não mexe em mais nada: alunos cadastrados de verdade ficam intactos.
-- =====================================================
USE acolher;

DELETE FROM log_acessos
 WHERE estudante_id IN (SELECT id FROM estudantes WHERE matricula LIKE '9999-%');

DELETE FROM encaminhamentos
 WHERE atendimento_id IN (SELECT a.id FROM atendimentos a JOIN estudantes e ON e.id = a.estudante_id
                           WHERE e.matricula LIKE '9999-%');

DELETE FROM atendimentos
 WHERE estudante_id IN (SELECT id FROM estudantes WHERE matricula LIKE '9999-%');

DELETE FROM acolhimento_demandas
 WHERE acolhimento_id IN (SELECT a.id FROM acolhimentos a JOIN estudantes e ON e.id = a.estudante_id
                           WHERE e.matricula LIKE '9999-%');

DELETE FROM acolhimentos
 WHERE estudante_id IN (SELECT id FROM estudantes WHERE matricula LIKE '9999-%');

DELETE FROM responsaveis
 WHERE estudante_id IN (SELECT id FROM estudantes WHERE matricula LIKE '9999-%');

DELETE FROM estudantes WHERE matricula LIKE '9999-%';
