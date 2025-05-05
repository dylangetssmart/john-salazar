/* ###################################################################################

*/

use ShinerSA
go



/*
######################################################################
Validation
######################################################################
*/

--if 1 = 0 -- Always false
--begin

--	--matter id: a0L8Z00000eDawuUAC
--	select
--		a.id,
--		a.type,
--		a.Name,
--		*
--	from ShinerLitify..[litify_pm__Negotiation__c] lpdc
--	join ShinerLitify..Account a
--		on a.Id = lpdc.litify_ext__Negotiating_with_Party__c
--	where lpdc.litify_pm__Matter__c like 'a0L8Z00000eDawuUAC'
--	-- litify_pm__Negotiating_with__c = a0VNt000000ZUBJMA4
--	-- litify_ext__Negotiating_with_Party__c =  0018Z00002rytGyQAI
--	-- OwnerId = 0058Z000009TFzAQAW

--	select
--		*
--	from shinerlitify..account
--	where id = '0058Z000009TFzAQAW'


--	select
--		*
--	from shinerlitify..contact
--	where LastName like '%hoffman%'
--		and firstname like '%michael%'
--	-- id = 003Nt000005czyxIAA
--	-- AccountId = 001Nt000005WIesIAG
--	-- OwnerId = 0058Z000008qiLTQAY

--	select
--		*
--	from shinerlitify..account
--	where name like '%hoffman%'
--id = 001Nt000005WIesIAG

--select * from shinerlitify..contact WHERE name like '%hoffman%'
--a0VNt000000ZUBJMA4


--SELECT
--	*
--FROM shinerlitify.dbo.User


--SELECT
--	*
--FROM sma_mst_users
--WHERE saga = '0058Z000008qiLTQAY'


--SELECT
--	a.name
--   ,*
--FROM ShinerLitify..[litify_pm__Negotiation__c] lpdc
--LEFT JOIN ShinerLitify..Account a
--	ON a.Id = lpdc.CreatedById
--WHERE lpdc.litify_pm__Matter__c LIKE 'a0L8Z00000eDawuUAC'

--SELECT
--	*
--FROM ShinerLitify..Account a

--SELECT
--	*
--FROM [ShinerLitify]..litify_pm__Role__c
--WHERE litify_pm__Party__c = '0018Z00002rytGyQAI'

----SELECT
----	MAX(LEN(lpdc.litify_ext__Negotiating_with_Party__c))
----FROM ShinerLitify..[litify_pm__Negotiation__c] lpdc

---- Account
--SELECT
--	*
--FROM ShinerLitify..Account a
--WHERE a.Id = '0018Z00002rytGyQAI'


--SELECT DISTINCT
--	a.Type
--FROM ShinerLitify..[litify_pm__Negotiation__c] lpdc
--JOIN ShinerLitify..Account a
--	ON a.Id = lpdc.litify_ext__Negotiating_with_Party__c



--SELECT
--	*
--FROM ShinerLitify..litify_pm__Matter__c lpmc
--WHERE lpmc.litify_pm__Display_Name__c LIKE '%cheryl lavigne%'
---- id: a0LNt00000B4BoWMAV
---- MAT-24041528833

--SELECT
--	*
--FROM ShinerSa


--end
-------------------------------------------- END VALIDATION --------------------------------------------

/*
######################################################################
[1.0] Party Helper
######################################################################

- build helper table with refernces to "Negotiating With"
- check Account.Type
SELECT DISTINCT a.type
FROM ShinerLitify..[litify_pm__Negotiation__c] lpdc
JOIN ShinerLitify..Account a
ON a.Id = lpdc.litify_ext__Negotiating_with_Party__c

if account.type = insurance, get
"I+[sma_trn_InsuranceCoverage].[IncnInsCovgID]"

if account.type = lawyer, get 
- "L+[sma_trn_LawFirms].[lwfnLawFirmID]"

--*/


---- [] Create helper
--IF
--	OBJECT_ID('helper_Negotiation_Party', 'U') IS NOT NULL
--BEGIN
--	DROP TABLE helper_Negotiation_Party;
--END;

