-- Combined Polygon, Solana, and Tron Wallet Monthly Transfer Summary

WITH filtered_polygon AS (
  SELECT
    blockchain,
    block_time,
    tx_hash,
    contract_address,
    "from",
    "to",
    amount,
    price_usd,
    amount_usd
  FROM tokens.transfers
  WHERE "to" IN (
          0xad407766b93cf4a715ec4d2646d43e24e35a60ee,
          0xaed8698e8d4af22bed9e28ba71aa8ec657c4254c,
          0x192d4effbc52fb2a38c95dbe4b6de997bba190d0
        )
     OR "from" = 0xad407766b93cf4a715ec4d2646d43e24e35a60ee
     OR ("to" = 0xbf50147ef47019e95652a5efec9f01c6d8ce116d AND blockchain = 'polygon')
     OR ("to" = 0x7c2e3b420426771b182550a00fd8587909faa5fd AND blockchain = 'base')
     OR ("to" = 0xad3b42cb2d7cf05b03ddc25e09870d0857cea398 AND blockchain = 'polygon')
),

filtered_solana AS (
  SELECT
    'solana' AS blockchain,
    block_time,
    from_owner AS "from",
    to_owner AS "to",
    amount,
    amount_usd
  FROM tokens_solana.transfers
  WHERE to_owner = '3h481uLM3WgR87Lc9CHEkqMpy8aWA5cAMY3ZRoxgks4e'
),

filtered_tron AS (
  SELECT 
    'tron' AS blockchain,
    evt_block_time AS block_time,
    "from",
    "to",
    value / 1e6 AS amount,
    value / 1e6 AS amount_usd
  FROM erc20_tron.evt_transfer
  WHERE "to" = 0x8A0B37174E07FD55E1EBE30C5D9E837C71A83B2F
    AND contract_address = 0xa614f803b6fd780986a42c78ec9c7f77e6ded13c
),

combined AS (
  SELECT block_time, blockchain, amount, amount_usd FROM filtered_polygon
  UNION ALL
  SELECT block_time, blockchain, amount, amount_usd FROM filtered_solana
  UNION ALL
  SELECT block_time, blockchain, amount, amount_usd FROM filtered_tron
),

monthly_combined AS (
  SELECT
    DATE_TRUNC('month', block_time) AS month,
    blockchain,
    COUNT(*) AS transfers,
    SUM(amount) AS amount,
    SUM(amount_usd) AS amount_usd
  FROM combined
  GROUP BY 1, 2
)

SELECT *,
  SUM(amount) OVER (PARTITION BY blockchain ORDER BY month) AS total_chain_amt,
  SUM(amount_usd) OVER (PARTITION BY blockchain ORDER BY month) AS total_chain_amt_usd,
  SUM(amount) OVER (ORDER BY month) AS total_amt,
  SUM(amount_usd) OVER (ORDER BY month) AS total_amt_usd,
  SUM(transfers) OVER (PARTITION BY blockchain ORDER BY month) AS total_chain_tx,
  SUM(transfers) OVER (ORDER BY month) AS total_tx
FROM monthly_combined
ORDER BY month DESC, blockchain;
