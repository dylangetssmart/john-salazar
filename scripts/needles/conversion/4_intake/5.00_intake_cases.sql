use [JohnSalazar_SA]
go


--SELECT
--	*
--FROM [JohnSalazar_Needles]..case_intake
--WHERE ISNULL(date_opened, '') <> ''--order by intake_taken
--sp_help sma_trn_Cases

alter table sma_trn_Cases
alter column saga INT
go

set quoted_identifier on
go

insert into [dbo].[CaseTypeMixture]
	(
		[matcode],
		[header],
		[description],
		[SmartAdvocate Case Type],
		[SmartAdvocate Case Sub Type]
	)
	select
		'',
		'',
		'',
		'Negligence',
		'Unknown'
	except
	select
		[matcode],
		[header],
		[description],
		[SmartAdvocate Case Type],
		[SmartAdvocate Case Sub Type]
	from CaseTypeMixture

--select * from [CaseTypeMixture]
----------------------------
--CASE SUB TYPES
------------------------------
--INSERT INTO [sma_MST_CaseSubType]
--	(
--	[cstsCode], [cstnGroupID], [cstsDscrptn], [cstnRecUserId], [cstdDtCreated], [cstnModifyUserID], [cstdDtModified], [cstnLevelNo], [cstbDefualt], [saga], [cstnTypeCode]
--	)
--	SELECT
--		NULL							  AS [cstsCode]
--	   ,cstncasetypeid					  AS [cstnGroupID]
--	   ,MIX.[SmartAdvocate Case Sub Type] AS [cstsDscrptn]
--	   ,368								  AS [cstnRecUserId]
--	   ,GETDATE()						  AS [cstdDtCreated]
--	   ,NULL							  AS [cstnModifyUserID]
--	   ,NULL							  AS [cstdDtModified]
--	   ,NULL							  AS [cstnLevelNo]
--	   ,1								  AS [cstbDefualt]
--	   ,NULL							  AS [saga]
--	   ,(
--			SELECT TOP 1
--				stcnCodeId
--			FROM [sma_MST_CaseSubTypeCode]
--			WHERE stcsDscrptn = MIX.[SmartAdvocate Case Sub Type]
--		)								  
--		AS [cstnTypeCode]
--	--select mix.*
--	FROM [sma_MST_CaseType] CST
--	JOIN [CaseTypeMixture] MIX
--		ON ISNULL(MIX.[SmartAdvocate Case Type], '') = ISNULL(CST.cstsType, '') --MIX.matcode=CST.cstsCode  
--	LEFT JOIN [sma_MST_CaseSubType] sub
--		ON sub.[cstnGroupID] = CST.cstnCaseTypeID
--			AND ISNULL(sub.[cstsDscrptn], '') = ISNULL(MIX.[SmartAdvocate Case Sub Type], '')
--	WHERE ISNULL(MIX.[SmartAdvocate Case Type], '') <> ''
--		AND sub.cstnCaseSubTypeID IS NULL
--		AND ISNULL([SmartAdvocate Case Sub Type], '') <> ''


