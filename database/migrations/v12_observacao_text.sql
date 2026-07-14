-- Migration v12: alargar despesas_viagem.observacao de VARCHAR(30) para TEXT
-- Aplicada em: 15/07/2026

-- BUG: a coluna foi criada como VARCHAR(30) na migration v11, mas o formato de
-- observacao usado pela divisao a/b/c ("DIVIDIR3 a:R$X.XX/b:R$Y.YY/c:R$Z.ZZ") facilmente
-- ultrapassa 30 caracteres (ex: "DIVIDIR3 a:R$102.80/b:R$36.00/c:R$0.00" = 38 chars),
-- causando "value too long for type character varying(30)" no INSERT de
-- WF-DPV.03 - DB | Salvar Despesa Final e travando o fluxo guiado sem resposta ao usuario.
ALTER TABLE despesas_viagem ALTER COLUMN observacao TYPE TEXT;
