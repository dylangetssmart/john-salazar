USE ShinerSA
GO

/*
alter table [sma_TRN_Documents] disable trigger all
delete from [sma_TRN_Documents] 
DBCC CHECKIDENT ('[sma_TRN_Documents]', RESEED, 0);
alter table [sma_TRN_Documents] enable trigger all
*/

---(0)----

IF OBJECT_ID(N'dbo.FileNamePart', N'FN') IS NOT NULL
	DROP FUNCTION FileNamePart;
GO
CREATE FUNCTION dbo.FileNamePart (@parameter VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS

BEGIN
	DECLARE @trimParameter VARCHAR(MAX) = LTRIM(RTRIM(@parameter));
	DECLARE @return VARCHAR(MAX);
	DECLARE @position INT = CONVERT(INT, (
		SELECT
			CHARINDEX('\', REVERSE(@trimParameter), 0)
	)
	)
	SET @return = SUBSTRING(RIGHT(@trimParameter, @position), 2, 1000)
	RETURN @return;
END;
GO

---(0)---

IF OBJECT_ID(N'dbo.PathPart', N'FN') IS NOT NULL
	DROP FUNCTION PathPart;
GO
CREATE FUNCTION dbo.PathPart (@parameter VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS

BEGIN
	DECLARE @trimParameter VARCHAR(MAX) = LTRIM(RTRIM(@parameter));
	DECLARE @return VARCHAR(MAX);
	IF ((LEN(@trimParameter) + 2 - CONVERT(INT, (
			SELECT
				CHARINDEX('\', REVERSE(@trimParameter), 0)
		)
		)) < 0)
	BEGIN
		SET @return = @trimParameter
	END
	ELSE
	BEGIN
		SET @return = SUBSTRING(@trimParameter, 0, LEN(@trimParameter) + 2 - CONVERT(INT, (
			SELECT
				CHARINDEX('\', REVERSE(@trimParameter), 0)
		)
		))
	END
	RETURN @return;
END;
GO

---(0)---
INSERT INTO [sma_MST_ScannedDocCategories]
	(
	sctgsCategoryName
	)
	SELECT
		'Other/Misc'
	EXCEPT
	SELECT
		sctgsCategoryName
	FROM [sma_MST_ScannedDocCategories]
GO

--ALTER TABLE [dbo].[sma_TRN_Documents]
--ALTER column [docsToContact] [varchar](120) NULL
--GO

----

IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga_char'
			AND Object_ID = OBJECT_ID(N'sma_TRN_Documents')
	)
BEGIN
	ALTER TABLE [sma_TRN_Documents] ADD [saga_char] [VARCHAR](100) NULL;
END

GO
----

ALTER TABLE [sma_TRN_Documents] DISABLE TRIGGER ALL
GO
SET QUOTED_IDENTIFIER ON

---(1)---


/*
alter table [sma_TRN_Documents] disable trigger all
delete from [sma_TRN_Documents] 
DBCC CHECKIDENT ('[sma_TRN_Documents]', RESEED, 0);
alter table [sma_TRN_Documents] enable trigger all
*/
-------------------------------------------------------
-- DOCUMENTS FROM LITIFY_DOCS__FILE_INFO__C
-------------------------------------------------------
INSERT INTO [sma_TRN_Documents]
	(
	[docnCaseID]
   ,[docsDocumentName]
   ,[docsDocumentPath]
   ,[docsDocumentData]
   ,[docnCategoryID]
   ,[docnSubCategoryID]
   ,[docnFromContactCtgID]
   ,[docnFromContactID]
   ,[docsToContact]
   ,[docsDocType]
   ,[docnTemplateID]
   ,[docbAttachFlag]
   ,[docsDescrptn]
   ,[docnAuthor]
   ,[docsDocsrflag]
   ,[docnRecUserID]
   ,[docdDtCreated]
   ,[docnModifyUserID]
   ,[docdDtModified]
   ,[docnLevelNo]
   ,[ctgnCategoryID]
   ,[sctnSubCategoryID]
   ,[sctssSubSubCategoryID]
   ,[sctsssSubSubSubCategoryID]
   ,[docnMedProvContactctgID]
   ,[docnMedProvContactID]
   ,[docnComments]
   ,[docnReasonReject]
   ,[docsReviewerContactId]
   ,[docsReviewDate]
   ,[docsDocumentAnalysisResultId]
   ,[docsIsReviewed]
   ,[docsToContactID]
   ,[docsToContactCtgID]
   ,[docdLastUpdated]
   ,[docnPriority]
   ,[saga_char]
	)

	SELECT
		CAS.casnCaseID AS [docnCaseID]
	   ,doc.[Name] AS [docsDocumentName]
	   ,REPLACE(REPLACE(REPLACE(litify_docs__folder_path__c, '"]', '\'), '["', ''), '","', '\') AS [docsDocumentPath]
	   ,'' AS [docsDocumentData]
	   ,NULL AS [docnCategoryID]
	   ,NULL AS [docnSubCategoryID]
	   ,1 AS [docnFromContactCtgID]
	   ,NULL AS docnFromContactID
	   ,NULL AS [docsToContact]
	   ,'Doc' AS [docsDocType]
	   ,NULL AS [docnTemplateID]
	   ,NULL AS [docbAttachFlag]
	   ,ISNULL('Source: ' + NULLIF(CONVERT(VARCHAR(MAX), doc.litify_docs__Source__c), '') + CHAR(13), '') +
		ISNULL('Name: ' + NULLIF(CONVERT(VARCHAR(MAX), doc.[name]), '') + CHAR(13), '') +
		'' AS [docsDescrptn]
	   ,0 AS [docnAuthor]
	   ,'' AS [docsDocsrflag]
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_users
			WHERE saga = doc.[litify_docs__Updated_By__c]
		)
		AS [docnRecUserID]
	   ,doc.[litify_docs__Updated_On__c] AS [docdDtCreated]
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_users
			WHERE saga = doc.[LastModifiedById]
		)
		AS [docnModifyUserID]
	   ,doc.LastModifiedDate AS [docdDtModified]
	   ,'' AS [docnLevelNo]
	   ,(
			SELECT
				sctgnCategoryID
			FROM sma_MST_ScannedDocCategories
			WHERE sctgsCategoryName = 'Other/Misc'
		)
		AS [ctgnCategoryID]
	   ,NULL AS [sctnSubCategoryID]
	   ,''
	   ,''
	   ,''
	   ,''
	   ,''
	   ,''
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,GETDATE()
	   ,3 AS [docnPriority]
	   ,  -- normal priority
		doc.Id AS [saga_char]
	--select *
	FROM [ShinerLitify].[dbo].[litify_Docs__file_info__c] DOC
	JOIN [sma_TRN_Cases] CAS
		ON CAS.Litify_saga = doc.litify_docs__Related_To__c
GO


-------------------------------------------------------
-- DOCUMENTS FROM LITIFY_PM__LITIFYDOC__C
-------------------------------------------------------
INSERT INTO [sma_TRN_Documents]
	(
	[docnCaseID]
   ,[docsDocumentName]
   ,[docsDocumentPath]
   ,[docsDocumentData]
   ,[docnCategoryID]
   ,[docnSubCategoryID]
   ,[docnFromContactCtgID]
   ,[docnFromContactID]
   ,[docsToContact]
   ,[docsDocType]
   ,[docnTemplateID]
   ,[docbAttachFlag]
   ,[docsDescrptn]
   ,[docnAuthor]
   ,[docsDocsrflag]
   ,[docnRecUserID]
   ,[docdDtCreated]
   ,[docnModifyUserID]
   ,[docdDtModified]
   ,[docnLevelNo]
   ,[ctgnCategoryID]
   ,[sctnSubCategoryID]
   ,[sctssSubSubCategoryID]
   ,[sctsssSubSubSubCategoryID]
   ,[docnMedProvContactctgID]
   ,[docnMedProvContactID]
   ,[docnComments]
   ,[docnReasonReject]
   ,[docsReviewerContactId]
   ,[docsReviewDate]
   ,[docsDocumentAnalysisResultId]
   ,[docsIsReviewed]
   ,[docsToContactID]
   ,[docsToContactCtgID]
   ,[docdLastUpdated]
   ,[docnPriority]
   ,[saga]
	)

	SELECT
		CAS.casnCaseID AS [docnCaseID]
	   ,dbo.FileNamePart(DOC.litify_pm__Path__c) AS [docsDocumentName]
	   ,dbo.PathPart(DOC.litify_pm__Path__c) AS [docsDocumentPath]
	   ,'' AS [docsDocumentData]
	   ,NULL AS [docnCategoryID]
	   ,NULL AS [docnSubCategoryID]
	   ,1 AS [docnFromContactCtgID]
	   ,NULL AS docnFromContactID
	   ,NULL AS [docsToContact]
	   ,'Doc' AS [docsDocType]
	   ,NULL AS [docnTemplateID]
	   ,NULL AS [docbAttachFlag]
	   ,
		--isnull('Source: ' + nullif(convert(varchar(max),doc.litify_docs__Source__c),'') + CHAR(13),'') +
		ISNULL('Name: ' + NULLIF(CONVERT(VARCHAR(MAX), dbo.FileNamePart(DOC.litify_pm__Path__c)), '') + CHAR(13), '') +
		'' AS [docsDescrptn]
	   ,0 AS [docnAuthor]
	   ,'' AS [docsDocsrflag]
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_users
			WHERE saga = doc.CreatedById
		)
		AS [docnRecUserID]
	   ,doc.CreatedDate AS [docdDtCreated]
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_users
			WHERE saga = doc.LastModifiedById
		)
		AS [docnModifyUserID]
	   ,doc.LastModifiedDate AS [docdDtModified]
	   ,'' AS [docnLevelNo]
	   ,(
			SELECT
				sctgnCategoryID
			FROM sma_MST_ScannedDocCategories
			WHERE sctgsCategoryName = 'Other/Misc'
		)
		AS [ctgnCategoryID]
	   ,NULL AS [sctnSubCategoryID]
	   ,''
	   ,''
	   ,''
	   ,''
	   ,''
	   ,''
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,GETDATE()
	   ,3 AS [docnPriority]
	   ,  -- normal priority
		doc.Id AS [saga]
	--select *
	FROM [ShinerLitify].[dbo].[litify_pm__litifydoc__c] DOC
	JOIN [sma_TRN_Cases] CAS
		ON CAS.Litify_saga = doc.litify_pm__RelatedTo__c
GO

ALTER TABLE [sma_TRN_Documents] ENABLE TRIGGER ALL
GO


