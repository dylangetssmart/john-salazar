use ShinerSA
go

------------------------------
--INTAKE CASES
------------------------------
alter table [sma_TRN_Cases] disable trigger all
go

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
		[saga_char],
		[source_db],
		[source_ref]
	)

	select
		m.[name]					 as cassCaseNumber,
		''							 as casbAppName,
		m.litify_pm__Display_Name__c as cassCaseName,
		(
			select
				cstnCaseSubTypeID
			from [sma_MST_CaseSubType] ST
			where ST.cstnGroupID = CST.cstnCaseTypeID
				and ST.cstsDscrptn = ISNULL(MIX.[SmartAdvocate Case Sub Type], 'Unknown')
		)							 as casnCaseTypeID,
		case
			when ISNULL(m.litify_pm__Case_State__c, '') <> ''
				then (
						select
							[sttnStateID]
						from [sma_MST_States]
						where sttsCode = LEFT(m.litify_pm__Case_State__c, 2)
					)
			else (
					select
						[sttnStateID]
					from [sma_MST_States]
					where [sttsDescription] = (
							select
								o.StateName
							from conversion.office o
						)
				)
		end							 as casnState,
		GETDATE()					 as casdStatusFromDt,
		(
			select
				cssnStatusID
			from [sma_MST_CaseStatus]
			where csssDescription = 'Presign - Not Scheduled For Sign Up'
		)							 as casnStatusValueID,
		GETDATE()					 as casdsubstatusfromdt,
		(
			select
				cssnStatusID
			from [sma_MST_CaseStatus]
			where csssDescription = 'Presign - Not Scheduled For Sign Up'
		)							 as casnSubStatusValueID,
		case
			when (m.litify_pm__Open_Date__c not between '1900-01-01' and '2079-12-31')
				then GETDATE()
			else m.litify_pm__Open_Date__c
		end							 
		as casdOpeningDate,
		case
			when (litify_pm__Turned_Down_Date__c not between '1900-01-01' and '2079-12-31')
				then GETDATE()
			else m.litify_pm__Turned_Down_Date__c
		end							 
		as casdClosingDate,
		null,
		null,
		null,
		null,
		null,
		null,
		0,
		litify_pm__Display_Name__c	 as cassCaptionText,
		1,
		0,
		0,
		0,
		0,
		0,
		0,
		1,
		null,
		null,
		null,
		0,
		0,
		case
			when ISNULL(m.litify_pm__Case_State__c, '') <> ''
				then (
						select
							[sttnStateID]
						from [sma_MST_States]
						where sttsCode = LEFT(m.litify_pm__Case_State__c, 2)
					)
			else (
					select
						[sttnStateID]
					from [sma_MST_States]
					where [sttsDescription] = (
							select
								o.StateName
							from conversion.office o
						)
				)
		end							 as casnStateID,
		null,
		null,
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga_char = m.CreatedById
		)							 as casnRecUserID,
		CreatedDate					 as casdDtCreated,
		null,
		null,
		'',
		'',
		null,
		null,
		null,
		cstnCaseTypeID				 as casnOrgCaseTypeID,
		''							 as CassCaption,
		0							 as cassMdl,
		(
			select
				office_id
			from sma_MST_Offices
			where office_name = (
					select
						OfficeName
					from conversion.office o
				)
		)							 as office_id,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null						 as CloseReason,
		null						 as saga,
		M.Id						 as saga_char,
		'litify'					 as source_db,
		'litify_pm__intake__c'		 as source_ref
	--select m.*
	from ShinerLitify..litify_pm__Intake__c m
	left join CaseTypeMap mix
		on mix.LitifyCaseTypeID = m.litify_pm__Case_Type__c
	left join sma_MST_CaseType CST
		on CST.cstsType = ISNULL(mix.[smartadvocate Case Type], 'Negligence')
			and VenderCaseType = 'ShinerCaseType'
	left join sma_TRN_Cases cas
		on cas.saga_char = m.litify_pm__Matter__c
	where cas.casnCaseID is null
--where
--	litify_pm__IsConverted__c <> 1		--not converted to matter
go

---
alter table [sma_TRN_Cases] enable trigger all
go
---