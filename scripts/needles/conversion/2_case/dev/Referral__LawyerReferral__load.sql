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
	from ShinerLitify..litify_pm__Matter__c m
	join sma_TRN_Cases cas
		on cas.saga_char = m.Id
	join ShinerLitify..[litify_pm__Source__c] s
		on m.litify_pm__Source__c = s.Id
	join IndvOrgContacts_Indexed ioc
		on ioc.saga_char = s.Id
	where
		s.litify_tso_Source_Type_Name__c in ('Attorney Referral')

-- [litify_pm__Matter__c].[Referred_By__c]
-- where [account].[type] in ('Referring attorney','Attorney','Law Firm')
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
	from ShinerLitify..litify_pm__Matter__c m
	join sma_TRN_Cases cas
		on cas.saga_char = m.Id
	join ShinerLitify..Account a
		on m.Referred_By__c = a.Id
	join IndvOrgContacts_Indexed ioc
		on ioc.saga_char = m.Referred_By__c
	where
		ISNULL(m.Referred_By__c, '') <> ''
		and
		a.Type in ('Referring attorney', 'Attorney', 'Law Firm')
go

-- [litify_pm__Matter__c].[Referred_By_2__c]
-- where [account].[type] in ('Referring attorney','Attorney','Law Firm')
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
	from ShinerLitify..litify_pm__Matter__c m
	join sma_TRN_Cases cas
		on cas.saga_char = m.Id
	join ShinerLitify..Account a
		on m.Referred_By_2__c = a.Id
	join IndvOrgContacts_Indexed ioc
		on ioc.saga_char = m.Referred_By_2__c
	where
		ISNULL(m.Referred_By_2__c, '') <> ''
		and
		a.Type in ('Referring attorney', 'Attorney', 'Law Firm')

-- [litify_pm__Matter__c].[Referred_By__c]
-- where [account].[type] not in ('Referring attorney','Attorney','Law Firm')
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
	from ShinerLitify..litify_pm__Matter__c m
	join sma_TRN_Cases cas
		on cas.saga_char = m.Id
	--JOIN ShinerLitify..[litify_pm__Source__c] s
	--	ON m.litify_pm__Source__c = s.Id
	join ShinerLitify..Account a
		on m.Referred_By__c = a.Id
	join IndvOrgContacts_Indexed ioc
		on ioc.saga_char = m.Referred_By__c
	where
		ISNULL(m.Referred_By__c, '') <> ''
		and
		a.Type not in ('Referring attorney', 'Attorney', 'Law Firm')
--WHERE s.litify_tso_Source_Type_Name__c IN ('Attorney Referral')
go

-- [litify_pm__Matter__c].[Referred_By_2__c]
-- where [account].[type] not in ('Referring attorney','Attorney','Law Firm')
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
	from ShinerLitify..litify_pm__Matter__c m
	join sma_TRN_Cases cas
		on cas.saga_char = m.Id
	--JOIN ShinerLitify..[litify_pm__Source__c] s
	--	ON m.litify_pm__Source__c = s.Id
	join ShinerLitify..Account a
		on m.Referred_By_2__c = a.Id
	join IndvOrgContacts_Indexed ioc
		on ioc.saga_char = m.Referred_By_2__c
	where
		ISNULL(m.Referred_By_2__c, '') <> ''
		and
		a.Type not in ('Referring attorney', 'Attorney', 'Law Firm')
	--WHERE s.litify_tso_Source_Type_Name__c IN ('Attorney Referral')