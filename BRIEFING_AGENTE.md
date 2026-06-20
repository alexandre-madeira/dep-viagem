# BRIEFING_AGENTE.md — dep-viagem [DPV]
Instruções para o agente Claude Code continuar a execução.
Gerado em: 09/06/2026 | Atualizado em: 20/06/2026

---

## 1. CONTEXTO DO PROJETO

**Projeto:** dep-viagem  
**Sigla:** DPV  
**Repositório:** https://github.com/alexandre-madeira/dep-viagem  
**n8n:** https://n8n.solucaomadeira.com  
**Versão atual:** v1.0 (tag publicada no GitHub)

**O que é:** Sistema de gestão de despesas de viagem onde funcionários fotografam
notas fiscais pelo WhatsApp. Claude Vision extrai os dados, salva no PostgreSQL
e gera relatório PDF financeiro. O financeiro acessa um painel web servido pelo
próprio n8n (sem CORS) para filtrar, aprovar e visualizar relatórios.

---

## 2. STACK COMPLETA

| Componente | Tecnologia | Detalhe |
|---|---|---|
| Orquestração | n8n self-hosted | https://n8n.solucaomadeira.com |
| WhatsApp | Evolution API self-hosted | https://evolution.solucaomadeira.com |
| IA / OCR | Anthropic Claude Vision | claude-opus-4-5, credencial: Anthropic DPV (ID: fA9wqoHasCFbjdwX) |
| Banco | PostgreSQL | credencial: DB_dep_viagem (ID: ggViIQGkepjwuOdv), banco: dep_viagem |
| PDF | Gotenberg | http://gotenberg:3000 — container gotenberg na rede easypanel ✅ RODANDO |
| E-mail | MailerSend HTTP API | credencial: MAILERSEND - Header Auth account (ID: hx3Z9csTHPS00ghb) |
| Painel | HTML server-side | Rota GET /webhook/dpv-financeiro-ui — sem CORS, mobile-ready |
| Versionamento | GitHub | alexandre-madeira/dep-viagem |

---

## 3. WORKFLOWS NO N8N

| Workflow | ID | Status |
|---|---|---|
| WF-DPV.01 - Receptor de NF | z0F4H4NUyLErFjZ7 | ✅ Ativo |
| WF-DPV.02 - Extrator IA | 31hBkBVq6rduQKXM | ✅ Ativo |
| WF-DPV.03 - Controle de Viagem | ruf039UAwh9KqIZo | ✅ Ativo |
| WF-DPV.04 - Relatório PDF | acKIy44sUfDgOR2E | ✅ Ativo |
| WF-DPV.05 - Setup Banco | eIm1nVXe1qnCKhYz | ✅ Executado |
| WF-DPV.06 - Painel Financeiro | fRA3D3njIJOWmtqU | ✅ Ativo |
| WF-DPV.07 - Cadastro de Usuários | 6SwQvQ5IVL8oVtUk | ✅ Ativo (novo 19/06) |
| WF-DPV.SIM - Simulador de Testes | KeDFPVOx6DwXLk6i | ✅ Disponível |
| WF-DPV.TEST - Diagnóstico | FjiFu11QnyGSDa4o | ✅ Disponível |
| WF-DPV.MAINT - Limpeza | GFoZCyAHX0HwNAsl | ✅ Disponível |

### Credenciais ativas
- **DB_dep_viagem** (ID: `ggViIQGkepjwuOdv`) — banco dedicado dep_viagem
- **Anthropic DPV** (ID: `fA9wqoHasCFbjdwX`) — Claude Vision no WF-DPV.02
- **HEADER_API_EVOLUTION_ENVIO** (ID: `Ka0C8J4zfOklD1lw`) — instância sofia
- **MAILERSEND - Header Auth account** (ID: `hx3Z9csTHPS00ghb`) — e-mail cadastro
- **Postgres que NÃO funcionam:** DB_proj_solu, Postgres_bd_agente, db_prestconta_db, DB_supportfaqagent

---

## 4. BANCO DE DADOS

```sql
funcionarios      (id, phone UNIQUE, nome, email, empresa, ativo, created_at)
viagens           (id, phone, nome_viagem VARCHAR(255), data_inicio, data_fim, status, created_at, updated_at)
despesas_viagem   (id, phone, estabelecimento, cnpj, valor_total, data_emissao,
                   categoria, itens_json, message_id UNIQUE, created_at)
cadastros_pendentes (phone PK, step, nome_temp, email_temp, codigo,
                     codigo_expira, tentativas, criado_em, atualizado_em)
```

