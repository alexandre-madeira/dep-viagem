# BRIEFING_AGENTE.md — dep-viagem [DPV]
Instruções para o agente Claude Code continuar a execução.
Gerado em: 09/06/2026 | Atualizado em: 18/06/2026

---

## 1. CONTEXTO DO PROJETO

**Projeto:** dep-viagem  
**Sigla:** DPV  
**Repositório:** https://github.com/alexandre-madeira/dep-viagem  
**n8n:** https://n8n.solucaomadeira.com  
**Versão atual:** v1.0 (tag publicada no GitHub)

**O que é:** Sistema de gestão de despesas de viagem onde funcionários fotografam
notas fiscais pelo WhatsApp. Claude Vision extrai os dados, salva no PostgreSQL
e gera relatório PDF financeiro. O financeiro acessa um painel React para
filtrar, aprovar e baixar relatórios.

---

## 2. STACK COMPLETA

| Componente | Tecnologia | Detalhe |
|---|---|---|
| Orquestração | n8n self-hosted | https://n8n.solucaomadeira.com |
| WhatsApp | Evolution API self-hosted | http://evolution-api:8080 |
| IA / OCR | Anthropic Claude Vision | claude-opus-4-5, credencial: ANTHROPIC_API_KEY (ID: A7kQbA9mH4B54bS4) |
| Banco | PostgreSQL | credencial: DB_dep_viagem (ID: ggViIQGkepjwuOdv), banco: dep_viagem |
| PDF | Gotenberg | http://gotenberg:3000, container gotenberg na rede easypanel |
| E-mail | MailerSend (HTTP API) | credencial: MAILERSEND - Header Auth account (ID: hx3Z9csTHPS00ghb) |
| Painel | React JSX | arquivo: painel/painel-financeiro-dpv.jsx |
| Versionamento | GitHub | alexandre-madeira/dep-viagem |

---

## 3. WORKFLOWS NO N8N

| Workflow | ID | URL |
|---|---|---|
| WF-DPV.01 - Receptor de NF | z0F4H4NUyLErFjZ7 | https://n8n.solucaomadeira.com/workflow/z0F4H4NUyLErFjZ7 |
| WF-DPV.02 - Extrator IA | 31hBkBVq6rduQKXM | https://n8n.solucaomadeira.com/workflow/31hBkBVq6rduQKXM |
| WF-DPV.03 - Controle de Viagem | ruf039UAwh9KqIZo | https://n8n.solucaomadeira.com/workflow/ruf039UAwh9KqIZo |
| WF-DPV.04 - Relatório PDF | acKIy44sUfDgOR2E | https://n8n.solucaomadeira.com/workflow/acKIy44sUfDgOR2E |
| WF-DPV.05 - Setup Banco | eIm1nVXe1qnCKhYz | https://n8n.solucaomadeira.com/workflow/eIm1nVXe1qnCKhYz |
| WF-DPV.06 - Painel Financeiro | fRA3D3njIJOWmtqU | https://n8n.solucaomadeira.com/workflow/fRA3D3njIJOWmtqU |

### Credenciais conhecidas
- **Postgres que funciona:** `DB_dep_viagem` (ID: `ggViIQGkepjwuOdv`) — banco dedicado `dep_viagem`
- **Postgres que NÃO funcionam:** DB_proj_solu, Postgres_bd_agente, db_prestconta_db, DB_supportfaqagent
- **Anthropic:** `ANTHROPIC_API_KEY` (ID: `A7kQbA9mH4B54bS4`) — já configurada no WF-DPV.02
- **Evolution API:** `HEADER_API_EVOLUTION_ENVIO` (ID: `Ka0C8J4zfOklD1lw`) — instância `sofia`
- **MailerSend:** `MAILERSEND - Header Auth account` (ID: `hx3Z9csTHPS00ghb`) — domínio trial testado e funcionando
- **SMTP:** NÃO usar — VPS bloqueia portas 465/587 de saída em containers Docker
- **n8n REST API:** ✅ Confirmado — JWT em `C:\Users\Alexandre\.claude\settings.json` (campo `mcpServers.n8n.headers.Authorization`). Usar como `X-N8N-API-KEY` nas chamadas REST. Exemplo:
  ```powershell
  $s = Get-Content "$env:USERPROFILE\.claude\settings.json" | ConvertFrom-Json
  $key = $s.mcpServers.n8n.headers.Authorization -replace "Bearer ", ""
  Invoke-WebRequest "https://n8n.solucaomadeira.com/api/v1/workflows?limit=250" -Headers @{"X-N8N-API-KEY"=$key}
  ```
