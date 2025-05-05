use ShinerSA
go

/*
select * from ShinerLitify..litify_pm__intake__c	--intake
where litify_pm__IsConverted__c <> 1		--not converted to matter
*/

---------------------------------------------------
--INSERT NEGLIGENCE CASE TYPE FOR UNKNOWN TYPES
---------------------------------------------------
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
		null			 as cstsCode,
		'Negligence'	 as cstsType,
		null			 as cstsSubType,
		null			 as cstnWorkflowTemplateID,
		720				 as cstnExpectedResolutionDays,
		368				 as cstnRecUserID,
		GETDATE()		 as cstdDtCreated,
		368				 as cstnModifyUserID,
		GETDATE()		 as cstdDtModified,
		0				 as cstnLevelNo,
		null			 as cstbTimeTracking,
		(
			select
				cgpnCaseGroupID
			from sma_MST_caseGroup
			where cgpsDscrptn = 'Litify'
		)				 as cstnGroupID,
		null			 as cstnGovtMunType,
		null			 as cstnIsMassTort,
		(
			select
				cssnStatusID
			from [sma_MST_CaseStatus]
			where csssDescription = 'Presign - Not Scheduled For Sign Up'
		)				 as cstnStatusID,
		(
			select
				stpnStatusTypeID
			from [sma_MST_CaseStatusType]
			where stpsStatusType = 'Status'
		)				 as cstnStatusTypeID,
		1				 as cstbActive,
		1				 as cstbUseIncident1,
		'Incident 1'	 as cstsIncidentLabel1,
		'ShinerCaseType' as VenderCaseType
	from [CaseTypeMap] MIX
	left join [sma_MST_CaseType] ct
		on ct.cststype = 'Negligence'
	where
		ct.cstncasetypeid is null


update [sma_MST_CaseType]
set VenderCaseType = 'ShinerCaseType'
where cstsType = 'Negligence'

---(2.1) sma_MST_CaseSubType
--insert into [sma_MST_CaseSubType]
--	(
--		[cstsCode],
--		[cstnGroupID],
--		[cstsDscrptn],
--		[cstnRecUserId],
--		[cstdDtCreated],
--		[cstnModifyUserID],
--		[cstdDtModified],
--		[cstnLevelNo],
--		[cstbDefualt],
--		[saga],
--		[cstnTypeCode]
--	)
--	select
--		null		   as [cstsCode],
--		cstncasetypeid as [cstnGroupID],
--		'Unknown'	   as [cstsDscrptn],
--		368			   as [cstnRecUserId],
--		GETDATE()	   as [cstdDtCreated],
--		null		   as [cstnModifyUserID],
--		null		   as [cstdDtModified],
--		null		   as [cstnLevelNo],
--		1			   as [cstbDefualt],
--		null		   as [saga],
--		(
--			select
--				stcnCodeId
--			from [sma_MST_CaseSubTypeCode]
--			where stcsDscrptn = 'Unknown'
--		)			   as [cstnTypeCode]
--	from [sma_MST_CaseType] CST
--	left join [sma_MST_CaseSubType] sub
--		on sub.[cstnGroupID] = cstncasetypeid
--			and sub.[cstsDscrptn] = 'Unknown'
--	where
--		sub.cstncasesubtypeID is null
--		and cst.cstsType = 'Negligence'