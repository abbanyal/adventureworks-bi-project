-- 09: SQL Server Agent job that runs usp_Load_All nightly at 02:00
-- Replaces the Azure Data Factory pipeline (no Azure access).
-- Note: if a schedule named 'Nightly 02:00' already exists on this server,
-- delete it first or change the name below.
USE msdb;
GO
IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'AW_DW_Nightly_Load')
    EXEC msdb.dbo.sp_delete_job @job_name = N'AW_DW_Nightly_Load';
GO
EXEC msdb.dbo.sp_add_job
    @job_name = N'AW_DW_Nightly_Load',
    @enabled = 1,
    @description = N'Loads AW_DW dimensions and fact table via dbo.usp_Load_All';

EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'AW_DW_Nightly_Load',
    @step_name = N'Run usp_Load_All',
    @subsystem = N'TSQL',
    @command = N'EXEC dbo.usp_Load_All;',
    @database_name = N'AW_DW';

EXEC msdb.dbo.sp_add_schedule
    @schedule_name = N'Nightly 02:00',
    @freq_type = 4,              -- daily
    @freq_interval = 1,          -- every 1 day
    @active_start_time = 20000;  -- 02:00:00

EXEC msdb.dbo.sp_attach_schedule
    @job_name = N'AW_DW_Nightly_Load',
    @schedule_name = N'Nightly 02:00';

EXEC msdb.dbo.sp_add_jobserver
    @job_name = N'AW_DW_Nightly_Load',
    @server_name = N'(local)';
GO
