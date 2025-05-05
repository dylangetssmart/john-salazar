/* #######################################################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-10-16
Description: Create All Contact records

- Contacts already exist.
- [sma_MST_OtherCasesContact]

litify_pm__Role__c > Account > Contact

https://smartadvocate.atlassian.net/wiki/spaces/Conversion/pages/edit-v2/2437283877#Contacts

##########################################################################################################################
*/

----------------------------------------------------------------------------
--select a.id, a.name, lprc.litify_pm__Role__c
--FROM ShinerLitify..litify_pm__Role__c lprc
--join ShinerLitify..Account a
--ON lprc.litify_pm__Party__c = a.Id
--WHERE lprc.litify_pm__Role__c = 'Family Member'

--select * FROM ShinerSA..IndvOrgContacts_Indexed ioci WHERE saga = '0018Z00002rgKZ6QAM'

--SELECT * FROM ShinerLitify..Contact c

----------------------------------------------------------------------------

use ShinerSA
go

/* ####################################
1.0 -- Add Contact to case
*/

alter table [sma_MST_OtherCasesContact] disable trigger all
GO

INSERT INTO [sma_MST_OtherCasesContact]
	(
	[OtherCasesID]
   ,[OtherCasesContactID]
   ,[OtherCasesContactCtgID]
   ,[OtherCaseContactAddressID]
   ,[OtherCasesContactRole]
   ,[OtherCasesCreatedUserID]
   ,[OtherCasesContactCreatedDt]
   ,[OtherCasesModifyUserID]
   ,[OtherCasesContactModifieddt]
	)
	SELECT
		cas.casnCaseID				 AS [OtherCasesID]
	   ,ioc.CID						 AS [OtherCasesContactID]
	   ,ioc.CTG						 AS [OtherCasesContactCtgID]
	   ,ioc.AID						 AS [OtherCaseContactAddressID]
	   ,lprc.litify_pm__Role__c AS [OtherCasesContactRole]
	   ,368							 AS [OtherCasesCreatedUserID]
	   ,GETDATE()					 AS [OtherCasesContactCreatedDt]
	   ,NULL						 AS [OtherCasesModifyUserID]
	   ,NULL						 AS [OtherCasesContactModifieddt]
	FROM ShinerLitify..litify_pm__Role__c lprc
	-- Link to contact card
	JOIN ShinerLitify..Account a
		ON lprc.litify_pm__Party__c = a.Id
	JOIN ShinerSA..IndvOrgContacts_Indexed ioc
		ON saga_char = a.Id
	-- Link to case
	JOIN ShinerSA..sma_TRN_Cases cas
		ON cas.saga_char = lprc.litify_pm__Matter__c
	where isnull(lprc.litify_pm__Role__c, '') IN ('Other', 'Family Member')
GO

alter table [sma_MST_OtherCasesContact] enable trigger all
GO

/* ####################################
2.0 -- Add comment
*/
                
-- INSERT INTO [sma_TRN_CaseContactComment]
-- (
-- 	[CaseContactCaseID]
-- 	,[CaseRelContactID]
-- 	,[CaseRelContactCtgID]
-- 	,[CaseContactComment]
-- 	,[CaseContactCreaatedBy]
-- 	,[CaseContactCreateddt]
-- 	,[caseContactModifyBy]
-- 	,[CaseContactModifiedDt]
-- )
-- SELECT
-- 	cas.casnCaseID	as [CaseContactCaseID]
-- 	,ioc.CID		as [CaseRelContactID]
-- 	,ioc.CTG		as [CaseRelContactCtgID]
-- 	,isnull(('Spouse: '+ nullif(convert(varchar(max),ud.spouse),'')+char(13)),'') +
-- 	isnull(('Alternate Contact: '+ nullif(convert(varchar(max),ud.Alternate_Contact),'')+char(13)),'') +
-- 	isnull(('Contact Relationship: '+ nullif(convert(varchar(max),ud.Contact_Relationship),'')+char(13)),'') +
-- 	''				as [CaseContactComment]
-- 	,368			as [CaseContactCreaatedBy]
-- 	,getdate()		as [CaseContactCreateddt]
-- 	,null			as [caseContactModifyBy]
-- 	,null			as [CaseContactModifiedDt]
-- FROM TestNeedles.[dbo].user_party_data ud
-- join sma_TRN_Cases cas
-- 	on cas.cassCaseNumber = ud.case_id
-- join TestNeedles..names n
-- 	on n.names_id = ud.party_id
-- join IndvOrgContacts_Indexed ioc
-- 	on ioc.SAGA = n.names_id
-- where isnull(ud.Spouse,'') <> '' or isnull(ud.Alternate_Contact,'') <> '' or isnull(ud.Contact_Relationship,'') <> ''