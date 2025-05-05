/*


Advertisement Sources
- Advertising Source > sma_TRN_PdAdvt

Non-Attorney Referral = Other Referral Name > sma_TRN_OtherReferral

Internet = Advertising Source > sma_TRN_PdAdvt

Attorney Referral = Referring Attorney > sma_TRN_LawyerReferral
Attorney Referral = Referring Law Firm > sma_TRN_LawyerReferral


- caseid
- ioc.cid
- ioc.ctg
- ioc.aid

*/

use ShinerSA
go

/* ---------------------------------------------------------------------------------------------------------------
ADVERTISEMENT SOURCES
*/

-- [litify_pm__Matter__c].[litify_pm__Source__c] -> [sma_TRN_PdAdvt]
insert into sma_TRN_PdAdvt
	(
		advnCaseID,
		advnSrcContactCtg,
		advnSrcContactID,
		advnSrcAddressID,
		advnSubTypeID,
		advnPlaintiffID,
		advdDateTime,
		advdRetainedDt,
		advnFeeStruID,
		advsComments,
		advnRecUserID,
		advdDtCreated,
		advnModifyUserID,
		advdDtModified,
		advnRecordSource
	)
	select
		cas.casnCaseID as advnCaseID,
		ioc.CTG		   as advnSrcContactCtg,
		ioc.CID		   as advnSrcContactID,
		ioc.AID		   as advnSrcAddressID,
		null		   as advnSubTypeID,
		-1			   as advnPlaintiffID,
		null		   as advdDateTime,
		null		   as advdRetainedDt,
		null		   as advnFeeStruID,
		''			   as advsComments,
		368			   as advnRecUserID,
		GETDATE()	   as advdDtCreated,
		null		   as advnModifyUserID,
		null		   as advdDtModified,
		0			   as advnRecordSource
	--select m.id,s.name, s.litify_tso_Source_Type_Name__c, s.*
	from ShinerLitify..litify_pm__Matter__c m
	join sma_TRN_Cases cas
		on cas.saga_char = m.Id
	join ShinerLitify..[litify_pm__Source__c] s
		on m.litify_pm__Source__c = s.Id
	join IndvOrgContacts_Indexed ioc
		on ioc.saga_char = s.Id
	where
		s.litify_tso_Source_Type_Name__c in ('Advertisement', 'Internet')

--select * From sma_TRN_PdAdvt

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

/* ---------------------------------------------------------------------------------------------------------------
OTHER REFERRALS
*/

-- [litify_pm__Matter__c].[litify_pm__Source__c]
insert into sma_TRN_OtherReferral
	(
		otrnCaseID,
		otrnRefContactCtg,
		otrnRefContactID,
		otrnRefAddressID,
		otrnPlaintiffID,
		otrsComments,
		otrnUserID,
		otrdDtCreated
	)
	select
		cas.casnCaseID as otrnCaseID,
		ioc.CTG		   as otrnRefContactCtg,
		ioc.CID		   as otrnRefContactID,
		ioc.AID		   as otrnRefAddressID,
		-1			   as otrnPlaintiffID,
		''			   as otrsComments,
		368			   as otrnUserID,
		GETDATE()	   as otrdDtCreated
	--select m.id,s.name, s.litify_tso_Source_Type_Name__c, s.*
	from ShinerLitify..litify_pm__Matter__c m
	join sma_TRN_Cases cas
		on cas.saga_char = m.Id
	join ShinerLitify..[litify_pm__Source__c] s
		on m.litify_pm__Source__c = s.Id
	join IndvOrgContacts_Indexed ioc
		on ioc.saga_char = s.Id
	where
		s.litify_tso_Source_Type_Name__c in ('Non-Attorney Referral', 'Other')
go

-- from Role
insert into sma_TRN_OtherReferral
	(
		otrnCaseID,
		otrnRefContactCtg,
		otrnRefContactID,
		otrnRefAddressID,
		otrnPlaintiffID,
		otrsComments,
		otrnUserID,
		otrdDtCreated
	)
	select
		cas.casnCaseID as otrnCaseID,
		ioc.CTG		   as otrnRefContactCtg,
		ioc.CID		   as otrnRefContactID,
		ioc.AID		   as otrnRefAddressID,
		-1			   as otrnPlaintiffID,
		''			   as otrsComments,
		368			   as otrnUserID,
		GETDATE()	   as otrdDtCreated
	--select m.id,s.name, s.litify_tso_Source_Type_Name__c, s.*
	from ShinerLitify..litify_pm__Role__c lprc
	join sma_TRN_Cases cas
		on lprc.litify_pm__Matter__c = cas.saga_char
	join IndvOrgContacts_Indexed ioc
		on ioc.SAGA_char = lprc.litify_pm__Party__c
	where
		litify_pm__role__c in ('Referral')
go

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