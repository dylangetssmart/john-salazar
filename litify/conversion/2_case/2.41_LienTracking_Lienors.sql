/* 
###########################################################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-24
Description: Create lienors and lien details

Step							Target						Source
-----------------------------------------------------------------------------------------------
[1.0] Lien Types				sma_MST_LienType			hardcode
[2.0] Lienors					sma_TRN_Lienors				[litify_pm__Lien__c]
[3.0] Lienors					sma_TRN_Lienors				[litify_pm__Damage__c]
[4.0] Lien Details				sma_TRN_LienDetails			[litify_pm__Lien__c]
[5.0] Lien Details				sma_TRN_LienDetails			[litify_pm__Damage__c]
*/

use ShinerSA
go


--select
--	*
--from ShinerLitify..litify_pm__Damage__c lpdc
--where
--	lpdc.litify_pm__Matter__c = 'a0lnt00000d1valma3'
--	and lpdc.litify_pm__Type__c = 'Subrogation Lien'
--lpdc.Id = 'a0j8z00000u9wyiqay'

--select
--	*
--from ShinerLitify..litify_pm__Matter__c lpmc
--where
--	id = 'a0lnt00000d1valma3'

/*
######################################################################
[2.0] Lienors
######################################################################
*/

alter table [sma_TRN_Lienors] disable trigger all
go

-- Add saga_char
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_TRN_Lienors')
	)
begin
	alter table [sma_TRN_Lienors]
	add saga_char VARCHAR(100)
end

go

/* ---------------------------------------------------------------------------------------------------------------------------------
Insert Lienors from [litify_pm__Damage__c]
- where [litify_pm__Type__c] = Subrogation Lien
- Lienor = litify_pm__Provider__c
*/
insert into [sma_TRN_Lienors]
	(
		[lnrnCaseID],
		[lnrnLienorTypeID],
		[lnrnLienorContactCtgID],
		[lnrnLienorContactID],
		[lnrnLienorAddressID],
		[lnrnLienorRelaContactID],
		[lnrnPlaintiffID],
		[lnrdReleaseRcvdDt],
		[lnrnCnfrmdLienAmount],
		[lnrnNegLienAmount],
		[lnrsComments],
		[lnrdNoticeDate],
		[lnrnRecUserID],
		[lnrdDtCreated],
		[lnrnFinal],
		[saga_char]
	)
	select
		cas.casnCaseID																							 as [lnrncaseid],
		(
			select
				lntnLienTypeID
			from sma_MST_LienType
			where lntsDscrptn = 'Subrogation Lien'
		)																										 as [lnrnlienortypeid],
		COALESCE(r.CTG, ioci.ctg)																				 as [lnrnlienorcontactctgid],
		COALESCE(r.cid, ioci.cid)																				 as [lnrnlienorcontactid],
		COALESCE(r.aid, ioci.aid)																				 as [lnrnlienoraddressid],
		0																										 as [lnrnlienorrelacontactid],
		t.plnnPlaintiffID																						 as [lnrnplaintiffid],
		null																									 as [lnrdreleasercvddt],
		litify_pm__Amount_Billed__c																				 as [lnrnCnfrmdLienAmount],
		/*
		UI						data
		-----------------------------------------------------------
		Amount Billed			litify_pm__Amount_Billed__c
		3rd Party Paid			Insurance_Paid__c
		Provider Adjustment		Provider_Adjustment_Amount__c
		Provider Reduction		Provider_Reduction_Amount__c
		Amount Paid				litify_pm__Amount_Paid__c
		*/
		(
		ISNULL(CONVERT(DECIMAL(10, 2), d.litify_pm__Amount_Billed__c), 0) -
		ISNULL(CONVERT(DECIMAL(10, 2), d.litify_pm__Amount_Paid__c), 0) -
		ISNULL(CONVERT(DECIMAL(10, 2), d.Provider_Adjustment_Amount__c), 0) -
		ISNULL(CONVERT(DECIMAL(10, 2), d.Provider_Reduction_Amount__c), 0) -
		ISNULL(CONVERT(DECIMAL(10, 2), d.Insurance_Paid__c), 0))												 as [lnrnNegLienAmount],
		LEFT(
		ISNULL('Damage Name: ' + NULLIF(CONVERT(VARCHAR(MAX), d.[Name]), '') + CHAR(13), '') +
		ISNULL('Provider Reduction Amount: ' + NULLIF(CONVERT(VARCHAR(MAX), d.Provider_Reduction_Amount__c), '') + CHAR(13), '') +
		ISNULL('Comments: ' + NULLIF(CONVERT(VARCHAR(MAX), d.litify_pm__Comments__c), '') + CHAR(13), ''), 2000) as [lnrscomments],
		null																									 as [lnrdnoticedate]
		--,Date_Sent__c AS [lnrdNoticeDate]
		,
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga_char = d.CreatedById
		)																										 as [lnrnrecuserid],
		d.CreatedDate																							 as [lnrddtcreated],
		0																										 as [lnrnfinal],
		d.Id																									 as [saga_char]
	--sp_help '[sma_TRN_Lienors]'
	--select d.id, ioci.*
	from ShinerLitify..[litify_pm__Damage__c] d
	left join vw_litifyRoleMapID r
		on d.litify_pm__Provider__c = r.Id
	left join IndvOrgContacts_Indexed ioci
		on ioci.Name = 'Unidentified Lienor'
	join [sma_TRN_Cases] cas
		on cas.saga_char = d.litify_pm__Matter__c
	left join [sma_TRN_Lienors] lien
		on lien.[lnrncaseid] = cas.casnCaseID
			and lien.[lnrnlienorcontactctgid] = r.CTG
			and lien.[lnrnlienorcontactid] = r.CID
	left join [sma_TRN_Plaintiff] t
		on t.plnnCaseID = cas.casnCaseID
			and t.plnbIsPrimary = 1
	where
		ISNULL(d.litify_pm__Type__c, '') in ('Subrogation Lien')
