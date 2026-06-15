# Processo de Criação de Projetos
## Ambiente: n8n + PostgreSQL + Docker Swarm + Claude Code + Claude LLM

---

## Fontes da Verdade

| Camada | O que guarda | Quem lê |
|--------|-------------|---------|
| **Git** | Workflows (JSON), DDL, docs, frontend | Claude Code, Claude LLM, humano |
| **Banco** | Dados operacionais, metadados de projetos | n8n, Claude Code via SQL |
| **n8n** | Execução live dos workflows | Evolution API, webhooks, subworkflows |
| **Memória Claude Code** | Contexto de sessão, decisões, convenções | Claude Code (próximas sessões) |

**Regra:** Git é a verdade do CÓDIGO. Banco é a verdade dos DADOS. n8n deve sempre refletir o Git.

---

## Fase 0 — Design (Claude LLM)

Antes de qualquer código, definir com Claude LLM:

- [ ] Nome do projeto (sigla de 3 letras, ex: DPV, FAQ, ECG)
- [ ] Stack: quais serviços do ambiente serão usados
- [ ] Fluxo de dados completo (diagrama textual)
- [ ] Schema do banco (tabelas, colunas, tipos)
- [ ] Lista de workflows e o que cada um faz
- [ ] Credenciais necessárias (quais serviços externos)
- [ ] BRIEFING_AGENTE.md inicial

**Output obrigatório desta fase:** `BRIEFING_AGENTE.md` + `ARQUITETURA.md` + `database/setup.sql`

---

## Fase 1 — Bootstrap (Claude Code)

### 1.1 Git
```bash
# Criar repositório
git init && git remote add origin https://github.com/alexandre-madeira/NOME-PROJETO

# Estrutura mínima obrigatória
mkdir -p docs database workflows painel
touch README.md BRIEFING_AGENTE.md
touch docs/ARQUITETURA.md docs/PENDENCIAS.md
touch database/setup.sql database/seeds.sql
touch workflows/IDS.md
```

### 1.2 Banco de dados
```sql
-- Banco dedicado por projeto (nunca compartilhar com outro projeto)
-- Convenção: nome_projeto em minúsculas com underscore
CREATE DATABASE nome_projeto;

-- Executar setup.sql no banco criado
-- Registrar na tabela central de projetos (n8n_data.projetos)
INSERT INTO projetos (sigla, nome, banco, repo_git, criado_em)
VALUES ('DPV', 'dep-viagem', 'dep_viagem', 'alexandre-madeira/dep-viagem', NOW());
```

### 1.3 Credenciais no n8n
Convenção de nomes:
- Banco: `DB_SIGLA` (ex: `DB_dep_viagem`)
- WhatsApp: `HEADER_API_EVOLUTION_ENVIO`
- IA: `ANTHROPIC_API_KEY`
- Email: `MAILERSEND_SIGLA`

### 1.4 N8N_API_KEY
```bash
# Obrigatório — sem isso Claude Code não acessa n8n via API REST
# Configurar na instância n8n e salvar como variável de ambiente
N8N_API_KEY=xxxx
```

---

## Fase 2 — Implementação (Claude Code)

### Ordem de criação dos workflows
1. WF-XX.05 — Setup Banco (executar e desativar)
2. WF-XX.02 — Subworkflow de processamento
3. WF-XX.03 — Handler de comandos
4. WF-XX.04 — Relatório/Output
5. WF-XX.01 — Receptor principal (ativar por último)
6. WF-XX.06 — Painel/Backend

### Após cada workflow criado no n8n
```bash
# Exportar JSON e commitar
git add workflows/
git commit -m "wf: adicionar WF-XX.NN - Descrição"
git push
```

### Convenções obrigatórias
- Nome workflow: `WF-XX.NN - Descrição [nome-projeto]`
- Nome nó: `WF-XX.NN - TIPO | Descrição`
- Tipos: TRIGGER, SET, SWITCH, IF, HTTP, DB, EXEC, AGENT, CODE, AGG, RESPOND, PARSER, LLM
- Credencial DB sempre com ID + nome explícitos no JSON

---

## Fase 3 — Validação

- [ ] Teste end-to-end do fluxo principal
- [ ] Verificar todos os workflows ativos no n8n
- [ ] Confirmar que banco foi criado e tabelas existem
- [ ] Exportar JSONs finais do n8n e commitar
- [ ] Atualizar PENDENCIAS.md com o que ficou para depois
- [ ] Tag de versão: `git tag v1.0 && git push --tags`
- [ ] Atualizar BRIEFING_AGENTE.md com estado final

---

## Checklist Rápido — Novo Projeto

```
[ ] Sigla definida (3 letras)
[ ] BRIEFING_AGENTE.md criado
[ ] Repo Git criado e estruturado
[ ] Banco dedicado criado (dep_nomeproject)
[ ] Credencial DB criada no n8n (DB_nomeprojeto)
[ ] N8N_API_KEY configurada
[ ] n8n-mcp conectado ao Claude Code
[ ] Workflows criados na ordem correta
[ ] JSONs exportados e commitados
[ ] Teste end-to-end realizado
[ ] Tag v1.0 publicada
```

---

## Problemas Conhecidos neste Ambiente

| Problema | Causa | Solução |
|----------|-------|---------|
| SMTP bloqueado | VPS bloqueia portas 465/587 | Usar MailerSend via HTTPS |
| DNS IPv6 trava conexões | Container Docker prefere IPv6 | Usar IP IPv4 direto ou desativar IPv6 |
| n8n API sem chave | N8N_API_KEY não configurada | Configurar e salvar nas envs do container |
| Claude Code sem MCP n8n | n8n-mcp não conectado | Adicionar ao settings.json do Claude Code |
| Git ≠ n8n live | Atualizações manuais no n8n não refletem no Git | Exportar JSON após cada mudança no n8n |
