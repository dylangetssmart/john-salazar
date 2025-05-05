use KurtYoung_SA
go

/* ##############################################
Create temporary table to hold disbursement value codes
*/
if OBJECT_ID('tempdb..#SpDmgValueCodes') is not null
	drop table #SpDmgValueCodes;

create table #SpDmgValueCodes (
	code VARCHAR(10)
);

insert into #SpDmgValueCodes
	(
		code
	)
	values
	('MISC SPCLS'),
	('PROPERTY')


------------------------------------------------------------------------------------------------------
-- utility table to store the applicable value codes
------------------------------------------------------------------------------------------------------
begin
	if OBJECT_ID('conversion.value_specialDamage', 'U') is not null
	begin
		drop table conversion.value_specialDamage
	end

	create table conversion.value_specialDamage (
		code VARCHAR(25)
	);
	insert into conversion.value_specialDamage
		(
			code
		)
		values
		('MISC SPCLS'),
		('PROPERTY');
end

---(0)---
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

---(0)---
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

---(0)---
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
	from [KurtYoung_Needles].[dbo].[value_Indexed] V
	join [sma_TRN_cases] CAS
		on CAS.NeedlesCasenum = V.case_id
	-- on CAS.cassCaseNumber = V.case_id
	join IndvOrgContacts_Indexed IOC
		on IOC.SAGA = V.provider
			and ISNULL(V.provider, 0) <> 0
	where
		code in (
			select
				code
			from conversion.value_specialDamage vd
		)



---(0)---
dbcc dbreindex ('value_tab_spDamages_Helper', ' ', 90) with no_infomsgs
go


---(0)---
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
	V.case_id  as cid,
	V.value_id as vid,
	T.plnnPlaintiffID
into value_tab_Multi_Party_Helper_Temp
from [KurtYoung_Needles].[dbo].[value_Indexed] V
join [sma_TRN_cases] CAS
	on CAS.NeedlesCasenum = V.case_id
-- on CAS.cassCaseNumber = V.case_id
join [IndvOrgContacts_Indexed] IOC
	on IOC.SAGA = V.party_id
join [sma_TRN_Plaintiff] T
	on T.plnnContactID = IOC.cid
		and T.plnnContactCtg = IOC.CTG
		and T.plnnCaseID = CAS.casnCaseID
go

update [value_tab_spDamages_Helper]
set PlaintiffID = A.plnnPlaintiffID
from value_tab_Multi_Party_Helper_Temp A
where case_id = A.cid
and value_id = A.vid
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
from [KurtYoung_Needles].[dbo].[value_Indexed] V
join [sma_TRN_cases] CAS
	on CAS.NeedlesCasenum = V.case_id
-- on CAS.cassCaseNumber = V.case_id
join [IndvOrgContacts_Indexed] IOC
	on IOC.SAGA = V.party_id
join [sma_TRN_Defendants] D
	on D.defnContactID = IOC.cid
		and D.defnContactCtgID = IOC.CTG
		and D.defnCaseID = CAS.casnCaseID
go

update value_tab_spDamages_Helper
set PlaintiffID = A.plnnPlaintiffID
from value_tab_Multi_Party_Helper_Temp A
where case_id = A.cid
and value_id = A.vid
go