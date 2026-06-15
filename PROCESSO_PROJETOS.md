# PROCESSO_PROJETOS.md — IATECH
Processo padrão para criação e manutenção de projetos no ambiente IATECH.
Versão: 1.0 — Gerado em: 14/06/2026
Baseado em: aprendizados do projeto dep-viagem (DPV)

---

## 1. PRINCÍPIOS DO AMBIENTE

### Três camadas de verdade

| Camada | Responsabilidade | Ferramenta |
|---|---|---|
| **Intenção** | O que foi projetado, aprovado e versionado | Git / GitHub |
| **Execução** | Estado vivo dos workflows e automações | n8n (banco interno) |
| **Dados** | Dados operacionais do negócio | PostgreSQL (banco do projeto) |

**Regra fundamental:** cada camada tem sua própria fonte de verdade. Não sincronizar automaticamente — sincronizar em marcos deliberados (fim de sprint, entrega de versão).

### Dois agentes, sem contexto compartilhado

| Agente | Papel | Acessa |
|---|---|---|
| **Claude LLM** (claude.ai) | Orientação estratégica, arquitetura, revisão | Git + BRIEFING_AGENTE.md |
| **Claude Code** | Execução técnica: criar workflows, SQL, código | Git + n8n-mcp + SSH/bash |

A ponte entre os dois é o **Git**. Todo alinhamento estratégico que o LLM produz deve ser commitado antes que o Code comece a executar.

---

## 2. SETUP ÚNICO DO AMBIENTE (fazer uma vez)

### 2.1 N8N_API_KEY

```bash
# No servidor, adicionar ao .env do n8n ou docker-compose:
N8N_API_KEY=sua_chave_aqui

# Verificar se a API está acessível:
curl https://n8n.solucaomadeira.com/api/v1/workflows \
  -H "X-N8N-API-KEY: $N8N_API_KEY"
```

### 2.2 n8n-mcp — registro no Claude Code

Arquivo: `~/.config/claude-code/mcp.json` (ou equivalente na plataforma):

```json
{
  "mcpServers": {
    "n8n": {
      "url": "https://n8n.solucaomadeira.com/mcp-server/http",
      "apiKey": "$N8N_API_KEY"
    }
  }
}
```

Com isso o Claude Code acessa o n8n via MCP sem SSH e sem SQL direto no banco interno do n8n.

**Por que nunca usar SQL direto no banco interno do n8n:**
o banco interno do n8n usa estrutura proprietária e pode ser sobrescrito a qualquer momento pelo próprio n8n. SQL direto bypassa validações e pode corromper estado. Sempre usar a API REST (via n8n-mcp ou via curl).

### 2.3 Tabela central de projetos (PostgreSQL)

Criar no banco `n8n_contratos` (ou banco administrativo):

```sql
CREATE TABLE IF NOT EXISTS projetos_iatech (
  sigla        VARCHAR(10) PRIMARY KEY,  -- ex: DPV, FAQ, CNT
  nome         VARCHAR(100) NOT NULL,    -- ex: dep-viagem
  repo_github  TEXT,
  banco_pg     VARCHAR(100),             -- banco dedicado do projeto
  n8n_url      TEXT,
  status       VARCHAR(20) DEFAULT 'ativo',  -- ativo | pausado | entregue
  versao       VARCHAR(20),
  criado_em    TIMESTAMP DEFAULT NOW(),
  atualizado_em TIMESTAMP DEFAULT NOW(),
  notas        TEXT
);

-- Inserir DPV como primeiro projeto
INSERT INTO projetos_iatech VALUES (
  'DPV', 'dep-viagem',
  'https://github.com/alexandre-madeira/dep-viagem',
  'n8n_contratos',
  'https://n8n.solucaomadeira.com',
  'ativo', 'v1.0',
  NOW(), NOW(),
  'Pendências: P02 Evolution apikey, P03 Anthropic credential, P04 Gotenberg'
);
```

Esta tabela serve como índice — não substitui o BRIEFING, serve para uma sessão nova descobrir quais projetos existem antes de buscar o Git.

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

