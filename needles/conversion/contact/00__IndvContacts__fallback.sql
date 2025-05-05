/*---
group: setup
order:
description:
---*/

/* ###################################################################################
description: Create unidentified contacts to be used as fallbacks where applicable
steps:
	- Insert [sma_MST_IndvContacts] fallback contacts
		- Unassigned Staff
		- Unidentified Individual
		- Unidentified Plaintiff
		- Unidentified Defendant
usage_instructions:
	-
dependencies:
	- 
notes:
	-
*/

use VanceLawFirm_SA
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