/*---
description: Creates case groups, types, subtypes, roles and cases
steps:
	1. Insert a general purpose case group		[sma_MST_CaseGroup]
	2. Insert case types from CaseTypeMap		[sma_MST_CaseType]
	- Create case subtype codes > [sma_MST_CaseSubTypeCode]
	- Create case subtypes > [sma_MST_CaseSubType]
instructions:
dependencies:
	- [PartyRoleMap]
	- [CaseTypeMap]
notes:
---*/

use [SA]
go

---
set nocount on

exec AddBreadcrumbsToTable 'sma_MST_CaseType'
exec AddBreadcrumbsToTable 'sma_MST_SubRole'
exec AddBreadcrumbsToTable 'sma_TRN_Cases'
go

alter table sma_TRN_Cases alter column saga INT
alter table sma_MST_SubRole alter column saga INT
go

---


/* ------------------------------------------------------------------------------
Case Types & Sub Types
*/ ------------------------------------------------------------------------------

-- [sma_MST_CaseGroup]
-- Create "Needles" case group umbrella
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
		'CONVERSION' as [cgpscode],
		'Needles'	 as [cgpsdscrptn],
		368			 as [cgpnrecuserid],
		GETDATE()	 as [cgpddtcreated],
		null		 as [cgpnmodifyuserid],
		null		 as [cgpddtmodified],
		null		 as [cgpnlevelno],
		(
		 select
			 incidenttypeid
		 from [sma_MST_IncidentTypes]
		 where description = 'General Negligence'
		)			 as [incidenttypeid],
		null		 as [limitgroupstatuses]
	where
		not exists (
		 select
			 1
		 from [sma_MST_CaseGroup]
		 where [cgpsCode] = 'CONVERSION'
			 and cgpsDscrptn = 'Needles'
		);
go

-- [sma_MST_CaseType]
-- Create case types from CaseTypeMap that don't already exist
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
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select distinct
		map.matcode					  as cstscode,
		map.[SmartAdvocate Case Type] as cststype,
		null						  as cstssubtype,
		null						  as cstnworkflowtemplateid,
		720							  as cstnexpectedresolutiondays 		-- ( Hardcode 2 years )
		,
		368							  as cstnrecuserid,
		GETDATE()					  as cstddtcreated,
		368							  as cstnmodifyuserid,
		GETDATE()					  as cstddtmodified,
		0							  as cstnlevelno,
		null						  as cstbtimetracking,
		(
		 select
			 cgpnCaseGroupID
		 from sma_MST_caseGroup
		 where cgpsDscrptn = 'Needles'
		)							  as cstngroupid,
		null						  as cstngovtmuntype,
		null						  as cstnismasstort,
		(
		 select
			 cssnStatusID
		 from [sma_MST_CaseStatus]
		 where csssDescription = 'Presign - Not Scheduled For Sign Up'
		)							  as cstnstatusid,
		(
		 select
			 stpnStatusTypeID
		 from [sma_MST_CaseStatusType]
		 where stpsStatusType = 'Status'
		)							  as cstnstatustypeid,
		1							  as cstbactive,
		1							  as cstbuseincident1,
		'Incident 1'				  as cstsincidentlabel1,
		null						  as [saga],
		map.matcode					  as [source_id],
		'needles'					  as [source_db],
		null						  as [source_ref]
	--select *
	from [CaseTypeMap] map
	left join [sma_MST_CaseType] ct
		on ct.cststype = map.[SmartAdvocate Case Type]
	--on ct.source_id = map.matcode
	where
		ct.cstnCaseTypeID is null
go

-- stamp conversion flag for any case types that existed already (cstsType matched needles description)
update sma_MST_CaseType
set source_db = 'needles'
from CaseTypeMap map
join sma_MST_CaseType ct
	on ct.cstsType = map.[SmartAdvocate Case Type]
where ct.source_db is null


-- [sma_MST_CaseSubTypeCode]
insert into [dbo].[sma_MST_CaseSubTypeCode]
	(
		stcsDscrptn
	)
	select distinct
		map.[SmartAdvocate Case Sub Type]
	from [CaseTypeMap] map
	where
		ISNULL(map.[SmartAdvocate Case Sub Type], '') <> ''
	except
	select
		stcsDscrptn
	from [dbo].[sma_MST_CaseSubTypeCode]
go

