/* ---------------------------------------------------------------------------------------------------------------------------------------
Litify/Auto Accident -> Auto Accidents/Auto Accident 

1. create case type
2. create subroles

- update [sma_trn_cases].[casnOrgCaseTypeID]
- roles for new case type
- update plaintiff
- update defendant
- delete case type (optional?)
- delete sub roles (optional?)
*/

SELECT stc.casnCaseID, stc.cassCaseNumber, stc.casnOrgCaseTypeID FROM sma_TRN_Cases stc where stc.casnCaseID = 272

SELECT * FROM sma_MST_CaseType where cstsType like '%auto acc%'
-- 1587

SELECT * FROM sma_MST_CaseGroup where cgpsDscrptn = 'litify'
-- 172

SELECT * FROM sma_MST_CaseGroup where cgpsDscrptn = 'auto accidents'
-- 132

SELECT * FROM sma_MST_SubRole smsr

UPDATE sma_MST_CaseType
set cstnGroupID = 132
where cstnCaseTypeID = 1587

SELECT * FROM sma_MST_CaseType smct where smct.cstnGroupID = 172

SELECT * FROM sma_TRN_Cases cas
join sma_MST_CaseType ct
on cas.casnOrgCaseTypeID = ct.cstnCaseTypeID
where ct.cstnGroupID = 132

/* ---------------------------------------------------------------------------------------------------------------------------------------
create case type
*/
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
		[cstsIncidentLabel1]
	)
	select
		null			as cstscode,
		'Auto Accident' as cststype,
		null			as cstssubtype,
		null			as cstnworkflowtemplateid,
		720				as cstnexpectedresolutiondays,
		368				as cstnrecuserid,
		GETDATE()		as cstddtcreated,
		368				as cstnmodifyuserid,
		GETDATE()		as cstddtmodified,
		0				as cstnlevelno,
		null			as cstbtimetracking,
		(
			select
				cgpnCaseGroupID
			from sma_MST_CaseGroup
			where cgpsDscrptn = 'auto accidents'
		)				as cstngroupid,
		null			as cstngovtmuntype,
		null			as cstnismasstort,
		(
			select
				cssnStatusID
			from [sma_MST_CaseStatus]
			where csssDescription = 'Presign - Not Scheduled For Sign Up'
		)				as cstnstatusid,
		(
			select
				stpnStatusTypeID
			from [sma_MST_CaseStatusType]
			where stpsStatusType = 'Status'
		)				as cstnstatustypeid,
		1				as cstbactive,
		1				as cstbuseincident1,
		'Incident 1'	as cstsincidentlabel1
--(
--	select
--		vendercasetype
--	from conversion.office so
--)						  as vendercasetype
--from [CaseTypeMap] mix
--left join [sma_MST_CaseType] ct
--	on ct.cststype = mix.[SmartAdvocate Case Type]
--where ct.cstnCaseTypeID is null;
go



/* ---------------------------------------------------------------------------------------------------------------------------------------
SubRoles
copy subroles from Litify/Auto Accident
*/
SELECT * FROM sma_MST_SubRole smsr where smsr.sbrnCaseTypeID = 1587 or smsr.sbrnCaseTypeID = 1591

INSERT INTO sma_MST_SubRole ( sbrnRoleID,sbrsDscrptn,sbrnCaseTypeID,sbrnTypeCode)
select
	T.sbrnRoleID,
	T.sbrsDscrptn,
	1591,	-- new case type
	T.sbrnTypeCode
from sma_MST_SubRole t
where
	sbrnCaseTypeID = 1587
except
select
	sbrnRoleID,
	sbrsDscrptn,
	sbrnCaseTypeID,
	sbrnTypeCode
from sma_MST_SubRole

/* ---------------------------------------------------------------------------------------------------------------------------------------
#casetypemap
*/
--drop TABLE #casetypeMap
select distinct
	ct.cstnCaseTypeID,
	cststype,
	--smcst.cstnCaseSubTypeID,
	--smcst.cstsDscrptn,
	null as NewCaseTypeID
	--null as NewSubTypeID
into #casetypeMap
from sma_mst_casetype ct
LEFT join sma_trn_Cases cas
	on cas.casnOrgCaseTypeID = ct.cstnCaseTypeID
left join sma_MST_CaseSubType smcst
	on smcst.cstnCaseSubTypeID = cas.casnCaseTypeID
where
	ct.cstnCaseTypeID = 1587
	--cststype in ('Auto Accident')

SELECT * FROM #casetypeMap m

--UPDATE NEW CASETYPE/
update #casetypeMap
set NewCaseTypeID = (
	select
		cstncasetypeid
	from sma_MST_CaseType
	where cstsType = 'auto accident'
		and cstnGroupID = (
			select
				g.cgpnCaseGroupID
			from sma_MST_CaseGroup g
			where g.cgpsDscrptn = 'auto accidents'
		)
)

SELECT * FROM #casetypeMap m

/* ---------------------------------------------------------------------------------------------------------------------------------------
#cases
*/

