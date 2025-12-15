/*---
description: Insert Disbursements from [value]
steps:
	1. Setup helper table with relevant id fields
	2. Insert Disbursement Types	[sma_MST_DisbursmentType]
	3. Insert Disbursements			[sma_TRN_Disbursement] 
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

exec AddBreadcrumbsToTable 'sma_TRN_Disbursement'
go


/* ------------------------------------------------------------------------------
Build helpers
*/ ------------------------------------------------------------------------------
if exists (
	 select
		 *
	 from sys.objects
	 where name = 'value_tab_Disbursement_Helper'
		 and type = 'U'
	)
begin
	drop table value_tab_Disbursement_Helper
end

go

create table value_tab_Disbursement_Helper (
	TableIndex	   [INT] identity (1, 1) not null,
	case_id		   INT,
	value_id	   INT,
	ProviderNameId INT,
	ProviderName   VARCHAR(200),
	ProviderCID	   INT,
	ProviderCTG	   INT,
	ProviderAID	   INT,
	ProviderUID	   BIGINT,
	casnCaseID	   INT,
	PlaintiffID	   INT,
	constraint IOC_Clustered_Index_value_tab_Disbursement_Helper primary key clustered (TableIndex)
) on [PRIMARY]
go

create nonclustered index IX_NonClustered_Index_value_tab_Disbursement_Helper_case_id on [value_tab_Disbursement_Helper] (case_id);
create nonclustered index IX_NonClustered_Index_value_tab_Disbursement_Helper_value_id on [value_tab_Disbursement_Helper] (value_id);
create nonclustered index IX_NonClustered_Index_value_tab_Disbursement_Helper_ProviderNameId on [value_tab_Disbursement_Helper] (ProviderNameId);
go

---(0)---
insert into value_tab_Disbursement_Helper
	(
		case_id,
		value_id,
		ProviderNameId,
		ProviderName,
		ProviderCID,
		ProviderCTG,
		ProviderAID,
		ProviderUID,
		casnCaseID,
		PlaintiffID
	)
	select
		v.case_id	   as case_id,	        -- needles case
		v.value_id	   as tab_id,		    -- needles records TAB item
		v.provider	   as providernameid,
		ioc.Name	   as providername,
		ioc.CID		   as providercid,
		ioc.CTG		   as providerctg,
		ioc.AID		   as provideraid,
		ioc.UNQCID	   as provideruid,
		cas.casnCaseID as casncaseid,
		null		   as plaintiffid
	from [Needles].[dbo].[value_Indexed] v
	join [sma_TRN_cases] cas
		on cas.saga = v.case_id
	join IndvOrgContacts_Indexed ioc
		on ioc.SAGA = v.provider
			and ISNULL(v.provider, 0) <> 0
	where
		code in (
		 select
			 code
		 from [ValueCodeMap]
		 where [SA_Screen] = 'Disbursements'
		);
go

---(0)---
dbcc dbreindex ('value_tab_Disbursement_Helper', ' ', 90) with no_infomsgs
go


---(0)--- value_id may associate with secondary plaintiff
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

select
	v.case_id  as cid,
	v.value_id as vid,
	t.plnnPlaintiffID
into value_tab_Multi_Party_Helper_Temp
from [Needles].[dbo].[value_Indexed] v
join [sma_TRN_cases] cas
	on cas.saga = v.case_id
join IndvOrgContacts_Indexed ioc
	on ioc.SAGA = v.party_id
join [sma_TRN_Plaintiff] t
	on t.plnnContactID = ioc.cid
		and t.plnnContactCtg = ioc.CTG
		and t.plnnCaseID = cas.casnCaseID

update value_tab_Disbursement_Helper
set PlaintiffID = a.plnnPlaintiffID
from value_tab_Multi_Party_Helper_Temp a
where case_id = a.CID
and value_id = a.vid
go

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

select
	v.case_id  as cid,
	v.value_id as vid,
	(
	 select
		 plnnPlaintiffID
	 from sma_TRN_Plaintiff
	 where plnnCaseID = cas.casnCaseID
		 and plnbIsPrimary = 1
	)		   as plnnplaintiffid