- **n8n MCP global:** ✖ Não usar. n8n 2.25.7 usa MCP por workflow (nó "MCP Server Trigger"), não endpoint global. O `/mcp-server/http` rejeita o JWT do REST API. Solução: REST API direta é suficiente.

---

## 4. BANCO DE DADOS

**Tabelas criadas e funcionando:**
```sql
funcionarios    (id, phone UNIQUE, nome, empresa, ativo, created_at)
viagens         (id, phone, nome_viagem, data_inicio, data_fim, status, created_at, updated_at)
despesas_viagem (id, phone, estabelecimento, cnpj, valor_total, data_emissao,
                 categoria, itens_json, message_id, created_at)
```

**Status:** `ativa` | `encerrada` | `aprovada`  
**Categorias:** `alimentacao` | `combustivel` | `hospedagem` | `transporte` | `pedagio` | `outros`

---

## 5. PENDÊNCIAS ABERTAS

### RESOLVIDAS (histórico)

| Pendência | O que era | Resolução |
|---|---|---|
| P02 | API Key Evolution nos workflows | Credencial `HEADER_API_EVOLUTION_ENVIO` (ID: Ka0C8J4zfOklD1lw) aplicada |
| P03 | Credencial Anthropic no n8n | `ANTHROPIC_API_KEY` (ID: A7kQbA9mH4B54bS4) aplicada no WF-DPV.02 |
| P04 | Gotenberg não estava rodando | `docker run gotenberg/gotenberg:8 --network easypanel` — container `gotenberg` ativo |

---

### ~~P06 — Trocar senha do painel financeiro~~ ✅ RESOLVIDO
**Resolvido em:** 14/06/2026 via REST API PUT /api/v1/workflows/fRA3D3njIJOWmtqU  
**Senha `SENHA_CONFIGURADA_NO_N8N` substituída.** Nova senha no gerenciador de senhas do usuário.  
**Script reutilizável:** `scripts/atualizar_senha_painel.ps1` (sem valor hardcoded)  
**Nota técnica:** PUT requer `settings: {executionOrder}` apenas — campos extras (`binaryMode`, `availableInMCP`) são rejeitados pela API.

```bash
# referência histórica — já executado
n8n:update_workflow workflowId=fRA3D3njIJOWmtqU
  type: setNodeParameter
  nodeName: "WF-DPV.06 - IF | Autenticacao Valida?"
  path: "/conditions/conditions/0/rightValue"
  value: "NOVA_SENHA"
```

---

### P14 — Ciclo de autocorreção n8n_contratos ✅ CONFIGURADO (18/06/2026)

**O que é:** Quando um nó DPV falha, Claude recebe contexto mínimo e reconstrói o código automaticamente.

**Infraestrutura ativada:**
- `projetos.wf_fix_habilitado = true` para `dep-viagem`
- `errorWorkflow = 6LU8TtukzsbgGCHe` (WF-ERR-CTX) configurado nos 6 WF-DPV
- `node_test_contract`: 141 nós sincronizados com node_id = nome completo do nó
- `arquitetura` nível A: 4 requisitos (stack, banco, credenciais, anti-duplicata)
- `arquitetura` nível B: 6 requisitos (um por workflow DPV)
- `arquitetura` nível C: 10 requisitos (5 por Code node: WF-DPV.04 e WF-DPV.06)
- `@contract` annotations: adicionadas em WF-DPV.04 e WF-DPV.06 Code nodes

**Fluxo quando um nó falha:**
```
Erro em WF-DPV → errorWorkflow → WF-ERR-CTX (6LU8TtukzsbgGCHe)
  → busca código + payload da execução
  → WF-FIX (lê arquitetura A+B+C do banco)
  → Claude API (claude-sonnet-4-5, max 2000 tokens)
  → aplica código corrigido via PUT /api/v1/workflows
  → WF-NOTIFY → WhatsApp instância sofia
```

**Custo por fix:** ~$0,006 (contexto mínimo, sem leitura de arquivos)

**Fixes feitos nos workflows de infra (via REST API):**
- WF-ADMIN: `node_id` agora usa nome completo do nó (não prefixo curto)
- WF-ERR-CTX.01: `node_id` e `node_name` extraem nome completo
- WF-ERR-CTX.04: `downstream` e `nos_anteriores` usam nome completo
- WF-DPV.06 Code node: nome corrigido de `Instru??es ZIP` → `Instruções ZIP`

