# DAX Measures

All measures live in the `_Measures` table.

## Base
| Measure | Formula | Purpose |
|---|---|---|
| Sales | `SUM ( fact_Sales[Revenue] )` | Revenue after discount |
| Cost | `SUM ( fact_Sales[ExtendedCost] )` | Quantity times standard cost |
| Profit | `[Sales] - [Cost]` | Revenue minus cost |
| Margin % | `DIVIDE ( [Profit], [Sales] )` | Profit as a share of sales |
| Orders | `DISTINCTCOUNT ( fact_Sales[SalesOrderID] )` | Number of orders |
| Units | `SUM ( fact_Sales[OrderQty] )` | Units sold |
| Avg Order Value | `DIVIDE ( [Sales], [Orders] )` | Sales per order |

## Time Intelligence
| Measure | Formula |
|---|---|
| Sales YTD | `TOTALYTD ( [Sales], dim_Date[Date] )` |
| Sales PY | `CALCULATE ( [Sales], SAMEPERIODLASTYEAR ( dim_Date[Date] ) )` |
| Sales YoY % | `DIVIDE ( [Sales] - [Sales PY], [Sales PY] )` |
| Sales Rolling 3M | `CALCULATE ( [Sales], DATESINPERIOD ( dim_Date[Date], MAX ( dim_Date[Date] ), -3, MONTH ) )` |
| Sales Rolling 3M Avg | `DIVIDE ( [Sales Rolling 3M], 3 )` |
| Sales YoY % (Comparable) | `VAR CutoffDate = [Last Sales Date] VAR Cur = CALCULATE ( [Sales], KEEPFILTERS ( dim_Date[Date] <= CutoffDate ) ) VAR PY = CALCULATE ( [Sales], SAMEPERIODLASTYEAR ( dim_Date[Date] ), dim_Date[Date] <= EDATE ( CutoffDate, -12 ) ) RETURN DIVIDE ( Cur - PY, PY )` |

## Helpers
| Measure | Formula |
|---|---|
| Last Sales Date | `VAR k = CALCULATE ( MAX ( fact_Sales[OrderDateKey] ), ALL ( fact_Sales ) ) RETURN DATE ( INT ( k / 10000 ), MOD ( INT ( k / 100 ), 100 ), MOD ( k, 100 ) )` |

## Notes
- Data runs from 30 May 2022 to 29 June 2025, so 2022 and 2025 are partial years.
- Use YoY % (Comparable) with one year selected.
- Rolling 3M Avg is understated for the first two months of data.
