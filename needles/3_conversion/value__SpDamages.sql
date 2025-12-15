/*---
description: Insert Special Damages from [value]
steps:
	1. Setup helper table with relevant id fields
	2. Insert Special Damage Types			[sma_MST_SpecialDamageType]
	3. Insert Special Damage Sub Types		[sma_MST_SpecialDamageSubType]
	4. Insert Special Damages				[sma_TRN_SpDamages]
instructions:
	1. Ensure [ValueCodeMap] is updated with applicable value codes
	2. Update insert statements as necessary
dependencies:
	- [Needles]..[value_Indexed]
    - [SA].[dbo].[ValueCodeMap]
	- [SA].[dbo].[sma_TRN_Cases]
	- [SA].[dbo].[IndvOrgContacts_Indexed]
	- [SA].[dbo].[sma_TRN_Plaintiff]
	- [SA].[dbo].[sma_TRN_Defendants]
notes: >
---*/

use [SA]
go

exec AddBreadcrumbsToTable 'sma_TRN_SpDamages'
go


/* ------------------------------------------------------------------------------
Build helpers
*/ ------------------------------------------------------------------------------

--- [value_tab_spDamages_Helper]
if exists (
	 select
		 *
	 from sys.objects
	 where name = 'value_tab_spDamages_Helper'
		 and type = 'U'
	)
begin
	drop table value_tab_spDamages_Helper
end

go

---
create table value_tab_spDamages_Helper (
	TableIndex	   [INT] identity (1, 1) not null,
	case_id		   INT,
	value_id	   INT,
	ProviderNameId INT,
	ProviderName   VARCHAR(200),
	ProviderCID	   INT,
	ProviderCTG	   INT,
	ProviderAID	   INT,
	casnCaseID	   INT,
	PlaintiffID	   INT,
	constraint IOC_Clustered_Index_value_tab_spDamages_Helper primary key clustered (TableIndex)
) on [PRIMARY]
go

create nonclustered index IX_NonClustered_Index_value_tab_spDamages_Helper_case_id on [value_tab_spDamages_Helper] (case_id);
create nonclustered index IX_NonClustered_Index_value_tab_spDamages_Helper_value_id on [value_tab_spDamages_Helper] (value_id);
create nonclustered index IX_NonClustered_Index_value_tab_spDamages_Helper_ProviderNameId on [value_tab_spDamages_Helper] (ProviderNameId);
go

---
insert into [value_tab_spDamages_Helper]
	(
		case_id,
		value_id,
		ProviderNameId,
		ProviderName,
		ProviderCID,
		ProviderCTG,
		ProviderAID,
		casnCaseID,
		PlaintiffID
	)
	select
		V.case_id	   as case_id,	        -- needles case
		V.value_id	   as tab_id,		    -- needles records TAB item
		V.provider	   as ProviderNameId,
		IOC.Name	   as ProviderName,
		IOC.CID		   as ProviderCID,
		IOC.CTG		   as ProviderCTG,
		IOC.AID		   as ProviderAID,
		CAS.casnCaseID as casnCaseID,
		null		   as PlaintiffID
	from [Needles].[dbo].[value_Indexed] V
	join [sma_TRN_cases] CAS
		on cas.saga = v.case_id
	join IndvOrgContacts_Indexed IOC
		on IOC.SAGA = V.provider
			and ISNULL(V.provider, 0) <> 0
	where
		code in (
		 select
			 code
		 from [ValueCodeMap]
		 where [SA_Screen] = 'Special Damages'
		)

---
dbcc dbreindex ('value_tab_spDamages_Helper', ' ', 90) with no_infomsgs
go


--- value_tab_Multi_Party_Helper_Temp
if exists (
	 select
		 *
	 from sys.objects
	 where Name = 'value_tab_Multi_Party_Helper_Temp'
	)
begin
	drop table value_tab_Multi_Party_Helper_Temp
end

go

---
select
	V.case_id  as cid,
	V.value_id as vid,
	T.plnnPlaintiffID
into value_tab_Multi_Party_Helper_Temp
from [Needles].[dbo].[value_Indexed] V
join [sma_TRN_cases] CAS
	on cas.saga = v.case_id
join [IndvOrgContacts_Indexed] IOC
	on IOC.SAGA = V.party_id
join [sma_TRN_Plaintiff] T
	on T.plnnContactID = IOC.cid
		and T.plnnContactCtg = IOC.CTG
		and T.plnnCaseID = CAS.casnCaseID
go

---
update [value_tab_spDamages_Helper]
set PlaintiffID = A.plnnPlaintiffID
from value_tab_Multi_Party_Helper_Temp A
where case_id = A.CID
and value_id = A.vid
go

---
if exists (
	 select
		 *
	 from sys.objects
	 where Name = 'value_tab_Multi_Party_Helper_Temp'
	)