**ATENÇÃO — Pendente P15:**
`throw new Error('TESTE_CICLO')` está injetado no WF-DPV.04 CODE node (após `@end-contract`).
Deve ser removido após validar o ciclo end-to-end.
Para remover via API:
```powershell
# Ler raw JSON, remover a linha do throw, PUT com UTF-8 bytes
$raw = (Invoke-WebRequest "https://n8n.solucaomadeira.com/api/v1/workflows/acKIy44sUfDgOR2E" -Headers $hdr -UseBasicParsing).Content
$fixed = $raw.Replace("throw new Error('TESTE_CICLO — remover apos validacao');\n\n", "")
# PUT com UTF-8 bytes conforme padrão desta sessão
```

---

### P07 — Exportar workflows como JSON para o Git
**O que fazer:** Exportar os 6 JSONs do n8n e commitar em `workflows/`

```bash
# Na pasta C:\GITHUB\DPV após exportar os arquivos:
git add workflows/
git commit -m "wf: exportar workflows DPV v1.0"
git push
```

---

### P08 — Cadastro de usuários com validação por e-mail
**O que é:** Novos números do WhatsApp devem se cadastrar antes de usar o sistema.  
**Fluxo:** novo número → pede nome → pede e-mail → envia código de 6 dígitos via MailerSend → confirma código → cadastrado  
**Tabelas a criar:**
```sql
-- Em: C:\GITHUB\DPV\database\migrations\ (novo arquivo v3_cadastro_usuarios.sql)
ALTER TABLE funcionarios ADD COLUMN IF NOT EXISTS email VARCHAR(150);

CREATE TABLE IF NOT EXISTS cadastros_pendentes (
  phone       VARCHAR(20) PRIMARY KEY,
  step        VARCHAR(30) NOT NULL DEFAULT 'aguardando_nome',
  nome_temp   VARCHAR(100),
  email_temp  VARCHAR(150),
  codigo      VARCHAR(6),
  codigo_expira TIMESTAMP,
  tentativas  INT DEFAULT 0,
  criado_em   TIMESTAMP DEFAULT NOW()
);
-- steps: aguardando_nome | aguardando_email | aguardando_confirmacao
```
**Onde implementar:** WF-DPV.01 → nó de switch inicial, antes de rotear para WF-DPV.02 ou WF-DPV.03  
**Email:** MailerSend via HTTP API — credencial `MAILERSEND - Header Auth account` (ID: `hx3Z9csTHPS00ghb`)  
**Domínio remetente:** `noreply@test-eqvygm0x5d8l0p7w.mlsender.net`

---

### P09 — Diagnóstico e2e concluído (14/06/2026)
**Resultado:**
- Gotenberg: ✅ UP (`chromium: up`, testado via `node` dentro do container n8n)
- Evolution API: ✅ Servidor acessível (`https://evolution.solucaomadeira.com` responde 401 = chave errada, server OK)
- WF-DPV.01: ✅ Ativo e recebendo mensagens reais (5 execuções hoje)
- WF-DPV.06: ✅ API diz ativo / ❌ webhook retorna 404 (nunca executou)
- Falhas encontradas → mapeadas em P11, P12, P13

---

### ~~P11 — VARCHAR(100) overflow no WF-DPV.01~~ ✅ RESOLVIDO
**Resolvido em:** 15/06/2026 via Adminer (ALTER TABLE)  
**Causa:** texto da mensagem WhatsApp passada como `nome_viagem` excedia 100 chars  
**Fix aplicado:** `ALTER TABLE viagens ALTER COLUMN nome_viagem TYPE VARCHAR(255);`  
**Confirmado em Adminer:** coluna agora tipo `character varying(255)`  
**Migration registrada:** `database/migrations/v3_nome_viagem_varchar255.sql`

---

### ~~P12 — WF-DPV.06 webhook 404~~ ✅ RESOLVIDO (15/06/2026)
**Causa raiz:** n8n em queue mode não faz pattern matching em paths dinâmicos (`:acao`).
O processo `n8n webhook` faz lookup literal — `dpv-financeiro/auth` não encontra `dpv-financeiro/:acao`.

**Fixes aplicados:**
1. DNS A record `webhook.solucaomadeira.com → 72.60.254.147` adicionado na Hostinger
2. WF-DPV.06 webhook path: `dpv-financeiro/:acao` → `dpv-financeiro` (path estático)
3. WF-DPV.06 SWITCH node: `$json.params.acao` → `$json.body.acao` (todas as 5 regras, via REST API)
4. Painel React: `API_BASE` atualizado para `webhook.solucaomadeira.com`, `acao` movida para o body JSON

**Confirmado funcionando:**
```bash
curl -k -s -X POST https://webhook.solucaomadeira.com/webhook/dpv-financeiro \
  -H "Content-Type: application/json" \
  -d '{"acao":"auth","senha":"teste"}'
# → {"ok":false,"erro":"Senha incorreta"}  ✅ workflow executou
```

