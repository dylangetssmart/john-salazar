USE ShinerSA
GO

/*
select distinct litify_pm__Question_Label__c, cas.casnOrgCaseTypeID
--SELECT q.litify_pm__Question_Label__c, q.litify_pm__Answer_Type__c, q.litify_pm__Answer_Options__c, q.litify_pm__Lookup_Sobject_Type__c, qa.*
FROM ShinerLitify..litify_pm__question_answer__c qa
JOIN ShinerLitify..litify_pm__question__c q on q.id = qa.litify_pm__Question__c
JOIN sma_trn_Cases cas on cas.saga = qa.litify_pm__Matter__c
WHERE isnull(convert(varchar(max),qa.litify_pm__Answer__c),'') <> ''

--INTAKE QUESTIONS
SELECT q.litify_pm__Question_Label__c, q.litify_pm__Answer_Type__c, q.litify_pm__Answer_Options__c, q.litify_pm__Lookup_Sobject_Type__c, qa.*
--select distinct litify_pm__Intake__c
FROM ShinerLitify..litify_pm__question_answer__c qa
JOIN ShinerLitify..litify_pm__question__c q on q.id = qa.litify_pm__Question__c
WHERE isnull(convert(varchar(max),qa.litify_pm__Answer__c),'') <> ''
and isnull(litify_pm__Matter__c,'') = '' 
and isnull(litify_pm__intake__c,'') <> ''
order by litify_pm__Intake__c

select * from ShinerLitify..litify_pm__Case_Type__c
*/
/*
SELECT DISTINCT litify_pm__Lookup_Sobject_Type__c
FROM ShinerLitify..litify_pm__question_answer__c qa
JOIN ShinerLitify..litify_pm__question__c q on q.id = qa.litify_pm__Question__c
WHERE q.litify_pm__Answer_Type__c = 'LOOKUP'
and isnull(convert(varchar(max),qa.litify_pm__Answer__c),'') <> ''
*/
--------------------------------------------------------
--GET ANSWERS WHERE THEY COME FROM LOOKUP TABLES
--------------------------------------------------------
IF EXISTS (
		SELECT
			*
		FROM sys.tables
		WHERE [name] = 'LitifyLookupAnswers'
	)
BEGIN
	DROP TABLE LitifyLookupAnswers
END

CREATE TABLE LitifyLookupAnswers (
	QuestionAnswerID VARCHAR(100)
   ,MatterID VARCHAR(100)
   ,IntakeID VARCHAR(100)
   ,Question VARCHAR(100)
   ,LookupAnswer VARCHAR(100)
   ,lookupTbl VARCHAR(100)
   ,QuestionAnswer VARCHAR(100)
)
---------------------------
--CASE TYPE LOOKUP TABLE
---------------------------
INSERT INTO LitifyLookupAnswers
	(
	QuestionAnswerID
   ,MatterID
   ,IntakeID
   ,Question
   ,LookupAnswer
   ,lookupTbl
   ,QuestionAnswer
	)
	SELECT
		qa.Id
	   ,litify_pm__Matter__c
	   ,litify_pm__Intake__c
	   ,litify_pm__Question_Label__c
	   ,litify_pm__Answer__c
	   ,litify_pm__Lookup_Sobject_Type__c
	   ,src.[Name]
	FROM ShinerLitify..litify_pm__question_answer__c qa
	JOIN ShinerLitify..litify_pm__question__c q
		ON q.id = qa.litify_pm__Question__c
	JOIN ShinerLitify..litify_pm__Case_Type__c src
		ON src.id = CONVERT(VARCHAR, litify_pm__Answer__c)
	WHERE q.litify_pm__Answer_Type__c = 'LOOKUP'
		AND litify_pm__Lookup_Sobject_Type__c = 'litify_pm__Case_Type__c'
		AND ISNULL(CONVERT(VARCHAR(MAX), qa.litify_pm__Answer__c), '') <> ''

---------------------------
--ROLE LOOKUP TABLE
---------------------------
INSERT INTO LitifyLookupAnswers
	(
	QuestionAnswerID
   ,MatterID
   ,IntakeID
   ,Question
   ,LookupAnswer
   ,lookupTbl
   ,QuestionAnswer
	)
	SELECT
		qa.Id
	   ,qa.litify_pm__Matter__c
	   ,qa.litify_pm__Intake__c
	   ,litify_pm__Question_Label__c
	   ,litify_pm__Answer__c
	   ,litify_pm__Lookup_Sobject_Type__c
	   ,src.litify_pm__Role__c
	FROM ShinerLitify..litify_pm__question_answer__c qa
	JOIN ShinerLitify..litify_pm__question__c q
		ON q.id = qa.litify_pm__Question__c
	JOIN ShinerLitify..litify_pm__Role__c src
		ON src.id = CONVERT(VARCHAR, litify_pm__Answer__c)
	WHERE q.litify_pm__Answer_Type__c = 'LOOKUP'
		AND litify_pm__Lookup_Sobject_Type__c = 'litify_pm__Role__c'
		AND ISNULL(CONVERT(VARCHAR(MAX), qa.litify_pm__Answer__c), '') <> ''

