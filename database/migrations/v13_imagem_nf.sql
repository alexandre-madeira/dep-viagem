-- Migration v13: FEAT-12 - armazenar imagem da NF em despesas_viagem
-- Aplicada em: 17/07/2026 (colunas ja aplicadas manualmente pelo usuario antes desta migration)

ALTER TABLE despesas_viagem ADD COLUMN IF NOT EXISTS imagem_nf_base64 TEXT;
ALTER TABLE despesas_viagem ADD COLUMN IF NOT EXISTS imagem_nf_mimetype VARCHAR(20);
