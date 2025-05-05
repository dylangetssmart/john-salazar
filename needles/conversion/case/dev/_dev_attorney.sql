/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create users and contacts

replace:
'OfficeName'
'StateDescription'
'VenderCaseType'
##########################################################################################################################
*/

USE [[JohnSalazar_SA]]
GO
/*
alter table [sma_TRN_PlaintiffAttorney] disable trigger all
delete from [sma_TRN_PlaintiffAttorney] 
DBCC CHECKIDENT ('[sma_TRN_PlaintiffAttorney]', RESEED, 0);
alter table [sma_TRN_PlaintiffAttorney] enable trigger all

alter table [sma_TRN_LawFirms] disable trigger all
delete from [sma_TRN_LawFirms] 
DBCC CHECKIDENT ('[sma_TRN_LawFirms]', RESEED, 0);
alter table [sma_TRN_LawFirms] enable trigger all

alter table [sma_TRN_LawFirmAttorneys] disable trigger all
delete from [sma_TRN_LawFirmAttorneys] 
DBCC CHECKIDENT ('[sma_TRN_LawFirmAttorneys]', RESEED, 0);
alter table [sma_TRN_LawFirmAttorneys] enable trigger all
*/

/*
-----------------------------------------------------------------------------------
--INSERT ATTORNEY TYPES
-----------------------------------------------------------------------------------
INSERT INTO sma_MST_AttorneyTypes (atnsAtorneyDscrptn)
SELECT Distinct Type_OF_Attorney From [JohnSalazar_Needles]..user_counsel_data where isnull(Type_of_attorney,'')<>''
EXCEPT
SELECT atnsAtorneydscrptn from sma_MST_AttorneyTypes
*/

---
ALTER TABLE [sma_TRN_PlaintiffAttorney] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_LawFirms] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_LawFirmAttorneys] DISABLE TRIGGER ALL
GO
---
--------------------------------------
--PLAINTIFF ATTONEYS
--------------------------------------


/*



*/


INSERT INTO [sma_TRN_PlaintiffAttorney]
	(
	[planPlaintffID], [planCaseID], [planPlCtgID], [planPlContactID], [planLawfrmAddID], [planLawfrmContactID], [planAtorneyAddID], [planAtorneyContactID], [planAtnTypeID], [plasFileNo], [planRecUserID], [pladDtCreated], [planModifyUserID], [pladDtModified], [planLevelNo], [planRefOutID], [plasComments]
	)
	SELECT DISTINCT
		T.plnnPlaintiffID AS [planPlaintffID]
	   ,CAS.casnCaseID	  AS [planCaseID]
	   ,T.plnnContactCtg  AS [planPlCtgID]
	   ,T.plnnContactID	  AS [planPlContactID]
	   ,CASE
			WHEN IOC.CTG = 2
				THEN IOC.AID
			ELSE NULL
		END				  AS [planLawfrmAddID]
	   ,CASE
			WHEN IOC.CTG = 2
				THEN IOC.CID
			ELSE NULL
		END				  AS [planLawfrmContactID]
	   ,CASE
			WHEN IOC.CTG = 1
				THEN IOC.AID
			ELSE NULL
		END				  AS [planAtorneyAddID]
	   ,CASE
			WHEN IOC.CTG = 1
				THEN IOC.CID
			ELSE NULL
		END				  AS [planAtorneyContactID]
	   ,(
			SELECT
				atnnAtorneyTypeID
			FROM sma_MST_AttorneyTypes
			WHERE atnsAtorneyDscrptn = 'Plaintiff Attorney'
		)				  
		AS [planAtnTypeID]
	   ,NULL			  AS [plasFileNo]
	   , --	 UD.Their_File_Number
		368				  AS [planRecUserID]
	   ,GETDATE()		  AS [pladDtCreated]
	   ,NULL			  AS [planModifyUserID]
	   ,NULL			  AS [pladDtModified]
	   ,0				  AS [planLevelNo]
	   ,NULL			  AS [planRefOutID]
	   ,ISNULL('comments : ' + NULLIF(CONVERT(VARCHAR(MAX), C.comments), '') + CHAR(13), '') +
		ISNULL('Attorney for party : ' + NULLIF(CONVERT(VARCHAR(MAX), IOCP.name), '') + CHAR(13), '') +
		''				  AS [plasComments]
	FROM [JohnSalazar_Needles]..[counsel_Indexed] C
	LEFT JOIN [JohnSalazar_Needles].[dbo].[user_counsel_data] UD
		ON UD.counsel_id = C.counsel_id
			AND C.case_num = UD.casenum
	JOIN [sma_TRN_Cases] CAS
		ON CAS.cassCaseNumber = C.case_num
	JOIN IndvOrgContacts_Indexed IOC
		ON IOC.SAGA = C.counsel_id
			AND ISNULL(C.counsel_id, 0) <> 0
	JOIN IndvOrgContacts_Indexed IOCP
		ON IOCP.SAGA = C.party_id
			AND ISNULL(C.party_id, 0) <> 0
	JOIN [sma_TRN_Plaintiff] T
		ON T.plnnContactID = IOCP.CID
			AND T.plnnContactCtg = IOCP.CTG
			AND T.plnnCaseID = CAS.casnCaseID
