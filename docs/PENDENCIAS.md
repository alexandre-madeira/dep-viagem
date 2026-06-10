# Pendências — dep-viagem [DPV]
Atualizado em: 09/06/2026

---

## 🔴 Críticas (sem isso o sistema não funciona)

### P02 — API Key da Evolution API
- **Onde:** WF-DPV.02, 03, 04, 06 — todos os nós `HTTP | Enviar *`
- **O que:** Header `apikey` com a chave da sua instância Evolution
- **Como:** No n8n, abra cada nó HTTP → aba Headers → campo `apikey`

### P03 — Credencial Anthropic (Claude Vision)
- **Onde:** WF-DPV.02 → nó `LLM | Claude Vision`
- **O que:** Criar credencial `anthropicApi` no n8n
- **Como:** n8n → Credentials → New → Anthropic → cole sua API Key

### P04 — Serviço Gotenberg no Docker
- **Onde:** WF-DPV.04 → nó `HTTP | Converter HTML para PDF`
- **O que:** Container `gotenberg` rodando em `http://gotenberg:3000`
- **Docker Compose a adicionar:**
  ```yaml
  gotenberg:
    image: gotenberg/gotenberg:8
    restart: unless-stopped
  ```

---

## 🟡 Pendências Técnicas

### P06 — Trocar senha do painel financeiro
- **Onde:** WF-DPV.06 → nó `IF | Autenticacao Valida?`
- **Senha padrão atual:** `financeiro123`
- **Como:** Abra o nó e altere o valor `rightValue` para sua senha

### P07 — Atualizar URL do painel no arquivo JSX
- **Onde:** `painel/painel-financeiro-dpv.jsx` → linha `const API_BASE`
- **Valor atual:** `https://n8n.solucaomadeira.com/webhook/dpv-financeiro`
- **Ação:** Confirmar se a URL está correta para seu ambiente

### P08 — ZIP de NFs com imagens reais
- **Onde:** WF-DPV.06 → nó `CODE | Instruções ZIP`
- **O que:** Hoje retorna metadados. Implementar download real via Evolution API + compressão ZIP via Gotenberg
- **Complexidade:** Média — requer acesso à API de mídia da Evolution

---

## ✅ Concluído

- [x] 6 workflows criados no n8n
- [x] Tabelas `viagens`, `despesas_viagem`, `funcionarios` criadas
- [x] Campo `nome_viagem` adicionado à tabela `viagens`
- [x] Credencial `DB_n8n_contratos` aplicada em todos os workflows
- [x] Subworkflows vinculados (WF-01 → 02, 03; WF-03 → 04; WF-06 → 04)
- [x] `imageUrl` e `imageBase64` mapeados no payload Evolution
- [x] Validação de NF duplicada por `message_id`
- [x] Notificação ao gestor quando PDF gerado
- [x] Painel financeiro React com login, filtros, PDF, ZIP e aprovação
- [x] Backend WF-DPV.06 com autenticação e 5 rotas
- [x] Repositório Git estruturado com processo documentado
