USE ShinerSA
GO

/*
select * from ShinerLitify..litify_pm__intake__c	--intake
where litify_pm__IsConverted__c <> 1		--not converted to matter
*/

---------------------------------------------------
--INSERT NEGLIGENCE CASE TYPE FOR UNKNOWN TYPES
---------------------------------------------------
INSERT INTO [sma_MST_CaseType]
	(
	[cstsCode]
   ,[cstsType]
   ,[cstsSubType]
   ,[cstnWorkflowTemplateID]
   ,[cstnExpectedResolutionDays]
   ,[cstnRecUserID]
   ,[cstdDtCreated]
   ,[cstnModifyUserID]
   ,[cstdDtModified]
   ,[cstnLevelNo]
   ,[cstbTimeTracking]
   ,[cstnGroupID]
   ,[cstnGovtMunType]
   ,[cstnIsMassTort]
   ,[cstnStatusID]
   ,[cstnStatusTypeID]
   ,[cstbActive]
   ,[cstbUseIncident1]
   ,[cstsIncidentLabel1]
   ,[VenderCaseType]
	)
	SELECT DISTINCT
		NULL			 AS cstsCode
	   ,'Negligence'	 AS cstsType
	   ,NULL			 AS cstsSubType
	   ,NULL			 AS cstnWorkflowTemplateID
	   ,720				 AS cstnExpectedResolutionDays
	   , -- ( Hardcode 2 years )
		368				 AS cstnRecUserID
	   ,GETDATE()		 AS cstdDtCreated
	   ,368				 AS cstnModifyUserID
	   ,GETDATE()		 AS cstdDtModified
	   ,0				 AS cstnLevelNo
	   ,NULL			 AS cstbTimeTracking
	   ,(
			SELECT
				cgpnCaseGroupID
			FROM sma_MST_caseGroup
			WHERE cgpsDscrptn = 'Litify'
		)				 
		AS cstnGroupID
	   ,NULL			 AS cstnGovtMunType
	   ,NULL			 AS cstnIsMassTort
	   ,(
			SELECT
				cssnStatusID
			FROM [sma_MST_CaseStatus]
			WHERE csssDescription = 'Presign - Not Scheduled For Sign Up'
		)				 
		AS cstnStatusID
	   ,(
			SELECT
				stpnStatusTypeID
			FROM [sma_MST_CaseStatusType]
			WHERE stpsStatusType = 'Status'
		)				 
		AS cstnStatusTypeID
	   ,1				 AS cstbActive
	   ,1				 AS cstbUseIncident1
	   ,'Incident 1'	 AS cstsIncidentLabel1
	   ,'LesserCaseType' AS VenderCaseType
	FROM [CaseTypeMap] MIX
	LEFT JOIN [sma_MST_CaseType] ct
		ON ct.cststype = 'Negligence'
	WHERE ct.cstncasetypeid IS NULL


UPDATE [sma_MST_CaseType]
SET VenderCaseType = 'LesserCaseType'
WHERE cstsType = 'Negligence'

---(2.1) sma_MST_CaseSubType
INSERT INTO [sma_MST_CaseSubType]
	(
	[cstsCode]
   ,[cstnGroupID]
   ,[cstsDscrptn]
   ,[cstnRecUserId]
   ,[cstdDtCreated]
   ,[cstnModifyUserID]
   ,[cstdDtModified]
   ,[cstnLevelNo]
   ,[cstbDefualt]
   ,[saga]
   ,[cstnTypeCode]
	)
	SELECT
		NULL		   AS [cstsCode]
	   ,cstncasetypeid AS [cstnGroupID]
	   ,'Unknown'	   AS [cstsDscrptn]
	   ,368			   AS [cstnRecUserId]
	   ,GETDATE()	   AS [cstdDtCreated]
	   ,NULL		   AS [cstnModifyUserID]
	   ,NULL		   AS [cstdDtModified]
	   ,NULL		   AS [cstnLevelNo]
	   ,1			   AS [cstbDefualt]
	   ,NULL		   AS [saga]
	   ,(
			SELECT
				stcnCodeId
			FROM [sma_MST_CaseSubTypeCode]
			WHERE stcsDscrptn = 'Unknown'
		)			   
		AS [cstnTypeCode]
	FROM [sma_MST_CaseType] CST
	LEFT JOIN [sma_MST_CaseSubType] sub
		ON sub.[cstnGroupID] = cstncasetypeid
			AND sub.[cstsDscrptn] = 'Unknown'
	WHERE sub.cstncasesubtypeID IS NULL
		AND cst.cstsType = 'Negligence'