--CREATE TABLE helper_Negotiation_Party (
--	SACaseID INT
--   ,LitifyCaseId VARCHAR(50)
--   ,negsUniquePartyID VARCHAR(25)
--   ,negotiatedBy INT
--   ,partyType VARCHAR(10)
--);
--GO

--/*
--[1.3] Populate helper

--- add insurance companies
--- add attorneys

--*/
--INSERT INTO helper_Negotiation_Party
--	(
--	SAcaseID
--   ,LitifyCaseId
--   ,negsUniquePartyID
--   ,negotiatedBy
--   ,partyType
--	)
--	-- Insurance Companies
--	SELECT
--		cas.casnCaseID								   AS SAcaseID
--	   ,cas.saga_char								   AS LitifyCaseId
--	   ,'I' + CONVERT(VARCHAR(10), stic.incnInsCovgID) AS negsUniquePartyID
--	   ,ioci.CID									   AS negotiatedBy
--	   ,'Insurance'									   AS partyType
--	FROM ShinerLitify..[litify_pm__Negotiation__c] lpdc
--	-- Negotiating With
--	JOIN ShinerLitify..Account a
--		ON a.Id = lpdc.litify_ext__Negotiating_with_Party__c
--	-- Insurance company Id
--	JOIN sma_TRN_Cases cas
--		ON cas.saga_char = lpdc.litify_pm__Matter__c
--	JOIN sma_TRN_InsuranceCoverage stic
--		ON stic.incnCaseID = cas.casnCaseID
--	-- Negotiated By
--	LEFT JOIN ShinerSA..IndvOrgContacts_Indexed ioci
--		ON ioci.saga_char = lpdc.OwnerId
--	WHERE ISNULL(a.Type, '') <> ''
--		AND a.Type IN ('insurance', 'Insurance Company')

--	UNION

--	-- Lawyers
--	SELECT
--		cas.casnCaseID								AS SAcaseID
--	   ,cas.saga_char								AS LitifyCaseId
--	   ,'L' + CONVERT(VARCHAR(10), [lwfnLawFirmID]) AS negsUniquePartyID
--	   ,ioci.CID									AS negotiatedBy
--	   ,'Attorney'									AS partyType
--	FROM ShinerLitify..[litify_pm__Negotiation__c] lpdc
--	-- case
--	JOIN sma_TRN_Cases cas
--		ON cas.saga_char = lpdc.litify_pm__Matter__c
--	-- Negotiated With
--	JOIN ShinerLitify..Account a
--		ON a.Id = lpdc.litify_ext__Negotiating_with_Party__c
--	LEFT JOIN IndvOrgContacts_Indexed IOC
--		ON IOC.saga_char = a.Id
--	-- Law Firm
--	LEFT JOIN sma_TRN_LawFirms stlf
--		ON stlf.lwfnLawFirmID = IOC.CID
--	-- Negotiated By
--	JOIN ShinerSA..IndvOrgContacts_Indexed ioci
--		ON ioci.saga_char = lpdc.OwnerId
--	WHERE ISNULL(a.Type, '') <> ''
--		AND a.Type IN ('Attorney')
--GO



----AND lpdc.litify_pm__Matter__c = 'a0L8Z00000eDawuUAC'

----SELECT * FROM sma_TRN_LawFirms stlf
----SELECT * FROM helper_Negotiation_Party
------[sma_TRN_Negotiations]
----WHERE SAcaseID= 2553

--/*
--######################################################################
--[1.0] Negotiations
--######################################################################
--*/

---- Add saga
--IF NOT EXISTS (
--		SELECT
--			*
--		FROM sys.columns
--		WHERE Name = N'saga_char'
--			AND object_id = OBJECT_ID(N'sma_TRN_Negotiations')
--	)
--BEGIN
--	ALTER TABLE [sma_TRN_Negotiations] ADD saga_char VARCHAR(100) NULL;
--END
--GO


---- [2.2] Insert Negotiations
---- Source = 

----SELECT
----	*
----FROM [sma_TRN_Negotiations]
----WHERE negncaseId = 2553
----SELECT
----	*
----FROM sma_MST_IndvContacts smic
----WHERE smic.cinnContactID = 446
----SELECT
----	ownerid
----FROM ShinerLitify..litify_pm__Negotiation__c lpnc
----WHERE lpnc.litify_pm__Matter__c = 'a0L8Z00000eDawuUAC'

