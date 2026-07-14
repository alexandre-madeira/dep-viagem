# ARQUITETURA DEP-VIAGEM (DPV) v1.0

> Gerado em 14/07/2026 a partir do banco `n8n_contratos` (credencial `DB_n8n_contratos`,
> uso pontual autorizado para esta consulta) e do estado real do repositório `dep-viagem`.

## 1. OBJETIVOS DO SISTEMA (F1)

| Componente | Requisito | Workflow |
|---|---|---|
| OBJ-01 | Funcionário fotografa NF via WhatsApp — sistema extrai dados automaticamente | — |
| OBJ-02 | Dados extraídos passam por fluxo guiado: quem pagou / como pagou / observação | — |
| OBJ-03 | Despesas salvas com divisão empresa/funcionário/cliente e desconto automático de bebida | — |
| OBJ-04 | Funcionário controla viagem via texto: INICIAR, ENCERRAR, REABRIR, RELATORIO, CORRIGIR ULTIMA | — |
| OBJ-05 | Sistema gera PDF de prestação de contas e envia via WhatsApp | — |
| OBJ-06 | Painel web permite ao financeiro visualizar, aprovar e rejeitar despesas por viagem | — |
| OBJ-07 | Novo usuário é cadastrado automaticamente via fluxo WhatsApp: nome > email > código > CPF | — |
| OBJ-08 | Todas as mensagens processadas uma única vez — deduplicação por messageId | — |
| OBJ-09 | Relatório PDF deve incluir anexo com imagens de todas as NFs da viagem em ordem cronológica | WF-DPV.04 |

## 2. WORKFLOWS (F2)

| Sigla | Alias | Papel | Workflow ID | Requisito |
|---|---|---|---|---|
| WF-DPV.01 | Receptor de Mensagens | entrada | `z0F4H4NUyLErFjZ7` | Ponto de entrada único. Recebe webhook Evolution API, filtra, deduplica e roteia |
| WF-DPV.02 | Extrator IA | processamento | `31hBkBVq6rduQKXM` | Recebe imagem NF, descriptografa via `getBase64FromMediaMessage`, envia ao Claude Vision, valida e salva pendente |
| WF-DPV.03 | Handler Comandos | processamento | `ruf039UAwh9KqIZo` | Processa textos WhatsApp: comandos de viagem e respostas do fluxo guiado pós-NF |
| WF-DPV.04 | Gerador PDF | saída | `acKIy44sUfDgOR2E` | Gera HTML com dados da viagem, converte para PDF via Gotenberg e envia via WhatsApp |
| WF-DPV.05 | Setup Banco | infra | `eIm1nVXe1qnCKhYz` | Criação e migração das tabelas do banco `dep_viagem` — execução manual |
| WF-DPV.06 | Painel Financeiro | saída | `fRA3D3njIJOWmtqU` | Backend do painel web: autentica, lista viagens/despesas, aprova/rejeita |
| WF-DPV.07 | Cadastro Usuários | entrada | `6SwQvQ5IVL8oVtUk` | Fluxo conversacional WhatsApp para cadastrar novo funcionário em 5 etapas |
| WF-DPV.CHK | Verificador Estado | infra | `1c8Ag8NgvtOiRYr7` | Verificação rápida do estado do sistema: erros pendentes (`erros_dpv`) + resumo do banco |
| WF-ERR-CTX | Error Context Handler | infra | `6LU8TtukzsbgGCHe` | Captura contexto de erro dos workflows DPV e grava em `erros_dpv` |
| WF-ADMIN | Admin Sync | infra | `OUbFTiwtY485IHxt` | Sincronização administrativa (registro em `workflow_registro`/`n8n_contratos`) |

## 3. REQUISITOS POR NÓ (F3)

