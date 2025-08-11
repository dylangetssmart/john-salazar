/*
- create employer records from value.provider > names.names_id
- create special damage records for lost wages
*/

use JohnSalazar_SA
go


--select
--	[Dates_of_Employment],
--	[Employer_Name],
--	[Job_Description],
--	[Lost_income],
--	[Other_Employment],
--	[Pay_Period],
--	[Rate_of_Pay],
--	[Time_Out_of_Work]
--from JohnSalazar_Needles..user_party_data upd

/* ------------------------------------------------------------------------------
[sma_TRN_Employment] Schema
*/

-- saga
if not exists (
	 select
		 *
	 from sys.columns
	 where Name = N'saga'
		 and object_id = OBJECT_ID(N'sma_TRN_Employment')
	)
begin
	alter table [sma_TRN_Employment] add [saga] INT null;
end

go

-- source_id
if not exists (
	 select
		 *
	 from sys.columns
	 where Name = N'source_id'
		 and object_id = OBJECT_ID(N'sma_TRN_Employment')
	)
begin
	alter table [sma_TRN_Employment] add [source_id] VARCHAR(MAX) null;
end

go

-- source_db
if not exists (
	 select
		 *
	 from sys.columns
	 where Name = N'source_db'
		 and object_id = OBJECT_ID(N'sma_TRN_Employment')
	)
begin
	alter table [sma_TRN_Employment] add [source_db] VARCHAR(MAX) null;
end

go

-- source_ref
if not exists (
	 select
		 *
	 from sys.columns
	 where Name = N'source_ref'
		 and object_id = OBJECT_ID(N'sma_TRN_Employment')
	)
begin
	alter table [sma_TRN_Employment] add [source_ref] VARCHAR(MAX) null;
end

go


/* ------------------------------------------------------------------------------
Create Employment records
*/

-- EmployerData CTE
-- employer_name is the only field with type = name, so explicitly join to user_party_matter to jump to user_party_name

