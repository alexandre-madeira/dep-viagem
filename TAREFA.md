PRIORIDADE 1 - [CONCLUIDO 15/07/2026] Corrigir WF-ERR-CTX (ID: 6LU8TtukzsbgGCHe)
Node HTTP | Enviar WhatsApp retorna 404 - instancia Evolution errada ou hardcoded.
Corrigir para usar instancia VIDROCOM_AG e credencial HEADER_API_EVOLUTION_ENVIO (ID: Ka0C8J4zfOklD1lw).
Sem isso erros_dpv nunca e populado e o protocolo de inicio de sessao e cego.

Causa raiz: node fica em WF-NOTIFY - Envio e Log (ID: QCek7t0vpz6yfTpR), chamado como
subworkflow pelo WF-ERR-CTX. Node "WF-NOTIFY.04 - HTTP | Enviar WhatsApp" tinha URL
hardcoded .../sendText/sofia sem credencial explicita. Corrigido via n8n MCP: URL trocada
para .../sendText/VIDROCOM_AG e credencial HEADER_API_EVOLUTION_ENVIO (Ka0C8J4zfOklD1lw)
atribuida. Publicado (activeVersionId bc379358-f9ac-4179-8d60-28485b637ea7).
Workflows n8n_contratos (WF-ERR-CTX/WF-NOTIFY) nao tem export local em workflows/,
fix aplicado apenas via MCP, sem arquivo a versionar alem deste registro.

PRIORIDADE 2 - Teste end-to-end completo:
1. INICIAR viagem
2. Enviar foto NF
3. Responder 1 (empresa), 1 (cartao), 1 (dividir)
4. Responder valores: empresa X, voce Y, cliente 0
5. RELATORIO - verificar PDF com coluna NF e valores corretos

Commitar fixes e push.
