# BRIEFING — Canal de Contexto via PostgreSQL
**Para:** Claude Code  
**Projeto:** dep-viagem (DPV) + n8n_contratos  
**Data:** 20/06/2026  
**Prioridade:** Alta — bloqueia eficiência de desenvolvimento  

---

## PROBLEMA A RESOLVER

O projeto `n8n_contratos` atualmente envia resultados de execução e erros para
o WhatsApp. Isso causa três problemas:

1. **Loop de mensagens** — risco real de novo banimento do número (já aconteceu dia 18/06)
2. **Ineficiência** — Alex copia e cola manualmente o conteúdo no Claude Code
3. **Claude Code relê sem contexto** — não sabe onde o fluxo parou, lê tudo do zero

**Solução:** n8n_contratos passa a gravar contexto estruturado diretamente na
tabela `erros_dpv` do banco `dep_viagem`. O WF-DPV.CHK já lê essa tabela —
o protocolo "verificar estado" entregará o contexto automaticamente na próxima sessão.

---

## INFRAESTRUTURA EXISTENTE (não criar, apenas usar)

### Banco de dados
- **Banco:** `dep_viagem` (separado do `n8n_contratos`)
- **Credencial n8n (DPV):** `DB_dep_viagem` (ID: `ggViIQGkepjwuOdv`)
- **Credencial n8n (INFRA):** `DB_n8n_contratos` (ID: `3z35ZPyLInGNam1Y`) — NÃO usar no projeto DPV

### Tabela alvo: `erros_dpv`
Confirmar schema atual com:
```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'erros_dpv' 
ORDER BY ordinal_position;
```

### Workflow de leitura: WF-DPV.CHK
- **ID n8n:** `1c8Ag8NgvtOiRYr7`
- Já faz SELECT em `erros_dpv` com status `pendente`
- Já é executado no início de cada sessão com "verificar estado"

---

## TAREFA 1 — Verificar e migrar schema da tabela erros_dpv

### 1.1 Verificar schema atual
Execute no banco `dep_viagem`:
```sql
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'erros_dpv' 
ORDER BY ordinal_position;
```

### 1.2 Schema necessário
A tabela precisa ter no mínimo estas colunas:

```sql
CREATE TABLE IF NOT EXISTS erros_dpv (
  id            SERIAL PRIMARY KEY,
  origem        VARCHAR(100),      -- 'n8n_contratos', 'WF-DPV.01', etc.
  workflow_id   VARCHAR(100),      -- ID do workflow n8n
  descricao     TEXT,              -- descrição legível do evento
  ultimo_no     VARCHAR(200),      -- nome do nó onde parou
  payload_json  JSONB,             -- dados completos do contexto
  status        VARCHAR(20) DEFAULT 'pendente',  -- pendente | lido | resolvido
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  lido_em       TIMESTAMPTZ
);
```

### 1.3 Se colunas estiverem faltando
Criar arquivo de migração:
```
C:\GITHUB\DPV\database\migrations\v6_erros_dpv_canal_contexto.sql
```

Com os ALTER TABLE necessários para adicionar colunas faltantes sem recriar a tabela.

---

## TAREFA 2 — Criar nó padrão de escrita no n8n_contratos

### Objetivo
Substituir o nó de envio WhatsApp por um nó PostgreSQL que grava na `erros_dpv`.

### Nó a criar (padrão para reutilizar em todos os workflows do n8n_contratos)

**Nome do nó:** `DB | Registrar Contexto Agente`  
**Tipo:** PostgreSQL  
**Credencial:** `DB_dep_viagem` (ID: `ggViIQGkepjwuOdv`)  
**Banco:** `dep_viagem`  

**Query:**
```sql
INSERT INTO erros_dpv (
  origem,
  workflow_id,
  descricao,
  ultimo_no,
  payload_json,
  status
) VALUES (
  '{{ $json.origem }}',
  '{{ $json.workflow_id }}',
  '{{ $json.descricao }}',
  '{{ $json.ultimo_no }}',
  '{{ JSON.stringify($json.payload) }}'::jsonb,
  'pendente'
)
```

### Payload padrão a ser montado antes do nó de insert (nó SET)

