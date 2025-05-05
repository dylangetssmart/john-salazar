use KurtYoung_SA
go

------------------------------------------------
-- [sma_MST_SettlementType]
------------------------------------------------
insert into [sma_MST_SettlementType]
	(
		SettlTypeName
	)
	select
		'Settlement Recovery'
	union
	select
		'MedPay'
	union
	select
		'Paid To Client'
	except
	select
		SettlTypeName
	from [sma_MST_SettlementType]
go

------------------------------------------------
-- [sma_TRN_Settlements]
------------------------------------------------
alter table [sma_TRN_Settlements] disable trigger all
go

insert into [sma_TRN_Settlements]
	(
		stlnCaseID,
		stlnSetAmt,
		stlnNet,
		stlnNetToClientAmt,
		stlnPlaintiffID,
		stlnStaffID,
		stlnLessDisbursement,
		stlnGrossAttorneyFee,
		stlnForwarder,  --referrer
		stlnOther,
		InterestOnDisbursement,
		stlsComments,
		stlTypeID,
		stldSettlementDate,
		saga,
		stlbTakeMedPay		-- "Take Fee"
	)
	select
		map.casnCaseID  as stlncaseid,

		case
			when v.code in ('MPP', 'SET')
				then v.total_value
		end				as stlnsetamt,
		null			as stlnnet,
		null			as stlnnettoclientamt,
		map.PlaintiffID as stlnplaintiffid,
		null			as stlnstaffid,
		null			as stlnlessdisbursement,
		case
			when v.code in ('VER')
				then v.total_value
		end				as stlngrossattorneyfee,
		null			as stlnforwarder,		-- Referrer
		null			as stlnother,
		null			as interestondisbursement,
		ISNULL('memo:' + NULLIF(v.memo, '') + CHAR(13), '')
		+ ISNULL('code:' + NULLIF(v.code, '') + CHAR(13), '')
		+ ''			as [stlscomments],
		case
			when v.code in ('VER')
				then (
						select
							ID
						from [sma_MST_SettlementType]
						where SettlTypeName = 'Verdict'
					--case
					--		when v.[code] in ('SET')
					--			then 'Settlement Recovery'
					--		when v.[code] in ('MP')
					--			then 'MedPay'
					--		when v.[code] in ('PTC')
					--			then 'Paid To Client'
					--		when v.[code] in ('VER')		-- VER > Fees Awarded
					--			then 'Verdict'
					--	end
					)
		end				as stltypeid,
		case
			when v.[start_date] between '1900-01-01' and '2079-06-06'
				then v.[start_date]
			else null
		end				as stldsettlementdate,
		v.value_id		as saga,
		case
			when v.code = 'MPP'
				then 1
			else 0
		end				as stlbtakemedpay		-- ds 2024-11-07 "Take Fee"
	from KurtYoung_Needles.[dbo].[value_Indexed] v
	join value_tab_Settlement_Helper map
		on map.case_id = v.case_id
			and map.value_id = v.value_id
	where
		v.code in (
			select
				code
			from conversion.value_settlements
		)
go

alter table [sma_TRN_Settlements] enable trigger all
go