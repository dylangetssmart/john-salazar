use ShinerSA
go

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

-- [litify_pm__Role__c]
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