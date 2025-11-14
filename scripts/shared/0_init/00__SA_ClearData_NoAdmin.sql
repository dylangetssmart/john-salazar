


/****************************************************************
 * CLEAR OUT DATA FROM MST TABLES THAT HOLD CASE DATA
 *		sma_MST_OtherCasesContact
 *		sma_MST_RestrictedUsers 
 *			(IF there are no associated contacts from Refer out Rules Firm ID)
 *		sma_MST_ContactJudgeMagistrate
 *		sma_MST_RelContacts
 ****************************************************************/
/*
select t.name, c.name
from sys.objects t
JOIN sys.columns c on c.object_id = t.object_id
where t.type='u'
and t.name like '%_mst_%'
and (c.name like '%CaseID%' or c.name like '%casesID%')
*/

truncate table sma_MST_OtherCasesContact	--need to truncate before truncating trn_Cases 
truncate table sma_MST_RestrictedUsers
truncate table sma_MST_ContactJudgeMagistrate
truncate table sma_TRN_TaskNew				--need to truncate before truncating trn_Notes
truncate table sma_trn_caseJudgeorClerk		--need to truncate before CourtDocket

--DO NOT DELETE ANY RELATED CONTACTS IF FIRMID IS LISTED IN REFER OUT RULES
DELETE FROM sma_MST_RelContacts 
WHERE cast(rlcnPrimaryCtgID as varchar(20)) + cast(rlcnPrimaryContactID as varchar(20)) NOT IN (select '2'+ cast(RefOutFirmID as varchar(20)) From sma_mst_ReferOutRules) 
and cast(rlcnRelCtgID as varchar(20)) + cast(rlcnRelContactID as varchar(20)) NOT IN (select '2'+ cast(RefOutFirmID as varchar(20)) From sma_mst_ReferOutRules) 
GO

----------------------------------------------------------------
--CLEAR TRN TABLE DATA - EXCEPT FOR TRN ADMIN TABLES
----------------------------------------------------------------
DECLARE @Name varchar(1000)
DECLARE @SQL varchar(2000)
DECLARE @isIdent bit

DECLARE trnasactiontable_Cursor CURSOR FAST_FORWARD FOR
SELECT t.name AS TABLE_NAME, is_identity
FROM sys.tables AS t
LEFT JOIN sys.columns AS c
    ON t.object_id = c.object_id AND c.is_identity = 1
WHERE t.[type] ='u' 
	and t.name like '%trn_%' 
	and t.name NOT LIKE '%_trn_Automat%'
	and t.name NOT IN ('sma_TRN_ViewTemplatePages', 'sma_TRN_WebDashboards', 'sma_TRN_AutomatedRuleGroups','sma_TRN_BirdeyeCaseExclusions','sma_TRN_CallRouting',
		'sma_TRN_CallRoutingMapping', 'sma_trn_GenerateCasePattern', 'sma_TRN_CaseRetainerTemplates', 'sma_TRN_CaseWizardConfiguration', 'sma_TRN_CustomLabelsConfiguration',
		'sma_TRN_DefaultRetainerFee_Settings', 'sma_TRN_DocumentTypeExtension', 'sma_TRN_EmailsForMonitoring', 'sma_TRN_Office_Account', 'sma_TRN_FirstNameAliases',
		'sma_TRN_FundingIntegrations', 'sma_TRN_GridLayoutUsersUsedAsDefault', 'sma_TRN_Saml2IdentityProviderCertificates', 'sma_TRN_Saml2IdentityProviders',
		'sma_TRN_CaseWizardConfiguration', 'sma_TRN_ExpertSpecialtySubSpecialty', 'sma_TRN_PrimaryConsultAttorneys', 'sma_TRN_QBO_DistrAccountMapping',
		'sma_TRN_QBO_SettlAccountMapping', 'sma_TRN_QBO_DisbursementStatusMapping', 'sma_TRN_QBO_CompanyOfficeRelations', 'sma_TRN_RingCentralUsers','sma_TRN_InterestList',
		'sma_TRN_InterestRates','sma_TRN_SettlementTaxPercents', 'sma_TRN_SharedFavoritesLinks', 'sma_TRN_WebDashboards', 'sma_TRN_AutomaticTextActions', 
		'sma_TRN_Saml2UserIdentityMapping', 'sma_TRN_RateGroups', 'sma_TRN_RateGroupVersions', 'sma_TRN_RetainerStaff', 'sma_TRN_CaseStagesStatus', 'sma_TRN_DueTerm',
		'sma_trn_Cases' )--truncate cases later
