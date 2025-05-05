/* ###################################################################################
description: Create unidentified contacts to be used as fallbacks where applicable
steps:
	- Insert [sma_MST_IndvContacts] fallback contacts
		- Unassigned Staff
		- Unidentified Individual
		- Unidentified Plaintiff
		- Unidentified Defendant
	- Insert [sma_MST_OrgContacts] fallback contacts
		- Unidentified Medical Provider
		- Unidentified Insurance
		- Unidentified Court
		- Unidentified Lienor
		- Unidentified School
		- Unidentified Employer
usage_instructions:
	-
dependencies:
	- 
notes:
	-
*/

use ShinerSA
go


/* --------------------------------------------------------------------------------------------------------------
[sma_MST_IndvContacts] Unidentified Contacts
*/

---------------------------------------------------
-- [1] Unidentified Staff
---------------------------------------------------
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

---------------------------------------------------
-- [2] Unidentified Individual
---------------------------------------------------

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

---------------------------------------------------
-- [3] Unidentified Plaintiff
---------------------------------------------------

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

---------------------------------------------------
-- [4] Unidentified Defendant
---------------------------------------------------

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


/* --------------------------------------------------------------------------------------------------------------
[sma_MST_OrgContacts] Unidentified Contacts
*/

---------------------------------------------------
-- [1] - Unidentified Medical Provider
---------------------------------------------------
if not exists (
		select
			*
		from [sma_MST_OrgContacts]
		where consName = 'Unidentified Medical Provider'
	)
begin
	insert into [sma_MST_OrgContacts]
		(
		[consName], [connContactCtg], [connContactTypeID], [connRecUserID], [condDtCreated]
		)
		select
			'Unidentified Medical Provider' as [consname],
			2								as [conncontactctg],
			(
				select
					octnOrigContactTypeID
				from [sma_MST_OriginalContactTypes]
				where octnContactCtgID = 2
					and octsDscrptn = 'Hospital'
			)								as [conncontacttypeid],
			368								as [connrecuserid],
			GETDATE()						as [conddtcreated]
end
go

---------------------------------------------------
-- [2] - Unidentified Insurance
---------------------------------------------------
if not exists (
		select
			*
		from [sma_MST_OrgContacts]
		where consName = 'Unidentified Insurance'
	)
begin
	insert into [sma_MST_OrgContacts]
		(
		[consName], [connContactCtg], [connContactTypeID], [connRecUserID], [condDtCreated]
		)
		select
			'Unidentified Insurance' as [consname],
			2						 as [conncontactctg],
			(
				select
					octnOrigContactTypeID
				from [sma_MST_OriginalContactTypes]
				where octnContactCtgID = 2
					and octsDscrptn = 'Insurance Company'
			)						 as [conncontacttypeid],
			368						 as [connrecuserid],
			GETDATE()				 as [conddtcreated]
end
go

---------------------------------------------------
-- [3] - Unidentified Court
---------------------------------------------------
if not exists (
		select
			*
		from [sma_MST_OrgContacts]
		where consName = 'Unidentified Court'
	)
begin
	insert into [sma_MST_OrgContacts]
		(
		[consName], [connContactCtg], [connContactTypeID], [connRecUserID], [condDtCreated]
		)
		select
			'Unidentified Court' as [consname],
			2					 as [conncontactctg],
			(
				select
					octnOrigContactTypeID
				from [sma_MST_OriginalContactTypes]
				where octnContactCtgID = 2
					and octsDscrptn = 'Court'
			)					 as [conncontacttypeid],
			368					 as [connrecuserid],
			GETDATE()			 as [conddtcreated]
end
go

---------------------------------------------------
-- [4] - Unidentified Lienor
---------------------------------------------------
if not exists (
		select
			*
		from [sma_MST_OrgContacts]
		where consName = 'Unidentified Lienor'
	)
begin
	insert into [sma_MST_OrgContacts]
		(
		[consName], [connContactCtg], [connContactTypeID], [connRecUserID], [condDtCreated]
		)
		select
			'Unidentified Lienor' as [consname],
			2					  as [conncontactctg],
			(
				select
					octnOrigContactTypeID
				from [sma_MST_OriginalContactTypes]
				where octnContactCtgID = 2
					and octsDscrptn = 'General'
			)					  as [conncontacttypeid],
			368					  as [connrecuserid],
			GETDATE()			  as [conddtcreated]
end
go

---------------------------------------------------
-- [5] - Unidentified School
---------------------------------------------------
if not exists (
		select
			*
		from [sma_MST_OrgContacts]
		where consName = 'Unidentified School'
	)
begin
	insert into [sma_MST_OrgContacts]
		(
		[consName], [connContactCtg], [connContactTypeID], [connRecUserID], [condDtCreated]
		)
		select
			'Unidentified School' as [consname],
			2					  as [conncontactctg],
			(
				select
					octnOrigContactTypeID
				from [sma_MST_OriginalContactTypes]
				where octnContactCtgID = 2
					and octsDscrptn = 'General'
			)					  as [conncontacttypeid],
			368					  as [connrecuserid],
			GETDATE()			  as [conddtcreated]
end
go

---------------------------------------------------
-- [6] - Unidentified Employer
---------------------------------------------------
if not exists (
		select
			*
		from [sma_MST_OrgContacts]
		where consName = 'Unidentified Employer'
	)
begin
	insert into [sma_MST_OrgContacts]
		(
		[consName], [connContactCtg], [connContactTypeID], [connRecUserID], [condDtCreated]
		)
		select
			'Unidentified Employer' as [consname],
			2					  as [conncontactctg],
			(
				select
					octnOrigContactTypeID
				from [sma_MST_OriginalContactTypes]
				where octnContactCtgID = 2
					and octsDscrptn = 'General'
			)					  as [conncontacttypeid],
			368					  as [connrecuserid],
			GETDATE()			  as [conddtcreated]
end
go

