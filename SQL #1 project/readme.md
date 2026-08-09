# Layoffs Data Analysis (SQL)

An end-to-end SQL project analyzing global tech layoffs from raw data cleaning through exploratory data analysis (EDA). Built entirely in MySQL using CTEs, window functions, and multi-table joins.

## Dataset

Raw layoffs data covering company name, industry, location, country, layoff counts/percentages, company stage, and funds raised, spanning 2020–2023.

## 1. Data Cleaning

Steps performed in `data_cleaning.sql`:

- **Staging tables** — copied raw data into a staging table to preserve the original, untouched dataset.
- **Deduplication** — used `ROW_NUMBER()` partitioned across all relevant columns to identify and remove true duplicate rows.
- **Standardization** — trimmed whitespace from text fields, consolidated inconsistent category labels (e.g. collapsing `Crypto`, `Crypto Currency`, `CryptoCurrency` into a single `Crypto` value), standardized country naming, and converted the `date` column from text to a proper `DATE` type.
- **Null/blank handling** — used a self-join to backfill missing `industry` values where the same company had the value populated in another row; removed rows where both `total_laid_off` and `percentage_laid_off` were null, since these rows carried no usable signal.
- **Cleanup** — dropped the helper `row_num` column once deduplication was complete.

## 2. Exploratory Data Analysis

### Q1 — Which companies/industries were hit hardest, in absolute and relative terms?
- **Absolute:** ranked companies and industries by total headcount laid off (`SUM(total_laid_off)`).
- **Relative:** isolated companies with `percentage_laid_off = 1` (complete shutdowns) and compared them by funds raised.
- **Finding:** Katerra (2,434 laid off, $1.6B raised) stands out as a full shutdown at scale. Quibi ($1.8B raised) also shut down entirely despite being one of the most heavily funded startups in the dataset.

### Q2 — How did layoffs trend over time?
- **Yearly totals:** peaks in **2020** (COVID-19 shock — sudden layoffs across travel, hospitality, retail) and **2022** (tech-sector correction following post-pandemic overhiring and tightening capital markets).
- **Monthly rolling total:** a cumulative running sum (via `SUM() OVER (ORDER BY month)`) shows the pace at which layoffs accumulated, highlighting where the crisis accelerated versus periods of relative calm.
- **Finding:** the dataset captures two distinct crises with different root causes, not one continuous trend.

### Q3 — Did well-funded companies lay off proportionally more or less than poorly-funded ones?
- Compared companies with `percentage_laid_off = 1` across a wide funding range.
- **Finding:** complete shutdowns occurred across the entire funding spectrum — from $10M-raised startups (PicoBrew, Lido Learning) to billion-dollar companies (Quibi, BlockFi, Britishvolt, Katerra). Funding size showed no protective relationship against total collapse, suggesting shutdown risk is driven more by industry conditions and burn rate than capital raised.

### Q4 — Which companies had repeat rounds of layoffs, and how far apart were they?
- Used `LAG()` partitioned by company to calculate the gap (in days) between a company's layoff rounds.
- **Finding:** gaps ranged from as little as 15–48 days (Airy Rooms, Airlift — signaling the first round of cuts failed to stabilize the company) to over 1,000 days (Airbnb — a 2020 COVID-era layoff followed by a separate, unrelated 2023 downturn).

### Q5 — Does company stage or country predict layoff severity?
- Compared average `percentage_laid_off` across company stage (Seed, Series A–D, Post-IPO, etc.) and country.
- *(Findings to be added once this section is run.)*

## Tools

MySQL — CTEs, window functions (`ROW_NUMBER`, `LAG`, running `SUM() OVER`), self-joins, string/date standardization.

## Files

- `data_cleaning.sql` — full cleaning pipeline
- `eda.sql` — exploratory analysis queries