| Componente | Requisito | Workflow |
|---|---|---|
| `AGENT \| Extrair Dados da NF` | Prompt deve incluir data atual para inferência correta do ano da nota fiscal | WF-DPV.02 |
| `CODE \| Processar Fluxo Guiado` | Máquina de estados: `aguardando_pagador > aguardando_forma > aguardando_observacao > aguardando_divisao` | WF-DPV.03 |
| `CODE \| Validar Combinacao` | `cpf_cnpj_pagador` é opcional — não bloquear quando null. Data máxima 90 dias | WF-DPV.02 |
| `DB \| Buscar Despesa Pendente` | `alwaysOutputData=true` obrigatório | WF-DPV.03 |
| `DB \| Dedup Mensagem` | `INSERT ON CONFLICT DO NOTHING` — tabela `mensagens_processadas` com UNIQUE em `message_id` | WF-DPV.01 |
| `DB \| Reabrir Viagem no Postgres` | `alwaysOutputData=true` obrigatório | WF-DPV.03 |
| `DB \| Salvar Despesa Final` | Colunas obrigatórias: `valor_empresa`, `valor_funcionario`, `tipo_despesa` — credencial `DB_dep_viagem` | WF-DPV.03 |
| `DB \| Verificar Funcionario` | `alwaysOutputData=true` obrigatório — zero linhas não deve parar execução | WF-DPV.01 |
| `HTTP \| Baixar Imagem da NF` | Usar `getBase64FromMediaMessage` — nunca baixar URL `.enc` diretamente | WF-DPV.02 |
| `HTTP \| Converter HTML para PDF` | Arquivo deve se chamar exatamente `index.html` no multipart — Gotenberg `http://gotenberg:3000` | WF-DPV.04 |
| `TODOS DB` | Credencial obrigatória: `DB_dep_viagem` (ID: `ggViIQGkepjwuOdv`) — nunca `DB_proj_solu` ou outros | — |
| `TODOS HTTP Evolution API` | Credencial: `HEADER_API_EVOLUTION_ENVIO` (ID: `Ka0C8J4zfOklD1lw`) — instância `VIDROCOM_AG` | — |

## 4. BACKLOG ABERTO

> ⚠️ **Discrepância detectada:** a tabela `backlog` em `n8n_contratos` ainda marca os 9 itens
> abaixo como `status='ABERTO'`, mas todos já foram implementados e fechados no repositório
> (`alexandre-madeira/dep-viagem`, issues #2–#9, commits `4815566`, `071b018`, `0bdfee2` e a
> sessão de 09/07/2026 registrada em `755db89`). A tabela de origem está desatualizada e não
> foi corrigida por esta tarefa (fora de escopo — banco de outro projeto). Recomenda-se
> atualizar `status` para `FECHADO` em `n8n_contratos.backlog` numa sessão futura autorizada.

| Fix ID | Descrição | Prioridade | Status (n8n_contratos) | Status real (repo) |
|---|---|---|---|---|
| BUG-01 | Respostas numéricas do rodapé (1=CORRIGIR ULTIMA, 2=ENCERRAR VIAGEM) não reconhecidas pelo SWITCH de comandos | ALTO | ABERTO | Fechado (09/07/2026) |
| ISSUE-02 | Permitir correção de despesa após confirmação — comando CORRIGIR ULTIMA | ALTO | ABERTO | Fechado (`4815566`) |
| ISSUE-03 | Respostas numéricas no fluxo guiado — usuário responde 1/2/3 em vez de texto | ALTO | ABERTO | Fechado (09/07/2026) |
| ISSUE-04 | Detectar bebida alcoólica por marca comercial: BRAHMA, HEINEKEN, SKOL etc | MEDIO | ABERTO | Fechado (09/07/2026) |
| ISSUE-05 | Adicionar tipo cliente no pagador — separar despesas a cobrar do cliente no relatório | MEDIO | ABERTO | Fechado (09/07/2026, migration v10) |
| ISSUE-06 | Reabrir viagem encerrada para anexar mais NF — comando REABRIR VIAGEM | MEDIO | ABERTO | Fechado (09/07/2026) |
| ISSUE-07 | Nome da viagem com formato cidade_obra — ano adicionado automaticamente | BAIXO | ABERTO | Fechado (09/07/2026) |
| ISSUE-08 | Datas reais da viagem baseadas nas notas fiscais — primeira e última NF | BAIXO | ABERTO | Fechado (`071b018`) |
| ISSUE-09 | Melhorar layout do relatório PDF com tabela detalhada por despesa | BAIXO | ABERTO | Fechado (`0bdfee2`) |

