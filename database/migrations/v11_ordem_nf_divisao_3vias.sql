-- Migration v11: numero sequencial de NF por viagem + divisao 3 vias (empresa/funcionario/cliente)
-- Aplicada em: 14/07/2026

ALTER TABLE despesas_viagem ADD COLUMN IF NOT EXISTS ordem_nf INTEGER;
ALTER TABLE despesas_viagem ADD COLUMN IF NOT EXISTS valor_cliente NUMERIC;

-- Coluna faltante desde a v9 (despesas_pendentes tem observacao, despesas_viagem nunca
-- ganhou a mesma coluna) — o relatorio PDF (WF-DPV.04) le d.observacao e sempre mostrava "-".
ALTER TABLE despesas_viagem ADD COLUMN IF NOT EXISTS observacao VARCHAR(30);