------------------------------
--INTAKE CASES
------------------------------
ALTER TABLE [sma_TRN_Cases] DISABLE TRIGGER ALL
GO

INSERT INTO [sma_TRN_Cases]
	(
	[cassCaseNumber]
   ,[casbAppName]
   ,[cassCaseName]
   ,[casnCaseTypeID]
   ,[casnState]
   ,[casdStatusFromDt]
   ,[casnStatusValueID]
   ,[casdsubstatusfromdt]
   ,[casnSubStatusValueID]
   ,[casdOpeningDate]
   ,[casdClosingDate]
   ,[casnCaseValueID]
   ,[casnCaseValueFrom]
   ,[casnCaseValueTo]
   ,[casnCurrentCourt]
   ,[casnCurrentJudge]
   ,[casnCurrentMagistrate]
   ,[casnCaptionID]
   ,[cassCaptionText]
   ,[casbMainCase]
   ,[casbCaseOut]
   ,[casbSubOut]
   ,[casbWCOut]
   ,[casbPartialOut]
   ,[casbPartialSubOut]
   ,[casbPartiallySettled]
   ,[casbInHouse]
   ,[casbAutoTimer]
   ,[casdExpResolutionDate]
   ,[casdIncidentDate]
   ,[casnTotalLiability]
   ,[cassSharingCodeID]
   ,[casnStateID]
   ,[casnLastModifiedBy]
   ,[casdLastModifiedDate]
   ,[casnRecUserID]
   ,[casdDtCreated]
   ,[casnModifyUserID]
   ,[casdDtModified]
   ,[casnLevelNo]
   ,[cassCaseValueComments]
   ,[casbRefIn]
   ,[casbDelete]
   ,[casbIntaken]
   ,[casnOrgCaseTypeID]
   ,[CassCaption]
   ,[cassMdl]
   ,[office_id]
   ,[saga]
   ,[LIP]
   ,[casnSeriousInj]
   ,[casnCorpDefn]
   ,[casnWebImporter]
   ,[casnRecoveryClient]
   ,[cas]
   ,[ngage]
   ,[casnClientRecoveredDt]
   ,[CloseReason]
   ,Litify_saga
	)
	SELECT
		m.[name]					 AS cassCaseNumber
	   ,''							 AS casbAppName
	   ,m.litify_pm__Display_Name__c AS cassCaseName
	   ,(
			SELECT
				cstnCaseSubTypeID
			FROM [sma_MST_CaseSubType] ST
			WHERE ST.cstnGroupID = CST.cstnCaseTypeID
				AND ST.cstsDscrptn = ISNULL(MIX.[SmartAdvocate Case Sub Type], 'Unknown')
		)							 
		AS casnCaseTypeID
	   ,CASE
			WHEN ISNULL(m.litify_pm__Case_State__c, '') <> ''
				THEN (
						SELECT
							[sttnStateID]
						FROM [sma_MST_States]
						WHERE sttsCode = LEFT(m.litify_pm__Case_State__c, 2)
					)
			ELSE (
					SELECT
						[sttnStateID]
					FROM [sma_MST_States]
					WHERE [sttsDescription] = 'Florida'
				)
		END							 AS casnState
	   ,GETDATE()					 AS casdStatusFromDt
	   ,(
			SELECT
				cssnStatusID
			FROM [sma_MST_CaseStatus]
			WHERE csssDescription = 'Presign - Not Scheduled For Sign Up'
		)							 
		AS casnStatusValueID
	   ,GETDATE()					 AS casdsubstatusfromdt
	   ,(
			SELECT
				cssnStatusID
			FROM [sma_MST_CaseStatus]
			WHERE csssDescription = 'Presign - Not Scheduled For Sign Up'
		)							 
		AS casnSubStatusValueID
	   ,CASE
			WHEN (m.litify_pm__Open_Date__c NOT BETWEEN '1900-01-01' AND '2079-12-31')
				THEN GETDATE()
			ELSE m.litify_pm__Open_Date__c
		END							 
		AS casdOpeningDate
	   ,CASE
			WHEN (litify_pm__Turned_Down_Date__c NOT BETWEEN '1900-01-01' AND '2079-12-31')
				THEN GETDATE()
			ELSE m.litify_pm__Turned_Down_Date__c
		END							 
		AS casdClosingDate
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,0
	   ,litify_pm__Display_Name__c	 AS cassCaptionText
	   ,1
	   ,0
	   ,0
	   ,0
	   ,0
	   ,0
	   ,0
	   ,1
	   ,NULL
	   ,NULL
	   ,NULL
	   ,0
	   ,0
	   ,CASE
			WHEN ISNULL(m.litify_pm__Case_State__c, '') <> ''
				THEN (
						SELECT
							[sttnStateID]
						FROM [sma_MST_States]
						WHERE sttsCode = LEFT(m.litify_pm__Case_State__c, 2)
					)
			ELSE (
					SELECT
						[sttnStateID]
					FROM [sma_MST_States]
					WHERE [sttsDescription] = 'Florida'
				)
		END							 AS casnStateID
	   ,NULL
	   ,NULL
	   ,(
			SELECT
				usrnUserID
			FROM sma_MST_Users
			WHERE saga = m.CreatedById
		)							 
		AS casnRecUserID
	   ,CreatedDate					 AS casdDtCreated
	   ,NULL
	   ,NULL
	   ,''
	   ,''
	   ,NULL
	   ,NULL
	   ,NULL
	   ,cstnCaseTypeID				 AS casnOrgCaseTypeID
	   ,''							 AS CassCaption
	   ,0							 AS cassMdl
	   ,(
			SELECT
				office_id
			FROM sma_MST_Offices
			WHERE office_name = 'Lesser Lesser Landy and Smith PLLC'
		)							 
		AS office_id
	   ,NULL						 AS saga
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,0							 AS CloseReason
	   ,M.Id						 AS Litify_saga
	--select m.*
	FROM ShinerLitify..litify_pm__intake__c m
	LEFT JOIN caseTypeMap mix
		ON mix.LitifyCaseTypeID = m.litify_pm__Case_Type__c
	LEFT JOIN sma_MST_CaseType CST
		ON CST.cststype = ISNULL(mix.[smartadvocate Case Type], 'Negligence')
			AND VenderCaseType = 'LesserCaseType'
	WHERE litify_pm__IsConverted__c <> 1		--not converted to matter
