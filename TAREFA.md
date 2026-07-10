MELHORIAS DE UX - DPV (09/07/2026)

M1 - Saudacao inicial personalizada (WF-DPV.03):
Quando usuario manda "ola", "oi", "bom dia", "boa tarde", "boa noite" ou similar,
responder com: "Ola, [NOME]! Como posso ajudar?"
Seguido do menu numerado (ver M7).

M2 - Nome da viagem formato cidade_obra, ano automatico (WF-DPV.03):
- Remover instrucao de digitar o ano - sistema adiciona automaticamente
- Dica no menu: "Use INICIAR cidade_obra (ex: INICIAR teresina_pele)"
- Bug atual: "INICIAR Teresina - jun26" vira "teresina_jun26_26" (ano duplicado)
- Correcao: extrair apenas o nome apos INICIAR, normalizar (lowercase, espacos->_,
  remover caracteres especiais exceto _), adicionar _26 no final
- Resultado esperado: "INICIAR Teresina-pele" -> "teresina_pele_26"

M3 - CORRIGIR ULTIMA aceitar variacoes (WF-DPV.03):
Aceitar: "Corregir", "Corrige", "CORRIGIR ULTIMA", "CORRIGIR ULTMA",
"corrigir ultima", "CORRIGIR ÚLTIMA" e outras variacoes com acento/erro.

M4 - Divisao por valor em Reais, nao percentual (WF-DPV.03):
- Perguntar separadamente: "Empresa RTrue / Voce RTrue / Cliente RTrue"
- Aceitar formato: "142,27" ou "142.27" (virgula ou ponto)
- Validar que soma nao ultrapassa valor total da despesa
- Remover suporte a percentual (% causa confusao)

M5 - Quando pagador e Cliente, mostrar apenas "Cliente: R$ X,XX" (WF-DPV.03):
- Remover mencao de "acertar com o cliente" da mensagem de confirmacao
- Mostrar apenas: "Cliente: R$ X,XX"

M6 - Rodape apos confirmacao de despesa (WF-DPV.03):
Adicionar ao final de toda mensagem de confirmacao de despesa:

"Para continuar envie nova foto ou:
1) CORRIGIR ULTIMA
2) ENCERRAR VIAGEM"

M7 - Menu de ajuda numerado com acentos corrigidos (WF-DPV.03):
Substituir menu atual por:

"Comandos disponiveis:
1) Iniciar viagem (INICIAR cidade_obra)
2) Encerrar viagem
3) Reabrir viagem (reabre a mais recente)
4) Corrigir ultima despesa
5) Gerar relatorio PDF

Ou envie uma foto de nota fiscal para registrar despesa."

OBS: os comandos continuam sendo acionados por texto (nao por numero),
apenas o VISUAL do menu e numerado para referencia do usuario.

Implementar todas as melhorias no WF-DPV.03 (ID: ruf039UAwh9KqIZo).
Commitar: feat: melhorias UX mensagens e menu DPV
git push
