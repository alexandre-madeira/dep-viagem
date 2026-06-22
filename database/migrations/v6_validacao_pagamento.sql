-- Migration v6: validação de pagamento (P17)
-- Aplicada em: 21/06/2026
-- Campos: tipo_pagador, forma_pagamento, cpf_cnpj, sem_nf, validado_manualmente

-- ── despesas_viagem: 6 novas colunas ──────────────────────────
ALTER TABLE despesas_viagem ADD COLUMN IF NOT EXISTS tipo_pagador        VARCHAR(20);
ALTER TABLE despesas_viagem ADD COLUMN IF NOT EXISTS forma_pagamento     VARCHAR(20);
ALTER TABLE despesas_viagem ADD COLUMN IF NOT EXISTS cpf_cnpj_pagador   VARCHAR(20);
ALTER TABLE despesas_viagem ADD COLUMN IF NOT EXISTS sem_nf              BOOLEAN DEFAULT false;
ALTER TABLE despesas_viagem ADD COLUMN IF NOT EXISTS validado_manualmente BOOLEAN;
ALTER TABLE despesas_viagem ADD COLUMN IF NOT EXISTS observacoes_validacao TEXT;

CREATE INDEX IF NOT EXISTS idx_despesas_tipo_forma ON despesas_viagem(tipo_pagador, forma_pagamento);
CREATE INDEX IF NOT EXISTS idx_despesas_cpf        ON despesas_viagem(cpf_cnpj_pagador);

-- ── despesas_sem_nf_log: tabela nova ─────────────────────────
CREATE TABLE IF NOT EXISTS despesas_sem_nf_log (
  id                SERIAL PRIMARY KEY,
  phone             VARCHAR(20),
  viagem_id         INTEGER,
  descricao         VARCHAR(200),
  tipo_pagador      VARCHAR(20),
  forma_pagamento   VARCHAR(20),
  cpf_cnpj_pagador  VARCHAR(20),
  valor             NUMERIC(10,2),
  data_compra       DATE,
  criado_em         TIMESTAMP DEFAULT NOW(),
  validacao_status  VARCHAR(20) DEFAULT 'pendente'
);

CREATE INDEX IF NOT EXISTS idx_despesas_log_status ON despesas_sem_nf_log(validacao_status);
CREATE INDEX IF NOT EXISTS idx_despesas_log_phone  ON despesas_sem_nf_log(phone);

-- ── funcionarios: 3 novas colunas ────────────────────────────
ALTER TABLE funcionarios ADD COLUMN IF NOT EXISTS cpf_cnpj               VARCHAR(20);
ALTER TABLE funcionarios ADD COLUMN IF NOT EXISTS tipo_pagador_padrao    VARCHAR(20);
ALTER TABLE funcionarios ADD COLUMN IF NOT EXISTS forma_pagamento_padrao VARCHAR(20);
