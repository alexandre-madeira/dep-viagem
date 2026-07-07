Corrigir WF-DPV.07 (ID: 6SwQvQ5IVL8oVtUk) - bugs no fluxo de cadastro.

CONTEXTO: execucao real 06/07/2026 entre 15:17:08 e 15:17:45.
Registro no banco: phone=554896289237, step=aguardando_confirmacao, nome_temp=Alexandre., email_temp=alexandremade@gmail.com, codigo=933071, tentativas=1.

BUG 1: mensagem exibe "undefined" no lugar do nome.
O nome foi salvo como nome_temp=Alexandre. no banco mas o no que envia a mensagem de confirmacao do email nao esta lendo nome_temp corretamente. Verificar de onde o no le o nome e corrigir a referencia.

BUG 2: exibe "NaN tentativas restantes" ao validar codigo.
O no que calcula tentativas restantes nao esta lendo o campo tentativas do banco corretamente. Verificar a expressao que calcula tentativas restantes e corrigir.

Buscar execucoes do WF-DPV.07 entre 15:17:00 e 15:18:00 UTC de hoje para ver os erros exatos.
Corrigir ambos os bugs.
Commitar: fix: WF-DPV.07 corrigir nome undefined e NaN tentativas
git push
