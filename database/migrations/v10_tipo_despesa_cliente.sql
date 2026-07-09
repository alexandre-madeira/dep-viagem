-- Migration v10: tipo_despesa (cobranca ao cliente) - issue #5
-- Aplicada em: 09/07/2026

ALTER TABLE despesas_viagem ADD COLUMN IF NOT EXISTS tipo_despesa VARCHAR(20) NOT NULL DEFAULT 'empresa';
