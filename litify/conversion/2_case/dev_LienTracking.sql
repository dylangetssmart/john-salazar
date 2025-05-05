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

/*
######################################################################
Validation
######################################################################
*/

--if 1 = 0 -- Always false
--begin

--	-- from Damage ------------------------------------
--	select
--		*
--	from ShinerLitify..litify_pm__Matter__c lpmc
--	where lpmc.litify_pm__Display_Name__c like '%cheryl lavigne%'
--	-- matter_id: a0LNt00000B4BoWMAV
--	-- MAT-24041528833

--	select
--		*
--	from ShinerLitify..litify_pm__Damage__c lpdc
--	where lpdc.litify_pm__Matter__c = 'a0LNt00000B4BoWMAV'

--	select
--		*
--	from ShinerLitify..[litify_pm__Damage__c] d
--	join vw_litifyRoleMapID r
--		on d.litify_pm__Provider__c = r.Id
--	join [sma_TRN_Cases] cas
--		on cas.Litify_saga = d.litify_pm__Matter__c
--	left join [sma_TRN_Lienors] lien
--		on lien.[lnrnCaseID] = cas.casnCaseID
--			and lien.[lnrnLienorContactCtgID] = r.CTG
--			and lien.[lnrnLienorContactID] = r.CID
--	left join [sma_TRN_Plaintiff] t
--		on t.plnnCaseID = cas.casnCaseID
--			and t.plnbIsPrimary = 1
--	where ISNULL(d.litify_pm__Type__c, '') in ('Subrogation Lien')
--		and d.litify_pm__Matter__c = 'a0LNt00000B4BoWMAV'


--	-- from Role ------------------------------------
--	select
--		*
--	from ShinerLitify..litify_pm__Matter__c lpmc
--	where lpmc.litify_pm__Display_Name__c like '%gariann%'
--	-- matter_id: a0L8Z00000eDawuUAC
--	-- MAT-23010526449


--	select
--		*
--	from ShinerLitify..litify_pm__Role__c role
--	join vw_litifyRoleMapID role_map
--		on role.litify_pm__Matter__c = role_map.litify_pm__Matter__c
--			and role.Id = role_map.Id
--	join [sma_TRN_Cases] cas
--		on cas.Litify_saga = role.litify_pm__Matter__c
--	left join [sma_TRN_Lienors] lien
--		on lien.[lnrnCaseID] = cas.casnCaseID
--			and lien.[lnrnLienorContactCtgID] = role_map.CTG
--			and lien.[lnrnLienorContactID] = role_map.CID
--	left join [sma_TRN_Plaintiff] t
--		on t.plnnCaseID = cas.casnCaseID
--			and t.plnbIsPrimary = 1
--	where ISNULL(role_map.litify_pm__Role__c, '') in ('Lien')
--		and role.litify_pm__Matter__c = 'a0L8Z00000eDawuUAC'
--		and lien.lnrnCaseID is null; -- Only include if lienor does not already exist






--	-- Lien
--	select
--		*
--	from ShinerLitify..[litify_pm__Lien__c]
--	where litify_pm__lit_Matter__c = 'a0L8Z00000eDawuUAC'
--	--litify_pm__lit_Payee__c > a0V8Z00000lvjXUUAY
--	--litify_ext__Payee_Party__c > 0018Z00002ryunCQAQ	
--	select
--		*
--	from ShinerLitify..Account a
--	where a.Id = '0018Z00002ryunCQAQ'
--	select
--		*
--	from ShinerLitify..Contact c
--	-- Lien.ext_payee_party > account.id >>>> represents Lienor


--	select
--		*
--	from indvorgContacts_Indexed
--	where SAGA = 'a0VNt000002mFwTMAU'


--	select
--		*
--	from ShinerLitify..[Account] c
--	left join ShinerLitify..Contact ct
--		on ct.AccountId = c.Id

--	--WHERE id = 'a0V8Z00000lvjXUUAY'


--	select
--		*
--	from ShinerLitify..litify_pm__Damage__c lpdc
--	where lpdc.litify_pm__Matter__c = 'a0LNt00000B4BoWMAV'




--	-- lien id: a0w8Z00000W3KjaQAF

--	select
--		*
--	from ShinerLitify..RecordType rt
--	select
--		*
--	from ShinerSA..sma_MST_LienType smlt

--	select
--		--DISTINCT	Type
--		cas.casnCaseID,
--		t.*
--	from ShinerLitify..[Task] t
--	join sma_TRN_Cases cas
--		on cas.Litify_saga = t.WhatId
--	where cas.cassCaseNumber = 'MAT-23010526449' --AND t.Priority = 'high'


--end
-------------------------------------------- END VALIDATION --------------------------------------------





