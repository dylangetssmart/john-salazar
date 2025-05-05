use [SA]
go

/* ##############################################
Create temporary table to hold disbursement value codes
*/
--if OBJECT_ID('tempdb..#DisbursementValueCodes') is not null
--	drop table #DisbursementValueCodes;

--create table #DisbursementValueCodes (
--	code VARCHAR(10)
--);

--insert into #DisbursementValueCodes
--	(
--		code
--	)
--	values
--	('MSC'),
--	('DTF')

------------------------------------------------------------------------------------------------------
-- utility table to store the applicable value codes
------------------------------------------------------------------------------------------------------
begin
	if OBJECT_ID('conversion.value_disbursements', 'U') is not null
	begin
		drop table conversion.value_disbursements
	end

	create table conversion.value_disbursements (
		code VARCHAR(25)
	);
	insert into conversion.value_disbursements
		(
			code
		)
		values
		('MSC'),
		('DTF');
end

/* --------------------------------------------------------------------------------------------------------------
Create Disbursement helper table
*/

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
		cas.casncaseid as casncaseid,
		null		   as plaintiffid
	from [KurtYoung_Needles].[dbo].[value_Indexed] v
	join [sma_TRN_cases] cas
		on cas.cassCaseNumber = v.case_id
	join IndvOrgContacts_Indexed ioc
		on ioc.SAGA = v.provider
			and ISNULL(v.provider, 0) <> 0
	where
		code in (
			select
				code
			from conversion.value_disbursements
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
from [KurtYoung_Needles].[dbo].[value_Indexed] v
join [sma_TRN_cases] cas
	on cas.cassCaseNumber = v.case_id
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

---(0)--- value_id may associate with defendant. steve malman make it associates to primary plaintiff 
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
			plnnplaintiffid
		from sma_TRN_Plaintiff
		where plnnCaseID = cas.casnCaseID
			and plnbIsPrimary = 1
	)		   as plnnplaintiffid
into value_tab_Multi_Party_Helper_Temp
from [KurtYoung_Needles].[dbo].[value_Indexed] v
join [sma_TRN_cases] cas
	on cas.cassCaseNumber = v.case_id
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