;
with EmployerData
as
(
 select
	 upd.case_id,
	 upd.party_id,
	 upd.Dates_of_Employment,
	 upd.Employer_Name,
	 upd.Job_Description,
	 upd.Lost_income,
	 upd.Other_Employment,
	 upd.Pay_Period,
	 upd.Rate_of_Pay,
	 upd.Time_Out_of_Work,
	 upn.user_name as employer_names_id
 from JohnSalazar_Needles..user_party_data upd
 left join JohnSalazar_Needles..user_party_name upn
	 on upd.party_id = upn.party_id
	 and upd.case_id = upn.case_id
 left join JohnSalazar_Needles..user_party_matter upm
	 on upn.ref_num = upm.ref_num
	 and upm.field_title = 'Employer Name'
 join JohnSalazar_Needles..cases c
	 on c.matcode = upm.mattercode
	 and c.casenum = upd.case_id
--where upd.case_id = 206807

)
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
	) select
		(
		 select
			 plnnPlaintiffID
		 from sma_trn_plaintiff
		 where plnnCaseID = cas.casncaseid
			 and plnbIsPrimary = 1
		)				  as [empnPlaintiffID],			-- Plaintiff ID
		ioci.AID		  as [empnEmprAddressID],			-- employer org AID
		ioci.CID		  as [empnEmployerID],				-- employer org CID
		null			  as [empnContactPersonID],		-- indv CID
		null			  as [empnCPAddressId],			-- indv AID
		e.Job_Description as [empsJobTitle],
		case LTRIM(RTRIM(UPPER(e.Pay_Period)))
				when 'DAY' then 1  -- Daily
				when 'WEEK' then 2  -- Weekly
				when 'MONTH' then 3  -- Monthly
				when 'YEAR' then 5  -- Annually
				when 'HOUR' then 7  -- Hourly
				when 'SEMI - WEEKLY' then 8  -- Bimonthly
				when 'BI - WEEKLY' then 6  -- Biweekly
				else null
		end				  as [empnSalaryFreqID],
		TRY_CAST(
		REPLACE(
		REPLACE(e.Rate_of_Pay, '$', ''),
		'/hr', ''
		)
		as NUMERIC(18, 2))
		as [empnSalaryAmt],
		null			  as [empnCommissionFreqID],		-- Commission: (frequency) > sma_mst_frequencies.fqmnFrequencyID
		null			  as [empnCommissionAmt],			-- Commission Amount
		null			  as [empnBonusFreqID],			-- Bonus: (frequency) > sma_mst_frequencies.fqmnFrequencyID
		null			  as [empnBonusAmt],				-- Bonus Amount
		null			  as [empnOverTimeFreqID],			-- Overtime (frequency) > sma_mst_frequencies.fqmnFrequencyID
		null			  as [empnOverTimeAmt],			-- Overtime Amoun
		null			  as [empnOtherFreqID],			-- Other Compensation (frequency) > sma_mst_frequencies.fqmnFrequencyID
		null			  as [empnOtherCompensationAmt],	-- Other Compensation Amount
		ISNULL('Dates of Employment: ' + NULLIF(CONVERT(VARCHAR, e.Dates_of_Employment), '') + CHAR(13), '') +
		ISNULL('Rate of Pay: ' + NULLIF(CONVERT(VARCHAR, e.Rate_of_Pay), '') + CHAR(13), '') +
		ISNULL('Hours per Day: ' + NULLIF(CONVERT(VARCHAR, e.Pay_Period), '') + CHAR(13), '') +
		''				  as [empsComments],
		null			  as [empbWorksOffBooks],
		ISNULL('Lost Income: ' + NULLIF(CONVERT(VARCHAR, e.Lost_income), '') + CHAR(13), '') +
		ISNULL('Other Employment: ' + NULLIF(CONVERT(VARCHAR, e.Other_Employment), '') + CHAR(13), '') +
		ISNULL('Time Out of Work: ' + NULLIF(CONVERT(VARCHAR, e.Time_Out_of_Work), '') + CHAR(13), '') +
		''				  as empsCompensationComments,		-- Compensation Comments
		null			  as [empbWorksPartiallyOffBooks],	-- bit
		null			  as [empbOnTheJob],				-- On the job injury? bit
		null			  as [empbWCClaim],				-- W/C Claim?  bit
		null			  as [empbContinuing],				-- continuing?  bit
		null			  as [empdDateHired],				-- Date From
		null			  as [empnUDF1],
		null			  as [empnUDF2],
		368				  as [empnRecUserID],
		GETDATE()		  as [empdDtCreated],
		null			  as [empnModifyUserID],
		null			  as [empdDtModified],
		null			  as [empnLevelNo],
		null			  as [empnauthtodefcoun],			-- Auth. to defense cousel:  bit
		null			  as [empnauthtodefcounDt],		-- Auth. to defense cousel:  date
		null			  as [empnTotalDisability],		-- Temporary Total Disability (TTD)
		null			  as [empnAverageWeeklyWage],		-- Average weekly wage (AWW)
		null			  as [empnEmpUnion],				-- Unique Contact ID of Union
		null			  as [NotEmploymentReasonID],		-- 1=Minor; 2=Retired; 3=Unemployed; (MST?)
		null			  as [empdDateTo],
		null			  as [empsDepartment],
		null			  as [empdSent],					-- emp verification request sent
		null			  as [empdReceived],				-- emp verification request received
		null			  as [empnStatusId],				-- status  > sma_MST_EmploymentStatuses.ID
		null			  as [empnWorkSiteId],
		null			  as [saga],
		null			  as [source_id],
		'needles'		  as [source_db],
		'user_tab3_data'  as [source_ref]
	--select *
	from EmployerData e
	join sma_trn_Cases cas
		on cas.cassCaseNumber = CONVERT(VARCHAR, e.case_id)
	left join IndvOrgContacts_Indexed ioci
		on ioci.SAGA = e.employer_names_id
	where
		e.Employer_Name is not null;





--from [JohnSalazar_Needles]..user_party_data upd
--join JohnSalazar_Needles..party p
--	on upd.party_id = p.party_id
--where ISNULL(upd.Employer_Name,'')<>''

----	from [JohnSalazar_Needles].[dbo].[user_party_matter] M
----join NeedlesUserFields F
----	on F.field_num = M.ref_num
----join PartyRoles R
----	on R.[Needles Roles] = M.party_role
----where
----	R.[SA Party] = 'Defendant'
----	and F.column_name in (
----		select
----			COLUMN_NAME
----		from [JohnSalazar_Needles].INFORMATION_SCHEMA.COLUMNS
----		where TABLE_NAME = 'user_party_data'
----	)
----	and M.field_type <> 'label';