/*
######################################################################
[1.0] Lien Types
######################################################################
*/
insert into sma_MST_LienType
	(
	lntsDscrptn
	)
	--SELECT DISTINCT
	--	ISNULL([type__c], 'Unknown')
	--FROM ShinerLitify..[litify_pm__Lien__c]
	select
		'Unknown'
	union
	select
		'Subrogation Lien'
	except
	select
		lntsDscrptn
	from sma_MST_LienType
go


/*
######################################################################
[2.0] Lienors
######################################################################
*/

alter table [sma_TRN_Lienors] disable trigger all
go

-- [2.1] Add Saga
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

-- [2.3] Insert Lienors
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
		cas.casnCaseID																							 as [lnrncaseid],
		(
			select
				lntnLienTypeID
			from sma_MST_LienType
			where lntsDscrptn = 'Subrogation Lien'
		)																										 as [lnrnlienortypeid],
		r.CTG																									 as [lnrnlienorcontactctgid],
		r.CID																									 as [lnrnlienorcontactid],
		r.AID																									 as [lnrnlienoraddressid],
		0																										 as [lnrnlienorrelacontactid],
		t.plnnPlaintiffID																						 as [lnrnplaintiffid],
		null																									 as [lnrdreleasercvddt],
		litify_pm__Amount_Billed__c																				 as [lnrncnfrmdlienamount],
		litify_pm__Reduction_Amount__c																			 as [lnrnneglienamount],
		LEFT(
		ISNULL('Name: ' + NULLIF(CONVERT(VARCHAR(MAX), d.[Name]), '') + CHAR(13), '') +
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
	--select *
	from ShinerLitify..[litify_pm__Damage__c] d
	join vw_litifyRoleMapID r
		on d.litify_pm__Provider__c = r.Id
	join [sma_TRN_Cases] cas
		on cas.saga_char = d.litify_pm__Matter__c
	left join [sma_TRN_Lienors] lien
		on lien.[lnrncaseid] = cas.casnCaseID
			and lien.[lnrnlienorcontactctgid] = r.CTG
			and lien.[lnrnlienorcontactid] = r.CID
	left join [sma_TRN_Plaintiff] t
		on t.plnnCaseID = cas.casnCaseID
			and t.plnbIsPrimary = 1
	where ISNULL(d.litify_pm__Type__c, '') in ('Subrogation Lien')

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


/*
######################################################################
[3.0] Lien Details
######################################################################
*/

alter table [sma_TRN_LienDetails] disable trigger all
go

-- [3.1] Add Saga
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_TRN_LienDetails')
	)
begin
	alter table [sma_TRN_LienDetails]
	add saga_char VARCHAR(100)
end
go

-- [3.2] Insert Lien Details
-- Source = [litify_pm__Lien__c]
insert into [sma_TRN_LienDetails]
	(
	lndnLienorID,
	lndnLienTypeID,
	lndnCnfrmdLienAmount,
	lndsRefTable,
	lndnRecUserID,
	lnddDtCreated,
	saga_char
	)
	select
		lnrnLienorID		 as lndnlienorid,
		lnrnLienorTypeID	 as lndnlientypeid,
		lnrnCnfrmdLienAmount as lndncnfrmdlienamount,
		'sma_TRN_Lienors'	 as lndsreftable,
		368					 as lndnrecuserid,
		GETDATE()			 as lndddtcreated,
		l.Id				 as saga
	from [ShinerLitify]..[litify_pm__Lien__c] l
	join sma_TRN_Cases cas
		on cas.saga_char = l.Id
	join sma_TRN_Lienors lien
		on lien.[lnrnCaseID] = cas.casnCaseID
			and lien.saga_char = l.Id
go

-- [3.3] Insert Lien Details
-- Source = [sma_TRN_Lienors] (Damage)
insert into [sma_TRN_LienDetails]
	(
	lndnLienorID,
	lndnLienTypeID,
	lndnCnfrmdLienAmount,
	lndsRefTable,
	lndnRecUserID,
	lnddDtCreated,
	saga_char
	)
	select
		lnrnLienorID		 as lndnlienorid,
		lnrnLienorTypeID	 as lndnlientypeid,
		lnrnCnfrmdLienAmount as lndncnfrmdlienamount,
		'sma_TRN_Lienors'	 as lndsreftable,
		368					 as lndnrecuserid,
		GETDATE()			 as lndddtcreated,
		lien.saga_char		 as saga

	from --[ShinerLitify]..[litify_pm__Damage__c] l
	--JOIN sma_trn_Cases cas on cas.Litify_saga = l.id
	sma_TRN_Lienors lien --on  lien.saga = l.Id
	left join [sma_TRN_LienDetails] ld
		on ld.lndnlienorid = lien.lnrnLienorID
			and ld.lndnlientypeid = lien.lnrnLienorTypeID
			and ld.lndncnfrmdlienamount = lien.lnrnCnfrmdLienAmount
	where ld.lndnLienDetailID is null
go

----
alter table [sma_TRN_Lienors] enable trigger all
go

alter table [sma_TRN_LienDetails] enable trigger all
go



