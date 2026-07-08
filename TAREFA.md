Criar issues no GitHub - melhorias DPV.

ISSUE 1: feat: permitir correcao de despesa apos confirmacao
Apos despesa registrada, usuario nao consegue corrigir. Adicionar comando CORRIGIR ULTIMA que reabre fluxo guiado para despesa mais recente.

ISSUE 2: feat: respostas numericas no fluxo guiado
Bot oferece opcoes numeradas. Usuario responde apenas numero. Validar intervalo.
Exemplo: Quem pagou? 1.Empresa 2.Eu 3.Cliente

ISSUE 3: fix: detectar bebida alcoolica por marca comercial
Expandir palavras-chave: BRAHMA, HEINEKEN, SKOL, DEVASSA, BUDWEISER, STELLA, CORONA, AMSTEL, ITAIPAVA, ANTARCTICA, BOHEMIA.
Desconto bebida sempre entre empresa e nome do funcionario cadastrado.

ISSUE 4: feat: adicionar tipo cliente no pagador
Terceira opcao: 1.Empresa 2.Eu 3.Cliente
Salvar tipo_despesa=cliente. No relatorio separar despesas a cobrar do cliente.
Migration: ALTER TABLE despesas_viagem ADD COLUMN IF NOT EXISTS tipo_despesa VARCHAR(20) DEFAULT empresa.

ISSUE 5: feat: reabrir viagem encerrada para anexar mais NF
Adicionar comando REABRIR VIAGEM que muda status de encerrada para ativa.
Apenas a viagem mais recente do usuario pode ser reaberta.

ISSUE 6: feat: nome da viagem com formato cidade_ano
Ao iniciar viagem, sugerir formato: INICIAR cidade_ano ex: INICIAR teresina_26
Salvar nome_viagem neste formato para facilitar identificacao no relatorio e painel.

Repositorio: alexandre-madeira/dep-viagem
Criar via gh CLI ou API GitHub.

---

## FIX WF-DPV.04 - geracao e envio do PDF do relatorio (07-08/07/2026) - CONCLUIDO

RELATORIO agora funciona ponta a ponta de verdade (validado com Gotenberg saudavel + simulacao
direta sem WhatsApp, node de teste temporario removido depois). Cadeia de bugs, todos corrigidos:

1. `WF-DPV.03 - DB | Buscar Total Despesas` nao selecionava `v.phone` -> WF-DPV.04 recebia telefone
   vazio -> zero despesas encontradas.
2. `WF-DPV.04 - HTTP | Converter HTML para PDF` recebia a string do HTML sem nenhuma conversao para
   binario -> adicionado node `CONVERT | HTML para Binario` (convertToFile, toText).
3. Esse mesmo node HTTP tinha `authentication: predefinedCredentialType` com `nodeCredentialType`
   vazio (credencial fantasma nunca configurada) -> trocado para `authentication: none` (Gotenberg
   self-hosted nao exige auth).
4. Gotenberg exige que o arquivo se chame exatamente `index.html` (erro claro da propria API: "form
   file 'index.html' is required") -> corrigido o fileName no node de conversao.
5. `WF-DPV.04 - HTTP | Enviar PDF pelo WhatsApp` tinha `inputDataFieldName: ""` vazio no parametro
   multipart do PDF -> corrigido para `"data"`.
6. Descoberta mais profunda: o endpoint `/message/sendMedia` da Evolution API **nao aceita
   multipart/form-data** (retornava 500 "Unexpected field") - o DTO real (`SendMediaDto`, confirmado
   no codigo-fonte oficial) espera JSON com `media` como string base64. Trocado o node inteiro de
   multipart para `contentType: json` + node novo `EXTRACT | PDF para Base64`
   (extractFromFile, binaryToPropery) antes dele.

Resultado real: PDF de 28.2kB gerado pelo Gotenberg, enviado via WhatsApp como documentMessage,
Evolution API confirmou `status: PENDING` (aceito para entrega).

**Pendente, fora do escopo deste fix:** `WF-DPV.04 - HTTP | Notificar Gestor` (ultimo node da
cadeia, roda depois do envio do PDF) falha com 400 porque `gestorPhone` nunca foi configurado em
lugar nenhum do sistema - isso faz a execucao inteira aparecer como "error" no n8n mesmo o PDF
tendo sido entregue com sucesso antes disso. Nao mexi nisso; requer decisao de produto (quem e o
gestor, ou remover essa notificacao).
