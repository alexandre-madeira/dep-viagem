-- Migration v9: divisao de conta + fluxo guiado de complemento de despesa
-- Aplicada em: 07/07/2026

-- ── despesas_viagem: divisao de conta ────────────────────────
ALTER TABLE despesas_viagem ADD COLUMN IF NOT EXISTS valor_empresa NUMERIC;
ALTER TABLE despesas_viagem ADD COLUMN IF NOT EXISTS valor_funcionario NUMERIC;

-- ── despesas_pendentes: staging do fluxo guiado pos-foto ─────
-- Guarda o estado da conversa (quem pagou / como pagou / observacao) entre
-- o momento em que a NF e processada pelo WF-DPV.02 e o momento em que o
-- INSERT final em despesas_viagem acontece via WF-DPV.03.
CREATE TABLE IF NOT EXISTS despesas_pendentes (
  phone           VARCHAR(20) PRIMARY KEY,
  message_id      VARCHAR(100) NOT NULL,
  step            VARCHAR(30)  NOT NULL DEFAULT 'aguardando_pagador',
  dados_extraidos JSONB        NOT NULL,
  tipo_pagador    VARCHAR(20),
  forma_pagamento VARCHAR(20),
  observacao      VARCHAR(30),
  criado_em       TIMESTAMP DEFAULT NOW(),
  atualizado_em   TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_despesas_pendentes_phone ON despesas_pendentes(phone);
