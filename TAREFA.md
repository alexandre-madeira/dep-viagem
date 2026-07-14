MELHORIAS DPV - 14/07/2026

MELHORIA 1 - Numero sequencial da NF por viagem:
Adicionar coluna ordem_nf em despesas_viagem.
Migration: ALTER TABLE despesas_viagem ADD COLUMN IF NOT EXISTS ordem_nf INTEGER;
Ao salvar despesa em DB | Salvar Despesa Final, calcular:
SELECT COUNT(*) + 1 FROM despesas_viagem WHERE phone = X AND viagem_id = Y
e salvar em ordem_nf.
Exibir no resumo da despesa: "NF #3 - Estabelecimento: X"
Exibir no relatorio PDF na primeira coluna da tabela.

PROBLEMA: despesas_viagem nao tem coluna viagem_id direta.
Usar: SELECT COUNT(*) + 1 FROM despesas_viagem d
JOIN viagens v ON v.phone = d.phone
WHERE d.phone = X AND v.id = (SELECT id FROM viagens WHERE phone = X ORDER BY id DESC LIMIT 1)
AND d.created_at >= v.data_inicio

MELHORIA 2 - Divisao com letras a/b/c no step aguardando_divisao:
Aceitar formato: a 100 b 0 c 30
Onde: a=empresa, b=funcionario(eu), c=cliente
Regex: /([abc])\s*R?\True\s*([\d.,]+)/gi
Mapear: a->valor_empresa, b->valor_funcionario, c->valor_cliente
Salvar valor_cliente em campo a criar: valor_cliente NUMERIC em despesas_viagem
Migration: ALTER TABLE despesas_viagem ADD COLUMN IF NOT EXISTS valor_cliente NUMERIC;
Exibir no resumo: "Empresa: R$ X | Voce: R$ Y | Cliente: R$ Z"
Manter suporte ao formato antigo EMPRESA X VOCE Y.

Registrar no backlog n8n_contratos:
INSERT INTO backlog (project_id, fix_id, descricao, workflow_id, prioridade, status)
VALUES
('DPV', 'FEAT-10', 'Numero sequencial da NF por viagem (ordem_nf)', 'ruf039UAwh9KqIZo', 'MEDIO', 'ABERTO'),
('DPV', 'FEAT-11', 'Divisao conta com letras a/b/c (empresa/funcionario/cliente)', 'ruf039UAwh9KqIZo', 'MEDIO', 'ABERTO')
ON CONFLICT DO NOTHING;

Implementar as duas melhorias, commitar e dar push.
