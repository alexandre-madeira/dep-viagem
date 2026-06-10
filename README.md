# dep-viagem [DPV]

> Sistema de gestão de despesas de viagem via WhatsApp com relatório financeiro em PDF.

## Fluxo de uso

```
📱 Funcionário envia foto da NF
        ↓
🤖 Claude Vision extrai dados
        ↓
💾 Salva no PostgreSQL
        ↓
✅ Confirmação pelo WhatsApp

📱 Funcionário envia "RELATORIO"
        ↓
📄 PDF gerado e enviado

💻 Financeiro acessa painel web
        ↓
🔍 Filtra, aprova, baixa ZIP e PDF
```

## Comandos WhatsApp

| Comando | Ação |
|---|---|
| `INICIAR VIAGEM` | Inicia com nome automático |
| `INICIAR São Paulo` | Inicia viagem com nome personalizado |
| `ENCERRAR VIAGEM` | Encerra viagem ativa |
| `RELATORIO` | Gera e envia PDF financeiro |
| *(foto de NF)* | Registra despesa automaticamente |

## Categorias

`alimentacao` · `combustivel` · `hospedagem` · `transporte` · `pedagio` · `outros`

## Workflows n8n

| ID | Workflow | Tipo |
|---|---|---|
| `z0F4H4NUyLErFjZ7` | WF-DPV.01 - Receptor de NF | Principal |
| `31hBkBVq6rduQKXM` | WF-DPV.02 - Extrator IA | Subworkflow |
| `ruf039UAwh9KqIZo` | WF-DPV.03 - Controle de Viagem | Handler |
| `acKIy44sUfDgOR2E` | WF-DPV.04 - Relatório PDF | Principal |
| `eIm1nVXe1qnCKhYz` | WF-DPV.05 - Setup Banco | Utilitário |
| `fRA3D3njIJOWmtqU` | WF-DPV.06 - Painel Financeiro | Backend |

## Stack

| Camada | Tecnologia |
|---|---|
| Orquestração | n8n self-hosted |
| WhatsApp | Evolution API self-hosted |
| IA | Anthropic Claude (Vision) |
| Banco | PostgreSQL (`DB_n8n_contratos`) |
| PDF | Gotenberg (`http://gotenberg:3000`) |
| Painel | React (arquivo `.jsx`) |

## Estrutura do repositório

```
dep-viagem/
├── README.md
├── docs/
│   ├── ARQUITETURA.md
│   ├── PENDENCIAS.md
│   ├── PROTOCOLO_dep-viagem.md
│   └── GIT_PROCESSO.md          ← processo de versionamento
├── database/
│   └── setup.sql
├── workflows/
│   ├── IDS.md
│   └── *.json                   ← exportar do n8n manualmente
└── painel/
    └── painel-financeiro-dpv.jsx
```
