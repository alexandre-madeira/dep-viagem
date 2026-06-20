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
