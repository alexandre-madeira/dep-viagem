TAREFA COMPLEMENTAR - Corrigir bugs identificados em 09/07/2026

BUG-01 CRITICO - WF-DPV.03 (ID: ruf039UAwh9KqIZo):
Respostas numericas do rodape nao reconhecidas pelo SWITCH de comandos.
Apos despesa registrada o bot envia rodape:
  "1) CORRIGIR ULTIMA
   2) ENCERRAR VIAGEM"
Usuario responde "1" ou "2" mas cai no menu de ajuda.

CAUSA: sem despesa pendente, o SWITCH nao reconhece numeros isolados como comandos.

CORRECAO: no CODE | Normalizar Comando ou SWITCH | Tipo de Comando,
antes de comparar com os comandos textuais, verificar se caption == "1" e mapear
para "CORRIGIR ULTIMA", e se caption == "2" mapear para "ENCERRAR VIAGEM".
Apenas quando nao existe despesa pendente ativa.

Registrar no backlog do banco n8n_contratos:
INSERT INTO backlog (project_id, fix_id, descricao, workflow_id, prioridade, status)
VALUES ('DPV', 'BUG-01', 'Respostas 1/2 do rodape nao reconhecidas pelo SWITCH', 'ruf039UAwh9KqIZo', 'ALTO', 'RESOLVIDO')
ON CONFLICT DO NOTHING;

Commitar: fix: BUG-01 respostas numericas do rodape reconhecidas no SWITCH
git push