---------------------------
--ACCOUNT LOOKUP TABLE
---------------------------
INSERT INTO LitifyLookupAnswers
	(
	QuestionAnswerID
   ,MatterID
   ,IntakeID
   ,Question
   ,LookupAnswer
   ,lookupTbl
   ,QuestionAnswer
	)
	SELECT
		qa.Id
	   ,qa.litify_pm__Matter__c
	   ,qa.litify_pm__Intake__c
	   ,litify_pm__Question_Label__c
	   ,litify_pm__Answer__c
	   ,litify_pm__Lookup_Sobject_Type__c
	   ,src.[name]
	FROM ShinerLitify..litify_pm__question_answer__c qa
	JOIN ShinerLitify..litify_pm__question__c q
		ON q.id = qa.litify_pm__Question__c
	JOIN ShinerLitify..Account src
		ON src.id = CONVERT(VARCHAR, litify_pm__Answer__c)
	WHERE q.litify_pm__Answer_Type__c = 'LOOKUP'
		AND litify_pm__Lookup_Sobject_Type__c = 'Account'
		AND ISNULL(CONVERT(VARCHAR(MAX), qa.litify_pm__Answer__c), '') <> ''

---------------------------
--SOURCE LOOKUP TABLE
---------------------------
INSERT INTO LitifyLookupAnswers
	(
	QuestionAnswerID
   ,MatterID
   ,IntakeID
   ,Question
   ,LookupAnswer
   ,lookupTbl
   ,QuestionAnswer
	)
	SELECT
		qa.Id
	   ,qa.litify_pm__Matter__c
	   ,qa.litify_pm__Intake__c
	   ,litify_pm__Question_Label__c
	   ,litify_pm__Answer__c
	   ,litify_pm__Lookup_Sobject_Type__c
	   ,src.[name]
	FROM ShinerLitify..litify_pm__question_answer__c qa
	JOIN ShinerLitify..litify_pm__question__c q
		ON q.id = qa.litify_pm__Question__c
	JOIN ShinerLitify..litify_pm__Source__c src
		ON src.id = CONVERT(VARCHAR, litify_pm__Answer__c)
	WHERE q.litify_pm__Answer_Type__c = 'LOOKUP'
		AND litify_pm__Lookup_Sobject_Type__c = 'litify_pm__Source__c'
		AND ISNULL(CONVERT(VARCHAR(MAX), qa.litify_pm__Answer__c), '') <> ''

--select * From LitifyLookupAnswers

--------------------------------------
--UDF DEFINITION
--------------------------------------
INSERT INTO [sma_MST_UDFDefinition]
	(
	[udfsUDFCtg]
   ,[udfnRelatedPK]
   ,[udfsUDFName]
   ,[udfsScreenName]
   ,[udfsType]
   ,[udfsLength]
   ,[udfbIsActive]
   ,[udfnLevelNo]
   ,[udfshortName]
   ,[udfsNewValues]
   ,[udfnSortOrder]
	)
	SELECT DISTINCT
		'C'														  AS [udfsUDFCtg]
	   ,casnOrgCaseTypeID										  AS [udfnRelatedPK]
	   ,litify_pm__Question_Label__c							  AS [udfsUDFName]
	   ,'Case'													  AS [udfsScreenName]
	   ,'Text'													  AS [udfsType]
	   ,150														  AS [udfsLength]
	   ,1														  AS [udfbIsActive]
	   ,NULL													  AS [udfnLevelNo]
	   ,NULL													  AS [udfshortName]
	   ,NULL													  AS [udfsNewValues]
	   ,DENSE_RANK() OVER (ORDER BY litify_pm__Question_Label__c) AS udfnSortOrder
	FROM ShinerLitify..litify_pm__question_answer__c qa
	JOIN ShinerLitify..litify_pm__question__c q
		ON q.id = qa.litify_pm__Question__c
	JOIN sma_trn_Cases cas
		ON cas.Litify_saga = qa.litify_pm__Matter__c
	LEFT JOIN [sma_MST_UDFDefinition] udf
		ON udf.udfnRelatedPK = casnOrgCaseTypeID
			AND udf.udfsScreenName = 'Case'
			AND udf.udfsUDFName = litify_pm__Question_Label__c
	WHERE ISNULL(CONVERT(VARCHAR(MAX), qa.litify_pm__Answer__c), '') <> ''
		AND udf.udfnUDFID IS NULL