GO

--------------------------------------
--DEFENSE ATTORNEYS
--------------------------------------
INSERT INTO [sma_TRN_LawFirms]
	(
	[lwfnLawFirmContactID], [lwfnLawFirmAddressID], [lwfnAttorneyContactID], [lwfnAttorneyAddressID], [lwfnAttorneyTypeID], [lwfsFileNumber], [lwfnRoleType], [lwfnContactID], [lwfnRecUserID], [lwfdDtCreated], [lwfnModifyUserID], [lwfdDtModified], [lwfnLevelNo], [lwfnAdjusterID], [lwfsComments]
	)
	SELECT DISTINCT
		CASE
			WHEN IOC.CTG = 2
				THEN IOC.CID
			ELSE NULL
		END				  AS [lwfnLawFirmContactID]
	   ,CASE
			WHEN IOC.CTG = 2
				THEN IOC.AID
			ELSE NULL
		END				  AS [lwfnLawFirmAddressID]
	   ,CASE
			WHEN IOC.CTG = 1
				THEN IOC.CID
			ELSE NULL
		END				  AS [lwfnAttorneyContactID]
	   ,CASE
			WHEN IOC.CTG = 1
				THEN IOC.AID
			ELSE NULL
		END				  AS [lwfnAttorneyAddressID]
	   ,(
			SELECT
				atnnAtorneyTypeID
			FROM [sma_MST_AttorneyTypes]
			WHERE atnsAtorneyDscrptn = 'Defense Attorney'
		)				  
		AS [lwfnAttorneyTypeID]
	   ,NULL			  AS [lwfsFileNumber]
	   ,2				  AS [lwfnRoleType]
	   ,D.defnDefendentID AS [lwfnContactID]
	   ,368				  AS [lwfnRecUserID]
	   ,GETDATE()		  AS [lwfdDtCreated]
	   ,CAS.casnCaseID	  AS [lwfnModifyUserID]
	   ,GETDATE()		  AS [lwfdDtModified]
	   ,NULL			  AS [lwfnLevelNo]
	   ,NULL			  AS [lwfnAdjusterID]
	   ,ISNULL('comments : ' + NULLIF(CONVERT(VARCHAR(MAX), C.comments), '') + CHAR(13), '') +
		ISNULL('Attorney for party : ' + NULLIF(CONVERT(VARCHAR(MAX), IOCD.name), '') + CHAR(13), '') +
		''				  AS [lwfsComments]
	FROM [JohnSalazar_Needles].[dbo].[counsel_Indexed] C
	LEFT JOIN [JohnSalazar_Needles].[dbo].[user_counsel_data] UD
		ON UD.counsel_id = C.counsel_id
			AND C.case_num = UD.casenum
	JOIN [sma_TRN_Cases] CAS
		ON CAS.cassCaseNumber = C.case_num
	JOIN IndvOrgContacts_Indexed IOC
		ON IOC.SAGA = C.counsel_id
			AND ISNULL(C.counsel_id, 0) <> 0
	JOIN IndvOrgContacts_Indexed IOCD
		ON IOCD.SAGA = C.party_id
			AND ISNULL(C.party_id, 0) <> 0
	JOIN [sma_TRN_Defendants] D
		ON D.defnContactID = IOCD.CID
			AND D.defnContactCtgID = IOCD.CTG
			AND D.defnCaseID = CAS.casnCaseID