GO
---
ALTER TABLE [sma_TRN_Cases] ENABLE TRIGGER ALL
GO
---

------------------------------------------------------------
--CASE STATUS
------------------------------------------------------------
---------
ALTER TABLE [sma_TRN_CaseStatus] DISABLE TRIGGER ALL
GO
---------

INSERT INTO [sma_TRN_CaseStatus]
	(
	[cssnCaseID]
   ,[cssnStatusTypeID]
   ,[cssnStatusID]
   ,[cssnExpDays]
   ,[cssdFromDate]
   ,[cssdToDt]
   ,[csssComments]
   ,[cssnRecUserID]
   ,[cssdDtCreated]
   ,[cssnModifyUserID]
   ,[cssdDtModified]
   ,[cssnLevelNo]
   ,[cssnDelFlag]
	)
	SELECT DISTINCT
		CAS.casnCaseID AS [cssnCaseID]
	   ,(
			SELECT
				stpnStatusTypeID
			FROM sma_MST_CaseStatusType
			WHERE stpsStatusType = 'Status'
		)			   
		AS [cssnStatusTypeID]
	   ,CASE
			WHEN litify_pm__Status__c = 'Closed'
				THEN (
						SELECT
							cssnStatusID
						FROM sma_MST_CaseStatus
						WHERE csssDescription = 'Closed Case'
					)
			WHEN litify_pm__Status__c IS NULL
				THEN (
						SELECT
							cssnStatusID
						FROM sma_MST_CaseStatus
						WHERE csssDescription = 'LIT 00 - Lawsuit Needed'
							AND cssnStatusTypeID = 1
					)
			ELSE (
					SELECT
						cssnStatusID
					FROM sma_MST_CaseStatus
					WHERE csssDescription = [litify_pm__Status__c]
						AND cssnStatusTypeID = 1
				)
		END			   AS [cssnStatusID]
	   ,''			   AS [cssnExpDays]
	   ,CASE
			WHEN litify_pm__Status__c = 'Closed'
				THEN m.litify_pm__Turned_Down_Date__c
			ELSE GETDATE()
		END			   AS [cssdFromDate]
	   ,NULL		   AS [cssdToDt]
	   ,
		--   isnull('Closed Reason: ' + nullif(convert(varchar,m.[litify_pm__Closed_Reason__c]),'') + CHAR(13),'') +
		--isnull('Closed Details: ' + nullif(convert(varchar,m.[litify_pm__Closed_Reason_Details__c]),'') + CHAR(13),'') +
		''			   AS [csssComments]
	   ,368			   AS [cssnRecUserID]
	   ,GETDATE()	   AS [cssdDtCreated]
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	FROM [sma_trn_cases] CAS
	JOIN ShinerLitify..[litify_pm__intake__c] m
		ON m.Id = CAS.Litify_saga
