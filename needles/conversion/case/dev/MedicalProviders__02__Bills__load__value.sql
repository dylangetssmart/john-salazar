use [SA]
go

insert into [sma_TRN_SpDamages]
	(
		[spdsRefTable],
		[spdnRecordID],
		[spdnBillAmt],
		[spddNegotiatedBillAmt],
		[spddDateFrom],
		[spddDateTo],
		[spddDamageSubType],
		[spdnVisitId],
		[spdsComments],
		[spdnRecUserID],
		[spddDtCreated],
		[spdnModifyUserID],
		[spddDtModified],
		[spdnBalance],
		[spdbLienConfirmed],
		[spdbDocAttached],
		[saga_bill_id]
	)
	select
		'Hospitals'														 as spdsRefTable,
		H.hosnHospitalID												 as spdnRecordID,
		V.total_value													 as spdnBillAmt,
		(V.total_value - V.reduction)									 as spddNegotiatedBillAmt,
		case
			when V.[start_date] between '1900-01-01' and '2079-06-06'
				then CONVERT(DATE, V.[start_date])
			else null
		end																 as spddDateFrom,
		case
			when V.[stop_date] between '1900-01-01' and '2079-06-06'
				then CONVERT(DATE, V.[stop_date])
			else null
		end																 as spddDateTo,
		null															 as spddDamageSubType,
		null															 as spdnVisitId,
		ISNULL('value tab medical bill. memo - ' + NULLIF(memo, ''), '') as spdsComments,
		368																 as spdnRecordID,
		GETDATE()														 as spddDtCreated,
		null															 as spdnModifyUserID,
		null															 as spddDtModified,
		V.due															 as spdnBalance,
		0																 as spdbLienConfirmed,
		0																 as spdbDocAttached,
		V.value_id														 as saga_bill_id  -- one bill one value
	from [Needles].[dbo].[value_Indexed] V
	join value_tab_MedicalProvider_Helper MAP
		on MAP.case_id = V.case_id
			and MAP.value_id = V.value_id
	join [sma_TRN_Hospitals] H
		on H.hosnContactID = MAP.ProviderCID
			and H.hosnContactCtg = MAP.ProviderCTG
			and H.hosnCaseID = MAP.casnCaseID
			and H.hosnPlaintiffID = MAP.PlaintiffID
go

---(3)--- (Amount Paid section)  --Type=Client--
insert into [sma_TRN_SpecialDamageAmountPaid]
	(
		[AmountPaidDamageReferenceID],
		[AmountPaidCollateralType],
		[AmountPaidPaidByID],
		[AmountPaidTotal],
		[AmountPaidClaimSubmittedDt],
		[AmountPaidDate],
		[AmountPaidRecUserID],
		[AmountPaidDtCreated],
		[AmountPaidModifyUserID],
		[AmountPaidDtModified],
		[AmountPaidLevelNo],
		[AmountPaidAdjustment],
		[AmountPaidComments]
	)
	select
		SPD.spdnSpDamageID as [AmountPaidDamageReferenceID],
		(
			select
				cltnCollateralTypeID
			from [dbo].[sma_MST_CollateralType]
			where cltsDscrptn = 'Client'
		)				   as [AmountPaidCollateralType],
		null			   as [AmountPaidPaidByID],
		VP.payment_amount  as [AmountPaidTotal],
		null			   as [AmountPaidClaimSubmittedDt],
		case
			when VP.date_paid between '1900-01-01' and '2079-06-06'
				then VP.date_paid
			else null
		end				   as [AmountPaidDate],
		368				   as [AmountPaidRecUserID],
		GETDATE()		   as [AmountPaidDtCreated],
		null			   as [AmountPaidModifyUserID],
		null			   as [AmountPaidDtModified],
		null			   as [AmountPaidLevelNo],
		null			   as [AmountPaidAdjustment],
		ISNULL('paid by:' + NULLIF(VP.paid_by, '') + CHAR(13), '')
		+ ISNULL('paid to:' + NULLIF(VP.paid_to, '') + CHAR(13), '')
		+ ''			   as [AmountPaidComments]
	from [Needles].[dbo].[value_Indexed] V
	join value_tab_MedicalProvider_Helper MAP
		on MAP.case_id = V.case_id
			and MAP.value_id = V.value_id
	join [sma_TRN_SpDamages] SPD
		on SPD.saga_bill_id = V.value_id
	join [Needles].[dbo].[value_payment] VP
		on VP.value_id = V.value_id -- multiple payment per value_id
go


---(Appendix)--- Update hospital TotalBill from Bill section
update [sma_TRN_Hospitals]
set hosnTotalBill = (
	select
		SUM(spdnBillAmt)
	from sma_TRN_SpDamages
	where sma_TRN_SpDamages.spdsRefTable = 'Hospitals'
		and sma_TRN_SpDamages.spdnRecordID = hosnHospitalID
)
go

alter table [sma_TRN_SpDamages] enable trigger all
go

alter table [sma_TRN_SpecialDamageAmountPaid] enable trigger all