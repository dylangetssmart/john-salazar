SELECT * FROM ShinerLitify..litify_pm__Intake__c lpic where lpic.Name = 'INT-25032018947' --lpic.litify_pm__Display_Name__c like '%yeny%'
-- id: a0CNt00002P5UybMAF
-- client: 0018Z00002rz0a1QAA

SELECT * FROM ShinerLitify..Account a where a.Id = '0018Z00002rz0a1QAA'
SELECT * FROM ShinerLitify..Account a where a.Id = '0018Z00002rz0cuQAA'

SELECT * FROM sma_TRN_Cases stc where stc.cassCaseNumber = 'INT-25032018947'
SELECT * FROM sma_TRN_Cases stc where stc.saga_char = 'a0CNt00002P5UybMAF'

SELECT * FROM IndvOrgContacts_Indexed ioci where cid = 19096 -- ioci.saga_char = '0018Z00002rz0a1QAA'
SELECT * FROM IndvOrgContacts_Indexed ioci where name like '%veny%'

select * 
from [ShinerLitify]..[litify_pm__intake__c] m
	join [sma_TRN_cases] CAS
		on CAS.saga_char = m.id
	--join [sma_MST_SubRole] S
	--	on CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID
	join IndvOrgContacts_Indexed CIO 
		on CIO.saga_char = m.litify_pm__Client__c
	where
		--s.sbrnRoleID = 4
		--and s.sbrsDscrptn = '(P)-Plaintiff'
		 m.Id = 'a0CNt00002P5UybMAF'

-- how many intake cases don't have a plaintiff?
SELECT *
from sma_TRN_Cases cas
LEFT join sma_TRN_Plaintiff p
on p.plnnCaseID = cas.casnCaseID
where p.plnnPlaintiffID is null
and cas.source_ref = 'litify_pm__intake__c'
-- 13,762



/* ---------------------------------------------------------------------------------------------------------------
find contacts from [litify_pm__Role__c]:
- tied to intake cases that are missing a plaintiff
- no associated ioci record
- 
- 
*/

-- 13769
select
	count(*)
from ShinerLitify..litify_pm__Role__c role
join ShinerLitify..litify_pm__Intake__c i
	on role.litify_pm__Intake__c = i.Id
join sma_TRN_Cases cas
	on cas.saga_char = i.Id
join ShinerLitify..Account a
		on a.Id = role.litify_pm__Party__c
left join sma_TRN_Plaintiff p
	on p.plnnCaseID = cas.casnCaseID
left join IndvOrgContacts_Indexed ioci
	on ioci.saga_char = role.litify_pm__Party__c
where
	p.plnnPlaintiffID is null
	and ioci.cid is null
	and role.litify_pm__Intake__c is not null
	and role.litify_pm__Role__c in ('client')


/* ---------------------------------------------------------------------------------------------------------------
Create contacts
*/
alter table [sma_MST_IndvContacts] disable trigger all
go

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
		(
			select
				octnOrigContactTypeID
			from sma_MST_OriginalContactTypes
			where octnContactCtgID = 1
				and octsDscrptn = 'General Unspecified'
		)									 as [cinncontacttypeid],
		null								 as [cinncontactsubctgid],
		litify_pm__Salutation__c			 as [cinsprefix],
		a.litify_pm__First_Name__c			 as [cinsfirstname],	--30
		''									 as [cinsmiddlename],  --30
		a.litify_pm__Last_Name__c			 as [cinslastname],  --40
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
		null								 as [cinsspouse],
		null								 as [cinsgrade],
		'litify'							 as [source_db],
		'role: missing intake'				 as [source_ref]
	--select *
	from ShinerLitify..litify_pm__Role__c role
	join ShinerLitify..litify_pm__Intake__c i
		on role.litify_pm__Intake__c = i.Id
	join sma_TRN_Cases cas
		on cas.saga_char = i.Id
	join ShinerLitify..Account a
		on a.Id = role.litify_pm__Party__c
	join ShinerLitify..RecordType rt
		on a.RecordTypeId = LEFT(rt.Id, 15)
			and rt.SobjectType = 'Account'
	left join sma_TRN_Plaintiff p
		on p.plnnCaseID = cas.casnCaseID
	--left join IndvOrgContacts_Indexed ioci
	--	on ioci.saga_char = role.litify_pm__Party__c
	left join sma_MST_IndvContacts ind
		on ind.saga_char = a.Id
	where
		p.plnnPlaintiffID is null
		--and ioci.cid is null
		and ind.cinnContactID is null
		and role.litify_pm__Intake__c is not null
		and role.litify_pm__Role__c in ('client')
		and rt.[Name] = 'Litify Individual'
		and ISNULL(a.litify_pm__Last_Name__c, '') <> ''
go

alter table sma_MST_IndvContacts enable trigger all