----0058Z000009TFzAQAW
----SELECT
----	*
----FROM shinersa..sma_mst_users
----WHERE saga = '0058Z000009TFzAQAW'
----truncate TABLE [sma_TRN_Negotiations]
----sp_help '[sma_TRN_Negotiations]'
--INSERT INTO [dbo].[sma_TRN_Negotiations]
--	(
--	[negnCaseID]
--   ,[negsUniquePartyID]		-- Negotiating With
--   ,[negdDate]
--   ,[negnStaffID]
--   ,[negnPlaintiffID]
--   ,[negbPartiallySettled]
--   ,[negnClientAuthAmt]
--   ,[negbOralConsent]
--   ,[negdOralDtSent]
--   ,[negdOralDtRcvd]
--   ,[negnDemand]
--   ,[negnOffer]
--   ,[negbConsentType]
--   ,[negnRecUserID]
--   ,[negdDtCreated]
--   ,[negnModifyUserID]
--   ,[negdDtModified]
--   ,[negnLevelNo]
--   ,[negsComments]
--   ,[negnPartyCompanyUid]
--   ,[negnPartyIndividualUid]
--   ,[saga_char]
--	)
--	SELECT DISTINCT
--		cas.casnCaseID
--	   ,CASE
--			WHEN ISNULL(hnp.negsUniquePartyID, '') <> ''
--				THEN hnp.negsUniquePartyID
--			ELSE NULL
--		END										AS [negsUniquePartyID]
--	   ,CASE
--			WHEN CONVERT(DATETIME, neg.litify_pm__Date__c) BETWEEN '1/1/1900' AND '12/31/2079'
--				THEN CONVERT(DATETIME, litify_pm__Date__c)
--			ELSE NULL
--		END										AS negdDate
--	   ,hnp.negotiatedBy						AS negnStaffID				 -- ds 2024-09-26
--	   ,p.plnnPlaintiffID						AS [negnPlaintiffID]
--	   ,NULL									AS [negbPartiallySettled]
--	   ,NULL									AS [negnClientAuthAmt]
--	   ,NULL									AS [negbOralConsent]
--	   ,NULL									AS [negdOralDtSent]
--	   ,NULL									AS [negdOralDtRcvd]
--	   ,CASE
--			WHEN neg.litify_pm__Type__c LIKE '%Demand%'
--				THEN litify_pm__Amount__c
--			ELSE NULL
--		END										AS [negnDemand]
--	   ,CASE
--			WHEN neg.litify_pm__Type__c LIKE '%Offer%'
--				THEN litify_pm__Amount__c
--			ELSE NULL
--		END										AS [negnOffer]
--	   ,NULL									AS [negbConsentType]
--	   ,(
--			SELECT
--				usrnUserID
--			FROM sma_MST_Users
--			WHERE saga_char = OwnerId
--		)										
--		AS [negnRecUserID]
--	   ,CONVERT(DATETIME, neg.CreatedDate)		AS [negdDtCreated]
--	   ,(
--			SELECT
--				usrnUserID
--			FROM sma_MST_Users
--			WHERE saga_char = LastModifiedById
--		)										
--		AS [negnModifyUserID]
--	   ,CONVERT(DATETIME, neg.LastModifiedDate) AS [negdDtModified]
--	   ,1										AS [negnLevelNo]
--	   ,ISNULL('Name: ' + NULLIF(CONVERT(VARCHAR(500), neg.[Name]), '') + CHAR(13), '') +
--		ISNULL('Type: ' + NULLIF(neg.litify_pm__Type__c, '') + CHAR(13), '') +
--		ISNULL('Comments: ' + NULLIF(CONVERT(VARCHAR(4000), neg.litify_pm__Comments__c), '') + CHAR(13), '') +
--		''										AS [negsComments]
--	   ,NULL									AS [negnPartyCompanyUid]
--	   ,NULL									AS [negnPartyIndividualUid]
--	   ,neg.Id									AS [saga_char]
--	--select *
--	FROM ShinerLitify..[litify_pm__Negotiation__c] neg
--	JOIN sma_TRN_Cases cas
--		ON cas.saga_char = neg.litify_pm__Matter__c
--	--RECEIVING PARTY / PLAINTIFF
--	LEFT JOIN sma_TRN_Plaintiff p
--		ON p.plnnCaseID = cas.casnCaseID
--			AND p.plnbIsPrimary = 1
--	-- Negotiating With
--	LEFT JOIN IndvOrgContacts_Indexed ioc
--		ON ioc.saga_char = neg.litify_ext__Negotiating_with_Party__c
--	JOIN sma_MST_AllContactInfo smaci
--		ON smaci.ContactId = ioc.CID
--	LEFT JOIN helper_Negotiation_Party hnp
--		ON hnp.SAcaseID = cas.casnCaseID
----	WHERE cas.casnCaseID = 2553



