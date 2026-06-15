# PROCESSO_PROJETOS.md — IATECH
Processo padrão para criação e manutenção de projetos no ambiente IATECH.
Versão: 1.1 — Atualizado em: 14/06/2026
Baseado em: aprendizados do projeto dep-viagem (DPV) + alinhamento Claude LLM

---

## 1. PRINCÍPIOS DO AMBIENTE

### Três camadas de verdade

| Camada | Responsabilidade | Ferramenta |
|---|---|---|
| **Intenção** | O que foi projetado, aprovado e versionado | Git / GitHub |
| **Execução** | Estado vivo dos workflows e automações | n8n (banco interno) |
| **Dados** | Dados operacionais do negócio | PostgreSQL (banco do projeto) |

**Regra fundamental:** cada camada tem sua própria fonte de verdade. Não sincronizar automaticamente — sincronizar em marcos deliberados (fim de sprint, entrega de versão).

**Por que nunca usar SQL direto no banco interno do n8n:**
o banco interno usa estrutura proprietária e pode ser sobrescrito pelo próprio n8n. SQL direto bypassa validações e pode corromper estado. Sempre usar a API REST (via n8n-mcp ou curl).

### Dois agentes, sem contexto compartilhado

| Agente | Papel | Acessa |
|---|---|---|
| **Claude LLM** (claude.ai) | Orientação estratégica, arquitetura, revisão | Git + BRIEFING_AGENTE.md |
| **Claude Code** | Execução técnica: criar workflows, SQL, código | Git + n8n-mcp + SSH/bash |

A ponte entre os dois é o **Git**. Todo alinhamento estratégico que o LLM produz deve ser commitado antes que o Code comece a executar.

**Fluxo correto:**
```
LLM arquiteta → commita BRIEFING → Code executa → commita IDs e estado real → LLM revisa
```

---

## 2. SETUP ÚNICO DO AMBIENTE (fazer uma vez)

### 2.1 N8N_API_KEY

```bash
# No servidor, adicionar ao docker-compose ou .env do n8n:
N8N_API_KEY=sua_chave_aqui

# Verificar se a API está acessível:
curl https://n8n.solucaomadeira.com/api/v1/workflows \
  -H "X-N8N-API-KEY: $N8N_API_KEY"
```

### 2.2 n8n-mcp — registro no Claude Code

Arquivo: `C:\Users\{usuario}\.claude\settings.json`:

```json
{
  "mcpServers": {
    "n8n": {
      "url": "https://n8n.solucaomadeira.com/mcp-server/http",
      "apiKey": "SUA_N8N_API_KEY"
    }
  }
}
```

Com isso o Claude Code acessa o n8n via MCP sem SSH e sem SQL direto no banco interno.

### 2.3 Email transacional (MailerSend)

SMTP está bloqueado neste servidor (VPS bloqueia portas 465/587 de saída).
Usar MailerSend via HTTPS (porta 443 — nunca bloqueada):

- Conta: `solucaosacadas@gmail.com` em `mailersend.com`
- Domínio trial: `test-eqvygm0x5d8l0p7w.mlsender.net`
- Credencial n8n: `MAILERSEND_dep_viagem` (Header Auth, `Authorization: Bearer TOKEN`)
- Remetente padrão: `noreply@test-eqvygm0x5d8l0p7w.mlsender.net`

### 2.4 Tabela central de projetos (PostgreSQL)

Criar no banco `n8n_contratos`:

```sql
CREATE TABLE IF NOT EXISTS projetos_iatech (
  sigla         VARCHAR(10) PRIMARY KEY,
  nome          VARCHAR(100) NOT NULL,
  repo_github   TEXT,
  banco_pg      VARCHAR(100),
  n8n_url       TEXT,
  status        VARCHAR(20) DEFAULT 'ativo',
  versao        VARCHAR(20),
  criado_em     TIMESTAMP DEFAULT NOW(),
  atualizado_em TIMESTAMP DEFAULT NOW(),
  notas         TEXT
);

-- Registrar DPV
INSERT INTO projetos_iatech VALUES (
  'DPV', 'dep-viagem',
  'https://github.com/alexandre-madeira/dep-viagem',
  'dep_viagem',
  'https://n8n.solucaomadeira.com',
  'ativo', 'v1.0',
  NOW(), NOW(),
  'Pendências: P06 senha painel, cadastro usuários, teste E2E'
);
```

Esta tabela serve como índice — não substitui o BRIEFING, permite que uma sessão nova descubra quais projetos existem antes de buscar o Git.

---

## 3. PROCESSO DE NOVO PROJETO — PASSO A PASSO

### Fase 0 — Identidade (Claude LLM)

```
1. Definir nome e sigla (ex: dep-viagem / DPV)
2. Definir objetivo em uma frase
3. Mapear stack necessária
4. Criar repositório GitHub: alexandre-madeira/{nome}
5. Registrar na tabela projetos_iatech
6. Commitar estrutura inicial de pastas
```

Estrutura mínima a commitar no `init`:

