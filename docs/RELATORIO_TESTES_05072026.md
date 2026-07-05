# Relatório de Testes — Sessão 05/07/2026

Origem: `TAREFA.md` (tarefas 1–11). Executado por Claude Code sem presença do usuário durante a maior parte da sessão; achado crítico interrompeu o plano original e foi validado com o usuário antes de prosseguir.

## Status por tarefa

| # | Tarefa | Status | Observação |
|---|---|---|---|
| 1 | Reativar WF-DPV.01 | ✅ OK | Estava `active: false` (divergente da memória, que registrava confirmação de 05/07). Reativado via `publish_workflow`; confirmado `active: true`, `versionId` inalterado (`0c6a7810-9d1c-4bad-9c4f-9b7a735c5459`) — não houve mudança de conteúdo, só reativação. |
| 2 | Verificar workflows ativos | ✅ OK | WF-DPV.01 `true` (após correção acima), WF-DPV.02 `true`, WF-DPV.03 `true`, WF-DPV.04 `true`, WF-DPV.06 `true`, WF-DPV.07 `true`. WF-DPV.05 não verificado (autorizado ficar inativo). |
| 3 | Verificar credenciais nos workflows | ⚠️ PARCIAL | A API de leitura (`get_workflow_details`) **redige o campo `credentials` de todos os nós** — não é possível confirmar por leitura qual credencial está de fato atribuída a cada nó. Confirmado apenas que as credenciais **existem** no n8n com os IDs esperados: `DB_dep_viagem` (`ggViIQGkepjwuOdv`), `HEADER_API_EVOLUTION_ENVIO` (`Ka0C8J4zfOklD1lw`), `Anthropic DPV` (`fA9wqoHasCFbjdwX`). Verificação de atribuição real por nó ficou bloqueada pelo achado abaixo (dependia de execução). |
| 4 | Testar webhook WF-DPV.01 | ❌ BLOQUEADO | Ver "Achado crítico" abaixo. |
| 5 | Testar webhook WF-DPV.06 (auth) | ❌ BLOQUEADO | Senha atual do painel obtida do nó `IF | Autenticacao Valida?` para uso futuro: `zFeh2dsmCWx27QmJ`. Teste não executado pelo mesmo bloqueio. |
| 6 | Testar painel UI | ❌ BLOQUEADO | GET a `/webhook/dpv-financeiro-ui` expirou (timeout); execução correspondente (`61366`) ficou presa em `new`. |
| 7 | Verificar banco de dados (tabelas) | ❌ BLOQUEADO | Dependia de `WF-DPV.CHK`, que não executou (ver abaixo). |
| 8 | Simular envio de NF (WF-DPV.02) | ❌ BLOQUEADO | Não disparado — mesmo bloqueio teria travado a execução. |
| 9 | Verificar erros_dpv pendentes | ❌ BLOQUEADO | Protocolo obrigatório do CLAUDE.md (checar `erros_dpv` antes de trabalhar) não pôde ser cumprido nesta sessão: a única via de acesso ao banco é via workflow n8n, e a fila está travada. **Ação necessária na próxima sessão**: rodar esta query assim que o n8n voltar a processar. |
| 10 | Exportar workflows atualizados | ✅ OK | Nenhum conteúdo de workflow mudou (só o flag `active` de WF-DPV.01, que já retornou ao mesmo `versionId` presente em `workflows/`). Nada para reexportar. |
| 11 | Commitar e push | ✅ OK | Ver commit desta sessão. `scripts/atualizar_senha_painel.ps1` tinha a senha real do painel hardcoded (não seria seguro commitar) — placeholder restaurado antes do commit. |

## Achado crítico: fila de execução do n8n travada

Toda tentativa de executar um workflow nesta sessão (webhook ou manual) ficou presa em status `new`, com `startedAt: null`, e nunca progrediu — não é 404, não é erro, é fila parada. Confirmado via `search_executions`:

- Execuções minhas desta sessão (`61364`, `61365`, `61366`) presas em `new`.
- O problema **não é desta sessão**: execuções do workflow `WF-ADMIN` (`OUbFTiwtY485IHxt`) já apareciam presas em `new` e foram canceladas manualmente em `2026-07-04T01:17`, `2026-07-05T14:24`, `14:53` e `15:51` — ou seja, o sintoma já vinha ocorrendo pelo menos desde 04/07.
- A base do n8n responde normalmente (`GET https://n8n.solucaomadeira.com/` → 200 em 657ms), então não é problema de rede/DNS — aponta para o **worker/processo de fila do n8n** parado ou travado, não a aplicação web em si.

Isso bloqueou as tarefas 4, 5, 6, 7, 8 e 9 do `TAREFA.md`, todas dependentes de disparar execuções. Apresentei o achado ao usuário durante a sessão; a decisão foi **não tentar corrigir a infraestrutura agora** (sem acesso SSH/EasyPanel) e seguir apenas com o que não depende de execução.

## Pendências para a próxima sessão

1. **Reiniciar o worker/processo de fila do n8n** (EasyPanel ou onde estiver hospedado) — bloqueante para tudo que envolve rodar workflows.
2. Após o reinício, repetir as tarefas 4–9 do `TAREFA.md`:
   - Testar webhook `dpv-whatsapp-receiver` (texto AJUDA).
   - Testar auth do painel (`dpv-financeiro`, senha atual: `zFeh2dsmCWx27QmJ`).
   - Testar `GET /webhook/dpv-financeiro-ui`.
   - Rodar `WF-DPV.CHK` para conferir tabelas do banco e erros pendentes.
   - Simular envio de NF via WF-DPV.02.
3. Cumprir o protocolo de início de sessão do `CLAUDE.md` (query em `erros_dpv`) assim que o banco ficar acessível via workflow.
4. Confirmar atribuição de credenciais por nó — não verificável por leitura de API (campo redigido); só será possível validar de fato via execução bem-sucedida dos workflows.

## Recomendação

Não confiar em "workflow marcado como ativo" como sinal de saúde do sistema — o mesmo vale para "execução iniciada sem 404". Confirmar sempre que a execução **progride** (`status` sai de `new`), já que a fila pode aceitar o disparo e nunca processá-lo.
