/* #######################################################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create Cases and case related codes

[sma_mst_offices]
[sma_MST_CaseType]
[sma_TRN_Cases]
[sma_mst_casegroup]
[sma_MST_CaseSubType]
[sma_MST_CaseSubTypeCode]

------------------------------------------------------------------------------------------------------
Step									Object				Action				Source				Notes
------------------------------------------------------------------------------------------------------
[0.0] #TempVariables					create
[1.0] Office							insert
[2.0] Case Groups						insert

[3.0] Case Types
	[3.1] VenderCaseType				schema
	[3.2] sma_MST_CaseType				insert
	[3.3] sma_MST_CaseSubTypeCode		update
	[3.4] sma_MST_CaseSubTypeCode		insert 
	[3.5] sma_MST_CaseSubType			insert

[4.0] Sub Role
	[4.1] sma_MST_SubRole				insert 
	[4.2] sma_MST_SubRole				update
	[4.3] sma_MST_SubroleCode			insert
	[4.3] sma_MST_SubRole				insert

[5.0] Cases								insert


Notes:
	- Because batch separators (GO) are required due to schema changes (adding columns),
	we use a temporary table instead of variables, which are locally scoped
	see: https://learn.microsoft.com/en-us/sql/t-sql/language-elements/variables-transact-sql?view=sql-server-ver16#variable-scope
	see also: https://stackoverflow.com/a/56370223
	- After making schema changes (e.g. adding a new column to an existing table) statements using the new schema must be compiled separately in a different batch.
	- For example, you cannot ALTER a table to add a column, then select that column in the same batch - because while compiling the execution plan, that column does not exist for selecting.

##########################################################################################################################
*/

use ShinerSA

------------------------------------------------------------------------------------------------------
-- [0.0] Temporary table to store variable values
------------------------------------------------------------------------------------------------------
begin

	if OBJECT_ID('conversion.office', 'U') is not null
	begin
		drop table conversion.office
	end

	create table conversion.office (
		OfficeName	   NVARCHAR(255),
		StateName	   NVARCHAR(100),
		PhoneNumber	   NVARCHAR(50),
		CaseGroup	   NVARCHAR(100),
		VenderCaseType NVARCHAR(25)
	);
	insert into conversion.office
		(
		OfficeName,
		StateName,
		PhoneNumber,
		CaseGroup,
		VenderCaseType
		)
	values (
	'Shiner Law Group',
	'Florida',
	'5617777700',
	'Litify',
	'ShinerCaseType'
	);
end

------------------------------------------------------------------------------------------------------
-- [2.0] Case Groups
-- Create catch-all case group data that does not neatly fit elsewhere
------------------------------------------------------------------------------------------------------

/* !!!! WARNING !!!!
- If the trigger below is DISABLED,

- is disabled, the post conversion sitemap fix script will likely need to be run.
alter table sma_MST_CaseGroup disable trigger all
go
*/

begin
	if not exists (
			select
				*
			from sma_MST_CaseGroup
			where cgpsDscrptn = (
					select
						CaseGroup
					from conversion.office so
				)
		)
	begin
		insert into [sma_MST_CaseGroup]
			(
			[cgpsCode],
			[cgpsDscrptn],
			[cgpnRecUserId],
			[cgpdDtCreated],
			[cgpnModifyUserID],
			[cgpdDtModified],
			[cgpnLevelNo],
			[IncidentTypeID],
			[LimitGroupStatuses]
			)
			select distinct
				null	  as [cgpscode],
				'Litify'  as [cgpsdscrptn],
				368		  as [cgpnrecuserid],
				GETDATE() as [cgpddtcreated],
				null	  as [cgpnmodifyuserid],
				null	  as [cgpddtmodified],
				null	  as [cgpnlevelno],
				(
					select
						incidenttypeid
					from [sma_MST_IncidentTypes]
					where Description = 'General Negligence'
				)		  as [incidenttypeid],
				null	  as [limitgroupstatuses]
	end
end

--alter table sma_MST_CaseGroup enable trigger all
--go


------------------------------------------------------------------------------------------------------
-- [3.0] Case Type
------------------------------------------------------------------------------------------------------
-- [3.1] VenderCaseType
if not exists (
		select
			*
		from sys.columns
		where Name = N'VenderCaseType'
			and object_id = OBJECT_ID(N'sma_MST_CaseType')
	)
begin
	alter table sma_MST_CaseType
	add VenderCaseType VARCHAR(100)
end

go