Order by t.[name]

--Open a cursor
OPEN trnasactiontable_Cursor 

FETCH NEXT FROM trnasactiontable_Cursor INTO @Name, @isIdent

WHILE @@FETCH_STATUS = 0
BEGIN
 
	select @SQL=case when @isIdent = 1 then 'alter table dbo.'+@Name+' disable trigger all 
			delete from dbo.'+@Name+' DBCC CHECKIDENT ('''+@Name+''', RESEED, 0);
			alter table dbo.'+@name+ ' enable trigger all'
			else 'truncate table '+@Name end
	--print @sql
	 EXEC(@SQL)

	--PRINT @name

FETCH NEXT FROM trnasactiontable_Cursor INTO @Name, @isIdent
END

CLOSE trnasactiontable_Cursor
DEALLOCATE trnasactiontable_Cursor


/**************************************************************
 * REMOVE CONTACT CARDS EXCEPT FOR CONTACTS REFERENCED IN:
 *		sma_mst_users
 *		sma_mst_firminfo
 *		sma_mst_offices
 *		CP_Tokens
 *		sma_MST_AdvertisementCampaignGroupContacts
 *		sma_mst_ContactTypesForContact
 *		sma_MST_ReferOutEmailContacts
 *		sma_MST_ReferOutRules (firm id)
 **************************************************************/

alter table sma_mst_address disable trigger all 
go
alter table sma_MST_ContactNumbers disable trigger all 
go
alter table sma_MST_EmailWebsite disable trigger all 
go
alter table sma_MST_IndvContacts disable trigger all 
go
alter table sma_MST_OrgContacts disable trigger all 
go
---------------------
--INDV CONTACTS
---------------------
DELETE FROM sma_mst_address where addnContactCtgID=1 
			and addnContactID in (select cinnContactID from sma_MST_IndvContacts where cinnContactID not in (select usrncontactid from sma_mst_users) 
																						and cinnContactID not in (8,9)
																						and '1'+cast(cinncontactid as varchar(20)) not in (select frinUniqueContactId from sma_MST_FirmInfo where frinUniqueContactId IS NOT NULL)
																						and '1'+cast(cinncontactid as varchar(20)) NOT IN (select UniqueContactId from sma_mst_offices where UniqueContactId IS NOT NULL)	
																						and '1'+cast(cinncontactid as varchar(20)) NOT IN (select originalContactID from CP_Tokens where originalContactID IS NOT NULL) 
																						and '1'+cast(cinncontactid as varchar(20)) NOT IN (select cast(contactCtgID as varchar(20))+cast(contactID as varchar(20)) from sma_MST_ReferOutEmailContacts where contactID IS NOT NULL) 
																						and '1'+cast(cinncontactid as varchar(20)) NOT IN (select cast(rlcnPrimaryCtgID as varchar(20)) + cast(rlcnPrimaryContactID as varchar(20)) from sma_MST_RelContacts where rlcnPrimaryContactID IS NOT NULL)
																						and '1'+cast(cinncontactid as varchar(20)) NOT IN (select cast(rlcnRelCtgID as varchar(20)) + cast(rlcnRelContactID as varchar(20)) from sma_MST_RelContacts where rlcnRelContactID IS NOT NULL) )
DELETE FROM sma_MST_ContactNumbers where cnnnContactCtgID=1 
			and cnnnContactID in (select cinnContactID from sma_MST_IndvContacts where cinnContactID not in (select usrncontactid from sma_mst_users) 
																						and cinnContactID not in (8,9)
																						and '1'+cast(cinncontactid as varchar(20)) not in (select frinUniqueContactId from sma_MST_FirmInfo where frinUniqueContactId IS NOT NULL)
																						and '1'+cast(cinncontactid as varchar(20)) NOT IN (select UniqueContactId from sma_mst_offices where UniqueContactId IS NOT NULL)	
																						and '1'+cast(cinncontactid as varchar(20)) NOT IN (select originalContactID from CP_Tokens where originalContactID IS NOT NULL) 
																						and '1'+cast(cinncontactid as varchar(20)) NOT IN (select cast(contactCtgID as varchar(20))+cast(contactID as varchar(20)) from sma_MST_ReferOutEmailContacts where contactID IS NOT NULL) 
																						and '1'+cast(cinncontactid as varchar(20)) NOT IN (select cast(rlcnPrimaryCtgID as varchar(20)) + cast(rlcnPrimaryContactID as varchar(20)) from sma_MST_RelContacts where rlcnPrimaryContactID IS NOT NULL)
																						and '1'+cast(cinncontactid as varchar(20)) NOT IN (select cast(rlcnRelCtgID as varchar(20)) + cast(rlcnRelContactID as varchar(20)) from sma_MST_RelContacts where rlcnRelContactID IS NOT NULL))
