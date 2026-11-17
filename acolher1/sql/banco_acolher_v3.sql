-- =====================================================
-- Sistema de Gestão do Atendimento Psicossocial de Estudantes
-- Versão 3: simples, porém bem separada (11 tabelas + 2 views)
-- Mudanças da v2: a view linha_do_tempo passou a mostrar a modalidade
-- e foi criada a view painel_estudantes (consulta pronta do dashboard).
-- MySQL / MariaDB (XAMPP). Importar pelo phpMyAdmin.
-- Escola única: não existe tabela de escolas.
-- =====================================================

DROP DATABASE IF EXISTS acolher;
CREATE DATABASE acolher CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE acolher;

-- =====================================================
-- BLOCO 1: ACESSO
-- =====================================================

-- 1) USUARIOS: equipe técnica e administradores
CREATE TABLE usuarios (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  nome            VARCHAR(120) NOT NULL,
  email           VARCHAR(120) NOT NULL UNIQUE,
  senha_hash      VARCHAR(255) NOT NULL,   -- gerar com password_hash() no PHP
  perfil          ENUM('ADMIN','PSICOLOGO','ASSISTENTE_SOCIAL') NOT NULL,
  registro_classe VARCHAR(30) NULL,        -- CRP / CRESS (obrigatório para profissionais, validar no PHP)
  ativo           TINYINT(1) NOT NULL DEFAULT 1,  -- nunca apagar usuário: desative
  criado_em       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2) LOG_ACESSOS: quem abriu/alterou cada prontuário (privacidade)
CREATE TABLE log_acessos (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id   INT NOT NULL,
  acao         ENUM('LOGIN','VISUALIZOU','CRIOU','EDITOU') NOT NULL,
  estudante_id INT NULL,
  criado_em    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- =====================================================
-- BLOCO 2: ESTUDANTE (PRONTUÁRIO)
-- =====================================================

-- 3) TURMAS: turma, turno e etapa ficam aqui (não se repetem em cada aluno)
CREATE TABLE turmas (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  nome         VARCHAR(20) NOT NULL,                       -- ex: '7º A'
  turno        ENUM('MANHA','TARDE','NOITE') NOT NULL,
  etapa_ensino ENUM('FUNDAMENTAL_I','FUNDAMENTAL_II','ENSINO_MEDIO') NOT NULL,
  ano_letivo   YEAR NOT NULL,
  UNIQUE (nome, turno, ano_letivo)
);

-- 4) ESTUDANTES: identificação + situação no sistema
-- A idade NÃO é coluna: é calculada a partir de data_nascimento.
CREATE TABLE estudantes (
  id                  INT AUTO_INCREMENT PRIMARY KEY,
  nome_completo       VARCHAR(150) NOT NULL,
  matricula           VARCHAR(20)  NOT NULL UNIQUE,
  data_nascimento     DATE NOT NULL,
  turma_id            INT NOT NULL,
  composicao_familiar TEXT NULL,
  necessidades_apoio  TEXT NULL,
  status              ENUM('TRIAGEM','EM_ACOMPANHAMENTO','ENCERRADO')
                      NOT NULL DEFAULT 'TRIAGEM',
  criado_por          INT NOT NULL,
  criado_em           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (turma_id)   REFERENCES turmas(id),
  FOREIGN KEY (criado_por) REFERENCES usuarios(id),
  INDEX idx_estudante_nome (nome_completo)
);

-- 5) RESPONSAVEIS: um estudante pode ter vários
CREATE TABLE responsaveis (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  estudante_id INT NOT NULL,
  nome         VARCHAR(150) NOT NULL,
  parentesco   VARCHAR(40)  NOT NULL,            -- mãe, pai, avó, tutor...
  telefone     VARCHAR(20)  NOT NULL,
  principal    TINYINT(1) NOT NULL DEFAULT 0,
  FOREIGN KEY (estudante_id) REFERENCES estudantes(id) ON DELETE CASCADE
);

-- =====================================================
-- BLOCO 3: TRIAGEM (ACOLHIMENTO E DEMANDAS)
-- =====================================================

-- 6) CATEGORIAS_DEMANDA: lista fixa, só para organizar e filtrar.
-- Não existe gravidade, score ou diagnóstico.
CREATE TABLE categorias_demanda (
  id                  INT AUTO_INCREMENT PRIMARY KEY,
  nome                VARCHAR(100) NOT NULL UNIQUE,
  exige_especificacao TINYINT(1) NOT NULL DEFAULT 0,   -- 1 = 'Outras'
  ativo               TINYINT(1) NOT NULL DEFAULT 1
);

