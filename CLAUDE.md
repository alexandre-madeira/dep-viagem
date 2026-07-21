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

## IDIOMA DE COMUNICACAO

TODAS as perguntas, confirmacoes, resumos e comunicacoes do agente com o usuario
devem ser em portugues brasileiro. Sem excecoes, independente do idioma do codigo
ou dos logs.

---

## PROTOCOLO OBRIGATORIO DE INICIO DE SESSAO

**Execute esta query no banco `n8n_contratos` usando a credencial `DB_n8n_contratos`
(ID: `3z35ZPyLInGNam1Y`):**

```sql
SELECT id, workflow_id, workflow_nome, no_nome, erro_msg, created_at
FROM erros_workflows
WHERE resolvido = false
ORDER BY created_at DESC
LIMIT 10;
```

**Se houver registros:** trabalhe APENAS no que esta nesses registros.
Nao leia o projeto inteiro. O contexto ja esta no banco.

**Se nao houver registros:** consulte o BRIEFING_AGENTE.md para orientacao geral.

**Apos resolver um erro, marque como resolvido:**
```sql
UPDATE erros_workflows SET resolvido = true WHERE id = <ID>;
```

---

## REGRAS DE EXECUCAO

- **Nunca** use a credencial `DB_n8n_contratos` (ID: `3z35ZPyLInGNam1Y`) em workflows DPV
- **Sempre** use `DB_dep_viagem` (ID: `ggViIQGkepjwuOdv`) para o banco `dep_viagem`
- **Sempre** commitar migrations antes de aplicar no banco
- **Nunca** publicar workflow sem chamar `publish_workflow` apos `update_workflow`

---

## REFERENCIAS RAPIDAS

| Item | Valor |
|---|---|
| n8n | https://n8n.solucaomadeira.com |
| Adminer | https://adminer.solucaomadeira.com |
| Evolution API | https://evolution.solucaomadeira.com |
| Instancia Evolution | `DVP` |
| Banco projeto | `dep_viagem` |
| Banco infra | `n8n_contratos` |
| Credencial DB projeto | `DB_dep_viagem` |
| Credencial DB infra | `DB_n8n_contratos` |
| Credencial Evolution | `HEADER_API_EVOLUTION_ENVIO` |
| Credencial Anthropic | `Anthropic DPV` |
| WF-DPV.01 | `z0F4H4NUyLErFjZ7` |
| WF-DPV.02 | `31hBkBVq6rduQKXM` |
| WF-DPV.03 | `ruf039UAwh9KqIZo` |
| WF-DPV.04 | `acKIy44sUfDgOR2E` |
| WF-DPV.05 | `eIm1nVXe1qnCKhYz` |
| WF-DPV.06 | `fRA3D3njIJOWmtqU` |
| WF-DPV.07 | `6SwQvQ5IVL8oVtUk` |
| WF-DPV.CHK | `1c8Ag8NgvtOiRYr7` |
| WF-ERR-CTX | `6LU8TtukzsbgGCHe` |
| Repositorio local | `C:\GITHUB\DPV` |
| GitHub | `alexandre-madeira/dep-viagem` |