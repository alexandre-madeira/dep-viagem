# BRIEFING_IMPLANTACAO — Canal de Contexto + CLAUDE.md
**Para:** Claude Code  
**Projeto:** dep-viagem (DPV)  
**Data:** 20/06/2026  
**Repositório local:** `C:\GITHUB\DPV`  
**n8n:** `https://n8n.solucaomadeira.com`

---

## OBJETIVO

Implementar duas melhorias que juntas eliminam o copia-cola do WhatsApp
e tornam cada sessão do Claude Code focada apenas no que precisa ser resolvido:

1. **Canal de contexto via PostgreSQL** — n8n_contratos grava resultados/erros
   direto na tabela `erros_dpv` do banco `dep_viagem`
2. **CLAUDE.md na raiz do projeto** — Claude Code lê o banco automaticamente
   ao iniciar qualquer sessão, sem precisar reler o projeto inteiro

---

## CREDENCIAIS (não alterar)

| Credencial | ID | Uso |
|---|---|---|
| `DB_dep_viagem` | `ggViIQGkepjwuOdv` | **Única credencial para o projeto DPV** |
| `DB_n8n_contratos` | `3z35ZPyLInGNam1Y` | Infra apenas — nunca usar no DPV |

---

## BLOCO 1 — Preparar o banco (Tarefas 1 e 2)

### Passo 1 — Verificar schema atual da tabela erros_dpv

Conectar ao banco `dep_viagem` com a credencial `DB_dep_viagem` e executar:

```sql
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'erros_dpv'
ORDER BY ordinal_position;
```

Anotar quais colunas existem e quais estão faltando em relação ao schema necessário:

```
id            SERIAL PRIMARY KEY
origem        VARCHAR(100)
workflow_id   VARCHAR(100)
descricao     TEXT
ultimo_no     VARCHAR(200)
payload_json  JSONB
status        VARCHAR(20) DEFAULT 'pendente'
created_at    TIMESTAMPTZ DEFAULT NOW()
lido_em       TIMESTAMPTZ
```

### Passo 2 — Criar migration v6

Criar o arquivo:
```
C:\GITHUB\DPV\database\migrations\v6_erros_dpv_canal_contexto.sql
```

Conteúdo: apenas os ALTER TABLE para colunas que estiverem faltando. Exemplo:

```sql
-- Migration v6: adicionar colunas de canal de contexto em erros_dpv
-- Aplicar no banco: dep_viagem

ALTER TABLE erros_dpv ADD COLUMN IF NOT EXISTS origem VARCHAR(100);
ALTER TABLE erros_dpv ADD COLUMN IF NOT EXISTS workflow_id VARCHAR(100);
ALTER TABLE erros_dpv ADD COLUMN IF NOT EXISTS ultimo_no VARCHAR(200);
ALTER TABLE erros_dpv ADD COLUMN IF NOT EXISTS payload_json JSONB;
ALTER TABLE erros_dpv ADD COLUMN IF NOT EXISTS lido_em TIMESTAMPTZ;
ALTER TABLE erros_dpv ALTER COLUMN status SET DEFAULT 'pendente';
```

Remover as linhas das colunas que já existirem para não gerar erro.

### Passo 3 — Aplicar a migration no banco

Executar o conteúdo do arquivo v6 no banco `dep_viagem`.

Confirmar com:
```sql
SELECT column_name FROM information_schema.columns
WHERE table_name = 'erros_dpv' ORDER BY ordinal_position;
```

---

## BLOCO 2 — Atualizar WF-DPV.CHK (Tarefa 3)

**Workflow:** WF-DPV.CHK  
**ID n8n:** `1c8Ag8NgvtOiRYr7`

### Passo 4 — Verificar query atual do nó de SELECT

Abrir o workflow e localizar o nó PostgreSQL de leitura.
Verificar se a query tem filtro por `origem` ou outro filtro que limite os resultados.

### Passo 5 — Substituir query do nó de SELECT

A query deve ser:

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

### Passo 6 — Adicionar nó de marcar como lido

Após o nó de SELECT, adicionar um nó PostgreSQL:

**Nome:** `DB | Marcar Contexto Como Lido`  
**Credencial:** `DB_dep_viagem`  
**Query:**
```sql
UPDATE erros_dpv
SET status = 'lido', lido_em = NOW()
WHERE status = 'pendente';
```

Conectar: SELECT → Marcar Como Lido → restante do fluxo existente.

---

## BLOCO 3 — Substituir WhatsApp por PostgreSQL no n8n_contratos (Tarefa 4)

### Passo 7 — Localizar workflows do n8n_contratos com nós WhatsApp

Buscar no n8n todos os workflows do projeto `n8n_contratos` que possuam
nós `HTTP Request` apontando para a Evolution API (URL contém `evolution-api`
ou header `apikey`).

