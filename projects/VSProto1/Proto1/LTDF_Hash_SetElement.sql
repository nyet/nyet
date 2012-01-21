DECLARE @intErrorCode INT;

BEGIN TRAN

UPDATE SessionHashInfo SET value1 = @p1 WHERE key1 = @p0

SELECT @intErrorCode = @@ERROR
IF (@intErrorCode != 0) GOTO PROBLEM
COMMIT TRAN
PROBLEM:
IF (@intErrorCode != 0) BEGIN
	PRINT 'Unexpected error occurred!'
	ROLLBACK TRAN
END
