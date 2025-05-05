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

delete [sma_TRN_Negotiations]
DBCC CHECKIDENT ('[sma_TRN_Negotiations]', RESEED, 1);
alter table [sma_TRN_Negotiations] enable trigger all

alter table [sma_TRN_Settlements] disable trigger all
delete [sma_TRN_Settlements]
DBCC CHECKIDENT ('[sma_TRN_Settlements]', RESEED, 1);

*/

--(0)--

ALTER TABLE [sma_TRN_Negotiations] DISABLE TRIGGER ALL

IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'SettlementAmount'
			AND object_id = OBJECT_ID(N'sma_TRN_Negotiations')
	)
BEGIN
	ALTER TABLE sma_TRN_Negotiations
	ADD SettlementAmount DECIMAL(18, 2) NULL
END
GO

--(1)--
INSERT INTO [sma_TRN_Negotiations]
	(
	[negnCaseID], [negsUniquePartyID], [negdDate], [negnStaffID], [negnPlaintiffID], [negbPartiallySettled], [negnClientAuthAmt], [negbOralConsent], [negdOralDtSent], [negdOralDtRcvd], [negnDemand], [negnOffer], [negbConsentType], [negnRecUserID], [negdDtCreated], [negnModifyUserID], [negdDtModified], [negnLevelNo], [negsComments], [SettlementAmount]
	)
	SELECT
		CAS.casnCaseID AS [negnCaseID]
	   ,('I' + CONVERT(VARCHAR, (
			SELECT TOP 1
				incnInsCovgID
			FROM [sma_TRN_InsuranceCoverage] INC
			WHERE INC.incnCaseID = CAS.casnCaseID
				AND INC.saga = INS.insurance_id
				AND INC.incnInsContactID = (
					SELECT TOP 1
						connContactID
					FROM [sma_MST_OrgContacts]
					WHERE saga = INS.insurer_id
				)
		)
		))			   
		AS [negsUniquePartyID]
	   ,CASE
			WHEN NEG.neg_date BETWEEN '1900-01-01' AND '2079-12-31'
				THEN NEG.neg_date
			ELSE NULL
		END			   AS [negdDate]
	   ,(
			SELECT
				usrnContactiD
			FROM sma_MST_Users
			WHERE source_id = NEG.staff
		)			   
		AS [negnStaffID]
	   ,-1			   AS [negnPlaintiffID]
	   ,NULL		   AS [negbPartiallySettled]
	   ,CASE
			WHEN NEG.kind = 'Client Auth.'
				THEN NEG.amount
			ELSE NULL
		END			   AS [negnClientAuthAmt]
	   ,NULL		   AS [negbOralConsent]
	   ,NULL		   AS [negdOralDtSent]
	   ,NULL		   AS [negdOralDtRcvd]
	   ,CASE
			WHEN NEG.kind = 'Demand'
				THEN NEG.amount
			ELSE NULL
		END			   AS [negnDemand]
	   ,CASE
			WHEN NEG.kind IN ('Offer', 'Conditional Ofr')
				THEN NEG.amount
			ELSE NULL
		END			   AS [negnOffer]
	   ,NULL		   AS [negbConsentType]
	   ,368
	   ,GETDATE()
	   ,368
	   ,GETDATE()
	   ,0			   AS [negnLevelNo]
	   ,ISNULL(NEG.kind + ' : ' + NULLIF(CONVERT(VARCHAR, NEG.amount), '') + CHAR(13) + CHAR(10), '') +
		NEG.notes	   AS [negsComments]
	   ,CASE
			WHEN NEG.kind = 'Settled'
				THEN NEG.amount
			ELSE NULL
		END			   AS [SettlementAmount]
	FROM [JohnSalazar_Needles].[dbo].[negotiation] NEG
	LEFT JOIN [JohnSalazar_Needles].[dbo].[insurance_Indexed] INS
		ON INS.insurance_id = NEG.insurance_id
	JOIN [sma_TRN_cases] CAS
		ON CAS.cassCaseNumber = NEG.case_id
	LEFT JOIN [[JohnSalazar_SA]].[conversion].[Insurance_Contacts_Helper] MAP
		ON INS.insurance_id = MAP.insurance_id

-----------------
/*

INSERT INTO [sma_TRN_Settlements]
(
    stlnSetAmt,
    stlnStaffID,
    stlnPlaintiffID,
    stlsUniquePartyID,
    stlnCaseID,
    stlnNegotID
)
SELECT 
    SettlementAmount    as stlnSetAmt,
    negnStaffID			as stlnStaffID,
	negnPlaintiffID		as stlnPlaintiffID,
    negsUniquePartyID   as stlsUniquePartyID,
    negnCaseID		    as stlnCaseID,
    negnID				as stlnNegotID
FROM [sma_TRN_Negotiations]
WHERE isnull(SettlementAmount ,0) > 0

*/

ALTER TABLE [sma_TRN_Settlements] ENABLE TRIGGER ALL