--join [JohnSalazar_Needles]..names n
--	on n.names_id = v.provider
----join [JohnSalazar_Needles]..provider p
----on p.name_id = n.names_id
--join sma_trn_Cases cas
--	on cas.cassCaseNumber = CONVERT(VARCHAR, v.case_id)
--join IndvOrgContacts_Indexed ioci
--	on ioci.SAGA = n.names_id
--where
--	v.code = 'lwg'
go


--/* ------------------------------------------------------------------------------
--Insert Lost Wages
--*/

--insert into [sma_TRN_LostWages]
--	(
--		[ltwnEmploymentID],
--		[ltwsType],
--		[ltwdFrmDt],
--		[ltwdToDt],
--		[ltwnAmount],
--		[ltwnAmtPaid],
--		[ltwnLoss],
--		[Comments],
--		[ltwdMDConfReqDt],
--		[ltwdMDConfDt],
--		[ltwdEmpVerfReqDt],
--		[ltwdEmpVerfRcvdDt],
--		[ltwnRecUserID],
--		[ltwdDtCreated],
--		[ltwnModifyUserID],
--		[ltwdDtModified],
--		[ltwnLevelNo]
--	)
--	select distinct
--		e.empnEmploymentID as [ltwnEmploymentID]		--sma_trn_employment ID
--		,
--		(
--			select
--				wgtnWagesTypeID
--			from [sma_MST_WagesTypes]
--			where wgtsDscrptn = 'Lost Wages'
--		)				   as [ltwsType]   			--[sma_MST_WagesTypes].wgtnWagesTypeID
--		-- ,case
--		-- 	when ud.Last_Date_Worked between '1/1/1900' and '6/6/2079'
--		-- 		then ud.Last_Date_Worked
--		-- 	else null 
--		-- 	end					as [ltwdFrmDt]
--		-- ,case
--		-- 	when ud.Returned_to_Work between '1/1/1900' and '6/6/2079'
--		-- 		then ud.Returned_to_Work 
--		-- 	when isdate(ud.returntowork) = 1 and ud.returntowork between '1/1/1900' and '6/6/2079'
--		-- 		then ud.returntowork 
--		-- 	else null
--		-- 	end					as [ltwdToDt]
--		,
--		case
--			when v.start_date between '1900-01-01' and '2079-06-06'
--				then v.start_date
--			else null
--		end				   as [ltwdFrmDt],
--		case
--			when v.stop_date between '1900-01-01' and '2079-06-06'
--				then v.stop_date
--			else null
--		end				   as [ltwdToDt],
--		null			   as [ltwnAmount],
--		null			   as [ltwnAmtPaid],
--		v.total_value	   as [ltwnLoss]
--		-- ,isnull('Return to work: ' + nullif(convert(Varchar,ud.returntowork),'') + char(13),'') +
--		-- ''						as [comments]
--		,
--		null			   as [comments],
--		null			   as [ltwdMDConfReqDt],
--		null			   as [ltwdMDConfDt],
--		null			   as [ltwdEmpVerfReqDt],
--		null			   as [ltwdEmpVerfRcvdDt],
--		368				   as [ltwnRecUserID],
--		GETDATE()		   as [ltwdDtCreated],
--		null			   as [ltwnModifyUserID],
--		null			   as [ltwdDtModified],
--		null			   as [ltwnLevelNo]
--	-- employment record id: case > plaintiff > employment (value has caseid)
--	from [JohnSalazar_Needles]..value_indexed v
--	join sma_trn_Cases cas
--		on cas.cassCaseNumber = CONVERT(VARCHAR, v.case_id)
--	join sma_trn_plaintiff p
--		on p.plnnCaseID = cas.casnCaseID
--			and p.plnbIsPrimary = 1
--	inner join sma_TRN_Employment e
--		on e.empnPlaintiffID = p.plnnPlaintiffID
--	where
--		v.code = 'LWG'

---- FROM [JohnSalazar_Needles]..user_tab4_data ud
---- JOIN EmployerTemp et on et.employer = ud.employer and et.employer_address = ud.Employer_Address
---- JOIN IndvOrgContacts_Indexed ioc on ioc.SAGA = et.empID and ioc.[Name] = et.employer
---- JOIN [sma_TRN_Employment] e on  e.empnPlaintiffID = p.plnnPlaintiffID and empnEmployerID = ioc.CID


