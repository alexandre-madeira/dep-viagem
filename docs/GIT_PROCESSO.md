# GIT_PROCESSO.md — dep-viagem [DPV]
Processo de versionamento do projeto.

---

## 1. CONFIGURAÇÃO INICIAL (fazer uma vez)

### 1.1 Criar repositório no GitHub
1. Acesse https://github.com/new
2. Nome: `dep-viagem`
3. Visibilidade: **Private**
4. Não inicializar com README (vamos enviar o nosso)
5. Clique em **Create repository**

### 1.2 Configurar Git local
```bash
git config --global user.name "Alexandre Madeira"
git config --global user.email "alexandremade@gmail.com"
```

### 1.3 Inicializar o repositório local
```bash
# Entre na pasta do projeto (onde está este arquivo)
cd dep-viagem

# Inicialize o Git
git init

# Conecte ao GitHub
git remote add origin https://github.com/alexandre-madeira/dep-viagem.git

# Commit inicial
git add .
git commit -m "init: dep-viagem criado via agente"

# Envie para o GitHub
git branch -M main
git push -u origin main
```

---

## 2. PROCESSO DE COMMIT — REGRAS DO PROJETO

### 2.1 Convenção de mensagens de commit

```
tipo: descrição curta em minúsculas

Tipos válidos:
  init      → criação inicial do projeto ou módulo
  feat      → nova funcionalidade
  fix       → correção de bug
  wf        → adição ou atualização de workflow n8n
  db        → mudança no banco de dados (migration, novo índice)
  docs      → documentação
  config    → configuração (credenciais, env, docker)
  painel    → alterações no painel financeiro
  hotfix    → correção urgente em produção
```

Exemplos:
```bash
git commit -m "wf: WF-DPV.02 adiciona validação de NF duplicada"
git commit -m "db: adiciona tabela funcionarios e campo nome_viagem"
git commit -m "painel: adiciona filtro por período no painel financeiro"
git commit -m "fix: corrige mapeamento imageUrl no WF-DPV.01"
git commit -m "docs: atualiza PENDENCIAS com status das melhorias"
```

### 2.2 Branches

```
main          → produção, sempre estável
dev           → desenvolvimento, integração de features
feature/xxx   → feature específica (ex: feature/zip-nfs)
hotfix/xxx    → correção urgente
```

Fluxo recomendado:
```bash
# Criar branch para nova feature
git checkout -b feature/nome-da-feature

# Trabalhar, commitar...
git add .
git commit -m "feat: descrição"

# Merge na dev
git checkout dev
git merge feature/nome-da-feature

# Quando estável, merge na main
git checkout main
git merge dev
git push origin main
```

---

## 3. O QUE COMMITAR — CHECKLIST

### ✅ SEMPRE commitar

| Arquivo/Pasta | Quando |
|---|---|
| `README.md` | Sempre que atualizar comandos, stack, links |
| `docs/*.md` | Sempre que atualizar arquitetura, pendências, protocolo |
| `database/setup.sql` | Sempre que criar ou alterar tabelas |
| `painel/painel-financeiro-dpv.jsx` | Sempre que alterar o painel financeiro |
| `workflows/IDS.md` | Sempre que um novo workflow for criado no n8n |
| `workflows/*.json` | Após exportar workflows do n8n (ver seção 4) |

### ❌ NUNCA commitar

```gitignore
# Criar arquivo .gitignore com:
.env
*.env.local
node_modules/
.DS_Store
Thumbs.db
*.log
secrets/
credenciais.txt
senha*.txt
```

---

## 4. EXPORTAR WORKFLOWS DO N8N PARA O GIT

Após qualquer alteração nos workflows, exporte e commite:

### 4.1 Exportar manualmente (interface)
1. Abra o workflow no n8n
2. Menu `...` (três pontos) → **Download**
3. Salve como `WF-DPV-NN.json` na pasta `workflows/`

### 4.2 Exportar via API (automatizado)
```bash
# Substituir SEU_HOST e SEU_API_KEY
N8N_HOST="https://n8n.solucaomadeira.com"
N8N_KEY="sua-api-key-aqui"

# IDs dos workflows DPV
declare -A WFS=(
  ["WF-DPV-01"]="z0F4H4NUyLErFjZ7"
  ["WF-DPV-02"]="31hBkBVq6rduQKXM"
  ["WF-DPV-03"]="ruf039UAwh9KqIZo"
  ["WF-DPV-04"]="acKIy44sUfDgOR2E"
  ["WF-DPV-05"]="eIm1nVXe1qnCKhYz"
  ["WF-DPV-06"]="fRA3D3njIJOWmtqU"
)

for nome in "${!WFS[@]}"; do
  id="${WFS[$nome]}"
  curl -s -H "X-N8N-API-KEY: $N8N_KEY" \
    "$N8N_HOST/api/v1/workflows/$id" \
    -o "workflows/$nome.json"
  echo "✅ $nome exportado"
done
```

### 4.3 Commitar os workflows
```bash
git add workflows/
git commit -m "wf: exportar workflows DPV atualizados"
git push
```

---

## 5. ROTINA RECOMENDADA — DIA A DIA

### Ao iniciar o dia
```bash
git pull origin main
```

### Ao fazer uma alteração no n8n
```bash
# 1. Exporte o workflow alterado (seção 4)
# 2. Commite
git add workflows/WF-DPV-XX.json
git commit -m "wf: descrição da alteração"
git push
```

### Ao alterar o banco
```bash
# 1. Atualize database/setup.sql
# 2. Documente em docs/PENDENCIAS.md se necessário
git add database/setup.sql docs/
git commit -m "db: descrição da alteração"
git push
```

### Ao alterar o painel
```bash
git add painel/
git commit -m "painel: descrição da alteração"
git push
```

---

## 6. RECUPERAR UMA VERSÃO ANTERIOR

```bash
# Ver histórico de commits
git log --oneline

# Voltar para um commit específico (somente visualizar)
git checkout abc1234

# Criar branch a partir de um commit antigo
git checkout -b recovery/nome abc1234

# Desfazer último commit (mantém arquivos)
git reset --soft HEAD~1

# Desfazer último commit (descarta arquivos — CUIDADO)
git reset --hard HEAD~1
```

---

## 7. TAGS DE VERSÃO

Marque versões estáveis:
```bash
# Criar tag
git tag -a v1.0 -m "v1.0 — MVP dep-viagem com painel financeiro"
git push origin v1.0

# Listar tags
git tag

# Versões sugeridas:
# v1.0 → MVP: WhatsApp + extração IA + relatório PDF
# v1.1 → Painel financeiro financeiro com login
# v1.2 → ZIP de NFs + aprovação pelo painel
```

---

## 8. STATUS ATUAL DO REPOSITÓRIO

| Item | Status |
|---|---|
| Repositório criado | ⏳ Pendente — seguir seção 1 |
| Commit inicial | ⏳ Pendente |
| Workflows exportados | ⏳ Pendente — seguir seção 4 |
| `.gitignore` criado | ✅ Arquivo incluído |
| Tag v1.0 | ⏳ Após commit inicial |
