-- Migration v3: aumentar limite de nome_viagem para 255 caracteres
-- Motivo: P11 — erro "value too long for type character varying(100)"
--         mensagens WhatsApp com texto longo falhavam ao inserir em viagens
-- Data: 2026-06-15

-- Tabela viagens (campo principal — origem do erro P11)
ALTER TABLE viagens ALTER COLUMN nome_viagem TYPE VARCHAR(255);
