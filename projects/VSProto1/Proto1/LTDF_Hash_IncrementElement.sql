DECLARE @intErrorCode INT;
--DECLARE @value2 NCHAR;

BEGIN TRAN

UPDATE SessionHashInfo
	SET value1 = 
	CASE 
		WHEN @p1 = '+' THEN CAST((CAST(value1 as INT) + 1) as NCHAR)
		WHEN @p1 = '-' THEN CAST((CAST(value1 as INT) - 1) as NCHAR)
		END
	WHERE key1 = @p0;
SELECT value1 FROM SessionHashInfo WHERE key1 = @p0;

SELECT @intErrorCode = @@ERROR
IF (@intErrorCode != 0) GOTO PROBLEM
COMMIT TRAN
PROBLEM:
IF (@intErrorCode != 0) BEGIN
	PRINT 'Unexpected error occurred!'
	ROLLBACK TRAN
END