-- 7) ACOLHIMENTOS: primeiro contato
CREATE TABLE acolhimentos (
  id                     INT AUTO_INCREMENT PRIMARY KEY,
  estudante_id           INT NOT NULL,
  profissional_id        INT NOT NULL,           -- usuário logado (vem da sessão)
  data_acolhimento       DATE NOT NULL,
  descricao_complementar TEXT NULL,
  outras_especificacao   VARCHAR(255) NULL,      -- preenchido se marcar 'Outras'
  criado_em              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (estudante_id)    REFERENCES estudantes(id),
  FOREIGN KEY (profissional_id) REFERENCES usuarios(id)
);

-- 8) ACOLHIMENTO_DEMANDAS: seleção múltipla (N:N)
CREATE TABLE acolhimento_demandas (
  acolhimento_id INT NOT NULL,
  categoria_id   INT NOT NULL,
  PRIMARY KEY (acolhimento_id, categoria_id),
  FOREIGN KEY (acolhimento_id) REFERENCES acolhimentos(id) ON DELETE CASCADE,
  FOREIGN KEY (categoria_id)   REFERENCES categorias_demanda(id)
);

-- =====================================================
-- BLOCO 4: ATENDIMENTOS E ENCAMINHAMENTOS
-- =====================================================

-- 9) TIPOS_ACAO e DESTINOS_ENCAMINHAMENTO: listas fixas
CREATE TABLE tipos_acao (
  id    INT AUTO_INCREMENT PRIMARY KEY,
  nome  VARCHAR(80) NOT NULL UNIQUE,
  ativo TINYINT(1) NOT NULL DEFAULT 1
);

CREATE TABLE destinos_encaminhamento (
  id      INT AUTO_INCREMENT PRIMARY KEY,
  nome    VARCHAR(80) NOT NULL UNIQUE,
  natureza ENUM('INTERNO','EXTERNO') NOT NULL,
  ativo   TINYINT(1) NOT NULL DEFAULT 1
);

-- 10) ATENDIMENTOS: cada linha vira um item da linha do tempo
CREATE TABLE atendimentos (
  id                 INT AUTO_INCREMENT PRIMARY KEY,
  estudante_id       INT NOT NULL,
  profissional_id    INT NOT NULL,                 -- sempre do usuário logado
  cargo_profissional ENUM('PSICOLOGO','ASSISTENTE_SOCIAL') NOT NULL, -- cargo no momento do registro
  data_atendimento   DATE NOT NULL,
  modalidade         ENUM('INDIVIDUAL','GRUPO','FAMILIA','PROFESSORES','TELEFONE') NOT NULL,
  tipo_acao_id       INT NOT NULL,
  descricao          TEXT NOT NULL,                -- descrição objetiva da intervenção
  criado_em          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (estudante_id)    REFERENCES estudantes(id),
  FOREIGN KEY (profissional_id) REFERENCES usuarios(id),
  FOREIGN KEY (tipo_acao_id)    REFERENCES tipos_acao(id),
  INDEX idx_atend_estudante_data (estudante_id, data_atendimento)
);

-- 11) ENCAMINHAMENTOS: um atendimento pode gerar vários
CREATE TABLE encaminhamentos (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  atendimento_id  INT NOT NULL,
  destino_id      INT NOT NULL,
  observacao      TEXT NULL,
  prazo           DATE NOT NULL,
  responsavel_id  INT NOT NULL,                    -- quem acompanha o prazo
  status          ENUM('ABERTO','CONCLUIDO','CANCELADO') NOT NULL DEFAULT 'ABERTO',
  concluido_em    DATE NULL,
  FOREIGN KEY (atendimento_id) REFERENCES atendimentos(id) ON DELETE CASCADE,
  FOREIGN KEY (destino_id)     REFERENCES destinos_encaminhamento(id),
  FOREIGN KEY (responsavel_id) REFERENCES usuarios(id),
  INDEX idx_enc_status_prazo (status, prazo)
);

-- =====================================================
-- DADOS INICIAIS (todos do grupo trabalham com a mesma base)
-- =====================================================

INSERT INTO categorias_demanda (nome, exige_especificacao) VALUES
 ('Dificuldades de aprendizagem e adaptação escolar', 0),
 ('Faltas frequentes, risco de evasão e abandono escolar', 0),
 ('Conflitos familiares e dificuldades de convivência', 0),
 ('Violência, negligência ou suspeita de violação de direitos', 0),
 ('Bullying, discriminação e conflitos interpessoais', 0),
 ('Sofrimento emocional e dificuldades comportamentais', 0),
 ('Outras', 1);