-----------------------------------------
---- Update Special Damages
-----------------------------------------
--alter table [sma_TRN_SpDamages] disable trigger all
--go

--insert into [sma_TRN_SpDamages]
--	(
--		[spdsRefTable],
--		[spdnRecordID],
--		[spdnRecUserID],
--		[spddDtCreated],
--		[spdnLevelNo],
--		spdnBillAmt,
--		spddDateFrom,
--		spddDateTo
--	)
--	select distinct
--		'LostWages'		   as spdsRefTable,
--		lw.ltwnLostWagesID as spdnRecordID,
--		lw.ltwnRecUserID   as [spdnRecUserID],
--		lw.ltwdDtCreated   as spddDtCreated,
--		null			   as [spdnLevelNo],
--		lw.[ltwnLoss]	   as spdnBillAmt,
--		lw.ltwdFrmDt	   as spddDateFrom,
--		lw.ltwdToDt		   as spddDateTo
--	from sma_TRN_LostWages LW


--alter table [sma_TRN_SpDamages] enable trigger all
--go


--/* ------------------------------------------------------------------------------
--[sma_TRN_LostWages] Schema
--*/

---- saga
--if not exists (
--		select
--			*
--		from sys.columns
--		where Name = N'saga'
--			and object_id = OBJECT_ID(N'sma_TRN_LostWages')
--	)
--begin
--	alter table [sma_TRN_LostWages] add [saga] INT null;
--end

--go

---- source_id
--if not exists (
--		select
--			*
--		from sys.columns
--		where Name = N'source_id'
--			and object_id = OBJECT_ID(N'sma_TRN_LostWages')
--	)
--begin
--	alter table [sma_TRN_LostWages] add [source_id] VARCHAR(MAX) null;
--end

--go

---- source_db
--if not exists (
--		select
--			*
--		from sys.columns
--		where Name = N'source_db'
--			and object_id = OBJECT_ID(N'sma_TRN_LostWages')
--	)
--begin
--	alter table [sma_TRN_LostWages] add [source_db] VARCHAR(MAX) null;
--end

--go

---- source_ref
--if not exists (
--		select
--			*
--		from sys.columns
--		where Name = N'source_ref'
--			and object_id = OBJECT_ID(N'sma_TRN_LostWages')
--	)
--begin
--	alter table [sma_TRN_LostWages] add [source_ref] VARCHAR(MAX) null;
--end

--go



--/* ------------------------------------------------------------------------------
--Create 'Lost Wages' wage type
--*/

--insert into [dbo].[sma_MST_WagesTypes]
--	(
--		[wgtsCode],
--		[wgtsDscrptn],
--		[wgtnRecUserID],
--		[wgtdDtCreated],
--		[wgtnModifyUserID],
--		[wgtdDtModified],
--		[wgtnLevelNo]
--	)
--	select
--		'LWG'		 as wgtsCode,
--		'Lost Wages' as wgtsDscrptn,
--		368			 as wgtnRecUserID,
--		GETDATE()	 as wgtdDtCreated,
--		null		 as wgtnModifyUserID,
--		null		 as wgtdDtModified,
--		null		 as wgtnLevelNo
--	where
--		not exists (
--			select
--				1
--			from [dbo].[sma_MST_WagesTypes]
--			where wgtsCode = 'LWG'
--		);


--/* ------------------------------------------------------------------------------
--Insert Lost Wages
--*/

