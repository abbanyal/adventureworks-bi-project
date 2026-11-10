# Performance Results

Environment: single laptop, SQL Server 2025 Evaluation (instance MSSQLSERVER02),
Power BI Desktop. Dataset: AdventureWorks2025, 121,317 fact rows.

## ETL (SQL Server Agent job AW_DW_Nightly_Load, procedure usp_Load_All)
Source: SQL Server Agent job history and dbo.EtlLog.

| Measure | Result |
|---|---|
| Runs recorded | 4 scheduled runs (7 to 10 Nov 2026) plus several manual runs |
| Job duration range | 2 to 12 seconds |
| Fact rows loaded per run | 121,317 |
| Failures | 0 |

## Power BI Desktop

| Measure | Result |
|---|---|
| Full model refresh | about 10 seconds |
| Report file size (.pbix) | 3.48 MB |
| Sales after refresh | 109,846,381 (matches warehouse) |

## Power BI Service refresh
Not measured. No work or school account was available, so the report was not
published. See docs/service_deployment_plan.md.
