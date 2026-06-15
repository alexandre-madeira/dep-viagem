# ARQUITETURA_BANCOS.md — IATECH
Referência para separação entre banco de infraestrutura e bancos de projeto.
Versão: 1.0 — 14/06/2026

---

## PRINCÍPIO

Cada projeto tem seu próprio banco PostgreSQL e sua própria credencial n8n.
O banco `n8n_contratos` é exclusivo de infraestrutura — nunca recebe dados de projeto.

```
n8n_contratos   → infra: metadados, projetos_iatech, configurações globais
dep_viagem      → projeto DPV exclusivo
{proximo}       → próximo projeto exclusivo
```

---

## BANCOS EXISTENTES

| Banco | Credencial n8n | ID credencial | Uso |
|---|---|---|---|
| n8n_contratos | DB_n8n_contratos | 3z35ZPyLInGNam1Y | INFRA — nunca usar em projetos |
| dep_viagem | DB_dep_viagem | ggViIQGkepjwuOdv | Projeto DPV exclusivo |

### Credenciais que NÃO funcionam (não usar)
- DB_proj_solu
- Postgres_bd_agente
- db_prestconta_db
- DB_supportfaqagent

---

## REGRA PARA NOVOS PROJETOS

1. Criar banco PostgreSQL dedicado: `CREATE DATABASE {nome_projeto};`
2. Criar credencial n8n: `DB_{sigla}` apontando para o novo banco
3. Registrar na tabela `projetos_iatech` (banco `n8n_contratos`)
4. **Nunca** usar `DB_n8n_contratos` nos workflows do projeto
5. Registrar ID da credencial no `BRIEFING_AGENTE.md` do projeto

---

## HISTÓRICO — LEGADO DPV

Durante o desenvolvimento inicial do DPV, os workflows usavam `DB_n8n_contratos`
por ausência de banco dedicado. Isso foi corrigido:

- Banco `dep_viagem` criado
- Credencial `DB_dep_viagem` (ID: `ggViIQGkepjwuOdv`) criada e aplicada nos 6 workflows
- Dados legados no `n8n_contratos` pendentes de remoção (ver abaixo)

### Limpeza concluída — 14/06/2026
Tabelas de projeto removidas do `n8n_contratos`:
- `despesas_viagem` ✅ removida
- `viagens` ✅ removida
- `funcionarios` ✅ removida

Tabelas de infra mantidas: `arquitetura`, `backlog`, `projetos`, `node_test_contract`, `node_test_contract_historico`
