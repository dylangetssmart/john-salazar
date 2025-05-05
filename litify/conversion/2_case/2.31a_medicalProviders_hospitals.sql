/* ###################################################################################
description: Create Medical Providers and Medical Bills

- Create medical providers from litify_pm__Damage__c
- Create medical providers from litify_pm__Role__c
- Create medical bills from damages

*/

use ShinerSA
go

/* ---------------------------------------------------------------------------------------------------------------
[sma_TRN_Hospitals] Schema
*/

-- saga_char
if not exists (
		select
			*
		from sys.COLUMNS
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_TRN_Hospitals')
	)
begin
	alter table [sma_TRN_Hospitals]
	add [saga_char] [VARCHAR](100) null;
end


-- source_db
if not exists (
		select
			*
		from sys.COLUMNS
		where Name = N'source_db'
			and object_id = OBJECT_ID(N'sma_TRN_Hospitals')
	)
begin
	alter table [sma_TRN_Hospitals] add [source_db] VARCHAR(MAX) null;
end

go

-- source_ref
if not exists (
		select
			*
		from sys.COLUMNS
		where Name = N'source_ref'
			and object_id = OBJECT_ID(N'sma_TRN_Hospitals')
	)
begin
	alter table [sma_TRN_Hospitals] add [source_ref] VARCHAR(MAX) null;
end

go

/* ---------------------------------------------------------------------------------------------------------------
[sma_TRN_SpDamages] Schema
*/

-- saga_bill_id
if not exists (
		select
			*
		from sys.COLUMNS
		where Name = N'saga_bill_id'
			and object_id = OBJECT_ID(N'sma_TRN_SpDamages')
	)
begin
	alter table [sma_TRN_SpDamages]
	add [saga_bill_id] [VARCHAR](100) null;
end

--------------------------------------------------------------------------
---------------------------- MEDICAL PROVIDERS ---------------------------
--------------------------------------------------------------------------

alter table [sma_TRN_Hospitals] disable trigger all
go

-----------------------------------------
--HOSPITALS FROM DAMAGES
-- damage type mapping
-----------------------------------------
insert into [sma_TRN_Hospitals]
	(
		[hosnCaseID],
		[hosnContactID],
		[hosnContactCtg],
		[hosnAddressID],
		[hossMedProType],
		[hosdStartDt],
		[hosdEndDt],
		[hosnPlaintiffID],
		[hosnComments],
		[hosnHospitalChart],
		[hosnRecUserID],
		[hosdDtCreated],
		[hosnModifyUserID],
		[hosdDtModified],
		[saga_char],
		[source_db],
		[source_ref]
	)
	select distinct
		casnCaseID				  as [hosncaseid],
		COALESCE(r.cid, ioci.cid) as [hosncontactid],
		COALESCE(r.CTG, ioci.ctg) as [hosncontactctg],
		COALESCE(r.aid, ioci.aid) as [hosnaddressid],
		'M'						  as [hossmedprotype],			--M or P (P for Prior Medical Provider)
		null					  as [hosdstartdt],
		null					  as [hosdenddt],
		(
			select top 1
				plnnPlaintiffID
			from [sma_TRN_Plaintiff]
			where plnnCaseID = casnCaseID
				and plnbIsPrimary = 1
		)						  as hosnplaintiffid,
		''						  as [hosncomments],
		null					  as [hosnhospitalchart],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga_char = d.CreatedById
		)						  as [hosnrecuserid],
		case
			when d.CreatedDate between '1900-01-01' and '2079-06-06'
				then d.CreatedDate
			else GETDATE()
		end						  as [hosddtcreated],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga_char = d.LastModifiedById
		)						  as [hosnmodifyuserid],
		case
			when d.LastModifiedDate between '1900-01-01' and '2079-06-06'
				then d.LastModifiedDate
			else GETDATE()
		end						  as [hosddtmodified],
		d.Id					  as [saga_char],
		'litify'				  as [source_db],
		'litify_pm__Damage__c'	  as [source_ref]
	--select * 
	from ShinerLitify..[litify_pm__Damage__c] d
	join ShinerSa..vw_litifyRoleMapID r
		on d.litify_pm__Provider__c = r.Id
	left join IndvOrgContacts_Indexed ioci
		on ioci.Name = 'Unidentified Medical Provider'
	join ShinerSA..[sma_TRN_Cases] cas
		on cas.saga_char = d.litify_pm__Matter__c
	left join ShinerSA..[sma_TRN_Hospitals] h
		on h.hosncaseid = cas.casnCaseID
			and h.hosncontactctg = r.CTG
			and h.hosncontactid = r.CID
	where
		ISNULL(d.litify_pm__Type__c, '') in ('Medical Bill'
		--select
		--	code
		--from #DamageTypes dt
		)
		and h.hosnHospitalID is null	--only add if it does not already exist
--and cas.casnCaseID = 2566
--and d.litify_pm__Matter__c = 'a0L8Z00000eDaxBUAS'
go


