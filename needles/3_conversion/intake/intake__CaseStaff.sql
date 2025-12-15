alter table [sma_TRN_caseStaff] disable trigger all
go

------------------------------------------------------------------------------
-- Convert staff_1 ###########################################################
------------------------------------------------------------------------------
insert into sma_TRN_caseStaff
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
	select
		c.casnCaseID	as [cssncaseid],
		u.usrnContactID as [cssnstaffid],
		(
			select
				sbrnSubRoleId
			from sma_MST_SubRole
			where sbrsDscrptn = 'Staff'
				and sbrnRoleID = 10
		)				as [cssnroleid],
		null			as [cssscomments],
		null			as cssdfromdate,
		null			as cssdtodate,
		368				as cssnrecuserid,
		GETDATE()		as [cssddtcreated],
		null			as [cssnmodifyuserid],
		null			as [cssddtmodified],
		0				as cssnlevelno
	--select *
	from [Needles].[dbo].case_intake n
	join [sma_TRN_Cases] c
		on c.saga = n.ROW_ID
	inner join [sma_MST_Users] u
		on u.source_id = n.staff_1
	where ISNULL(n.staff_1, '') <> ''

alter table [sma_TRN_caseStaff] enable trigger all
go