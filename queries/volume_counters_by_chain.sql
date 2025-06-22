WITH
filtered_solana AS (
  SELECT
    'solana' AS blockchain,
    block_time,
    amount,
    amount_usd
  FROM tokens_solana.transfers
  WHERE to_owner = '3h481uLM3WgR87Lc9CHEkqMpy8aWA5cAMY3ZRoxgks4e'
),

filtered_tron AS (
  SELECT
    'tron' AS blockchain,
    evt_block_time AS block_time,
    value / 1e6 AS amount,
    value / 1e6 AS amount_usd
  FROM erc20_tron.evt_transfer
  WHERE "to" = 0x8A0B37174E07FD55E1EBE30C5D9E837C71A83B2F
    AND contract_address = 0xa614f803b6fd780986a42c78ec9c7f77e6ded13c
),

filtered_transfers AS (
  SELECT
    blockchain,
    block_time,
    amount,
    amount_usd
  FROM tokens.transfers
  WHERE 
    "to" IN (
      0xad407766b93cf4a715ec4d2646d43e24e35a60ee,
      0xaed8698e8d4af22bed9e28ba71aa8ec657c4254c,
      0x192d4effbc52fb2a38c95dbe4b6de997bba190d0
    )
    OR "from" = 0xad407766b93cf4a715ec4d2646d43e24e35a60ee
    OR ("to" = 0xbf50147ef47019e95652a5efec9f01c6d8ce116d AND blockchain = 'polygon')
    OR ("to" = 0x7c2e3b420426771b182550a00fd8587909faa5fd AND blockchain = 'base')
    OR ("to" = 0xad3b42cb2d7cf05b03ddc25e09870d0857cea398 AND blockchain = 'polygon')

  UNION ALL

  SELECT * FROM filtered_solana
  UNION ALL
  SELECT * FROM filtered_tron
),

monthly_sums AS (
  SELECT
    DATE_TRUNC('month', block_time) AS month,

    -- Known chains
    COUNT(*) FILTER (WHERE blockchain = 'polygon') AS polygon_tx,
    SUM(amount) FILTER (WHERE blockchain = 'polygon') AS polygon_amount,
    SUM(amount_usd) FILTER (WHERE blockchain = 'polygon') AS polygon_amount_usd,

    COUNT(*) FILTER (WHERE blockchain = 'arbitrum') AS arbitrum_tx,
    SUM(amount) FILTER (WHERE blockchain = 'arbitrum') AS arbitrum_amount,
    SUM(amount_usd) FILTER (WHERE blockchain = 'arbitrum') AS arbitrum_amount_usd,

    COUNT(*) FILTER (WHERE blockchain = 'optimism') AS optimism_tx,
    SUM(amount) FILTER (WHERE blockchain = 'optimism') AS optimism_amount,
    SUM(amount_usd) FILTER (WHERE blockchain = 'optimism') AS optimism_amount_usd,

    COUNT(*) FILTER (WHERE blockchain = 'base') AS base_tx,
    SUM(amount) FILTER (WHERE blockchain = 'base') AS base_amount,
    SUM(amount_usd) FILTER (WHERE blockchain = 'base') AS base_amount_usd,

    COUNT(*) FILTER (WHERE blockchain = 'bnb') AS bnb_tx,
    SUM(amount) FILTER (WHERE blockchain = 'bnb') AS bnb_amount,
    SUM(amount_usd) FILTER (WHERE blockchain = 'bnb') AS bnb_amount_usd,

    COUNT(*) FILTER (WHERE blockchain = 'ethereum') AS ethereum_tx,
    SUM(amount) FILTER (WHERE blockchain = 'ethereum') AS ethereum_amount,
    SUM(amount_usd) FILTER (WHERE blockchain = 'ethereum') AS ethereum_amount_usd,

    COUNT(*) FILTER (WHERE blockchain = 'solana') AS solana_tx,
    SUM(amount) FILTER (WHERE blockchain = 'solana') AS solana_amount,
    SUM(amount_usd) FILTER (WHERE blockchain = 'solana') AS solana_amount_usd,

    COUNT(*) FILTER (WHERE blockchain = 'tron') AS tron_tx,
    SUM(amount) FILTER (WHERE blockchain = 'tron') AS tron_amount,
    SUM(amount_usd) FILTER (WHERE blockchain = 'tron') AS tron_amount_usd,

    -- Other chains
    COUNT(*) FILTER (WHERE blockchain NOT IN ('polygon','arbitrum','optimism','base','bnb','ethereum','solana','tron')) AS other_tx,
    SUM(amount) FILTER (WHERE blockchain NOT IN ('polygon','arbitrum','optimism','base','bnb','ethereum','solana','tron')) AS other_amount,
    SUM(amount_usd) FILTER (WHERE blockchain NOT IN ('polygon','arbitrum','optimism','base','bnb','ethereum','solana','tron')) AS other_amount_usd,

    -- Total
    COUNT(*) AS total_tx,
    SUM(amount) AS total_amount,
    SUM(amount_usd) AS total_amount_usd

  FROM filtered_transfers
  GROUP BY 1
),