-----------------------------------------
--HOSPITALS FROM CONTACT ROLES
-----------------------------------------
-- from Party Mapping
insert into [sma_TRN_Hospitals]
	(
		[hosnCaseID],
		[hosnContactID],
		[hosnContactCtg],
		[hosnAddressID],
		[hossMedProType],
		[hosdStartDt],
		[hosdEndDt],
		[hosnPlaintiffID],
		[hosnComments],
		[hosnHospitalChart],
		[hosnRecUserID],
		[hosdDtCreated],
		[hosnModifyUserID],
		[hosdDtModified],
		[saga_char]
	)
	select distinct
		casnCaseID as [hosncaseid],
		ioc.CID	   as [hosncontactid],
		ioc.CTG	   as [hosncontactctg],
		ioc.AID	   as [hosnaddressid],
		case
			when litify_pm__role__c like 'Prior%'
				then 'P'
			else 'M'
		end		   as [hossmedprotype],		--M or P (P for Prior Medical Provider)
		null	   as [hosdstartdt],
		null	   as [hosdenddt],
		(
			select top 1
				plnnPlaintiffID
			from [sma_TRN_Plaintiff]
			where plnnCaseID = casnCaseID
				and plnbIsPrimary = 1
		)		   as hosnplaintiffid,
		''		   as [hosncomments],
		null	   as [hosnhospitalchart],
		368		   as [hosnrecuserid],
		GETDATE()  as [hosddtcreated],
		null	   as [hosnmodifyuserid],
		null	   as [hosddtmodified],
		m.Id	   as [saga_char]
	from [ShinerLitify]..litify_pm__role__c m
	join [sma_TRN_Cases] cas
		on cas.saga_char = m.litify_pm__Matter__c
	join IndvOrgContacts_Indexed ioc
		on ioc.saga_char = m.litify_pm__Party__c
	left join [sma_TRN_Hospitals] h
		on h.hosncaseid = cas.casnCaseID
			and h.hosncontactctg = ioc.ctg
			and h.hosncontactid = ioc.CID
	where
		litify_pm__role__c in ('Medical Provider'
		--select
		--	code
		--from #MedicalProviderRoles mpr
		)
		and h.hosnHospitalID is null	--only add if it does not already exist
--WHERE litify_pm__role__c IN ('Doctor', 'Health Care Facility', 'Medical Provider', 'PRIOR Medical Provider')
go


-----------------------------------
----MEDICAL BILLS #########################################################################################
-----------------------------------
---- uses #DamageTypes
--insert into [sma_TRN_SpDamages]
--	(
--	[spdsRefTable],
--	[spdnRecordID],
--	[spdnBillAmt]
--	--,[spdnadditionalField2] --written off
--	,
--	[spdsAccntNo],
--	[spddNegotiatedBillAmt],
--	[spdnAmtPaid],
--	[spddDateFrom],
--	[spddDateTo],
--	[spddDamageSubType],
--	[spdnVisitId],
--	[spdsComments],
--	[spdnRecUserID],
--	[spddDtCreated],
--	[spdnModifyUserID],
--	[spddDtModified],
--	[spdnBalance],
--	[spdbLienConfirmed],
--	[spdbDocAttached],
--	[saga_bill_id]
--	)
--	select
--		'Hospitals'																	 as spdsreftable,
--		h.hosnHospitalID															 as spdnrecordid,
--		d.litify_pm__Amount_Billed__c												 as spdnbillamt
--		--,d.litify_pm__Reduction_Amount__c											 AS [spdnadditionalField2]
--		,
--		null																		 as spdsaccntno,
--		null																		 as spddnegotiatedbillamt,
--		d.litify_pm__Amount_Paid__c													 as [spdnamtpaid],
--		case
--			when d.litify_pm__Service_Start_Date__c between '1900-01-01' and '2079-06-06'
--				then d.litify_pm__Service_Start_Date__c
--			else null
--		end																			 as spdddatefrom,
--		case
--			when d.litify_pm__Service_End_Date__c between '1900-01-01' and '2079-06-06'
--				then d.litify_pm__Service_End_Date__c
--			else null
--		end																			 as spdddateto,
--		null																		 as spdddamagesubtype,
--		null																		 as spdnvisitid,
--		ISNULL(NULLIF(CONVERT(VARCHAR, d.litify_pm__Comments__c), ''), 'conversion') as spdscomments,
--		(
--			select
--				usrnUserID
--			from sma_MST_Users
--			where saga_char = d.CreatedById
--		)																			 as spdnrecordid,
--		case
--			when d.CreatedDate between '1900-01-01' and '2079-06-06'
--				then d.CreatedDate
--			else GETDATE()
--		end																			 as spdddtcreated,
--		(
--			select
--				usrnUserID
--			from sma_MST_Users
--			where saga_char = d.LastModifiedById
--		)																			 as spdnmodifyuserid,
--		case
--			when d.LastModifiedDate between '1900-01-01' and '2079-06-06'
--				then d.LastModifiedDate
--			else GETDATE()
--		end																			 as spdddtmodified,
--		null																		 as spdnbalance,
--		0																			 as spdblienconfirmed,
--		0																			 as spdbdocattached,
--		d.Id																		 as saga_bill_id  -- one bill one value
--	--select *
--	from ShinerLitify..[litify_pm__Damage__c] d
--	join vw_litifyRoleMapID r
--		on d.litify_pm__Provider__c = r.Id
--	join [sma_TRN_Cases] cas
--		on cas.saga_char = d.litify_pm__Matter__c
--	join [sma_TRN_Hospitals] h
--		on h.hosnCaseID = cas.casnCaseID
--			and h.hosnContactCtg = r.ctg
--			and h.hosnContactID = r.CID
--	where ISNULL(d.litify_pm__Type__c, '') in ('Medical Bill'
--		--select
--		--	code
--		--from #DamageTypes dt
--		)
--		or d.litify_pm__Type__c is null		-- ds 2024-10-21 include null values, which should not exist during live conversion
----WHERE ISNULL(d.litify_pm__type__C, '') IN ('', 'Medical Bill')


alter table [sma_TRN_Hospitals] enable trigger all
go
