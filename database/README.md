# Database — dep-viagem [DPV]

## Estrutura

```
database/
├── setup.sql              ← executa tudo do zero (v1 + v2)
├── seeds.sql              ← dados de teste (não usar em produção)
└── migrations/
    ├── v1_criacao_inicial.sql   ← tabelas funcionarios, viagens, despesas_viagem
    └── v2_nome_viagem.sql       ← adiciona nome_viagem e índice
```

## Como usar

### Instalação do zero
```sql
-- Execute no seu cliente PostgreSQL (DBeaver, psql, TablePlus):
\i setup.sql
```

### Atualização (já tem v1 instalada)
```sql
\i migrations/v2_nome_viagem.sql
```

### Carregar dados de teste
```sql
\i seeds.sql
-- ⚠️ Apenas em ambiente de desenvolvimento
```

### Via psql na linha de comando
```bash
psql -h localhost -U postgres -d seu_banco -f setup.sql
psql -h localhost -U postgres -d seu_banco -f seeds.sql
```

## Tabelas

| Tabela | Descrição |
|---|---|
| `funcionarios` | Cadastro de funcionários (phone → nome) |
| `viagens` | Registro de viagens com data início/fim e status |
| `despesas_viagem` | Notas fiscais vinculadas a um phone/viagem |

## Quando commitar

Sempre que criar ou alterar tabelas:
```bash
git add database/
git commit -m "db: descrição da alteração"
git push
```
