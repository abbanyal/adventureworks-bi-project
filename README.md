# AdventureWorks BI Project

An end-to-end business intelligence solution: a SQL Server star schema, scheduled
loads with SQL Server Agent, and a Power BI report with DAX measures, drill-through
and row-level security.

## Architecture

```mermaid
flowchart LR
  A\[AdventureWorks2025<br/>SQL Server] --> B\[SQL Agent job<br/>usp\_Load\_All, 02:00]
  B --> C\[AW\_DW<br/>dim and fact tables]
  C --> D\[Power BI Desktop<br/>model, DAX, RLS]
  D --> E\[Report pages<br/>Overview, Product, Order Detail]
```

Azure Data Factory was in the original brief. It was replaced by SQL Server Agent
because no Azure access was available.

## Star schema

!\[Star schema](docs/star\_schema.png)

Grain of `fact.Sales`: one row per sales order line (121,317 rows). Dimensions:
Date, Product, Customer, Territory, SalesPerson. See `docs/data\_dictionary.md`.

## Prerequisites

* SQL Server 2025 (or 2022) and SSMS
* Power BI Desktop (Windows)
* The AdventureWorks2025 OLTP backup restored as `AdventureWorks2025`

## Setup

1. Run the scripts in `sql/` in numbered order (01 to 10) in SSMS.
2. Run `EXEC AW\_DW.dbo.usp\_Load\_All;` to load the warehouse.
3. Open `powerbi/AdventureWorks\_BI.pbix`.
4. Home > Transform data > Data source settings: set the server to your instance
(the project used `localhost\\MSSQLSERVER02`) and the database to `AW\_DW`.
5. Click Home > Refresh.

## Results

* 121,317 order lines loaded. Revenue reconciles to the source within 0.025.
* ETL runs in 2 to 12 seconds. A Desktop refresh takes about 10 seconds.
* DAX: Sales, Cost, Profit, Margin %, YTD, prior year, YoY %, rolling 3-month average.
* Row-level security tested for two regional managers and an executive role.
* See `tests/` for reconciliation, ETL, DAX, RLS and performance evidence.

## Challenges

* A reconciliation check exposed a modelling error in dim.Customer: store customers
were labelled as individuals. Fixed in place so surrogate keys stayed stable.
* Source data starts mid-2022 and thins out in May and June 2025, so year-over-year
comparisons needed a "comparable period" measure.
* Revenue differs from the source by 0.025 because of decimal precision (rounding).

## Known limitations

* Power BI Service publishing and scheduled cloud refresh were not done: no work or
school account was available (see `docs/service\_deployment\_plan.md`).
* The host laptop must be on for the scheduled load to run.
* ExtendedCost uses current StandardCost, not the cost at the time of sale.
* Data ends on 29 June 2025.

## Next steps

Add Azure Data Factory with watermark-based incremental loads, use ProductCostHistory
for accurate cost, track product price history (SCD Type 2), and deploy to the
Power BI Service with a gateway and scheduled refresh.

## Documentation

* `docs/User\_Guide.md`
* `docs/data\_dictionary.md`
* `docs/service\_deployment\_plan.md`
* `tests/` (reconciliation, ETL, DAX, RLS, performance)

## Demo

https://drive.google.com/file/d/1pkivNpgEX01FOAEra45MYOfwkG4f2wIT/view?usp=sharing

## Presentation

Video: https://drive.google.com/file/d/16075IUBBO5SdN2ec5\_yz88keHAG1NH5a/view?usp=sharing

Slides: [docs/presentation.pdf](docs/presentation.pdf)

