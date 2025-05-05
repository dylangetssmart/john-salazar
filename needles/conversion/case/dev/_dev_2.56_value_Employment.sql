/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create users and contacts

replace:
'OfficeName'
'StateDescription'
'VenderCaseType'
##########################################################################################################################
*/

use [KurtYoung_SA]
go


-------------------------------------------------------------------------------
-- Insert 'Lost Wage' wage type
-------------------------------------------------------------------------------
if not exists (
		select
			1
		from [sma_MST_WagesTypes]
		where wgtsCode = 'LOST'
	)
begin
	insert into [sma_MST_WagesTypes]
		(
		wgtsCode,
		wgtsDscrptn,
		wgtnRecUserID,
		wgtdDtCreated,
		wgtnModifyUserID,
		wgtdDtModified,
		wgtnLevelNo
		)
	values (
	'LOST',
	'Lost Wages',
	368,
	GETDATE(),
	null,
	null,
	null
	)
end

select
	*
from [sma_MST_WagesTypes]


-------------------------------------------------------------------------------
-- Create employment records using value.provider
-------------------------------------------------------------------------------
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
	[empnWorkSiteId]
	)
	select
		(
			select
				plnnPlaintiffID
			from sma_trn_plaintiff
			where plnnCaseID = cas.casncaseid
				and plnbIsPrimary = 1
		)				 as [empnplaintiffid],		--Plaintiff ID
		employer_org.AID as [empnempraddressid],		--employer org AID
		employer_org.CID as [empnemployerid],		--employer org CID
		employer_ind.CID as [empncontactpersonid],	--employer indv CID
		employer_ind.AID as [empncpaddressid],		--employer indv AID
		null			 as [empsjobtitle],			--Job Title  varchar200
		null			 as [empnsalaryfreqid],		--Salary: (frequency)  sma_mst_frequencies.fqmnFrequencyID
		null			 as [empnsalaryamt],			--Salary Amount
		null			 as [empncommissionfreqid],	--Commission: (frequency)  sma_mst_frequencies.fqmnFrequencyID
		null			 as [empncommissionamt],		--Commission Amount
		null			 as [empnbonusfreqid],		--Bonus: (frequency)  sma_mst_frequencies.fqmnFrequencyID
		null			 as [empnbonusamt],			--Bonus Amount
		null			 as [empnovertimefreqid],	--Overtime (frequency)  sma_mst_frequencies.fqmnFrequencyID
		null			 as [empnovertimeamt],		--Overtime Amoun
		null			 as [empnotherfreqid],		--Other Compensation (frequency)  sma_mst_frequencies.fqmnFrequencyID
		null			 as [empnothercompensationamt],	--Other Compensation Amount
		--ISNULL('Time Lost From Work: ' + NULLIF(CONVERT(VARCHAR, ud.Time_Lost_From_Work), '') + CHAR(13), '') +
		--ISNULL('Rate of Pay: ' + NULLIF(CONVERT(VARCHAR, ud.Rate_of_Pay), '') + CHAR(13), '') +
		--ISNULL('Hours per Day: ' + NULLIF(CONVERT(VARCHAR, ud.Hours_per_Day), '') + CHAR(13), '') +
		--ISNULL('Hours per week: ' + NULLIF(CONVERT(VARCHAR, ud.Hours_per_week), '') + CHAR(13), '') +
		--ISNULL('Lost Wage Claim?: ' + NULLIF(CONVERT(VARCHAR, ud.Lost_Wage_Claim), '') + CHAR(13), '') +
		--ISNULL('OOW Slip Requested?: ' + NULLIF(CONVERT(VARCHAR, ud.OOW_Slip_Reqested), '') + CHAR(13), '') +
		--ISNULL('OOW Reqest Sent: ' + NULLIF(CONVERT(VARCHAR, ud.OOW_Request_Sent), '') + CHAR(13), '') +
		''				 as [empscomments],				--employer Comments
		null			 as [empbworksoffbooks],			--bit
		null			 as [empscompensationcomments],	--Compensation Comments
		null			 as [empbworkspartiallyoffbooks],	--bit
		null			 as [empbonthejob],				--On the job injury? bit
		null			 as [empbwcclaim],				--W/C Claim?  bit
		null			 as [empbcontinuing],			--continuing?  bit
		null			 as [empddatehired],			--date hired  Date From:
		null			 as [empnudf1],
		null			 as [empnudf2],
		null			 as [empnrecuserid],
		--case
		--	when ISNULL(v.staff_created, '') <> ''
		--		then (
		--				select
		--					u.usrnUserID
		--				from sma_MST_Users u
		--				where u.source_id = v.staff_created

		--			)
		--	else 368
		--end				 as [empnrecuserid],
		v.date_created	 as [empddtcreated],
		null			 as [empnmodifyuserid],
		--case
		--	when ISNULL(v.staff_modified, '') <> ''
		--		then (
		--				select
		--					u.usrnUserID
		--				from sma_MST_Users u
		--				where u.source_id = v.staff_modified

		--			)
		--end				 as [empnmodifyuserid],
		null			 as [empddtmodified],
		null			 as [empnlevelno],
		null			 as [empnauthtodefcoun],		--Auth. to defense cousel:  bit
		null			 as [empnauthtodefcoundt],	--Auth. to defense cousel:  date
		null			 as [empntotaldisability],	--Temporary Total Disability (TTD)
		null			 as [empnaverageweeklywage],		--Average weekly wage (AWW)
		null			 as [empnempunion],			--Unique Contact ID of Union
		null			 as [notemploymentreasonid],		--1=Minor; 2=Retired; 3=Unemployed; (MST?)
		null			 as [empddateto],			--Date TO;
		null			 as [empsdepartment],		--Department
		null			 as [empdsent],			--emp verification request sent
		null			 as [empdreceived],		--emp verification request received
		null			 as [empnstatusid],		--status  sma_MST_EmploymentStatuses.ID
		null			 as [empnworksiteid]
	--select employer_ind.CID, employer_org.CID, v.party_id, v.provider
	from KurtYoung_Needles..value_indexed v
	join sma_trn_Cases cas
		on cas.cassCaseNumber = CONVERT(VARCHAR, v.case_id)
	join KurtYoung_Needles..names n
		on v.provider = n.names_id
	-- Individual Employer
	left join IndvOrgContacts_Indexed employer_ind
		on employer_ind.SAGA = n.names_id
			and employer_ind.CTG = 1
	-- Organization Employer
	left join IndvOrgContacts_Indexed employer_org
		on employer_org.SAGA = n.names_id
			and employer_org.CTG = 2
	left join IndvOrgContacts_Indexed unid_employer
		on unid_employer.Name = 'Unidentified Employer'
			and employer_org.CTG = 2
	where v.code = 'lw'