---------------------------------------------------
-- schema
---------------------------------------------------


-- saga_char
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and Object_ID = OBJECT_ID(N'sma_TRN_Negotiations')
	)
begin
	alter table [sma_TRN_Negotiations] add saga_char VARCHAR(100) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and Object_ID = OBJECT_ID(N'sma_TRN_Negotiations')
	)
begin
	alter table [sma_TRN_Negotiations] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and Object_ID = OBJECT_ID(N'sma_TRN_Negotiations')
	)
begin
	alter table [sma_TRN_Negotiations] add [source_ref] VARCHAR(MAX) null;
end
go

--;
--with cte_negotiation_party (
--	sacaseid, litifycaseid, negsuniquepartyid, negotiatedby, partytype
--)
--as
---- Insurance Companies
--(
--	select
--		cas.casnCaseID as SAcaseID,
--		cas.saga_char as LitifyCaseId,
--		'I' + CONVERT(VARCHAR(10), stic.incnInsCovgID) as negsUniquePartyID,
--		ioci.CID as negotiatedBy,
--		'Insurance' as partyType
--	from ShinerLitify..[litify_pm__Negotiation__c] lpdc
--	-- Negotiating With
--	join ShinerLitify..Account a
--		on a.Id = lpdc.litify_ext__Negotiating_with_Party__c
--	-- Insurance company Id
--	join sma_TRN_Cases cas
--		on cas.saga_char = lpdc.litify_pm__Matter__c
--	join sma_TRN_InsuranceCoverage stic
--		on stic.incnCaseID = cas.casnCaseID
--	-- Negotiated By
--	left join ShinerSA..IndvOrgContacts_Indexed ioci
--		on ioci.saga_char = lpdc.OwnerId
--	where ISNULL(a.Type, '') <> ''
--		and a.Type in ('insurance', 'Insurance Company')

--	union

--	-- Lawyers
--	select
--		cas.casnCaseID as SAcaseID,
--		cas.saga_char as LitifyCaseId,
--		'L' + CONVERT(VARCHAR(10), [lwfnLawFirmID]) as negsUniquePartyID,
--		ioci.CID as negotiatedBy,
--		'Attorney' as partyType
--	from ShinerLitify..[litify_pm__Negotiation__c] lpdc
--	-- case
--	join sma_TRN_Cases cas
--		on cas.saga_char = lpdc.litify_pm__Matter__c
--	-- Negotiated With
--	join ShinerLitify..Account a
--		on a.Id = lpdc.litify_ext__Negotiating_with_Party__c
--	left join IndvOrgContacts_Indexed IOC
--		on IOC.saga_char = a.Id
--	-- Law Firm
--	left join sma_TRN_LawFirms stlf
--		on stlf.lwfnLawFirmID = IOC.CID
--	-- Negotiated By
--	join ShinerSA..IndvOrgContacts_Indexed ioci
--		on ioci.saga_char = lpdc.OwnerId
--	where ISNULL(a.Type, '') <> ''
--		and a.Type in ('Attorney')
--)