begin
	drop table value_tab_Multi_Party_Helper_Temp
end

go

---
select
	V.case_id  as cid,
	V.value_id as vid,
	(
	 select
		 plnnPlaintiffID
	 from [sma_TRN_Plaintiff]
	 where plnnCaseID = CAS.casnCaseID
		 and plnbIsPrimary = 1
	)		   as plnnPlaintiffID
into value_tab_Multi_Party_Helper_Temp
from [Needles].[dbo].[value_Indexed] V
join [sma_TRN_cases] CAS
	on cas.saga = v.case_id
join [IndvOrgContacts_Indexed] IOC
	on IOC.SAGA = V.party_id
join [sma_TRN_Defendants] D
	on D.defnContactID = IOC.cid
		and D.defnContactCtgID = IOC.CTG
		and D.defnCaseID = CAS.casnCaseID
go

---
update value_tab_spDamages_Helper
set PlaintiffID = A.plnnPlaintiffID
from value_tab_Multi_Party_Helper_Temp A
where case_id = A.CID
and value_id = A.vid
go

/* ------------------------------------------------------------------------------
Insert Damage Types
*/ ------------------------------------------------------------------------------
-- Create Special Damage Type "Other" if it doesn't exist
if (
	 select
		 COUNT(*)
	 from sma_MST_SpecialDamageType
	 where SpDamageTypeDescription = 'Other'
	) = 0
begin
	insert into sma_MST_SpecialDamageType
		(
			SpDamageTypeDescription,
			IsEditableType,
			SpDamageTypeCreatedUserID,
			SpDamageTypeDtCreated
		)
		select 'Other', 1, 368, GETDATE()
end

-- Insert Special Damage Sub Types from value_code under Type "Other"
insert into sma_MST_SpecialDamageSubType
	(
		SpDamageTypeID,
		SpDamageSubTypeDescription,
		SpDamageSubTypeDtCreated,
		SpDamageSubTypeCreatedUserID
	)
	select
		(
		 select
			 SpDamageTypeID
		 from sma_MST_SpecialDamageType
		 where SpDamageTypeDescription = 'Other'
		),
		vc.[description],
		GETDATE(),
		368
	from [Needles]..value_code vc
	where
		code in (
		 select
			 code
		 from [ValueCodeMap]
		 where [SA_Screen] = 'Special Damages'
		)

/* ------------------------------------------------------------------------------
Insert Special Damages
*/ ------------------------------------------------------------------------------
alter table [sma_TRN_SpDamages] disable trigger all
go

insert into [sma_TRN_SpDamages]
	(
		spdsRefTable,
		spdnRecordID,
		spddCaseID,
		spddPlaintiff,
		spddDamageType,
		spddDamageSubType,
		spdnRecUserID,
		spddDtCreated,
		spdnLevelNo,
		spdnBillAmt,
		spddDateFrom,
		spddDateTo,
		spdsComments,
		saga,
		source_id,
		source_db,
		source_ref
	)
	select distinct
		'CustomDamage'  as spdsRefTable,
		null			as spdnRecordID,
		SDH.casnCaseID  as spddCaseID,
		SDH.PlaintiffID as spddPlaintiff,
		(
		 select top 1
			 SpDamageTypeID
		 from sma_MST_SpecialDamageType
		 where SpDamageTypeDescription = 'Other'
		)				as spddDamageType,
		(
		 select top 1
			 SpDamageSubTypeID
		 from sma_MST_SpecialDamageSubType
		 where SpDamageSubTypeDescription = VC.[description]
			 and SpDamageTypeID = (
			  select
				  SpDamageTypeID
			  from sma_MST_SpecialDamageType
			  where SpDamageTypeDescription = 'Other'
			 )
		)				as spddDamageSubType,
		368				as spdnRecUserID,
		GETDATE()		as spddDtCreated,
		0				as spdnLevelNo,
		V.total_value   as spdnBillAmt,
		case
			when V.[start_date] between '1900-01-01' and '2079-06-01' then V.[start_date]
			else null
		end				as spddDateFrom,
		case
			when V.stop_date between '1900-01-01' and '2079-06-01' then V.stop_date
			else null
		end				as spddDateTo,
		'Provider: '
		+ SDH.[ProviderName]
		+ CHAR(13)
		+ V.memo		as spdsComments,
		V.value_id		as [saga],
		null			as [source_id],
		null			as [source_db],
		'value'			as [source_ref]
	from [Needles].[dbo].[value_Indexed] V
	join [Needles].[dbo].[value_Code] VC
		on V.code = VC.code
	join [value_tab_spDamages_Helper] SDH
		on V.value_id = SDH.value_id
	where
		V.code in (
		 select
			 code
		 from [ValueCodeMap]
		 where [SA_Screen] = 'Special Damages'
		)
go

alter table [sma_TRN_SpDamages] enable trigger all
go