**Status viagem:** `ativa` | `encerrada` | `aprovada`  
**Categorias:** `alimentacao` | `combustivel` | `hospedagem` | `transporte` | `pedagio` | `outros`  
**Steps cadastro:** `aguardando_nome` | `aguardando_email` | `aguardando_confirmacao`

---

## 5. FLUXO COMPLETO ATUALIZADO

```
[WhatsApp] → mensagem recebida
    ↓
WF-DPV.01 (Webhook /dpv-whatsapp-receiver)
    ↓ SET | Normalizar Payload (phone, messageType, caption, from_me)
    ↓ IF | Ignorar Mensagens do Bot (from_me = false passa)
    ↓ DB | Verificar Funcionario
    ↓ IF | Funcionario Cadastrado?
        ├── NÃO → WF-DPV.07 (cadastro por etapas)
        │         → aguardando_nome → aguardando_email → código 6 dígitos
        │         → MailerSend envia código → confirma → INSERT funcionarios
        │
        └── SIM → SWITCH | Tipo de Mensagem
                ├── imageMessage → WF-DPV.02 (Claude Vision → INSERT despesas)
                └── conversation → WF-DPV.03
                        ├── INICIAR → INSERT viagens
                        ├── ENCERRAR → UPDATE viagens status=encerrada
                        └── RELATORIO → WF-DPV.04
                                → HTML → Gotenberg → PDF → WhatsApp

[Browser/Celular]
    ↓ GET /webhook/dpv-financeiro-ui
    → WF-DPV.06 busca banco → gera HTML completo → retorna página
    → Painel mostra viagens, despesas, categorias, botão Aprovar
```

---

## 6. PROTEÇÕES ANTI-LOOP (Evolution API)

Três camadas implementadas:

1. **`fromMe = false`** no WF-DPV.01 — filtra echo do bot no n8n
2. **Webhook configurado com `MESSAGES_UPSERT` only** — rodar ao reconectar:
```bash
curl -X PUT https://evolution.solucaomadeira.com/webhook/set/sofia \
  -H "Content-Type: application/json" \
  -H "apikey: SUA_APIKEY" \
  -d '{"url":"https://n8n.solucaomadeira.com/webhook/dpv-whatsapp-receiver","webhook_by_events":false,"webhook_base64":false,"events":["MESSAGES_UPSERT"]}'
```
3. **Anti-duplicata por `message_id`** no WF-DPV.02

---

## 7. PENDÊNCIAS

| # | Status | O que é |
|---|---|---|
| P02 | ⏳ Aguarda WhatsApp | Configurar apikey Evolution nos nós HTTP |
| P07 | ⏳ Pendente | Exportar JSONs dos 7 workflows para Git |
| P08 | ✅ Implementado 19/06 | Cadastro com e-mail — WF-DPV.07 criado |
| P15 | ✅ Resolvido 20/06 | Throw removido do WF-DPV.04; loop corrigido (WF-NOTIFY + DPV.02/03) |
| P16 | ✅ Resolvido 20/06 | Routing WF-DPV.01: CODE Merge Dados preserva messageType após DB |

### P16 — Bug Routing WF-DPV.01 (Resolvido 20/06/2026)
**Root cause:** `DB | Verificar Funcionario` usa `executeQuery` que sobrescreve `$json` com só o resultado DB `{id}`.
O `SWITCH | Tipo de Mensagem` downstream checava `$json.messageType` que era undefined → caia no NOOP.
**Fix:** Inserido `CODE | Merge Dados` (n8n-nodes-base.code, entre DB e IF) que une dados normalizados
(`$('WF-DPV.01 - SET | Normalizar Payload').item.json`) com resultado DB (`id`).
**Validado:** WF-DPV.03 executado 5x no WF-DPV.SIM — INICIAR/ENCERRAR/RELATORIO roteiam corretamente.

### P02 — Configurar API Key Evolution
Após WhatsApp ser liberado, configurar nos nós HTTP de todos os workflows.
A credencial `HEADER_API_EVOLUTION_ENVIO` (ID: `Ka0C8J4zfOklD1lw`) já existe —
verificar se a apikey está correta ou atualizar se expirou.

---

## 8. ROTEIRO DE TESTE E2E

### Sem WhatsApp (disponível agora)