into value_tab_Multi_Party_Helper_Temp
from [Needles].[dbo].[value_Indexed] v
join [sma_TRN_cases] cas
	on cas.saga = v.case_id
join [IndvOrgContacts_Indexed] ioc
	on ioc.SAGA = v.party_id
join [sma_TRN_Defendants] d
	on d.defnContactID = ioc.cid
		and d.defnContactCtgID = ioc.CTG
		and d.defnCaseID = cas.casnCaseID
go

update value_tab_Disbursement_Helper
set PlaintiffID = a.plnnPlaintiffID
from value_tab_Multi_Party_Helper_Temp a
where case_id = a.CID
and value_id = a.vid
go

/* ------------------------------------------------------------------------------
Insert Disbursement Types
*/ ------------------------------------------------------------------------------
insert into [sma_MST_DisbursmentType]
	(
		disnTypeCode,
		dissTypeName
	)
	(
	select distinct
		'CONVERSION',
		vc.[description]
	from [Needles].[dbo].[value] v
	join [Needles].[dbo].[value_code] vc
		on vc.code = v.code
	where ISNULL(v.code, '') in (
		 select
			 code
		 from [ValueCodeMap]
		 where SAScreen = 'Disbursements'
		))
	except
	select
		'CONVERSION',
		dissTypeName
	from [sma_MST_DisbursmentType]
go

/* ------------------------------------------------------------------------------
Insert Disbursements from [value]
*/ ------------------------------------------------------------------------------
alter table [sma_TRN_Disbursement] disable trigger all
go

insert into [sma_TRN_Disbursement]
	(
		disnCaseID,
		disdCheckDt,
		disnPayeeContactCtgID,
		disnPayeeContactID,
		disnAmount,
		disnPlaintiffID,
		dissDisbursementType,
		UniquePayeeID,
		dissDescription,
		dissComments,
		disnCheckRequestStatus,
		disdBillDate,
		disdDueDate,
		disnRecUserID,
		disdDtCreated,
		disnRecoverable,
		saga,
		source_id,
		source_db,
		source_ref
	)
	select
		map.casnCaseID  as disncaseid,
		null			as disdcheckdt,
		map.ProviderCTG as disnpayeecontactctgid,
		map.ProviderCID as disnpayeecontactid,
		v.total_value   as disnamount,
		map.PlaintiffID as disnplaintiffid,
		(
		 select
			 disnTypeID
		 from [sma_MST_DisbursmentType]
		 where dissTypeName = (
			  select
				  [description]
			  from [Needles].[dbo].[value_code]
			  where [code] = v.code
			 )
		)				as dissdisbursementtype,
		map.ProviderUID as uniquepayeeid,
		v.[memo]		as dissdescription,
		null			as dissComments,
		(
		 select
			 Id
		 from [sma_MST_CheckRequestStatus]
		 where [Description] = 'Paid'
		)				as disncheckrequeststatus,
		case
			when v.start_date between '1900-01-01' and '2079-06-06' then v.start_date
			else null
		end				as disdbilldate,
		case
			when v.stop_date between '1900-01-01' and '2079-06-06' then v.stop_date
			else null
		end				as disdduedate,
		(
		 select
			 usrnUserID
		 from sma_MST_Users
		 where source_id = v.staff_created
		)				as disnrecuserid,
		case
			when date_created between '1900-01-01' and '2079-06-06' then date_created
			else null
		end				as disddtcreated,
		case
			when v.code = 'DTF' then 1
			else 0
		end				as disnrecoverable,
		v.value_id		as saga,
		null			as source_id,
		'needles'		as source_db,
		'value_indexed' as source_ref
	from [Needles].[dbo].[value_Indexed] v
	join value_tab_Disbursement_Helper map
		on map.case_id = v.case_id
			and map.value_id = v.value_id
go

alter table [sma_TRN_Disbursement] enable trigger all
go
---