DELETE FROM sma_MST_EmailWebsite where cewnContactCtgID=1 
		and cewnContactID in (select cinnContactID from sma_MST_IndvContacts where cinnContactID not in (select usrncontactid from sma_mst_users) 
																						and cinnContactID not in (8,9)
																						and '1'+cast(cinncontactid as varchar(20)) not in (select frinUniqueContactId from sma_MST_FirmInfo where frinUniqueContactId IS NOT NULL)
																						and '1'+cast(cinncontactid as varchar(20)) NOT IN (select UniqueContactId from sma_mst_offices where UniqueContactId IS NOT NULL)	
																						and '1'+cast(cinncontactid as varchar(20)) NOT IN (select originalContactID from CP_Tokens where originalContactID IS NOT NULL) 
																						and '1'+cast(cinncontactid as varchar(20)) NOT IN (select cast(contactCtgID as varchar(20))+cast(contactID as varchar(20)) from sma_MST_ReferOutEmailContacts where contactID IS NOT NULL) 
																						and '1'+cast(cinncontactid as varchar(20)) NOT IN (select cast(rlcnPrimaryCtgID as varchar(20)) + cast(rlcnPrimaryContactID as varchar(20)) from sma_MST_RelContacts where rlcnPrimaryContactID IS NOT NULL)
																						and '1'+cast(cinncontactid as varchar(20)) NOT IN (select cast(rlcnRelCtgID as varchar(20)) + cast(rlcnRelContactID as varchar(20)) from sma_MST_RelContacts where rlcnRelContactID IS NOT NULL) )

DELETE FROM sma_mst_ContactTypesForContact where ctcnContactCtgID = 1
		and ctcnContactID IN (select cinnContactID from sma_MST_IndvContacts where cinnContactID not in (select usrncontactid from sma_mst_users) 
																						and cinnContactID not in (8,9)
																						and '1'+cast(cinncontactid as varchar(20)) not in (select frinUniqueContactId from sma_MST_FirmInfo where frinUniqueContactId IS NOT NULL)
																						and '1'+cast(cinncontactid as varchar(20)) NOT IN (select UniqueContactId from sma_mst_offices where UniqueContactId IS NOT NULL)	
																						and '1'+cast(cinncontactid as varchar(20)) NOT IN (select originalContactID from CP_Tokens where originalContactID IS NOT NULL) 
																						and '1'+cast(cinncontactid as varchar(20)) NOT IN (select cast(contactCtgID as varchar(20))+cast(contactID as varchar(20)) from sma_MST_ReferOutEmailContacts where contactID IS NOT NULL) 
																						and '1'+cast(cinncontactid as varchar(20)) NOT IN (select cast(rlcnPrimaryCtgID as varchar(20)) + cast(rlcnPrimaryContactID as varchar(20)) from sma_MST_RelContacts where rlcnPrimaryContactID IS NOT NULL)
																						and '1'+cast(cinncontactid as varchar(20)) NOT IN (select cast(rlcnRelCtgID as varchar(20)) + cast(rlcnRelContactID as varchar(20)) from sma_MST_RelContacts where rlcnRelContactID IS NOT NULL) )

DELETE FROM sma_MST_IndvContacts where cinnContactID in (select cinnContactID from sma_MST_IndvContacts where cinnContactID not in (select usrncontactid from sma_mst_users) 
																						and cinnContactID not in (8,9)
																						and '1'+cast(cinncontactid as varchar(20)) not in (select frinUniqueContactId from sma_MST_FirmInfo where frinUniqueContactId IS NOT NULL)
																						and '1'+cast(cinncontactid as varchar(20)) NOT IN (select UniqueContactId from sma_mst_offices where UniqueContactId IS NOT NULL)	
																						and '1'+cast(cinncontactid as varchar(20)) NOT IN (select originalContactID from CP_Tokens where originalContactID IS NOT NULL) 
																						and '1'+cast(cinncontactid as varchar(20)) NOT IN (select cast(contactCtgID as varchar(20))+cast(contactID as varchar(20)) from sma_MST_ReferOutEmailContacts where contactID IS NOT NULL)
																						and '1'+cast(cinncontactid as varchar(20)) NOT IN (select cast(rlcnPrimaryCtgID as varchar(20)) + cast(rlcnPrimaryContactID as varchar(20)) from sma_MST_RelContacts where rlcnPrimaryContactID IS NOT NULL)
																						and '1'+cast(cinncontactid as varchar(20)) NOT IN (select cast(rlcnRelCtgID as varchar(20)) + cast(rlcnRelContactID as varchar(20)) from sma_MST_RelContacts where rlcnRelContactID IS NOT NULL) )
  
