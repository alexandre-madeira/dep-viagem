# P17 — Validação de Pagamento

**Status:** 🟡 Planejamento | **Prioridade:** Alta | **Data:** 20/06/2026

---

## 1. VISÃO GERAL

Adicionar validação obrigatória de pagamento em todas as despesas:
- **Tipo de Pagador:** empresa OU particular
- **Forma de Pagamento:** cartão OU dinheiro
- **CPF/CNPJ:** Quem foi debitado (11 ou 14 dígitos)
- **Valor + Data:** Obrigatórios

Diferencia: **NF com foto** (Claude Vision) vs **Despesa sem NF** (cadastro manual).

---

## 2. REQUISITOS FUNCIONAIS

### Combinações Válidas (únicas 4)

empresa + cartão
empresa + dinheiro
particular + cartão
particular + dinheiro


Qualquer outra combinação = erro com orientação de correção.

### Campos Obrigatórios

| Campo | Tipo | Validação | Fonte |
|-------|------|-----------|-------|
| tipo_pagador | string | ∈ [empresa, particular] | Claude Vision OU usuário |
| forma_pagamento | string | ∈ [cartão, dinheiro] | Claude Vision OU usuário |
| cpf_cnpj_pagador | string | ^[0-9]{11,14}$ | Claude Vision OU usuário |
| valor | decimal | > 0 && < 999999.99 | Claude Vision OU usuário |
| data_compra | date | [-90 dias, hoje] | Claude Vision OU usuário |
| categoria | string | (já existe) | Claude Vision |
| estabelecimento | string | (já existe) | Claude Vision |

---

## 3. ESTRUTURA DE DADOS

### Alterações em `despesas_viagem`

```sql
ALTER TABLE despesas_viagem ADD COLUMN IF NOT EXISTS (
  tipo_pagador VARCHAR(20),           -- 'empresa' | 'particular'
  forma_pagamento VARCHAR(20),        -- 'cartão' | 'dinheiro'
  cpf_cnpj_pagador VARCHAR(20),       -- 11 ou 14 dígitos
  sem_nf BOOLEAN DEFAULT false,       -- true = sem foto
  validado_manualmente BOOLEAN,       -- true = usuário preencheu
  observacoes_validacao TEXT
);

CREATE INDEX idx_despesas_tipo_forma ON despesas_viagem(tipo_pagador, forma_pagamento);
CREATE INDEX idx_despesas_cpf ON despesas_viagem(cpf_cnpj_pagador);
```

### Nova Tabela: `despesas_sem_nf_log`

```sql
CREATE TABLE IF NOT EXISTS despesas_sem_nf_log (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  phone VARCHAR(20),
  viagem_id INTEGER,
  descricao VARCHAR(200),
  tipo_pagador VARCHAR(20),
  forma_pagamento VARCHAR(20),
  cpf_cnpj_pagador VARCHAR(20),
  valor DECIMAL(10,2),
  data_compra DATE,
  criado_em TIMESTAMP DEFAULT NOW(),
  validacao_status VARCHAR(20)   -- 'pendente' | 'validado' | 'rejeitado'
);

CREATE INDEX idx_despesas_log_status ON despesas_sem_nf_log(validacao_status);
```

### Alterações em `funcionarios`

```sql
ALTER TABLE funcionarios ADD COLUMN IF NOT EXISTS (
  cpf_cnpj VARCHAR(20),
  tipo_pagador_padrao VARCHAR(20),    -- preferência para sugestão
  forma_pagamento_padrao VARCHAR(20)  -- preferência para sugestão
);
```

### Migration SQL

```sql
-- database/migrations/v6_validacao_pagamento.sql
-- [Consolidar os 3 ALTERs acima em um arquivo]
```

---

## 4. FLUXOS (SIMPLIFICADOS)

### Fluxo A: NF com Foto (WF-DPV.02)
Usuário envia foto

↓

Claude Vision extrai dados + tipo_pagador + forma_pagamento

↓

IF confiança < 0.8 OU campo faltante?

├─ SIM: Solicita preenchimento manual do campo faltante

└─ NÃO: Continua

↓

CODE | Validar Combinação (tipo × forma)

↓

IF válida?

├─ SIM: DB | Salvar com todos os campos

└─ NÃO: HTTP | Erro com lista de opções válidas

**Novo Prompt Claude Vision:**
Extrair de NF:

estabelecimento, cpf_cnpj, categoria, valor, data


NOVO: tipo_pagador (inferir: "empresa" se CNPJ grande, "particular" se CPF)
NOVO: forma_pagamento (inferir: "cartão" se visível, "dinheiro" se visível)

Responder em JSON puro:

{

"estabelecimento": "...",

"cpf_cnpj": "...",

"tipo_pagador": "empresa|particular|null",

"forma_pagamento": "cartão|dinheiro|null",

"categoria": "...",

"valor": 0,

"data": "YYYY-MM-DD",

"confianca": 0.95,

"campos_faltantes": []

}

### Fluxo B: Despesa sem NF (WF-DPV.03 - Novo Comando)
Usuário: "DESPESA | empresa | cartão | 12345678901234 | 150 | Descrição"

↓

CODE | Parse (extrai partes)

↓

CODE | Validar (verifica cada campo)

↓

IF válida?

