# DAX Test Results

| # | Test | Expected | Actual | Result |
|---|------|----------|--------|--------|
| 1 | Total Sales | about 109.85M | 109,846,381.43 | Pass |
| 2 | Sales YTD at Dec = year total (2022 to 2024) | equal | 14.56M / 31.60M / 43.67M | Pass |
| 3 | Sales YTD at Jun 2025 = 2025 total | equal | 20,008,518.36 | Pass |
| 4 | Sales PY blank for 2022 | blank | blank | Pass |
| 5 | Sales PY Jun 2023 = Sales Jun 2022 | equal | 2,001,278.97 | Pass |
| 6 | Rolling 3M Avg Jul 2022 = average of May to Jul | 1,395,842.30 | 1,395,842.30 | Pass |
| 7 | Power BI yearly totals match SQL | equal | matched | Pass |

## Known limitations
- 2022 data starts on 30 May, so 2022 is partial and May 2023 YoY (+493.9%) is not meaningful.
- Sales in May and June 2025 are sparse, so their YoY figures are low.
- Plain YoY shows -100% for Jul to Dec 2025 (no data). YoY (Comparable) is blank there.
- The 3-month rolling average is understated for the first two months of data.
