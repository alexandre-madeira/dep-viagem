-- Migration v8: deduplicacao de mensagens do Evolution API
-- Aplicada em: 07/07/2026
--
-- Contexto: o Evolution API pode entregar o mesmo evento messages.upsert
-- mais de uma vez (webhook duplicado). Sem controle de idempotencia, o
-- WF-DPV.01 processava a mesma mensagem duas vezes, e se o estado do
-- telefone mudasse entre as duas entregas (ex: cadastro confirmado na
-- primeira), a segunda entrega podia ser roteada para um fluxo diferente
-- do esperado (ex: WF-DPV.03 em vez de WF-DPV.07), gerando uma "mensagem
-- duplicada" indevida.

CREATE TABLE IF NOT EXISTS mensagens_processadas (
  message_id  VARCHAR(64) PRIMARY KEY,
  phone       VARCHAR(20),
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_mensagens_processadas_phone ON mensagens_processadas(phone);