-- 3.2 sma_MST_CaseType
insert into [sma_MST_CaseType]
	(
	[cstsCode],
	[cstsType],
	[cstsSubType],
	[cstnWorkflowTemplateID],
	[cstnExpectedResolutionDays],
	[cstnRecUserID],
	[cstdDtCreated],
	[cstnModifyUserID],
	[cstdDtModified],
	[cstnLevelNo],
	[cstbTimeTracking],
	[cstnGroupID],
	[cstnGovtMunType],
	[cstnIsMassTort],
	[cstnStatusID],
	[cstnStatusTypeID],
	[cstbActive],
	[cstbUseIncident1],
	[cstsIncidentLabel1],
	[VenderCaseType]
	)
	select distinct
		null					  as cstscode,
		[SmartAdvocate Case Type] as cststype,
		null					  as cstssubtype,
		null					  as cstnworkflowtemplateid,
		720						  as cstnexpectedresolutiondays,
		368						  as cstnrecuserid,
		GETDATE()				  as cstddtcreated,
		368						  as cstnmodifyuserid,
		GETDATE()				  as cstddtmodified,
		0						  as cstnlevelno,
		null					  as cstbtimetracking,
		(
			select
				cgpnCaseGroupID
			from sma_MST_CaseGroup
			where cgpsDscrptn = 'Litify'
		)						  as cstngroupid,
		null					  as cstngovtmuntype,
		null					  as cstnismasstort,
		(
			select
				cssnStatusID
			from [sma_MST_CaseStatus]
			where csssDescription = 'Presign - Not Scheduled For Sign Up'
		)						  as cstnstatusid,
		(
			select
				stpnStatusTypeID
			from [sma_MST_CaseStatusType]
			where stpsStatusType = 'Status'
		)						  as cstnstatustypeid,
		1						  as cstbactive,
		1						  as cstbuseincident1,
		'Incident 1'			  as cstsincidentlabel1,
		(
			select
				vendercasetype
			from conversion.office so
		)						  as vendercasetype
	from [CaseTypeMap] mix
	left join [sma_MST_CaseType] ct
		on ct.cststype = mix.[SmartAdvocate Case Type]
	where ct.cstnCaseTypeID is null;
go

-- Update existing records with VenderCaseType
update [sma_MST_CaseType]
set VenderCaseType = (
	select
		VenderCaseType
	from conversion.office so
)
from [CaseTypeMap] mix
join [sma_MST_CaseType] ct
	on ct.cstsType = mix.[SmartAdvocate Case Type]
where ISNULL(VenderCaseType, '') = '';
go

-- [3.3] sma_MST_CaseSubTypeCode
insert into [dbo].[sma_MST_CaseSubTypeCode]
	(
	stcsDscrptn
	)
	select distinct
		mix.[SmartAdvocate Case Sub Type]
	from [CaseTypeMap] mix
	where ISNULL(mix.[SmartAdvocate Case Sub Type], '') <> ''
	except
	select
		stcsDscrptn
	from [dbo].[sma_MST_CaseSubTypeCode];
go

-- [3.4] sma_MST_CaseSubType
insert into [sma_MST_CaseSubType]
	(
	[cstsCode],
	[cstnGroupID],
	[cstsDscrptn],
	[cstnRecUserId],
	[cstdDtCreated],
	[cstnModifyUserID],
	[cstdDtModified],
	[cstnLevelNo],
	[cstbDefualt],
	[saga],
	[cstnTypeCode]
	)
	select
		null						  as [cstscode],
		cstnCaseTypeID				  as [cstngroupid],
		[SmartAdvocate Case Sub Type] as [cstsdscrptn],
		368							  as [cstnrecuserid],
		GETDATE()					  as [cstddtcreated],
		null						  as [cstnmodifyuserid],
		null						  as [cstddtmodified],
		null						  as [cstnlevelno],
		1							  as [cstbdefualt],
		null						  as [saga],
		(
			select
				stcnCodeId
			from [sma_MST_CaseSubTypeCode]
			where stcsDscrptn = [SmartAdvocate Case Sub Type]
		)							  as [cstntypecode]
	from [sma_MST_CaseType] cst
	join [CaseTypeMap] mix
		on mix.[SmartAdvocate Case Type] = cst.cstsType
	left join [sma_MST_CaseSubType] sub
		on sub.[cstngroupid] = cstnCaseTypeID
			and sub.[cstsdscrptn] = [SmartAdvocate Case Sub Type]
	where sub.cstnCaseSubTypeID is null
		and ISNULL([SmartAdvocate Case Sub Type], '') <> '';