with_cumulative AS (
  SELECT
    month,

    -- Polygon
    polygon_tx,
    polygon_amount,
    polygon_amount_usd,
    SUM(polygon_tx) OVER (ORDER BY month) AS polygon_cumulative_tx,
    SUM(polygon_amount) OVER (ORDER BY month) AS polygon_cumulative,
    SUM(polygon_amount_usd) OVER (ORDER BY month) AS polygon_cumulative_usd,

    -- Arbitrum
    arbitrum_tx,
    arbitrum_amount,
    arbitrum_amount_usd,
    SUM(arbitrum_tx) OVER (ORDER BY month) AS arbitrum_cumulative_tx,
    SUM(arbitrum_amount) OVER (ORDER BY month) AS arbitrum_cumulative,
    SUM(arbitrum_amount_usd) OVER (ORDER BY month) AS arbitrum_cumulative_usd,

    -- Optimism
    optimism_tx,
    optimism_amount,
    optimism_amount_usd,
    SUM(optimism_tx) OVER (ORDER BY month) AS optimism_cumulative_tx,
    SUM(optimism_amount) OVER (ORDER BY month) AS optimism_cumulative,
    SUM(optimism_amount_usd) OVER (ORDER BY month) AS optimism_cumulative_usd,

    -- Base
    base_tx,
    base_amount,
    base_amount_usd,
    SUM(base_tx) OVER (ORDER BY month) AS base_cumulative_tx,
    SUM(base_amount) OVER (ORDER BY month) AS base_cumulative,
    SUM(base_amount_usd) OVER (ORDER BY month) AS base_cumulative_usd,

    -- BNB
    bnb_tx,
    bnb_amount,
    bnb_amount_usd,
    SUM(bnb_tx) OVER (ORDER BY month) AS bnb_cumulative_tx,
    SUM(bnb_amount) OVER (ORDER BY month) AS bnb_cumulative,
    SUM(bnb_amount_usd) OVER (ORDER BY month) AS bnb_cumulative_usd,

    -- Ethereum
    ethereum_tx,
    ethereum_amount,
    ethereum_amount_usd,
    SUM(ethereum_tx) OVER (ORDER BY month) AS ethereum_cumulative_tx,
    SUM(ethereum_amount) OVER (ORDER BY month) AS ethereum_cumulative,
    SUM(ethereum_amount_usd) OVER (ORDER BY month) AS ethereum_cumulative_usd,

    -- Solana
    solana_tx,
    solana_amount,
    solana_amount_usd,
    SUM(solana_tx) OVER (ORDER BY month) AS solana_cumulative_tx,
    SUM(solana_amount) OVER (ORDER BY month) AS solana_cumulative,
    SUM(solana_amount_usd) OVER (ORDER BY month) AS solana_cumulative_usd,

    -- Tron
    tron_tx,
    tron_amount,
    tron_amount_usd,
    SUM(tron_tx) OVER (ORDER BY month) AS tron_cumulative_tx,
    SUM(tron_amount) OVER (ORDER BY month) AS tron_cumulative,
    SUM(tron_amount_usd) OVER (ORDER BY month) AS tron_cumulative_usd,

    -- Other
    other_tx,
    other_amount,
    other_amount_usd,
    SUM(other_tx) OVER (ORDER BY month) AS other_cumulative_tx,
    SUM(other_amount) OVER (ORDER BY month) AS other_cumulative,
    SUM(other_amount_usd) OVER (ORDER BY month) AS other_cumulative_usd,

    -- Totals
    total_tx,
    total_amount,
    total_amount_usd,
    SUM(total_tx) OVER (ORDER BY month) AS total_cumulative_tx,
    SUM(total_amount) OVER (ORDER BY month) AS total_cumulative_amount,
    SUM(total_amount_usd) OVER (ORDER BY month) AS total_cumulative_amount_usd
  FROM monthly_sums
)

SELECT *
FROM with_cumulative
ORDER BY month DESC;

