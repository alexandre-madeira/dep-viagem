# LIÇÕES APRENDIDAS — dep-viagem (DPV)

---

> ⚠️ ITEM MIGRADO DO n8n_contratos — Verificar necessidade real antes de executar.
> Este item foi registrado em sessão anterior e pode estar superado.
> Analise o estado atual do projeto antes de agir.

---

## n8n MCP global não funciona no n8n 2.x

Lição aprendida no DPV: `n8n-mcp` global não funciona no n8n 2.25.7.
O n8n 2.x usa MCP por workflow, não globalmente.

**Solução:** Usar sempre REST API com a API Key.

```bash
curl https://n8n.solucaomadeira.com/api/v1/workflows \
  -H "X-N8N-API-KEY: SUA_CHAVE"
```

JWT configurado em `settings.json` do Claude Code.

---

## Registro do projeto no banco de infra

O projeto DPV estava registrado na tabela `projetos_iatech` do banco `n8n_contratos`:

| sigla | nome | banco_pg | status | versão |
|---|---|---|---|---|
| DPV | dep-viagem | dep_viagem | ativo | v1.0 |

> **Nota:** A tabela `projetos_iatech` foi substituída pela tabela `projetos` na arquitetura atual.
> Verificar se o registro DPV foi migrado para a tabela `projetos`.

---

## Pendências históricas registradas (P11/P12)

Status registrado em sessão anterior: `ativo — pendências P11/P12`
Verificar estado atual antes de agir.
