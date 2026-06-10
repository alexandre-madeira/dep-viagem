# Painel Financeiro — dep-viagem [DPV]

## Arquivos

```
painel/
├── painel-financeiro-dpv.jsx   ← versão PRODUÇÃO (conecta no n8n)
└── README.md
```

## Configuração obrigatória

Abra `painel-financeiro-dpv.jsx` e ajuste na linha do `CONFIG`:
```js
const CONFIG = {
  API_BASE: "https://n8n.solucaomadeira.com/webhook/dpv-financeiro",
  // Troque pela URL do seu n8n
};
```

## Como rodar localmente

```powershell
# Instalar dependências (uma vez só)
cd C:\GITHUB
npx create-react-app dpv-painel
cd dpv-painel

# Copiar o painel
copy C:\GITHUB\DPV\painel\painel-financeiro-dpv.jsx src\App.jsx

# Rodar
npm start
# Abre em http://localhost:3000
```

## Senha padrão
`SENHA_CONFIGURADA_NO_N8N` — alterar em: n8n → WF-DPV.06 → nó `IF | Autenticacao Valida?`

## Quando commitar

Sempre que alterar o painel:
```bash
git add painel/
git commit -m "painel: descrição da alteração"
git push
```
