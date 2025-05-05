/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-11-07
Description: Create employment records and corresponding lost wage records

##########################################################################################################################
*/


use [JohnSalazar_SA]
go

/* ##############################################
Store applicable value codes
*/
if OBJECT_ID('tempdb..#NegSetValueCodes') is not null
	drop table #NegSetValueCodes;

create table #NegSetValueCodes (
	code VARCHAR(10)
);

insert into #NegSetValueCodes
	(
	code
	)
values (
	   'MPP'
	   ),
	   (
'VER'
),
	   (
'SET'
);

-- ds 2024-11-07 update value codes
--('ATT'),
--('MPP'),
--('PIP'),
--('SET'),
--('SUB');


/*
alter table [sma_TRN_Settlements] disable trigger all
delete [sma_TRN_Settlements]
DBCC CHECKIDENT ('[sma_TRN_Settlements]', RESEED, 1);
alter table [sma_TRN_Settlements] enable trigger all
*/

--select distinct code, description from [JohnSalazar_Needles].[dbo].[value] order by code
---(0)---
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and Object_ID = OBJECT_ID(N'sma_TRN_Settlements')
	)
begin
	alter table [sma_TRN_Settlements] add [saga] VARCHAR(100) null;
end
go

---(0)---
------------------------------------------------
--INSERT SETTLEMENT TYPES
------------------------------------------------
insert into [sma_MST_SettlementType]
	(
	SettlTypeName
	)
	select
		'Settlement Recovery'
	union
	select
		'MedPay'
	union
	select
		'Paid To Client'
	except
	select
		SettlTypeName
	from [sma_MST_SettlementType]
go


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
	where code in (
			select
				code
			from #NegSetValueCodes
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
set PlaintiffID = A.plnnPlaintiffID
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
set PlaintiffID = A.plnnPlaintiffID
from value_tab_Multi_Party_Helper_Temp a
where case_id = a.cid
and value_id = a.vid
go

----(1)----(  specified items go to settlement rows )
alter table [sma_TRN_Settlements] disable trigger all
go

insert into [sma_TRN_Settlements]
	(
	stlnCaseID,
	stlnSetAmt,
	stlnNet,
	stlnNetToClientAmt,
	stlnPlaintiffID,
	stlnStaffID,
	stlnLessDisbursement,
	stlnGrossAttorneyFee,
	stlnForwarder,  --referrer
	stlnOther,
	InterestOnDisbursement,
	stlsComments,
	stlTypeID,
	stldSettlementDate,
	saga,
	stlbTakeMedPay		-- "Take Fee"
	)
	select
		map.casnCaseID  as stlncaseid,

		case
			when v.code in ('MPP', 'SET')
				then v.total_value
		end				as stlnsetamt,
		null			as stlnnet,
		null			as stlnnettoclientamt,
		map.PlaintiffID as stlnplaintiffid,
		null			as stlnstaffid,
		null			as stlnlessdisbursement,
		case
			when v.code in ('VER')
				then v.total_value
		end				as stlngrossattorneyfee,
		null			as stlnforwarder,		-- Referrer
		null			as stlnother,
		null			as interestondisbursement,
		ISNULL('memo:' + NULLIF(v.memo, '') + CHAR(13), '')
		+ ISNULL('code:' + NULLIF(v.code, '') + CHAR(13), '')
		+ ''			as [stlscomments],
		case
			when v.code in ('VER')
				then (
						select
							ID
						from [sma_MST_SettlementType]
						where SettlTypeName = 'Verdict'
					--case
					--		when v.[code] in ('SET')
					--			then 'Settlement Recovery'
					--		when v.[code] in ('MP')
					--			then 'MedPay'
					--		when v.[code] in ('PTC')
					--			then 'Paid To Client'
					--		when v.[code] in ('VER')		-- VER > Fees Awarded
					--			then 'Verdict'
					--	end
					)
		end				as stltypeid,
		case
			when v.[start_date] between '1900-01-01' and '2079-06-06'
				then v.[start_date]
			else null
		end				as stldsettlementdate,
		v.value_id		as saga,
		case
			when v.code = 'MPP'
				then 1
			else 0
		end				as stlbtakemedpay		-- ds 2024-11-07 "Take Fee"
	from [JohnSalazar_Needles].[dbo].[value_Indexed] v
	join value_tab_Settlement_Helper map
		on map.case_id = v.case_id
			and map.value_id = v.value_id
	where v.code in (
			select
				code
			from #NegSetValueCodes
		)
go

alter table [sma_TRN_Settlements] enable trigger all
go