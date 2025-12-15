/*---
description: Insert individual contacts
steps:
	1. Insert Contact Race				[sma_MST_ContactRace]
	2. Insert Individual Contacts		[sma_MST_IndvContacts]
		- Unassigned Staff
		- Unidentified Individual
		- Unidentified Plaintiff
		- Unidentified Defendant
		- from [names]
		- from [police]
		- from [staff]
		- from [insurance]
	3. Update comments					[sma_MST_IndvContacts] 
instructions:
dependencies:
	- [Needles]..[names]
	- [Needles]..[police]
	- [Needles]..[staff]
	- [Needles]..[insurance]
notes: >
---*/


use [SA]
go


---
exec AddBreadcrumbsToTable 'sma_MST_IndvContacts'
go

alter table [sma_MST_IndvContacts] alter column saga INT
go

---

/* ------------------------------------------------------------------------------
Insert [sma_Mst_ContactRace] from [race]
*/ ------------------------------------------------------------------------------
insert into sma_MST_ContactRace
	(
		RaceDesc
	)
	select distinct
		race_name
	from [Needles]..race
	except
	select
		RaceDesc
	from sma_Mst_ContactRace
go

/* ------------------------------------------------------------------------------
Insert Indvidual Contacts
*/ ------------------------------------------------------------------------------
alter table [sma_MST_IndvContacts] disable trigger all
go

-- Unidentified Staff
if not exists (
	 select
		 *
	 from sma_MST_IndvContacts
	 where [cinsFirstName] = 'Staff'
		 and [cinsLastName] = 'Unassigned'
	)
begin
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
			[saga],
			[cinsSpouse],
			[cinsGrade]
		)

		select
			1,
			10,
			null,
			'Mr.',
			'Staff',
			'',
			'Unassigned',
			null,
			null,
			1,
			null,
			null,
			null,
			1,
			'',
			'',
			null,
			'',
			'',
			1,
			'',
			1,
			1,
			null,
			null,
			'',
			'',
			null,
			0,
			368,
			GETDATE(),
			'',
			null,
			0,
			'',
			'',
			'',
			'',
			null + null,
			null,
			'',
			null,
			'',
			'',
			'',
			'',
			'',
			'',
			null
end

go

-- Unidentified Individual
if not exists (
	 select
		 *
	 from sma_MST_IndvContacts
	 where [cinsFirstName] = 'Individual'
		 and [cinsLastName] = 'Unidentified'
	)
begin
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
			[saga],
			[cinsSpouse],
			[cinsGrade]
		)

		select
			1,
			10,
			null,
			'Mr.',
			'Individual',
			'',
			'Unidentified',
			null,
			null,
			1,
			null,
			null,
			null,
			1,
			'',
			'',
			null,
			'',
			'',
			1,
			'',
			1,
			1,
			null,
			null,
			'',
			'',
			null,
			0,
			368,
			GETDATE(),
			'',
			null,
			0,
			'',
			'',
			'',
			'',
			null + null,
			null,
			'',
			null,
			'',
			'',
			'',
			'Unknown',
			'',
			'Doe',
			null
end

go

-- Unidentified Plaintiff
if not exists (
	 select
		 *
	 from sma_MST_IndvContacts
	 where [cinsFirstName] = 'Plaintiff'
		 and [cinsLastName] = 'Unidentified'
	)
begin
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
			[saga],
			[cinsSpouse],
			[cinsGrade]
		)

		select
			1,
			10,
			null,
			'',
			'Plaintiff',
			'',
			'Unidentified',
			null,
			null,
			1,
			null,
			null,
			null,
			1,
			'',
			'',
			null,
			'',
			'',
			1,
			'',
			1,
			1,
			null,
			null,
			'',
			'',
			null,
			0,
			368,
			GETDATE(),
			'',
			null,
			0,
			'',
			'',
			'',
			'',
			null + null,
			null,
			'',
			null,
			'',
			'',
			'',
			'',
			'',
			'',
			null
end

go

-- Unidentified Defendant
if not exists (
	 select
		 *
	 from sma_MST_IndvContacts
	 where [cinsFirstName] = 'Defendant'
		 and [cinsLastName] = 'Unidentified'
	)
begin
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
			[saga],
			[cinsSpouse],
			[cinsGrade]
		)

		select distinct
			1,
			10,
			null,
			'',
			'Defendant',
			'',
			'Unidentified',
			null,
			null,
			1,
			null,
			null,
			null,
			1,
			'',
			'',
			null,
			'',
			'',
			1,
			'',
			1,
			1,
			null,
			null,
			'',
			'',
			null,
			0,
			368,
			GETDATE(),
			'',
			null,
			0,
			'',
			'',
			'',
			'',
			null + null,
			null,
			'',
			null,
			'',
			'',
			'',
			'',
			'',
			'',
			null
