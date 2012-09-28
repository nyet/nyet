SELECT name, type_desc FROM sys.system_objects WHERE name LIKE 'dm_%' ORDER BY name

Page #17: 1.1.1 A glimpse into SQL Server’s internal data

SELECT * FROM sys.dm_exec_requests
sql_handle: 0x0200000002C6D42F7AAACE541C95D637FEB5A6185258B435



select * from sys.dm_exec_query_stats
select * from sys.dm_exec_query_stats where sql_handle = 0x0200000002C6D42F7AAACE541C95D637FEB5A6185258B435
query_hash: 0x3699BA96D3F9F6A1
query_plan_hash: 0xAD412BC185253225

dm_exec_sql_text	SQL_INLINE_TABLE_VALUED_FUNCTION


sys.dm_exec_sql_text(sql_handle)


Page #20: 1.2.2 Performance tuning