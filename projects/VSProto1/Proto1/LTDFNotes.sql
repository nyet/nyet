USE [ImpactLTDB]

CREATE TABLE [dbo].[SessionStackInfo] (
	[key1] [nchar](20) NOT NULL,
	[value1] [nvarchar](max) NULL,
);
INSERT INTO SessionStackInfo(key1, value1)
VALUES ('test_key_1', '1');

select * from SessionStackInfo
------------------------------------------------------------------------
USE [ImpactLTDB]

CREATE TABLE [dbo].[SessionHashInfo](
	[key1] [nchar](20) NOT NULL,
	[value1] [nvarchar](max) NULL,
 CONSTRAINT [PK_SessionHashInfo] PRIMARY KEY CLUSTERED 
	([key1] ASC) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY];

INSERT INTO SessionHashInfo(key1, value1)
VALUES ('test_key_1', '1');



SELECT * FROM SessionHashInfo
SELECT value1 FROM SessionInfo WHERE key1 = 'orderNumber';
SELECT key1 FROM SessionInfo WHERE key1 = 'orderNumber'; 





DECLARE @this INT;
SET @this = (SELECT
	CASE 
		WHEN key1 = 'test_key_1' THEN 1
		ELSE 0
	END AS TEST_EXIST
FROM SessionInfo WHERE key1 = 'test_key_1'); 
SELECT @this AS THAT;

INSERT INTO SessionInfo(key1, value1)
VALUES ('test_key_1', '1');

