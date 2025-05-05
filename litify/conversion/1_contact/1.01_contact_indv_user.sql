/*
create individual contacts from litifty.user
join to sma_mst_users ensures that contacts already linked to user records are not re-created
*/

use ShinerSA
go

alter table [sma_MST_IndvContacts] disable trigger all
go

---------------------------------------------------
-- Create Individual contacts from [user]
---------------------------------------------------
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
		[saga_char],
		[cinsSpouse],
		[cinsGrade],
		[source_db],
		[source_ref]
	)
	select distinct
		1		  as [cinbprimary],
		10		  as [cinncontacttypeid],
		null,
		'',
		FirstName as [cinsfirstname],
		''		  as [cinsmiddlename],
		LastName  as [cinslastname],
		null	  as [cinssuffix],
		null	  as [cinsnickname],
		1		  as [cinbstatus],
		null	  as [cinsssnno],
		null	  as [cindbirthdate],
		null	  as [cinscomments],
		1		  as [cinncontactctg],
		'',
		'',
		null,
		'',
		'',
		0		  as [cinngender],
		'',
		1,
		1,
		null,
		null,
		'',
		'',
		null,
		0,
		368		  as [cinnrecuserid],
		GETDATE() as [cinddtcreated],
		'',
		null,
		0,
		'',
		'',
		'',
		'',
		null,
		null,
		'',
		null,
		'',
		'',
		'',
		u.Title	  as [cinsoccupation],
		u.[Id]	  as [saga_char],
		''		  as [cinsspouse],
		null	  as [cinsgrade],
		'litify'  as [source_db],
		'user'	  as [source_ref]
	--select *
	from ShinerLitify..[User] u
	left join shinersa..[sma_MST_IndvContacts] ind
		on ind.saga_char = u.[Id]
	where
		ind.cinnContactID is null

--		FROM implementation_users STF
--JOIN sma_MST_IndvContacts INDV
--	ON INDV.cinsGrade = STF.staffcode
--LEFT JOIN [sma_MST_Users] u
--	ON u.saga = CONVERT(VARCHAR(20), STF.staffcode)
--WHERE u.usrsLoginID IS NULL

alter table sma_MST_IndvContacts enable trigger all
go