/* #######################################################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create individual contacts from [account]

[0.0] Update schema
- 

[1.0] Individual Contacts					Target							Source
	-------------------------------------------------------------------------------------------------
	[1.1] Litify Contacts					sma_MST_IndvContacts			dbo.Contact
	[1.2] Litify Individual accounts		sma_MST_IndvContacts			dbo.Account
	[1.3] Law Firm Primary Contacts			sma_MST_IndvContacts			dbo.litify_pm__firm__c

[2.0] Organization Contacts					Target							Source
	-------------------------------------------------------------------------------------------------
	[2.1] Litify Business accounts			sma_MST_OrgContacts				dbo.Account
	[2.2] Law Firms							sma_MST_OrgContacts				dbo.litify_pm__firm__c

########################################################################################################################
*/


/* ###################################################################################
description: Create general individual contacts
steps:
	- insert [sma_MST_IndvContacts] from [needles].[names]
	- update bridge
usage_instructions:
	-
dependencies:
	- 
notes:
	- 
saga:
	- saga
source:
	- [names]
target:
	- [sma_MST_IndvContacts]
######################################################################################
*/


use ShinerSA
go



---------------------------------------------------
-- [1.0] Individual Contacts
---------------------------------------------------
alter table [sma_MST_IndvContacts] disable trigger all
go


-- [1.2] "Litify Individual" accounts
insert into [sma_MST_IndvContacts]
	(
		[cinbPrimary],
		[cinnContactTypeID],
		[cinnContactSubCtgID],
		[cinsPrefix],
		[cinsFirstName],
		[cinsMiddleName],
		[cinsLastName],
		[cinsSuffix],
		[cinsNickName],
		[cinbStatus],
		[cinsSSNNo],
		cinsEINNo,
		[cindBirthDate],
		[cinsComments],
		[cinnContactCtg],
		[cinnRefByCtgID],
		[cinnReferredBy],
		[cindDateOfDeath],
		[cinsCVLink],
		[cinnMaritalStatusID],
		[cinnGender],
		[cinsBirthPlace],
		[cinnCountyID],
		[cinsCountyOfResidence],
		[cinbFlagForPhoto],
		[cinsPrimaryContactNo],
		[cinsHomePhone],
		[cinsWorkPhone],
		[cinsMobile],
		[cinbPreventMailing],
		[cinnRecUserID],
		[cindDtCreated],
		[cinnModifyUserID],
		[cindDtModified],
		[cinnLevelNo],
		[cinsPrimaryLanguage],
		[cinsOtherLanguage],
		[cinbDeathFlag],
		[cinsCitizenship],
		[cinsHeight],
		[cinnWeight],
		[cinsReligion],
		[cindMarriageDate],
		[cinsMarriageLoc],
		[cinsDeathPlace],
		[cinsMaidenName],
		[cinsOccupation],
		[saga_char],
		[cinsSpouse],
		[cinsGrade],
		[source_db],
		[source_ref]
	)
	select distinct
		1									 as [cinbprimary],
		case
			when a.[Type] = 'Doctor'
				then (
						select
							octnOrigContactTypeID
						from sma_MST_OriginalContactTypes
						where octnContactCtgID = 1
							and octsDscrptn = 'Doctor'
					)
			when a.[Type] = 'Judge'
				then (
						select
							octnOrigContactTypeID
						from sma_MST_OriginalContactTypes
						where octnContactCtgID = 1
							and octsDscrptn = 'Judge'
					)
			when a.[Type] in ('Attorney', 'Co-Counsel')
				then (
						select
							octnOrigContactTypeID
						from sma_MST_OriginalContactTypes
						where octnContactCtgID = 1
							and octsDscrptn = 'Attorney'
					)
			when a.[Type] = 'Adjuster'
				then (
						select
							octnOrigContactTypeID
						from sma_MST_OriginalContactTypes
						where octnContactCtgID = 1
							and octsDscrptn = 'Adjuster'
					)
			when a.[Type] = 'Clerk'
				then (
						select
							octnOrigContactTypeID
						from sma_MST_OriginalContactTypes
						where octnContactCtgID = 1
							and octsDscrptn = 'Law Clerk'
					)
			else (
					select
						octnOrigContactTypeID
					from sma_MST_OriginalContactTypes
					where octnContactCtgID = 1
						and octsDscrptn = 'General Unspecified'
				)
		end									 as [cinncontacttypeid],
		null								 as [cinncontactsubctgid],
		litify_pm__Salutation__c			 as [cinsprefix],
		litify_pm__First_Name__c			 as [cinsfirstname],	--30
		''									 as [cinsmiddlename],  --30
		litify_pm__Last_Name__c				 as [cinslastname],  --40
		null								 as [cinssuffix], -- 10
		null								 as [cinsnickname],
		1									 as [cinbstatus],
		litify_pm__Social_Security_Number__c as [cinsssnno],
		null								 as cinseinno,
		a.litify_pm__Date_of_birth__c		 as [cindbirthdate],
		ISNULL('Description: ' + NULLIF(CONVERT(VARCHAR(MAX), a.[Description]), '') + CHAR(13), '') +
		''									 as [cinscomments],
		1									 as [cinncontactctg],
		''									 as [cinnrefbyctgid],
		''									 as [cinnreferredby],
		null								 as [cinddateofdeath],
		''									 as [cinscvlink],
		''									 as [cinnmaritalstatusid],
		case
			when a.litify_pm__Gender__c = 'female'
				then 2
			when a.litify_pm__Gender__c = 'male'
				then 1
			else 0
		end									 as [cinngender],
		''									 as [cinsbirthplace],
		1									 as [cinncountyid],
		1									 as [cinscountyofresidence],
		null								 as [cinbflagforphoto],
		null								 as [cinsprimarycontactno],
		''									 as [cinshomephone],
		''									 as [cinsworkphone],
		null								 as [cinsmobile],
		0									 as [cinbpreventmailing],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga_char = a.CreatedById
		)									 as [cinnrecuserid],
		--convert(datetime, left(created, 19))		as [cindDtCreated], 
		a.CreatedDate						 as [cinddtcreated],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga_char = a.LastModifiedById
		)									 as [cinnmodifyuserid],
		a.LastModifiedDate					 as [cinddtmodified],
		0									 as [cinnlevelno],
		null								 as [cinsprimarylanguage],
		''									 as [cinsotherlanguage],
		litify_pm__lit_Is_Deceased__c		 as [cinbdeathflag],
		''									 as [cinscitizenship],
		null								 as [cinsheight],
		null								 as [cinnweight],
		''									 as [cinsreligion],
		null								 as [cindmarriagedate],
		''									 as [cinsmarriageloc],
		''									 as [cinsdeathplace],
		''									 as [cinsmaidenname],
		''									 as [cinsoccupation],
		a.[Id]								 as [saga_char],
		--case when isnull(Spouse_Name__c,'') not in ('','Y','N/A') then Spouse_Name__c else '' end	as [cinsSpouse], 
		null								 as [cinsspouse],
		null								 as [cinsgrade],
		'litify'							 as [source_db],
		'account: Litify Individual'		 as [source_ref]
	--select *
	from conversion.cases_to_convert ctc
	-- Role
	join ShinerLitify..litify_pm__Role__c role
		on role.litify_pm__Matter__c = ctc.matter_id
	-- Account
	join ShinerLitify..Account a
		on a.Id = role.litify_pm__Party__c
	-- RecordType
	join ShinerLitify..RecordType rt
		on a.RecordTypeId = LEFT(rt.Id, 15)
			and rt.SobjectType = 'Account'
	left join sma_MST_IndvContacts ind
		on ind.saga_char = a.Id
	-- where org.id doesnt exist
	-- and rt.Name = Litify Business
	where
		ind.cinnContactID is null
		and rt.[Name] = 'Litify Individual'
		and ISNULL(litify_pm__Last_Name__c, '') <> ''



