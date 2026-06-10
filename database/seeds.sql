-- ============================================
-- SEEDS — Dados de exemplo para testes
-- dep-viagem [DPV]
-- ⚠️ Não executar em produção
-- ============================================

-- Funcionários
INSERT INTO funcionarios (phone, nome, empresa) VALUES
  ('5541999999999', 'Alexandre Madeira', 'Empresa XYZ'),
  ('5542888881234', 'Maria Santos',      'Empresa XYZ'),
  ('5541777775555', 'Carlos Ferreira',   'Empresa XYZ')
ON CONFLICT (phone) DO NOTHING;

-- Viagem 1 — encerrada
INSERT INTO viagens (phone, nome_viagem, data_inicio, data_fim, status) VALUES
  ('5541999999999', 'Palmeira / Santo Antônio — Jun/26',
   '2026-06-09 08:00:00', '2026-06-09 20:00:00', 'encerrada');

INSERT INTO despesas_viagem (phone, estabelecimento, cnpj, valor_total, data_emissao, categoria, message_id) VALUES
  ('5541999999999', 'Acaron Restaurante e Lanchonete', '38.417.761/0001-80', 22.00,  '2026-06-09', 'alimentacao', 'MSG001'),
  ('5541999999999', 'Andrey Josue Meotti Ltda (Buffet)','02.958.035/0001-63', 102.11, '2026-06-09', 'alimentacao', 'MSG002'),
  ('5541999999999', 'Auto Posto Ravanello Ltda',        '77.240.815/0001-35', 345.95, '2026-06-09', 'combustivel', 'MSG003');

-- Viagem 2 — ativa
INSERT INTO viagens (phone, nome_viagem, data_inicio, status) VALUES
  ('5542888881234', 'Curitiba — Jun/26', '2026-06-09 06:00:00', 'ativa');

INSERT INTO despesas_viagem (phone, estabelecimento, valor_total, data_emissao, categoria, message_id) VALUES
  ('5542888881234', 'Hotel Bourbon Curitiba',   389.00, '2026-06-09', 'hospedagem',  'MSG004'),
  ('5542888881234', 'Posto Ipiranga BR-277',    210.40, '2026-06-09', 'combustivel', 'MSG005'),
  ('5542888881234', 'Arco Eco — Pedágio PR-151',  8.90, '2026-06-09', 'pedagio',     'MSG006'),
  ('5542888881234', 'McDonald''s BR-277',         47.50, '2026-06-09', 'alimentacao', 'MSG007');

-- Viagem 3 — aprovada
INSERT INTO viagens (phone, nome_viagem, data_inicio, data_fim, status) VALUES
  ('5541777775555', 'São Paulo — Mai/26',
   '2026-05-20 07:00:00', '2026-05-22 20:00:00', 'aprovada');

INSERT INTO despesas_viagem (phone, estabelecimento, valor_total, data_emissao, categoria, message_id) VALUES
  ('5541777775555', 'Ibis Styles São Paulo',         520.00, '2026-05-20', 'hospedagem',  'MSG008'),
  ('5541777775555', 'Restaurante Fogo de Chão',      189.90, '2026-05-21', 'alimentacao', 'MSG009'),
  ('5541777775555', 'Uber — traslados SP',           143.20, '2026-05-21', 'transporte',  'MSG010'),
  ('5541777775555', 'Posto Shell — Rodovia Anhanguera',298.00,'2026-05-22','combustivel', 'MSG011');
