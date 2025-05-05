use ShinerSA
go

-------------------------------------------------------------------------------------------------------------
ALTER TABLE sma_TRN_caseStaff DISABLE TRIGGER ALL
GO

INSERT INTO sma_mst_subrolecode
	(
	srcsDscrptn
   ,srcnRoleID
	)
	SELECT DISTINCT
		'Intake'
	   ,10
	EXCEPT
	SELECT
		srcsDscrptn
	   ,srcnRoleID
	FROM sma_mst_subrolecode
GO

INSERT INTO sma_MST_SubRole
	(
	sbrnRoleID
   ,sbrsDscrptn
   ,sbrnTypeCode
	)
	SELECT
		10
	   ,'Intake'
	   ,(
			SELECT
				srcnCodeID
			FROM sma_mst_subrolecode
			WHERE srcnRoleID = 10
				AND srcsDscrptn = 'Intake'
		)
	EXCEPT
	SELECT
		sbrnRoleID
	   ,sbrsDscrptn
	   ,sbrnTypeCode
	FROM sma_MST_SubRole
GO
------------------------------
--CASE STAFF - ADD AS INTAKE
------------------------------
-- [litify_pm__intake__c].[OwnerId]
INSERT INTO sma_TRN_caseStaff
	(
	[cssnCaseID]
   ,[cssnStaffID]
   ,[cssnRoleID]
   ,[csssComments]
   ,[cssdFromDate]
   ,[cssdToDate]
   ,[cssnRecUserID]
   ,[cssdDtCreated]
   ,[cssnModifyUserID]
   ,[cssdDtModified]
   ,[cssnLevelNo]
	)
	SELECT DISTINCT
		CAS.casnCaseID  AS [cssnCaseID]
	   ,u.usrnContactID AS [cssnStaffID]
	   ,(
			SELECT
				sbrnSubRoleId
			FROM sma_MST_SubRole
			WHERE sbrnRoleID = 10
				AND sbrsDscrptn = 'Intake'
		)				
		AS [cssnRoleID]
	   ,NULL			AS [csssComments]
	   ,NULL			AS cssdFromDate
	   ,NULL			AS cssdToDate
	   ,368				AS cssnRecUserID
	   ,GETDATE()		AS [cssdDtCreated]
	   ,NULL			AS [cssnModifyUserID]
	   ,NULL			AS [cssdDtModified]
	   ,0				AS cssnLevelNo
	--Select *
	FROM [sma_trn_cases] CAS
	JOIN [ShinerLitify]..[litify_pm__intake__c] m
		ON m.id = cas.saga_char
	JOIN [sma_MST_Users] u
		ON u.saga_char = m.OwnerId
GO

ALTER TABLE sma_TRN_caseStaff ENABLE TRIGGER ALL
GO