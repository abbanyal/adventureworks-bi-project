-- 03: dim.Territory (10 source rows + Unknown = 11)
USE AW_DW;
GO
CREATE TABLE dim.Territory (
    TerritoryKey      INT          IDENTITY(1,1) PRIMARY KEY,
    TerritoryID       INT          NOT NULL,
    Region            VARCHAR(50)  NOT NULL,
    CountryRegionCode VARCHAR(3)   NOT NULL,
    TerritoryGroup    VARCHAR(50)  NOT NULL
);
GO
SET IDENTITY_INSERT dim.Territory ON;
INSERT INTO dim.Territory (TerritoryKey, TerritoryID, Region, CountryRegionCode, TerritoryGroup)
VALUES (-1, -1, 'Unknown', 'N/A', 'Unknown');
SET IDENTITY_INSERT dim.Territory OFF;
GO
INSERT INTO dim.Territory (TerritoryID, Region, CountryRegionCode, TerritoryGroup)
SELECT TerritoryID, Name, CountryRegionCode, [Group]
FROM AdventureWorks2025.Sales.SalesTerritory;
GO
SELECT * FROM dim.Territory ORDER BY TerritoryKey;
