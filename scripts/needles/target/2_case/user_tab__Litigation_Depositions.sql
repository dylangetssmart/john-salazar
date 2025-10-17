/*---
description: Insert Depositions from user_tab_data
steps:
	- Disable triggers, add breadcrumbs, create staging table
	- Insert a default deposition type if it doesn't exist.
	- Insert data from the staging table into [sma_TRN_Depositions].
usage_instructions: >
	1. Update the stored procedure BuildNeedlesUserTabStagingTable arguments
	2. Configure [sma_TRN_Depositions] insert as per client specifications
dependencies:
	- 
notes: >
	This script is designed to be reusable. The source data collection is
	abstracted into a CTE, making it clear what needs to change for a
	new project.
---*/

use JohnSalazar_SA
go

---
alter table [sma_TRN_Depositions] disable trigger all
go

exec AddBreadcrumbsToTable 'sma_TRN_Depositions'
go

exec dbo.BuildNeedlesUserTabStagingTable @SourceDatabase = 'JohnSalazar_Needles',
										 @TargetDatabase = 'JohnSalazar_SA',
										 @DataTableName	 = 'user_tab_data',
										 @StagingTable	 = 'staging_depositions',
										 @ColumnList	 = '
Court_Reporter,
Depo_Date,
Depo_Time,
Name,
Transcript_Recd,
Videographer,
Connection_to_Case,
Depo_Location,
Atty_Attending_Depo,
Atty_Retaining_Expert,
Depo_Prep_Date,
Depo_Prep_Time,
Interpreter,
CV_on_file,
Ct_Rptr_Value_Code,
Video_Value_Code';
go
---

select
	*
from JohnSalazar_SA..staging_depositions


/* ---------------------------------------------------------------------------------------------------------------
Create Deposition Type if it doesn't exist
*/
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
Insert Depositions from SourceData CTE
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
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		cas.casnCaseID				as dpsnCaseId,
		dbo.ValidDate(sd.Depo_Date) as dscdEnteredDt,
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
		null						as dpsdOnDate,
		null						as dpsdOnBeforeDt,
		null						as dpsnWithinDays,
		null						as dpsdDaysFromDate,
		null						as dpsdDateToComply,
		null						as dpsnAppointmentID,
		null						as dpsnDtHeldApptID,
		null						as dpsdDateHeld,
		null						as dpsbHeld,
		sd.Court_Reporter_CID		as dpsnCourtReporterID,
		null						as dpsdCourtFiledDt,
		null						as dpsnAgencyID,
		LEFT(
		ISNULL('Connection to Case: ' + NULLIF(CONVERT(VARCHAR(MAX), sd.Connection_to_Case), '') + CHAR(13), '') +
		ISNULL('Depo Location: ' + NULLIF(CONVERT(VARCHAR(MAX), sd.Depo_Location_CID), '') + CHAR(13), '') +
		ISNULL('Atty Attending Depo: ' + NULLIF(CONVERT(VARCHAR(MAX), sd.Atty_Attending_Depo_CID), '') + CHAR(13), '') +
		ISNULL('Atty Retaining Expert: ' + NULLIF(CONVERT(VARCHAR(MAX), sd.Atty_Retaining_Expert_CID), '') + CHAR(13), '') +
		ISNULL('Depo Prep Date: ' + NULLIF(CONVERT(VARCHAR(MAX), sd.Depo_Prep_Date), '') + CHAR(13), '') +
		ISNULL('Depo Prep Time: ' + NULLIF(CONVERT(VARCHAR(MAX), sd.Depo_Prep_Time), '') + CHAR(13), '') +
		ISNULL('CV on file: ' + NULLIF(CONVERT(VARCHAR(MAX), sd.CV_on_file), '') + CHAR(13), '') +
		ISNULL('Ct Rptr Value Code: ' + NULLIF(CONVERT(VARCHAR(MAX), sd.Ct_Rptr_Value_Code), '') + CHAR(13), '') +
		ISNULL('Video Value Code: ' + NULLIF(CONVERT(VARCHAR(MAX), sd.Video_Value_Code), '') + CHAR(13), '') +
		'', 4000)					as dpssComments,
		null						as dpssExhibits,
		0							as dpsnExecutedWaived,
		null						as dpsdExecDt,
		0							as dpsbVideoTape,
		sd.Videographer_CID			as dpsnVideoTapeOperator,
		null						as dpsnVideoTapeCompany,
		null						as dpsnServedBY,
		null						as dpsnOnBehalf,
		368							as dpsnRecUserID,
		dbo.ValidDate(sd.Depo_Date) as dpsdDtCreated,
		null						as dpsnModifyUserID,
		null						as dpsdDtModified,
		1							as dpsnLevelNo,
		case sd.Interpreter
			when 'Y' then 1
			else 0
		end							as dpsntranslator,
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
		sd.tabid					as [saga],
		null						as [source_id],
		'needles'					as [source_db],
		'user_tab_data'				as [source_ref]
	--select *
	from staging_depositions sd
	join sma_TRN_Cases cas
		on cas.saga = sd.caseid
	join IndvOrgContacts_Indexed ioci
		on sd.Name_CID = ioci.CID
go

---
alter table [sma_TRN_Depositions] enable trigger all
go
---