select
	map.*,
	cas.casnCaseID,
	cas.casnOrgCaseTypeID CaseType
	--CAS.casnCaseTypeID	  caseSubType
into #cases
from #casetypeMap map
join sma_trn_Cases cas
	on cas.casnOrgCaseTypeID = map.cstnCaseTypeID
		--and ISNULL(cas.casnCaseTypeID, '') = ISNULL(map.cstnCaseSubTypeID, '')

select * from #cases

/* ---------------------------------------------------------------------------------------------------------------------------------------
Plaintiffs
*/

-- how many plaintiffs should we expect to update?
-- 1310
SELECT
count(*)
--p.plnnPlaintiffID, p.plnnRole, cas.casnCaseID, cas.casnOrgCaseTypeID, ct.cstsType, sr.sbrnSubRoleId, sr.sbrnRoleID, sr.sbrsDscrptn
FROM sma_TRN_Plaintiff p
join sma_TRN_Cases cas
on cas.casnCaseID = p.plnnCaseID
join sma_MST_CaseType ct
on cas.casnOrgCaseTypeID = ct.cstnCaseTypeID
join sma_MST_SubRole sr
on p.plnnRole = sr.sbrnSubRoleId
where ct.cstnCaseTypeID = 1587


-- create #plaintiff
--drop TABLE #PLAINTIFF
select
	cas.casncaseid,
	cas.cstncasetypeid,
	p.plnnPlaintiffID,
	p.plnnrole,
	sr.sbrsDscrptn,
	srnew.sbrnSubRoleId as NEWSubRoleID,
	srnew.sbrsDscrptn   as NEWSubRoleDescr
into #PLAINTIFF
from #cases cas
join sma_TRN_Plaintiff p
	on p.plnnCaseID = cas.casnCaseID
join sma_MST_SubRole sr
	on p.plnnRole = sr.sbrnSubRoleId
left join sma_MST_SubRole srNEW
	on srnew.sbrsDscrptn = sr.sbrsDscrptn
		and srnew.sbrnCaseTypeID = cas.newCaseTypeID

select * from #plaintiff
SELECT * FROM sma_MST_SubRole smsr where smsr.sbrnCaseTypeID = 1587 or smsr.sbrnCaseTypeID = 1591

/* ---------------------------------------------------------------------------------------------------------------------------------------
Defendants
*/

-- how many defendants should we expect to update?
-- 1239
select
count(*)
--d.defnDefendentID, d.defnSubRole, cas.casnCaseID, cas.casnOrgCaseTypeID, ct.cstsType, sr.sbrnSubRoleId, sr.sbrnRoleID, sr.sbrsDscrptn
FROM sma_TRN_Defendants d
join sma_TRN_Cases cas
on d.defnCaseID = cas.casnCaseID
join sma_MST_CaseType ct
on cas.casnOrgCaseTypeID = ct.cstnCaseTypeID
join sma_MST_SubRole sr
on d.defnSubRole = sr.sbrnSubRoleId
where ct.cstnCaseTypeID = 1587

-- create #defendant
select
	cas.casncaseid,
	cas.cstncasetypeid,
	d.defnDefendentID,
	d.defnSubRole,
	sr.sbrsDscrptn,
	srnew.sbrnSubRoleId as NEWSubRoleID,
	srnew.sbrsDscrptn   as NEWSubRoleDescr
into #DEFENDANT
from #CASES cas
join sma_TRN_Defendants d
	on d.defnCaseID = cas.casnCaseID
join sma_MST_SubRole sr
	on d.defnSubRole = sr.sbrnSubRoleId
left join sma_MST_SubRole srNEW
	on srnew.sbrsDscrptn = sr.sbrsDscrptn
		and srnew.sbrnCaseTypeID = cas.newCaseTypeID

select * from #defendant
SELECT * FROM sma_MST_SubRole smsr where smsr.sbrnCaseTypeID = 1587 or smsr.sbrnCaseTypeID = 1591


/* ---------------------------------------------------------------------------------------------------------------------------------------
commit updates
*/


select * FROM #cases
select * from #PLAINTIFF p
select * FROM #DEFENDANT d


update sma_TRN_Defendants
SET defnSubRole = NEWSubRoleID
FROM #DEFENDANT d
JOIN sma_trn_Defendants def on d.defnDefendentID =def.defnDefendentID

update sma_TRN_Plaintiff
SET plnnRole = NEWSubRoleID
--select pl.*
FROM #PLAINTIFF p
JOIN sma_TRN_Plaintiff pl on pl.plnnPlaintiffID = p.plnnPlaintiffID


alter table sma_trn_Cases disable trigger all
GO
update sma_trn_Cases 
SET casnOrgCaseTypeID = newCaseTypeID
	--casnCaseTypeID = NewSubTypeID
--select * 
FROM #Cases c
JOIN sma_trn_cases cas on c.casnCaseID = cas.casnCaseID

alter table sma_trn_Cases enable trigger all
GO