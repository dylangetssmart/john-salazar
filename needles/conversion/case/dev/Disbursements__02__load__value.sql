use [JohnSalazar_SA]
go


-- Use this to create custom CheckRequestStatuses
-- INSERT INTO [sma_MST_CheckRequestStatus] ([description])
-- select 'Unrecouped'
-- EXCEPT SELECT [description] FROM [sma_MST_CheckRequestStatus]


/* --------------------------------------------------------------------------------------------------------------
Create disbursement types for applicable value codes
[sma_MST_DisbursmentType]
*/

insert into [sma_MST_DisbursmentType]
	(
	disnTypeCode,
	dissTypeName
	)
	(
	select distinct
		'CONVERSION',
		vc.[description]
	from [[JohnSalazar_Needles]].[dbo].[value] v
	join [[JohnSalazar_Needles]].[dbo].[value_code] vc
		on vc.code = v.code
	where ISNULL(v.code, '') in (
			select
				code
			from conversion.value_disbursements
		))
	except
	select
		'CONVERSION',
		dissTypeName
	from [sma_MST_DisbursmentType]


/* --------------------------------------------------------------------------------------------------------------
Create Disbursements
[sma_TRN_Disbursement]
*/

alter table [sma_TRN_Disbursement] disable trigger all
go

insert into [sma_TRN_Disbursement]
	(
	disnCaseID,
	disdCheckDt,
	disnPayeeContactCtgID,
	disnPayeeContactID,
	disnAmount,
	disnPlaintiffID,
	dissDisbursementType,
	UniquePayeeID,
	dissDescription,
	dissComments,
	disnCheckRequestStatus,
	disdBillDate,
	disdDueDate,
	disnRecUserID,
	disdDtCreated,
	disnRecoverable,
	saga,
	source_id,
	source_db,
	source_ref
	)
	select
		map.casnCaseID  as disncaseid,
		null			as disdcheckdt,
		map.ProviderCTG as disnpayeecontactctgid,
		map.ProviderCID as disnpayeecontactid,
		v.total_value   as disnamount,
		map.PlaintiffID as disnplaintiffid,
		(
			select
				disnTypeID
			from [sma_MST_DisbursmentType]
			where dissTypeName = (
					select
						[description]
					from [[JohnSalazar_Needles]].[dbo].[value_code]
					where [code] = v.code
				)
		)				as dissdisbursementtype,
		map.ProviderUID as uniquepayeeid,
		v.[memo]		as dissdescription,
		--,v.settlement_memo + 
		--ISNULL('Account Number: ' + NULLIF(CAST(Account_Number AS VARCHAR(MAX)), '') + CHAR(13), '') +
		--ISNULL('Cancel: ' + NULLIF(CAST(Cancel AS VARCHAR(MAX)), '') + CHAR(13), '') +    
		--ISNULL('CM Reviewed: ' + NULLIF(CAST(CM_Reviewed AS VARCHAR(MAX)), '') + CHAR(13), '') +
		--ISNULL('Date Paid: ' + NULLIF(CAST(Date_Paid AS VARCHAR(MAX)), '') + CHAR(13), '') +
		--ISNULL('For Dates From: ' + NULLIF(CAST(For_Dates_From AS VARCHAR(MAX)), '') + CHAR(13), '') +
		--ISNULL('OI Checked: ' + NULLIF(CAST(OI_Checked AS VARCHAR(MAX)), '') + CHAR(13), '')
		--                                        as dissComments
		null			as disscomments,
		--case
		--	when v.code in ('MSC', 'DTF')
		--		then (
		--				select
		--					Id
		--				from [sma_MST_CheckRequestStatus]
		--				where [Description] = 'Paid'
		--			)
		--	-- when v.code in ('UCC')
		--	--     then (
		--	--             select Id
		--	--             FROM [sma_MST_CheckRequestStatus]
		--	--             where [Description]='Check Pending'
		--	--         )
		--	when ISNULL(Check_Requested, '') <> ''
		--		then (
		--				select
		--					Id
		--				from [sma_MST_CheckRequestStatus]
		--				where [Description] = 'Check Pending'
		--			)
		--	else null
		--end				  as disncheckrequeststatus,
		(
			select
				Id
			from [sma_MST_CheckRequestStatus]
			where [Description] = 'Paid'
		)				as disncheckrequeststatus,
		case
			when v.start_date between '1900-01-01' and '2079-06-06'
				then v.start_date
			else null
		end				as disdbilldate,
		case
			when v.stop_date between '1900-01-01' and '2079-06-06'
				then v.stop_date
			else null
		end				as disdduedate,
		(
			select
				usrnUserID
			from sma_MST_Users
			where source_id = v.staff_created
		)				as disnrecuserid,
		case
			when date_created between '1900-01-01' and '2079-06-06'
				then date_created
			else null
		end				as disddtcreated,
		case
			when v.code = 'DTF'
				then 0
			else 1
		end				as disnrecoverable,
		v.value_id		as saga,
		null			as source_id,
		null			as source_db,
		null			as source_ref
	from [[JohnSalazar_Needles]].[dbo].[value_Indexed] v
	join value_tab_Disbursement_Helper map
		on map.case_id = v.case_id
			and map.value_id = v.value_id
--join [JohnSalazar_Needles]..user_tab2_data u
--	on u.case_id = v.case_id
go

---
alter table [sma_TRN_Disbursement] enable trigger all
go
---