---------------------
--ORG CONTACTS
---------------------
DELETE FROM sma_mst_address where addnContactCtgID=2 
		and addnContactID in (select connContactID from sma_MST_OrgContacts where '2'+cast(connContactID as varchar(20)) not in (select frinUniqueContactId from sma_MST_FirmInfo )
																					and '2'+cast(connContactID as varchar(20)) not in (select UniqueContactID from sma_MST_Offices where UniqueContactId is not null)
																					and '2'+cast(connContactID as varchar(20)) not in (select originalContactID from CP_Tokens where OriginalContactId is not null) 
																					and conncontactid not in (select cgcnContactID from sma_MST_AdvertisementCampaignGroupContacts) 
																					and conncontactid not in (select RefOutFirmID from sma_MST_ReferOutRules) 
																					and '2'+cast(conncontactid as varchar(20)) NOT IN (select cast(contactCtgID as varchar(20))+cast(contactID as varchar(20)) from sma_MST_ReferOutEmailContacts where contactID IS NOT NULL)
																					and '2'+cast(conncontactid as varchar(20)) NOT IN (select cast(rlcnPrimaryCtgID as varchar(20)) + cast(rlcnPrimaryContactID as varchar(20)) from sma_MST_RelContacts where rlcnPrimaryContactID IS NOT NULL)
																					and '2'+cast(conncontactid as varchar(20)) NOT IN (select cast(rlcnRelCtgID as varchar(20)) + cast(rlcnRelContactID as varchar(20)) from sma_MST_RelContacts where rlcnRelContactID IS NOT NULL) )
DELETE FROM sma_MST_ContactNumbers where cnnnContactCtgID=2 
		and cnnnContactID in (select connContactID from sma_MST_OrgContacts where '2'+cast(connContactID as varchar(20)) not in (select frinUniqueContactId from sma_MST_FirmInfo )
																					and '2'+cast(connContactID as varchar(20)) not in (select UniqueContactID from sma_MST_Offices where UniqueContactId is not null)
																					and '2'+cast(connContactID as varchar(20)) not in (select originalContactID from CP_Tokens where OriginalContactId is not null) 
																					and conncontactid not in (select cgcnContactID from sma_MST_AdvertisementCampaignGroupContacts) 
																					and conncontactid not in (select RefOutFirmID from sma_MST_ReferOutRules) 
																					and '2'+cast(conncontactid as varchar(20)) NOT IN (select cast(contactCtgID as varchar(20))+cast(contactID as varchar(20)) from sma_MST_ReferOutEmailContacts where contactID IS NOT NULL)
																					and '2'+cast(conncontactid as varchar(20)) NOT IN (select cast(rlcnPrimaryCtgID as varchar(20)) + cast(rlcnPrimaryContactID as varchar(20)) from sma_MST_RelContacts where rlcnPrimaryContactID IS NOT NULL)
																					and '2'+cast(conncontactid as varchar(20)) NOT IN (select cast(rlcnRelCtgID as varchar(20)) + cast(rlcnRelContactID as varchar(20)) from sma_MST_RelContacts where rlcnRelContactID IS NOT NULL) )
