


/*



Non-Attorney Referral = Other Referral Name > sma_TRN_OtherReferral

Internet = Advertising Source > sma_TRN_PdAdvt
Advertisement = Advertising Source > sma_TRN_PdAdvt

Attorney Referral = Referring Attorney > sma_TRN_LawyerReferral
Attorney Referral = Referring Law Firm > sma_TRN_LawyerReferral


- caseid
- ioc.cid
- ioc.ctg
- ioc.aid

*/

------------------------------------------------------------
--use ShinerLitify
--GO

--litify_tso_Source_Type_Name__c


--litify_pm__Matter__c





--SELECT
--	lpsc.litify_tso_Source_Type_Name__c
--   ,COUNT(*) AS Count
--FROM ShinerLitify..litify_pm__Source__c lpsc
--GROUP BY lpsc.litify_tso_Source_Type_Name__c
--ORDER BY Count DESC;


-------------------------------------------------------------


use ShinerSA
go


-------------------------------------
--INSERT ADVERTISEMENT SOURCES
-------------------------------------
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
		cas.casnCaseID as advncaseid,
		ioc.CTG		   as advnsrccontactctg,
		ioc.CID		   as advnsrccontactid,
		ioc.AID		   as advnsrcaddressid,
		null		   as advnsubtypeid,
		-1			   as advnplaintiffid,
		null		   as advddatetime,
		null		   as advdretaineddt,
		null		   as advnfeestruid,
		''			   as advscomments,
		368			   as advnrecuserid,
		GETDATE()	   as advddtcreated,
		null		   as advnmodifyuserid,
		null		   as advddtmodified,
		0			   as advnrecordsource
	--select m.id,s.name, s.litify_tso_Source_Type_Name__c, s.*
	from ShinerLitify..litify_pm__Matter__c m
	join sma_TRN_Cases cas
		on cas.saga_char = m.Id
	join ShinerLitify..[litify_pm__Source__c] s
		on m.litify_pm__Source__c = s.Id
	join IndvOrgContacts_Indexed ioc
		on ioc.saga_char = s.Id
	where s.litify_tso_Source_Type_Name__c in ('Advertisement', 'Internet')

--select * From sma_TRN_PdAdvt
------------------------------------
--ATTORNEY REFERRALS
------------------------------------
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
		cas.casnCaseID as lwrncaseid,
		case
			when ioc.CTG = 2
				then ioc.CID
			else null
		end			   as lwrnreflawfrmcontactid,
		case
			when ioc.CTG = 2
				then ioc.AID
			else null
		end			   as lwrnreflawfrmaddressid,
		case
			when ioc.CTG = 1
				then ioc.CID
			else null
		end			   as lwrnattcontactid,
		case
			when ioc.CTG = 1
				then ioc.AID
			else null
		end			   as lwrnattaddressid,
		-1			   as lwrnplaintiffid,
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
	where s.litify_tso_Source_Type_Name__c in ('', 'Attorney Referral')

------------------------
--OTHER REFERRALS
------------------------
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
		cas.casnCaseID as otrncaseid,
		ioc.CTG		   as otrnrefcontactctg,
		ioc.CID		   as otrnrefcontactid,
		ioc.AID		   as otrnrefaddressid,
		-1			   as otrnplaintiffid,
		''			   as otrscomments,
		368			   as otrnuserid,
		GETDATE()	   as otrddtcreated
	--select m.id,s.name, s.litify_tso_Source_Type_Name__c, s.*
	from ShinerLitify..litify_pm__Matter__c m
	join sma_TRN_Cases cas
		on cas.saga_char = m.Id
	join ShinerLitify..[litify_pm__Source__c] s
		on m.litify_pm__Source__c = s.Id
	join IndvOrgContacts_Indexed ioc
		on ioc.saga_char = s.Id
	where s.litify_tso_Source_Type_Name__c in ('Non-Attorney Referral', 'Other')