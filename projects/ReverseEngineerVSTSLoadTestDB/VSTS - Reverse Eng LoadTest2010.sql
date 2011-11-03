select * FROM [LoadTest2010].[dbo].[WebLoadTestTransaction]
select COUNT(*) from LoadTestTestLog --344
select COUNT(*) from LoadTestRun --37
select * from LoadTestRun
--LoadTestRunId, RunId and StartTime
select COUNT(*) from LoadTestLogData_Run37_Log0 --0
select COUNT(*) from LoadTestDataCollectorLog --32
select * from LoadTestDataCollectorLog
select * from LoadTestBrowsers
select * from LoadTestCase
select * from LoadTestDetailMessage where LoadTestRunId = 35
select * from LoadTestNetworks
select * from LoadTestPageDetail --0
select * from LoadTestPageSummaryByNetwork --0
select * from LoadTestPageSummaryData --0

select * from LoadTestPerformanceCounter -- some expert system included.
select * from LoadTestPerformanceCounterCategory
select COUNT(*) from LoadTestPerformanceCounterInstance --273352
select COUNT(*) from LoadTestPerformanceCounterInstance where LoadTestRunId = 35 --350 * 5 = 17
select * from LoadTestPerformanceCounterInstance where LoadTestRunId = 35

sp_help LoadTestPerformanceCounterInstance

select * from LoadTestMessage where  LoadTestRunId = 35 --to get messages