use [JohnSalazar_SA]
go

----------------------------------------------------------------------------
-- Damage Types
----------------------------------------------------------------------------
--delete From [sma_TRN_SpDamages] where spdsRefTable = 'CustomDamage'

-- Create Special Damage Type "Other" if it doesn't exist
if (
		select
			COUNT(*)
		from sma_MST_SpecialDamageType
		where SpDamageTypeDescription = 'Other'
	) = 0
begin
	insert into sma_MST_SpecialDamageType
		(
			SpDamageTypeDescription,
			IsEditableType,
			SpDamageTypeCreatedUserID,
			SpDamageTypeDtCreated
		)
		select
			'Other',
			1,
			368,
			GETDATE()
end

-- Insert Special Damage Sub Types from value_code under Type "Other"
insert into sma_MST_SpecialDamageSubType
	(
		spdamagetypeid,
		SpDamageSubTypeDescription,
		SpDamageSubTypeDtCreated,
		SpDamageSubTypeCreatedUserID
	)
	select
		(
			select
				spdamagetypeid
			from sma_MST_SpecialDamageType
			where SpDamageTypeDescription = 'Other'
		),
		vc.[description],
		GETDATE(),
		368
	from [JohnSalazar_Needles]..value_code vc
	where
		code in (
			select
				code
			from conversion.value_specialDamage
		)

----------------------------------------------------------------------------
--[sma_TRN_SpDamages]
----------------------------------------------------------------------------
alter table [sma_TRN_SpDamages] disable trigger all
go

insert into [sma_TRN_SpDamages]
	(
		spdsRefTable,
		spdnRecordID,
		spddCaseID,
		spddPlaintiff,
		spddDamageType,
		spddDamageSubType,
		spdnRecUserID,
		spddDtCreated,
		spdnLevelNo,
		spdnBillAmt,
		spddDateFrom,
		spddDateTo,
		spdsComments,
		saga,
		source_id,
		source_db,
		source_ref
	)
	select distinct
		'CustomDamage'  as spdsRefTable,
		null			as spdnRecordID,
		SDH.casnCaseID  as spddCaseID,
		SDH.PlaintiffID as spddPlaintiff,
		(
			select top 1
				spdamagetypeid
			from sma_MST_SpecialDamageType
			where SpDamageTypeDescription = 'Other'
		)				as spddDamageType,
		(
			select top 1
				SpDamageSubTypeID
			from sma_MST_SpecialDamageSubType
			where SpDamageSubTypeDescription = VC.[description]
				and spdamagetypeid = (
					select
						spdamagetypeid
					from sma_MST_SpecialDamageType
					where SpDamageTypeDescription = 'Other'
				)
		)				as spddDamageSubType,
		368				as spdnRecUserID,
		GETDATE()		as spddDtCreated,
		0				as spdnLevelNo,
		V.total_value   as spdnBillAmt,
		case
			when V.[start_date] between '1900-01-01' and '2079-06-01'
				then V.[start_date]
			else null
		end				as spddDateFrom,
		case
			when V.stop_date between '1900-01-01' and '2079-06-01'
				then V.stop_date
			else null
		end				as spddDateTo,
		'Provider: '
		+ SDH.[ProviderName]
		+ CHAR(13)
		+ V.memo		as spdsComments,
		V.value_id		as [saga],
		null			as [source_id],
		null			as [source_db],
		'value'			as [source_ref]
	from [JohnSalazar_Needles].[dbo].[value_Indexed] V
	join [JohnSalazar_Needles].[dbo].[value_Code] VC
		on V.code = VC.code
	join [value_tab_spDamages_Helper] SDH
		on V.value_id = SDH.value_id
	where
		V.code in (
			select
				code
			from conversion.value_specialDamage
		)
go

alter table [sma_TRN_SpDamages] enable trigger all
go

