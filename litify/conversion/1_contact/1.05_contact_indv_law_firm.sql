/* #######################################################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create Create individual contacts from [litify_pm__Firm__c]

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

alter table sma_MST_IndvContacts disable trigger all
go

-- 	[1.3] Law firm primary contacts
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
		1													as [cinbprimary],
		(
			select
				octnOrigContactTypeID
			from sma_MST_OriginalContactTypes
			where octnContactCtgID = 1
				and octsDscrptn = 'General Unspecified'
		)													as [cinncontacttypeid],
		null												as [cinncontactsubctgid],
		''													as [cinsprefix],
		LEFT(litify_pm__Primary_Contact_First_Name__c, 100) as [cinsfirstname],	-- 100
		''													as [cinsmiddlename],  -- 100
		LEFT(litify_pm__Primary_Contact_Last_Name__c, 100)  as [cinslastname],  -- 100
		''													as [cinssuffix], -- 10
		''													as [cinsnickname],
		1													as [cinbstatus],
		null												as [cinsssnno],
		null												as cinseinno,
		null												as [cindbirthdate],
		--isnull('Description: ' + nullif(convert(varchar(max),c.[Description]),'') + CHAR(13),'') +
		''													as [cinscomments],
		1													as [cinncontactctg],
		''													as [cinnrefbyctgid],
		''													as [cinnreferredby],
		null												as [cinddateofdeath],
		''													as [cinscvlink],
		''													as [cinnmaritalstatusid],
		0													as [cinngender],
		''													as [cinsbirthplace],
		1													as [cinncountyid],
		1													as [cinscountyofresidence],
		null												as [cinbflagforphoto],
		null												as [cinsprimarycontactno],
		''													as [cinshomephone],
		''													as [cinsworkphone],
		null												as [cinsmobile],
		0													as [cinbpreventmailing],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga_char = c.CreatedById
		)													as [cinnrecuserid],
		--convert(datetime, left(created, 19))		as [cindDtCreated], 
		c.CreatedDate										as [cinddtcreated],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga_char = c.LastModifiedById
		)													as [cinnmodifyuserid],
		c.LastModifiedDate									as [cinddtmodified],
		0													as [cinnlevelno],
		''													as [cinsprimarylanguage],
		''													as [cinsotherlanguage],
		''													as [cinbdeathflag],
		''													as [cinscitizenship],
		null												as [cinsheight],
		null												as [cinnweight],
		''													as [cinsreligion],
		null												as [cindmarriagedate],
		''													as [cinsmarriageloc],
		''													as [cinsdeathplace],
		''													as [cinsmaidenname],
		''													as [cinsoccupation],
		c.[Id]												as [saga_char],
		''													as [cinsspouse],
		null												as [cinsgrade],
		'litify'											as [source_db],
		'litify_pm__Firm__c'								as [source_ref]
	--Select *
	from ShinerLitify..[litify_pm__Firm__c] c
	left join sma_MST_IndvContacts ind
		on ind.saga_char = c.Id
	where
		ind.cinnContactID is null
		and (ISNULL(litify_pm__Primary_Contact_First_Name__c, '') <> '' or ISNULL(litify_pm__Primary_Contact_Last_Name__c, '') <> '')

alter table [sma_MST_IndvContacts] enable trigger all
go