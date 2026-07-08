BUG: erro de timezone nas validacoes de data no WF-DPV.02.

PROBLEMA: servidor em UTC, usuario em UTC-3 (America/Teresina). 
Data da nota: 2026-06-27. Hoje: 2026-07-07. Diferenca real: 10 dias.
Sistema esta calculando como mais de 90 dias - calculo errado.

CORRECAO:
1. Localizar validacao de data no WF-DPV.02
2. Usar sempre America/Sao_Paulo ou America/Teresina para calcular diferenca de dias
3. Parse da data_emissao deve considerar que e uma data local (sem timezone)
4. Comparar apenas datas (sem horas) para evitar problemas de UTC

Commitar: fix: timezone na validacao de data da NF
git push

---

## DIAGNOSTICO REAL (07/08/07/2026)

Nao era timezone. Execucao 61813 (comprovante iFood, sem ano impresso na data) mostrou o Claude
Vision inferindo `data_emissao: "2024-07-06"` (observacoes_modelo: "A data nao contem o ano, foi
inferido como 2024") quando o ano real e 2026 — diferenca de ~2 anos, nao 10 dias. A validacao de
90 dias em `CODE | Validar Combinacao` calculou certo dado o input; o input e que veio errado porque
o modelo nao sabe que ano estamos.

**Fix aplicado:** prompt do `AGENT | Extrair Dados da NF` (WF-DPV.02) agora informa a data atual real
(`$now.toFormat("dd/MM/yyyy")`) e instrui explicitamente a assumir o ano atual quando o documento nao
mostra o ano, em vez de chutar um ano passado. Publicado, nao validado ainda com o mesmo comprovante
(usuario optou por commitar direto).
