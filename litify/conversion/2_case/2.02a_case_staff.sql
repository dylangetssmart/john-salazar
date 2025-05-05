/* ###################################################################################

1. create roles:
- Paralegal
- Principal Attorney
- Case Manager

2. Add case staff
- litify_pm__Principal_Attorney__c
- Paralegal__c
- litify_pm__lit_Case_Manager__c


Litify					SA
-------------------------------------------------------------------
Principal Attorney		'1. Attorney, Assigned'
Case Manager			'Case Manager, Presuit'
Paralegal				'4 Litigation Paralegal'
Legal Assistant			'Legal Assistant, Presuit'


- Reference
	- https://smartadvocate.atlassian.net/wiki/spaces/Conversion/pages/2436366355/SmartAdvocate#Case-Roles
##########################################################################################################################
*/

use ShinerSA
go

/* ---------------------------------------------------------------------------------------------------------------
Sub Roles
*/

-- Insert SubRoleCode
insert into sma_mst_SubRoleCode
	(
		srcsDscrptn,
		srcnRoleID
	)
	select
		v.srcsDscrptn,
		v.srcnRoleID
	from (
		select
			--	'Paralegal' as srcsdscrptn,
			--	10 as srcnroleid
			--union all
			--select
			--	'Principal Attorney',
			--	10
			--union all
			--select
			--	'Case Manager',
			--	10

			-- ds 2025-03-14 updated roles
			'4 Litigation Paralegal' as srcsdscrptn,
			10						 as srcnroleid
		union all
		select
			'1. Attorney, Assigned',
			10
		union all
		select
			'Case Manager, Presuit ',
			10
	) v
	except
	select
		srcsDscrptn,
		srcnRoleID
	from sma_mst_SubRoleCode;
go

-- Insert SubRole
-- sbrnTypeCode = SubRoleCode.srcnCodeId
insert into sma_MST_SubRole
	(
	sbrnRoleID,
	sbrsDscrptn,
	sbrnTypeCode
	)
	select
		v.srcnroleid,
		v.srcsdscrptn,
		v.srcntypecode
	from (
		-- Paralegal
		select
			10 as srcnroleid,
			'4 Litigation Paralegal' as srcsdscrptn,
			(
				select
					srcnCodeId
				from sma_mst_SubRoleCode
				where srcnroleid = 10
					and srcsdscrptn = '4 Litigation Paralegal'
			) as srcntypecode
		union all
		-- Principal Attorney
		select
			10 as srcnroleid,
			'1. Attorney, Assigned' as srcsdscrptn,
			(
				select
					srcnCodeId
				from sma_mst_SubRoleCode
				where srcnroleid = 10
					and srcsdscrptn = '1. Attorney, Assigned'
			) as srcntypecode
		union all
		-- Case Manager
		select
			10 as srcnroleid,
			'Case Manager, Presuit' as srcsdscrptn,
			(
				select
					srcnCodeId
				from sma_mst_SubRoleCode
				where srcnroleid = 10
					and srcsdscrptn = 'Case Manager, Presuit'
			) as srcntypecode
	) v
	except
	select
		sbrnRoleID,
		sbrsDscrptn,
		sbrnTypeCode
	from sma_MST_SubRole
go

/* ---------------------------------------------------------------------------------------------------------------
Insert Case Staff
*/

alter table [sma_TRN_CaseStaff] disable trigger all
go

insert into sma_TRN_CaseStaff
	(
	[cssnCaseID],
	[cssnStaffID],
	[cssnRoleID],
	[csssComments],
	[cssdFromDate],
	[cssdToDate],
	[cssnRecUserID],
	[cssdDtCreated],
	[cssnModifyUserID],
	[cssdDtModified],
	[cssnLevelNo]
	)
	-- Principal Attorney =	'1. Attorney, Assigned'
	select
		cas.casnCaseID,
		u.usrnContactID,
		(
			select
				sbrnSubRoleId
			from sma_MST_SubRole
			where sbrnRoleID = 10
				and sbrsDscrptn = '1. Attorney, Assigned'
		),
		null	  as cssscomments,
		null	  as cssdfromdate,
		null	  as cssdtodate,
		368		  as cssnrecuserid,
		GETDATE() as cssddtcreated,
		null	  as cssnmodifyuserid,
		null	  as cssddtmodified,
		0		  as cssnlevelno
	from [sma_TRN_Cases] cas
	join [ShinerLitify]..[litify_pm__Matter__c] m
		on m.Id = cas.saga_char
	join [sma_MST_Users] u
		on u.saga_char = m.litify_pm__Principal_Attorney__c
	where m.litify_pm__Principal_Attorney__c is not null

	union all

	-- Paralegal = '4 Litigation Paralegal'
	select
		cas.casnCaseID,
		u.usrnContactID,
		(
			select
				sbrnSubRoleId
			from sma_MST_SubRole
			where sbrnRoleID = 10
				and sbrsDscrptn = '4 Litigation Paralegal'
		),
		null	  as cssscomments,
		null	  as cssdfromdate,
		null	  as cssdtodate,
		368		  as cssnrecuserid,
		GETDATE() as cssddtcreated,
		null	  as cssnmodifyuserid,
		null	  as cssddtmodified,
		0		  as cssnlevelno
	from [sma_TRN_Cases] cas
	join [ShinerLitify]..[litify_pm__Matter__c] m
		on m.Id = cas.saga_char
	join [sma_MST_Users] u
		on u.saga_char = m.Paralegal__c
	where m.Paralegal__c is not null

	union all

	-- Case Manager = 'Case Manager, Presuit'
	select
		cas.casnCaseID,
		u.usrnContactID,
		(
			select
				sbrnSubRoleId
			from sma_MST_SubRole
			where sbrnRoleID = 10
				and sbrsDscrptn = 'Case Manager, Presuit'
		),
		null	  as cssscomments,
		null	  as cssdfromdate,
		null	  as cssdtodate,
		368		  as cssnrecuserid,
		GETDATE() as cssddtcreated,
		null	  as cssnmodifyuserid,
		null	  as cssddtmodified,
		0		  as cssnlevelno
	from [sma_TRN_Cases] cas
	join [ShinerLitify]..[litify_pm__Matter__c] m
		on m.Id = cas.saga_char
	join [sma_MST_Users] u
		on u.saga_char = m.litify_pm__lit_Case_Manager__c
	where m.litify_pm__lit_Case_Manager__c is not null

	--union all

	-- Legal Assistant = 'Legal Assistant, Presuit'
	--select
	--	cas.casnCaseID,
	--	u.usrnContactID,
	--	(
	--		select
	--			sbrnSubRoleId
	--		from sma_MST_SubRole
	--		where sbrnRoleID = 10
	--			and sbrsDscrptn = 'Case Manager'
	--	),
	--	null	  as cssscomments,
	--	null	  as cssdfromdate,
	--	null	  as cssdtodate,
	--	368		  as cssnrecuserid,
	--	GETDATE() as cssddtcreated,
	--	null	  as cssnmodifyuserid,
	--	null	  as cssddtmodified,
	--	0		  as cssnlevelno
	--from [sma_TRN_Cases] cas
	--join [ShinerLitify]..[litify_pm__Matter__c] m
	--	on m.Id = cas.saga_char
	--join [sma_MST_Users] u
	--	on u.saga_char = m.litify_pm__lit_Case_Manager__c
	--where m.litify_pm__lit_Case_Manager__c is not null;
go

alter table [sma_TRN_CaseStaff] enable trigger all
go