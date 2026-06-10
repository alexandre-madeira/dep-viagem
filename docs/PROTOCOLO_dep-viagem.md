# PROTOCOLO_dep-viagem.md
Protocolo Operacional — dep-viagem [DPV]
Instanciado em: 09/06/2026 | Atualizado: 09/06/2026

---

## VISÃO GERAL

**Projeto:** dep-viagem | **Sigla:** DPV
**Descrição:** Sistema de gestão de despesas de viagem via WhatsApp com relatório financeiro em PDF e painel web para o financeiro.

---

## FASES DE EXECUÇÃO

| Fase | Status | Descrição |
|---|---|---|
| F1 — Objetivo | ✅ | Definição do problema e resultado esperado |
| F2 — Identidade | ✅ | Nome `dep-viagem`, sigla `DPV` |
| F3 — Arquitetura | ✅ | 6 workflows, 3 tabelas, painel React |
| F4 — Execução n8n | ✅ | 6 workflows criados e configurados |
| F5 — Versionamento | ⏳ | Repositório pronto, aguarda push inicial |
| F6 — Documentação | ✅ | README, Arquitetura, Pendências, Protocolo, Git |

---

## WORKFLOWS

| ID n8n | Workflow | Status |
|---|---|---|
| `z0F4H4NUyLErFjZ7` | WF-DPV.01 - Receptor de NF | ✅ Criado |
| `31hBkBVq6rduQKXM` | WF-DPV.02 - Extrator IA | ✅ Criado |
| `ruf039UAwh9KqIZo` | WF-DPV.03 - Controle de Viagem | ✅ Criado |
| `acKIy44sUfDgOR2E` | WF-DPV.04 - Relatório PDF | ✅ Criado |
| `eIm1nVXe1qnCKhYz` | WF-DPV.05 - Setup Banco | ✅ Executado |
| `fRA3D3njIJOWmtqU` | WF-DPV.06 - Painel Financeiro | ✅ Criado |

---

## PRÓXIMAS AÇÕES (em ordem)

1. **Configurar API Key Evolution** nos workflows (P02)
2. **Criar credencial Anthropic** no n8n (P03)
3. **Adicionar Gotenberg** no Docker Compose (P04)
4. **Trocar senha** do painel financeiro (P06)
5. **Fazer commit inicial** no GitHub (ver `docs/GIT_PROCESSO.md`)
6. **Exportar JSONs** dos workflows e commitar (seção 4 do GIT_PROCESSO)
7. **Ativar WF-DPV.01** no n8n para começar a receber mensagens
8. **Hospedar o painel** em servidor estático ou CDN

---

## COMANDOS DE USO RÁPIDO

```bash
# Funcionário
INICIAR VIAGEM          → inicia viagem (nome automático)
INICIAR São Paulo       → inicia com nome personalizado
[foto NF]               → registra despesa
ENCERRAR VIAGEM         → encerra
RELATORIO               → recebe PDF pelo WhatsApp

# Financeiro (painel web)
# URL: https://n8n.solucaomadeira.com/webhook/dpv-financeiro
# Senha: SENHA_CONFIGURADA_NO_N8N (alterar — P06)
```
