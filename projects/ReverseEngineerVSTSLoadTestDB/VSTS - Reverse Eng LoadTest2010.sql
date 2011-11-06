select * FROM [LoadTest2010].[dbo].[WebLoadTestTransaction]
select COUNT(*) from LoadTestTestLog --344
select COUNT(*) from LoadTestRun --37
select * from LoadTestRun
--LoadTestRunId, RunId and StartTime
select COUNT(*) from LoadTestLogData_Run37_Log0 --0
select COUNT(*) from LoadTestDataCollectorLog --32, -> Event Log
select * from LoadTestDataCollectorLog
select * from LoadTestBrowsers
select * from LoadTestCase
select * from LoadTestDetailMessage where LoadTestRunId = 35
select * from LoadTestFileAttachment --33
select * from LoadTestFileAttachmentChunk -- what the hell is this?
select * from LoadTestLogData_Run10_Log0 --0
select * from LoadTestLogData_Run37_Log0 --0
select * from LoadTestNetworks
select * from LoadTestPageDetail --0
select * from LoadTestPageSummaryByNetwork --0
select * from LoadTestPageSummaryData --0

select * from LoadTestPerformanceCounter -- some expert system included. --4159, counter per test
select * from LoadTestPerformanceCounterCategory --651
select COUNT(*) from LoadTestPerformanceCounterInstance --273352
select COUNT(*) from LoadTestPerformanceCounterInstance where LoadTestRunId = 35 --350 * 5 = 17
select * from LoadTestPerformanceCounterInstance where LoadTestRunId = 35
sp_help LoadTestPerformanceCounterInstance

select COUNT(*) from LoadTestPerformanceCounterSample -- 8459081
sp_help LoadTestPerformanceCounterSample
select top 100 * from LoadTestPerformanceCounterSample where LoadTestRunId = 35  
select distinct(countertype) from LoadTestPerformanceCounterSample where LoadTestRunId = 35 
--13 countertype
select distinct(instanceid) from LoadTestPerformanceCounterSample where LoadTestRunId = 35 
--350 instanceid
--counterid->instanceid

select * from LoadTestMessage where  LoadTestRunId = 35 --to get messages

--Find //JTCWFNFEPSAV01/% Processor Time/_Total
select * from LoadTestPerformanceCounterCategory where LoadTestRunId = 35 
and CategoryName = 'Processor'
and MachineName = 'JTCWFNFEPSAV01'
--CounterCategoryId = 9
select * from LoadTestPerformanceCounter where LoadTestRunId = 35 
and CounterCategoryId = 9
and CounterName = '% Processor Time'
--CounterId = 83
select * from LoadTestPerformanceCounterInstance where LoadTestRunId = 35 
and CounterId = 83
and InstanceName = '_Total'
--InstanceId = 221 -> 
select * from LoadTestPerformanceCounterSample where LoadTestRunId = 35 and InstanceId = 221
--53 instances of ComputedValue