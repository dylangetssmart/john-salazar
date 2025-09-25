use JohnSalazar_SA


exec AddBreadcrumbsToTable @tableName = N'sma_TRN_LawyerReferral'

alter table sma_TRN_LawyerReferral disable trigger all
go


/* ---------------------------------------------------------------------------------------------------------------
ATTORNEY REFERRALS
*/

insert into sma_TRN_LawyerReferral
	(
		lwrnCaseID,
		lwrnRefLawFrmContactID,
		lwrnRefLawFrmAddressId,
		lwrnAttContactID,
		lwrnAttAddressID,
		lwrnPlaintiffID,
		lwrsComments,
		lwrnUserID,
		lwrdDtCreated,
		lwrnFeeAmt,
		saga,
		source_id,
		source_db,
		source_ref
	)
	select
		cas.casnCaseID  as lwrnCaseID,
		case
			when ioci.CTG = 2 then ioci.CID
			else null
		end				as lwrnRefLawFrmContactID,
		case
			when ioci.CTG = 2 then ioci.AID
			else null
		end				as lwrnRefLawFrmAddressId,
		case
			when ioci.CTG = 1 then ioci.CID
			else null
		end				as lwrnAttContactID,
		case
			when ioci.CTG = 1 then ioci.AID
			else null
		end				as lwrnAttAddressID,
		-1				as lwrnPlaintiffID,
		''				as lwrscomments,
		368				as lwrnuserid,
		GETDATE()		as lwrddtcreated,
		v.total_value   as lwrnFeeAmt,
		v.value_id		as saga,
		null			as source_id,
		'needles'		as source_db,
		'value_indexed' as source_ref
	--select *
	from JohnSalazar_Needles..value_Indexed v
	join [sma_TRN_Cases] CAS
		on CAS.cassCaseNumber = CONVERT(VARCHAR, v.case_id)
	join IndvOrgContacts_Indexed ioci
		on ioci.saga = v.provider
	where
		v.code = 'REF FEE'
go

alter table sma_TRN_LawyerReferral enable trigger all
go