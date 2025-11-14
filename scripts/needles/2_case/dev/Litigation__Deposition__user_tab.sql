/*---
description: Insert Depositions from user_tab_data
steps:
	- 
	- 
usage_instructions:
	-
dependencies:
	- 
notes: >
	
---*/

use JohnSalazar_SA
go

---
alter table [sma_TRN_Depositions] disable trigger all
go
exec AddBreadcrumbsToTable 'sma_TRN_Depositions'
go
---

SELECT * FROM JohnSalazar_Needles..user_tab_data where Depo_Time is not null


/* ---------------------------------------------------------------------------------------------------------------
Create Deposition Type
*/
--SELECT * FROM ShinerSA..sma_MST_DepositionType smdt

if not exists (
		select
			1
		from [dbo].[sma_MST_DepositionType]
		where dptsCode = 'UNSPC'
	)
begin
	insert into [dbo].[sma_MST_DepositionType]
		(
			[dptsCode],
			[dptsDescription],
			[dptnRecUserID],
			[dptdDtCreated],
			[dptnModifyUserID],
			[dptdDtModified],
			[dptnLevelNo]
		)
		select
			'UNSPC',
			'Deposition - Unspecified' as dptsDescription,
			368						   as dptnRecUserID,
			GETDATE()				   as dptdDtCreated,
			null					   as dptnModifyUserID,
			null					   as dptdDtModified,
			null					   as dptnLevelNo
end

go

