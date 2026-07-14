Criar docs/ARQUITETURA_DPV.md e commitar no GitHub.

Buscar dados do banco n8n_contratos usando credencial DB_n8n_contratos (ID: 3z35ZPyLInGNam1Y):

SELECT fase, componente, requisito, workflow_id, status
FROM arquitetura
WHERE project_id = 'DPV' AND status = 'ATIVO'
ORDER BY fase, componente, id;

SELECT fix_id, descricao, workflow_id, prioridade, status
FROM backlog
WHERE project_id = 'DPV'
ORDER BY prioridade, fix_id;

SELECT workflow_id, sigla, alias, papel
FROM workflow_registro
WHERE project_id = 'DPV'
ORDER BY sigla;

Montar o arquivo markdown com estrutura:

# ARQUITETURA DEP-VIAGEM (DPV) v1.0
## 1. OBJETIVOS DO SISTEMA (F1)
## 2. WORKFLOWS (F2)
## 3. REQUISITOS POR NO (F3)
## 4. BACKLOG ABERTO
## 5. CREDENCIAIS E INFRA
## 6. BANCO DE DADOS

Incluir na secao 5:
- Credencial Evolution API: HEADER_API_EVOLUTION_ENVIO (ID: Ka0C8J4zfOklD1lw) instancia VIDROCOM_AG
- Credencial banco: DB_dep_viagem (ID: ggViIQGkepjwuOdv)
- Credencial Anthropic: Anthropic DPV (ID: fA9wqoHasCFbjdwX)
- Gotenberg: http://gotenberg:3000
- n8n: https://n8n.solucaomadeira.com
- Evolution API: https://evolution.solucaomadeira.com

Incluir na secao 6 a estrutura completa do banco dep_viagem conforme docs/BANCO_DEP_VIAGEM.md ja existente no repo.

Commitar: docs: ARQUITETURA_DPV.md v1.0 gerada a partir do banco n8n_contratos
git push
