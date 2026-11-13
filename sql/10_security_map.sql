-- 10: Row-level security mapping table (FAKE emails only, never commit real ones)
USE AW_DW;
GO
CREATE TABLE dbo.SecurityMap (
    UserEmail    VARCHAR(200) NOT NULL,
    TerritoryKey INT          NOT NULL REFERENCES dim.Territory(TerritoryKey),
    PRIMARY KEY (UserEmail, TerritoryKey)
);
GO
INSERT INTO dbo.SecurityMap (UserEmail, TerritoryKey) VALUES
 ('manager.us@example.com',     1),   -- Northwest
 ('manager.us@example.com',     2),   -- Northeast
 ('manager.europe@example.com', 7),   -- France
 ('manager.europe@example.com', 8),   -- Germany
 ('manager.europe@example.com', 10);  -- United Kingdom
GO
