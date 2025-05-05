USE ShinerSA
GO

--------------------------------------------------
--FUNCTIONS
--------------------------------------------------
IF OBJECT_ID(N'dbo.FormatPhone', N'FN') IS NOT NULL
	DROP FUNCTION FormatPhone;
GO
CREATE FUNCTION dbo.FormatPhone (@phone VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS
BEGIN
	IF LEN(@phone) = 10
		AND ISNUMERIC(@phone) = 1
	BEGIN
		RETURN '(' + SUBSTRING(@phone, 1, 3) + ') ' + SUBSTRING(@phone, 4, 3) + '-' + SUBSTRING(@phone, 7, 4) ---> this is good for perecman
	END
	RETURN @phone;
END;
GO

IF OBJECT_ID(N'dbo.udf_StripHTML', N'FN') IS NOT NULL
	DROP FUNCTION udf_StripHTML;
GO
CREATE FUNCTION [dbo].[udf_StripHTML] (@HTMLText VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @Start INT
	DECLARE @End INT
	DECLARE @Length INT
	SET @Start = CHARINDEX('<', @HTMLText)
	SET @End = CHARINDEX('>', @HTMLText, CHARINDEX('<', @HTMLText))
	SET @Length = (@End - @Start) + 1
	WHILE @Start > 0
	AND @End > 0
	AND @Length > 0
	BEGIN
	SET @HTMLText = STUFF(@HTMLText, @Start, @Length, '')
	SET @Start = CHARINDEX('<', @HTMLText)
	SET @End = CHARINDEX('>', @HTMLText, CHARINDEX('<', @HTMLText))
	SET @Length = (@End - @Start) + 1
	END
	RETURN LTRIM(RTRIM(@HTMLText))
END
GO
--------------------------------------------------
--FIELD LENGTHS/SAGA
--------------------------------------------------

--IndvContacts SAGA
ALTER TABLE sma_MST_IndvContacts
ALTER COLUMN [saga] VARCHAR(100)
GO

--ALTER TABLE sma_MST_IndvContacts
--ALTER COLUMN [cinsFirstName] VARCHAR(50)
--GO

--ALTER TABLE sma_MST_IndvContacts
--ALTER COLUMN [cinsLastName] VARCHAR(50)
--GO

ALTER TABLE sma_MST_IndvContacts
ALTER COLUMN [cinsNickName] VARCHAR(80)
GO

--ADD SAGA TO USERS
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga'
			AND object_id = OBJECT_ID(N'sma_MST_Users')
	)
BEGIN
	ALTER TABLE [sma_MST_Users]
	ADD [saga] [VARCHAR](100) NULL;
END
GO

--ORG Contacts SAGA
ALTER TABLE sma_MST_OrgContacts
ALTER COLUMN [saga] VARCHAR(100)
GO


--SMA_MST_ADDRESS
--ALTER TABLE sma_MST_Address
--ALTER COLUMN [addsAddress1] VARCHAR(150)
--GO
ALTER TABLE sma_MST_Address
ALTER COLUMN [addsZip] VARCHAR(12)
GO
ALTER TABLE sma_MST_Address
ALTER COLUMN [saga] VARCHAR(100)
GO

ALTER TABLE [sma_MST_EmailWebsite]
ALTER COLUMN saga VARCHAR(100);
GO

ALTER TABLE [sma_MST_ContactNumbers]
ALTER COLUMN cnnsContactNumber VARCHAR(31)
GO

--ADD LITIFY_SAGA  CASE SAGA HAS TO BE INT TYPE
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'Litify_saga'
			AND object_id = OBJECT_ID(N'sma_trn_Cases')
	)
BEGIN
	ALTER TABLE [sma_TRN_Cases]
	ADD Litify_saga [VARCHAR](100) NULL;
END
GO
