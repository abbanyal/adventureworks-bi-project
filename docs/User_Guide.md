# AdventureWorks Sales Report: User Guide

## Purpose
This report shows sales performance for AdventureWorks by region, product and
customer, so managers can track revenue, profit and growth.

## How to open it
1. Install Power BI Desktop (free, Windows only).
2. Open `powerbi/AdventureWorks_BI.pbix`.
3. If the data does not load, update the data source: Home > Transform data >
   Data source settings, and set the server to your SQL Server instance
   (the project used `localhost\MSSQLSERVER02`) and the database to `AW_DW`.

## Pages
| Page | What it shows |
|---|---|
| Executive Overview | Sales, Profit, Margin % and YoY % cards, monthly trend with 3-month rolling average, sales by region, top 10 products |
| Product & Customer | Sales by category, a Category > Subcategory > Product matrix, a decomposition tree, sales by customer type over time |
| Order Detail | Order-level lines for a chosen region, product or customer (reached by drill-through) |

## Filtering
- Use the **Year** and **Region** slicers at the top. Selections carry across the
  first two pages.
- Click any bar, slice or row to cross-filter the other visuals on the page.
  Click it again to clear.
- Hold Ctrl to select several regions at once.
- The buttons at the top of the Executive Overview jump to saved views
  (All regions, Europe only, 2024 view). Ctrl + click them in Desktop.

## Drill-through
Right-click a region bar, a product row or a customer row, choose
**Drill through > Order Detail**, and the page shows the order lines for that
selection. Ctrl + click the back arrow to return.

## Metric definitions
| Measure | Meaning |
|---|---|
| Sales | Sum of order line revenue after discount |
| Cost | Order quantity x the product's standard cost |
| Profit | Sales minus Cost |
| Margin % | Profit divided by Sales |
| Sales YoY % (Comparable) | Growth against the same dates a year earlier. Use it with one year selected |
| Sales Rolling 3M Avg | Sales over the last 3 months divided by 3. Understated for the first two months of data |

## Data and refresh
- Data covers 30 May 2022 to 29 June 2025. Sales are thin in May and June 2025.
- 2022 is a partial year, so early comparisons are not meaningful.
- A SQL Server Agent job loads the warehouse nightly at 02:00. In Desktop, click
  Home > Refresh after the load to update the report.

## Security
Row-level security limits each regional manager to their own regions. It is
tested in Desktop with Modeling > View as. It applies in the Power BI Service
only when the report is published and users are assigned to roles.

## Contact
Name: Ankush
Email: abankushbanyal@gmail.com
