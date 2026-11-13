-- 06: dim.SalesPerson (17 source rows + Unknown = 18)
USE AW_DW;
GO
CREATE TABLE dim.SalesPerson (
    SalesPersonKey   INT          IDENTITY(1,1) PRIMARY KEY,
    SalesPersonID    INT          NOT NULL,
    SalesPersonName  VARCHAR(100) NOT NULL,
    TerritoryKey     INT          NOT NULL REFERENCES dim.Territory(TerritoryKey),
    Region           VARCHAR(50)  NOT NULL
);
GO
SET IDENTITY_INSERT dim.SalesPerson ON;
INSERT INTO dim.SalesPerson (SalesPersonKey, SalesPersonID, SalesPersonName, TerritoryKey, Region)
VALUES (-1, -1, 'No Salesperson (Online)', -1, 'Unknown');
SET IDENTITY_INSERT dim.SalesPerson OFF;
GO
INSERT INTO dim.SalesPerson (SalesPersonID, SalesPersonName, TerritoryKey, Region)
SELECT sp.BusinessEntityID,
       LTRIM(RTRIM(p.FirstName + ' ' + p.LastName)),
       ISNULL(t.TerritoryKey, -1),
       ISNULL(t.Region, 'Unknown')
FROM AdventureWorks2025.Sales.SalesPerson sp
JOIN AdventureWorks2025.Person.Person p ON p.BusinessEntityID = sp.BusinessEntityID
LEFT JOIN dim.Territory t ON t.TerritoryID = sp.TerritoryID;
GO
SELECT * FROM dim.SalesPerson ORDER BY SalesPersonKey;
