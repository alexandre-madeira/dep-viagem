# Arquitetura — dep-viagem [DPV]

## MACRO — Integrações Externas

| Sistema | Papel | Endereço |
|---|---|---|
| WhatsApp (Evolution API) | Entrada de fotos + entrega de relatório | `http://evolution-api:8080` |
| Claude Vision (Anthropic) | Extração de dados das NFs | `api.anthropic.com` |
| PostgreSQL | Armazenamento de viagens e despesas | credencial `DB_n8n_contratos` |
| Gotenberg | Conversão HTML → PDF | `http://gotenberg:3000` |
| n8n | Orquestrador de todos os fluxos | self-hosted |

## MESO — Workflows

```
WF-DPV.01 (Receptor)
├── [imagem]  → WF-DPV.02 (Extrator IA)
│                   ├── Verifica duplicata
│                   ├── Claude Vision → Postgres
│                   └── Confirmação WhatsApp (com nome do funcionário)
└── [comando] → WF-DPV.03 (Controle Viagem)
                    ├── INICIAR  → INSERT viagens (nome_viagem) → WhatsApp
                    ├── ENCERRAR → UPDATE viagens → WhatsApp
                    └── RELATORIO → WF-DPV.04 (Relatório PDF)
                                        └── Postgres → HTML → Gotenberg → PDF → WhatsApp

WF-DPV.06 (Painel Financeiro — Backend)
├── POST /dpv-financeiro/auth          → valida senha
├── POST /dpv-financeiro/viagens       → lista viagens + despesas
├── POST /dpv-financeiro/relatorio-pdf → dispara WF-DPV.04
├── POST /dpv-financeiro/zip-nfs       → metadados das NFs em ordem
└── POST /dpv-financeiro/aprovar       → UPDATE status=aprovada
```

## Painel Financeiro (React)

Arquivo: `painel/painel-financeiro-dpv.jsx`

Funcionalidades:
- Login com senha
- Cards de resumo (total, viagens, notas)
- Filtros: busca, status, categoria, período
- Por viagem: barras por categoria, tabela de NFs
- Ações: PDF, ZIP, Aprovar

Conecta em: `https://n8n.solucaomadeira.com/webhook/dpv-financeiro`

## Modelo de Dados

```sql
funcionarios    (id, phone UNIQUE, nome, empresa, ativo, created_at)
viagens         (id, phone, nome_viagem, data_inicio, data_fim, status, created_at, updated_at)
despesas_viagem (id, phone, estabelecimento, cnpj, valor_total, data_emissao, categoria, itens_json, message_id, created_at)
```

## Convenção de Nomenclatura

- Workflows: `WF-DPV.NN - Descrição [dep-viagem]`
- Nós: `WF-DPV.NN - TIPO | Descrição`
- Tipos: TRIGGER, SET, SWITCH, HTTP, DB, EXEC, AGENT, CODE, AGG, RESPOND, NOOP, PARSER, LLM, IF
