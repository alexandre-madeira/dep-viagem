#!/bin/bash
# Script de commit final — Sessão 19/06/2026
# Execute em C:\GITHUB\DPV

set -e

echo "=== COMMITS DEP-VIAGEM 19/06/2026 ==="

# 1. Atualizar BRIEFING_AGENTE.md
echo "✓ Atualizando BRIEFING_AGENTE.md..."
# (substituir pelo arquivo gerado nesta sessão)

# 2. Criar migrations v4 e v5
echo "✓ Criando migration v4..."
mkdir -p database/migrations
cat > database/migrations/v4_cadastro_usuarios.sql << 'EOF'
-- Migration v4: cadastro de usuários com validação por e-mail
-- Aplicada em: 19/06/2026

ALTER TABLE funcionarios ADD COLUMN IF NOT EXISTS email VARCHAR(150);

CREATE TABLE IF NOT EXISTS cadastros_pendentes (
  phone             VARCHAR(20) PRIMARY KEY,
  step              VARCHAR(30) NOT NULL DEFAULT 'aguardando_nome',
  nome_temp         VARCHAR(100),
  email_temp        VARCHAR(150),
  codigo            VARCHAR(6),
  codigo_expira     TIMESTAMP,
  tentativas        INT DEFAULT 0,
  criado_em         TIMESTAMP DEFAULT NOW(),
  atualizado_em     TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_cadastros_phone ON cadastros_pendentes(phone);
CREATE INDEX IF NOT EXISTS idx_funcionarios_phone ON funcionarios(phone);
EOF

echo "✓ Criando migration v5..."
cat > database/migrations/v5_erros_dpv.sql << 'EOF'
-- Migration v5: fila de erros para ciclo de autocorreção
-- Aplicada em: 19/06/2026

CREATE TABLE IF NOT EXISTS erros_dpv (
  id                SERIAL PRIMARY KEY,
  workflow_id       VARCHAR(50) NOT NULL,
  workflow_nome     VARCHAR(100),
  no_nome           VARCHAR(150),
  no_tipo           VARCHAR(100),
  erro_msg          TEXT,
  codigo_atual      TEXT,
  payload_entrada   JSONB,
  execution_id      VARCHAR(50),
  execution_url     VARCHAR(255),
  status            VARCHAR(20) NOT NULL DEFAULT 'pendente',
  fase_analise      VARCHAR(20),
  correcao_aplicada TEXT,
  resolvido_em      TIMESTAMP,
  created_at        TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_erros_status ON erros_dpv(status);
CREATE INDEX IF NOT EXISTS idx_erros_workflow ON erros_dpv(workflow_id);
CREATE INDEX IF NOT EXISTS idx_erros_created ON erros_dpv(created_at DESC);
EOF

# 3. Atualizar workflows/IDS.md
echo "✓ Atualizando workflows/IDS.md..."
cat > workflows/IDS.md << 'EOF'
# Workflows DPV — IDs n8n

| Workflow | ID | Status | Notas |
|---|---|---|---|
| WF-DPV.01 - Receptor de NF | z0F4H4NUyLErFjZ7 | 🔴 P16 | IF bloco não funciona |
| WF-DPV.02 - Extrator IA | 31hBkBVq6rduQKXM | ✅ Ativo | Anthropic DPV configurada |
| WF-DPV.03 - Controle de Viagem | ruf039UAwh9KqIZo | ✅ Ativo | Aguarda P16 |
| WF-DPV.04 - Relatório PDF | acKIy44sUfDgOR2E | ✅ Ativo | Gotenberg no EasyPanel |
| WF-DPV.05 - Setup Banco | eIm1nVXe1qnCKhYz | ✅ Executado | Migrations aplicadas |
| WF-DPV.06 - Painel Financeiro | fRA3D3njIJOWmtqU | ✅ Ativo | Mobile-ready, server-side HTML |
| WF-DPV.07 - Cadastro Usuários | 6SwQvQ5IVL8oVtUk | ✅ Ativo | Novo 19/06 — e-mail validation |
| WF-DPV.CHK - Verificação Estado | 1c8Ag8NgvtOiRYr7 | ✅ Ativo | Novo 19/06 — check erros_dpv |
| WF-DPV.SIM - Simulador | KeDFPVOx6DwXLk6i | ⚠️ FALHA | P16: bloqueia ciclo e2e |
| WF-DPV.TEST - Diagnóstico | FjiFu11QnyGSDa4o | ✅ Ativo | Utilitário |
| WF-DPV.MAINT - Limpeza | GFoZCyAHX0HwNAsl | ✅ Ativo | Utilitário |
EOF

# 4. Adicionar documentação P16
echo "✓ Adicionando documentação P16..."
mkdir -p docs
cat > docs/P16_Bug_IF_Funcionario.md << 'EOF'
# P16 — Bug: IF Funcionario Cadastrado executa ambas as branches

## Problema

Nó `WF-DPV.01 - IF | Funcionario Cadastrado?` não funciona como IF/ELSE.

Quando recebe `id: "5"` (string, presente):
- Deveria: branch TRUE → `SWITCH | Tipo de Mensagem`
- Realmente: ambas as branches simultaneamente
- Resultado: usuários cadastrados são ignorados

## Impacto

- ❌ WF-DPV.03 nunca é chamado (Handler de Comandos)
- ❌ Mensagens INICIAR/ENCERRAR/RELATORIO descartadas
- ❌ WF-DPV.SIM não passa ciclo e2e

## Solução recomendada

Substituir IF por SWITCH com lógica explícita:

```n8n
DB | Verificar Funcionario
    ↓
SWITCH | Roteamento Cadastro
    ├── when: $json.id != null && $json.id != ""
    │   → SWITCH | Tipo de Mensagem
    └── default:
        → EXEC | Cadastrar Usuario
```

## Status

Descoberto em exec 61270 (19/06/2026 21:02 UTC)
Bloqueante para teste e2e
Aguardando resolução sessão seguinte
EOF

# 5. Commit tudo
echo ""
echo "=== CRIANDO COMMITS ==="

git add BRIEFING_AGENTE.md
git add database/migrations/v4_cadastro_usuarios.sql
git add database/migrations/v5_erros_dpv.sql
git add workflows/IDS.md
git add docs/P16_Bug_IF_Funcionario.md

git commit -m "feat: WF-DPV.07, erros_dpv, P16 descoberto

Implementação:
- WF-DPV.07: cadastro usuarios via WhatsApp com validacao e-mail
- Tabela erros_dpv: fila de autocorrecao (WF-ERR-CTX → DB)
- WF-DPV.CHK: verificacao rapida de estado do banco
- Migration v4: cadastros_pendentes + email em funcionarios
- Migration v5: erros_dpv para ciclo de debugging

Bugs:
- P16: IF Funcionario Cadastrado executa ambas branches (BLOQUEANTE)
  Afeta WF-DPV.01 → WF-DPV.03 roteamento
  Usuarios cadastrados ignoram mensagens

Testes:
- WF-DPV.SIM: ciclo e2e falha em INICIAR (P16)
- WF-DPV.CHK: estado do banco OK
- Painel mobile: OK em GET /webhook/dpv-financeiro-ui

Proximo:
- Corrigir P16 (Switch em vez de IF)
- Testar WF-DPV.SIM completo
- Exportar 7 workflows como JSON"

git push

echo ""
echo "=== COMMIT CONCLUÍDO ==="
echo "Git: dep-viagem atualizado"
echo "Pendência: P16 para próxima sessão"