insert into [dbo].[sma_TRN_Negotiations]
	(
	[negnCaseID], [negsUniquePartyID], [negdDate], [negnStaffID], [negnPlaintiffID], [negbPartiallySettled], [negnClientAuthAmt], [negbOralConsent], [negdOralDtSent], [negdOralDtRcvd], [negnDemand], [negnOffer], [negbConsentType], [negnRecUserID], [negdDtCreated], [negnModifyUserID], [negdDtModified], [negnLevelNo], [negsComments], [negnPartyCompanyUid], [negnPartyIndividualUid], [saga_char], [source_db], [source_ref]
	)
	select distinct
		cas.casnCaseID				as [negncaseid],
		null						as [negsuniquepartyid],		-- ds 2/3/2025 leave blank as per Sue
		case
			when CONVERT(DATETIME, neg.litify_pm__Date__c) between '1/1/1900' and '12/31/2079'
				then CONVERT(DATETIME, litify_pm__Date__c)
			else null
		end							as [negddate],
		(

			select
				usr.usrnContactID
			from sma_mst_users usr
			where usr.saga_char = neg.OwnerId

		)							as [negnstaffid],		-- Negotiated By > sma_MST_IndvContacts.cinnContactID
		p.plnnPlaintiffID			as [negnplaintiffid],
		null						as [negbpartiallysettled],
		null						as [negnclientauthamt],
		null						as [negboralconsent],
		null						as [negdoraldtsent],
		null						as [negdoraldtrcvd],
		case
			when neg.litify_pm__Type__c like '%Demand%'
				then litify_pm__Amount__c
			else null
		end							as [negndemand],
		case
			when neg.litify_pm__Type__c like '%Offer%'
				then litify_pm__Amount__c
			else null
		end							as [negnoffer],
		null						as [negbconsenttype],
		(
			select
				usrnUserID
			from sma_mst_users
			where saga_char = neg.OwnerId
		)							as [negnrecuserid],
		case
			when CONVERT(DATETIME, neg.CreatedDate) between '1/1/1900' and '12/31/2079'
				then CONVERT(DATETIME, neg.CreatedDate)
			else null
		end							as [negddtcreated],
		(
			select
				usrnUserID
			from sma_mst_users
			where saga_char = neg.LastModifiedById
		)							as [negnmodifyuserid],
		case
			when CONVERT(DATETIME, neg.LastModifiedDate) between '1/1/1900' and '12/31/2079'
				then CONVERT(DATETIME, neg.LastModifiedDate)
			else null
		end							as [negddtmodified],
		1							as [negnlevelno],
		ISNULL('Name: ' + NULLIF(CONVERT(VARCHAR(500), neg.[name]), '') + CHAR(13), '') +
		ISNULL('Type: ' + NULLIF(neg.litify_pm__Type__c, '') + CHAR(13), '') +
		ISNULL('Comments: ' + NULLIF(CONVERT(VARCHAR(4000), neg.litify_pm__Comments__c), '') + CHAR(13), '') +
		''							as [negscomments],
		ioci_ins_company.UNQCID		as [negnpartycompanyuid],		-- sma_MST_AllContactInfo.UniqueContactID of Insurance Company OR LawFirm
		ioci_adj.UNQCID				as [negnpartyindividualuid],	-- sma_MST_AllContactInfo.UniqueContactID of Adjuster from Insurance Company OR Lawyer from LawFirm
		neg.Id						as [saga_char],
		'litify'					as [source_db],
		'litify_pm__Negotiation__c' as [source_ref]
	--select * 
	from [ShinerLitify]..[litify_pm__Negotiation__c] neg
	join sma_trn_cases cas
		on cas.saga_char = neg.litify_pm__Matter__c
	--RECEIVING PARTY / PLAINTIFF
	join sma_TRN_Plaintiff p
		on p.plnnCaseID = cas.casnCaseID
			and p.plnbIsPrimary = 1
	left join ShinerLitify..litify_pm__Insurance__c ins
		on neg.litify_pm__Related_Insurance__c = ins.Id
	-- Insurance Company
	left join ShinerLitify..Account a_ins_company
		on ins.litify_ext__Insurance_Company_Party__c = a_ins_company.Id
	left join IndvOrgContacts_Indexed ioci_ins_company
		on a_ins_company.id = ioci_ins_company.saga_char
	-- Adjuster
	left join ShinerLitify..Account a_adj
		on ins.litify_ext__Adjuster_Party__c = a_adj.Id
	left join IndvOrgContacts_Indexed ioci_adj
		on a_adj.id = ioci_adj.saga_char
	--where cas.casnCaseID = 4125
	--where neg.litify_pm__Matter__c = 'a0L8Z00000eDawuUAC'