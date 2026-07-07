Analisar execucoes do WF-DPV.01 e WF-DPV.02 entre 00:25:28 e 12:37:17 UTC de hoje 07/07/2026.

PROBLEMA: diversas fotos de NF foram enviadas pelo WhatsApp mas nenhuma foi salva em despesas_viagem.

TAREFA:
1. Buscar todas as execucoes do WF-DPV.01 (z0F4H4NUyLErFjZ7) neste periodo
2. Para cada execucao com imageMessage: verificar qual foi o lastNodeExecuted e se houve erro
3. Buscar execucoes do WF-DPV.02 (31hBkBVq6rduQKXM) no mesmo periodo
4. Identificar onde o fluxo esta parando
5. Reportar o erro exato de cada falha

Nao corrigir ainda - apenas diagnosticar e reportar.

---

## DIAGNOSTICO (concluido 07/07/2026)

Janela analisada: 00:25:28-12:37:17 UTC.
WF-DPV.01: 99 execucoes, todas entre 00:33 e 05:31 UTC (nada depois disso na janela).
WF-DPV.02: 14 execucoes no periodo, 100% com erro.

### Causa raiz
No no `WF-DPV.01 - SET | Normalizar Payload`:
```
imageBase64 = {{ $json.body.data.message?.imageMessage?.jpegThumbnail ?? '' }}
```
`jpegThumbnail` chega da Evolution API como objeto de bytes (`{"0":255,"1":216,...}`), nao como string base64.
Como o campo do Set e tipado `string`, o n8n serializa o objeto inteiro (JSON.stringify) em vez de
converter para base64 valido. Esse "base64" corrompido e enviado ao modelo de IA no WF-DPV.02, que nao
consegue interpretar a imagem e retorna algo fora do schema esperado.

### Onde o fluxo trava
`WF-DPV.01 - EXEC | Chamar Extrator IA` -> `WF-DPV.02 - PARSER | Estruturar Dados NF`
(`@n8n/n8n-nodes-langchain.outputParserStructured`) falha em 100% dos casos com:
```
NodeOperationError: Model output doesn't fit required format
outputParserFailReason: "Invalid JSON in model output"
```
A execucao aborta antes de qualquer INSERT em `despesas_viagem`.

### Problema adicional
Mesmo corrigindo a conversao, `jpegThumbnail` e so a miniatura de baixa resolucao, nao a foto completa.
A correcao real precisa buscar a imagem completa via `imageUrl` (endpoint de midia da Evolution API).

### Achado secundario (fora do escopo de fotos)
Execucao 61503 (fluxo de cadastro, nao imagem) falhou no no `WF-DPV.07 - HTTP | Pedir CPF` com
`Credentials not found` (httpHeaderAuth sem credencial configurada).

---

## LISTA DE CORRECOES (pendente - nao aplicado ainda)

1. **WF-DPV.01 - SET | Normalizar Payload**: trocar leitura de `imageMessage.jpegThumbnail` por
   download da imagem completa via `imageUrl` na Evolution API, convertendo corretamente para base64.
2. **WF-DPV.02**: validar que o base64 recebido e uma imagem valida antes de chamar o modelo de IA
   (fail-fast com mensagem clara em vez de erro generico do parser).
3. **WF-DPV.07 - HTTP | Pedir CPF**: configurar credencial httpHeaderAuth ausente (erro
   "Credentials not found" na execucao 61503).