DELETE FROM sma_MST_EmailWebsite where cewnContactCtgID=2 
		and cewnContactID in (select connContactID from sma_MST_OrgContacts where '2'+cast(connContactID as varchar(20)) not in (select frinUniqueContactId from sma_MST_FirmInfo )
																					and '2'+cast(connContactID as varchar(20)) not in (select UniqueContactID from sma_MST_Offices where UniqueContactId is not null)
																					and '2'+cast(connContactID as varchar(20)) not in (select originalContactID from CP_Tokens where OriginalContactId is not null) 
																					and conncontactid not in (select cgcnContactID from sma_MST_AdvertisementCampaignGroupContacts) 
																					and conncontactid not in (select RefOutFirmID from sma_MST_ReferOutRules) 
																					and '2'+cast(conncontactid as varchar(20)) NOT IN (select cast(contactCtgID as varchar(20))+cast(contactID as varchar(20)) from sma_MST_ReferOutEmailContacts where contactID IS NOT NULL)
																					and '2'+cast(conncontactid as varchar(20)) NOT IN (select cast(rlcnPrimaryCtgID as varchar(20)) + cast(rlcnPrimaryContactID as varchar(20)) from sma_MST_RelContacts where rlcnPrimaryContactID IS NOT NULL)
																					and '2'+cast(conncontactid as varchar(20)) NOT IN (select cast(rlcnRelCtgID as varchar(20)) + cast(rlcnRelContactID as varchar(20)) from sma_MST_RelContacts where rlcnRelContactID IS NOT NULL) )
DELETE FROM sma_mst_ContactTypesForContact where ctcnContactCtgID = 1
		and ctcnContactID IN (select connContactID from sma_MST_OrgContacts where '2'+cast(connContactID as varchar(20)) not in (select frinUniqueContactId from sma_MST_FirmInfo )
																					and '2'+cast(connContactID as varchar(20)) not in (select UniqueContactID from sma_MST_Offices where UniqueContactId is not null)
																					and '2'+cast(connContactID as varchar(20)) not in (select originalContactID from CP_Tokens where OriginalContactId is not null) 
																					and conncontactid not in (select cgcnContactID from sma_MST_AdvertisementCampaignGroupContacts) 
																					and conncontactid not in (select RefOutFirmID from sma_MST_ReferOutRules) 
																					and '2'+cast(conncontactid as varchar(20)) NOT IN (select cast(contactCtgID as varchar(20))+cast(contactID as varchar(20)) from sma_MST_ReferOutEmailContacts where contactID IS NOT NULL)
																					and '2'+cast(conncontactid as varchar(20)) NOT IN (select cast(rlcnPrimaryCtgID as varchar(20)) + cast(rlcnPrimaryContactID as varchar(20)) from sma_MST_RelContacts where rlcnPrimaryContactID IS NOT NULL)
																					and '2'+cast(conncontactid as varchar(20)) NOT IN (select cast(rlcnRelCtgID as varchar(20)) + cast(rlcnRelContactID as varchar(20)) from sma_MST_RelContacts where rlcnRelContactID IS NOT NULL) )

DELETE FROM sma_MST_OrgContacts where conncontactid in (select connContactID from sma_MST_OrgContacts where '2'+cast(connContactID as varchar(20)) not in (select frinUniqueContactId from sma_MST_FirmInfo )
																					and '2'+cast(connContactID as varchar(20)) not in (select UniqueContactID from sma_MST_Offices where UniqueContactId is not null)
																					and '2'+cast(connContactID as varchar(20)) not in (select originalContactID from CP_Tokens where OriginalContactId is not null) 
																					and conncontactid not in (select cgcnContactID from sma_MST_AdvertisementCampaignGroupContacts) 
																					and conncontactid not in (select RefOutFirmID from sma_MST_ReferOutRules) 
																					and '2'+cast(conncontactid as varchar(20)) NOT IN (select cast(contactCtgID as varchar(20))+cast(contactID as varchar(20)) from sma_MST_ReferOutEmailContacts where contactID IS NOT NULL)
																					and '2'+cast(conncontactid as varchar(20)) NOT IN (select cast(rlcnPrimaryCtgID as varchar(20)) + cast(rlcnPrimaryContactID as varchar(20)) from sma_MST_RelContacts where rlcnPrimaryContactID IS NOT NULL)
																					and '2'+cast(conncontactid as varchar(20)) NOT IN (select cast(rlcnRelCtgID as varchar(20)) + cast(rlcnRelContactID as varchar(20)) from sma_MST_RelContacts where rlcnRelContactID IS NOT NULL) )

alter table sma_mst_address enable trigger all 
go
alter table sma_MST_ContactNumbers enable trigger all 
go
alter table sma_MST_EmailWebsite enable trigger all 
go
alter table sma_MST_IndvContacts enable trigger all 
go
alter table sma_MST_OrgContacts enable trigger all 
go



alter table [dbo].[sma_trn_Cases] disable trigger all
delete from [dbo].[sma_trn_Cases]
DBCC CHECKIDENT ('[dbo].[sma_trn_Cases]', RESEED, 0);
alter table [dbo].[sma_trn_Cases] enable trigger all
GO