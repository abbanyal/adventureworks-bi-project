-- 07: fact.Sales, grain = one sales order line (expected 121,317 rows)
-- Reconciliation: SUM(Revenue) should be about 109,846,381.43
USE AW_DW;
GO
CREATE TABLE fact.Sales (
    SalesKey         INT IDENTITY(1,1) PRIMARY KEY,
    OrderDateKey     INT NOT NULL REFERENCES dim.Date(DateKey),
    ShipDateKey      INT NOT NULL REFERENCES dim.Date(DateKey),
    ProductKey       INT NOT NULL REFERENCES dim.Product(ProductKey),
    CustomerKey      INT NOT NULL REFERENCES dim.Customer(CustomerKey),
    TerritoryKey     INT NOT NULL REFERENCES dim.Territory(TerritoryKey),
    SalesPersonKey   INT NOT NULL REFERENCES dim.SalesPerson(SalesPersonKey),
    SalesOrderID     INT NOT NULL,
    OrderLineNumber  INT NOT NULL,
    SalesOrderNumber VARCHAR(25) NOT NULL,
    OrderQty         INT NOT NULL,
    UnitPrice        DECIMAL(19,4) NOT NULL,
    DiscountPct      DECIMAL(5,4)  NOT NULL,
    Revenue          DECIMAL(19,4) NOT NULL,
    ExtendedCost     DECIMAL(19,4) NOT NULL
);
GO
INSERT INTO fact.Sales
    (OrderDateKey, ShipDateKey, ProductKey, CustomerKey, TerritoryKey, SalesPersonKey,
     SalesOrderID, OrderLineNumber, SalesOrderNumber,
     OrderQty, UnitPrice, DiscountPct, Revenue, ExtendedCost)
SELECT
    CONVERT(INT, CONVERT(CHAR(8), h.OrderDate, 112)),
    CONVERT(INT, CONVERT(CHAR(8), h.ShipDate, 112)),
    ISNULL(dp.ProductKey, -1), ISNULL(dc.CustomerKey, -1),
    ISNULL(dt.TerritoryKey, -1), ISNULL(ds.SalesPersonKey, -1),
    d.SalesOrderID, d.SalesOrderDetailID, h.SalesOrderNumber,
    d.OrderQty, d.UnitPrice, d.UnitPriceDiscount, d.LineTotal,
    d.OrderQty * ISNULL(dp.StandardCost, 0)
FROM AdventureWorks2025.Sales.SalesOrderDetail d
JOIN AdventureWorks2025.Sales.SalesOrderHeader h ON h.SalesOrderID = d.SalesOrderID
LEFT JOIN dim.Product     dp ON dp.ProductID     = d.ProductID
LEFT JOIN dim.Customer    dc ON dc.CustomerID    = h.CustomerID
LEFT JOIN dim.Territory   dt ON dt.TerritoryID   = h.TerritoryID
LEFT JOIN dim.SalesPerson ds ON ds.SalesPersonID = h.SalesPersonID;
GO
SELECT COUNT(*) AS Lines, SUM(Revenue) AS TotalRevenue, SUM(Revenue - ExtendedCost) AS Profit FROM fact.Sales;
