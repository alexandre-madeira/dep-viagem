-- Migration v7: corrigir timezone de codigo_expira (loop codigo expirado)
-- Aplicada em: 07/07/2026
--
-- Contexto: codigo_expira era TIMESTAMP (sem timezone). A sessao do Postgres
-- roda em UTC e o codigo grava/le o valor como string ISO com sufixo 'Z',
-- mas o driver usado pelo node Postgres do n8n interpreta o timestamp naive
-- lido de volta como horario local do servidor (America/Sao_Paulo, UTC-3),
-- somando 3h indevidas na serializacao. Resultado: um codigo que deveria
-- expirar em 15 minutos so era considerado expirado depois de ~3h15min.
--
-- USING codigo_expira AT TIME ZONE 'UTC' reinterpreta o valor naive existente
-- como UTC (que e o que ele de fato representa, ja que a sessao e UTC) sem
-- deslocar o horario, e passa a coluna a ser TIMESTAMPTZ para que leitura e
-- escrita fiquem consistentes daqui em diante.

ALTER TABLE cadastros_pendentes
  ALTER COLUMN codigo_expira TYPE TIMESTAMPTZ USING codigo_expira AT TIME ZONE 'UTC';