--and d.litify_pm__Matter__c = 'a0lnt00000d1valma3'



--select
----lpdc.*,
--	lpdc.litify_pm__Amount_Billed__c,
--	lpdc.litify_pm__Amount_Paid__c,
--	lpdc.Amount_Paid_by_Firm__c,
--	lpdc.litify_pm__Reduction_Amount__c,
--	lpdc.Provider_Adjustment_Amount__c,
--	lpdc.Provider_Reduction_Amount__c,
--	lpdc.Insurance_Paid__c,
--	ISNULL(CONVERT(DECIMAL(10, 2), lpdc.litify_pm__Amount_Billed__c), 0) -
--	ISNULL(CONVERT(DECIMAL(10, 2), lpdc.litify_pm__Amount_Paid__c), 0) -
--	--isnull(convert(decimal(10,2),lpdc.Amount_Paid_by_Firm__c),0) -
--	ISNULL(CONVERT(DECIMAL(10, 2), lpdc.Provider_Adjustment_Amount__c), 0) -
--	ISNULL(CONVERT(DECIMAL(10, 2), lpdc.Provider_Reduction_Amount__c), 0) -
--	ISNULL(CONVERT(DECIMAL(10, 2), lpdc.Insurance_Paid__c), 0) as AmountDue
--from ShinerLitify..litify_pm__Damage__c lpdc
--where lpdc.Id = 'a0j8Z00000u7la1QAA'
--where
--	ISNULL(lpdc.litify_pm__Amount_Billed__c, '') <> ''
--	and ISNULL(lpdc.litify_pm__Amount_Paid__c, '') <> ''
--	and ISNULL(lpdc.Amount_Paid_by_Firm__c, '') <> ''
--	and ISNULL(lpdc.Provider_Adjustment_Amount__c, '') <> ''
--	and ISNULL(lpdc.Provider_Reduction_Amount__c, '') <> ''

--	select name from ShinerLitify..litify_pm__Matter__c lpmc where lpmc.Id in ('a0L8Z00000eDavPUAS',
--'a0L8Z00000fKmu1UAC')

--select
--	*
--from ShinerLitify..litify_pm__Damage__c lpdc
--where lpdc.Id = 'a0j8Z00000u7la1QAA'
--where
--	lpdc.litify_pm__Amount_Paid__c <> lpdc.Amount_Paid_by_Firm__c

go

