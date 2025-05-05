/* ###################################################################################
description: Insert defendants
steps:
	- Update schema > [sma_TRN_InsuranceCoverage]
	- Construct [conversion].[insurance_contacts_helper]
	- Create insurance types from [needles].[insurance].[policy_type] > [sma_MST_InsuranceType]
usage_instructions:
	- 
dependencies:
	- 
notes:
	-
*/

use [KurtYoung_SA]
go

-------------------------------------------------------------------------------
-- Update schema
-------------------------------------------------------------------------------

if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and object_id = OBJECT_ID(N'sma_TRN_InsuranceCoverage')
	)
begin
	alter table [sma_TRN_InsuranceCoverage]
	add [saga] INT null;
end


-- source_id
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and Object_ID = OBJECT_ID(N'sma_TRN_InsuranceCoverage')
	)
begin
	alter table [sma_TRN_InsuranceCoverage] add [source_id] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and Object_ID = OBJECT_ID(N'sma_TRN_InsuranceCoverage')
	)
begin
	alter table [sma_TRN_InsuranceCoverage] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and Object_ID = OBJECT_ID(N'sma_TRN_InsuranceCoverage')
	)
begin
	alter table [sma_TRN_InsuranceCoverage] add [source_ref] VARCHAR(MAX) null;
end
go


-------------------------------------------------------------------------------
-- Build conversion.insurance_contacts_helper
-------------------------------------------------------------------------------
--if exists (
--		select
--			*
--		from sys.objects
--		where name = 'insurance_contacts_helper'
--			and type = 'U'
--			and schema_id
--	)
--begin
--	drop table conversion.insurance_contacts_helper
--end
--go

if OBJECT_ID('conversion.insurance_contacts_helper', 'U') is not null
	begin
		drop table conversion.insurance_contacts_helper
	end

create table conversion.insurance_contacts_helper (
	tableIndex			 INT identity (1, 1) not null,
	insurance_id		 INT,					-- table id
	insurer_id			 INT,					-- insurance company
	adjuster_id			 INT,					-- adjuster
	insured				 VARCHAR(100),			-- a person or organization covered by insurance
	incnInsContactID	 INT,
	incnInsAddressID	 INT,
	incnAdjContactId	 INT,
	incnAdjAddressID	 INT,
	incnInsured			 INT,
	pord				 VARCHAR(1),
	caseID				 INT,
	PlaintiffDefendantID INT 
	constraint IX_Insurance_Contacts_Helper primary key clustered
	(
	tableIndex
	) with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on, fillfactor = 80) on [PRIMARY]
) on [PRIMARY]
go

create nonclustered index IX_NonClustered_Index_insurance_id on conversion.insurance_contacts_helper (insurance_id);
go

create nonclustered index IX_NonClustered_Index_insurer_id on conversion.insurance_contacts_helper (insurer_id);
go

create nonclustered index IX_NonClustered_Index_adjuster_id on conversion.insurance_contacts_helper (adjuster_id);
go

---(0)---
insert into conversion.insurance_contacts_helper
	(
	insurance_id,
	insurer_id,
	adjuster_id,
	insured,
	incnInsContactID,
	incnInsAddressID,
	incnAdjContactId,
	incnAdjAddressID,
	incnInsured,
	pord,
	caseID,
	PlaintiffDefendantID
	)
	select
		ins.insurance_id,
		ins.insurer_id,
		ins.adjuster_id,
		ins.insured,
		ioc1.CID			 as incninscontactid,
		ioc1.AID			 as incninsaddressid,
		ioc2.CID			 as incnadjcontactid,
		ioc2.AID			 as incnadjaddressid,
		info.UniqueContactId as incninsured,
		null				 as pord,
		cas.casnCaseID		 as caseid,
		null				 as plaintiffdefendantid
	--select *
	from KurtYoung_Needles.[dbo].[insurance_Indexed] ins
	join [sma_TRN_Cases] cas
		on cas.cassCaseNumber = ins.case_num
	join IndvOrgContacts_Indexed ioc1
		on ioc1.saga = ins.insurer_id
			and ISNULL(ins.insurer_id, 0) <> 0
			and ioc1.CTG = 2
	left join IndvOrgContacts_Indexed ioc2
		on ioc2.saga = ins.adjuster_id
			and ISNULL(ins.adjuster_id, 0) <> 0
	join [sma_MST_IndvContacts] i
		on i.cinsLastName = ins.insured
			and i.source_id = ins.insured
			and i.source_ref = 'insured'
	join [sma_MST_AllContactInfo] info
		on info.ContactId = i.cinnContactID
			and info.ContactCtg = i.cinnContactCtg
go

dbcc dbreindex ('conversion.insurance_contacts_helper', ' ', 90) with no_infomsgs
go

-------------------------------------------------------------------------------
-- Build conversion.multi_party_helper
-------------------------------------------------------------------------------
if object_id('conversion.multi_party_helper') is not null
begin
	drop table conversion.multi_party_helper
end
go

-- Seed multi_party_helper with plaintiff id's
select
	ins.insurance_id as ins_id,
	t.plnnPlaintiffID
into conversion.multi_party_helper
--select *
from KurtYoung_Needles.[dbo].[insurance_Indexed] ins
join [sma_TRN_cases] cas
	on cas.cassCaseNumber = ins.case_num
join [IndvOrgContacts_Indexed] ioc
	on ioc.SAGA = ins.party_id
join [sma_TRN_Plaintiff] t
	on t.plnnContactID = ioc.CID
		and t.plnnContactCtg = ioc.CTG
		and t.plnnCaseID = cas.casnCaseID
go

-- update insurance_contacts_helper.pord = P using multi_party_helper
update conversion.insurance_contacts_helper
set pord = 'P',
	PlaintiffDefendantID = A.plnnPlaintiffID
from conversion.multi_party_helper a
where a.ins_id = insurance_id
go

-- drop multi_party_helper
if object_id('conversion.multi_party_helper') is not null
begin
	drop table conversion.multi_party_helper
end
go

-- Seed multi_party_helper with defendant id's
select
	ins.insurance_id as ins_id,
	d.defnDefendentID
into conversion.multi_party_helper
from KurtYoung_Needles.[dbo].[insurance_Indexed] ins
join [sma_TRN_cases] cas
	on cas.cassCaseNumber = ins.case_num
join [IndvOrgContacts_Indexed] ioc
	on ioc.SAGA = ins.party_id
join [sma_TRN_Defendants] d
	on d.defnContactID = ioc.CID
		and d.defnContactCtgID = ioc.CTG
		and d.defnCaseID = cas.casnCaseID
go

-- update insurance_contacts_helper.pord = D using multi_party_helper
update conversion.insurance_contacts_helper
set pord = 'D',
	PlaintiffDefendantID = A.defnDefendentID
from conversion.multi_party_helper a
where a.ins_id = insurance_id
go

-------------------------------------------------------------------------------
-- Insurance Types
-------------------------------------------------------------------------------
insert into [sma_MST_InsuranceType]
	(
	intsDscrptn
	)
	select
		'Unspecified'
	union
	select distinct
		policy_type
	from KurtYoung_Needles.[dbo].[insurance] ins
	where ISNULL(policy_type, '') <> ''
	except
	select
		intsDscrptn
	from [sma_MST_InsuranceType]
go

--select * from [sma_MST_InsuranceType]
--select distinct i.policy_type from KurtYoung_Needles..insurance i