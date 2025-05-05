SELECT * INTO sma_TRN_RoleCaseStuffMainRoles_Backup
FROM sma_TRN_RoleCaseStuffMainRoles;

truncate table sma_TRN_RoleCaseStuffMainRoles
go

if (
		select
			COUNT(*)
		from sma_TRN_RoleCaseStuffMainRoles
	) = 0
begin
	insert into sma_TRN_RoleCaseStuffMainRoles
		(
			[CaseID],
			[AttyContactID],
			[ParalegalContactID],
			[CaseManagerContactID]
		)
		select
			cssnCaseID as CaseID,
			[1],
			[2],
			[3]
		from (
			select
				SS.cssnCaseID,
				SS.cssnStaffID,
				RG.RoleGroupID
			from sma_TRN_CaseStaff SS
			join sma_MST_RolePriorityGroup RG
				on RoleID = cssnRoleID
				and SS.cssdToDate is null
			outer apply (
				select top 1
					cssnCaseID as CaseID,
					RoleGroupID,
					PriorityFlag,
					cssnStaffID,
					cssnPKID
				from sma_TRN_CaseStaff sss
				join sma_MST_RolePriorityGroup RF
					on RoleID = cssnRoleID
				where sss.cssdToDate is null
					and sss.cssnCaseID is not null
					and sss.cssnCaseID = SS.cssnCaseID
					and RG.RoleGroupID = RF.RoleGroupID
				order by CaseID, PriorityFlag, sss.cssdFromDate
			) dddd
			where dddd.CaseID = SS.cssnCaseID
				and dddd.cssnPKID = ss.cssnPKID
				and dddd.RoleGroupID is not null
		) as SourceTable
		pivot
		(
		AVG(cssnStaffID)
		for RoleGroupID in ([1], [2], [3])
		) as PivotTable
end


select * from sma_trn_RoleCaseStuffMainRoles 
select * from sma_TRN_CaseStaff stcs
select * from sma_MST_RolePriorityGroup smrpg

select * from sma_MST_RoleGroup

select sbrnSubRoleID from sma_MST_SubRole

SELECT *
FROM sma_MST_RolePriorityGroup rp
join sma_MST_RoleGroup rg
on rg.RoleGroupID = rp.RoleGroupID
join sma_MST_SubRole sr
on sr.sbrnSubRoleId = rp.RoleID

SELECT * FROM sma_MST_SubRole smsr