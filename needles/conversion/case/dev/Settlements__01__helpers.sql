use [JohnSalazar_SA]
go

------------------------------------------------------------------------------------------------------
-- utility table to store the applicable value codes
------------------------------------------------------------------------------------------------------
begin
	if OBJECT_ID('conversion.value_settlements', 'U') is not null
	begin
		drop table conversion.value_settlements
	end

	create table conversion.value_settlements (
		code VARCHAR(25)
	);
	insert into conversion.value_settlements
		(
			code
		)
		values
		('FEE'),
		('SET');
end

---(0)---
if exists (
		select
			*
		from sys.objects
		where name = 'value_tab_Settlement_Helper'
			and type = 'U'
	)
begin
	drop table value_tab_Settlement_Helper
end
go

---(0)---
create table value_tab_Settlement_Helper (
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
	constraint IOC_Clustered_Index_value_tab_Settlement_Helper primary key clustered (TableIndex)
) on [PRIMARY]
go

create nonclustered index IX_NonClustered_Index_value_tab_Settlement_Helper_case_id on [value_tab_Settlement_Helper] (case_id);
create nonclustered index IX_NonClustered_Index_value_tab_Settlement_Helper_value_id on [value_tab_Settlement_Helper] (value_id);
create nonclustered index IX_NonClustered_Index_value_tab_Settlement_Helper_ProviderNameId on [value_tab_Settlement_Helper] (ProviderNameId);
create nonclustered index IX_NonClustered_Index_value_tab_Settlement_Helper_PlaintiffID on [value_tab_Settlement_Helper] (PlaintiffID);
go

---(0)---
insert into value_tab_Settlement_Helper
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
		v.case_id	   as case_id,	-- needles case
		v.value_id	   as tab_id,		-- needles records TAB item
		v.provider	   as providernameid,
		ioc.Name	   as providername,
		ioc.CID		   as providercid,
		ioc.CTG		   as providerctg,
		ioc.AID		   as provideraid,
		cas.casncaseid as casncaseid,
		null		   as plaintiffid
	from [JohnSalazar_Needles].[dbo].[value_Indexed] v
	join [sma_TRN_cases] cas
		on cas.cassCaseNumber = v.case_id
	join IndvOrgContacts_Indexed ioc
		on ioc.SAGA = v.provider
			and ISNULL(v.provider, 0) <> 0
	where
		code in (
			select
				code
			from conversion.value_settlements
		);
go

---(0)---
dbcc dbreindex ('value_tab_Settlement_Helper', ' ', 90) with no_infomsgs
go


---(0)--- (prepare for multiple party)
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
from [JohnSalazar_Needles].[dbo].[value_Indexed] v
join [sma_TRN_cases] cas
	on cas.cassCaseNumber = v.case_id
join [IndvOrgContacts_Indexed] ioc
	on ioc.SAGA = v.party_id
join [sma_TRN_Plaintiff] t
	on t.plnnContactID = ioc.cid
		and t.plnnContactCtg = ioc.CTG
		and t.plnnCaseID = cas.casnCaseID
go

update value_tab_Settlement_Helper
set PlaintiffID = a.plnnPlaintiffID
from value_tab_Multi_Party_Helper_Temp a
where case_id = a.cid
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
			plnnplaintiffid
		from [sma_TRN_Plaintiff]
		where plnnCaseID = cas.casnCaseID
			and plnbIsPrimary = 1
	)		   as plnnplaintiffid
into value_tab_Multi_Party_Helper_Temp
from [JohnSalazar_Needles].[dbo].[value_Indexed] v
join [sma_TRN_cases] cas
	on cas.cassCaseNumber = v.case_id
join [IndvOrgContacts_Indexed] ioc
	on ioc.SAGA = v.party_id
join [sma_TRN_Defendants] d
	on d.defnContactID = ioc.cid
		and d.defnContactCtgID = ioc.CTG
		and d.defnCaseID = cas.casnCaseID
go

update value_tab_Settlement_Helper
set PlaintiffID = a.plnnPlaintiffID
from value_tab_Multi_Party_Helper_Temp a
where case_id = a.cid
and value_id = a.vid
go