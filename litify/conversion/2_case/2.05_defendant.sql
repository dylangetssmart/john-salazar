/* ######################################################################################
description: Insert defendants
steps:
	- Defendants from matter
	- Defendants from party roles
	- at least one defendant
	- one primary defendant
usage_instructions:
	-
dependencies:
	- 
notes:
	-
#########################################################################################
*/

use ShinerSA
go

alter table [sma_TRN_Defendants] disable trigger all
go

----------------------------------------------
-- Defendants from Matter
-- matter.litify_pm__OpposingParty__c
----------------------------------------------
insert into [sma_TRN_Defendants]
	(
	[defnCaseID],
	[defnContactCtgID],
	[defnContactID],
	[defnAddressID],
	[defnSubRole],
	[defbIsPrimary],
	[defbCounterClaim],
	[defbThirdParty],
	[defsThirdPartyRole],
	[defnPriority],
	[defdFrmDt],
	[defdToDt],
	[defnRecUserID],
	[defdDtCreated],
	[defnModifyUserID],
	[defdDtModified],
	[defnLevelNo],
	[defsMarked],
	[saga],
	defbIsClient
	)
	select distinct
		cas.casnCaseID  as [defncaseid],
		cio.ctg			as [defncontactctgid],
		cio.cid			as [defncontactid],
		cio.aid			as [defnaddressid],
		s.sbrnSubRoleId as [defnsubrole],
		1				as [defbisprimary],
		null,
		null,
		null,
		null,
		null,
		null,
		368				as [defnrecuserid],
		GETDATE()		as [defddtcreated],
		null			as [defnmodifyuserid],
		null			as [defddtmodified],
		null,
		null,
		null,
		0				as defbisclient
	from ShinerLitify..litify_pm__Matter__c m
	join [sma_TRN_cases] cas
		on cas.saga_char = m.id
	join [sma_MST_SubRole] s
		on cas.casnOrgCaseTypeID = s.sbrnCaseTypeID
			and s.sbrnRoleID = 5
			and s.sbrsDscrptn = '(D)-Defendant'
	join IndvOrgContacts_Indexed cio
		on cio.saga_char = m.litify_pm__OpposingParty__c
	-- Exclude existing defendants
	left join [sma_TRN_Defendants] d
		on d.defncaseid = cas.casnCaseID
			and d.defncontactctgid = cio.ctg
			and d.defncontactid = cio.cid
	where d.defncaseid is null
	--and cas.casnCaseID = 3093

