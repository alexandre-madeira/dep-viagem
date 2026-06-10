# SETUP_LOCAL.md — dep-viagem [DPV]
Guia completo para montar o projeto em C:\GITHUB\DPV

---

## PASSO 1 — Criar a pasta local

Abra o **PowerShell** ou **Prompt de Comando** e execute:

```powershell
# Criar pasta do projeto
mkdir C:\GITHUB\DPV
cd C:\GITHUB\DPV
```

---

## PASSO 2 — Criar a estrutura de pastas

```powershell
mkdir docs
mkdir database
mkdir workflows
mkdir painel
```

Resultado esperado:
```
C:\GITHUB\DPV\
├── docs\
├── database\
├── workflows\
└── painel\
```

---

## PASSO 3 — Copiar os arquivos do ZIP

1. Baixe o arquivo `dep-viagem-final.zip` (entregue pelo agente)
2. Extraia o conteúdo
3. Copie os arquivos para `C:\GITHUB\DPV\` conforme a estrutura:

```
C:\GITHUB\DPV\
├── .gitignore
├── README.md
├── SETUP_LOCAL.md                  ← este arquivo
├── docs\
│   ├── ARQUITETURA.md
│   ├── GIT_PROCESSO.md
│   ├── PENDENCIAS.md
│   └── PROTOCOLO_dep-viagem.md
├── database\
│   └── setup.sql
├── workflows\
│   └── IDS.md                      ← adicionar JSONs do n8n aqui
└── painel\
    ├── README.md
    └── painel-financeiro-dpv.jsx   ← interface do financeiro
```

---

## PASSO 4 — Inicializar o Git

### 4.1 Verificar se Git está instalado
```powershell
git --version
# Esperado: git version 2.x.x
# Se não estiver: https://git-scm.com/download/win
```

### 4.2 Configurar seu usuário (uma vez só)
```powershell
git config --global user.name "Alexandre Madeira"
git config --global user.email "alexandremade@gmail.com"
```

### 4.3 Inicializar o repositório
```powershell
cd C:\GITHUB\DPV
git init
git add .
git commit -m "init: dep-viagem criado via agente"
```

---

## PASSO 5 — Conectar ao GitHub

### 5.1 Criar o repositório no GitHub
1. Acesse https://github.com/new
2. Repository name: `dep-viagem`
3. Visibilidade: **Private**
4. ⚠️ NÃO marque "Add README" (já temos o nosso)
5. Clique **Create repository**

### 5.2 Conectar e enviar
```powershell
git remote add origin https://github.com/alexandre-madeira/dep-viagem.git
git branch -M main
git push -u origin main
```

### 5.3 Verificar no browser
Acesse: https://github.com/alexandre-madeira/dep-viagem
Você deve ver todos os arquivos listados.

---

## PASSO 6 — Exportar os workflows do n8n

Faça isso para cada um dos 6 workflows:

| Workflow | ID | URL direta |
|---|---|---|
| WF-DPV.01 | z0F4H4NUyLErFjZ7 | https://n8n.solucaomadeira.com/workflow/z0F4H4NUyLErFjZ7 |
| WF-DPV.02 | 31hBkBVq6rduQKXM | https://n8n.solucaomadeira.com/workflow/31hBkBVq6rduQKXM |
| WF-DPV.03 | ruf039UAwh9KqIZo | https://n8n.solucaomadeira.com/workflow/ruf039UAwh9KqIZo |
| WF-DPV.04 | acKIy44sUfDgOR2E | https://n8n.solucaomadeira.com/workflow/acKIy44sUfDgOR2E |
| WF-DPV.05 | eIm1nVXe1qnCKhYz | https://n8n.solucaomadeira.com/workflow/eIm1nVXe1qnCKhYz |
| WF-DPV.06 | fRA3D3njIJOWmtqU | https://n8n.solucaomadeira.com/workflow/fRA3D3njIJOWmtqU |

**Como exportar cada um:**
1. Abra a URL do workflow
2. Clique nos `...` (três pontos) no canto superior direito
3. Clique em **Download**
4. Salve como `WF-DPV-01.json`, `WF-DPV-02.json` etc. em `C:\GITHUB\DPV\workflows\`

**Commitar os workflows:**
```powershell
cd C:\GITHUB\DPV
git add workflows\
git commit -m "wf: exportar todos os workflows DPV v1.0"
git push
```

---

## PASSO 7 — Rodar o painel financeiro localmente

### Opção A — Sem instalar nada (recomendado para testar)
1. Abra o Claude: https://claude.ai
2. Crie um novo chat
3. Arraste o arquivo `painel\painel-financeiro-dpv.jsx`
4. Digite: "renderize este componente React"
5. Use a senha: `SENHA_CONFIGURADA_NO_N8N`

### Opção B — React local (para hospedar de verdade)

**Pré-requisito:** Node.js instalado → https://nodejs.org (versão LTS)

```powershell
# Verificar Node
node --version    # Esperado: v18.x ou superior
npm --version

