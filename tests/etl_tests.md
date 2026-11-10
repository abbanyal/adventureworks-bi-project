# ETL Tests

## Idempotency
usp_Load_All was run repeatedly. Fact rows stayed at 121,317, revenue at
109,846,381.4250, and dimension counts at 11 / 505 / 19,821 / 18. No duplicates
were added.

## Scheduling (SQL Server Agent job AW_DW_Nightly_Load, schedule Nightly 02:00)
- Scheduled runs succeeded on 7, 8, 9 and 10 Nov 2026. Manual runs also succeeded.
- Durations: 2 to 12 seconds.
- Limitation: the laptop is not always on at 02:00, so some scheduled runs
  started late. A production setup would use an always-on server.

## Audit log
Every run writes start time, end time, fact row count and status to dbo.EtlLog.
