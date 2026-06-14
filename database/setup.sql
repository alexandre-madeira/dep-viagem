-- ============================================
-- dep-viagem [DPV] — Setup do Banco de Dados
-- v2 — 09/06/2026
-- Credencial n8n: DB_dep_viagem
-- ============================================

-- Tabela de funcionários
CREATE TABLE IF NOT EXISTS funcionarios (
  id         SERIAL PRIMARY KEY,
  phone      VARCHAR(20)  NOT NULL UNIQUE,
  nome       VARCHAR(100) NOT NULL,
  empresa    VARCHAR(100),
  ativo      BOOLEAN      NOT NULL DEFAULT true,
  created_at TIMESTAMP    NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_funcionarios_phone ON funcionarios(phone);

-- Tabela de viagens
CREATE TABLE IF NOT EXISTS viagens (
  id          SERIAL PRIMARY KEY,
  phone       VARCHAR(20)  NOT NULL,
  nome_viagem VARCHAR(100),
  data_inicio TIMESTAMP    NOT NULL,
  data_fim    TIMESTAMP,
  status      VARCHAR(20)  NOT NULL DEFAULT 'ativa', -- ativa | encerrada | aprovada
  created_at  TIMESTAMP    NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMP    NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_viagens_phone      ON viagens(phone);
CREATE INDEX IF NOT EXISTS idx_viagens_status     ON viagens(status);
CREATE INDEX IF NOT EXISTS idx_viagens_phone_nome ON viagens(phone, nome_viagem);

-- Tabela de despesas por nota fiscal
CREATE TABLE IF NOT EXISTS despesas_viagem (
  id              SERIAL PRIMARY KEY,
  phone           VARCHAR(20)   NOT NULL,
  estabelecimento VARCHAR(255),
  cnpj            VARCHAR(20),
  valor_total     NUMERIC(10,2) NOT NULL,
  data_emissao    DATE,
  categoria       VARCHAR(50)   NOT NULL DEFAULT 'outros',
  -- categorias: alimentacao | combustivel | hospedagem | transporte | pedagio | outros
  itens_json      TEXT,
  message_id      VARCHAR(100),  -- usado para evitar duplicatas
  created_at      TIMESTAMP     NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_despesas_phone     ON despesas_viagem(phone);
CREATE INDEX IF NOT EXISTS idx_despesas_categoria ON despesas_viagem(categoria);
CREATE INDEX IF NOT EXISTS idx_despesas_data      ON despesas_viagem(data_emissao);
CREATE INDEX IF NOT EXISTS idx_despesas_msgid     ON despesas_viagem(message_id);

-- ── Exemplos de uso ──────────────────────────────────────────
-- Cadastrar funcionário:
-- INSERT INTO funcionarios (phone, nome, empresa)
-- VALUES ('5541999999999', 'João Silva', 'Empresa XYZ');

-- Consultar despesas por viagem:
-- SELECT d.*, v.nome_viagem FROM despesas_viagem d
-- JOIN viagens v ON v.phone = d.phone
--   AND d.created_at >= v.data_inicio
--   AND (v.data_fim IS NULL OR d.created_at <= v.data_fim)
-- WHERE v.id = 1 ORDER BY d.data_emissao;

-- Totais por categoria de uma viagem:
-- SELECT categoria, SUM(valor_total) as total
-- FROM despesas_viagem d
-- JOIN viagens v ON v.phone = d.phone
--   AND d.created_at >= v.data_inicio
-- WHERE v.id = 1
-- GROUP BY categoria ORDER BY total DESC;
