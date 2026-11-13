# Power BI Service Deployment Plan

Status: not executed. No work or school account was available, and Power BI
Service requires one. The report was built, tested and refreshed in Power BI
Desktop instead.

## Steps that would be performed
1. Publish to a workspace named "AW BI Project".
2. Install an on-premises data gateway on the machine hosting SQL Server.
3. Map the data source: server localhost\MSSQLSERVER02, database AW_DW,
   Windows authentication. The name must match Desktop exactly.
4. Schedule refresh daily at 07:00, after the 02:00 SQL Server Agent load.
5. Assign users to the RegionManager and Executive roles under Security.
6. Publish an app for the reviewers.

## What was done instead
- The nightly load runs via SQL Server Agent (see tests/etl_tests.md).
- Row-level security was tested with "View as" in Desktop (tests/rls_tests.md).
- Refresh was run manually in Desktop after each load (tests/performance.md).

## Limitation
The gateway and cloud refresh only work while the host machine is on.
A production deployment would use an always-on server.