## 5. CREDENCIAIS E INFRA

| Item | Valor |
|---|---|
| Credencial Evolution API | `HEADER_API_EVOLUTION_ENVIO` (ID: `Ka0C8J4zfOklD1lw`) — instância `VIDROCOM_AG` |
| Credencial banco | `DB_dep_viagem` (ID: `ggViIQGkepjwuOdv`) |
| Credencial Anthropic | `Anthropic DPV` (ID: `fA9wqoHasCFbjdwX`) |
| Gotenberg | `http://gotenberg:3000` |
| n8n | `https://n8n.solucaomadeira.com` |
| Evolution API | `https://evolution.solucaomadeira.com` |

**Nunca** usar a credencial `DB_n8n_contratos` (ID: `3z35ZPyLInGNam1Y`) em workflows DPV —
ela pertence a outro banco/projeto e só foi usada nesta sessão, em modo leitura, para gerar
as seções 1–4 deste documento a partir de `n8n_contratos.arquitetura/backlog/workflow_registro`.

## 6. BANCO DE DADOS

Estrutura completa do banco `dep_viagem` — ver `docs/BANCO_DEP_VIAGEM.md` (fonte da verdade,
atualizada em 06/07/2026).

### Tabelas

- **cadastros_pendentes** — PK `phone`. Steps: novo, aguardando_nome, aguardando_email, aguardando_confirmacao, aguardando_cpf
- **funcionarios** — id, phone, nome, empresa, ativo, email, cpf_cnpj, tipo_pagador_padrao, forma_pagamento_padrao
- **viagens** — id, phone, nome_viagem, data_inicio, data_fim, status (`ativa` | `encerrada` | `aprovada`)
- **despesas_viagem** — id, phone, estabelecimento, cnpj, valor_total, data_emissao, categoria, itens_json, message_id, tipo_pagador, forma_pagamento, cpf_cnpj_pagador, sem_nf, validado_manualmente, observacoes_validacao, tipo_despesa (migration v10)
- **despesas_sem_nf_log** — id, phone, viagem_id, descricao, tipo_pagador, forma_pagamento, cpf_cnpj_pagador, valor, data_compra, criado_em (⚠️ não `created_at`), validacao_status
- **erros_dpv** — id, workflow_id, workflow_nome, no_nome, no_tipo, erro_msg, codigo_atual, payload_entrada, execution_id, execution_url, status (`pendente` | `em_analise` | `resolvido`), fase_analise, correcao_aplicada, resolvido_em, created_at

### Observações

- `cadastros_pendentes` usa `phone` como PK (não tem `id`)
- `despesas_sem_nf_log` usa `criado_em` (não `created_at`) — inconsistência herdada
- `erros_dpv` é a tabela de log do sistema — consultar no início de cada sessão (protocolo `CLAUDE.md`)
- ⚠️ O protocolo de início de sessão do `CLAUDE.md` (`SELECT id, origem, workflow_id, descricao, ultimo_no, payload_json ...`) referencia colunas (`origem`, `ultimo_no`, `payload_json`) que não existem no schema real de `erros_dpv`. A query correta, de fato usada pelo `WF-DPV.CHK`, é a que consta acima (`workflow_nome`, `no_nome`, `erro_msg`, `codigo_atual`). Vale corrigir o `CLAUDE.md` numa sessão futura.