├─ SIM: DB INSERT + HTTP Confirmado

└─ NÃO: HTTP Erro (qual campo?)

### Fluxo C: Aprovação (WF-DPV.06)
Financeiro vê despesa no painel

↓

IF falta tipo_pagador OU forma_pagamento OU cpf_cnpj?

├─ SIM: Botão "Completar" → formulário de preenchimento

└─ NÃO: Botão "Aprovar" ativa

↓

IF Rejeitar: registro rejeitado, usuário refaz

---

## 5. IMPACTO NOS WORKFLOWS

| Workflow | Mudança |
|----------|---------|
| **WF-DPV.02** | Prompt Claude Vision (+ tipo_pagador, forma) + CODE \| Validar Combinação |
| **WF-DPV.03** | Novo case DESPESA + 2 CODE nodes (parse, validar) |
| **WF-DPV.04** | Tabela relatório (+ tipo, forma) + resumo por combinação |
| **WF-DPV.06** | Filtros (tipo, forma) + validação manual no painel |
| **WF-DPV.07** | 3 etapas novas: CPF/CNPJ, tipo_pagador_padrao, forma_padrao |

---

## 6. VALIDAÇÕES (JavaScript/SQL)

### Validação de Combinação

```javascript
const combinacoes_validas = [
  ["empresa", "cartão"],
  ["empresa", "dinheiro"],
  ["particular", "cartão"],
  ["particular", "dinheiro"]
];

function isValid(tipo, forma) {
  return combinacoes_validas.some(c => c[0] === tipo && c[1] === forma);
}
```

### Validação de CPF/CNPJ

```javascript
/^[0-9]{11,14}$/.test(cpf_cnpj)  // 11 (CPF) ou 14 (CNPJ) dígitos
```

### Validação de Data

```javascript
const hoje = new Date();
const limite = new Date(hoje.setDate(hoje.getDate() - 90));
data >= limite && data <= new Date();
```

---

## 7. CASOS DE USO

### Caso 1: NF Automática (100% extraída)
Input: Foto clara de NF (empresa com CNPJ, forma visível)

Processo: Claude Vision extrai tudo automaticamente

Resultado: INSERT sem intervenção do usuário

Painel: "Validado ✓"

### Caso 2: NF com Campo Faltante
Input: Foto com CNPJ mas forma não visível

Processo: Claude Vision solicita "Cartão ou Dinheiro?"

Resultado: Usuário responde, sistema salva

Painel: "Validado (manual)"

### Caso 3: Despesa sem NF (Comando)
Input: "DESPESA | particular | cartão | 12345678901 | 75 | Uber"

Processo: Parse → Validação → INSERT

Resultado: Despesa + Log (status=pendente)

Painel: "Pendente validação"

### Caso 4: Rejeição (Painel)
Input: Financeiro vê erro (tipo errado)

Processo: Rejeita, pede correção

Resultado: Usuário reenvia com dados corretos

Painel: "Aprovado ✓"

---

## 8. IMPLEMENTAÇÃO (6 Fases)

### Fase 1: Banco (WF-DPV.05)
Execute migration v6

├─ ALTER despesas_viagem (+3 colunas)

├─ CREATE despesas_sem_nf_log

├─ ALTER funcionarios (+3 colunas)

└─ CREATE 4 índices

### Fase 2: Claude Vision (WF-DPV.02)
Atualizar prompt

Add CODE | Validar Combinação

Modificar HTTP | Erro

### Fase 3: Comandos (WF-DPV.03)
Add case DESPESA ao SWITCH

Add CODE | Parse Despesa

Add CODE | Validar Despesa

Conectar IF | Validação OK?

### Fase 4: Cadastro (WF-DPV.07)
Add 3 etapas (CPF, tipo_pagador, forma_pagamento)

Salvar em funcionarios

### Fase 5: Painel (WF-DPV.06)
Add filtros (tipo, forma)

Add coluna à tabela

Implementar form validação manual

### Fase 6: Relatório (WF-DPV.04)
Update HTML (+ colunas tipo/forma)

Add resumo por combinação

Test Gotenberg

---

## 9. TESTES

| Cenário | Input | Esperado |
|---------|-------|----------|
| NF automática | Foto clara, dados visíveis | Salva sem intervalo |
| Campo faltante | Forma ilegível | Solicita preenchimento |
| Comando válido | `DESPESA \| empresa \| cartão \| ...` | INSERT OK |
| Combinação inválida | tipo ou forma inválidos | Erro + opções |
| CPF inválido | Menos de 11 dígitos | Erro de formato |
| Data futura | Data > hoje | Bloqueado |
| Painel - validar | Clica "Validar" | UPDATE status |

---

## 10. CHECKLIST DE ENTREGA

- [ ] Migration v6 executada
- [ ] WF-DPV.02 Claude Vision (+ tipo, forma)
- [ ] WF-DPV.02 CODE | Validar Combinação
- [ ] WF-DPV.03 case DESPESA + validação
- [ ] WF-DPV.04 tabela relatório (+ tipo, forma)
- [ ] WF-DPV.06 filtros + validação manual
- [ ] WF-DPV.07 3 etapas de cadastro
- [ ] Testes: 10 cenários validados
- [ ] Commit no Git

---

**Pronto para Claude Code implementar em sequência.**