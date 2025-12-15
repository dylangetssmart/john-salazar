/*---
description: Insert Employers and lost wages from [value]
steps:
	1. Insert [sma_TRN_Employment]
	2. Insert [sma_MST_WagesTypes]
	3. Insert [sma_TRN_LostWages]
	4. Update [sma_TRN_SpDamages]
instructions:
	1. Ensure [ValueCodeMap] is updated with applicable value codes
	2. Update insert statements as necessary
dependencies:
	- [Needles]..[value_Indexed]
    - [SA].[dbo].[ValueCodeMap]
	- [SA].[dbo].[sma_TRN_Cases]
	- [SA].[dbo].[IndvOrgContacts_Indexed]
	- [SA].[dbo].[sma_TRN_Plaintiff]
notes: >
---*/


use [SA]
go

exec AddBreadcrumbsToTable 'sma_TRN_Employment'
go


/* ------------------------------------------------------------------------------
Employers
*/ ------------------------------------------------------------------------------
-- Create employment records from [value].[provider]
insert into [dbo].[sma_TRN_Employment]
	(
		[empnPlaintiffID],
		[empnEmprAddressID],
		[empnEmployerID],
		[empnContactPersonID],
		[empnCPAddressId],
		[empsJobTitle],
		[empnSalaryFreqID],
		[empnSalaryAmt],
		[empnCommissionFreqID],
		[empnCommissionAmt],
		[empnBonusFreqID],
		[empnBonusAmt],
		[empnOverTimeFreqID],
		[empnOverTimeAmt],
		[empnOtherFreqID],
		[empnOtherCompensationAmt],
		[empsComments],
		[empbWorksOffBooks],
		[empsCompensationComments],
		[empbWorksPartiallyOffBooks],
		[empbOnTheJob],
		[empbWCClaim],
		[empbContinuing],
		[empdDateHired],
		[empnUDF1],
		[empnUDF2],
		[empnRecUserID],
		[empdDtCreated],
		[empnModifyUserID],
		[empdDtModified],
		[empnLevelNo],
		[empnauthtodefcoun],
		[empnauthtodefcounDt],
		[empnTotalDisability],
		[empnAverageWeeklyWage],
		[empnEmpUnion],
		[NotEmploymentReasonID],
		[empdDateTo],
		[empsDepartment],
		[empdSent],
		[empdReceived],
		[empnStatusId],
		[empnWorkSiteId],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		(
		 select
			 plnnPlaintiffID
		 from sma_trn_plaintiff
		 where plnnCaseID = cas.casnCaseID
			 and plnbIsPrimary = 1
		)		   as [empnPlaintiffID],			-- Plaintiff ID
		ioci.AID   as [empnEmprAddressID],			-- employer org AID
		ioci.CID   as [empnEmployerID],				-- employer org CID
		null	   as [empnContactPersonID],		-- indv CID
		null	   as [empnCPAddressId],			-- indv AID
		null	   as [empsJobTitle],
		(
		 select
			 fqmnFrequencyID
		 from sma_MST_Frequencies
		 where fqmsCode = 'AN'
		)		   as [empnSalaryFreqID],
		null	   as [empnSalaryAmt],
		null	   as [empnCommissionFreqID],		-- Commission: (frequency) > sma_mst_frequencies.fqmnFrequencyID
		null	   as [empnCommissionAmt],			-- Commission Amount
		null	   as [empnBonusFreqID],			-- Bonus: (frequency) > sma_mst_frequencies.fqmnFrequencyID
		null	   as [empnBonusAmt],				-- Bonus Amount
		null	   as [empnOverTimeFreqID],			-- Overtime (frequency) > sma_mst_frequencies.fqmnFrequencyID
		null	   as [empnOverTimeAmt],			-- Overtime Amoun
		null	   as [empnOtherFreqID],			-- Other Compensation (frequency) > sma_mst_frequencies.fqmnFrequencyID
		null	   as [empnOtherCompensationAmt],	-- Other Compensation Amount
		null	   as [empsComments],
		null	   as [empbWorksOffBooks],
		null	   as empsCompensationComments,		-- Compensation Comments
		null	   as [empbWorksPartiallyOffBooks],	-- bit
		null	   as [empbOnTheJob],				-- On the job injury? bit
		null	   as [empbWCClaim],				-- W/C Claim?  bit
		null	   as [empbContinuing],				-- continuing?  bit
		null	   as [empdDateHired],				-- Date From
		null	   as [empnUDF1],
		null	   as [empnUDF2],
		368		   as [empnRecUserID],
		GETDATE()  as [empdDtCreated],
		null	   as [empnModifyUserID],
		null	   as [empdDtModified],
		null	   as [empnLevelNo],
		null	   as [empnauthtodefcoun],			-- Auth. to defense cousel:  bit
		null	   as [empnauthtodefcounDt],		-- Auth. to defense cousel:  date
		null	   as [empnTotalDisability],		-- Temporary Total Disability (TTD)
		null	   as [empnAverageWeeklyWage],		-- Average weekly wage (AWW)
		null	   as [empnEmpUnion],				-- Unique Contact ID of Union
		null	   as [NotEmploymentReasonID],		-- 1=Minor; 2=Retired; 3=Unemployed; (MST?)
		null	   as [empdDateTo],
		null	   as [empsDepartment],
		null	   as [empdSent],					-- emp verification request sent
		null	   as [empdReceived],				-- emp verification request received
		null	   as [empnStatusId],				-- status  > sma_MST_EmploymentStatuses.ID
		null	   as [empnWorkSiteId],
		v.value_id as [saga],
		null	   as [source_id],
		'needles'  as [source_db],
		'value'	   as [source_ref]
	--select *
	from [Needles]..value_Indexed v
	join [Needles]..names n
		on n.names_id = v.provider
	--join [Needles]..provider p
	--on p.name_id = n.names_id
	join sma_trn_Cases cas
		on cas.cassCaseNumber = CONVERT(VARCHAR, v.case_id)
	join IndvOrgContacts_Indexed ioci
		on ioci.saga = n.names_id
	where
		v.code in (
		 select
			 code
		 from [ValueCodeMap]
		 where [SA_Screen] = 'Employment'
		);
go


/* ------------------------------------------------------------------------------
Lost Wages
*/ ------------------------------------------------------------------------------
exec AddBreadcrumbsToTable 'sma_TRN_LostWages'
go

-- Create wage types
insert into [dbo].[sma_MST_WagesTypes]
	(
		[wgtsCode],
		[wgtsDscrptn],
		[wgtnRecUserID],
		[wgtdDtCreated],
		[wgtnModifyUserID],
		[wgtdDtModified],
		[wgtnLevelNo]
	)
	select
		'LWG'		 as wgtsCode,
		'Lost Wages' as wgtsDscrptn,
		368			 as wgtnRecUserID,
		GETDATE()	 as wgtdDtCreated,
		null		 as wgtnModifyUserID,
		null		 as wgtdDtModified,
		null		 as wgtnLevelNo
	where
		not exists (
		 select
			 1
		 from [dbo].[sma_MST_WagesTypes]
		 where wgtsCode = 'LWG'
		);
go


-- Insert Lost Wages
insert into [sma_TRN_LostWages]
	(
		[ltwnEmploymentID],
		[ltwsType],
		[ltwdFrmDt],
		[ltwdToDt],
		[ltwnAmount],
		[ltwnAmtPaid],
		[ltwnLoss],
		[Comments],
		[ltwdMDConfReqDt],
		[ltwdMDConfDt],
		[ltwdEmpVerfReqDt],
		[ltwdEmpVerfRcvdDt],
		[ltwnRecUserID],
		[ltwdDtCreated],
		[ltwnModifyUserID],
		[ltwdDtModified],
		[ltwnLevelNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select distinct
		e.empnEmploymentID as [ltwnEmploymentID]		--sma_trn_employment ID
		,
		(
		 select
			 wgtnWagesTypeID
		 from [sma_MST_WagesTypes]
		 where wgtsDscrptn = 'Lost Wages'
		)				   as [ltwsType],   			--[sma_MST_WagesTypes].wgtnWagesTypeID
		case
			when v.start_date between '1900-01-01' and '2079-06-06' then v.start_date
			else null
		end				   as [ltwdFrmDt],
		case
			when v.stop_date between '1900-01-01' and '2079-06-06' then v.stop_date
			else null
		end				   as [ltwdToDt],
		null			   as [ltwnAmount],
		null			   as [ltwnAmtPaid],
		v.total_value	   as [ltwnLoss],
		ISNULL('Memo: ' + NULLIF(CONVERT(VARCHAR, v.memo), '') + CHAR(13), '') +
		''				   as [comments],
		null			   as [ltwdMDConfReqDt],
		null			   as [ltwdMDConfDt],
		null			   as [ltwdEmpVerfReqDt],
		null			   as [ltwdEmpVerfRcvdDt],
		368				   as [ltwnRecUserID],
		GETDATE()		   as [ltwdDtCreated],
		null			   as [ltwnModifyUserID],
		null			   as [ltwdDtModified],
		null			   as [ltwnLevelNo],
		v.value_id		   as [saga],
		null			   as [source_id],
		'needles'		   as [source_db],
		'value_indexed'	   as [source_ref]
	-- employment record id: case > plaintiff > employment (value has caseid)
	from [Needles]..value_indexed v
	join sma_trn_Cases cas
		on cas.cassCaseNumber = CONVERT(VARCHAR, v.case_id)
	join sma_trn_plaintiff p
		on p.plnnCaseID = cas.casnCaseID
			and p.plnbIsPrimary = 1
	inner join sma_TRN_Employment e
		on e.empnPlaintiffID = p.plnnPlaintiffID
	where
		code in (
		 select
			 code
		 from [ValueCodeMap]
		 where [SA_Screen] = 'Employment'
		);
go


-- Update Special Damages
alter table [sma_TRN_SpDamages] disable trigger all
go

insert into [sma_TRN_SpDamages]
	(
		[spdsRefTable],
		[spdnRecordID],
		[spdnRecUserID],
		[spddDtCreated],
		[spdnLevelNo],
		spdnBillAmt,
		spddDateFrom,
		spddDateTo
	)
	select distinct
		'LostWages'		   as spdsRefTable,
		lw.ltwnLostWagesID as spdnRecordID,
		lw.ltwnRecUserID   as [spdnRecUserID],
		lw.ltwdDtCreated   as spddDtCreated,
		null			   as [spdnLevelNo],
		lw.[ltwnLoss]	   as spdnBillAmt,
		lw.ltwdFrmDt	   as spddDateFrom,
		lw.ltwdToDt		   as spddDateTo
	from sma_TRN_LostWages LW


alter table [sma_TRN_SpDamages] enable trigger all
go