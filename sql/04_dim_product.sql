-- 04: dim.Product (504 source rows + Unknown = 505), category hierarchy flattened
USE AW_DW;
GO
CREATE TABLE dim.Product (
    ProductKey      INT           IDENTITY(1,1) PRIMARY KEY,
    ProductID       INT           NOT NULL,
    ProductName     VARCHAR(100)  NOT NULL,
    ProductNumber   VARCHAR(25)   NOT NULL,
    Color           VARCHAR(20)   NOT NULL,
    Subcategory     VARCHAR(50)   NOT NULL,
    Category        VARCHAR(50)   NOT NULL,
    StandardCost    DECIMAL(19,4) NOT NULL,
    ListPrice       DECIMAL(19,4) NOT NULL
);
GO
SET IDENTITY_INSERT dim.Product ON;
INSERT INTO dim.Product (ProductKey, ProductID, ProductName, ProductNumber, Color, Subcategory, Category, StandardCost, ListPrice)
VALUES (-1, -1, 'Unknown', 'N/A', 'N/A', 'Unknown', 'Unknown', 0, 0);
SET IDENTITY_INSERT dim.Product OFF;
GO
INSERT INTO dim.Product (ProductID, ProductName, ProductNumber, Color, Subcategory, Category, StandardCost, ListPrice)
SELECT p.ProductID, p.Name, p.ProductNumber,
       ISNULL(p.Color, 'N/A'),
       ISNULL(sc.Name, 'No Subcategory'),
       ISNULL(c.Name,  'No Category'),
       p.StandardCost, p.ListPrice
FROM AdventureWorks2025.Production.Product p
LEFT JOIN AdventureWorks2025.Production.ProductSubcategory sc ON sc.ProductSubcategoryID = p.ProductSubcategoryID
LEFT JOIN AdventureWorks2025.Production.ProductCategory c     ON c.ProductCategoryID = sc.ProductCategoryID;
GO
SELECT Category, COUNT(*) AS Products FROM dim.Product GROUP BY Category ORDER BY Products DESC;
