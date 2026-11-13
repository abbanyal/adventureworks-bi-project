-- 02: dim.Date, one row per day, 2022-01-01 to 2025-12-31 (1,461 rows)
USE AW_DW;
GO
CREATE TABLE dim.Date (
    DateKey        INT         NOT NULL PRIMARY KEY,   -- yyyymmdd
    [Date]         DATE        NOT NULL,
    [Year]         SMALLINT    NOT NULL,
    [Quarter]      TINYINT     NOT NULL,
    QuarterName    CHAR(2)     NOT NULL,
    [Month]        TINYINT     NOT NULL,
    MonthName      VARCHAR(10) NOT NULL,
    [Day]          TINYINT     NOT NULL,
    DayOfWeek      TINYINT     NOT NULL,               -- 1 = Monday
    DayName        VARCHAR(10) NOT NULL,
    IsWeekend      BIT         NOT NULL,
    FiscalYear     SMALLINT    NOT NULL,               -- fiscal year starts 1 July
    FiscalQuarter  TINYINT     NOT NULL
);
GO
WITH Nums AS (
    SELECT TOP (DATEDIFF(DAY, '2022-01-01', '2025-12-31') + 1)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
),
Days AS (
    SELECT DATEADD(DAY, n, CAST('2022-01-01' AS DATE)) AS dt FROM Nums
)
INSERT INTO dim.Date
SELECT
    YEAR(dt) * 10000 + MONTH(dt) * 100 + DAY(dt),
    dt,
    YEAR(dt),
    DATEPART(QUARTER, dt),
    'Q' + CAST(DATEPART(QUARTER, dt) AS CHAR(1)),
    MONTH(dt),
    DATENAME(MONTH, dt),
    DAY(dt),
    DATEDIFF(DAY, '19000101', dt) % 7 + 1,
    DATENAME(WEEKDAY, dt),
    CASE WHEN DATEDIFF(DAY, '19000101', dt) % 7 >= 5 THEN 1 ELSE 0 END,
    YEAR(DATEADD(MONTH, 6, dt)),
    ((MONTH(dt) + 5) % 12) / 3 + 1
FROM Days;
GO
SELECT COUNT(*) AS Days, MIN([Date]) AS FirstDay, MAX([Date]) AS LastDay FROM dim.Date;
