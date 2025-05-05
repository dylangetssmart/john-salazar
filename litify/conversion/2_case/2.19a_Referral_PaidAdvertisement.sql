use ShinerSA
go

/* ---------------------------------------------------------------------------------------------------------------
Create Referral Types
from [litify_pm__Source__c].[litify_tso_Source_Type_Name__c]
*/

--SELECT * FROM shinersa..sma_MST_ReferralType
--SELECT distinct lpsc.litify_tso_Source_Type_Name__c FROM ShinerLitify..litify_pm__Source__c lpsc

insert into [dbo].[sma_MST_ReferralType]
	(
		[rftsCode],
		[rftsDscrptn],
		[rftnRecUserID],
		[rftdDtCreated],
		[rftnModifyUserID],
		[rftdDtModified],
		[rftnLevelNo]
	)
	select distinct
		null									   as rftsCode, --varchar(20),>
		LEFT(s.litify_tso_Source_Type_Name__c, 50) as rftsDscrptn, --varchar(50),>
		368										   as rftnRecUserID, --int,>
		GETDATE()								   as rftdDtCreated, --smalldatetime,>
		null									   as rftnModifyUserID, --int,>
		null									   as rftdDtModified, --smalldatetime,>
		null									   as rftnLevelNo -- int,>
	from ShinerLitify..litify_pm__Source__c s
	where
		ISNULL(s.litify_tso_Source_Type_Name__c, '') <> ''
		and not exists (
			select
				1
			from [dbo].[sma_MST_ReferralType] rt
			where rt.rftsDscrptn = LEFT(s.litify_tso_Source_Type_Name__c, 50)
		)
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
		(
			select
				rftnRefferalTypeID
			from sma_MST_ReferralType
			where rftsDscrptn = s.litify_tso_Source_Type_Name__c
		)			   as advnSubTypeID,
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