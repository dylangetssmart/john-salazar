/*
For contacts NOT associated with cases, if they have Type = Client, convert them
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
		'account: type = client'							 as [source_ref]
	--SELECT *
	from ShinerLitify..Account a
	left join ShinerLitify..litify_pm__Role__c role
		on role.litify_pm__Party__c = a.Id
	left join conversion.cases_to_convert ctc
		on ctc.matter_id = role.litify_pm__Matter__c
	-- RecordType
	join ShinerLitify..RecordType rt
		on a.RecordTypeId = LEFT(rt.Id, 15)
			and rt.SobjectType = 'Account'
	left join sma_MST_IndvContacts ind
		on ind.saga_char = a.Id
	where
		ind.cinnContactID is null
		and rt.[Name] = 'Litify Individual'
		and ISNULL(a.litify_pm__Last_Name__c, '') <> ''
		and role.litify_pm__Party__c is null	-- No matching role (not assigned to a case)
		and ctc.matter_id is null				-- No matching case (not assigned to a case)
		and a.Type = 'Client'					-- Only accounts where Type = 'Client'


--from ShinerLitify..[Account] c
--left join ShinerLitify..Contact ct
--	on c.Id = ct.AccountId
--join ShinerLitify..RecordType rt
--	on c.RecordTypeId = LEFT(rt.Id, 15)
--		and rt.SobjectType = 'Account'
---- Only include accounts that are NOT assigned to cases
--left join ShinerLitify..litify_pm__Role__c role
--	on role.litify_pm__Party__c = c.Id
--left join conversion.cases_to_convert ctc
--	on ctc.matter_id = role.litify_pm__Matter__c
--left join sma_MST_IndvContacts ind
--	on ind.saga_char = c.Id
--where
--	ind.cinnContactID is null
--	and
--	rt.[Name] = 'Litify Individual'
--	and
--	ISNULL(c.litify_pm__Last_Name__c, '') <> ''
--	and
--	role.litify_pm__Party__c is null  -- No matching role (not assigned to a case)
--	and ctc.matter_id is null  -- No matching case (not assigned to a case)
--	and c.Type = 'Client'  -- Only accounts where Type = 'Client'






--select *
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
--	on ctc.Id = role.litify_pm__Matter__c
--left join sma_MST_IndvContacts ind
--	on ind.saga_char = c.Id
--where ind.cinnContactID is null
--	and rt.[Name] = 'Litify Individual'
--	and ISNULL(litify_pm__Last_Name__c, '') <> ''
go

alter table sma_MST_IndvContacts enable trigger all