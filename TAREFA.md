BUG + MELHORIA - Step aguardando_divisao no WF-DPV.03 (ID: ruf039UAwh9KqIZo)

PROBLEMA 1: parser nao reconhece variacoes:
- "A) 216" (parentese apos letra)
- "EMPRESA 123,80 FUNCIONÁRIO 0" (acento em FUNCIONÁRIO)
- Quando falta VOCE/EU nao explica o que falta

PROBLEMA 2: sem resposta apos timeout de mensagens em loop

SOLUCAO: substituir step aguardando_divisao por 3 steps sequenciais:
- aguardando_divisao_empresa: "Quanto a EMPRESA paga? (ex: 123.80 ou 0)"
- aguardando_divisao_voce: "Quanto VOCE paga? (ex: 50.00 ou 0)"
- aguardando_divisao_cliente: "Quanto o CLIENTE paga? (ex: 0)"

Em cada step aceitar apenas um numero (com ponto ou virgula).
Salvar parcialmente em despesas_pendentes a cada resposta.
No ultimo step calcular e finalizar.
Validar que soma nao ultrapassa o total.

Commitar: fix: divisao conta em steps sequenciais evita parser ambiguo
git push