GO

--------
ALTER TABLE [sma_TRN_CaseStatus] ENABLE TRIGGER ALL
GO
--------


---(2)---
ALTER TABLE [sma_trn_cases] DISABLE TRIGGER ALL
GO
---------
UPDATE sma_trn_cases
SET casnStatusValueID = STA.cssnStatusID
FROM sma_TRN_CaseStatus STA
WHERE STA.cssnCaseID = casnCaseID

ALTER TABLE [sma_trn_cases] ENABLE TRIGGER ALL
GO

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
		ON m.id = cas.Litify_saga
	JOIN [sma_MST_Users] u
		ON u.saga = m.OwnerId
GO

ALTER TABLE sma_TRN_caseStaff ENABLE TRIGGER ALL
GO

--------------------------------------------------
--PLAINTIFFS
--------------------------------------------------
ALTER TABLE [sma_TRN_Plaintiff] DISABLE TRIGGER ALL
GO
INSERT INTO [sma_TRN_Plaintiff]
	(
	[plnnCaseID]
   ,[plnnContactCtg]
   ,[plnnContactID]
   ,[plnnAddressID]
   ,[plnnRole]
   ,[plnbIsPrimary]
   ,[plnbWCOut]
   ,[plnnPartiallySettled]
   ,[plnbSettled]
   ,[plnbOut]
   ,[plnbSubOut]
   ,[plnnSeatBeltUsed]
   ,[plnnCaseValueID]
   ,[plnnCaseValueFrom]
   ,[plnnCaseValueTo]
   ,[plnnPriority]
   ,[plnnDisbursmentWt]
   ,[plnbDocAttached]
   ,[plndFromDt]
   ,[plndToDt]
   ,[plnnRecUserID]
   ,[plndDtCreated]
   ,[plnnModifyUserID]
   ,[plndDtModified]
   ,[plnnLevelNo]
   ,[plnsMarked]
   ,[saga]
   ,[plnnNoInj]
   ,[plnnMissing]
   ,[plnnLIPBatchNo]
   ,[plnnPlaintiffRole]
   ,[plnnPlaintiffGroup]
   ,[plnnPrimaryContact]
   ,plnbIsClient
	)
	SELECT DISTINCT
		CAS.casnCaseID  AS [plnnCaseID]
	   ,CIO.CTG			AS [plnnContactCtg]
	   ,CIO.CID			AS [plnnContactID]
	   ,CIO.AID			AS [plnnAddressID]
	   ,S.sbrnSubRoleId AS [plnnRole]
	   ,1				AS [plnbIsPrimary]
	   ,0
	   ,0
	   ,0
	   ,0
	   ,0
	   ,0
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,GETDATE()
	   ,NULL
	   ,368				AS [plnnRecUserID]
	   ,GETDATE()		AS [plndDtCreated]
	   ,NULL
	   ,NULL
	   ,NULL			AS [plnnLevelNo]
	   ,NULL
	   ,''
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,1				AS [plnnPrimaryContact]
	   ,1				AS plnbIsClient
	FROM [ShinerLitify]..[litify_pm__intake__c] m
	JOIN [sma_TRN_cases] CAS
		ON CAS.Litify_saga = m.id
	JOIN [sma_MST_SubRole] S
		ON CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID
	JOIN IndvOrgContacts_Indexed CIO
		ON CIO.saga = m.litify_pm__Client__c
	WHERE s.sbrnRoleID = 4
		AND s.sbrsDscrptn = '(P)-Plaintiff'
GO
ALTER TABLE [sma_TRN_Plaintiff] ENABLE TRIGGER ALL
GO

------------------------------------
--INCIDENT
------------------------------------

ALTER TABLE [sma_TRN_Incidents] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Cases] DISABLE TRIGGER ALL
GO

