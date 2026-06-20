-- Migration v4: cadastro de usuários com validação por e-mail
-- Aplicada em: 19/06/2026

ALTER TABLE funcionarios ADD COLUMN IF NOT EXISTS email VARCHAR(150);

CREATE TABLE IF NOT EXISTS cadastros_pendentes (
  phone             VARCHAR(20) PRIMARY KEY,
  step              VARCHAR(30) NOT NULL DEFAULT 'aguardando_nome',
  nome_temp         VARCHAR(100),
  email_temp        VARCHAR(150),
  codigo            VARCHAR(6),
  codigo_expira     TIMESTAMP,
  tentativas        INT DEFAULT 0,
  criado_em         TIMESTAMP DEFAULT NOW(),
  atualizado_em     TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_cadastros_phone ON cadastros_pendentes(phone);
CREATE INDEX IF NOT EXISTS idx_funcionarios_phone ON funcionarios(phone);
