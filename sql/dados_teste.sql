-- =====================================================
-- DADOS DE TESTE (rodar DEPOIS do banco_acolher_v2.sql)
-- Só para desenvolvimento. Remover antes da apresentação final.
-- =====================================================
USE acolher;

-- Usuários de teste. Senha de ambos: teste123 (já guardada como hash, gerada com password_hash)
INSERT INTO usuarios (nome, email, senha_hash, perfil, registro_classe) VALUES
 ('Marina Lopes',  'marina@escola.test',  '$2y$10$3jbHeboi6xuMKKx99cSWvO/3AIABGsEkm2AfwLP1zax6VbZulm85q', 'PSICOLOGO',         'CRP 06/12345'),
 ('Ricardo Alves', 'ricardo@escola.test', '$2y$10$3jbHeboi6xuMKKx99cSWvO/3AIABGsEkm2AfwLP1zax6VbZulm85q', 'ASSISTENTE_SOCIAL', 'CRESS 12345');

-- Turmas do ano letivo atual (YEAR(CURDATE()) = o ano de hoje, assim nunca "vencem")
INSERT INTO turmas (nome, turno, etapa_ensino, ano_letivo) VALUES
 ('5º C',    'MANHA', 'FUNDAMENTAL_I',  YEAR(CURDATE())),
 ('7º A',    'MANHA', 'FUNDAMENTAL_II', YEAR(CURDATE())),
 ('9º B',    'TARDE', 'FUNDAMENTAL_II', YEAR(CURDATE())),
 ('1º EM A', 'MANHA', 'ENSINO_MEDIO',   YEAR(CURDATE())),
 ('2º EM B', 'TARDE', 'ENSINO_MEDIO',   YEAR(CURDATE()));
