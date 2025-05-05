use [KurtYoung_SA]
go

-------------------------------------------------------------------------------
-- [#MedChargeCodes]
-------------------------------------------------------------------------------
--if OBJECT_ID('tempdb..#MedChargeCodes') is not null
--	drop table #MedChargeCodes;

--create table #MedChargeCodes (
--	code VARCHAR(10)
--);

--insert into #MedChargeCodes
--	(
--		code
--	)
--	values
--	('MEDICAL')

------------------------------------------------------------------------------------------------------
-- utility table to store the applicable value codes
------------------------------------------------------------------------------------------------------
begin
	if OBJECT_ID('conversion.value_medicalProviders', 'U') is not null
	begin
		drop table conversion.value_medicalProviders
	end

	create table conversion.value_medicalProviders (
		code VARCHAR(25)
	);
	insert into conversion.value_medicalProviders
		(
			code
		)
		values
		('MEDICAL');
end

-------------------------------------------------------------------------------
-- [value_tab_MedicalProvider_Helper]
-------------------------------------------------------------------------------
if exists (
		select
			*
		from sys.objects
		where name = 'value_tab_MedicalProvider_Helper'
			and type = 'U'
	)
begin
	drop table value_tab_MedicalProvider_Helper
end
go

---(0)---
create table value_tab_MedicalProvider_Helper (
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
	constraint IOC_Clustered_Index_value_tab_MedicalProvider_Helper primary key clustered (TableIndex)
) on [PRIMARY]
go

create nonclustered index IX_NonClustered_Index_value_tab_MedicalProvider_Helper_case_id on [value_tab_MedicalProvider_Helper] (case_id);
create nonclustered index IX_NonClustered_Index_value_tab_MedicalProvider_Helper_value_id on [value_tab_MedicalProvider_Helper] (value_id);
create nonclustered index IX_NonClustered_Index_value_tab_MedicalProvider_Helper_ProviderNameId on [value_tab_MedicalProvider_Helper] (ProviderNameId);
go

---(0)---
insert into value_tab_MedicalProvider_Helper
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
		V.case_id	   as case_id,	-- needles case
		V.value_id	   as tab_id,		-- needles records TAB item
		V.provider	   as ProviderNameId,
		IOC.Name	   as ProviderName,
		IOC.CID		   as ProviderCID,
		IOC.CTG		   as ProviderCTG,
		IOC.AID		   as ProviderAID,
		CAS.casnCaseID as casnCaseID,
		null		   as PlaintiffID
	from [KurtYoung_Needles].[dbo].[value_Indexed] V
	join [sma_TRN_cases] CAS
		on CAS.cassCaseNumber = V.case_id
	join IndvOrgContacts_Indexed IOC
		on IOC.SAGA = V.provider
			and ISNULL(V.provider, 0) <> 0
	where
		code in (
			select
				code
			from conversion.value_medicalProviders
		)
go

---(0)---
dbcc dbreindex ('value_tab_MedicalProvider_Helper', ' ', 90) with no_infomsgs
go


-------------------------------------------------------------------------------
-- [value_tab_Multi_Party_Helper_Temp]
-------------------------------------------------------------------------------

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
	V.case_id  as cid,
	V.value_id as vid,
	T.plnnPlaintiffID
into value_tab_Multi_Party_Helper_Temp
from [KurtYoung_Needles].[dbo].[value_Indexed] V
join [sma_TRN_cases] CAS
	on CAS.cassCaseNumber = V.case_id
join IndvOrgContacts_Indexed IOC
	on IOC.SAGA = V.party_id
join [sma_TRN_Plaintiff] T
	on T.plnnContactID = IOC.CID
		and T.plnnContactCtg = IOC.CTG
		and T.plnnCaseID = CAS.casnCaseID

update value_tab_MedicalProvider_Helper
set PlaintiffID = A.plnnPlaintiffID
from value_tab_Multi_Party_Helper_Temp A
where case_id = A.cid
and value_id = A.vid
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
	V.case_id  as cid,
	V.value_id as vid,
	(
		select
			plnnPlaintiffID
		from [KurtYoung_SA].[dbo].[sma_TRN_Plaintiff]
		where plnnCaseID = CAS.casnCaseID
			and plnbIsPrimary = 1
	)		   as plnnPlaintiffID
into value_tab_Multi_Party_Helper_Temp
from [KurtYoung_Needles].[dbo].[value_Indexed] V
join [sma_TRN_cases] CAS
	on CAS.cassCaseNumber = V.case_id
join [IndvOrgContacts_Indexed] IOC
	on IOC.SAGA = V.party_id
join [sma_TRN_Defendants] D
	on D.defnContactID = IOC.CID
		and D.defnContactCtgID = IOC.CTG
		and D.defnCaseID = CAS.casnCaseID
go

update value_tab_MedicalProvider_Helper
set PlaintiffID = A.plnnPlaintiffID
from value_tab_Multi_Party_Helper_Temp A
where case_id = A.cid
and value_id = A.vid
go