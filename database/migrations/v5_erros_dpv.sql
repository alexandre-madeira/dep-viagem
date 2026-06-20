-- Migration v5: fila de erros para ciclo de autocorreção
-- Aplicada em: 19/06/2026

CREATE TABLE IF NOT EXISTS erros_dpv (
  id                SERIAL PRIMARY KEY,
  workflow_id       VARCHAR(50) NOT NULL,
  workflow_nome     VARCHAR(100),
  no_nome           VARCHAR(150),
  no_tipo           VARCHAR(100),
  erro_msg          TEXT,
  codigo_atual      TEXT,
  payload_entrada   JSONB,
  execution_id      VARCHAR(50),
  execution_url     VARCHAR(255),
  status            VARCHAR(20) NOT NULL DEFAULT 'pendente',
  fase_analise      VARCHAR(20),
  correcao_aplicada TEXT,
  resolvido_em      TIMESTAMP,
  created_at        TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_erros_status ON erros_dpv(status);
CREATE INDEX IF NOT EXISTS idx_erros_workflow ON erros_dpv(workflow_id);
CREATE INDEX IF NOT EXISTS idx_erros_created ON erros_dpv(created_at DESC);
