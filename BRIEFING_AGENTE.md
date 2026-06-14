# BRIEFING_AGENTE.md — dep-viagem [DPV]
Instruções para o agente Claude Code continuar a execução.
Gerado em: 09/06/2026

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
| IA / OCR | Anthropic Claude Vision | claude-opus-4-5 |
| Banco | PostgreSQL | credencial: DB_n8n_contratos (ID: 3z35ZPyLInGNam1Y) |
| PDF | Gotenberg | http://gotenberg:3000 |
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
- **Postgres que funciona:** `DB_n8n_contratos` (ID: `3z35ZPyLInGNam1Y`)
- **Postgres que NÃO funcionam:** DB_proj_solu, Postgres_bd_agente, db_prestconta_db, DB_supportfaqagent
- **Anthropic:** ainda não criada no n8n — pendência P03

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

## 5. PENDÊNCIAS CRÍTICAS (P02, P03, P04)

### P02 — API Key da Evolution API
**O que é:** Chave de autenticação da instância Evolution API.  
**Onde configurar:** Em todos os nós HTTP de envio de mensagem nos workflows:
- WF-DPV.02 → nó `HTTP | Enviar Confirmacao WhatsApp` → header `apikey`
- WF-DPV.02 → nó `HTTP | Avisar NF Duplicada` → header `apikey`
- WF-DPV.03 → nós `HTTP | Confirmar Inicio/Encerramento/Ajuda` → header `apikey`
- WF-DPV.04 → nó `HTTP | Enviar PDF pelo WhatsApp` → header `apikey`
- WF-DPV.06 → nós HTTP de notificação → header `apikey`

**Como obter:** Acessar o painel da Evolution API e copiar a apikey da instância ativa.

**Como configurar via n8n API:**
```bash
# Para cada nó HTTP, usar n8n:update_workflow com:
# type: "setNodeParameter"
# path: "/headerParameters/parameters/0/value"
# value: "SUA_API_KEY_AQUI"
```

---

### P03 — Credencial Anthropic no n8n
**O que é:** API Key do Anthropic para o Claude Vision funcionar no WF-DPV.02.  
**Onde configurar:** n8n → Credentials → New → Anthropic API  
**Nó afetado:** WF-DPV.02 → `LLM | Claude Vision`

**Como criar via n8n (se tiver acesso à API de credentials):**
```json
{
  "name": "Anthropic DPV",
  "type": "anthropicApi",
  "data": { "apiKey": "sk-ant-XXXX" }
}
```

**Após criar, aplicar no workflow:**
```bash
n8n:update_workflow workflowId=31hBkBVq6rduQKXM
  type: setNodeCredential
  nodeName: "WF-DPV.02 - LLM | Claude Vision"
  credentialKey: anthropicApi
  credentialId: <ID_GERADO>
```

---

### P04 — Gotenberg no Docker
**O que é:** Serviço de conversão HTML → PDF usado no WF-DPV.04.  
**URL esperada:** `http://gotenberg:3000`  
**Verificar:** `curl http://gotenberg:3000/health`

**Se não estiver rodando, adicionar ao docker-compose.yml:**
```yaml
gotenberg:
  image: gotenberg/gotenberg:8
  restart: unless-stopped
  networks:
    - the same network as n8n
```

**Após subir:** `docker-compose up -d gotenberg`

---

### P06 — Trocar senha do painel financeiro
**Senha padrão atual:** `SENHA_CONFIGURADA_NO_N8N`  
**Onde trocar:** WF-DPV.06 → nó `IF | Autenticacao Valida?` → campo `rightValue`

```bash
n8n:update_workflow workflowId=fRA3D3njIJOWmtqU
  type: setNodeParameter
  nodeName: "WF-DPV.06 - IF | Autenticacao Valida?"
  path: "/conditions/conditions/0/rightValue"
  value: "NOVA_SENHA"
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
│       └── v2_nome_viagem.sql
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
- [x] Credencial DB_n8n_contratos em todos os workflows
- [x] imageUrl mapeado no payload Evolution
- [x] Tabela funcionarios criada
- [x] Campo nome_viagem adicionado
- [x] Painel React dark theme completo
- [x] Repositório GitHub criado e com push
- [x] Tag v1.0 publicada
- [ ] P02 — API Key Evolution configurada
- [ ] P03 — Credencial Anthropic criada no n8n
- [ ] P04 — Gotenberg verificado/instalado
- [ ] P06 — Senha do painel trocada
- [ ] P07 — JSONs dos workflows exportados e comitados
- [ ] WF-DPV.01 ativado (toggle ON)
- [ ] Teste end-to-end realizado
