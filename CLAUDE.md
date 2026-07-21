# CLAUDE.md — dep-viagem (DPV)

## LIMITE DE TOKENS POR OPERACAO

EXPRESSAMENTE PROIBIDO executar qualquer operacao que consuma mais de 10.000 tokens
sem autorizacao explicita e por escrito do usuario em portugues.

Isso inclui:
- Exportar workflows grandes via MCP
- Ler arquivos JSON extensos em loop
- Operacoes em massa sem aprovacao previa
- Agentes autonomos com muitas chamadas encadeadas

Antes de qualquer operacao potencialmente grande, estimar o custo e pedir autorizacao.
Formato da autorizacao aceita: mensagem em portugues do usuario confirmando a operacao.

---

## PROTOCOLO OBRIGATÓRIO DE INÍCIO DE SESSÃO

**Antes de ler qualquer arquivo do projeto, execute esta query no banco `dep_viagem`
usando a credencial `DB_dep_viagem` (ID: `ggViIQGkepjwuOdv`):**

```sql
SELECT id, workflow_id, workflow_nome, no_nome, no_tipo, erro_msg, execution_url, created_at
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
UPDATE erros_dpv SET status = 'lido' WHERE status = 'pendente';
```

---

## REGRAS DE EXECUÇÃO

- **Nunca** use a credencial `DB_n8n_contratos` (ID: `3z35ZPyLInGNam1Y`) em workflows DPV
- **Sempre** use `DB_dep_viagem` (ID: `ggViIQGkepjwuOdv`) para o banco `dep_viagem`
- **Sempre** commitar migrations antes de aplicar no banco

---

## REFERÊNCIAS RÁPIDAS

| Item | Valor |
|---|---|
| n8n | https://n8n.solucaomadeira.com |
| Banco projeto | `dep_viagem` |
| Credencial DB | `DB_dep_viagem` / `ggViIQGkepjwuOdv` |
| WF-DPV.CHK | `1c8Ag8NgvtOiRYr7` |
| WF-DPV.01 | `z0F4H4NUyLErFjZ7` — Ativo (P16 resolvido 20/06/2026) |
| Repositório | `C:\GITHUB\DPV` |