-- [sma_MST_CaseSubType]
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
	join [CaseTypeMap] map
		on map.[SmartAdvocate Case Type] = cst.cststype
	left join [sma_MST_CaseSubType] sub
		on sub.[cstngroupid] = cstnCaseTypeID
			and sub.[cstsdscrptn] = [SmartAdvocate Case Sub Type]
	where
		sub.cstnCaseSubTypeID is null
		and
		ISNULL([SmartAdvocate Case Sub Type], '') <> ''
go

/* ------------------------------------------------------------------------------
Case Roles
*/ ------------------------------------------------------------------------------

-- [sma_MST_SubRoleCode]
-- Create SubRoleCodes for each mapped Needles Role from PartyRoleMap
-- srcnRoleID 4 = plaintiff
-- srcnRoleID 5 = defendant
insert into [sma_MST_SubRoleCode]
	(
		srcsDscrptn,
		srcnRoleID
	)
	(
	-- Default Roles
	select
		'(P)-Default Role',
		4
	union all
	select
		'(D)-Default Role',
		5
	-- Roles from PartyRoleMap
	union all
	select
		[SA Role],
		4
	from [PartyRoleMap]
	where [SA Party] = 'Plaintiff'

	union all

	select
		[SA Role],
		5
	from [PartyRoleMap]
	where [SA Party] = 'Defendant'
	)

	except

	select
		srcsDscrptn,
		srcnRoleID
	from [sma_MST_SubRoleCode];
go


-- [sma_MST_SubRole]
-- Insert a SubRole reocrd for each case type AND for each SubRoleCode
with
	CaseTypes
	as (
		 -- collect applicable case types
		 select
			 *
		 from sma_MST_CaseType
		 where source_db = 'needles'
		),
	CrossJoinedRoles
	as (
		 -- cross join applicable case types with PartyRoleMap and join SubRoleCode on [SA Role]
		 select
			 src.srcnRoleId	   as sbrnRoleID,
			 src.srcsDscrptn   as sbrsDscrptn,
			 ct.cstnCaseTypeID as sbrnCaseTypeID,
			 src.srcnCodeId	   as sbrnTypeCode
		 from CaseTypes ct
		 cross join PartyRoleMap prm
		 join sma_MST_SubRoleCode src
			 on src.srcsDscrptn = prm.[SA Role]
		),
	DefaultRoles
	as (
		 -- add default roles once per case type
		 select
			 src.srcnRoleId	   as sbrnRoleID,
			 src.srcsDscrptn   as sbrsDscrptn,
			 ct.cstnCaseTypeID as sbrnCaseTypeID,
			 src.srcnCodeId	   as sbrnTypeCode
		 from CaseTypes ct
		 cross join (
		  select
			  '(P)-Default Role' as role
		  union all
		  select
			  '(D)-Default Role'
		 ) dr
		 join sma_MST_SubRoleCode src
			 on src.srcsDscrptn = dr.role
		),
	AllRolesToInsert
	as (
		 -- combine cross-joined roles and default roles
		 select
			 *
		 from CrossJoinedRoles
		 union all
		 select
			 *
		 from DefaultRoles
		)
--select * from AllRolesToInsert order by sbrnCaseTypeID
insert into sma_MST_SubRole
	(
		sbrnRoleID,
		sbrsDscrptn,
		sbrnCaseTypeID,
		sbrnTypeCode
	)
	select
		*
	from AllRolesToInsert
	except
	select
		sbrnRoleID,
		sbrsDscrptn,
		sbrnCaseTypeID,
		sbrnTypeCode
	from sma_MST_SubRole;
go


/* ------------------------------------------------------------------------------
Cases
*/ ------------------------------------------------------------------------------
alter table [sma_TRN_Cases] disable trigger all
go

;
with
	static_lookup
	as (
		 select
			 smo.office_name as OfficeName,
			 (
			  select
				  smo.state_id
			  from sma_MST_States
			  where sttnStateID = smo.state_id
			 )				 as state_id,
			 smo.PhoneNumber as PhoneNumber,
			 smo.office_id
		 from sma_mst_offices smo
		 where smo.is_default = 1
		)