/*
ds 2025-03-03
as per Sue, only create Lienors from damages

-- [2.2] Insert Lienors
-- Source = [litify_pm__Lien__c]
-- Type = Unknown
-- Lienor = litify_ext__Payee_Party__c

insert into [sma_TRN_Lienors]
	(
	[lnrnCaseID],
	[lnrnLienorTypeID],
	[lnrnLienorContactCtgID],
	[lnrnLienorContactID],
	[lnrnLienorAddressID],
	[lnrnLienorRelaContactID],
	[lnrnPlaintiffID],
	[lnrdReleaseRcvdDt],
	[lnrnCnfrmdLienAmount],
	[lnrnNegLienAmount],
	[lnrsComments],
	[lnrdNoticeDate],
	[lnrnRecUserID],
	[lnrdDtCreated],
	[lnrnFinal],
	[saga_char]
	)
	select
		cas.casnCaseID				 as [lnrncaseid],
		(
			select
				lntnLienTypeID
			from sma_MST_LienType
			--WHERE lntsDscrptn = ISNULL([type__c], 'Unknown')
			where lntsDscrptn = 'Unknown'
		)							 as [lnrnlienortypeid],
		ISNULL(ioc.CTG, iocu.CTG)	 as [lnrnlienorcontactctgid],
		ISNULL(ioc.CID, iocu.CID)	 as [lnrnlienorcontactid],
		ISNULL(ioc.AID, iocu.AID)	 as [lnrnlienoraddressid],
		0							 as [lnrnlienorrelacontactid],
		t.plnnPlaintiffID			 as [lnrnplaintiffid],
		null						 as [lnrdreleasercvddt],
		litify_pm__lit_Amount__c	 as [lnrncnfrmdlienamount],
		litify_pm__lit_Reductions__c as [lnrnneglienamount],
		ISNULL('Name: ' + NULLIF(CONVERT(VARCHAR(MAX), r.[Name]), '') + CHAR(13), '') +
		ISNULL('Comments: ' + NULLIF(CONVERT(VARCHAR(MAX), r.[litify_pm__lit_Comments__c]), '') + CHAR(13), '') +
		''							 as [lnrscomments],
		r.CreatedDate				 as [lnrdnoticedate],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga_char = r.CreatedById
		)							 as [lnrnrecuserid],
		r.CreatedDate				 as [lnrddtcreated],
		0							 as [lnrnfinal],
		r.Id						 as [saga_char]
	--select *
	from [ShinerLitify]..[litify_pm__Lien__c] r
	join sma_TRN_Cases cas
		on cas.saga_char = r.litify_pm__lit_Matter__c
	-- Lienor
	left join IndvOrgContacts_Indexed ioc
		on ioc.saga_char = r.litify_ext__Payee_Party__c
	--LEFT JOIN indvorgContacts_Indexed ioc
	--	ON ioc.saga = r.Provider__c
	-- Fallback to unid lienor
	left join IndvOrgContacts_Indexed iocu
		on iocu.Name = 'Unidentified Lienor'
	-- Plaintiff
	left join [sma_TRN_Plaintiff] t
		on t.plnnCaseID = cas.casnCaseID
			and t.plnbIsPrimary = 1
go

-- [2.4] Insert Lienors from litify_pm__Role__c
-- Source = [litify_pm__Damage__c]
-- Type = Subrogation Lien
-- Lienor = litify_pm__Provider__c
insert into [sma_TRN_Lienors]
	(
	[lnrnCaseID],
	[lnrnLienorTypeID],
	[lnrnLienorContactCtgID],
	[lnrnLienorContactID],
	[lnrnLienorAddressID],
	[lnrnLienorRelaContactID],
	[lnrnPlaintiffID],
	[lnrdReleaseRcvdDt],
	[lnrnCnfrmdLienAmount],
	[lnrnNegLienAmount],
	[lnrsComments],
	[lnrdNoticeDate],
	[lnrnRecUserID],
	[lnrdDtCreated],
	[lnrnFinal],
	[saga_char]
	)
	select
		cas.casnCaseID	  as [lnrncaseid],
		(
			select
				lntnLienTypeID
			from sma_MST_LienType
			where lntsDscrptn = 'Other'
		)				  as [lnrnlienortypeid],
		role_map.CTG	  as [lnrnlienorcontactctgid],
		role_map.CID	  as [lnrnlienorcontactid],
		role_map.AID	  as [lnrnlienoraddressid],
		0				  as [lnrnlienorrelacontactid],
		t.plnnPlaintiffID as [lnrnplaintiffid],
		null			  as [lnrdreleasercvddt],
		null			  as [lnrncnfrmdlienamount],
		null			  as [lnrnneglienamount]
		--  ,ISNULL('Name: ' + NULLIF(CONVERT(VARCHAR(MAX), d.[Name]), '') + CHAR(13), '') +
		--ISNULL('Comments: ' + NULLIF(CONVERT(VARCHAR(MAX), d.litify_pm__Comments__c), '') + CHAR(13), '') +
		,
		''				  as [lnrscomments],
		null			  as [lnrdnoticedate]
		--,Date_Sent__c AS [lnrdNoticeDate]
		--  ,(
		--	SELECT
		--		usrnUserID
		--	FROM sma_MST_Users
		--	WHERE saga = d.CreatedById
		--)							   
		--AS [lnrnRecUserID]
		,
		null			  as [lnrnrecuserid],
		null			  as [lnrddtcreated],
		0				  as [lnrnfinal],
		role.Id			  as [saga_char]
	--sp_help '[sma_TRN_Lienors]'
	--select *
	from ShinerLitify..litify_pm__Role__c role
	--where role.litify_pm__Matter__c = 'a0L8Z00000eDawuUAC'
	-- Role mapping
	join vw_litifyRoleMapID role_map
		on role.litify_pm__Matter__c = role_map.litify_pm__Matter__c
	-- Case
	join [sma_TRN_Cases] cas
		on cas.saga_char = role.litify_pm__Matter__c
	-- Lienors
	left join [sma_TRN_Lienors] lien
		on lien.[lnrncaseid] = cas.casnCaseID
			and lien.[lnrnlienorcontactctgid] = role_map.CTG
			and lien.[lnrnlienorcontactid] = role_map.CID
	-- Plaintiff
	left join [sma_TRN_Plaintiff] t
		on t.plnnCaseID = cas.casnCaseID
			and t.plnbIsPrimary = 1
	where ISNULL(role_map.litify_pm__Role__c, '') in ('Lien')
		--AND role.litify_pm__Matter__c ='a0L8Z00000eDawuUAC'
		and lien.lnrncaseid is null; -- Only include if lienor does not already exist

go
*/


----
alter table [sma_TRN_Lienors] enable trigger all
go