---------------------------------------
--INSERT INTAKE INTO CASES
---------------------------------------

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
		[saga],
		[LIP],
		[casnSeriousInj],
		[casnCorpDefn],
		[casnWebImporter],
		[casnRecoveryClient],
		[cas],
		[ngage],
		[casnClientRecoveredDt],
		[CloseReason],
		[source_ref]
	)
	select distinct
		'Intake ' + RIGHT('00000' + CONVERT(VARCHAR, ROW_ID), 5) as [casscasenumber],
		''														 as [casbappname],
		''														 as [casscasename],
		(
		 select top 1
			 cstnCaseSubTypeID
		 from [sma_MST_CaseSubType] st
		 where st.cstnGroupID = cst.cstnCaseTypeID
			 and st.cstsDscrptn = mix.[SmartAdvocate Case Sub Type]
		)														 as [casncasetypeid],
		(
		 select
			 [sttnStateID]
		 from [sma_MST_States]
		 where [sttsDescription] = (
			  select
				  o.StateName
			  from conversion.office o
			 )
		)														 as [casnstate],
		ISNULL(date_rejected, GETDATE())						 as [casdstatusfromdt],
		null													 as [casnstatusvalueid],
		null													 as [casdsubstatusfromdt],
		null													 as [casnsubstatusvalueid],
		case
			when (c.intake_taken not between '1900-01-01' and '2079-12-31') then GETDATE()
			else c.intake_taken
		end														 as [casdopeningdate],
		case
			when (c.date_rejected between '1900-01-01' and '2079-12-31') then c.date_rejected
			else null
		end														 as [casdclosingdate],
		null													 as [casncasevalueid],
		null													 as [casncasevaluefrom],
		null													 as [casncasevalueto],
		null													 as [casncurrentcourt],
		null													 as [casncurrentjudge],
		null													 as [casncurrentmagistrate],
		null													 as [casncaptionid],
		''														 as [casscaptiontext],
		1														 as [casbmaincase],
		0														 as [casbcaseout],
		0														 as [casbsubout],
		0														 as [casbwcout],
		0														 as [casbpartialout],
		0														 as [casbpartialsubout],
		0														 as [casbpartiallysettled],
		0														 as [casbinhouse],
		1														 as [casbautotimer],
		null													 as [casdexpresolutiondate],
		null													 as [casdincidentdate],
		null													 as [casntotalliability],
		null													 as [casssharingcodeid],
		(
		 select
			 [sttnStateID]
		 from [sma_MST_States]
		 where [sttsDescription] = (
			  select
				  o.StateName
			  from conversion.office o
			 )
		)														 as [casnstateid],
		null													 as [casnlastmodifiedby],
		null													 as [casdlastmodifieddate],
		(
		 select
			 usrnUserID
		 from sma_MST_Users
		 where source_id = c.taken_by
		)														 as [casnrecuserid],
		case
			when (c.intake_taken between '1900-01-01' and '2079-06-06') then c.intake_taken
			else null
		end														 as [casddtcreated],
		null													 as [casnmodifyuserid],
		null													 as [casddtmodified],
		0														 as [casnlevelno],
		''														 as [casscasevaluecomments],
		null													 as [casbrefin],
		null													 as [casbdelete],
		null													 as [casbintaken],
		cstnCaseTypeID											 as [casnorgcasetypeid],
		''														 as [casscaption],
		0														 as [cassmdl],
		(
		 select
			 office_id
		 from sma_MST_Offices
		 where office_name = (select o.OfficeName from conversion.office o)
		)														 as [office_id],
		ROW_ID													 as [saga],
		null													 as [lip],
		null													 as [casnseriousinj],
		null													 as [casncorpdefn],
		null													 as [casnwebimporter],
		null													 as [casnrecoveryclient],
		null													 as [cas],
		null													 as [ngage],
		null													 as [casnclientrecovereddt],
		0														 as [closereason],
		'case_intake'											 as [source_ref]
	--select *
	from [JohnSalazar_Needles].[dbo].[Case_intake] c
	left join [CaseTypeMixture] mix
		on mix.matcode = REPLACE(c.matcode, ' ', '')
	left join sma_MST_CaseType cst
		on ISNULL(cst.cstsType, '') = ISNULL(mix.[SmartAdvocate Case Type], '')
	where
		ISNULL(name_ID, '') <> ''
--and ISNULL(c.date_opened, '') <> ''


--select * FROM [JohnSalazar_Needles].[dbo].[Case_intake] C

------------------------------------------
--INTAKE STATUS
------------------------------------------
insert into [sma_TRN_CaseStatus]
	(
		[cssnCaseID],
		[cssnStatusTypeID],
		[cssnStatusID],
		[cssnExpDays],
		[cssdFromDate],
		[cssdToDt],
		[csssComments],
		[cssnRecUserID],
		[cssdDtCreated],
		[cssnModifyUserID],
		[cssdDtModified],
		[cssnLevelNo],
		[cssnDelFlag]
	)
	select
		cas.casnCaseID,
		(
		 select
			 stpnStatusTypeID
		 from sma_MST_CaseStatusType
		 where stpsStatusType = 'Status'
		)	 as [cssnstatustypeid],
		case
			when c.date_rejected between '1900-01-01' and '2079-06-06' then (
					 select
						 cssnstatusid
					 from sma_MST_CaseStatus
					 where csssDescription = 'Closed Case'
					)
			else (
				 select
					 cssnstatusid
				 from sma_MST_CaseStatus
				 where csssDescription = 'Presign - Not scheduled for Sign Up'
				)
		end	 as [cssnstatusid],
		''	 as [cssnexpdays],
		case
			when c.date_rejected between '1900-01-01' and '2079-06-06' then CONVERT(DATE, c.date_rejected)
			else GETDATE()
		end	 as [cssdfromdate],
		null as [cssdtodt],
		case
			when date_rejected is not null then 'Rejected'
			else ''
		end	 as [cssscomments],
		368,
		GETDATE(),
		null,
		null,
		null,
		null
	from [sma_trn_cases] cas
	join [JohnSalazar_Needles]..case_intake c
		on c.ROW_ID = cas.saga
go

------------------------------
--INCIDENT
------------------------------

--alter table [sma_TRN_Incidents] disable trigger all
--go

--alter table [sma_TRN_Cases] disable trigger all
--go