----------------------------------------------
-- Defendants from [litify_pm__Matter__c].[Defendant]
-- standard
----------------------------------------------
insert into [sma_TRN_Defendants]
	(
	[defnCaseID],
	[defnContactCtgID],
	[defnContactID],
	[defnAddressID],
	[defnSubRole],
	[defbIsPrimary],
	[defbCounterClaim],
	[defbThirdParty],
	[defsThirdPartyRole],
	[defnPriority],
	[defdFrmDt],
	[defdToDt],
	[defnRecUserID],
	[defdDtCreated],
	[defnModifyUserID],
	[defdDtModified],
	[defnLevelNo],
	[defsMarked],
	[saga],
	defbIsClient
	)
	select distinct
		cas.casnCaseID  as [defncaseid],
		cio.ctg			as [defncontactctgid],
		cio.cid			as [defncontactid],
		cio.aid			as [defnaddressid],
		s.sbrnSubRoleId as [defnsubrole],
		1				as [defbisprimary],
		null,
		null,
		null,
		null,
		null,
		null,
		368				as [defnrecuserid],
		GETDATE()		as [defddtcreated],
		null			as [defnmodifyuserid],
		null			as [defddtmodified],
		null,
		null,
		null,
		0				as defbisclient
	--FROM  (SELECT id as matterID, Primary_Defendant__c as Defendant, 'Primary Defendant' as [type] FROM ShinerLitify..litify_pm__Matter__c  WHERE isnull(Primary_Defendant__c,'')<>'' --or isnull(Legacy_Plaintiff__c,'') <>''
	--	UNION
	from (
		select
			litify_pm__Matter__c,
			litify_pm__Party__c as defendant,
			case
				when litify_pm__role__c = 'Defendant Driver'
					then '(D)-Driver'
				when litify_pm__role__c = 'Defendant Owner'
					then '(D)-Owner'
				when litify_pm__role__c = 'Respondent'
					then '(D)-Respondent'
				else '(D)-' + litify_pm__role__c
			end as [role]
		from ShinerLitify..litify_pm__role__c
		where litify_pm__role__c in ('Defendant')
	) m
	join sma_trn_Cases cas
		on cas.saga_char = m.litify_pm__Matter__c
	join [sma_MST_SubRole] s
		on cas.casnOrgCaseTypeID = s.sbrnCaseTypeID
			and s.sbrsDscrptn = m.[role]
			and s.sbrnRoleID = 5
	join IndvOrgContacts_Indexed cio
		on cio.saga_char = m.defendant
	-- Exclude existing defendants
	left join [sma_TRN_Defendants] d
		on d.defncaseid = cas.casnCaseID
			and d.defncontactctgid = cio.ctg
			and d.defncontactid = cio.cid
	where d.defncaseid is null;
go

----------------------------------------------
-- Defendants from Party Role Mapping
-- [litify_pm__role__c].[litify_pm__role__c]
-- Expected: 78
----------------------------------------------
insert into [sma_TRN_Defendants]
	(
	[defnCaseID],
	[defnContactCtgID],
	[defnContactID],
	[defnAddressID],
	[defnSubRole],
	[defbIsPrimary],
	[defbCounterClaim],
	[defbThirdParty],
	[defsThirdPartyRole],
	[defnPriority],
	[defdFrmDt],
	[defdToDt],
	[defnRecUserID],
	[defdDtCreated],
	[defnModifyUserID],
	[defdDtModified],
	[defnLevelNo],
	[defsMarked],
	[saga],
	defbIsClient
	)
	select distinct
		cas.casnCaseID  as [defncaseid],
		cio.ctg			as [defncontactctgid],
		cio.cid			as [defncontactid],
		cio.aid			as [defnaddressid],
		s.sbrnSubRoleId as [defnsubrole],
		1				as [defbisprimary],
		null,
		null,
		null,
		null,
		null,
		null,
		368				as [defnrecuserid],
		GETDATE()		as [defddtcreated],
		null			as [defnmodifyuserid],
		null			as [defddtmodified],
		null,
		null,
		null,
		0				as defbisclient
	from ShinerLitify..litify_pm__role__c m
	join [sma_TRN_cases] cas
		on cas.saga_char = m.litify_pm__Matter__c
	join [sma_MST_SubRole] s
		on cas.casnOrgCaseTypeID = s.sbrnCaseTypeID
			and s.sbrnRoleID = 5
			and s.sbrsDscrptn = '(D)-Defendant'
	join IndvOrgContacts_Indexed cio
		on cio.saga_char = m.litify_pm__Party__c
	-- add defendants table so that we don't add any that already exist
	left join [sma_TRN_Defendants] d
		on d.defncaseid = cas.casnCaseID
			and d.defncontactctgid = cio.ctg
			and d.defncontactid = cio.cid
	where m.litify_pm__role__c in ('Defendant')
		and d.defncaseid is null; -- Exclude existing defendants

go

----------------------------------------------------------------
---(APPENDIX B)-- EVERY CASE NEED AT LEAST ONE DEFENDANT
----------------------------------------------------------------
insert into [sma_TRN_Defendants]
	(
	[defnCaseID],
	[defnContactCtgID],
	[defnContactID],
	[defnAddressID],
	[defnSubRole],
	[defbIsPrimary],
	[defbCounterClaim],
	[defbThirdParty],
	[defsThirdPartyRole],
	[defnPriority],
	[defdFrmDt],
	[defdToDt],
	[defnRecUserID],
	[defdDtCreated],
	[defnModifyUserID],
	[defdDtModified],
	[defnLevelNo],
	[defsMarked],
	[saga]
	)
	select
		casnCaseID as [defncaseid],
		1		   as [defncontactctgid],
		(
			select
				cinnContactID
			from sma_MST_IndvContacts
			where cinsFirstName = 'Defendant'
				and cinsLastName = 'Unidentified'
		)		   as [defncontactid],
		null	   as [defnaddressid],
		(
			select
				sbrnSubRoleId
			from sma_MST_SubRole s
			join sma_MST_SubRoleCode c
				on c.srcnCodeId = s.sbrnTypeCode
				and c.srcsDscrptn = '(D)-Defendant'
			where s.sbrnCaseTypeID = cas.casnOrgCaseTypeID
		)		   as [defnsubrole],
		1		   as [defbisprimary], -- reexamine??
		null,
		null,
		null,
		null,
		null,
		null,
		368		   as [defnrecuserid],
		GETDATE()  as [defddtcreated],
		368		   as [defnmodifyuserid],
		GETDATE()  as [defddtmodified],
		null,
		null,
		null
	from sma_trn_cases cas
	left join [sma_TRN_Defendants] d
		on d.defncaseid = cas.casnCaseID
	where d.defncaseid is null
go

----------------------------------------
--ONLY ONE PRIMARY DEFENDANT
----------------------------------------
update sma_TRN_Defendants
set defbIsPrimary = 0
go

update sma_TRN_Defendants
set defbIsPrimary = 1
from (
	select distinct
		d.defnCaseID,
		ROW_NUMBER() over (partition by d.defnCaseID order by d.defnDefendentID asc) as rownumber,
		d.defnDefendentID as id
	from sma_TRN_Defendants d
) a
where a.rownumber = 1
and defnDefendentID = a.id
go

alter table [sma_TRN_Defendants] enable trigger all
go