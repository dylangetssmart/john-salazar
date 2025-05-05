use [SA]
go

------------------------------------------------------------------------------------------------------
-- utility table to store the applicable value codes
------------------------------------------------------------------------------------------------------
begin

	if OBJECT_ID('conversion.value_lienTracking', 'U') is not null
	begin
		drop table conversion.value_lienTracking
	end

	create table conversion.value_lienTracking (
		code VARCHAR(25)
	);
	insert into conversion.value_lienTracking
		(
			code
		)
		values
		('LIEN'),
		('LIEN WC');
end


-------------------------------------------------------------------------------
-- [value_tab_Liencheckbox_Helper]
-------------------------------------------------------------------------------

---(0)---
if exists (
		select
			*
		from sys.objects
		where name = 'value_tab_Liencheckbox_Helper'
			and TYPE = 'U'
	)
begin
	drop table value_tab_Liencheckbox_Helper
end

go

---(0)---
create table value_tab_Liencheckbox_Helper (
	TableIndex INT identity (1, 1) not null,
	value_id   INT,
	constraint IOC_Clustered_Index_value_tab_Liencheckbox_Helper primary key clustered (TableIndex)
) on [PRIMARY]
create nonclustered index IX_NonClustered_Index_value_tab_Liencheckbox_Helper_value_id on [Needles].[dbo].[value_tab_Liencheckbox_Helper] (value_id);
go

---(0)---
insert into value_tab_Liencheckbox_Helper
	(
		value_id
	)
	select
		VP1.value_id
	from [Needles].[dbo].[value_payment] VP1
	left join (
		select distinct
			value_id
		from [Needles].[dbo].[value_payment]
		where lien = 'Y'
	) VP2
		on VP1.value_id = VP2.value_id
			and VP2.value_id is not null
	where
		VP2.value_id is not null -- ( Lien checkbox got marked ) 
go

---(0)---
dbcc dbreindex ('value_tab_Liencheckbox_Helper', ' ', 90) with no_infomsgs
go

---(0)---
if exists (
		select
			*
		from sys.objects
		where name = 'value_tab_Lien_Helper'
			and TYPE = 'U'
	)
begin
	drop table value_tab_Lien_Helper
end

go

---(0)---
create table value_tab_Lien_Helper (
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
	Paid		   VARCHAR(20),
	constraint IOC_Clustered_Index_value_tab_Lien_Helper primary key clustered (TableIndex)
) on [PRIMARY]
go

create nonclustered index IX_NonClustered_Index_value_tab_Lien_Helper_case_id on [value_tab_Lien_Helper] (case_id);
create nonclustered index IX_NonClustered_Index_value_tab_Lien_Helper_value_id on [value_tab_Lien_Helper] (value_id);
create nonclustered index IX_NonClustered_Index_value_tab_Lien_Helper_ProviderNameId on [value_tab_Lien_Helper] (ProviderNameId);
go

---(0)---
insert into value_tab_Lien_Helper
	(
		case_id,
		value_id,
		ProviderNameId,
		ProviderName,
		ProviderCID,
		ProviderCTG,
		ProviderAID,
		casnCaseID,
		PlaintiffID,
		Paid
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
		null		   as PlaintiffID,
		null		   as Paid
	from [Needles].[dbo].[value_Indexed] V
	inner join [sma_TRN_cases] CAS
		on CAS.cassCaseNumber = CONVERT(VARCHAR, V.case_id)
	inner join [IndvOrgContacts_Indexed] IOC
		on IOC.SAGA = V.provider
			and ISNULL(V.provider, 0) <> 0
	where
		code in (
			select
				code
			from conversion.value_lienTracking
		)
		or V.value_id in (
			select
				value_id
			from value_tab_Liencheckbox_Helper
		)

go

---(0)---
dbcc dbreindex ('value_tab_Lien_Helper', ' ', 90) with no_infomsgs
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
	CONVERT(VARCHAR, ((
		select
			SUM(payment_amount)
		from [Needles].[dbo].[value_payment]
		where value_id = V.value_id
	))
	)		   as Paid,
	T.plnnPlaintiffID
into value_tab_Multi_Party_Helper_Temp
from [Needles].[dbo].[value_Indexed] V
inner join [sma_TRN_cases] CAS
	on CAS.cassCaseNumber = CONVERT(VARCHAR, V.case_id)
inner join [IndvOrgContacts_Indexed] IOC
	on IOC.SAGA = V.party_id
inner join [sma_TRN_Plaintiff] T
	on T.plnnContactID = IOC.cid
		and T.plnnContactCtg = IOC.CTG
		and T.plnnCaseID = CAS.casnCaseID
go


update value_tab_Lien_Helper
set PlaintiffID = A.plnnPlaintiffID,
	Paid = A.Paid
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
	CONVERT(VARCHAR, ((
		select
			SUM(payment_amount)
		from [Needles].[dbo].[value_payment]
		where value_id = V.value_id
	))
	)		   as Paid,
	(
		select
			plnnPlaintiffID
		from [sma_TRN_Plaintiff]
		where plnnCaseID = CAS.casnCaseID
			and plnbIsPrimary = 1
	)		   as plnnPlaintiffID
into value_tab_Multi_Party_Helper_Temp
from [Needles].[dbo].[value_Indexed] V
inner join [sma_TRN_cases] CAS
	on CAS.cassCaseNumber = CONVERT(VARCHAR, V.case_id)
inner join [IndvOrgContacts_Indexed] IOC
	on IOC.SAGA = V.party_id
inner join [sma_TRN_Defendants] D
	on D.defnContactID = IOC.cid
		and D.defnContactCtgID = IOC.CTG
		and D.defnCaseID = CAS.casnCaseID
go


update value_tab_Lien_Helper
set PlaintiffID = A.plnnPlaintiffID,
	Paid = A.Paid
from value_tab_Multi_Party_Helper_Temp A
where case_id = A.cid
and value_id = A.vid
go