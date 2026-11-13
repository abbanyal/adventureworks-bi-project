-- 08: Audit log and ETL stored procedures
-- Dimensions: update in place + insert new rows (surrogate keys never change).
-- Fact: truncate and reload. Master procedure usp_Load_All logs every run.
USE AW_DW;
GO
IF OBJECT_ID('dbo.EtlLog') IS NULL
CREATE TABLE dbo.EtlLog (
    LogID        INT IDENTITY(1,1) PRIMARY KEY,
    ProcName     VARCHAR(100)   NOT NULL,
    StartTime    DATETIME2      NOT NULL,
    EndTime      DATETIME2      NULL,
    FactRows     INT            NULL,
    Status       VARCHAR(10)    NOT NULL,   -- Running / Success / Failed
    ErrorMessage NVARCHAR(4000) NULL
);
GO
CREATE OR ALTER PROCEDURE dbo.usp_Load_DimTerritory AS
BEGIN
    SET NOCOUNT ON;
    UPDATE t SET Region = s.Name, CountryRegionCode = s.CountryRegionCode, TerritoryGroup = s.[Group]
    FROM dim.Territory t
    JOIN AdventureWorks2025.Sales.SalesTerritory s ON s.TerritoryID = t.TerritoryID;

    INSERT INTO dim.Territory (TerritoryID, Region, CountryRegionCode, TerritoryGroup)
    SELECT s.TerritoryID, s.Name, s.CountryRegionCode, s.[Group]
    FROM AdventureWorks2025.Sales.SalesTerritory s
    WHERE NOT EXISTS (SELECT 1 FROM dim.Territory t WHERE t.TerritoryID = s.TerritoryID);
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_Load_DimProduct AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.ProductID, p.Name AS ProductName, p.ProductNumber,
           ISNULL(p.Color,'N/A') AS Color,
           ISNULL(sc.Name,'No Subcategory') AS Subcategory,
           ISNULL(c.Name,'No Category') AS Category,
           p.StandardCost, p.ListPrice
    INTO #src
    FROM AdventureWorks2025.Production.Product p
    LEFT JOIN AdventureWorks2025.Production.ProductSubcategory sc ON sc.ProductSubcategoryID = p.ProductSubcategoryID
    LEFT JOIN AdventureWorks2025.Production.ProductCategory c ON c.ProductCategoryID = sc.ProductCategoryID;

    UPDATE d SET ProductName = s.ProductName, ProductNumber = s.ProductNumber, Color = s.Color,
                 Subcategory = s.Subcategory, Category = s.Category,
                 StandardCost = s.StandardCost, ListPrice = s.ListPrice
    FROM dim.Product d JOIN #src s ON s.ProductID = d.ProductID
    WHERE d.ProductKey <> -1;

    INSERT INTO dim.Product (ProductID, ProductName, ProductNumber, Color, Subcategory, Category, StandardCost, ListPrice)
    SELECT s.ProductID, s.ProductName, s.ProductNumber, s.Color, s.Subcategory, s.Category, s.StandardCost, s.ListPrice
    FROM #src s
    WHERE NOT EXISTS (SELECT 1 FROM dim.Product d WHERE d.ProductID = s.ProductID);
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_Load_DimCustomer AS
BEGIN
    SET NOCOUNT ON;
    WITH Addr AS (
        SELECT BusinessEntityID, MIN(AddressID) AS AddressID
        FROM AdventureWorks2025.Person.BusinessEntityAddress
        GROUP BY BusinessEntityID
    )
    SELECT c.CustomerID,
           CASE WHEN c.StoreID IS NULL
                THEN LTRIM(RTRIM(ISNULL(p.FirstName,'') + ' ' + ISNULL(p.LastName,'')))
                ELSE ISNULL(s.Name,'Unknown') END AS CustomerName,
           CASE WHEN c.StoreID IS NULL THEN 'Individual' ELSE 'Store' END AS CustomerType,
           ISNULL(a.City,'Unknown') AS City,
           ISNULL(sp.Name,'Unknown') AS StateProvince,
           ISNULL(cr.Name,'Unknown') AS Country
    INTO #src
    FROM AdventureWorks2025.Sales.Customer c
    LEFT JOIN AdventureWorks2025.Person.Person p ON p.BusinessEntityID = c.PersonID
    LEFT JOIN AdventureWorks2025.Sales.Store s ON s.BusinessEntityID = c.StoreID
    LEFT JOIN Addr ad ON ad.BusinessEntityID = COALESCE(c.StoreID, c.PersonID)
    LEFT JOIN AdventureWorks2025.Person.Address a ON a.AddressID = ad.AddressID
    LEFT JOIN AdventureWorks2025.Person.StateProvince sp ON sp.StateProvinceID = a.StateProvinceID
    LEFT JOIN AdventureWorks2025.Person.CountryRegion cr ON cr.CountryRegionCode = sp.CountryRegionCode;

    UPDATE d SET CustomerName = s.CustomerName, CustomerType = s.CustomerType,
                 City = s.City, StateProvince = s.StateProvince, Country = s.Country
    FROM dim.Customer d JOIN #src s ON s.CustomerID = d.CustomerID
    WHERE d.CustomerKey <> -1;

    INSERT INTO dim.Customer (CustomerID, CustomerName, CustomerType, City, StateProvince, Country)
    SELECT s.CustomerID, s.CustomerName, s.CustomerType, s.City, s.StateProvince, s.Country
    FROM #src s
    WHERE NOT EXISTS (SELECT 1 FROM dim.Customer d WHERE d.CustomerID = s.CustomerID);
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_Load_DimSalesPerson AS
BEGIN
    SET NOCOUNT ON;
    SELECT sp.BusinessEntityID AS SalesPersonID,
           LTRIM(RTRIM(p.FirstName + ' ' + p.LastName)) AS SalesPersonName,
           ISNULL(t.TerritoryKey,-1) AS TerritoryKey,
           ISNULL(t.Region,'Unknown') AS Region
    INTO #src
    FROM AdventureWorks2025.Sales.SalesPerson sp
    JOIN AdventureWorks2025.Person.Person p ON p.BusinessEntityID = sp.BusinessEntityID
    LEFT JOIN dim.Territory t ON t.TerritoryID = sp.TerritoryID;

    UPDATE d SET SalesPersonName = s.SalesPersonName, TerritoryKey = s.TerritoryKey, Region = s.Region
    FROM dim.SalesPerson d JOIN #src s ON s.SalesPersonID = d.SalesPersonID
    WHERE d.SalesPersonKey <> -1;

    INSERT INTO dim.SalesPerson (SalesPersonID, SalesPersonName, TerritoryKey, Region)
    SELECT s.SalesPersonID, s.SalesPersonName, s.TerritoryKey, s.Region
    FROM #src s
    WHERE NOT EXISTS (SELECT 1 FROM dim.SalesPerson d WHERE d.SalesPersonID = s.SalesPersonID);
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_Load_FactSales AS
BEGIN
    SET NOCOUNT ON;
    TRUNCATE TABLE fact.Sales;

    INSERT INTO fact.Sales
        (OrderDateKey, ShipDateKey, ProductKey, CustomerKey, TerritoryKey, SalesPersonKey,
         SalesOrderID, OrderLineNumber, SalesOrderNumber,
         OrderQty, UnitPrice, DiscountPct, Revenue, ExtendedCost)
    SELECT
        CONVERT(INT, CONVERT(CHAR(8), h.OrderDate, 112)),
        CONVERT(INT, CONVERT(CHAR(8), h.ShipDate, 112)),
        ISNULL(dp.ProductKey,-1), ISNULL(dc.CustomerKey,-1),
        ISNULL(dt.TerritoryKey,-1), ISNULL(ds.SalesPersonKey,-1),
        d.SalesOrderID, d.SalesOrderDetailID, h.SalesOrderNumber,
        d.OrderQty, d.UnitPrice, d.UnitPriceDiscount, d.LineTotal,
        d.OrderQty * ISNULL(dp.StandardCost,0)
    FROM AdventureWorks2025.Sales.SalesOrderDetail d
    JOIN AdventureWorks2025.Sales.SalesOrderHeader h ON h.SalesOrderID = d.SalesOrderID
    LEFT JOIN dim.Product     dp ON dp.ProductID     = d.ProductID
    LEFT JOIN dim.Customer    dc ON dc.CustomerID    = h.CustomerID
    LEFT JOIN dim.Territory   dt ON dt.TerritoryID   = h.TerritoryID
    LEFT JOIN dim.SalesPerson ds ON ds.SalesPersonID = h.SalesPersonID;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_Load_All AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @LogID INT;
    INSERT INTO dbo.EtlLog (ProcName, StartTime, Status)
    VALUES ('usp_Load_All', SYSDATETIME(), 'Running');
    SET @LogID = SCOPE_IDENTITY();

    BEGIN TRY
        EXEC dbo.usp_Load_DimTerritory;
        EXEC dbo.usp_Load_DimProduct;
        EXEC dbo.usp_Load_DimCustomer;
        EXEC dbo.usp_Load_DimSalesPerson;
        EXEC dbo.usp_Load_FactSales;

        UPDATE dbo.EtlLog
        SET EndTime = SYSDATETIME(), Status = 'Success',
            FactRows = (SELECT COUNT(*) FROM fact.Sales)
        WHERE LogID = @LogID;
    END TRY
    BEGIN CATCH
        UPDATE dbo.EtlLog
        SET EndTime = SYSDATETIME(), Status = 'Failed', ErrorMessage = ERROR_MESSAGE()
        WHERE LogID = @LogID;
        THROW;
    END CATCH
END;
GO
