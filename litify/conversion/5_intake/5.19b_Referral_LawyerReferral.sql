use ShinerSA
go

/* ---------------------------------------------------------------------------------------------------------------
ATTORNEY REFERRALS
*/

-- [litify_pm__Matter__c].[litify_pm__Source__c]
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
		lwrdDtCreated
	)
	select
		cas.casnCaseID as lwrnCaseID,
		case
			when ioc.CTG = 2
				then ioc.CID
			else null
		end			   as lwrnRefLawFrmContactID,
		case
			when ioc.CTG = 2
				then ioc.AID
			else null
		end			   as lwrnRefLawFrmAddressId,
		case
			when ioc.CTG = 1
				then ioc.CID
			else null
		end			   as lwrnAttContactID,
		case
			when ioc.CTG = 1
				then ioc.AID
			else null
		end			   as lwrnAttAddressID,
		-1			   as lwrnPlaintiffID,
		''			   as lwrscomments,
		368			   as lwrnuserid,
		GETDATE()	   as lwrddtcreated
	--select m.id,s.name, s.litify_tso_Source_Type_Name__c, s.*
	from ShinerLitify..litify_pm__Intake__c i
	join sma_trn_Cases cas
		on cas.saga_char = i.Id
	join [IndvOrgContacts_Indexed] ioc
		on ioc.saga_char = i.Referred_By__c
	where
		ISNULL(i.Referred_By__c, '') <> ''

	--from ShinerLitify..litify_pm__Matter__c m
	--join sma_TRN_Cases cas
	--	on cas.saga_char = m.Id
	--join ShinerLitify..[litify_pm__Source__c] s
	--	on m.litify_pm__Source__c = s.Id
	--join IndvOrgContacts_Indexed ioc
	--	on ioc.saga_char = s.Id
	--where
	--	s.litify_tso_Source_Type_Name__c in ('Attorney Referral')