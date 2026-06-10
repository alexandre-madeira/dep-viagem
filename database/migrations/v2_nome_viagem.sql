-- ============================================
-- MIGRATION v2 — Adiciona nome_viagem e status aprovada
-- dep-viagem [DPV] · 09/06/2026
-- Aplique se já tinha a v1 instalada
-- ============================================

ALTER TABLE viagens ADD COLUMN IF NOT EXISTS nome_viagem VARCHAR(100);
CREATE INDEX IF NOT EXISTS idx_viagens_phone_nome ON viagens(phone, nome_viagem);

-- Novo status disponível: aprovada
-- Valores possíveis: ativa | encerrada | aprovada
