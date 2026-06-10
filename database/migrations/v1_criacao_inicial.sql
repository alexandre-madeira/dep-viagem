-- ============================================
-- MIGRATION v1 — Criação inicial
-- dep-viagem [DPV] · 09/06/2026
-- ============================================

CREATE TABLE IF NOT EXISTS funcionarios (
  id         SERIAL PRIMARY KEY,
  phone      VARCHAR(20)  NOT NULL UNIQUE,
  nome       VARCHAR(100) NOT NULL,
  empresa    VARCHAR(100),
  ativo      BOOLEAN      NOT NULL DEFAULT true,
  created_at TIMESTAMP    NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_funcionarios_phone ON funcionarios(phone);

CREATE TABLE IF NOT EXISTS viagens (
  id          SERIAL PRIMARY KEY,
  phone       VARCHAR(20)  NOT NULL,
  nome_viagem VARCHAR(100),
  data_inicio TIMESTAMP    NOT NULL,
  data_fim    TIMESTAMP,
  status      VARCHAR(20)  NOT NULL DEFAULT 'ativa',
  created_at  TIMESTAMP    NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMP    NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_viagens_phone      ON viagens(phone);
CREATE INDEX IF NOT EXISTS idx_viagens_status     ON viagens(status);
CREATE INDEX IF NOT EXISTS idx_viagens_phone_nome ON viagens(phone, nome_viagem);

CREATE TABLE IF NOT EXISTS despesas_viagem (
  id              SERIAL PRIMARY KEY,
  phone           VARCHAR(20)   NOT NULL,
  estabelecimento VARCHAR(255),
  cnpj            VARCHAR(20),
  valor_total     NUMERIC(10,2) NOT NULL,
  data_emissao    DATE,
  categoria       VARCHAR(50)   NOT NULL DEFAULT 'outros',
  itens_json      TEXT,
  message_id      VARCHAR(100),
  created_at      TIMESTAMP     NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_despesas_phone     ON despesas_viagem(phone);
CREATE INDEX IF NOT EXISTS idx_despesas_categoria ON despesas_viagem(categoria);
CREATE INDEX IF NOT EXISTS idx_despesas_data      ON despesas_viagem(data_emissao);
CREATE INDEX IF NOT EXISTS idx_despesas_msgid     ON despesas_viagem(message_id);