Estrutura mínima de pastas a commitar no `init`:

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
│   └── PENDENCIAS.md
├── workflows/
│   └── IDS.md              ← IDs dos workflows n8n
└── painel/                 ← se houver frontend
```

### Fase 1 — Arquitetura (Claude LLM)

```
1. Desenhar fluxo de dados completo
2. Definir tabelas do banco
3. Listar workflows e responsabilidades de cada um
4. Identificar credenciais necessárias
5. Commitar ARQUITETURA.md
6. Gerar BRIEFING_AGENTE.md versão 1
7. Commitar — este é o "ponto de handoff" para o Claude Code
```

### Fase 2 — Execução (Claude Code)

```
1. Ler BRIEFING_AGENTE.md do Git
2. Criar banco/tabelas via WF de setup
3. Criar workflows via n8n-mcp (validar antes de criar)
4. Vincular subworkflows e credenciais
5. Executar WF de setup do banco
6. Testar fluxo básico
7. Commitar IDS.md com IDs gerados
8. Atualizar BRIEFING com IDs e estado real
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

O BRIEFING é o único arquivo que um agente novo precisa ler para retomar qualquer projeto. Deve ter exatamente estas seções — sem mais, sem menos:

### Seção obrigatória 1 — Contexto do projeto
```markdown
## CONTEXTO
Projeto: {nome} [{sigla}]
Repo: {url github}
n8n: {url n8n}
Versão: {vX.X}
O que é: {uma frase}
```

### Seção obrigatória 2 — Stack (tabela)
Componente | Tecnologia | URL/Detalhe. Incluir apenas o que está em uso real.

### Seção obrigatória 3 — Workflows (tabela com IDs)
Nome | ID | URL direta. IDs são essenciais — sem eles o Claude Code não consegue operar via MCP.

### Seção obrigatória 4 — Credenciais que FUNCIONAM
Listar apenas as que foram testadas e funcionam. Listar explicitamente as que NÃO funcionam (evita reteste desnecessário).

### Seção obrigatória 5 — Banco de dados
DDL resumido das tabelas. Enums de status e categorias.

### Seção obrigatória 6 — Pendências abertas
Formato: `P0N — Nome` com descrição, onde configurar, e comando exato para resolver.

### Seção obrigatória 7 — Fluxo de dados
Diagrama ASCII do fluxo completo. Indispensável para o LLM raciocinar sobre o sistema.

### Seção obrigatória 8 — Convenções
Nomenclatura de workflows, nós e commits. Sem isso o agente inventa nomes inconsistentes.

### Seção obrigatória 9 — Checklist de entrega
`[x]` para concluído, `[ ]` para pendente. É o estado atual do projeto em uma olhada.

**O que NÃO deve estar no BRIEFING:**
- Dados operacionais (registros de funcionários, despesas reais)
- Logs de execução
- Discussões de decisões já tomadas (isso vai no ARQUITETURA.md)
- Código completo de workflows (isso fica nos JSONs em `workflows/`)

---

## 5. SINCRONIZAÇÃO GIT ↔ N8N

### Quando exportar (não fazer automaticamente)

Exportar JSONs dos workflows nos seguintes momentos:
- Ao completar uma Fase de entrega
- Antes de criar uma tag de versão
- Após qualquer alteração significativa de lógica (não de credenciais/config)

### Como exportar

Via n8n UI: Workflow → ⋯ → Download. Salvar em `workflows/WF-{SIGLA}-{NN}.json`.

Via API REST (pode automatizar com script):
```bash
# Para cada workflow ID:
curl https://n8n.solucaomadeira.com/api/v1/workflows/{ID} \
  -H "X-N8N-API-KEY: $N8N_API_KEY" \
  -o workflows/WF-DPV-01.json
```

### O que NÃO commitar nos JSONs
Antes de commitar, sanitizar credenciais dos JSONs (apikeys, senhas). Usar `.gitignore` para arquivos `.env` e criar `.env.example`.

---

## 6. CONVENÇÕES GLOBAIS DO AMBIENTE

### Nomenclatura de projetos
```
nome-kebab-case   →  dep-viagem, faq-agente, contratos-sig
SIGLA (3 letras)  →  DPV, FAQ, CNT
```

### Nomenclatura de workflows
```
WF-{SIGLA}.NN - Descrição [{nome-projeto}]
Exemplo: WF-DPV.01 - Receptor de NF [dep-viagem]
```