GO


----(3)---- Plaintiff Attorney list
INSERT INTO sma_TRN_LawFirmAttorneys
	(
	SourceTableRowID, UniqueContactID, IsDefendant, IsPrimary
	)
	SELECT
		A.LawFirmID			AS SourceTableRowID
	   ,A.AttorneyContactID AS UniqueAontactID
	   ,0					AS IsDefendant
	   , --0:Plaintiff
		CASE
			WHEN A.SequenceNumber = 1
				THEN 1
			ELSE 0
		END					AS IsPrimary
	FROM (
		SELECT
			F.planAtnID AS LawFirmID
		   ,AC.UniqueContactId AS AttorneyContactID
		   ,ROW_NUMBER() OVER (PARTITION BY F.planCaseID ORDER BY F.planAtnID) AS SequenceNumber
		FROM [sma_TRN_PlaintiffAttorney] F
		LEFT JOIN sma_MST_AllContactInfo AC
			ON AC.ContactCtg = 1
			AND AC.ContactId = F.planAtorneyContactID
	) A
	WHERE A.AttorneyContactID IS NOT NULL
GO


----(4)---- Defense Attorney list
INSERT INTO sma_TRN_LawFirmAttorneys
	(
	SourceTableRowID, UniqueContactID, IsDefendant, IsPrimary
	)
	SELECT
		A.LawFirmID			AS SourceTableRowID
	   ,A.AttorneyContactID AS UniqueAontactID
	   ,1					AS IsDefendant
	   ,CASE
			WHEN A.SequenceNumber = 1
				THEN 1
			ELSE 0
		END					AS IsPrimary
	FROM (
		SELECT
			F.lwfnLawFirmID AS LawFirmID
		   ,AC.UniqueContactId AS AttorneyContactID
		   ,ROW_NUMBER() OVER (PARTITION BY F.lwfnModifyUserID ORDER BY F.lwfnLawFirmID) AS SequenceNumber
		FROM [sma_TRN_LawFirms] F
		LEFT JOIN sma_MST_AllContactInfo AC
			ON AC.ContactCtg = 1
			AND AC.ContactId = F.lwfnAttorneyContactID
	) A
	WHERE A.AttorneyContactID IS NOT NULL
GO


---(Appendix)----
UPDATE sma_MST_IndvContacts
SET cinnContactTypeID = (
	SELECT
		octnOrigContactTypeID
	FROM [sma_MST_OriginalContactTypes]
	WHERE octsDscrptn = 'Attorney'
		AND octnContactCtgID = 1
)
FROM (
	SELECT
		I.cinnContactID AS ID
	FROM [JohnSalazar_Needles].[dbo].[counsel] C
	JOIN [JohnSalazar_Needles].[dbo].[names] L
		ON C.counsel_id = L.names_id
	JOIN [dbo].[sma_MST_IndvContacts] I
		ON saga = L.names_id
	WHERE L.person = 'Y'
) A
WHERE cinnContactID = A.ID
GO
---
ALTER TABLE [sma_TRN_PlaintiffAttorney] ENABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_LawFirms] ENABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_LawFirmAttorneys] ENABLE TRIGGER ALL
GO
---