insert into [sma_TRN_Cases]
	(
		[cassCaseNumber],
		[casbAppName],
		[cassCaseName],
		[casnCaseTypeID],
		[casnState],
		[casdStatusFromDt],
		[casnStatusValueID],
		[casdsubstatusfromdt],
		[casnSubStatusValueID],
		[casdOpeningDate],
		[casdClosingDate],
		[casnCaseValueID],
		[casnCaseValueFrom],
		[casnCaseValueTo],
		[casnCurrentCourt],
		[casnCurrentJudge],
		[casnCurrentMagistrate],
		[casnCaptionID],
		[cassCaptionText],
		[casbMainCase],
		[casbCaseOut],
		[casbSubOut],
		[casbWCOut],
		[casbPartialOut],
		[casbPartialSubOut],
		[casbPartiallySettled],
		[casbInHouse],
		[casbAutoTimer],
		[casdExpResolutionDate],
		[casdIncidentDate],
		[casnTotalLiability],
		[cassSharingCodeID],
		[casnStateID],
		[casnLastModifiedBy],
		[casdLastModifiedDate],
		[casnRecUserID],
		[casdDtCreated],
		[casnModifyUserID],
		[casdDtModified],
		[casnLevelNo],
		[cassCaseValueComments],
		[casbRefIn],
		[casbDelete],
		[casbIntaken],
		[casnOrgCaseTypeID],
		[CassCaption],
		[cassMdl],
		[office_id],
		[LIP],
		[casnSeriousInj],
		[casnCorpDefn],
		[casnWebImporter],
		[casnRecoveryClient],
		[cas],
		[ngage],
		[casnClientRecoveredDt],
		[CloseReason],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.casenum		as casscasenumber,
		''				as casbappname,
		case_title		as casscasename,
		(
		 select
			 cstnCaseSubTypeID
		 from [sma_MST_CaseSubType] st
		 where st.cstnGroupID = cst.cstnCaseTypeID
			 and st.cstsDscrptn = map.[SmartAdvocate Case Sub Type]
		)				as casncasetypeid,
		sl.state_id		as casnstate,
		GETDATE()		as casdstatusfromdt,
		(
		 select
			 cssnStatusID
		 from [sma_MST_CaseStatus]
		 where csssDescription = 'Presign - Not Scheduled For Sign Up'
		)				as casnstatusvalueid,
		GETDATE()		as casdsubstatusfromdt,
		(
		 select
			 cssnStatusID
		 from [sma_MST_CaseStatus]
		 where csssDescription = 'Presign - Not Scheduled For Sign Up'
		)				as casnsubstatusvalueid,
		case
			when (c.date_opened not between '1900-01-01' and '2079-12-31') then GETDATE()
			else c.date_opened
		end				as casdopeningdate,
		case
			when (c.close_date not between '1900-01-01' and '2079-12-31') then GETDATE()
			else c.close_date
		end				as casdclosingdate,
		null			as [casncasevalueid],
		null			as [casncasevaluefrom],
		null			as [casncasevalueto],
		null			as [casncurrentcourt],
		null			as [casncurrentjudge],
		null			as [casncurrentmagistrate],
		0				as [casncaptionid],
		case_title		as casscaptiontext,
		1				as [casbmaincase],
		0				as [casbcaseout],
		0				as [casbsubout],
		0				as [casbwcout],
		0				as [casbpartialout],
		0				as [casbpartialsubout],
		0				as [casbpartiallysettled],
		1				as [casbinhouse],
		null			as [casbautotimer],
		null			as [casdexpresolutiondate],
		null			as [casdincidentdate],
		0				as [casntotalliability],
		0				as [casssharingcodeid],
		sl.state_id		as [casnstateid],
		null			as [casnlastmodifiedby],
		null			as [casdlastmodifieddate],
		(
		 select
			 usrnUserID
		 from sma_MST_Users
		 where source_id = c.intake_staff
		)				as casnrecuserid,
		case
			when c.intake_date between '1900-01-01' and '2079-06-06' and
				c.intake_time between '1900-01-01' and '2079-06-06' then (
					 select
						 CAST(CONVERT(DATE, c.intake_date) as DATETIME) + CAST(CONVERT(TIME, c.intake_time) as DATETIME)
					)
			else null
		end				as casddtcreated,
		null			as casnmodifyuserid,
		null			as casddtmodified,
		''				as casnlevelno,
		''				as casscasevaluecomments,
		null			as casbrefin,
		null			as casbdelete,
		null			as casbintaken,
		cstnCaseTypeID  as casnorgcasetypeid, -- actual case type
		''				as casscaption,
		0				as cassmdl,
		sl.office_id	as office_id,
		null			as [lip],
		null			as [casnseriousinj],
		null			as [casncorpdefn],
		null			as [casnwebimporter],
		null			as [casnrecoveryclient],
		null			as [cas],
		null			as [ngage],
		null			as [casnclientrecovereddt],
		null			as [closereason],
		c.casenum		as [saga],
		null			as [source_id],
		'needles'		as [source_db],
		'cases_indexed' as [source_ref]
	--select *
	from [Needles].[dbo].[cases_Indexed] c
	--left join [Needles].[dbo].[user_case_data] u
	--	on u.casenum = c.casenum
	join CaseTypeMap map
		on map.matcode = c.matcode
	left join sma_MST_CaseType cst
		on cst.cstsType = map.[SmartAdvocate Case Type]
			and cst.source_id = c.matcode
	cross join static_lookup sl
	order by c.casenum
go

alter table [sma_TRN_Cases] enable trigger all
go


/* ------------------------------------------------------------------------------
Retainer Date
-- Retain date = case open date
*/ ------------------------------------------------------------------------------
alter table sma_TRN_Retainer disable trigger all
go

insert into [dbo].[sma_TRN_Retainer]
	(
		[rtnnCaseID],
		[rtnnPlaintiffID],
		[rtndSentDt],
		[rtndRcvdDt],
		[rtndRetainerDt],
		[rtnbCopyRefAttFee],
		[rtnnFeeStru],
		[rtnbMultiFeeStru],
		[rtnnBeforeTrial],
		[rtnnAfterTrial],
		[rtnnAtAppeal],
		[rtnnUDF1],
		[rtnnUDF2],
		[rtnnUDF3],
		[rtnbComplexStru],
		[rtnbWrittenAgree],
		[rtnnStaffID],
		[rtnsComments],
		[rtnnUserID],
		[rtndDtCreated],
		[rtnnModifyUserID],
		[rtndDtModified],
		[rtnnLevelNo],
		[rtnnPlntfAdv],
		[rtnnFeeAmt],
		[rtnsRetNo],
		[rtndRetStmtSent],
		[rtndRetStmtRcvd],
		[rtndClosingStmtRcvd],
		[rtndClosingStmtSent],
		[rtnsClosingRetNo],
		[rtndSignDt],
		[rtnsDocuments],
		[rtndExecDt],
		[rtnsGrossNet],
		[rtnnFeeStruAlter],
		[rtnsGrossNetAlter],
		[rtnnFeeAlterAmt],
		[rtnbFeeConditionMet],
		[rtnsFeeCondition]
	)
	select
		casnCaseID		as rtnnCaseID,
		null			as rtnnPlaintiffID,
		null			as rtndSentDt,
		casdOpeningDate as rtndRcvdDt,
		null			as rtndRetainerDt,
		0				as rtnbCopyRefAttFee,
		null			as rtnnFeeStru,
		0				as rtnbMultiFeeStru,
		null			as rtnnBeforeTrial,
		null			as rtnnAfterTrial,
		null			as rtnnAtAppeal,
		null			as rtnnUDF1,
		null			as rtnnUDF2,
		null			as rtnnUDF3,
		0				as rtnbComplexStru,
		0				as rtnbWrittenAgree,
		null			as rtnnStaffID,
		null			as rtnsComments,
		368				as rtnnUserID,
		GETDATE()		as rtndDtCreated,
		null			as rtnnModifyUserID,
		null			as rtndDtModified,
		1				as rtnnLevelNo,
		null			as rtnnPlntfAdv,
		null			as rtnnFeeAmt,
		null			as rtnsRetNo,
		null			as rtndRetStmtSent,
		null			as rtndRetStmtRcvd,
		null			as rtndClosingStmtRcvd,
		null			as rtndClosingStmtSent,
		null			as rtnsClosingRetNo,
		null			as rtndSignDt,
		null			as rtnsDocuments,
		null			as rtndExecDt,
		null			as rtnsGrossNet,
		null			as rtnnFeeStruAlter,
		null			as rtnsGrossNetAlter,
		null			as rtnnFeeAlterAmt,
		null			as rtnbFeeConditionMet,
		null			as rtnsFeeCondition
	from sma_TRN_Cases
go

alter table sma_TRN_Retainer enable trigger all
go