# 📊 Capa.fi Cross-Chain Volume Dashboard

This Dune Analytics dashboard tracks mostly **USDC transaction activity** related to Capa.fi’s operations across multiple blockchains. It provides a unified view of volume, trends, and usage, helping monitor ramp flows over time.

## 🔍 Features

- ✅ **Total USDC Volume Processed**
- ✅ **Chain-level breakdowns** (Polygon, Solana, Tron, Optimism, Arbitrum, Ethereum, Base, BNB)
- ✅ **Monthly and Weekly bar charts**
- ✅ **Cumulative volume tracking**
- ✅ **Transaction count widgets**
- ✅ **Ability to filter by date**

## 📈 Dashboard

![Monthly Volume](/assets/capa-dashboard-monthly.png)
![Weekly Volume](/assets/capa-dashboard-weekly.png)

## 🧠 Methodology

All data is based on **verified Capa-related wallets**. Transfers are pulled from native `tokens.transfers`, `tokens_solana.transfers`, and `erc20_tron.evt_transfer` tables, normalized per chain.

Queries are grouped by:
- `DATE_TRUNC('month', block_time)` for monthly charts
- `DATE_TRUNC('week', block_time)` for weekly charts

Cumulative metrics are calculated using `SUM(...) OVER (ORDER BY time)` logic.

## 📂 File Structure

```
queries/
├── volume_counters_by_chain.sql       # Total & cumulative volume by chain/month
├── monthly_volume_barchart.sql        # Monthly volume bar chart (Polygon, Solana, Tron)
├── weekly_volume_barchart.sql         # Weekly volume bar chart (Polygon, Solana, Tron)
assets/
├── capa-dashboard-monthly.png         # Screenshot of monthly chart
├── capa-dashboard-weekly.png          # Screenshot of weekly chart
```

## 📎 License

This project is for analytics, research, and operational transparency purposes. Built by **@mimegod**.