/* ---------------------------------------------------------------------------------------------------------------
Insert Depositions
*/
insert into [dbo].[sma_TRN_Depositions]
	(
		[dpsnCaseId],
		[dscdEnteredDt],
		[dpsnType],
		[dpssPartyType],
		[dpsnPartyID],
		[dpsnRoleID],
		[dpsnReqMethodID],
		[dpssServedByType],
		[dpsnServedByID],
		[dpsdServedDt],
		[dpsbExpertNonParty],
		[dpsnPartyNParty],
		[dpsdTrnscrptRcvdDt],
		[dpsdTrnscrptToClientDt],
		[dpsdRcvdFromClient],
		[dpsdTrnscrptServedDt],
		[dpsdExecTransToDefAttorney],
		[dpsnDeponentID],
		[dpsnOnCalendarUpdate],
		[dpsnOnBeforeWithin],
		[dpsnOnDateAppointmentID],
		[dpsdOnDate],
		[dpsdOnBeforeDt],
		[dpsnWithinDays],
		[dpsdDaysFromDate],
		[dpsdDateToComply],
		[dpsnAppointmentID],
		[dpsnDtHeldApptID],
		[dpsdDateHeld],
		[dpsbHeld],
		[dpsnCourtReporterID],
		[dpsdCourtFiledDt],
		[dpsnAgencyID],
		[dpssComments],
		[dpssExhibits],
		[dpsnExecutedWaived],
		[dpsdExecDt],
		[dpsbVideoTape],
		[dpsnVideoTapeOperator],
		[dpsnVideoTapeCompany],
		[dpsnServedBY],
		[dpsnOnBehalf],
		[dpsnRecUserID],
		[dpsdDtCreated],
		[dpsnModifyUserID],
		[dpsdDtModified],
		[dpsnLevelNo],
		[dpsntranslator],
		[dpsnTranslatorAddID],
		[dpsntranslatorCntID],
		[dpsnTransAgnAddID],
		[dpsnTransAgnCntID],
		[dpsnOnDateTaskID],
		[dpsnDtSchTaskId],
		[dpsnOnDateAppointmentIDNew],
		[dpsnAppointmentIDNew],
		[dpsnDtHeldApptIDNew],
		[ServedByUniqueID],
		[TestifyForUniqueID],
		[DeponentUID],
		[CourtReporterUID],
		[CourtAgencyUID],
		[VideoOperatorUID],
		[VideoCompanyUID],
		[TranslatorUID],
		[TranslAgencyUID],
		[dpsbTranslator],
		[dpssDocuments],
		[dpsnIsFull],
		[dpsnIsCT],
		[dpsnIsPTX],
		[dpsnIsVideo],
		[dpsnIsExhibits],
		[dpsnIsSynched],
		[dpsnIsSummary],
		[saga],
		[saga_char],
		[source_db],
		[source_ref]
	)
	select
		cas.casnCaseID				as dpsnCaseId,
		case
			when (dep.litify_ext__Scheduled_Date__c not between '1900-01-01' and '2079-12-31')
				then null
			else dep.litify_ext__Scheduled_Date__c
		end							as dscdEnteredDt,
		(
			select
				dptnDepositionTypeID
			from sma_MST_DepositionType
			where dptsDescription = 'Deposition - Unspecified'
		)							as dpsnType,
		null						as dpssPartyType,
		null						as dpsnPartyID,
		null						as dpsnRoleID,
		(
			select
				sctnSrvcTypeID
			from sma_MST_ServiceTypes
			where sctsDscrptn = 'Unspecified'
		)							as dpsnReqMethodID,
		null						as dpssServedByType,
		null						as dpsnServedByID,
		null						as dpsdServedDt,
		2							as dpsbExpertNonParty,
		1							as dpsnPartyNParty,
		null						as dpsdTrnscrptRcvdDt,
		null						as dpsdTrnscrptToClientDt,
		null						as dpsdRcvdFromClient,
		null						as dpsdTrnscrptServedDt,
		null						as dpsdExecTransToDefAttorney,
		null						as dpsnDeponentID,
		null						as dpsnOnCalendarUpdate,
		null						as dpsnOnBeforeWithin,
		null						as dpsnOnDateAppointmentID,
		case
			when (dep.litify_ext__Deposition_Date_Only__c not between '1900-01-01' and '2079-12-31')
				then null
			else dep.litify_ext__Deposition_Date_Only__c
		end								as dpsdOnDate,
		null						as dpsdOnBeforeDt,
		null						as dpsnWithinDays,
		null						as dpsdDaysFromDate,
		null						as dpsdDateToComply,
		null						as dpsnAppointmentID,
		null						as dpsnDtHeldApptID,
		null						as dpsdDateHeld,
		null						as dpsbHeld,
		null						as dpsnCourtReporterID,
		null						as dpsdCourtFiledDt,
		null						as dpsnAgencyID,
		LEFT(ISNULL('Deposition Name: ' + NULLIF(CONVERT(VARCHAR(MAX), dep.Name), '') + CHAR(13), '') +
		ISNULL('Deposition Notes: ' + NULLIF(CONVERT(VARCHAR(MAX), dbo.udf_StripHTML(dep.litify_ext__Deposition_Notes__c)), '') + CHAR(13), '') +
		ISNULL('Status: ' + NULLIF(CONVERT(VARCHAR(MAX), dep.litify_ext__Status__c), '') + CHAR(13), '') +
		ISNULL('Transcript: ' + NULLIF(CONVERT(VARCHAR(MAX), dep.Transcript__c), '') + CHAR(13), '') +
		'', 4000)					as dpssComments,
		null						as dpssExhibits,
		0							as dpsnExecutedWaived,
		null						as dpsdExecDt,
		0							as dpsbVideoTape,
		null						as dpsnVideoTapeOperator,
		null						as dpsnVideoTapeCompany,
		null						as dpsnServedBY,
		null						as dpsnOnBehalf,
		(
			select
				smu.usrnUserID
			from sma_MST_Users smu
			where smu.saga_char = dep.CreatedById
		)							as dpsnRecUserID,
		case
			when (dep.CreatedDate not between '1900-01-01' and '2079-12-31')
				then null
			else dep.CreatedDate
		end							as dpsdDtCreated,
		(
			select
				smu.usrnUserID
			from sma_MST_Users smu
			where smu.saga_char = dep.LastModifiedById
		)							as dpsnModifyUserID,
		case
			when (dep.LastModifiedDate not between '1900-01-01' and '2079-12-31')
				then null
			else dep.LastModifiedDate
		end							as dpsdDtModified,
		1							as dpsnLevelNo,
		null						as dpsntranslator,
		null						as dpsnTranslatorAddID,
		null						as dpsntranslatorCntID,
		null						as dpsnTransAgnAddID,
		null						as dpsnTransAgnCntID,
		null						as dpsnOnDateTaskID,
		null						as dpsnDtSchTaskId,
		null						as dpsnOnDateAppointmentIDNew,
		null						as dpsnAppointmentIDNew,
		null						as dpsnDtHeldApptIDNew,
		null						as ServedByUniqueID,
		null						as TestifyForUniqueID,
		ioci.UNQCID					as DeponentUID,		-- sma_MST_AllContactInfo.UniqueContactID
		null						as CourtReporterUID,
		null						as CourtAgencyUID,
		null						as VideoOperatorUID,
		null						as VideoCompanyUID,
		null						as TranslatorUID,
		null						as TranslAgencyUID,
		0							as dpsbTranslator,
		null						as dpssDocuments,
		null						as dpsnIsFull,
		null						as dpsnIsCT,
		null						as dpsnIsPTX,
		null						as dpsnIsVideo,
		null						as dpsnIsExhibits,
		null						as dpsnIsSynched,
		null						as dpsnIsSummary,
		null						as [saga],
		dep.Id						as [saga_char],
		'litify'					as [source_db],
		'litify_ext__Deposition__c' as [source_ref]
	--select *
	

	--from ShinerLitify..litify_ext__Deposition__c dep
	--join sma_TRN_Cases cas
	--	on cas.saga_char = dep.litify_ext__Matter__c
	---- plaintiff
	--join sma_TRN_Plaintiff p
	--	on p.plnnCaseID = cas.casnCaseID
	--		and p.plnbIsPrimary = 1
	--join IndvOrgContacts_Indexed ioci
	--	on ioci.CID = p.plnnContactID
	--		and ioci.CTG = p.plnnContactCtg
go

---
alter table [sma_TRN_Depositions] enable trigger all
go
---