---

### ~~P13 — SSL webhook.solucaomadeira.com~~ ✅ RESOLVIDO (16/06/2026)
**Problema:** Traefik router `https-n8n_n8n_webhook-0@file` tem `certificateResolver` errado.  
**Erro no log Traefik:**
```
ERR Router uses a nonexistent certificate resolver
certificateResolver=AAAAC3NzaC1lZDI1NTE5AAAAIKAqF/R5N+/BCviQpAW1kkrAiOje4fHPHTF0sJa4Sfuk
routerName=https-n8n_n8n_webhook-0@file
```
O valor parece uma chave SSH em vez de `letsencrypt`. Let's Encrypt nunca emite o cert.

**Status 16/06/2026:**
- Arquivo de config: `/etc/easypanel/traefik/config/main.yaml` (montado em `/data` no container)
- Fix aplicado via SSH:
```bash
sed -i 's/"certResolver": "AAAAC3[^"]*"/"certResolver": "letsencrypt"/g' /etc/easypanel/traefik/config/main.yaml
```
- Confirmado: `certResolver` do router `https-n8n_n8n_webhook-0` agora é `letsencrypt`

**Próximo passo — retomar aqui:**
```bash
docker restart $(docker ps --filter name=traefik -q) && sleep 30 && \
curl -s -X POST https://webhook.solucaomadeira.com/webhook/dpv-financeiro \
  -H "Content-Type: application/json" \
  -d '{"acao":"auth","senha":"teste"}'
```
Se retornar `{"ok":false,"erro":"Senha incorreta"}` sem erro SSL → P13 resolvido → testar painel no browser.

---

### P10 — MCP do n8n: JWT rejeitado no endpoint `/mcp-server/http`
**O que é:** A API REST do n8n funciona com o JWT como `X-N8N-API-KEY`. Mas o endpoint MCP `/mcp-server/http` exige `Authorization: Bearer` e rejeita o mesmo JWT com `{"message":"Unauthorized"}`.  
**Diagnóstico via SSH:**
```bash
# 1. Identificar container n8n
docker ps | grep n8n

# 2. Checar env vars MCP no container web
docker exec {n8n_web} env | grep -iE 'MCP|VERSION|API'
```
**Resultado esperado:** procurar variáveis como `N8N_MCP_*` ou confirmar versão do n8n.  
**Alternativa se o built-in MCP não funcionar:** usar n8n-mcp como processo local (stdio):
```json
{
  "mcpServers": {
    "n8n": {
      "command": "npx",
      "args": ["-y", "n8n-mcp"],
      "env": { "N8N_HOST": "https://n8n.solucaomadeira.com", "N8N_API_KEY": "JWT_AQUI" }
    }
  }
}
```

---

## 6. FLUXO DE DADOS COMPLETO

```
[WhatsApp] → foto NF
    ↓
WF-DPV.01 (Webhook /dpv-whatsapp-receiver)
    ↓ verifica messageType
    ├── imageMessage → WF-DPV.02
    │       ↓ verifica duplicata (message_id)
    │       ↓ baixa imagem via Evolution API
    │       ↓ Claude Vision extrai dados
    │       ↓ INSERT despesas_viagem
    │       ↓ busca nome em funcionarios
    │       ↓ envia confirmação WhatsApp
    │
    └── conversation → WF-DPV.03
            ↓ normaliza comando (UPPERCASE)
            ├── INICIAR → INSERT viagens (nome_viagem extraído do texto)
            ├── ENCERRAR → UPDATE viagens SET data_fim, status=encerrada
            └── RELATORIO → WF-DPV.04
                    ↓ SELECT despesas + JOIN viagens
                    ↓ gera HTML financeiro (Code node)
                    ↓ Gotenberg converte HTML→PDF
                    ↓ envia PDF pelo WhatsApp
                    ↓ notifica gestor

[Navegador] → painel financeiro
    ↓
WF-DPV.06 (Webhook /dpv-financeiro/:acao)
    ↓ verifica senha
    ├── /auth → valida senha
    ├── /viagens → SELECT viagens + despesas + funcionarios
    ├── /relatorio-pdf → chama WF-DPV.04
    ├── /zip-nfs → retorna metadados das NFs em ordem
    └── /aprovar → UPDATE viagens SET status=aprovada
```

---

## 7. CONVENÇÕES DO PROJETO

### Nomenclatura de workflows
```
WF-DPV.NN - Descrição [dep-viagem]
```

