/*
create various Plaintiff and Defendant roles for each case type

*/

use ShinerSA
go

------------------------------------------------------------------------------------------------------
-- [4.0] Sub Role
------------------------------------------------------------------------------------------------------


-- [4.1] sma_MST_SubRole
insert into [sma_MST_SubRole]
	(
	[sbrsCode],
	[sbrnRoleID],
	[sbrsDscrptn],
	[sbrnCaseTypeID],
	[sbrnPriority],
	[sbrnRecUserID],
	[sbrdDtCreated],
	[sbrnModifyUserID],
	[sbrdDtModified],
	[sbrnLevelNo],
	[sbrbDefualt],
	[saga]
	)
	select
		[sbrscode]		   as [sbrscode],
		[sbrnroleid]	   as [sbrnroleid],
		[sbrsdscrptn]	   as [sbrsdscrptn],
		cst.cstnCaseTypeID as [sbrncasetypeid],
		[sbrnpriority]	   as [sbrnpriority],
		[sbrnrecuserid]	   as [sbrnrecuserid],
		[sbrddtcreated]	   as [sbrddtcreated],
		[sbrnmodifyuserid] as [sbrnmodifyuserid],
		[sbrddtmodified]   as [sbrddtmodified],
		[sbrnlevelno]	   as [sbrnlevelno],
		[sbrbdefualt]	   as [sbrbdefualt],
		[saga]			   as [saga]
	from sma_MST_CaseType cst
	left join sma_MST_SubRole s
		on cst.cstnCaseTypeID = s.sbrncasetypeid
			or s.sbrncasetypeid = 1
	join [CaseTypeMap] mix
		on mix.[SmartAdvocate Case Type] = cst.cstsType
	where VenderCaseType = (
			select
				VenderCaseType
			from conversion.office so
		)
		and ISNULL(mix.[SmartAdvocate Case Type], '') = ''
go

-- [4.2] sma_MST_SubRole - use the sma_MST_SubRole.sbrsDscrptn value to set the sma_MST_SubRole.sbrnTypeCode field
update sma_MST_SubRole
set sbrnTypeCode = A.CodeId
from (
	select
		s.sbrsdscrptn as sbrsdscrptn,
		s.sbrnSubRoleId as subroleid,
		(
			select
				MAX(srcnCodeId)
			from sma_mst_SubRoleCode
			where srcsDscrptn = s.sbrsdscrptn
		) as codeid
	from sma_MST_SubRole s
	join sma_MST_CaseType cst
		on cst.cstnCaseTypeID = s.sbrnCaseTypeID
		and cst.VenderCaseType = (
			select
				VenderCaseType
			from conversion.office so
		)
) a
where a.subroleid = sbrnSubRoleId
go

-- [4.3] sma_mst_SubRoleCode - specific plaintiff and defendant party roles
insert into [sma_mst_SubRoleCode]
	(
	srcsDscrptn,
	srcnRoleID
	)
	(
	select
		'(P)-Plaintiff',
		4
	union
	select
		'(P)-Plaintiff 2',
		4
	union
	select
		'(P)-Petitioner',
		4
	union
	select
		'(P)-Claimant',
		4
	union
	select
		'(P)-Deceased',
		4
	union
	select
		'(D)-Defendant',
		5
	union
	select
		'(D)-Defendant 2',
		5
	union
	select
		'(D)-Driver',
		5
	union
	select
		'(D)-Owner',
		5
	union
	select
		'(D)-Respondent',
		5
	)
	except
	select
		srcsDscrptn,
		srcnRoleID
	from [sma_mst_SubRoleCode]
go

-- [4.4] Not already in sma_MST_SubRole
insert into sma_MST_SubRole
	(
	sbrnRoleID,
	sbrsDscrptn,
	sbrnCaseTypeID,
	sbrnTypeCode
	)

	select
		t.sbrnroleid,
		t.sbrsdscrptn,
		t.sbrncasetypeid,
		t.sbrntypecode
	from (
		select
			r.pord as sbrnroleid,
			r.[role] as sbrsdscrptn,
			cst.cstnCaseTypeID as sbrncasetypeid,
			(
				select
					srcnCodeId
				from sma_mst_SubRoleCode
				where srcsDscrptn = r.role
					and srcnRoleID = r.pord
			) as sbrntypecode
		from sma_MST_CaseType cst
		cross join (
			select
				'(P)-Plaintiff' as [role],
				4 as pord
			union
			select
				'(P)-Plaintiff 2' as [role],
				4 as pord
			union
			select
				'(P)-Petitioner' as [role],
				4 as pord
			union
			select
				'(P)-Claimant' as [role],
				4 as pord
			union
			select
				'(P)-Deceased' as [role],
				4 as pord
			union
			select
				'(D)-Defendant' as [role],
				5 as pord
			union
			select
				'(D)-Defendant 2' as [role],
				5 as pord
			union
			select
				'(D)-Driver' as [role],
				5 as pord
			union
			select
				'(D)-Owner' as [role],
				5 as pord
			union
			select
				'(D)-Respondent' as [role],
				5 as pord
		) r
		where cst.VenderCaseType = (
				select
					VenderCaseType
				from conversion.office so
			)
	) t
	except
	select
		sbrnroleid,
		sbrsdscrptn,
		sbrncasetypeid,
		sbrntypecode
	from sma_MST_SubRole
