# BANCO dep_viagem — Estrutura Completa
Atualizado: 06/07/2026

---

## cadastros_pendentes
| Coluna | Tipo | Nulo | Default |
|---|---|---|---|
| phone | varchar(20) | NO | - |
| step | varchar(30) | NO | - |
| nome_temp | varchar(100) | YES | - |
| email_temp | varchar(150) | YES | - |
| codigo | varchar(6) | YES | - |
| codigo_expira | timestamp | YES | - |
| tentativas | integer | NO | 0 |
| created_at | timestamp | NO | now() |

**PK:** phone | **Steps:** novo, aguardando_nome, aguardando_email, aguardando_confirmacao, aguardando_cpf

---

## funcionarios
| Coluna | Tipo | Nulo | Default |
|---|---|---|---|
| id | integer | NO | autoincrement |
| phone | varchar(20) | NO | - |
| nome | varchar(100) | NO | - |
| empresa | varchar(100) | YES | - |
| ativo | boolean | NO | true |
| created_at | timestamp | NO | now() |
| email | varchar(150) | YES | - |
| cpf_cnpj | varchar(20) | YES | - |
| tipo_pagador_padrao | varchar(20) | YES | - |
| forma_pagamento_padrao | varchar(20) | YES | - |

---

## viagens
| Coluna | Tipo | Nulo | Default |
|---|---|---|---|
| id | integer | NO | autoincrement |
| phone | varchar(20) | NO | - |
| nome_viagem | varchar(255) | YES | - |
| data_inicio | timestamp | NO | - |
| data_fim | timestamp | YES | - |
| status | varchar(20) | NO | 'ativa' |
| created_at | timestamp | NO | now() |
| updated_at | timestamp | NO | now() |

**Status:** ativa | encerrada | aprovada

---

## despesas_viagem
| Coluna | Tipo | Nulo | Default |
|---|---|---|---|
| id | integer | NO | autoincrement |
| phone | varchar(20) | NO | - |
| estabelecimento | varchar(255) | YES | - |
| cnpj | varchar(20) | YES | - |
| valor_total | numeric | NO | - |
| data_emissao | date | YES | - |
| categoria | varchar(50) | NO | 'outros' |
| itens_json | text | YES | - |
| message_id | varchar(100) | YES | - |
| created_at | timestamp | NO | now() |
| tipo_pagador | varchar(20) | YES | - |
| forma_pagamento | varchar(20) | YES | - |
| cpf_cnpj_pagador | varchar(20) | YES | - |
| sem_nf | boolean | YES | false |
| validado_manualmente | boolean | YES | - |
| observacoes_validacao | text | YES | - |

**Categorias:** alimentacao | combustivel | hospedagem | transporte | pedagio | outros

---

## despesas_sem_nf_log
| Coluna | Tipo | Nulo | Default |
|---|---|---|---|
| id | integer | NO | autoincrement |
| phone | varchar(20) | YES | - |
| viagem_id | integer | YES | - |
| descricao | varchar(200) | YES | - |
| tipo_pagador | varchar(20) | YES | - |
| forma_pagamento | varchar(20) | YES | - |
| cpf_cnpj_pagador | varchar(20) | YES | - |
| valor | numeric | YES | - |
| data_compra | date | YES | - |
| criado_em | timestamp | YES | now() |
| validacao_status | varchar(20) | YES | 'pendente' |

---

## erros_dpv
| Coluna | Tipo | Nulo | Default |
|---|---|---|---|
| id | integer | NO | autoincrement |
| workflow_id | varchar(50) | NO | - |
| workflow_nome | varchar(100) | YES | - |
| no_nome | varchar(150) | YES | - |
| no_tipo | varchar(100) | YES | - |
| erro_msg | text | YES | - |
| codigo_atual | text | YES | - |
| payload_entrada | jsonb | YES | - |
| execution_id | varchar(50) | YES | - |
| execution_url | varchar(255) | YES | - |
| status | varchar(20) | NO | 'pendente' |
| fase_analise | varchar(20) | YES | - |
| correcao_aplicada | text | YES | - |
| resolvido_em | timestamp | YES | - |
| created_at | timestamp | YES | now() |

**Status:** pendente | em_analise | resolvido

---

## Observações importantes
- `cadastros_pendentes` usa phone como PK (não tem id)
- `despesas_sem_nf_log` usa `criado_em` (não `created_at`) — inconsistência herdada
- `erros_dpv` é a tabela de log do sistema — consultar no início de cada sessão
- Credencial n8n: `DB_dep_viagem` (ID: `ggViIQGkepjwuOdv`)
