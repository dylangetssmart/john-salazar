use [SA]
go

/*
Insert hospitals from [value_tab_MedicalProvider_Helper]
*/

alter table [sma_TRN_Hospitals] disable trigger all
go

insert into [sma_TRN_Hospitals]
	(
		[hosnCaseID],
		[hosnContactID],
		[hosnContactCtg],
		[hosnAddressID],
		[hossMedProType],
		[hosdStartDt],
		[hosdEndDt],
		[hosnPlaintiffID],
		[hosnComments],
		[hosnHospitalChart],
		[hosnRecUserID],
		[hosdDtCreated],
		[hosnModifyUserID],
		[hosdDtModified],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		A.casnCaseID  as [hosnCaseID],
		A.ProviderCID as [hosnContactID],
		A.ProviderCTG as [hosnContactCtg],
		A.ProviderAID as [hosnAddressID],
		'M'			  as [hossMedProType],
		null		  as [hosdStartDt],
		null		  as [hosdEndDt],
		A.PlaintiffID as hosnPlaintiffID,
		null		  as [hosnComments],
		null		  as [hosnHospitalChart],
		368			  as [hosnRecUserID],
		GETDATE()	  as [hosdDtCreated],
		null		  as [hosnModifyUserID],
		null		  as [hosdDtModified],
		null		  as [saga],
		null		  as [source_id],
		null		  as [source_db],
		'value'		  as [source_ref]
	from (
		select -- (Note: make sure no duplicate provider per case )
			ROW_NUMBER() over (partition by MAP.ProviderCID, MAP.ProviderCTG, MAP.casnCaseID, MAP.PlaintiffID order by V.value_id) as RowNumber,
			MAP.PlaintiffID,
			MAP.casnCaseID,
			MAP.ProviderCID,
			MAP.ProviderCTG,
			MAP.ProviderAID
		from [Needles].[dbo].[value_Indexed] V
		inner join value_tab_MedicalProvider_Helper MAP
			on MAP.case_id = V.case_id
			and MAP.value_id = V.value_id
	) A
	where
		A.RowNumber = 1 ---Note: No merging. got to be the first script to populate Medical Provider
go

alter table [sma_TRN_Hospitals] enable trigger all
go