--------------------------------------
--UDF VALUES
--------------------------------------
ALTER TABLE sma_trn_udfvalues DISABLE TRIGGER ALL
GO
INSERT INTO [sma_TRN_UDFValues]
	(
	[udvnUDFID]
   ,[udvsScreenName]
   ,[udvsUDFCtg]
   ,[udvnRelatedID]
   ,[udvnSubRelatedID]
   ,[udvsUDFValue]
   ,[udvnRecUserID]
   ,[udvdDtCreated]
   ,[udvnModifyUserID]
   ,[udvdDtModified]
   ,[udvnLevelNo]
	)
	SELECT
		udf.udfnUDFID AS [udvnUDFID]
	   ,'Case'		  AS [udvsScreenName]
	   ,'C'			  AS [udvsUDFCtg]
	   ,casnCaseID	  AS [udvnRelatedID]
	   ,0			  AS [udvnSubRelatedID]
	   ,CASE
			WHEN q.litify_pm__Answer_Type__c <> 'LOOKUP'
				THEN litify_pm__Answer__c
			ELSE CONVERT(VARCHAR(MAX), lla.QuestionAnswer)
		END			  AS [udvsUDFValue]
	   ,368			  AS [udvnRecUserID]
	   ,GETDATE()	  AS [udvdDtCreated]
	   ,NULL		  AS [udvnModifyUserID]
	   ,NULL		  AS [udvdDtModified]
	   ,NULL		  AS [udvnLevelNo]
	--select *
	FROM ShinerLitify..litify_pm__question_answer__c qa
	JOIN ShinerLitify..litify_pm__question__c q
		ON q.id = qa.litify_pm__Question__c
	JOIN sma_trn_Cases cas
		ON cas.Litify_saga = qa.litify_pm__Matter__c
	JOIN [sma_MST_UDFDefinition] udf
		ON udf.udfnRelatedPK = casnOrgCaseTypeID
			AND udf.udfsScreenName = 'Case'
			AND udf.udfsUDFName = litify_pm__Question_Label__c
	LEFT JOIN LitifyLookupAnswers lla
		ON lla.MatterID = cas.Litify_saga
			AND lla.question = litify_pm__Question_Label__c
	WHERE ISNULL(CONVERT(VARCHAR(MAX), qa.litify_pm__Answer__c), '') <> ''
GO


--UDF FOR INTAKE 
INSERT INTO [sma_TRN_UDFValues]
	(
	[udvnUDFID]
   ,[udvsScreenName]
   ,[udvsUDFCtg]
   ,[udvnRelatedID]
   ,[udvnSubRelatedID]
   ,[udvsUDFValue]
   ,[udvnRecUserID]
   ,[udvdDtCreated]
   ,[udvnModifyUserID]
   ,[udvdDtModified]
   ,[udvnLevelNo]
	)
	SELECT
		udf.udfnUDFID AS [udvnUDFID]
	   ,'Case'		  AS [udvsScreenName]
	   ,'C'			  AS [udvsUDFCtg]
	   ,casnCaseID	  AS [udvnRelatedID]
	   ,0			  AS [udvnSubRelatedID]
	   ,CASE
			WHEN q.litify_pm__Answer_Type__c <> 'LOOKUP'
				THEN litify_pm__Answer__c
			ELSE lla.QuestionAnswer
		END			  AS [udvsUDFValue]
	   ,368			  AS [udvnRecUserID]
	   ,GETDATE()	  AS [udvdDtCreated]
	   ,NULL		  AS [udvnModifyUserID]
	   ,NULL		  AS [udvdDtModified]
	   ,NULL		  AS [udvnLevelNo]
	--select *
	FROM ShinerLitify..litify_pm__question_answer__c qa
	JOIN ShinerLitify..litify_pm__question__c q
		ON q.id = qa.litify_pm__Question__c
	JOIN sma_trn_Cases cas
		ON cas.Litify_saga = qa.litify_pm__Intake__c
	JOIN [sma_MST_UDFDefinition] udf
		ON udf.udfnRelatedPK = casnOrgCaseTypeID
			AND udf.udfsScreenName = 'Case'
			AND udf.udfsUDFName = litify_pm__Question_Label__c
	LEFT JOIN LitifyLookupAnswers lla
		ON lla.MatterID = cas.Litify_saga
			AND lla.question = litify_pm__Question_Label__c
	WHERE ISNULL(CONVERT(VARCHAR(MAX), qa.litify_pm__Answer__c), '') <> ''
		AND ISNULL(litify_pm__Matter__c, '') = ''
GO

ALTER TABLE sma_trn_udfvalues ENABLE TRIGGER ALL
GO

