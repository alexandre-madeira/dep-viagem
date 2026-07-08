REFATORACAO COMPLETA DO FLUXO DE DESPESAS - DPV

TAREFA 1 - Remover CPF/CNPJ do pagador (simplificacao):
- Remover cpf_cnpj_pagador de CODE | Validar Combinacao no WF-DPV.02
- Campos obrigatorios: apenas tipo_pagador e forma_pagamento
- Campos opcionais: tudo mais

TAREFA 2 - Fluxo guiado passo a passo apos foto NF:
Quando NF processada, bot faz 3 perguntas:
1. "Quem pagou? Responda EMPRESA ou EU"
2. "Como pagou? Responda CARTAO ou DINHEIRO"
3. "Observacao? Responda: DIVIDIR / DESCONTO BEBIDA / NAO"

TAREFA 3 - Guardar extracao completa em itens_json:
Salvar em despesas_viagem.itens_json todo o JSON extraido pelo Claude Vision:
estabelecimento, cnpj, valor_total, data_emissao, categoria, forma_pagamento,
itens (array completo com descricao/quantidade/valor_unitario/valor_total),
confianca, observacoes_modelo

TAREFA 4 - Divisao de conta:
Quando usuario responde DIVIDIR:
- Adicionar colunas em despesas_viagem: valor_empresa NUMERIC, valor_funcionario NUMERIC
- Bot pergunta: "Informe divisao. Ex: EMPRESA 80% EU 20% ou EMPRESA 80 EU 30"
- Sistema calcula e salva os dois valores

TAREFA 5 - Desconto bebida alcoolica:
Quando usuario responde DESCONTO BEBIDA:
- Claude Vision ja extraiu os itens
- Identificar automaticamente por palavra-chave: CERVEJA, VINHO, WHISKY, CACHAÇA, DOSE, DRINK, BEER, ALCOOL
- Calcular soma dos itens alcoolicos
- Salvar em valor_funcionario (desconta da empresa)
- Salvar em itens_json campo alcoolicos_detectados com lista e valor

MIGRATIONS NECESSARIAS:
ALTER TABLE despesas_viagem ADD COLUMN IF NOT EXISTS valor_empresa NUMERIC;
ALTER TABLE despesas_viagem ADD COLUMN IF NOT EXISTS valor_funcionario NUMERIC;

Executar migrations, implementar fluxo, commitar tudo:
"feat: fluxo guiado despesa + divisao conta + desconto bebida + itens_json"
git push

---

## IMPLEMENTADO (07-08/07/2026)

Migration `v9_divisao_conta_fluxo_guiado.sql` aplicada (valor_empresa/valor_funcionario em
despesas_viagem + tabela `despesas_pendentes` para staging do fluxo guiado, mesmo padrao de
`cadastros_pendentes`).

**WF-DPV.02** (31hBkBVq6rduQKXM): `CODE | Validar Combinacao` simplificado — so valida valor>0 e
data razoavel; tipo_pagador/forma_pagamento/cpf_cnpj_pagador saem inteiramente do OCR e passam a
vir so do fluxo guiado. Prompt do Claude Vision ganhou `observacoes_modelo`. Em vez de INSERT direto
em `despesas_viagem`, agora faz UPSERT em `despesas_pendentes` (step=aguardando_pagador) e dispara a
1a pergunta ("Quem pagou?").

**WF-DPV.03** (ruf039UAwh9KqIZo): novo gate no inicio (`DB | Buscar Despesa Pendente` -> `IF | Tem
Despesa Pendente`) intercepta respostas de texto quando ha um fluxo guiado em andamento, antes do
SWITCH de comandos (INICIAR/ENCERRAR/RELATORIO/DESPESA) original — que continua intacto para quando
nao ha pendencia. Toda a maquina de estados (aguardando_pagador -> aguardando_forma ->
aguardando_observacao -> [aguardando_divisao | finalize]) esta em `CODE | Processar Fluxo Guiado`,
incluindo deteccao de itens alcoolicos por palavra-chave e calculo de divisao percentual. Ao
finalizar, INSERT em despesas_viagem (com itens_json = JSON completo da extracao) + DELETE em
despesas_pendentes.

**Validado com foto real** (execucoes 61801/61804/61807/61810): fluxo completo ate DESCONTO BEBIDA —
identificou `CERVEJA IMPERIO PURO MALT` (R$ 11,85) automaticamente, calculou valor_empresa R$ 42,32 /
valor_funcionario R$ 11,85 (soma bate com valor_total 54,17), salvou despesa id 23, confirmou via
WhatsApp real. TAREFA 4 (DIVIDIR) implementada mas nao exercitada em teste real ainda — mesma logica
(`finalize()`) do caminho ja validado, risco residual aceito pelo usuario.