```
{nome}/
├── BRIEFING_AGENTE.md      ← gerado no final da Fase 0
├── README.md
├── SETUP_LOCAL.md
├── .gitignore
├── database/
│   ├── setup.sql           ← DDL completo
│   └── migrations/
├── docs/
│   ├── ARQUITETURA.md
│   ├── PENDENCIAS.md
│   └── PROCESSO_PROJETOS.md ← referência ao processo global
├── workflows/
│   └── IDS.md              ← IDs dos workflows n8n
└── painel/                 ← se houver frontend
```

### Fase 1 — Arquitetura (Claude LLM)

```
1. Desenhar fluxo de dados completo
2. Definir tabelas do banco (DDL completo em database/setup.sql)
3. Listar workflows e responsabilidade de cada um
4. Identificar credenciais necessárias
5. Commitar ARQUITETURA.md
6. Gerar BRIEFING_AGENTE.md versão 1
7. Commitar — este é o ponto de handoff para o Claude Code
```

### Fase 2 — Execução (Claude Code)

```
1. Ler BRIEFING_AGENTE.md do Git
2. Criar banco dedicado no PostgreSQL
3. Criar credencial DB no n8n (convenção: DB_{nome_projeto})
4. Criar workflows via n8n-mcp na ordem correta:
   - WF-XX.05 Setup Banco → executar → desativar
   - WF-XX.02 Subworkflow de processamento
   - WF-XX.03 Handler de comandos
   - WF-XX.04 Relatório/Output
   - WF-XX.01 Receptor principal (ativar por último)
   - WF-XX.06 Painel/Backend
5. Vincular subworkflows e credenciais
6. Commitar IDS.md com IDs gerados
7. Atualizar BRIEFING com IDs e estado real
```

### Fase 3 — Entrega e Versionamento

```
1. Exportar JSONs dos workflows do n8n → workflows/
2. Commitar: "wf: exportar workflows vX.X"
3. Atualizar checklist no BRIEFING
4. Tag de versão: git tag vX.X && git push --tags
5. Atualizar projetos_iatech SET versao, atualizado_em
```

---

## 4. ESTRUTURA DO BRIEFING_AGENTE.md

O BRIEFING é o único arquivo que um agente novo precisa ler para retomar qualquer projeto. Deve ter exatamente estas seções:

| Seção | Conteúdo | Tamanho máximo |
|---|---|---|
| CONTEXTO | Nome, repo, n8n URL, versão, uma frase | 5 linhas |
| STACK | Tabela componente/tecnologia/detalhe | 1 tabela |
| WORKFLOWS | Tabela nome/ID/URL | 1 tabela com IDs reais |
| CREDENCIAIS | Só as testadas e funcionando | Lista curta |
| BANCO | DDL resumido + enums | 20 linhas |
| PENDÊNCIAS | P0N com descrição, local e comando exato | 1 bloco por pendência |
| FLUXO DE DADOS | Diagrama ASCII do fluxo completo | 30 linhas |
| CONVENÇÕES | Nomenclatura de workflows, nós e commits | 10 linhas |
| CHECKLIST | [x] feito / [ ] pendente | 1 lista |

**O que NÃO deve estar no BRIEFING:**
- Dados operacionais (registros de funcionários, despesas reais)
- Logs de execução ou histórico de sessões
- Discussões de decisões já tomadas (isso vai no ARQUITETURA.md)
- Código completo de workflows (isso fica nos JSONs em `workflows/`)

---

## 5. SINCRONIZAÇÃO GIT ↔ N8N

**Regra:** não sincronizar automaticamente. Exportar em marcos deliberados.

### Quando exportar
- Ao completar uma Fase de entrega
- Antes de criar uma tag de versão
- Após alteração significativa de lógica (não de credenciais/config)

### Como exportar via API REST
```bash
# Para cada workflow ID (substituir {ID} e {NOME}):
curl https://n8n.solucaomadeira.com/api/v1/workflows/{ID} \
  -H "X-N8N-API-KEY: $N8N_API_KEY" \
  -o workflows/WF-DPV-{NN}.json
```

### O que NÃO commitar
- Valores reais de credenciais nos JSONs (sanitizar antes)
- Arquivos `.env` (usar `.env.example`)

---

## 6. CONVENÇÕES GLOBAIS DO AMBIENTE

### Nomenclatura
```
Projeto:   nome-kebab-case    → dep-viagem, faq-agente
Sigla:     3 LETRAS           → DPV, FAQ, CNT
Banco:     nome_projeto       → dep_viagem, n8n_contratos
Workflow:  WF-{SIGLA}.NN - Descrição [{nome-projeto}]
Nó:        WF-{SIGLA}.NN - TIPO | Descrição
Credencial DB: DB_{nome_projeto}  → DB_dep_viagem
Credencial email: MAILERSEND_{sigla}
```

### Tipos de nó válidos
```
TRIGGER SET SWITCH IF HTTP DB EXEC AGENT CODE AGG RESPOND NOOP PARSER LLM
```

### Commits Git
```
tipo: descrição em minúsculas

Tipos: init feat fix wf db docs config painel hotfix
```

---

## 7. DIAGNÓSTICO RÁPIDO — QUANDO ALGO QUEBRA

