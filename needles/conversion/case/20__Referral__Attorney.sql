use JohnSalazar_SA

-------------------------------------------------------------------------------
-- [sma_TRN_LawyerReferral] Schema
-------------------------------------------------------------------------------
-- saga
if not exists (
	 select
		 *
	 from sys.columns
	 where Name = N'saga'
		 and object_id = OBJECT_ID(N'sma_TRN_LawyerReferral')
	)
begin
	alter table [sma_TRN_LawyerReferral] add [saga] INT null;
end

-- source_id
if not exists (
	 select
		 *
	 from sys.columns
	 where Name = N'source_id'
		 and object_id = OBJECT_ID(N'sma_TRN_LawyerReferral')
	)
begin
	alter table [sma_TRN_LawyerReferral] add [source_id] VARCHAR(MAX) null;
end

go

-- source_db
if not exists (
	 select
		 *
	 from sys.columns
	 where Name = N'source_db'
		 and object_id = OBJECT_ID(N'sma_TRN_LawyerReferral')
	)
begin
	alter table [sma_TRN_LawyerReferral] add [source_db] VARCHAR(MAX) null;
end

go

-- source_ref
if not exists (
	 select
		 *
	 from sys.columns
	 where Name = N'source_ref'
		 and object_id = OBJECT_ID(N'sma_TRN_LawyerReferral')
	)
begin
	alter table [sma_TRN_LawyerReferral] add [source_ref] VARCHAR(MAX) null;
end

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
	) select
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
		on ioci.SAGA = v.provider
	where
		v.code = 'REF FEE'