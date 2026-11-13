-- 05: dim.Customer (19,820 source rows + Unknown = 19,821)
-- Corrected logic: a customer is a Store when StoreID is present. Store customers
-- also carry a PersonID (the store contact), so PersonID must not decide the type.
-- Expected: 18,484 Individual, 1,336 Store, 1 Unknown.
USE AW_DW;
GO
CREATE TABLE dim.Customer (
    CustomerKey   INT          IDENTITY(1,1) PRIMARY KEY,
    CustomerID    INT          NOT NULL,
    CustomerName  VARCHAR(160) NOT NULL,
    CustomerType  VARCHAR(10)  NOT NULL,
    City          VARCHAR(50)  NOT NULL,
    StateProvince VARCHAR(50)  NOT NULL,
    Country       VARCHAR(50)  NOT NULL
);
GO
SET IDENTITY_INSERT dim.Customer ON;
INSERT INTO dim.Customer (CustomerKey, CustomerID, CustomerName, CustomerType, City, StateProvince, Country)
VALUES (-1, -1, 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown');
SET IDENTITY_INSERT dim.Customer OFF;
GO
WITH Addr AS (
    SELECT BusinessEntityID, MIN(AddressID) AS AddressID
    FROM AdventureWorks2025.Person.BusinessEntityAddress
    GROUP BY BusinessEntityID
)
INSERT INTO dim.Customer (CustomerID, CustomerName, CustomerType, City, StateProvince, Country)
SELECT
    c.CustomerID,
    CASE WHEN c.StoreID IS NULL
         THEN LTRIM(RTRIM(ISNULL(p.FirstName,'') + ' ' + ISNULL(p.LastName,'')))
         ELSE ISNULL(s.Name, 'Unknown') END,
    CASE WHEN c.StoreID IS NULL THEN 'Individual' ELSE 'Store' END,
    ISNULL(a.City, 'Unknown'),
    ISNULL(sp.Name, 'Unknown'),
    ISNULL(cr.Name, 'Unknown')
FROM AdventureWorks2025.Sales.Customer c
LEFT JOIN AdventureWorks2025.Person.Person p ON p.BusinessEntityID = c.PersonID
LEFT JOIN AdventureWorks2025.Sales.Store s   ON s.BusinessEntityID = c.StoreID
LEFT JOIN Addr ad ON ad.BusinessEntityID = COALESCE(c.StoreID, c.PersonID)
LEFT JOIN AdventureWorks2025.Person.Address a ON a.AddressID = ad.AddressID
LEFT JOIN AdventureWorks2025.Person.StateProvince sp ON sp.StateProvinceID = a.StateProvinceID
LEFT JOIN AdventureWorks2025.Person.CountryRegion cr ON cr.CountryRegionCode = sp.CountryRegionCode;
GO
SELECT CustomerType, COUNT(*) AS Customers FROM dim.Customer GROUP BY CustomerType;