go

-------------------------------------------------------------------------------
-- Insert Lost Wages
-------------------------------------------------------------------------------
--delete from [sma_TRN_LostWages]
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
	[ltwnLevelNo]
	)
	select distinct
		e.empnEmploymentID as [ltwnemploymentid]		--sma_trn_employment ID
		,
		(
			select
				wgtnWagesTypeID
			from [sma_MST_WagesTypes]
			where wgtsDscrptn = 'Lost Wages'
		)				   as [ltwstype]   			--[sma_MST_WagesTypes].wgtnWagesTypeID
		,
		case
			when v.start_date between '1/1/1900' and '6/6/2079'
				then v.start_date
			else null
		end				   as [ltwdfrmdt],
		case
			when v.stop_date between '1/1/1900' and '6/6/2079'
				then v.stop_date
			else null
		end				   as [ltwdtodt],
		--null			   as [ltwdfrmdt],
		--null			   as [ltwdtodt],
		null			   as [ltwnamount],
		null			   as [ltwnamtpaid],
		v.total_value	   as [ltwnloss],
		-- ,isnull('Return to work: ' + nullif(convert(Varchar,ud.returntowork),'') + char(13),'') +
		-- ''						as [comments]
		null			   as [comments],
		null			   as [ltwdmdconfreqdt],
		null			   as [ltwdmdconfdt],
		null			   as [ltwdempverfreqdt],
		null			   as [ltwdempverfrcvddt],
		368				   
		as [ltwnrecuserid],
		null			   as [ltwddtcreated],
		null			   as [ltwnmodifyuserid],
		null			   as [ltwddtmodified],
		null			   as [ltwnlevelno]
	-- employment record id: case > plaintiff > employment (value has caseid)
	from KurtYoung_Needles..value_indexed v
	join sma_trn_Cases cas
		on CONVERT(VARCHAR, cas.cassCaseNumber) = v.case_id
	join sma_trn_plaintiff p
		on p.plnnCaseID = cas.casnCaseID
			and p.plnbIsPrimary = 1
	join KurtYoung_Needles..names n
		on v.provider = n.names_id
	-- Individual Employer
	left join IndvOrgContacts_Indexed employer_ind
		on employer_ind.SAGA = n.names_id
			and employer_ind.CTG = 1
	-- Organization Employer
	left join IndvOrgContacts_Indexed employer_org
		on employer_org.SAGA = n.names_id
			and employer_org.CTG = 2
	inner join sma_TRN_Employment e
		on e.empnPlaintiffID = p.plnnPlaintiffID
			and e.empnEmployerID = COALESCE(employer_org.CID, employer_ind.CID) -- Prefer employer_org.CID, fallback to employer_ind.CID
	where v.code = 'LW'


--select * from sma_TRN_Employment ste where 




-- FROM KurtYoung_Needles..user_tab4_data ud
-- JOIN EmployerTemp et on et.employer = ud.employer and et.employer_address = ud.Employer_Address
-- JOIN IndvOrgContacts_Indexed ioc on ioc.SAGA = et.empID and ioc.[Name] = et.employer
-- JOIN [sma_TRN_Employment] e on  e.empnPlaintiffID = p.plnnPlaintiffID and empnEmployerID = ioc.CID


---------------------------------------
-- Update Special Damages
---------------------------------------
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
		'LostWages'		   as spdsreftable,
		lw.ltwnLostWagesID as spdnrecordid,
		lw.ltwnRecUserID   as [spdnrecuserid],
		lw.ltwdDtCreated   as spdddtcreated,
		null			   as [spdnlevelno],
		lw.[ltwnLoss]	   as spdnbillamt,
		lw.ltwdFrmDt	   as spdddatefrom,
		lw.ltwdToDt		   as spdddateto
	from sma_TRN_LostWages lw


alter table [sma_TRN_SpDamages] enable trigger all
go
