
select m.litify_pm__Source__c,m.Referral__c, m.Referral_Source__c, m.Referred_To__c, s.*
FROM [sma_trn_cases] CAS
JOIN [LitifyLesser]..[litify_pm__intake__c] m on m.id = cas.Litify_saga
join litifylesser..[litify_pm__Source__c] s on m.litify_pm__Source__c= s.Id

------------------------------------
--ATTORNEY REFERRALS
------------------------------------
INSERT INTO sma_TRN_LawyerReferral (lwrnCaseID, lwrnRefLawFrmContactID, lwrnRefLawFrmAddressId, lwrnAttContactID, lwrnAttAddressID, lwrnPlaintiffID, lwrsComments, lwrnUserID, lwrdDtCreated)
SELECT 
		cas.casnCaseID			as lwrnCaseID,
		case when ioc.ctg = 2 then ioc.CID else NULL end		as lwrnRefLawFrmContactID,
		case when ioc.ctg = 2 then ioc.AID else NULL end		as lwrnRefLawFrmAddressId,
		case when ioc.ctg = 1 then ioc.cid else NULL end		as lwrnAttContactID,
		case when ioc.ctg = 1 then ioc.AID else NULL end		as lwrnAttAddressID,
		-1						as lwrnPlaintiffID,
		''						as lwrscomments,
		368						as lwrnuserid,
		getdate()				as lwrddtcreated
--select m.id,s.name, s.litify_tso_Source_Type_Name__c, s.*
from LitifyLesser..[litify_pm__intake__c] m
JOIN sma_trn_Cases cas on CAS.Litify_saga = m.Id
join LitifyLesser..[litify_pm__Source__c] s on m.litify_pm__Source__c= s.Id
JOIN IndvOrgContacts_Indexed ioc on ioc.saga = s.Id
WHERE s.litify_tso_Source_Type_Name__c in ('Attorney Referral')



------------------------
--OTHER REFERRALS
------------------------
INSERT INTO sma_TRN_OtherReferral (otrnCaseID, otrnRefContactCtg, otrnRefContactID, otrnRefAddressID, otrnPlaintiffID, otrsComments, otrnUserID, otrdDtCreated)
SELECT 
		cas.casnCaseID			as otrnCaseID,
		ioc.CTG					as otrnRefContactCtg,
		ioc.CID					as otrnRefContactID,
		ioc.AID					as otrnRefAddressID,
		-1						as otrnPlaintiffID,
		''						as otrsComments,
		368						as otrnUserID,
		getdate()				as otrdDtCreated
--select m.id,s.name, s.litify_tso_Source_Type_Name__c, s.*
from litifylesser..[litify_pm__intake__c] m
JOIN sma_trn_Cases cas on CAS.Litify_saga = m.Id
join litifylesser..[litify_pm__Source__c] s on m.litify_pm__Source__c= s.Id
JOIN IndvOrgContacts_Indexed ioc on ioc.saga = s.Id
WHERE s.litify_tso_Source_Type_Name__c in ('Friend of the Firm','Medical Provider Referral','Client','Other','')



-------------------------------------
--INSERT ADVERTISEMENT SOURCES
-------------------------------------
INSERT INTO sma_TRN_PdAdvt (advnCaseID, advnSrcContactCtg, advnSrcContactID, advnSrcAddressID, advnSubTypeID, advnPlaintiffID, advdDateTime, 
			advdRetainedDt, advnFeeStruID, advsComments, advnRecUserID, advdDtCreated, advnModifyUserID, advdDtModified,advnRecordSource)
SELECT 
		cas.casnCaseID		as advnCaseID,
		ioc.CTG				as advnSrcContactCtg,
		ioc.CID				as advnSrcContactID,
		ioc.AID				as advnSrcAddressID,
		NULL				as advnSubTypeID,
		-1					as advnPlaintiffID,
		NULL				as advdDateTime,
		NULL				as advdRetainedDt,
		NULL				as advnFeeStruID,
		''					as advsComments,
		368					as advnRecUserID,
		getdate()			as advdDtCreated,
		NULL				as advnModifyUserID, 
		NULL				as advdDtModified,
		0				as advnRecordSource
--select m.id,s.name, s.litify_tso_Source_Type_Name__c, s.*
--select distinct s.*
FROM [sma_trn_cases] CAS
JOIN LitifyLesser..[litify_pm__intake__c] m on m.Id = CAS.Litify_saga
join LitifyLesser..[litify_pm__Source__c] s on m.litify_pm__Source__c= s.Id
JOIN IndvOrgContacts_Indexed ioc on ioc.saga = s.Id
WHERE s.litify_tso_Source_Type_Name__c in ('Search Engine','Internet','Other')