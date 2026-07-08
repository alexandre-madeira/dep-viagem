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

## FIX WF-DPV.04 - geracao de PDF do relatorio (07-08/07/2026)

Cadeia de 3 bugs achados ao depurar RELATORIO nao enviando PDF:

1. `WF-DPV.03 - DB | Buscar Total Despesas` nao selecionava `v.phone` — o item passado para
   `WF-DPV.04` via Execute Workflow ficava sem telefone, fazendo a query de despesas do WF-DPV.04
   rodar com `WHERE d.phone = ''` (zero resultados). Corrigido junto com o fix de RELATORIO
   aceitar viagem encerrada (commit anterior).
2. `WF-DPV.04 - HTTP | Converter HTML para PDF` esperava um arquivo binario (`formBinaryData`)
   mas recebia direto a string do HTML gerado, sem nenhuma conversao — faltava o node
   `WF-DPV.04 - CONVERT | HTML para Binario` (novo, `convertToFile` operation `toText`) entre a
   geracao do HTML e essa chamada, alem do campo `inputDataFieldName` que nunca tinha sido
   configurado no parametro multipart `files`.
3. Gotenberg (`http://gotenberg:3000`) inacessivel — confirmado resolvido pelo usuario (healthcheck
   ok de dentro do container do n8n).

Fixes 1 e 2 aplicados e publicados em WF-DPV.03/WF-DPV.04. Validado via simulacao direta (node de
teste temporario no lugar do trigger real, sem precisar de mensagem WhatsApp) — ver commit para
detalhes do resultado.
