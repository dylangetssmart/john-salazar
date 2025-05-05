/*


*/

use ShinerSA

------------------------------------------------------------------------------------------------------
-- [5.0] Cases
------------------------------------------------------------------------------------------------------

alter table [sma_TRN_Cases] disable trigger all
go

insert into [sma_TRN_Cases]
	(
	[cassCaseNumber], [casbAppName], [cassCaseName], [casnCaseTypeID], [casnState], [casdStatusFromDt], [casnStatusValueID], [casdsubstatusfromdt], [casnSubStatusValueID], [casdOpeningDate], [casdClosingDate], [casnCaseValueID], [casnCaseValueFrom], [casnCaseValueTo], [casnCurrentCourt], [casnCurrentJudge], [casnCurrentMagistrate], [casnCaptionID], [cassCaptionText], [casbMainCase], [casbCaseOut], [casbSubOut], [casbWCOut], [casbPartialOut], [casbPartialSubOut], [casbPartiallySettled], [casbInHouse], [casbAutoTimer], [casdExpResolutionDate], [casdIncidentDate], [casnTotalLiability], [cassSharingCodeID], [casnStateID], [casnLastModifiedBy], [casdLastModifiedDate], [casnRecUserID], [casdDtCreated], [casnModifyUserID], [casdDtModified], [casnLevelNo], [cassCaseValueComments], [casbRefIn], [casbDelete], [casbIntaken], [casnOrgCaseTypeID], [CassCaption], [cassMdl], [office_id], [saga], [LIP], [casnSeriousInj], [casnCorpDefn], [casnWebImporter], [casnRecoveryClient], [cas], [ngage], [casnClientRecoveredDt], [CloseReason], [saga_char]
	)
	select
		m.[Name]					 as casscasenumber,
		''							 as casbappname,
		m.litify_pm__Display_Name__c as casscasename,
		(
			select
				cstnCaseSubTypeID
			from [sma_MST_CaseSubType] st
			where st.cstnGroupID = cst.cstnCaseTypeID
				and st.cstsDscrptn = mix.[SmartAdvocate Case Sub Type]
		)							 as casncasetypeid,
		case
			when ISNULL(m.litify_pm__Matter_State__c, '') <> ''
				then (
						select
							[sttnStateID]
						from [sma_MST_States]
						where sttsCode = LEFT(m.litify_pm__Matter_State__c, 2)
					)
			else (
					select
						[sttnStateID]
					from [sma_MST_States]
					where [sttsDescription] = (
							select
								StateName
							from conversion.office
						)
				)
		end							 as casnstate,
		GETDATE()					 as casdstatusfromdt,
		(
			select
				cssnStatusID
			from [sma_MST_CaseStatus]
			where csssDescription = 'Presign - Not Scheduled For Sign Up'
		)							 as casnstatusvalueid,
		GETDATE()					 as casdsubstatusfromdt,
		(
			select
				cssnStatusID
			from [sma_MST_CaseStatus]
			where csssDescription = 'Presign - Not Scheduled For Sign Up'
		)							 as casnsubstatusvalueid,
		case
			when (m.litify_pm__Open_Date__c not between '1900-01-01' and '2079-12-31')
				then GETDATE()
			else m.litify_pm__Open_Date__c
		end							 
		as casdopeningdate,
		case
			when m.litify_pm__Status__c = 'Closed'
				then case
						when ISNULL(m.litify_pm__Closed_Date__c, m.litify_pm__Close_Date__c) is null
							then GETDATE()
						when ISNULL(m.litify_pm__Closed_Date__c, m.litify_pm__Close_Date__c) not between '1900-01-01' and '2079-12-31'
							then GETDATE()
						else ISNULL(m.litify_pm__Closed_Date__c, m.litify_pm__Close_Date__c)
					end
			else null
		end							 
		as casdclosingdate,
		null						 as [casnCaseValueID],
		null						 as [casnCaseValueFrom],
		null						 as [casnCaseValueTo],
		null						 as [casnCurrentCourt],
		null						 as [casnCurrentJudge],
		null						 as [casnCurrentMagistrate],
		0							 as [casnCaptionID],
		litify_pm__Case_Title__c	 as casscaptiontext,
		1							 as [casbMainCase],
		0							 as [casbCaseOut],
		0							 as [casbSubOut],
		0							 as [casbWCOut],
		0							 as [casbPartialOut],
		0							 as [casbPartialSubOut],
		0							 as [casbPartiallySettled],
		1							 as [casbInHouse],
		null						 as [casbAutoTimer],
		null						 as [casdExpResolutionDate],
		null						 as [casdIncidentDate],
		0							 as [casnTotalLiability],
		0							 as [cassSharingCodeID],
		case
			when ISNULL(m.litify_pm__Matter_State__c, '') <> ''
				then (
						select
							[sttnStateID]
						from [sma_MST_States]
						where sttsCode = LEFT(m.litify_pm__Matter_State__c, 2)
					)
			else (
					select
						[sttnStateID]
					from [sma_MST_States]
					where [sttsDescription] = (
							select
								StateName
							from conversion.office so
						)
				)
		end							 as [casnstateid],
		null						 as [casnLastModifiedBy],
		null						 as [casdLastModifiedDate],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga = m.CreatedById
		)							 as [casnrecuserid],
		CreatedDate					 as [casddtcreated],
		null						 as [casnModifyUserID],
		null						 as [casdDtModified],
		''							 as [casnLevelNo],
		''							 as [cassCaseValueComments],
		null						 as [casbRefIn],
		null						 as [casbDelete],
		null						 as [casbIntaken],
		cstnCaseTypeID				 as [casnorgcasetypeid],
		m.litify_pm__Case_Title__c	 as [casscaption],
		0							 as [cassmdl],
		(
			select
				office_id
			from sma_mst_offices
			where office_name = (
					select
						OfficeName
					from conversion.office so
				)
		)							 as [office_id],
		null						 as [saga],
		null						 as [LIP],
		null						 as [casnSeriousInj],
		null						 as [casnCorpDefn],
		null						 as [casnWebImporter],
		null						 as [casnRecoveryClient],
		null						 as [cas],
		null						 as [ngage],
		null						 as [casnClientRecoveredDt],
		null						 as [closereason],
		m.Id						 as [saga_char]
	from conversion.cases_to_convert ctc
	join ShinerLitify..litify_pm__Matter__c m
		on m.Id = ctc.matter_id
	join CaseTypeMap mix
		on mix.LitifyCaseTypeID = m.litify_pm__Case_Type__c
	left join sma_MST_CaseType cst
		on cst.cstsType = mix.[SmartAdvocate Case Type]
			and VenderCaseType = (
				select
					VenderCaseType
				from conversion.office so
			)


--from ShinerLitify..litify_pm__Matter__c m
----JOIN ShinerLitify..litify_pm__case_type__c ct on ct.id = m.litify_pm__Case_Type__c
--where
--	/*
--	There are two close dates:
--		- litify_pm__Close_Date__c
--		- litify_pm__Closed_Date__c
--	Skip cases where either close date is on or before January 5, 2023
--	*/
--	(
--		(m.litify_pm__Close_Date__c is not null	and m.litify_pm__Close_Date__c < '2023-01-06')
--	or
--		(m.litify_pm__Closed_Date__c is not null and m.litify_pm__Closed_Date__c < '2023-01-06')
--	)

--	or

--	-- Skip cases with no closed date that are in a Closed status
--	(
--		(m.litify_pm__Close_Date__c is null and m.litify_pm__Closed_Date__c is null)
--	and
--		m.litify_pm__Status__c = 'Closed'
--	)
go


alter table [sma_TRN_Cases] enable trigger all
go