-----
--insert into [sma_TRN_Incidents]
--	(
--	[CaseId],
--	[IncidentDate],
--	[StateID],
--	[LiabilityCodeId],
--	[IncidentFacts],
--	[MergedFacts],
--	[Comments],
--	[IncidentTime],
--	[RecUserID],
--	[DtCreated],
--	[ModifyUserID],
--	[DtModified]
--	)
--	select
--		cas.casnCaseID as caseid,
--		case
--			when (c.[date_of_incident] between '1900-01-01' and '2079-06-06')
--				then CONVERT(DATE, c.[date_of_incident])
--			else null
--		end			   as incidentdate,
--		(
--			select
--				sttnStateID
--			from sma_MST_States
--			where sttsCode = 'VA'
--		)			   as [stateid],
--		0			   as liabilitycodeid,
--		c.synopsis	   as incidentfacts,
--		''			   as [mergedfacts],
--		null		   as [comments],
--		null		   as [incidenttime],
--		368			   as [recuserid],
--		GETDATE()	   as [dtcreated],
--		null		   as [modifyuserid],
--		null		   as [dtmodified]
--	--Select *
--	from [JohnSalazar_Needles]..case_intake c
--	join [sma_TRN_cases] cas
--		on c.ROW_ID = cas.saga


--update CAS
--set CAS.casdIncidentDate = INC.IncidentDate,
--	CAS.casnStateID = INC.StateID,
--	CAS.casnState = INC.StateID
--from sma_trn_cases as cas
--left join sma_TRN_Incidents as inc
--	on casnCaseID = caseid
--where inc.CaseId = cas.casncaseid

-----
--alter table [sma_TRN_Incidents] enable trigger all
--go

alter table [sma_TRN_Cases] enable trigger all
go
--

----------------------------
----INCIDENT LOCATION
----------------------------
----INCIDENT LOCATION UDF IF NOT EXISTS
--INSERT INTO [dbo].[sma_MST_UDFDefinition] (
--		[udfsUDFCtg],
--		[udfnRelatedPK],
--		[udfsUDFName],
--		[udfsScreenName],
--		[udfsType],
--		[udfsLength],
--		[udfsFormat],
--		[udfsTableName],
--		[udfsNewValues],
--		[udfsDefaultValue],
--		[udfnSortOrder],
--		[udfbIsActive],
--		[udfnRecUserID],
--		[udfnDtCreated],
--		[udfnModifyUserID],
--		[udfnDtModified],
--		[udfnLevelNo],
--		[udfbIsSystem],
--		[UdfShortName],
--		[DisplayInSingleColumn]  )
--SELECT DISTINCT 
--		'C'						as [udfsUDFCtg],
--		casnOrgCaseTypeID		as [udfnRelatedPK],
--		'Location'				as [udfsUDFName],
--		'Incident Wizard'		as [udfsScreenName],
--		'Text'					as [udfsType],
--		100						as [udfsLength],
--		null,null,null,null,
--		0						as [udfnSortOrder],
--		1						as [udfbIsActive],
--		368						as [udfnRecUserID],
--		getdate()				as [udfnDtCreated],
--		null,null,0,0,null,0 
--FROM sma_trn_Cases CAS 
--LEFT JOIN sma_MST_UDFDefinition UD on UD.udfnRelatedPK=cas.casnOrgCaseTypeID and UD.udfsScreenName='Incident Wizard' and udfsUDFName= 'Location'
--WHERE UD.udfnUDFID IS NULL
--and cas.cassCaseNumber like 'Intake%'
--and isnull(casnOrgCaseTypeID,'') <> ''

----------------------------
-----LOCATION UDF VALUES---
----------------------------
--INSERT INTO [sma_TRN_UDFValues] (
--       [udvnUDFID]
--      ,[udvsScreenName]
--      ,[udvsUDFCtg]
--      ,[udvnRelatedID]
--      ,[udvnSubRelatedID]
--      ,[udvsUDFValue]
--      ,[udvnRecUserID]
--      ,[udvdDtCreated]
--      ,[udvnModifyUserID]
--      ,[udvdDtModified]
--      ,[udvnLevelNo]
--)
--SELECT DISTINCT
--    (select udfnUDFID from sma_MST_UDFDefinition 
--	   where udfnRelatedPK= cas.casnOrgCaseTypeID
--	   and udfsScreenName='Incident Wizard'
--	   and udfsUDFName='Location')
--    						  as [udvnUDFID],
--    'Incident Wizard'		  as [udvsScreenName],
--    'I'						  as [udvsUDFCtg],
--    CAS.casnCaseID			  as [udvnRelatedID],
--    0						  as[udvnSubRelatedID],
--    convert(varchar(max),c.Location_Case)			  as [udvsUDFValue], 
--    368						  as [udvnRecUserID],
--    getdate()				  as [udvdDtCreated],
--    null					  as [udvnModifyUserID],
--    null					  as [udvdDtModified],
--    null					  as [udvnLevelNo]
--FROM [sma_TRN_Cases] CAS
--JOIN [JohnSalazar_Needles]..case_intake C on C.ROW_ID = CAS.saga 
--WHERE isnull(convert(varchar(max),c.Location_Case),'')<>''
