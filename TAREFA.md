FEAT-12 - Salvar imagem da NF no banco e incluir no PDF

CONTEXTO:
Colunas ja existem em despesas_viagem (migration ja aplicada pelo usuario):
- imagem_nf_base64 TEXT
- imagem_nf_mimetype VARCHAR(20)

TAREFA 1 - WF-DPV.02 (ID: 31hBkBVq6rduQKXM):
Apos HTTP | Baixar Imagem da NF que retorna base64 e mimetype,
salvar esses dados em despesas_pendentes (campo dados_extraidos JSONB)
para persistir durante o fluxo guiado.
Quando DB | Salvar Despesa Final for executado no WF-DPV.03,
incluir imagem_nf_base64 e imagem_nf_mimetype no INSERT.

TAREFA 2 - WF-DPV.03 (ID: ruf039UAwh9KqIZo):
No DB | Salvar Despesa Final adicionar os campos:
imagem_nf_base64 = dados_extraidos.imagem_base64
imagem_nf_mimetype = dados_extraidos.imagem_mimetype

TAREFA 3 - WF-DPV.04 (ID: acKIy44sUfDgOR2E):
Apos a tabela de despesas no HTML do relatorio,
adicionar secao "Comprovantes" com as imagens em ordem de ordem_nf.
Cada imagem: tag <img> com src="data:[mimetype];base64,[base64]"
Largura maxima: 400px. Legenda: "NF #[ordem_nf] - [estabelecimento] - [data_emissao]"
Apenas incluir imagens onde imagem_nf_base64 IS NOT NULL.

Commitar: feat: FEAT-12 salvar imagem NF no banco e incluir no PDF
git push
