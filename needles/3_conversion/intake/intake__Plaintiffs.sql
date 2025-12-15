USE [SA]
GO

--Plaintiffs
/*
select name_id, first_name, last_name, name_id_2, First_Name_Party_2, Last_Name_Party_2
From [Needles]..case_intake
where isnull(name_id,0)<>0
*/

--INSERT (P)-PLAINTIFF FOR CASE TYPES
INSERT INTO sma_MST_SubRole
	(
	sbrnRoleID, sbrsDscrptn, sbrnCaseTypeID, sbrnTypeCode
	)
	SELECT
		4
	   ,'(P)-Plaintiff'
	   ,cst.cstnCaseTypeID
	   ,(
			SELECT
				srcnCodeId
			FROM sma_MST_SubRoleCode
			WHERE srcsDscrptn = '(P)-Plaintiff'
				AND srcnRoleID = 4
		)
	FROM sma_MST_CaseType cst
	JOIN sma_trn_cases cas
		ON cas.casnOrgCaseTypeID = cst.cstnCaseTypeID
	WHERE cas.cassCaseNumber LIKE 'Intake%'
	EXCEPT
	SELECT
		sbrnRoleID
	   ,sbrsDscrptn
	   ,sbrnCaseTypeID
	   ,sbrnTypeCode
	FROM sma_MST_SubRole


-----------------------
--INSERT PLAINTIFF
-----------------------
INSERT INTO [sma_TRN_Plaintiff]
	(
	[plnnCaseID], [plnnContactCtg], [plnnContactID], [plnnAddressID], [plnnRole], [plnbIsPrimary], [plnbWCOut], [plnnPartiallySettled], [plnbSettled], [plnbOut], [plnbSubOut], [plnnSeatBeltUsed], [plnnCaseValueID], [plnnCaseValueFrom], [plnnCaseValueTo], [plnnPriority], [plnnDisbursmentWt], [plnbDocAttached], [plndFromDt], [plndToDt], [plnnRecUserID], [plndDtCreated], [plnnModifyUserID], [plndDtModified], [plnnLevelNo], [plnsMarked], [saga], [plnnNoInj], [plnnMissing], [plnnLIPBatchNo], [plnnPlaintiffRole], [plnnPlaintiffGroup], [plnnPrimaryContact], [saga_party]
	)
	SELECT DISTINCT
		CAS.casnCaseID AS [plnnCaseID]
	   ,CIO.CTG		   AS [plnnContactCtg]
	   ,CIO.CID		   AS [plnnContactID]
	   ,CIO.AID		   AS [plnnAddressID]
	   ,(
			SELECT TOP 1
				sbrnSubRoleId
			FROM [sma_MST_SubRole]
			WHERE sbrnCaseTypeID = CAS.casnOrgCaseTypeID
				AND sbrnRoleID = 4
				AND sbrsDscrptn = '(P)-Plaintiff'
		)			   
		AS [plnnRole]
	   ,1			   AS [plnbIsPrimary]
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
	   ,368			   AS [plnnRecUserID]
	   ,GETDATE()	   AS [plndDtCreated]
	   ,NULL
	   ,NULL
	   ,NULL		   AS [plnnLevelNo]
	   ,NULL
	   ,''
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,1			   AS [plnnPrimaryContact]
	   ,NULL		   AS [saga_party]
	--select *
	FROM [Needles]..case_intake c
	JOIN [sma_TRN_Cases] CAS
		ON CAS.saga = c.ROW_ID
	JOIN IndvOrgContacts_Indexed CIO
		ON CIO.SAGA = c.name_id
	WHERE ISNULL(name_id, 0) <> 0
		AND cas.cassCaseNumber LIKE 'Intake%'



