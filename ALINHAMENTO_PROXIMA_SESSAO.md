# ALINHAMENTO PRÓXIMA SESSÃO — dep-viagem
**Data:** 19/06/2026 | **Gerado para:** Claude LLM ou Claude Code  
**Status do projeto:** Implementação em andamento | **Bloqueante:** P16

---

## 1. ESTADO ATUAL DO SISTEMA

### ✅ Implementado esta sessão

| Item | Status | Detalhe |
|---|---|---|
| Tabela `erros_dpv` | ✅ Criada | Fila de autocorreção no banco |
| WF-DPV.CHK | ✅ Criado | Verificação rápida de estado (3 nós) |
| WF-DPV.07 | ✅ Criado | Cadastro por WhatsApp com validação e-mail (21 nós) |
| WF-ADMIN sync | ✅ Executado | 172 nós indexados (WF-DPV.07 incluído) |
| Credencial Anthropic | ✅ Aplicada | ID: `fA9wqoHasCFbjdwX` no WF-DPV.02 |
| Gotenberg | ✅ Rodando | Container no EasyPanel, porta 3000 |
| Painel mobile | ✅ Funcional | GET `/webhook/dpv-financeiro-ui` — HTML server-side |
| Migration v4 | ✅ Aplicada | `cadastros_pendentes` + coluna `email` |
| Migration v5 | ✅ Aplicada | Tabela `erros_dpv` |
| Simulador | ✅ Testa | WF-DPV.SIM cobre fluxo sem WhatsApp |

### ❌ Bug P16 — BLOQUEANTE

**Nó:** `WF-DPV.01 - IF | Funcionario Cadastrado?`

**Sintoma:** Executa ambas as branches (true E false) simultaneamente em vez de escolher uma.

**Evidência:**
```json
"main": [[{"json": {"id": "5"}}, []]]
// Saída 1: dados (deveria ser true)
// Saída 2: vazia (deveria ser false)
// Resultado: ambas rodam ao mesmo tempo
```

**Impacto:**
- Usuários cadastrados são desviados para `NOOP` em vez de `SWITCH | Tipo de Mensagem`
- Mensagens silenciosamente ignoradas
- WF-DPV.03 nunca é chamado
- Simulador falha no INICIAR

**Reprodução:**
```
executar simulador → cadastra funcionário → INICIAR webhook
→ WF-DPV.01 busca funcionário (encontra id=5) ✅
→ IF deveria: true → SWITCH
→ IF realmente: true + false simultâneos → NOOP
```

### 📊 Estado do banco

```
funcionarios:      0 (zerado)
viagens:           0 (zerado)
despesas_viagem:   0 (zerado)
cadastros_pendentes: 0 (vazio)
erros_dpv:         0 (limpo)
```

### 🔧 Workflows

| WF | ID | Status | Notas |
|---|---|---|---|
| WF-DPV.01 | z0F4H4NUyLErFjZ7 | 🔴 BLOQUEADO | P16: IF não funciona |
| WF-DPV.02 | 31hBkBVq6rduQKXM | ✅ Ativo | Credencial Anthropic configurada |
| WF-DPV.03 | ruf039UAwh9KqIZo | ✅ Ativo | Nunca chamado (P16) |
| WF-DPV.04 | acKIy44sUfDgOR2E | ✅ Ativo | Aguarda WF-DPV.03 |
| WF-DPV.05 | eIm1nVXe1qnCKhYz | ✅ Ativo | Migrations executadas |
| WF-DPV.06 | fRA3D3njIJOWmtqU | ✅ Ativo | Painel testado |
| WF-DPV.07 | 6SwQvQ5IVL8oVtUk | ✅ Ativo | Aguarda P16 ser resolvido |
| WF-DPV.CHK | 1c8Ag8NgvtOiRYr7 | ✅ Ativo | Verificação de estado |
| WF-DPV.SIM | KeDFPVOx6DwXLk6i | ⚠️ FALHA | P16: bloqueia ciclo e2e |
| WF-ADMIN | OUbFTiwtY485IHxt | ✅ Ativo | Sync de nós completado |

---

## 2. RESOLUÇÃO P16 — PRIORIDADE MÁXIMA

### Opção A — Substituir IF por Switch (recomendado)

```n8n
WF-DPV.01 - DB | Verificar Funcionario
    ↓
WF-DPV.01 - SWITCH | Roteamento Cadastro
    ├── case: $json.id != null && $json.id != ""
    │   → WF-DPV.01 - SWITCH | Tipo de Mensagem (fluxo normal)
    └── default:
        → WF-DPV.01 - EXEC | Cadastrar Usuario (WF-DPV.07)
```

**Passos:**
1. Remover nó `IF | Funcionario Cadastrado?`
2. Criar novo nó `SWITCH | Roteamento Cadastro` com 2 cases
3. Case 1: condicional no `id`
4. Case 2: default (sem ID = novo usuário)
5. Conectar outputs corretos
6. Publicar e testar simulador

### Opção B — Usar Code node (alternativa rápida)

```javascript
// CODE | Rotear por Cadastro
const id = $json.id;

if (id && id.toString().trim() !== "") {
  // Usuário existe → ir para SWITCH
  return [{ json: { ....$json, rota: "fluxo_normal" } }];
} else {
  // Novo usuário → ir para cadastro
  return [{ json: { ....$json, rota: "cadastro" } }];
}
```

Depois usar IF para checar `rota` (mais confiável que verificar campo direto).

### Testar após corrigir

```bash
# 1. Limpar banco
executar WF-DPV.MAINT

# 2. Rodar simulador
executar WF-DPV.SIM

# 3. Verificar estado
executar WF-DPV.CHK

# Esperado:
# ✅ viagem_id criado
# ✅ despesas inseridas
# ✅ status = encerrada
# ✅ PDF gerado (ou 404 se Gotenberg fora)
```

