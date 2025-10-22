WITH tb_transacao AS (

    SELECT 
        *,
        SUBSTR(DtCriacao, 0, 11) AS dtDia,
        CAST( SUBSTR(DtCriacao, 12 ,2) AS INT) AS dtHora
    FROM transacoes
    WHERE DtCriacao < '2025-10-01'
),
tb_agg_transacao AS (

    SELECT 
        IdCliente,
        MAX(JULIANDAY(date('2025-10-01', '-1 day')) - JULIANDAY(DtCriacao)) AS idadeDias,
        -- Frequencia em dias (D7, D14, D28, D56, vida)
        COUNT(DISTINCT dtDia) AS qtdeAtivacaoVida,
        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-7 day') THEN dtDia END) AS qtdeAtivacaoD7,
        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-14 day') THEN dtDia END) AS qtdeAtivacaoD14,
        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-28 day') THEN dtDia END) AS qtdeAtivacaoD28,
        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-56 day') THEN dtDia END) AS qtdeAtivacaoD56,
        -- Frequencia em dias (D7, D14, D28, D56, vida)
        COUNT(DISTINCT dtDia) AS qtdeTransacaoVida,
        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-7 day') THEN IdTransacao END) AS qtdeTransacaoD7,
        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-14 day') THEN IdTransacao END) AS qtdeTransacaoD14,
        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-28 day') THEN IdTransacao END) AS qtdeTransacaoD28,
        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-56 day') THEN IdTransacao END) AS qtdeTransacaoD56,
        -- Valor de pontos (positivo, negativo, saldo) - (D7, D14, D28, D56, vida)
        SUM(qtdePontos) AS saldoVida,
        SUM(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-7 day') THEN qtdePontos else 0 END) AS saldoD7,
        SUM(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-14 day') THEN qtdePontos else 0 END) AS saldoD14,
        SUM(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-28 day') THEN qtdePontos else 0 END) AS saldoD28,
        SUM(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-56 day') THEN qtdePontos else 0 END) AS saldoD56,

        SUM(CASE WHEN qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosVida,
        SUM(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-7 day') AND qtdePontos > 0 THEN qtdePontos else 0 END) AS qtdePontosPosD7,
        SUM(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-14 day') AND qtdePontos > 0 THEN qtdePontos else 0 END) AS qtdePontosPosD14,
        SUM(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-28 day') AND qtdePontos > 0 THEN qtdePontos else 0 END) AS qtdePontosPosD28,
        SUM(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-56 day') AND qtdePontos > 0 THEN qtdePontos else 0 END) AS qtdePontosPosD56,

        SUM(CASE WHEN qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegVida,
        SUM(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-7 day') AND qtdePontos < 0 THEN qtdePontos else 0 END) AS qtdePontosNegD7,
        SUM(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-14 day') AND qtdePontos < 0 THEN qtdePontos else 0 END) AS qtdePontosNegD14,
        SUM(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-28 day') AND qtdePontos < 0 THEN qtdePontos else 0 END) AS qtdePontosNegD28,
        SUM(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-56 day') AND qtdePontos < 0 THEN qtdePontos else 0 END) AS qtdePontosNegD56,
        --  Período que assiste live (share de período)
            -- valor absoluto
        COUNT(CASE WHEN dtHora BETWEEN 10 AND 14 THEN IdTransacao END) AS qtdeTransacaoManha,
        COUNT(CASE WHEN dtHora BETWEEN 15 AND 21 THEN IdTransacao END) AS qtdeTransacaoTarde,
        COUNT(CASE WHEN dtHora > 21 OR dtHora < 7 THEN IdTransacao END) AS qtdeTransacaoNoite,
            -- valor relativo em relação ele mesmo (padronização)
        1.* COUNT(CASE WHEN dtHora BETWEEN 10 AND 14 THEN IdTransacao END) / COUNT(IdTransacao) AS pctTransacaoManha,
        1.* COUNT(CASE WHEN dtHora BETWEEN 15 AND 21 THEN IdTransacao END) / COUNT(IdTransacao) AS pctTransacaoTarde,
        1.* COUNT(CASE WHEN dtHora > 21 OR dtHora < 7 THEN IdTransacao END) / COUNT(IdTransacao) AS pctTransacaoNoite
    FROM tb_transacao
    GROUP BY IdCliente
),

tb_agg_calc AS (

    SELECT 
        *,
        -- Quantidade de transacaoes por dia (D7, D14, D28, D56)
        COALESCE(1. * qtdeTransacaoVida / qtdeAtivacaoVida, 0) AS QtdeTransacaoVida,  
        COALESCE(1. * qtdeTransacaoD7 / qtdeAtivacaoD7, 0) AS QtdeTransacaoD7, 
        COALESCE(1. * qtdeTransacaoD14 / qtdeAtivacaoD14, 0) AS QtdeTransacaoD14, 
        COALESCE(1. * qtdeTransacaoD28 / qtdeAtivacaoD28, 0) AS QtdeTransacaoD28, 
        COALESCE(1. * qtdeTransacaoD56 / qtdeAtivacaoD56, 0) AS QtdeTransacaoD56,
    -- Percentual de ativacao no MAU
        COALESCE(1. * qtdeAtivacaoD28 / 28, 0) AS pctAtivacaoMau

    FROM tb_agg_transacao
),

tb_horas_dia AS (

    SELECT 
        IdCliente,
        dtDia,
        24 * (MAX(JULIANDAY(DtCriacao)) - MIN(JULIANDAY(DtCriacao))) AS duracao
        
    FROM tb_transacao
    GROUP BY idCliente, dtDia
),

tb_hora_cliente AS (
    
    SELECT 
        IdCliente,
        -- Horas assistidas (D7, D14, D28, D56)
        SUM(duracao) AS qtdeHorasVida,
        SUM(CASE WHEN dtDia >= date('2025-10-01', '-7 day') THEN duracao ELSE 0 END) AS qtdeHorasD7,
        SUM(CASE WHEN dtDia >= date('2025-10-01', '-14 day') THEN duracao ELSE 0 END) AS qtdeHorasD14,
        SUM(CASE WHEN dtDia >= date('2025-10-01', '-28 day') THEN duracao ELSE 0 END) AS qtdeHorasD28,
        SUM(CASE WHEN dtDia >= date('2025-10-01', '-56 day') THEN duracao ELSE 0 END) AS qtdeHorasD56
    FROM tb_horas_dia
    GROUP BY IdCliente
),

tb_lag_dia AS (

    SELECT 
        idCliente,
        dtDia,
        -- Saber quantos dias faz que o cliente nao realiza uma transacao desde o ultimo dia que fez
        LAG(dtDia) OVER (PARTITION BY IdCliente ORDER BY dtDia) AS lagDia
    FROM tb_horas_dia
),

tb_intervalo_dias AS (

    SELECT IdCliente,
    -- Média de intervalo entre os dias de ativacao
        AVG(JULIANDAY(dtDia) - JULIANDAY(lagDia)) AS avgIntervaloDias,
        AVG(CASE WHEN dtDia >= date('2025-10-01', '-28 day') THEN JULIANDAY(dtDia) - JULIANDAY(lagDia) END) AS avgIntervaloDias28
    FROM tb_lag_dia
    GROUP BY IdCliente
), 

tb_share_produtos AS (

    SELECT 
        idCliente,
        1. * COUNT(CASE WHEN DescNomeProduto = 'ChatMessage' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdeChatMessage,
        1. * COUNT(CASE WHEN DescNomeProduto = 'Airflow Lover' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdeAirflowLover,
        1. * COUNT(CASE WHEN DescNomeProduto = 'R Lover' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdeRLover,
        1. * COUNT(CASE WHEN DescNomeProduto = 'Resgatar Ponei' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdeResgatarPonei,
        1. * COUNT(CASE WHEN DescNomeProduto = 'Lista de presença' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdeListadepresenca,
        1. * COUNT(CASE WHEN DescNomeProduto = 'Presença Streak' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdePresençaStreak,
        1. * COUNT(CASE WHEN DescNomeProduto = 'Troca de Pontos StreamElement' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdeTrocadePontosStreamElement,
        1. * COUNT(CASE WHEN DescNomeProduto = 'Reembolso: Troca de Pontos StreamElement' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdeReembolsoTrocadePontosStreamElement,
        1. * COUNT(CASE WHEN DescCategoriaProduto ='rpg'THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdeRpg,
        1. * COUNT(CASE WHEN DescCategoriaProduto ='churn_model'THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdeChurnModel

    FROM tb_transacao AS t1 LEFT JOIN transacao_produto AS t2 ON t1.IdTransacao = t2.IdTransacao
    LEFT JOIN produtos AS t3 ON t2.IdProduto = t3.IdProduto

    GROUP BY idCliente
),

tb_join AS (

    SELECT
        t1.*,
        t2.qtdeHorasVida,
        t2.qtdeHorasD7,
        t2.qtdeHorasD14,
        t2.qtdeHorasD28,
        t2.qtdeHorasD56,
        t3.avgIntervaloDias,
        t3.avgIntervaloDias28,
        t4.qtdeChatMessage,
        t4.qtdeAirflowLover,
        t4.qtdeRLover,
        t4.qtdeResgatarPonei,
        t4.qtdeListadepresenca,
        t4.qtdePresençaStreak,
        t4.qtdeTrocadePontosStreamElement,
        t4.qtdeReembolsoTrocadePontosStreamElement,
        t4.qtdeRpg,
        t4.qtdeChurnModel
    FROM tb_agg_calc AS t1
    LEFT JOIN tb_hora_cliente AS t2 ON t1.IdCliente = t2.IdCliente
    LEFT JOIN tb_intervalo_dias AS t3 ON t1.IdCliente = t3.IdCliente
    LEFT JOIN tb_share_produtos AS t4 ON t1.IdCliente = t4.IdCliente
)

SELECT *, date('2025-10-01', '-1 day') AS dtRef
FROM tb_join