**Nome:** `SET | Montar Contexto Agente`

```json
{
  "origem": "n8n_contratos",
  "workflow_id": "<ID_DO_WORKFLOW>",
  "descricao": "<DESCRIÇÃO_LEGÍVEL_DO_QUE_ACONTECEU>",
  "ultimo_no": "<NOME_DO_NÓ_ONDE_PAROU>",
  "payload": {
    "erro": "<MENSAGEM_DE_ERRO_SE_HOUVER>",
    "dados_entrada": "<DADOS_QUE_CHEGARAM_NO_NÓ>",
    "timestamp": "<TIMESTAMP_ISO>"
  }
}
```

---

## TAREFA 3 — Atualizar WF-DPV.CHK para incluir origem n8n_contratos

### Workflow: WF-DPV.CHK (ID: `1c8Ag8NgvtOiRYr7`)

Verificar a query atual do nó de SELECT. Garantir que ela retorna registros de
qualquer `origem`, não apenas do DPV:

```sql
SELECT 
  id,
  origem,
  workflow_id,
  descricao,
  ultimo_no,
  payload_json,
  status,
  created_at
FROM erros_dpv
WHERE status = 'pendente'
ORDER BY created_at DESC
LIMIT 20;
```

Se a query tiver filtro `WHERE origem = 'DPV'` ou similar, remover o filtro de origem.

### Marcar como lido após leitura
Adicionar nó após o SELECT para marcar registros como lidos:

```sql
UPDATE erros_dpv 
SET status = 'lido', lido_em = NOW()
WHERE status = 'pendente'
  AND created_at < NOW();
```

---

## TAREFA 4 — Remover / desativar nós WhatsApp do n8n_contratos

Após implementar as tarefas 1-3:

1. Localizar todos os nós de tipo `HTTP Request` que apontam para a Evolution API
   no projeto n8n_contratos
2. Desconectá-los do fluxo (não deletar ainda — apenas desconectar as arestas)
3. Conectar o fluxo ao novo nó `DB | Registrar Contexto Agente`

**Critério de confirmação:** Nenhuma mensagem WhatsApp disparada durante teste.

---

## TAREFA 5 — Criar migration e commitar

### Arquivo de migration
```
C:\GITHUB\DPV\database\migrations\v6_erros_dpv_canal_contexto.sql
```

Conteúdo: todos os ALTER TABLE aplicados na Tarefa 1.

### Commits esperados
```
db: adicionar colunas canal contexto em erros_dpv (v6)
wf: substituir whatsapp por postgres em n8n_contratos
wf: atualizar WF-DPV.CHK para ler todas as origens
```

---

## SEQUÊNCIA DE EXECUÇÃO

```
1. Consultar schema atual de erros_dpv
2. Identificar colunas faltantes
3. Criar migration v6 se necessário
4. Aplicar migration no banco dep_viagem
5. Localizar workflows do n8n_contratos com nós WhatsApp
6. Criar nó SET | Montar Contexto Agente
7. Criar nó DB | Registrar Contexto Agente  
8. Conectar ao fluxo, desconectar WhatsApp
9. Verificar query do WF-DPV.CHK
10. Atualizar WF-DPV.CHK se necessário
11. Teste: disparar execução manual → verificar INSERT em erros_dpv
12. Teste: executar "verificar estado" → confirmar que contexto aparece
13. Commitar migrations e exportar JSONs atualizados
```

---

## CRITÉRIO DE SUCESSO

- [ ] Execução do n8n_contratos NÃO envia mensagem WhatsApp
- [ ] Registro aparece em `erros_dpv` com campos preenchidos
- [ ] Comando "verificar estado" entrega o contexto automaticamente
- [ ] Claude Code não precisa de copia-cola para ter contexto da execução
- [ ] Migration v6 commitada no repositório

---

## REFERÊNCIAS

- Banco alvo: `dep_viagem`
- Credencial DPV: `DB_dep_viagem` (ID: `ggViIQGkepjwuOdv`)
- WF-DPV.CHK: `1c8Ag8NgvtOiRYr7`
- Repositório local: `C:\GITHUB\DPV`
- n8n: `https://n8n.solucaomadeira.com`