### Nomenclatura de nós n8n
```
WF-{SIGLA}.NN - TIPO | Descrição
Tipos válidos: TRIGGER SET SWITCH IF HTTP DB EXEC AGENT CODE AGG RESPOND NOOP PARSER LLM
```

### Commits Git
```
tipo: descrição em minúsculas

Tipos: init feat fix wf db docs config painel hotfix
```

### Bancos PostgreSQL
Usar sempre a credencial `DB_n8n_contratos` (ID: `3z35ZPyLInGNam1Y`) enquanto não houver banco dedicado por projeto. Quando criar banco dedicado, registrar novo ID de credencial no BRIEFING imediatamente.

---

## 7. DIAGNÓSTICO RÁPIDO — QUANDO ALGO QUEBRA

Checklist de diagnóstico na ordem correta:

```
1. Credencial Postgres → só DB_n8n_contratos funciona
2. n8n-mcp acessível? → curl https://n8n.solucaomadeira.com/api/v1/workflows -H "X-N8N-API-KEY: ..."
3. Gotenberg rodando? → curl http://gotenberg:3000/health
4. Evolution API respondendo? → curl http://evolution-api:8080/instance/fetchInstances -H "apikey: ..."
5. Workflow ativo? → verificar toggle ON no n8n
6. IDs dos subworkflows corretos? → IDS.md pode estar desatualizado após recriação
```

---

## 8. ESTADO ATUAL DO AMBIENTE (14/06/2026)

### Projetos ativos

| Sigla | Projeto | Versão | Status |
|---|---|---|---|
| DPV | dep-viagem | v1.0 | Pendências P02/P03/P04 |

### Credenciais globais que funcionam

| Serviço | Credencial n8n | ID |
|---|---|---|
| PostgreSQL | DB_n8n_contratos | 3z35ZPyLInGNam1Y |

### Credenciais a criar

| Serviço | Ação necessária |
|---|---|
| Anthropic API | n8n → Credentials → New → Anthropic API |
| Evolution API key | Obter no painel da instância Evolution |

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

O que é: {uma frase descrevendo o sistema}

## STACK
| Componente | Tecnologia | Detalhe |
|---|---|---|
| Orquestração | n8n self-hosted | https://n8n.solucaomadeira.com |
| WhatsApp | Evolution API | http://evolution-api:8080 |
| Banco | PostgreSQL | credencial: DB_n8n_contratos |

## WORKFLOWS
| Workflow | ID | URL |
|---|---|---|
| WF-{SIGLA}.01 - {Descrição} | {ID} | https://n8n.solucaomadeira.com/workflow/{ID} |

## CREDENCIAIS
- Postgres que funciona: DB_n8n_contratos (ID: 3z35ZPyLInGNam1Y)
- Anthropic: {pendente ou ID após criar}

## BANCO DE DADOS
Banco: {nome_banco}
Tabelas:
{DDL resumido}

## PENDÊNCIAS
### P01 — {Nome}
O que é: {descrição}
Onde: {localização exata}
Comando: {código exato para resolver}

## FLUXO DE DADOS
{diagrama ASCII}

## CONVENÇÕES
- Workflows: WF-{SIGLA}.NN - Descrição
- Nós: WF-{SIGLA}.NN - TIPO | Descrição
- Commits: tipo: descrição minúscula

## CHECKLIST
- [ ] WF-{SIGLA}.01 criado
- [ ] Banco inicializado
- [ ] Credenciais configuradas
- [ ] Teste end-to-end realizado
- [ ] JSONs exportados e commitados
- [ ] Tag de versão publicada
```

---

## 10. PRÓXIMOS PASSOS — DEP-VIAGEM (DPV)

Em ordem de prioridade:

1. Verificar Gotenberg: `curl http://gotenberg:3000/health`
2. Obter Evolution API key no painel da instância
3. Criar credencial Anthropic no n8n → registrar ID no BRIEFING
4. Configurar apikeys Evolution nos nós HTTP via n8n-mcp (P02)
5. Aplicar credencial Anthropic no WF-DPV.02 via n8n-mcp (P03)
6. Trocar senha do painel financeiro (P06)
7. Ativar WF-DPV.01 (toggle ON)
8. Teste end-to-end completo
9. Exportar 6 JSONs → commitar (P07)
10. Atualizar BRIEFING com estado final → tag v1.1
