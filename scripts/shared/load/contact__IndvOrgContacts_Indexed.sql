/*---
description: Create [IndvOrgContacts_Indexed]

steps: >
  - Create table [IndvOrgContacts_Indexed]
  - Create indexes on [IndvOrgContacts_Indexed]
  - Insert individual contacts from [sma_MST_IndvContacts]
  - Fill out address information from [sma_MST_Address]
  - Fill out email information from [sma_MST_EmailWebsite]
  - Fill out phone information from [sma_MST_ContactNumbers]
  - Insert contact types from various sources into [sma_MST_ContactTypesForContact]

dependencies:
  - [sma_MST_IndvContacts]
  - [sma_MST_OrgContacts]
  - [sma_MST_Address]
  - [sma_MST_AllContactInfo]
  - [sma_MST_EmailWebsite]
  - [sma_MST_ContactNumbers]

notes: >
  - 
  
---*/

use [BrachEichler_SA]
go

if exists (
		select
			*
		from sys.objects
		where name = 'IndvOrgContacts_Indexed'
			and type = 'U'
	)
begin
	drop table IndvOrgContacts_Indexed
end
go

create table IndvOrgContacts_Indexed (
	TableIndex INT identity (1, 1) not null,
	CID		   INT,
	CTG		   INT,
	AID		   INT,
	UNQCID	   BIGINT,
	Name	   VARCHAR(100),
	SAGA	   VARCHAR(100),
	source_id  VARCHAR(MAX),
	source_db  VARCHAR(MAX),
	source_ref VARCHAR(MAX)
	constraint IOC_Clustered_Index primary key clustered (TableIndex)
)
create nonclustered index IX_NonClustered_Index_IndvOrgContacts_Indexed_CID on IndvOrgContacts_Indexed (CID);
go

create nonclustered index IX_NonClustered_Index_IndvOrgContacts_Indexed_CTG on IndvOrgContacts_Indexed (CTG);
go

create nonclustered index IX_NonClustered_Index_IndvOrgContacts_Indexed_AID on IndvOrgContacts_Indexed (AID);
go

create nonclustered index IX_NonClustered_Index_IndvOrgContacts_Indexed_UNID on IndvOrgContacts_Indexed (UNQCID);
go

create nonclustered index IX_NonClustered_Index_IndvOrgContacts_Indexed_SAGA on IndvOrgContacts_Indexed (SAGA);
go

insert into IndvOrgContacts_Indexed
	(
	CID, CTG, AID, UNQCID, Name, SAGA, source_id, source_db, source_ref
	)
	select
		IOC.CID				as CID,
		IOC.CTG				as CTG,
		A.addnAddressID		as AID,
		ACF.UniqueContactId as UNQCID,
		IOC.Name			as Name,
		IOC.SAGA			as SAGA,
		ioc.source_id		as source_id,
		ioc.source_db		as source_db,
		ioc.source_ref		as source_ref
	from (
		select
			cinnContactID					   as CID,
			cinnContactCtg					   as CTG,
			cinsFirstName + ' ' + cinsLastName as Name,
			saga							   as SAGA,
			source_id						   as source_id,
			source_db						   as source_db,
			source_ref						   as source_ref
		from [sma_MST_IndvContacts]
		union
		select
			connContactID  as CID,
			connContactCtg as CTG,
			consName	   as Name,
			saga		   as SAGA,
			source_id	   as source_id,
			source_db	   as source_db,
			source_ref	   as source_ref
		from [sma_MST_OrgContacts]
	) ioc
	join [sma_MST_Address] A
		on A.addnContactID = IOC.CID
			and A.addnContactCtgID = IOC.CTG
			and A.addbPrimary = 1
	join [sma_MST_AllContactInfo] ACF
		on ACF.ContactId = IOC.CID
			and ACF.ContactCtg = IOC.CTG
go

dbcc dbreindex ('IndvOrgContacts_Indexed', ' ', 90) with no_infomsgs
go