Listar os workflows encontrados antes de alterar qualquer coisa.

### Passo 8 — Para cada workflow encontrado, adicionar dois nós

**Nó A — SET | Montar Contexto Agente**  
Posicionar antes do nó HTTP de WhatsApp.  
Campos a definir:

```
origem      → "n8n_contratos"
workflow_id → ID do workflow atual
descricao   → texto descritivo do que aconteceu (ex: "Erro ao processar X")
ultimo_no   → nome do nó anterior no fluxo
payload     → objeto com: erro (se houver), dados de entrada, timestamp ISO
```

**Nó B — DB | Registrar Contexto Agente**  
**Credencial:** `DB_dep_viagem` (ID: `ggViIQGkepjwuOdv`)  
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
);
```

### Passo 9 — Rerotar o fluxo

Desconectar a aresta que ia para o nó HTTP WhatsApp.
Conectar: nó anterior → SET | Montar Contexto → DB | Registrar Contexto.
**Não deletar** o nó HTTP WhatsApp ainda — apenas desconectar.

---

## BLOCO 4 — Adicionar CLAUDE.md na raiz do projeto (Tarefa 5)

### Passo 10 — Criar o arquivo CLAUDE.md

Criar o arquivo `C:\GITHUB\DPV\CLAUDE.md` com este conteúdo exato:

```markdown
# CLAUDE.md — dep-viagem (DPV)

## PROTOCOLO OBRIGATÓRIO DE INÍCIO DE SESSÃO

Antes de ler qualquer arquivo do projeto, execute esta query no banco `dep_viagem`
usando a credencial `DB_dep_viagem` (ID: `ggViIQGkepjwuOdv`):

SELECT id, origem, workflow_id, descricao, ultimo_no, payload_json, created_at
FROM erros_dpv
WHERE status = 'pendente'
ORDER BY created_at DESC
LIMIT 10;

Se houver registros: trabalhe APENAS no que está nesses registros.
Não leia o projeto inteiro. O contexto já está no banco.

Se não houver registros: consulte o BRIEFING_AGENTE.md para orientação geral.

Após ler, marque como lido:

UPDATE erros_dpv SET status = 'lido', lido_em = NOW() WHERE status = 'pendente';

---

## REGRAS DE EXECUÇÃO

- Nunca use a credencial DB_n8n_contratos (ID: 3z35ZPyLInGNam1Y) em workflows DPV
- Sempre use DB_dep_viagem (ID: ggViIQGkepjwuOdv) para o banco dep_viagem
- Nunca ative o WF-DPV.01 sem confirmar que o P16 (bug SWITCH) está resolvido
- Sempre commitar migrations antes de aplicar no banco

---

## REFERÊNCIAS RÁPIDAS

n8n:          https://n8n.solucaomadeira.com
Banco projeto: dep_viagem
Credencial DB: DB_dep_viagem / ggViIQGkepjwuOdv
WF-DPV.CHK:   1c8Ag8NgvtOiRYr7
WF-DPV.01:    z0F4H4NUyLErFjZ7 — MANTER DESATIVADO até P16 resolvido
Repositório:  C:\GITHUB\DPV
```

---

## BLOCO 5 — Commits finais (Tarefa 6)

### Passo 11 — Commitar tudo

```bash
cd C:\GITHUB\DPV

git add CLAUDE.md
git commit -m "docs: adicionar CLAUDE.md com protocolo de inicio de sessao"

git add database/migrations/v6_erros_dpv_canal_contexto.sql
git commit -m "db: migration v6 canal de contexto em erros_dpv"

git commit -m "wf: exportar WF-DPV.CHK atualizado com marcar como lido"
```

---

## CRITÉRIO DE SUCESSO — verificar antes de encerrar

- [ ] `erros_dpv` tem todas as colunas do schema necessário
- [ ] Migration v6 existe em `database/migrations/`
- [ ] WF-DPV.CHK retorna registros de qualquer origem
- [ ] WF-DPV.CHK marca registros como lidos após SELECT
- [ ] Workflows do n8n_contratos NÃO disparam mensagem WhatsApp
- [ ] INSERT em `erros_dpv` funciona via teste manual
- [ ] `CLAUDE.md` existe na raiz `C:\GITHUB\DPV`
- [ ] Todos os commits feitos e push realizado

---

## TESTE FINAL

1. Disparar execução manual de um workflow do n8n_contratos
2. Verificar: `SELECT * FROM erros_dpv WHERE status = 'pendente' ORDER BY created_at DESC LIMIT 5;`
3. Confirmar que o registro apareceu com campos preenchidos
4. Abrir nova sessão do Claude Code no projeto `C:\GITHUB\DPV`
5. Confirmar que ele leu o banco antes de qualquer outra ação