---

## 3. PENDÊNCIAS ABERTAS

| # | Título | Status | Bloqueante | Próximo |
|---|---|---|---|---|
| P01 | WhatsApp liberado do banimento | ⏳ Aguardando | Tudo | Configurar webhook |
| P02 | API Key Evolution nos nós HTTP | ⏳ Aguardando P01 | Todos WF | Configurar credencial |
| P03 | ~~Credencial Anthropic~~ | ✅ RESOLVIDO | Não | N/A |
| P04 | ~~Gotenberg rodando~~ | ✅ RESOLVIDO | Não | N/A |
| P06 | Senha do painel trocada | ✅ RESOLVIDO | Não | N/A |
| P07 | JSONs dos workflows no Git | ⏳ Pendente | Não | Exportar 7 WFs |
| P08 | ~~Cadastro com e-mail~~ | ✅ RESOLVIDO | P16 | Aguarda P16 |
| P09 | Teste e2e real | ⏳ Aguardando | P01, P16 | Após P16 + WhatsApp |
| **P16** | **IF bloco funciona errado** | 🔴 **CRÍTICO** | **TUDO** | **Resolver opção A/B** |

---

## 4. PRÓXIMAS ETAPAS EM ORDEM

### 🔴 Crítico — Resolver primeiro

1. **Corrigir P16** (Switch ou Code node)
2. **Testar simulador** até ciclo completo passar
3. **Verificar estado do banco** com WF-DPV.CHK
4. **Commitar no Git:**
   ```bash
   git add workflows/IDS.md BRIEFING_AGENTE.md
   git commit -m "fix: P16 IF bloco cadastro — usar SWITCH/Code

   - Substituir IF por logica confiavel
   - Testar ciclo e2e completo
   - WF-DPV.SIM deve passar"
   ```

### 🟡 Importante — Quando P16 resolvido

5. **Exportar 7 workflows como JSON** para pasta `workflows/`
6. **Commitar JSONs** (P07)
7. **Atualizar BRIEFING** com status "P16 resolvido"

### 🟢 Quando WhatsApp liberado (P01)

8. **Aplicar webhook** com `MESSAGES_UPSERT` only
9. **Configurar API Key Evolution** nos nós HTTP (P02)
10. **Teste e2e real** com funcionário de teste (P09)

### 📋 Rotina de início de sessão

Toda sessão, comece com:

```
"verificar estado" 
→ Claude executa WF-DPV.CHK
→ Mostra erros_dpv pendentes + resumo do banco
→ Pronto para trabalhar com contexto completo
```

---

## 5. BRIEFING PARA CLAUDE CODE

Se for transferir para Claude Code, use este contexto:

```markdown
## Contexto do projeto
- Sistema dep-viagem: expense tracking via WhatsApp
- n8n: 7 workflows + utilitários
- PostgreSQL: banco dep_viagem com 5 tabelas
- Bug P16: IF no WF-DPV.01 executa ambas as branches

## Arquivos críticos (Git)
- BRIEFING_AGENTE.md — instruções arquitetura
- workflows/IDS.md — mapa de workflows
- database/migrations/ — v4, v5

## Como começar
1. git pull (atualizar do alinhamento de hoje)
2. executar WF-DPV.CHK (verificar estado)
3. Corrigir P16 (Switch ou Code node no WF-DPV.01)
4. Testar WF-DPV.SIM

## Ferramentas disponíveis
- n8n MCP: chamar workflows, atualizar nós
- Git: commitar fixes
- PostgreSQL: consultar banco, verificar dados

## Saída esperada
- P16 resolvido
- WF-DPV.SIM passa (ciclo e2e)
- Novo commit no Git com fix
```

---

## 6. ESTADO DO GIT (ANTES DE COMMITAR)

**Última commit:** 19/06/2026 — "docs: atualizar briefing 19/06..."

**A commitar:**
- BRIEFING_AGENTE.md (atualizado com P16)
- database/migrations/v4_cadastro_usuarios.sql (criado)
- database/migrations/v5_erros_dpv.sql (criado)
- workflows/IDS.md (com WF-DPV.07, WF-DPV.CHK)
- P16_Bug_IF_Funcionario.md (documentação do bug)

**Scripts prontos:**
- commit_19jun2026.sh (arquivo de referência)

---

## 7. CHECKLIST FINAL

Antes de passar para próxima sessão:

- [ ] P16 corrigido (IF → Switch ou Code)
- [ ] WF-DPV.SIM passa com ciclo e2e
- [ ] WF-DPV.CHK mostra estado correto
- [ ] Banco zerado (prepare para testes reais)
- [ ] BRIEFING_AGENTE.md atualizado
- [ ] Commits feitos no Git
- [ ] Documentação P16 adicionada

---

## 8. ARQUIVOS GERADOS NESTA SESSÃO

Todos em `/mnt/user-data/outputs/`:

```
BRIEFING_AGENTE.md              ← Usar para atualizar repo
commit_19jun2026.sh             ← Referência de commits
ALINHAMENTO_PROXIMA_SESSAO.md  ← Este arquivo
P16_Bug_IF_Funcionario.md       ← Documentação do bug
```

---

## 9. CONTATO COM PRÓXIMA SESSÃO

**Para Claude LLM:**
- Usar userMemories atualizada
- Começar com "verificar estado"
- Ler P16_Bug_IF_Funcionario.md para contexto

**Para Claude Code:**
- Git pull para trazer alinhamento
- Usar BRIEFING_AGENTE.md como guia
- MCP disponível para n8n

---

**Gerado em:** 2026-06-19 21:10 UTC  
**Por:** Claude LLM em sessão contínua  
**Status:** Pronto para próxima sessão
