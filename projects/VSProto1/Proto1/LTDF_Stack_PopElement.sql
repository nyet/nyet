DECLARE @intErrorCode INT;
DECLARE @idx1 INT;
DECLARE @value1 NCHAR;

BEGIN TRAN

SET @idx1 = (SELECT TOP 1 idx1 FROM SessionStackInfo WHERE key1 = @p0);

SET @value1 = (SELECT value1 FROM SessionStackInfo WHERE idx1 = @idx1);

DELETE FROM SessionStackInfo WHERE key1 = @p0 and idx1 = @idx1;

SELECT @value1 as value1;

SELECT @intErrorCode = @@ERROR
IF (@intErrorCode != 0) GOTO PROBLEM
COMMIT TRAN
PROBLEM:
IF (@intErrorCode != 0) BEGIN
	PRINT 'Unexpected error occurred!'
	ROLLBACK TRAN
END