### Nomenclatura de nós
```
WF-DPV.NN - TIPO | Descrição
```
Tipos: `TRIGGER` `SET` `SWITCH` `IF` `HTTP` `DB` `EXEC` `AGENT` `CODE` `AGG` `RESPOND` `NOOP` `PARSER` `LLM`

### Commits Git
```
tipo: descrição em minúsculas

Tipos: init | feat | fix | wf | db | docs | config | painel | hotfix
```

---

## 8. ORDEM DE EXECUÇÃO RECOMENDADA

Execute nesta sequência para colocar o sistema em produção:

1. **Verificar Gotenberg** — `curl http://gotenberg:3000/health`
2. **Obter API Key Evolution** — painel da instância
3. **Criar credencial Anthropic** no n8n
4. **Configurar apikey Evolution** nos nós HTTP (P02)
5. **Aplicar credencial Anthropic** no WF-DPV.02 (P03)
6. **Trocar senha** do painel (P06)
7. **Ativar WF-DPV.01** no n8n (toggle ON)
8. **Testar fluxo completo:**
   - Enviar foto de NF pelo WhatsApp
   - Verificar se despesa foi salva no banco
   - Enviar "RELATORIO" e verificar PDF
   - Acessar painel financeiro e verificar dados
9. **Exportar JSONs** dos workflows → commitar no Git (P07)
10. **Commitar** configurações finais

---

## 9. ARQUIVOS NO REPOSITÓRIO LOCAL

```
C:\GITHUB\DPV\
├── .gitignore
├── README.md
├── SETUP_LOCAL.md
├── BRIEFING_AGENTE.md          ← este arquivo
├── database\
│   ├── README.md
│   ├── setup.sql               ← DDL completo v1+v2
│   ├── seeds.sql               ← dados de teste
│   └── migrations\
│       ├── v1_criacao_inicial.sql
│       ├── v2_nome_viagem.sql
│       └── v3_nome_viagem_varchar255.sql  ← P11 fix
├── docs\
│   ├── ARQUITETURA.md
│   ├── GIT_PROCESSO.md
│   ├── PENDENCIAS.md
│   └── PROTOCOLO_dep-viagem.md
├── painel\
│   ├── README.md
│   └── painel-financeiro-dpv.jsx
└── workflows\
    └── IDS.md                  ← adicionar WF-DPV-NN.json aqui
```

---

## 10. CHECKLIST DE ENTREGA

- [x] WF-DPV.01 criado no n8n
- [x] WF-DPV.02 criado com anti-duplicata e nome do funcionário
- [x] WF-DPV.03 criado com suporte a nome_viagem
- [x] WF-DPV.04 criado com Gotenberg + notificação gestor
- [x] WF-DPV.05 executado — tabelas criadas
- [x] WF-DPV.06 criado — backend do painel
- [x] Subworkflows vinculados (01→02, 01→03, 03→04, 06→04)
- [x] Credencial DB_dep_viagem em todos os workflows
- [x] imageUrl mapeado no payload Evolution
- [x] Tabela funcionarios criada
- [x] Campo nome_viagem adicionado
- [x] Painel React dark theme completo
- [x] Repositório GitHub criado e com push
- [x] Tag v1.0 publicada
- [x] P02 — API Key Evolution configurada (credencial Ka0C8J4zfOklD1lw)
- [x] P03 — Credencial Anthropic criada no n8n (ID: A7kQbA9mH4B54bS4)
- [x] P04 — Gotenberg rodando (container gotenberg, rede easypanel)
- [x] P06 — Senha do painel financeiro atualizada via REST API (WF-DPV.06)
- [ ] P07 — JSONs dos workflows exportados e comitados
- [ ] P08 — Cadastro de usuários com validação por e-mail
- [x] P09 — Diagnóstico e2e concluído (14/06/2026) — falhas mapeadas, ver P11–P13 abaixo
- [x] P10 — MCP global descartado. Acesso n8n via REST API direta (JWT em settings.json)
- [x] WF-DPV.01 ativado (toggle ON) — recebendo mensagens (5 execuções registradas)
- [x] P11 — nome_viagem VARCHAR(255) (migration v3 aplicada via Adminer, 15/06/2026)
- [x] P12 — webhook funciona: path estático, acao no body, domínio webhook.solucaomadeira.com
- [x] P13 — SSL webhook.solucaomadeira.com válido (Let's Encrypt emitido, 16/06/2026)
- [x] P14 — Ciclo de autocorreção n8n_contratos integrado ao DPV (18/06/2026)
- [ ] P15 — Testar ciclo erro→fix→notify end-to-end (throw injetado em WF-DPV.04)