end

go

--Insert from [names]
insert into [sma_MST_IndvContacts]
	(
		[cinsPrefix],
		[cinsSuffix],
		[cinsFirstName],
		[cinsMiddleName],
		[cinsLastName],
		[cinsHomePhone],
		[cinsWorkPhone],
		[cinsSSNNo],
		[cindBirthDate],
		[cindDateOfDeath],
		[cinnGender],
		[cinsMobile],
		[cinsComments],
		[cinnContactCtg],
		[cinnContactTypeID],
		[cinnContactSubCtgID],
		[cinnRecUserID],
		[cindDtCreated],
		[cinbStatus],
		[cinbPreventMailing],
		[cinsNickName],
		[cinsPrimaryLanguage],
		[cinsOtherLanguage],
		[cinnRace],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		LEFT(n.[prefix], 20)					 as [cinsprefix],
		LEFT(n.[suffix], 10)					 as [cinssuffix],
		CONVERT(VARCHAR(30), n.[first_name])	 as [cinsfirstname],
		CONVERT(VARCHAR(30), n.[initial])		 as [cinsmiddlename],
		CONVERT(VARCHAR(40), n.[last_long_name]) as [cinslastname],
		LEFT(n.[home_phone], 20)				 as [cinshomephone],
		LEFT(n.[work_phone], 20)				 as [cinsworkphone],
		LEFT(n.[ss_number], 20)					 as [cinsssnno],
		case
			when (n.[date_of_birth] not between '1900-01-01' and '2079-12-31') then GETDATE()
			else n.[date_of_birth]
		end										 as [cindbirthdate],
		case
			when (n.[date_of_death] not between '1900-01-01' and '2079-12-31') then GETDATE()
			else n.[date_of_death]
		end										 as [cinddateofdeath],
		case
			when n.[sex] = 'M' then 1
			when n.[sex] = 'F' then 2
			else 0
		end										 as [cinngender],
		LEFT(n.[car_phone], 20)					 as [cinsmobile],
		case
			when ISNULL(n.[fax_number], '') <> '' then 'FAX NUMBER: ' + n.[fax_number]
			else null
		end										 as [cinscomments],
		1										 as [cinncontactctg],
		(
		 select
			 octnOrigContactTypeID
		 from [sma_MST_OriginalContactTypes]
		 where octsDscrptn = 'General'
			 and octnContactCtgID = 1
		)										 as [cinncontacttypeid],
		case
			-- if names.deceased = "Y", then grab the contactSubCategoryID for "Deceased"
			when n.[deceased] = 'Y' then (
					 select
						 cscnContactSubCtgID
					 from [sma_MST_ContactSubCategory]
					 where cscsDscrptn = 'Deceased'
					)
			-- if incapacitated = "Y" on the [party_Indexed] table, then grab the contactSubCategoryID for "Incompetent"
			when exists (
				 select
					 *
				 from [Needles].[dbo].[party_Indexed] p
				 where p.party_id = n.names_id
					 and p.incapacitated = 'Y'
				) then (
					 select
						 cscnContactSubCtgID
					 from [sma_MST_ContactSubCategory]
					 where cscsDscrptn = 'Incompetent'
					)
			-- if minor = "Y" on the [party_Indexed] table, then grab the contactSubCategoryID for "Infant"
			-- otherwise, grab the contactSubCategoryID for "Adult"
			when exists (
				 select
					 *
				 from [Needles].[dbo].[party_Indexed] p
				 where p.party_id = n.names_id
					 and p.minor = 'Y'
				) then (
					 select
						 cscnContactSubCtgID
					 from [sma_MST_ContactSubCategory]
					 where cscsDscrptn = 'Infant'
					)
			else (
				 select
					 cscnContactSubCtgID
				 from [sma_MST_ContactSubCategory]
				 where cscsDscrptn = 'Adult'
				)
		end										 as cinncontactsubctgid,
		368										 as cinnrecuserid,
		GETDATE()								 as cinddtcreated,
		1										 as [cinbstatus],
		0										 as [cinbpreventmailing],
		CONVERT(VARCHAR(15), aka_full)			 as [cinsnickname],
		null									 as [cinsprimarylanguage],
		null									 as [cinsotherlanguage],
		case
			when ISNULL(n.race, '') <> '' then (
					 select
						 RaceID
					 from sma_mst_ContactRace
					 where RaceDesc = r.race_name
					)
			else null
		end										 as cinnrace,
		n.[names_id]							 as saga,
		null									 as source_id,
		'needles'								 as source_db,
		'names'									 as source_ref
	from [Needles].[dbo].[names] n
	left join [Needles].[dbo].[Race] r
		on r.race_id = case
				when ISNUMERIC(n.race) = 1 then CONVERT(INT, n.race)
				else null
			end
	where
		n.[person] = 'Y'
go

-- Insert from [police]
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
		[cinsSpouse],
		[cinsGrade],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select distinct
		1							 as [cinbprimary],
		(
		 select
			 octnOrigContactTypeID
		 from [dbo].[sma_MST_OriginalContactTypes]
		 where octsDscrptn = 'Police Officer'
		)							 as [cinncontacttypeid],
		null						 as [cinncontactsubctgid],
		'Officer'					 as [cinsprefix],
		dbo.get_firstword(p.officer) as [cinsfirstname],
		''							 as [cinsmiddlename],
		dbo.get_lastword(p.officer)	 as [cinslastname],
		null						 as [cinssuffix],
		null						 as [cinsnickname],
		1							 as [cinbstatus],
		null						 as [cinsssnno],
		null						 as [cindbirthdate],
		null						 as [cinscomments],
		1							 as [cinncontactctg],
		''							 as [cinnrefbyctgid],
		''							 as [cinnreferredby],
		null						 as [cinddateofdeath],
		''							 as [cinscvlink],
		''							 as [cinnmaritalstatusid],
		1							 as [cinngender],
		''							 as [cinsbirthplace],
		1							 as [cinncountyid],
		1							 as [cinscountyofresidence],
		null						 as [cinbflagforphoto],
		null						 as [cinsprimarycontactno],
		''							 as [cinshomephone],
		''							 as [cinsworkphone],
		null						 as [cinsmobile],
		0							 as [cinbpreventmailing],
		368							 as [cinnrecuserid],
		GETDATE()					 as [cinddtcreated],
		''							 as [cinnmodifyuserid],
		null						 as [cinddtmodified],
		0							 as [cinnlevelno],
		''							 as [cinsprimarylanguage],
		''							 as [cinsotherlanguage],
		''							 as [cinbdeathflag],
		''							 as [cinscitizenship],
		null + null					 as [cinsheight],
		null						 as [cinnweight],
		''							 as [cinsreligion],
		null						 as [cindmarriagedate],
		null						 as [cinsmarriageloc],
		null						 as [cinsdeathplace],
		''							 as [cinsmaidenname],
		''							 as [cinsoccupation],
		''							 as [cinsspouse],
		null						 as [cinsgrade],
		null						 as [saga],
		p.officer					 as [source_id],
		'needles'					 as [source_db],
		'police'					 as [source_ref]
	from [Needles].[dbo].[police] p
	where
		ISNULL(officer, '') <> ''
go



-- Insert from [insurance]
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
		[cinsSpouse],
		[cinsGrade],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select distinct
		1					  as [cinbprimary],
		10					  as [cinncontacttypeid],
		null				  as [cinncontactsubctgid],
		''					  as [cinsprefix],
		''					  as [cinsfirstname],
		''					  as [cinsmiddlename],
		LEFT(ins.insured, 40) as [cinslastname],
		null				  as [cinssuffix],
		null				  as [cinsnickname],
		1					  as [cinbstatus],
		null				  as [cinsssnno],
		null				  as [cindbirthdate],
		null				  as [cinscomments],
		1					  as [cinncontactctg],
		''					  as [cinnrefbyctgid],
		''					  as [cinnreferredby],
		null				  as [cinddateofdeath],
		''					  as [cinscvlink],
		''					  as [cinnmaritalstatusid],
		1					  as [cinngender],
		''					  as [cinsbirthplace],
		1					  as [cinncountyid],
		1					  as [cinscountyofresidence],
		null				  as [cinbflagforphoto],
		null				  as [cinsprimarycontactno],
		''					  as [cinshomephone],
		''					  as [cinsworkphone],
		null				  as [cinsmobile],
		0					  as [cinbpreventmailing],
		368					  as [cinnrecuserid],
		GETDATE()			  as [cinddtcreated],
		''					  as [cinnmodifyuserid],
		null				  as [cinddtmodified],
		0					  as [cinnlevelno],
		''					  as [cinsprimarylanguage],
		''					  as [cinsotherlanguage],
		''					  as [cinbdeathflag],
		''					  as [cinscitizenship],
		null + null			  as [cinsheight],
		null				  as [cinnweight],
		''					  as [cinsreligion],
		null				  as [cindmarriagedate],
		null				  as [cinsmarriageloc],
		null				  as [cinsdeathplace],
		''					  as [cinsmaidenname],
		''					  as [cinsoccupation],
		''					  as [cinsspouse],
		null				  as [cinsgrade],
		null				  as [saga],
		ins.insured			  as [source_id],
		'needles'			  as [source_db],
		'insurance'			  as [source_ref]
	from [Needles].[dbo].[insurance] ins
	where
		ISNULL(insured, '') <> ''
go

/* ------------------------------------------------------------------------------
Update contact comments
*/ ------------------------------------------------------------------------------

-- Age
update sma_MST_IndvContacts
set cinsComments = ISNULL(cinsComments, '') + CHAR(13) + 'Age : ' + CONVERT(VARCHAR, A.Age)
from (
 select
	 p.case_id														 as caseid,
	 p.party_id														 as partyid,
	 DATEPART(yyyy, GETDATE()) - DATEPART(yyyy, n.date_of_birth) - 1 as age

 from [Needles].[dbo].[party_Indexed] p
 join [Needles].[dbo].[names] n
	 on n.names_id = p.party_id
 where n.date_of_birth is not null
) a
where a.partyid = saga
go

-- Age at date of incident
update sma_MST_IndvContacts
set cinsComments = ISNULL(cinsComments, '') + CHAR(13) + 'Age at DOI : ' + CONVERT(VARCHAR, A.DOI)
from (
 select
	 p.case_id																  as caseid,
	 p.party_id																  as partyid,
	 DATEPART(yyyy, c.date_of_incident) - DATEPART(yyyy, n.date_of_birth) - 1 as doi
 from [Needles].[dbo].[party_Indexed] p
 join [Needles].[dbo].[names] n
	 on n.names_id = p.party_id
 join [Needles].[dbo].[cases] c
	 on c.casenum = p.case_id
 where c.date_of_incident is not null
	 and n.date_of_birth is not null
) a
where a.partyid = saga
go

-- Deceased
update sma_MST_IndvContacts
set cinsComments = ISNULL(cinsComments, '') + CHAR(13) + 'Deceased : ' + CONVERT(VARCHAR, A.Deceased)
from (
 select
	 p.case_id  as caseid,
	 p.party_id as partyid,
	 n.deceased as deceased
 from [Needles].[dbo].[party_Indexed] p
 join [Needles].[dbo].[names] n
	 on n.names_id = p.party_id
 where n.deceased is not null
) a
where a.partyid = saga
go

-- Date of death
update sma_MST_IndvContacts
set cinsComments = ISNULL(cinsComments, '') + CHAR(13) + 'Date of Death : ' + CONVERT(VARCHAR, A.DOD)
from (
 select
	 p.case_id						 as caseid,
	 p.party_id						 as partyid,
	 DATEPART(yyyy, n.date_of_death) as dod
 from [Needles].[dbo].[party_Indexed] p
 join [Needles].[dbo].[names] n
	 on n.names_id = p.party_id
 where n.date_of_death is not null
) a
where a.partyid = saga
go

-- Incapacitated
update sma_MST_IndvContacts
set cinsComments = ISNULL(cinsComments, '') + CHAR(13) + 'Incapacitated : ' + CONVERT(VARCHAR, A.incapacitated)
from (
 select
	 p.case_id		 as caseid,
	 p.party_id		 as partyid,
	 p.incapacitated as incapacitated
 from [Needles].[dbo].[party_Indexed] p
 join [Needles].[dbo].[names] n
	 on n.names_id = p.party_id
 where ISNULL(incapacitated, '') <> ''
) a
where a.partyid = saga
go

-- Incapacity
update sma_MST_IndvContacts
set cinsComments = ISNULL(cinsComments, '') + CHAR(13) + 'Incapacity : ' + CONVERT(VARCHAR, A.incapacity)
from (
 select
	 p.case_id	  as caseid,
	 p.party_id	  as partyid,
	 p.incapacity as incapacity
 from [Needles].[dbo].[party_Indexed] p
 join [Needles].[dbo].[names] n
	 on n.names_id = p.party_id
 where ISNULL(incapacity, '') <> ''
) a
where a.partyid = saga
go

-- Responsible for another party
update sma_MST_IndvContacts
set cinsComments = ISNULL(cinsComments, '') + CHAR(13) + 'Responsible for another party : ' + CONVERT(VARCHAR, A.responsibility)
from (
 select
	 p.case_id		  as caseid,
	 p.party_id		  as partyid,
	 p.responsibility as responsibility
 from [Needles].[dbo].[party_Indexed] p
 join [Needles].[dbo].[names] n
	 on n.names_id = p.party_id
 where ISNULL(p.responsibility, '') <> ''
) a
where a.partyid = saga

---
alter table [sma_MST_IndvContacts] enable trigger all
go
---