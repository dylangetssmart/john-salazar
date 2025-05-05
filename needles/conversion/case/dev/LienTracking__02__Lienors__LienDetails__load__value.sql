use [JohnSalazar_SA]
go

/* ------------------------------------------------------------------------------
Create Lien Types
*/
insert into sma_MST_LienType
	(
		[lntsCode],
		[lntsDscrptn]
	)
	(
	select distinct
		'CONVERSION',
		VC.[description]
	from [Skolrood_Needles].[dbo].[value] V
	inner join [Skolrood_Needles].[dbo].[value_code] VC
		on VC.code = V.code
	where ISNULL(V.code, '') in (
			select
				code
			from conversion.value_lienTracking
		))
	except
	select
		[lntsCode],
		[lntsDscrptn]
	from [sma_MST_LienType]
go

/* ------------------------------------------------------------------------------
Lienors
*/

alter table [sma_TRN_Lienors] disable trigger all
go

insert into [sma_TRN_Lienors]
	(
		[lnrnCaseID],
		[lnrnLienorTypeID],
		[lnrnLienorContactCtgID],
		[lnrnLienorContactID],
		[lnrnLienorAddressID],
		[lnrnLienorRelaContactID],
		[lnrnPlaintiffID],
		[lnrnCnfrmdLienAmount],
		[lnrnNegLienAmount],
		[lnrsComments],
		[lnrnRecUserID],
		[lnrdDtCreated],
		[lnrnFinal],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		MAP.casnCaseID			 as [lnrnCaseID],
		(
			select top 1
				lntnLienTypeID
			from [sma_MST_LienType]
			where lntsDscrptn = (
					select
						[description]
					from [Skolrood_Needles].[dbo].[value_code]
					where [code] = V.code
				)
		)						 as [lnrnLienorTypeID],
		MAP.ProviderCTG			 as [lnrnLienorContactCtgID],
		MAP.ProviderCID			 as [lnrnLienorContactID],
		MAP.ProviderAID			 as [lnrnLienorAddressID],
		0						 as [lnrnLienorRelaContactID],
		MAP.PlaintiffID			 as [lnrnPlaintiffID],
		ISNULL(V.total_value, 0) as [lnrnCnfrmdLienAmount],
		ISNULL(V.due, 0)		 as [lnrnNegLienAmount],
		ISNULL('Memo : ' + ISNULL(V.memo, '') + CHAR(13), '') +
		ISNULL('From : ' + CONVERT(VARCHAR(10), V.start_date) + CHAR(13), '') +
		ISNULL('To : ' + CONVERT(VARCHAR(10), V.stop_date) + CHAR(13), '') +
		ISNULL('Value Total : ' + CONVERT(VARCHAR, V.total_value) + CHAR(13), '') +
		ISNULL('Reduction : ' + CONVERT(VARCHAR, V.reduction) + CHAR(13), '') +
		ISNULL('Paid : ' + MAP.Paid, '')
		as [lnrsComments],
		368						 as [lnrnRecUserID],
		GETDATE()				 as [lnrdDtCreated],
		0						 as [lnrnFinal],
		V.value_id				 as [saga],
		null					 as [source_id],
		null					 as [source_db],
		null					 as [source_ref]
	from [Skolrood_Needles].[dbo].[value_Indexed] V
	inner join [value_tab_Lien_Helper] MAP
		on MAP.case_id = V.case_id
			and MAP.value_id = V.value_id

alter table [sma_TRN_Lienors] enable trigger all
go

/* ------------------------------------------------------------------------------
Lien Details
*/

alter table [sma_TRN_LienDetails] disable trigger all
go

insert into [sma_TRN_LienDetails]
	(
		lndnLienorID,
		lndnLienTypeID,
		lndnCnfrmdLienAmount,
		lndsRefTable,
		lndnRecUserID,
		lnddDtCreated
	)
	select
		lnrnLienorID		 as lndnLienorID, --> same as lndnRecordID
		lnrnLienorTypeID	 as lndnLienTypeID,
		lnrnCnfrmdLienAmount as lndnCnfrmdLienAmount,
		'sma_TRN_Lienors'	 as lndsRefTable,
		368					 as lndnRecUserID,
		GETDATE()			 as lnddDtCreated
	from [sma_TRN_Lienors]

alter table [sma_TRN_LienDetails] enable trigger all
go