--insert into [sma_TRN_LostWages]
--	(
--		[ltwnEmploymentID],
--		[ltwsType],
--		[ltwdFrmDt],
--		[ltwdToDt],
--		[ltwnAmount],
--		[ltwnAmtPaid],
--		[ltwnLoss],
--		[Comments],
--		[ltwdMDConfReqDt],
--		[ltwdMDConfDt],
--		[ltwdEmpVerfReqDt],
--		[ltwdEmpVerfRcvdDt],
--		[ltwnRecUserID],
--		[ltwdDtCreated],
--		[ltwnModifyUserID],
--		[ltwdDtModified],
--		[ltwnLevelNo],
--		[saga],
--		[source_id],
--		[source_db],
--		[source_ref]
--	)
--	select distinct
--		e.empnEmploymentID as [ltwnEmploymentID]		--sma_trn_employment ID
--		,
--		(
--			select
--				wgtnWagesTypeID
--			from [sma_MST_WagesTypes]
--			where wgtsDscrptn = 'Lost Wages'
--		)				   as [ltwsType]   			--[sma_MST_WagesTypes].wgtnWagesTypeID
--		-- ,case
--		-- 	when ud.Last_Date_Worked between '1/1/1900' and '6/6/2079'
--		-- 		then ud.Last_Date_Worked
--		-- 	else null 
--		-- 	end					as [ltwdFrmDt]
--		-- ,case
--		-- 	when ud.Returned_to_Work between '1/1/1900' and '6/6/2079'
--		-- 		then ud.Returned_to_Work 
--		-- 	when isdate(ud.returntowork) = 1 and ud.returntowork between '1/1/1900' and '6/6/2079'
--		-- 		then ud.returntowork 
--		-- 	else null
--		-- 	end					as [ltwdToDt]
--		,
--		case
--			when v.start_date between '1900-01-01' and '2079-06-06'
--				then v.start_date
--			else null
--		end				   as [ltwdFrmDt],
--		case
--			when v.stop_date between '1900-01-01' and '2079-06-06'
--				then v.stop_date
--			else null
--		end				   as [ltwdToDt],
--		null			   as [ltwnAmount],
--		null			   as [ltwnAmtPaid],
--		v.total_value	   as [ltwnLoss],
--		ISNULL('Memo: ' + NULLIF(CONVERT(VARCHAR, v.memo), '') + CHAR(13), '') +
--		''				   as [comments],
--		null			   as [ltwdMDConfReqDt],
--		null			   as [ltwdMDConfDt],
--		null			   as [ltwdEmpVerfReqDt],
--		null			   as [ltwdEmpVerfRcvdDt],
--		368				   as [ltwnRecUserID],
--		GETDATE()		   as [ltwdDtCreated],
--		null			   as [ltwnModifyUserID],
--		null			   as [ltwdDtModified],
--		null			   as [ltwnLevelNo],
--		v.value_id		   as [saga],
--		null			   as [source_id],
--		'needles'		   as [source_db],
--		'value_indexed'	   as [source_ref]
--	-- employment record id: case > plaintiff > employment (value has caseid)
--	from [JohnSalazar_Needles]..value_indexed v
--	join sma_trn_Cases cas
--		on cas.cassCaseNumber = CONVERT(VARCHAR, v.case_id)
--	join sma_trn_plaintiff p
--		on p.plnnCaseID = cas.casnCaseID
--			and p.plnbIsPrimary = 1
--	inner join sma_TRN_Employment e
--		on e.empnPlaintiffID = p.plnnPlaintiffID
--	where
--		v.code = 'LWG'

---- FROM [JohnSalazar_Needles]..user_tab4_data ud
---- JOIN EmployerTemp et on et.employer = ud.employer and et.employer_address = ud.Employer_Address
---- JOIN IndvOrgContacts_Indexed ioc on ioc.SAGA = et.empID and ioc.[Name] = et.employer
---- JOIN [sma_TRN_Employment] e on  e.empnPlaintiffID = p.plnnPlaintiffID and empnEmployerID = ioc.CID


-----------------------------------------
---- Update Special Damages
-----------------------------------------
--alter table [sma_TRN_SpDamages] disable trigger all
--go

--insert into [sma_TRN_SpDamages]
--	(
--		[spdsRefTable],
--		[spdnRecordID],
--		[spdnRecUserID],
--		[spddDtCreated],
--		[spdnLevelNo],
--		spdnBillAmt,
--		spddDateFrom,
--		spddDateTo
--	)
--	select distinct
--		'LostWages'		   as spdsRefTable,
--		lw.ltwnLostWagesID as spdnRecordID,
--		lw.ltwnRecUserID   as [spdnRecUserID],
--		lw.ltwdDtCreated   as spddDtCreated,
--		null			   as [spdnLevelNo],
--		lw.[ltwnLoss]	   as spdnBillAmt,
--		lw.ltwdFrmDt	   as spddDateFrom,
--		lw.ltwdToDt		   as spddDateTo
--	from sma_TRN_LostWages LW


--alter table [sma_TRN_SpDamages] enable trigger all
--go
