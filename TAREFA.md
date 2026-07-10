TAREFAS DPV - ISSUES E MELHORIAS

PARTE 1 - Criar 8 issues no GitHub via gh CLI (repositorio: alexandre-madeira/dep-viagem)

ISSUE 1: feat: permitir correcao de despesa apos confirmacao
Apos despesa registrada usuario nao consegue corrigir. Adicionar comando CORRIGIR ULTIMA que reabre fluxo guiado para despesa mais recente.

ISSUE 2: feat: respostas numericas no fluxo guiado
Bot oferece opcoes numeradas. Usuario responde apenas numero. Validar intervalo 1-3. Exemplo: Quem pagou? 1.Empresa 2.Eu 3.Cliente

ISSUE 3: fix: detectar bebida alcoolica por marca comercial
Expandir palavras-chave: BRAHMA, HEINEKEN, SKOL, DEVASSA, BUDWEISER, STELLA, CORONA, AMSTEL, ITAIPAVA, ANTARCTICA, BOHEMIA. Desconto sempre entre empresa e nome do funcionario cadastrado.

ISSUE 4: feat: adicionar tipo cliente no pagador
Terceira opcao no fluxo: 1.Empresa 2.Eu 3.Cliente. Salvar tipo_despesa=cliente. No relatorio separar despesas a cobrar do cliente. Migration: ALTER TABLE despesas_viagem ADD COLUMN IF NOT EXISTS tipo_despesa VARCHAR(20) DEFAULT empresa.

ISSUE 5: feat: reabrir viagem encerrada para anexar mais NF
Adicionar comando REABRIR VIAGEM que muda status de encerrada para ativa. Apenas viagem mais recente pode ser reaberta.

ISSUE 6: feat: nome da viagem com formato cidade_ano
Sugerir formato INICIAR cidade_ano ex: INICIAR teresina_26. Salvar nome_viagem neste formato.

ISSUE 7: feat: datas reais da viagem baseadas nas notas fiscais
data_inicio = data_emissao da primeira NF, data_fim = data_emissao da ultima NF. Exibir no relatorio e painel.

ISSUE 8: feat: melhorar layout do relatorio PDF
Cabecalho: nome funcionario, periodo (data primeira NF - data ultima NF), total geral.
Tabela: Data | Estabelecimento | Categoria | Quem Pagou | Como Pagou | Desconto/Divisao | Empresa | Funcionario | Cliente
Rodape: totais por coluna. Secao separada para despesas a cobrar do cliente.

PARTE 2 - Configurar telefone do gestor no WF-DPV.04
O node Notificar Gestor falha porque nenhum telefone de gestor foi configurado.
Perguntar ao usuario qual telefone usar antes de configurar.

PARTE 3 - Commitar TAREFA.md e git push apos criar todas as issues.

---

## CONCLUIDO (08/07/2026)

PARTE 1 - 8 issues criadas em alexandre-madeira/dep-viagem:
- #2 feat: permitir correcao de despesa apos confirmacao
- #3 feat: respostas numericas no fluxo guiado
- #4 fix: detectar bebida alcoolica por marca comercial
- #5 feat: adicionar tipo cliente no pagador
- #6 feat: reabrir viagem encerrada para anexar mais NF
- #7 feat: nome da viagem com formato cidade_ano
- #8 feat: datas reais da viagem baseadas nas notas fiscais
- #9 feat: melhorar layout do relatorio PDF

PARTE 2 - `WF-DPV.04 - HTTP | Notificar Gestor`: telefone do gestor configurado como
`554896289237` (mesmo numero de teste, confirmado pelo usuario). Publicado.

---

## CONCLUIDO (09/07/2026) - implementacao das 8 issues

Todas as issues #2-#9 implementadas, testadas via test_workflow e fechadas no GitHub:

- #2 CORRIGIR ULTIMA: reabre fluxo guiado para a despesa mais recente, substitui o
  registro antigo ao finalizar (WF-DPV.03). Commit 4815566.
- #3 respostas numericas: fluxo guiado aceita 1/2/3 alem do texto (WF-DPV.03). Commit 1e19ce6.
- #4 marcas de bebida: lista expandida com marcas comerciais (WF-DPV.03). Commit 1e19ce6.
- #5 tipo cliente: 3a opcao no pagador, coluna tipo_despesa (migration v10), pula
  divisao e finaliza direto (WF-DPV.03). Commit 1e19ce6.
- #6 REABRIR VIAGEM: reabre apenas a viagem mais recente se encerrada (WF-DPV.03).
  Commit 4b596d4.
- #7 nome_viagem cidade_ano: normalizado automaticamente (sem acento, underscore,
  sufixo _ano) (WF-DPV.03). Commit 5a959ea.
- #8 datas reais da NF: periodo do relatorio/painel calculado por MIN/MAX(data_emissao)
  em vez de viagens.data_inicio/data_fim (WF-DPV.04, WF-DPV.06). Commit 071b018.
- #9 layout do relatorio: cabecalho com nome do funcionario, tabela com split
  Empresa/Funcionario/Cliente, secao separada de despesas a cobrar do cliente
  (WF-DPV.04). Commit 0bdfee2.

Todos os workflows re-exportados para `workflows/` apos cada mudanca.
