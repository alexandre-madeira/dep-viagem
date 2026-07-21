DIAGNOSTICO Evolution API - imagem nao dispara webhook

PROBLEMA CONFIRMADO: n8n processa imagens corretamente (teste sintetico OK).
A Evolution API nao esta entregando eventos de imageMessage ao webhook DPV.
Nao temos acesso aos logs do container Docker.

TENTAR via API REST da Evolution API:

1. GET https://evolution.solucaomadeira.com/instance/fetchInstances
   Credencial: HEADER_API_EVOLUTION_ENVIO (ID: Ka0C8J4zfOklD1lw)
   Ver detalhes da instancia DPV - versao, configuracoes

2. GET https://evolution.solucaomadeira.com/chat/findMessages/DPV
   Body: {"where": {"key": {"fromMe": false}}, "limit": 5}
   Ver se as mensagens de imagem estao sendo recebidas pela instancia

3. POST https://evolution.solucaomadeira.com/webhook/set/DPV
   Tentar reconfigurar o webhook completamente com:
   {
     "url": "https://n8n.solucaomadeira.com/webhook/dpv-whatsapp-receiver",
     "enabled": true,
     "webhookByEvents": false,
     "webhookBase64": false,
     "events": ["MESSAGES_UPSERT", "CONNECTION_UPDATE"]
   }
   Mudar webhookByEvents para false pode ser a chave -
   quando true, a Evolution API pode estar filtrando tipos de mensagem por evento
   e imageMessage pode estar caindo em bucket diferente de MESSAGES_UPSERT.

4. Apos reconfigurar, pedir ao usuario para enviar imagem de teste.

Reportar resultado de cada passo.
