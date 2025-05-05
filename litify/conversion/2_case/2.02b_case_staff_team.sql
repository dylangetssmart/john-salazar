/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create individual contacts and users

SubRoleCode from team
Subrole
Case Staff

--------------------------------------------------------------------------------------------------------------------------------------
Step				Object							Action			Source				Notes
--------------------------------------------------------------------------------------------------------------------------------------
	[1.1]			sma_mst_SubRoleCode				insert			hardcode			
	[1.2]			sma_mst_SubRole					insert			hardcode			
	[2.0]			sma_TRN_CaseStaff				insert			dbo.litify_pm__Matter__c

Reference
- https://smartadvocate.atlassian.net/wiki/spaces/Conversion/pages/2436366355/SmartAdvocate#Case-Roles

##########################################################################################################################
*/

use ShinerSA
go

---------------------------------------------------
-- Sub Roles
---------------------------------------------------
-- Create sma_mst_SubRoleCode from [litify_pm__Matter_Team_Role__c].[name]
insert into sma_mst_SubRoleCode
	(
	srcsDscrptn,
	srcnRoleID
	)
	select distinct
		name,
		10
	from ShinerLitify..litify_pm__Matter_Team_Role__c
	except
	select
		srcsdscrptn,
		srcnroleid
	from sma_mst_SubRoleCode;
go

--select * from ShinerSA..sma_mst_SubRoleCode
--select * from ShinerSA..sma_mst_SubRole

-- Create SubRole definitions that don't exist
-- sbrnTypeCode = SubRoleCode.srcnCodeId
insert into sma_MST_SubRole
	(
	sbrnRoleID,
	sbrsDscrptn,
	sbrnTypeCode
	)
	select
		10 as sbrnroleid, -- roleid 10 for case staff
		srcsDscrptn,
		srcnCodeId
	from sma_mst_SubRoleCode
	where srcnRoleID = 10
	except
	select
		sbrnroleid,
		sbrsDscrptn,
		sbrnTypeCode
	from sma_MST_SubRole;
go


---------------------------------------------------
-- Insert [sma_TRN_CaseStaff]
---------------------------------------------------
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
	select
		cas.casnCaseID,
		(
			select
				u.usrnContactID
			from sma_MST_Users u
			where u.saga_char = team_member.litify_pm__User__c
		)		  as [cssnstaffid],
		(
			select
				sbrnSubRoleId
			from sma_MST_SubRole
			where sbrnRoleID = 10
				and sbrsDscrptn = (
					select
						team_role.name
					from shinerlitify..litify_pm__Matter_Team_Role__c team_role
					where team_member.litify_pm__Role__c = team_role.id
				)
		)		  as [cssnroleid],
		null	  as cssscomments,
		null	  as cssdfromdate,
		null	  as cssdtodate,
		368		  as cssnrecuserid,
		GETDATE() as cssddtcreated,
		null	  as cssnmodifyuserid,
		null	  as cssddtmodified,
		0		  as cssnlevelno
	from ShinerLitify..litify_pm__Matter_Team_Member__c team_member
	join sma_TRN_Cases cas
		on cas.saga_char = team_member.litify_pm__Matter__c
	--where team_member.litify_pm__Matter__c = 'a0L8Z00000eDawuUAC'
go

alter table [sma_TRN_CaseStaff] enable trigger all
go