INSERT INTO tipos_acao (nome) VALUES
 ('Escuta / acolhimento'),
 ('Orientação ao estudante'),
 ('Contato com a família'),
 ('Reunião com professores'),
 ('Visita domiciliar'),
 ('Articulação com a rede'),
 ('Reavaliação');

INSERT INTO destinos_encaminhamento (nome, natureza) VALUES
 ('Coordenação pedagógica', 'INTERNO'),
 ('Conselho Tutelar',       'EXTERNO'),
 ('CRAS',                   'EXTERNO'),
 ('CAPS',                   'EXTERNO'),
 ('UBS / Rede de saúde',    'EXTERNO');

-- O primeiro ADMIN deve ser criado por um script PHP com password_hash(),
-- nunca com a senha digitada direto no SQL.

-- =====================================================
-- VIEW: LINHA DO TEMPO UNIFICADA (acolhimentos + atendimentos)
-- Uso: SELECT * FROM linha_do_tempo WHERE estudante_id = ? ORDER BY data DESC, criado_em DESC;
-- =====================================================
CREATE VIEW linha_do_tempo AS
  SELECT a.estudante_id,
         a.data_acolhimento       AS data,
         'Acolhimento inicial'    AS titulo,
         u.nome                   AS profissional,
         CAST(u.perfil AS CHAR)   AS cargo,
         a.descricao_complementar AS descricao,
         NULL                     AS modalidade,   -- acolhimento não tem modalidade
         a.criado_em
    FROM acolhimentos a
    JOIN usuarios u ON u.id = a.profissional_id
  UNION ALL
  SELECT t.estudante_id,
         t.data_atendimento,
         ta.nome,
         u.nome,
         CAST(t.cargo_profissional AS CHAR),
         t.descricao,
         CAST(t.modalidade AS CHAR),
         t.criado_em
    FROM atendimentos t
    JOIN usuarios u      ON u.id  = t.profissional_id
    JOIN tipos_acao ta   ON ta.id = t.tipo_acao_id;

-- =====================================================
-- VIEW: PAINEL DO DASHBOARD (uma linha por estudante)
-- Uso: SELECT * FROM painel_estudantes ORDER BY ultimo_atendimento DESC;
-- Quem ainda não tem atendimento mostra a data de cadastro e quem cadastrou.
-- =====================================================
CREATE VIEW painel_estudantes AS
  SELECT e.id AS estudante_id,
         e.nome_completo,
         e.status,
         t.nome AS turma,
         COALESCE((SELECT MAX(l.data) FROM linha_do_tempo l WHERE l.estudante_id = e.id),
                  DATE(e.criado_em)) AS ultimo_atendimento,
         COALESCE((SELECT l.profissional FROM linha_do_tempo l WHERE l.estudante_id = e.id
                    ORDER BY l.data DESC, l.criado_em DESC LIMIT 1),
                  (SELECT u.nome FROM usuarios u WHERE u.id = e.criado_por)) AS profissional
    FROM estudantes e
    JOIN turmas t ON t.id = e.turma_id;

-- =====================================================
-- CONSULTAS ÚTEIS
-- =====================================================

-- Idade calculada:
-- SELECT nome_completo, TIMESTAMPDIFF(YEAR, data_nascimento, CURDATE()) AS idade FROM estudantes;

-- Cards do dashboard:
-- SELECT COUNT(*) FROM estudantes WHERE status = 'EM_ACOMPANHAMENTO';
-- SELECT COUNT(*) FROM estudantes WHERE status = 'TRIAGEM';
-- SELECT COUNT(*) FROM atendimentos
--  WHERE MONTH(data_atendimento) = MONTH(CURDATE()) AND YEAR(data_atendimento) = YEAR(CURDATE());
-- SELECT COUNT(*) FROM encaminhamentos WHERE status = 'ABERTO';

-- Encaminhamentos com prazo vencido:
-- SELECT * FROM encaminhamentos WHERE status = 'ABERTO' AND prazo < CURDATE();

-- Dashboard: SELECT * FROM painel_estudantes;  (a view já faz o trabalho)

-- Filtrar estudantes por categoria de demanda:
-- SELECT DISTINCT e.nome_completo
--   FROM acolhimento_demandas ad
--   JOIN acolhimentos a ON a.id = ad.acolhimento_id
--   JOIN estudantes e   ON e.id = a.estudante_id
--  WHERE ad.categoria_id = ?;