# Criar app React
cd C:\GITHUB
npx create-react-app dpv-painel
cd dpv-painel

# Substituir o App.jsx pelo nosso painel
copy C:\GITHUB\DPV\painel\painel-financeiro-dpv.jsx src\App.jsx

# Iniciar em modo desenvolvimento
npm start
# Abre automaticamente: http://localhost:3000
```

### Opção C — Build para produção
```powershell
cd C:\GITHUB\dpv-painel
npm run build
# Pasta build\ estará pronta para hospedar em qualquer servidor
```

---

## PASSO 8 — Configurações pendentes no n8n

Antes de ativar os workflows, configure:

### P02 — API Key da Evolution API
- Abra cada workflow que tem nós HTTP de envio
- Em cada nó `HTTP | Enviar *` → aba Headers → campo `apikey`
- Cole a sua chave da Evolution API

### P03 — Credencial Anthropic
- No n8n: **Credentials** → **New** → buscar "Anthropic"
- Cole sua API Key do Anthropic
- Aplique no nó `LLM | Claude Vision` do WF-DPV.02

### P04 — Gotenberg no Docker
Adicione ao seu `docker-compose.yml`:
```yaml
gotenberg:
  image: gotenberg/gotenberg:8
  restart: unless-stopped
  ports:
    - "3000:3000"
```
Depois: `docker-compose up -d gotenberg`

### P06 — Trocar senha do painel
- n8n → WF-DPV.06 → nó `IF | Autenticacao Valida?`
- Altere o campo `rightValue` de `SENHA_CONFIGURADA_NO_N8N` para sua senha

---

## ROTINA DIÁRIA DE TRABALHO

```powershell
# Início do dia — puxar atualizações
cd C:\GITHUB\DPV
git pull origin main

# Após alterar workflow no n8n:
# 1. Exporte o JSON (ver Passo 6)
# 2. Salve em workflows\
git add workflows\WF-DPV-XX.json
git commit -m "wf: descrição da alteração"
git push

# Após alterar o painel:
git add painel\
git commit -m "painel: descrição da alteração"
git push

# Após alterar banco:
git add database\setup.sql
git commit -m "db: descrição da alteração"
git push
```

---

## CHECKLIST FINAL

- [ ] Pasta `C:\GITHUB\DPV` criada
- [ ] Arquivos do ZIP copiados
- [ ] Git inicializado (`git init`)
- [ ] Commit inicial feito
- [ ] Repositório GitHub criado (privado)
- [ ] Push inicial feito (`git push`)
- [ ] 6 workflows exportados como JSON e comitados
- [ ] API Key Evolution configurada nos workflows
- [ ] Credencial Anthropic criada no n8n
- [ ] Gotenberg adicionado ao Docker Compose
- [ ] Senha do painel trocada
- [ ] WF-DPV.01 ativado no n8n
- [ ] Painel testado localmente

---

## SUPORTE RÁPIDO

| Problema | Solução |
|---|---|
| `git` não reconhecido | Instalar Git: https://git-scm.com/download/win |
| `node` não reconhecido | Instalar Node.js: https://nodejs.org |
| Push rejeitado | `git pull --rebase origin main` depois `git push` |
| Painel não conecta no n8n | Verificar URL em `API_BASE` no topo do `.jsx` |
| Workflow não dispara | Verificar se está ativo (toggle no n8n) |