```
1. Credencial Postgres → usar DB_{nome_projeto} com banco dedicado
2. n8n API acessível? → curl .../api/v1/workflows -H "X-N8N-API-KEY: ..."
3. Gotenberg rodando? → docker exec {n8n} curl http://gotenberg:3000/health
4. Evolution API? → GET /instance/fetchInstances com apikey header
5. Workflow ativo? → verificar toggle ON no n8n
6. IDs subworkflows corretos? → IDS.md pode estar desatualizado
7. SMTP bloqueado? → usar MailerSend via HTTPS
8. DNS IPv6 travando? → usar IP IPv4 direto na credencial
```

---

## 8. ESTADO ATUAL DO AMBIENTE (14/06/2026)

### Projetos ativos

| Sigla | Projeto | Banco | Versão | Status |
|---|---|---|---|---|
| DPV | dep-viagem | dep_viagem | v1.0 | Em produção — pendências menores |

### Infraestrutura

| Serviço | Status | Detalhe |
|---|---|---|
| n8n | ✅ Ativo | https://n8n.solucaomadeira.com |
| PostgreSQL | ✅ Ativo | container n8n_postgres |
| Evolution API | ✅ Ativo | https://evolution.solucaomadeira.com |
| Gotenberg | ✅ Ativo | container gotenberg, rede easypanel |
| Redis | ✅ Ativo | container n8n_redis |
| MailerSend | ✅ Testado | trial domain, via HTTP API |
| N8N_API_KEY | ❌ Não configurada | Claude Code usa SQL workaround |
| n8n-mcp no Claude Code | ❌ Não conectado | settings.json vazio |

### Credenciais globais que funcionam

| Serviço | Credencial n8n | ID |
|---|---|---|
| PostgreSQL (DPV) | DB_dep_viagem | ggViIQGkepjwuOdv |
| Evolution API | HEADER_API_EVOLUTION_ENVIO | Ka0C8J4zfOklD1lw |
| Anthropic | ANTHROPIC_API_KEY | A7kQbA9mH4B54bS4 |
| MailerSend | MAILERSEND - Header Auth account | hx3Z9csTHPS00ghb |

---

## 9. TEMPLATE — BRIEFING_AGENTE.md MÍNIMO

```markdown
# BRIEFING_AGENTE.md — {nome-projeto} [{SIGLA}]
Gerado em: {data}

## CONTEXTO
Projeto: {nome} [{SIGLA}]
Repo: https://github.com/alexandre-madeira/{nome}
n8n: https://n8n.solucaomadeira.com
Versão: v0.1
O que é: {uma frase}

## STACK
| Componente | Tecnologia | Detalhe |
|---|---|---|
| Orquestração | n8n self-hosted | https://n8n.solucaomadeira.com |
| WhatsApp | Evolution API | https://evolution.solucaomadeira.com |
| Banco | PostgreSQL | credencial: DB_{sigla_lower} |

## WORKFLOWS
| Workflow | ID | URL |
|---|---|---|
| WF-{SIGLA}.01 - {Descrição} | {ID} | https://n8n.solucaomadeira.com/workflow/{ID} |

## CREDENCIAIS
- Postgres: DB_{nome_projeto} (ID: {ID})
- Evolution: HEADER_API_EVOLUTION_ENVIO (ID: Ka0C8J4zfOklD1lw)
- Anthropic: ANTHROPIC_API_KEY (ID: A7kQbA9mH4B54bS4)

## BANCO DE DADOS
Banco: {nome_banco}
{DDL resumido das tabelas}

## PENDÊNCIAS
### P01 — {Nome}
Onde: {localização exata}
Como resolver: {comando exato}

## FLUXO DE DADOS
{diagrama ASCII}

## CONVENÇÕES
- Workflows: WF-{SIGLA}.NN - Descrição [{nome}]
- Nós: WF-{SIGLA}.NN - TIPO | Descrição
- Commits: tipo: descrição minúscula

## CHECKLIST
- [ ] WF-{SIGLA}.01 criado e ativo
- [ ] Banco inicializado
- [ ] Credenciais configuradas e testadas
- [ ] Teste end-to-end realizado
- [ ] JSONs exportados e commitados
- [ ] Tag de versão publicada
```

---

## 10. PRÓXIMOS PASSOS PRIORITÁRIOS

### Ambiente (fazer uma vez — desbloqueiam todos os projetos)
1. Configurar `N8N_API_KEY` no docker-compose do n8n
2. Registrar n8n-mcp no `~/.claude/settings.json` do Claude Code
3. Criar tabela `projetos_iatech` no banco administrativo

### DPV — dep-viagem (pendências atuais)
1. P06 — Trocar senha padrão `SENHA_CONFIGURADA_NO_N8N` no WF-DPV.06
2. Implementar cadastro de usuários com validação de e-mail (MailerSend pronto)
3. Criar tabela `cadastros_pendentes` + campo `email` em `funcionarios`
4. Teste end-to-end completo (NF real via WhatsApp)
5. Exportar JSONs atualizados e commitar
6. Tag v1.1
