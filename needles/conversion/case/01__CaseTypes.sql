/*---
group: case
order: 2
description:
---*/


/* ###################################################################################
description: Handles common operations related to [sma_MST_IndvContacts]
steps:
	- Create a general purpose case group > [sma_MST_CaseGroup]
	- Create case types from CaseTypeMixture > [sma_MST_CaseType]
	- Create case subtype codes > [sma_MST_CaseSubTypeCode]
	- Create case subtypes > [sma_MST_CaseSubType]
usage_instructions:
	- update values for [conversion].[office]
dependencies:
	- 
notes:
	-
*/


use [SA]
go


-- (0.1) sma_MST_CaseGroup -----------------------------------------------------
-- Create a default case group for data that does not neatly fit elsewhere
if not exists (
		select
			*
		from [sma_MST_CaseGroup]
		where [cgpsDscrptn] = (
				select
					CaseGroup
				from conversion.office
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
		select
			'FORCONVERSION' as [cgpscode],
			(
				select
					CaseGroup
				from conversion.office
			)				as [cgpsdscrptn],
			368				as [cgpnrecuserid],
			GETDATE()		as [cgpddtcreated],
			null			as [cgpnmodifyuserid],
			null			as [cgpddtmodified],
			null			as [cgpnlevelno],
			(
				select
					incidenttypeid
				from [sma_MST_IncidentTypes]
				where Description = 'General Negligence'
			)				as [incidenttypeid],
			null			as [limitgroupstatuses]
end
go



-- (1) sma_MST_CaseType -----------------------------------------------------
-- (1.1) - Add a case type field that acts as conversion flag
-- for future reference: "VenderCaseType"
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

-- (1.2) - Create case types from CaseTypeMixture
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
		720						  as cstnexpectedresolutiondays 		-- ( Hardcode 2 years )
		,
		368						  as cstnrecuserid,
		GETDATE()				  as cstddtcreated,
		368						  as cstnmodifyuserid,
		GETDATE()				  as cstddtmodified,
		0						  as cstnlevelno,
		null					  as cstbtimetracking,
		(
			select
				cgpnCaseGroupID
			from sma_MST_caseGroup
			where cgpsDscrptn = (
					select
						CaseGroup
					from conversion.office
				)
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
			from conversion.office
		)						  as vendercasetype
	from [CaseTypeMixture] mix
	left join [sma_MST_CaseType] ct
		on ct.cststype = mix.[SmartAdvocate Case Type]
	where ct.cstnCaseTypeID is null
go

-- (1.3) - Add conversion flag to case types created above
update [sma_MST_CaseType]
set VenderCaseType = (
	select
		VenderCaseType
	from conversion.office
)
from [CaseTypeMixture] mix
join [sma_MST_CaseType] ct
	on ct.cststype = mix.[SmartAdvocate Case Type]
where ISNULL(VenderCaseType, '') = ''
go

-- (2) sma_MST_CaseSubType -----------------------------------------------------
-- (2.1) - sma_MST_CaseSubTypeCode
-- For non-null values of SA Case Sub Type from CaseTypeMixture,
-- add distinct values to CaseSubTypeCode and populate stcsDscrptn
insert into [dbo].[sma_MST_CaseSubTypeCode]
	(
	stcsDscrptn
	)
	select distinct
		mix.[SmartAdvocate Case Sub Type]
	from [CaseTypeMixture] mix
	where ISNULL(mix.[SmartAdvocate Case Sub Type], '') <> ''
	except
	select
		stcsDscrptn
	from [dbo].[sma_MST_CaseSubTypeCode]
go

-- (2.2) - sma_MST_CaseSubType
-- Construct CaseSubType using CaseTypes
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
	join [CaseTypeMixture] mix
		on mix.[SmartAdvocate Case Type] = cst.cststype
	left join [sma_MST_CaseSubType] sub
		on sub.[cstngroupid] = cstnCaseTypeID
			and sub.[cstsdscrptn] = [SmartAdvocate Case Sub Type]
	where sub.cstnCaseSubTypeID is null
		and ISNULL([SmartAdvocate Case Sub Type], '') <> ''

