# CLAUDE.md — dep-viagem (DPV)

## PROTOCOLO OBRIGATÓRIO DE INÍCIO DE SESSÃO

**Antes de ler qualquer arquivo do projeto, execute esta query no banco `dep_viagem`
usando a credencial `DB_dep_viagem` (ID: `ggViIQGkepjwuOdv`):**

```sql
SELECT id, origem, workflow_id, descricao, ultimo_no, payload_json, created_at
FROM erros_dpv
WHERE status = 'pendente'
ORDER BY created_at DESC
LIMIT 10;
```

**Se houver registros:** trabalhe APENAS no que está nesses registros.
Não leia o projeto inteiro. O contexto já está no banco.

**Se não houver registros:** consulte o BRIEFING_AGENTE.md para orientação geral.

**Após ler, marque como lido:**
```sql
UPDATE erros_dpv SET status = 'lido', lido_em = NOW() WHERE status = 'pendente';
```

---

## REGRAS DE EXECUÇÃO

- **Nunca** use a credencial `DB_n8n_contratos` (ID: `3z35ZPyLInGNam1Y`) em workflows DPV
- **Sempre** use `DB_dep_viagem` (ID: `ggViIQGkepjwuOdv`) para o banco `dep_viagem`
- **Nunca** ative o WF-DPV.01 sem confirmar que o P16 (bug SWITCH) está resolvido
- **Sempre** commitar migrations antes de aplicar no banco

---

## REFERÊNCIAS RÁPIDAS

| Item | Valor |
|---|---|
| n8n | https://n8n.solucaomadeira.com |
| Banco projeto | `dep_viagem` |
| Credencial DB | `DB_dep_viagem` / `ggViIQGkepjwuOdv` |
| WF-DPV.CHK | `1c8Ag8NgvtOiRYr7` |
| WF-DPV.01 | `z0F4H4NUyLErFjZ7` — **MANTER DESATIVADO até P16 resolvido** |
| Repositório | `C:\GITHUB\DPV` |
