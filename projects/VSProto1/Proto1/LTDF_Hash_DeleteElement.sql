DECLARE @intErrorCode INT;

BEGIN TRAN

DELETE FROM SessionHashInfo WHERE key1 = @p0

SELECT @intErrorCode = @@ERROR
IF (@intErrorCode != 0) GOTO PROBLEM
COMMIT TRAN
PROBLEM:
IF (@intErrorCode != 0) BEGIN
	PRINT 'Unexpected error occurred!'
	ROLLBACK TRAN
END