**Executar WF-DPV.SIM** (`KeDFPVOx6DwXLk6i`) — cobre:
- ✅ INICIAR viagem via webhook
- ✅ INSERT despesas fake no banco
- ✅ ENCERRAR viagem
- ✅ RELATORIO (chama WF-DPV.04, falha só no Gotenberg/WhatsApp)
- ✅ Verificação do banco ao final

**Testar painel financeiro:**
```
GET https://n8n.solucaomadeira.com/webhook/dpv-financeiro-ui
```

**Testar cadastro (WF-DPV.07) via webhook:**
```bash
# Passo 1: novo número (inicia cadastro)
curl -X POST https://n8n.solucaomadeira.com/webhook/dpv-whatsapp-receiver \
  -H "Content-Type: application/json" \
  -d '{"instance":"sofia","data":{"key":{"remoteJid":"5548888880001@s.whatsapp.net","id":"TEST_CAD_001","fromMe":false},"messageType":"conversation","message":{"conversation":"Olá"}}}'

# Verificar banco: SELECT * FROM cadastros_pendentes;
# Esperado: step = 'aguardando_nome'
```

### Com WhatsApp liberado

Sequência completa de um funcionário real:

1. Primeiro contato → bot pede nome
2. Usuário digita nome → bot pede e-mail
3. Usuário digita e-mail → código enviado por e-mail
4. Usuário digita código → cadastrado, boas-vindas
5. Usuário envia `INICIAR Viagem São Paulo`
6. Usuário fotografa NF → Claude Vision extrai → confirmação
7. Usuário envia `RELATORIO` → PDF gerado → enviado via WhatsApp
8. Financeiro acessa painel → aprova viagem

**Antes de reconectar a instância:**
```bash
# 1. Configurar webhook com MESSAGES_UPSERT only (anti-loop)
curl -X PUT https://evolution.solucaomadeira.com/webhook/set/sofia \
  -H "apikey: SUA_APIKEY" \
  -H "Content-Type: application/json" \
  -d '{"url":"https://n8n.solucaomadeira.com/webhook/dpv-whatsapp-receiver","webhook_by_events":false,"webhook_base64":false,"events":["MESSAGES_UPSERT"]}'

# 2. Escanear QR code
# 3. Testar com número de teste ANTES de divulgar para funcionários reais
```

---

## 9. WORKFLOWS DE MANUTENÇÃO

| Workflow | Quando usar |
|---|---|
| WF-DPV.SIM (`KeDFPVOx6DwXLk6i`) | Testar ciclo completo sem WhatsApp |
| WF-DPV.TEST (`FjiFu11QnyGSDa4o`) | Ver estado atual do banco |
| WF-DPV.MAINT (`GFoZCyAHX0HwNAsl`) | Limpar dados de teste antes de produção |
| WF-DPV.05 (`eIm1nVXe1qnCKhYz`) | Rodar migrations de banco |

---

## 10. CHECKLIST DE ENTREGA

- [x] WF-DPV.01 a WF-DPV.06 criados e ativos
- [x] WF-DPV.07 — Cadastro com e-mail criado e ativo (19/06/2026)
- [x] Credencial DB_dep_viagem em todos os workflows
- [x] Credencial Anthropic DPV configurada (fA9wqoHasCFbjdwX)
- [x] Credencial HEADER_API_EVOLUTION_ENVIO configurada (Ka0C8J4zfOklD1lw)
- [x] Gotenberg rodando no EasyPanel (container gotenberg, porta 3000)
- [x] Filtro fromMe anti-loop no WF-DPV.01
- [x] Tabela cadastros_pendentes criada no banco
- [x] Coluna email adicionada em funcionarios
- [x] Painel financeiro server-side (sem CORS) — /webhook/dpv-financeiro-ui
- [x] Simulador de testes sem WhatsApp (WF-DPV.SIM)
- [x] Banco zerado (dados de teste removidos pelo WF-DPV.MAINT)
- [x] P15 — Loop corrigido (WF-NOTIFY→FALLBACK, DPV.02/DPV.03 sem errorWorkflow)
- [x] P16 — Routing WF-DPV.01 corrigido: CODE node Merge Dados preserva messageType após DB
- [ ] P02 — apikey Evolution atualizada nos nós HTTP (aguarda WhatsApp)
- [ ] P07 — JSONs dos 7 workflows exportados e comitados no Git
- [ ] Webhook Evolution configurado com MESSAGES_UPSERT only
- [ ] Teste e2e com WhatsApp real realizado
- [ ] Banco de produção populado com funcionários reais