INSERT INTO sma_trn_Incidents
	(
	[CaseId]
   ,[IncidentDate]
   ,[StateID]
   ,[LiabilityCodeId]
   ,[IncidentFacts]
   ,[MergedFacts]
   ,[Comments]
   ,[IncidentTime]
   ,[RecUserID]
   ,[DtCreated]
   ,[ModifyUserID]
   ,[DtModified]
	)
	SELECT
		cas.casnCaseID				AS caseid
	   ,litify_pm__Incident_date__c AS IncidentDate
	   ,CASE
			WHEN ISNULL(m.litify_pm__Case_State__c, '') <> ''
				THEN (
						SELECT
							[sttnStateID]
						FROM [sma_MST_States]
						WHERE sttsCode = LEFT(m.litify_pm__Case_State__c, 2)
					)
			ELSE (
					SELECT
						[sttnStateID]
					FROM [sma_MST_States]
					WHERE [sttsDescription] = 'Florida'
				)
		END							AS StateID
	   ,0							AS LiabilityCodeId
	   ,m.litify_pm__Description__c AS [IncidentFacts]
	   ,''							AS [MergedFacts]
	   ,''							AS [Comments]
	   ,NULL						AS [IncidentTime]
	   ,368							AS [RecUserID]
	   ,GETDATE()					AS [DtCreated]
	   ,NULL						AS [ModifyUserID]
	   ,NULL						AS [DtModified]
	FROM ShinerLitify..[litify_pm__intake__c] m
	JOIN sma_trn_Cases cas
		ON cas.Litify_saga = m.Id


UPDATE CAS
SET CAS.casdIncidentDate = INC.IncidentDate
   ,CAS.casnStateID = INC.StateID
   ,CAS.casnState = INC.StateID
FROM sma_trn_cases AS CAS
LEFT JOIN sma_TRN_Incidents AS INC
	ON casnCaseID = caseid
WHERE INC.CaseId = CAS.casncaseid

---
ALTER TABLE [sma_TRN_Incidents] ENABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Cases] ENABLE TRIGGER ALL
GO

----------------------------------
--INTAKE NOTE
----------------------------------
INSERT INTO [sma_TRN_Notes]
	(
	[notnCaseID]
   ,[notnNoteTypeID]
   ,[notmDescription]
   ,[notmPlainText]
   ,[notnContactCtgID]
   ,[notnContactId]
   ,[notsPriority]
   ,[notnFormID]
   ,[notnRecUserID]
   ,[notdDtCreated]
   ,[notnModifyUserID]
   ,[notdDtModified]
   ,[notnLevelNo]
   ,[notdDtInserted]
   ,[WorkPlanItemId]
   ,[notnSubject]
   ,SAGA
	)
	SELECT
		casnCaseID												   AS [notnCaseID]
	   ,(
			SELECT
				MIN(nttnNoteTypeID)
			FROM [sma_MST_NoteTypes]
			WHERE nttsDscrptn = 'Intake'
		)														   
		AS [notnNoteTypeID]
	   ,ISNULL('Start Date: ' + NULLIF(CONVERT(VARCHAR(MAX), n.litify_pm__Questionnaire_Start_Date__c), '') + CHAR(13), '') +
		ISNULL('End Date: ' + NULLIF(CONVERT(VARCHAR(MAX), n.litify_pm__Questionnaire_End_Date__c), '') + CHAR(13), '') +
		ISNULL('Last Modified Date: ' + NULLIF(CONVERT(VARCHAR(MAX), n.litify_pm__Questionnaire_Last_Modified__c), '') + CHAR(13), '') +
		''														   AS [notmDescription]
	   ,CONVERT(VARCHAR(MAX), litify_pm__Questions_and_answers__c) AS [notmPlainText]
	   ,0														   AS [notnContactCtgID]
	   ,NULL													   AS [notnContactId]
	   ,NULL													   AS [notsPriority]
	   ,NULL													   AS [notnFormID]
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_users
			WHERE saga = n.CreatedById
		)														   
		AS [notnRecUserID]
	   ,n.CreatedDate											   AS notdDtCreated
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_users
			WHERE saga = n.LastModifiedById
		)														   
		AS [notnModifyUserID]
	   ,n.LastModifiedDate										   AS notdDtModified
	   ,NULL													   AS [notnLevelNo]
	   ,NULL													   AS [notdDtInserted]
	   ,NULL													   AS [WorkPlanItemId]
	   ,n.[name]												   AS [notnSubject]
	   ,n.Id													   AS SAGA
	--select *
	FROM [ShinerLitify]..[litify_pm__intake__c] N
	JOIN [sma_TRN_Cases] C
		ON C.Litify_saga = n.id
	WHERE ISNULL(litify_pm__Questionnaire_Start_Date__c, '') <> ''
		OR ISNULL(litify_pm__Questionnaire_End_Date__c, '') <> ''
		OR ISNULL(CONVERT(VARCHAR(MAX), litify_pm__Questions_and_answers__c), '') <> ''