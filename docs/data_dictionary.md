# Data Dictionary (database AW_DW)

## fact.Sales (grain: one row per sales order line, 121,317 rows)
| Column | Type | Description |
|---|---|---|
| SalesKey | int | Surrogate key |
| OrderDateKey, ShipDateKey | int | yyyymmdd keys to dim.Date |
| ProductKey, CustomerKey, TerritoryKey, SalesPersonKey | int | Keys to dimensions (-1 = Unknown) |
| SalesOrderID, OrderLineNumber | int | Degenerate dimensions from the source |
| SalesOrderNumber | varchar | Order number shown to users |
| OrderQty | int | Units on the line |
| UnitPrice | decimal | Price per unit |
| DiscountPct | decimal | Discount as a fraction |
| Revenue | decimal | Line total after discount |
| ExtendedCost | decimal | OrderQty x current StandardCost |

## dim.Date (1,461 days, 2022-01-01 to 2025-12-31)
DateKey, Date, Year, Quarter, QuarterName, Month, MonthName, Day, DayOfWeek,
DayName, IsWeekend, FiscalYear (starts 1 July), FiscalQuarter.

## dim.Product (505 rows)
ProductKey, ProductID, ProductName, ProductNumber, Color, Subcategory, Category,
StandardCost, ListPrice. Nulls become N/A, No Subcategory or No Category.

## dim.Customer (19,821 rows)
CustomerKey, CustomerID, CustomerName, CustomerType (Individual or Store), City,
StateProvince, Country. Type is Store when StoreID is present.

## dim.Territory (11 rows)
TerritoryKey, TerritoryID, Region, CountryRegionCode, TerritoryGroup.

## dim.SalesPerson (18 rows)
SalesPersonKey, SalesPersonID, SalesPersonName, TerritoryKey, Region.
Key -1 = No Salesperson (Online).

## Supporting tables
- dbo.EtlLog: audit of every load (start, end, rows, status, error).
- dbo.SecurityMap: UserEmail to TerritoryKey, used for row-level security.

Notes: dimensions are Type 1 (overwritten). Every dimension has an Unknown member (-1).