--from ShinerLitify..[Account] c
--left join ShinerLitify..Contact ct
--	on c.Id = ct.AccountId
--join ShinerLitify..RecordType rt
--	on c.RecordTypeId = LEFT(rt.Id, 15)
--		and rt.SobjectType = 'Account'
---- Only convert contacts that exist as a party in a case
--join ShinerLitify..litify_pm__Role__c role
--	on role.litify_pm__Party__c = c.Id
--join conversion.cases_to_convert ctc
--	on ctc.matter_id = role.litify_pm__Matter__c
--left join sma_MST_IndvContacts ind
--	on ind.saga_char = c.Id
--where
--	ind.cinnContactID is null
--	and
--	rt.[Name] = 'Litify Individual'
--	and
--	ISNULL(litify_pm__Last_Name__c, '') <> ''




go

alter table sma_MST_IndvContacts enable trigger all



/*
For contacts not associated with cases, if they have Type = Client, convert them
*/
--SELECT *
--FROM ShinerLitify..[Account] c
--LEFT JOIN ShinerLitify..Contact ct
--    ON c.Id = ct.AccountId
--JOIN ShinerLitify..RecordType rt
--    ON c.RecordTypeId = LEFT(rt.Id, 15)
--    AND rt.SobjectType = 'Account'
---- Only include accounts that are NOT assigned to cases
--LEFT JOIN ShinerLitify..litify_pm__Role__c role
--    ON role.litify_pm__Party__c = c.Id
--LEFT JOIN conversion.cases_to_convert ctc
--    ON ctc.Id = role.litify_pm__Matter__c
--LEFT JOIN sma_MST_IndvContacts ind
--    ON ind.saga_char = c.Id
--WHERE ind.cinnContactID IS NULL
--    AND rt.[Name] = 'Litify Individual'
--    AND ISNULL(c.litify_pm__Last_Name__c, '') <> ''
--    AND role.litify_pm__Party__c IS NULL  -- No matching role (not assigned to a case)
--    AND ctc.Id IS NULL  -- No matching case (not assigned to a case)
--    AND c.Type = 'Client'  -- Only accounts where Type = 'Client'
