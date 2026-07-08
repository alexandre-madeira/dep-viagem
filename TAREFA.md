Corrigir WF-DPV.03 - dois bugs do RELATORIO.

BUG 1 - Comando case insensitive e sem acento:
Corrigir reconhecimento de todos os comandos usando .toLowerCase().normalize():
- RELATORIO: aceitar relatorio, relatório, RELATÓRIO, Relatorio
- ENCERRAR VIAGEM: aceitar encerrar viagem, encerra viagem, encerra viajem
- INICIAR: aceitar iniciar, Iniciar, INICIAR

BUG 2 - Query do relatorio filtra status ativa mas viagem ja foi encerrada:
O bot diz "Envie RELATORIO" apos encerrar mas a query busca WHERE status = 'ativa'.
CORRECAO: mudar query para buscar WHERE status IN ('ativa', 'encerrada') ou remover filtro de status.

Commitar: fix: RELATORIO aceita acento e busca viagem encerrada
git push

---

## VALIDADO (07/07/2026, execucoes 61853/61854/61855)

Ambos os bugs confirmados corrigidos com teste real:
- `RELATORIO` (sem acento) roteou certo para a branch de relatorio (antes caia no fallback Ajuda
  quando vinha acentuado, ex: "Relatório").
- A query em `WF-DPV.03 - DB | Buscar Total Despesas` achou a viagem 242 mesmo com
  `status = 'encerrada'` (antes so achava com `status = 'ativa'`, retornando vazio logo apos
  ENCERRAR VIAGEM — exatamente o fluxo que o proprio bot recomenda).
- PDF nao foi gerado nessa execucao especifica porque a viagem 242 (teste de INICIAR/ENCERRAR) durou
  92 segundos e nao tem nenhuma despesa dentro da janela — nao e bug, e falta de dado de teste.
  `WF-DPV.03 - SWITCH | Tipo de Comando` normalizado para `ENCERR` (em vez de `ENCERRAR`) tambem
  aceita "encerra viagem"/"encerra viajem".
