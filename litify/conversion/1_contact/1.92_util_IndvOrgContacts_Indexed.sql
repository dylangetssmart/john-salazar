/* ######################################################################################
description:
steps:
	-
usage_instructions:
	-
dependencies:
	- sma_MST_AllContactInfo
notes:
	-
######################################################################################
*/

use [ShinerSA]
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
	saga_char  VARCHAR(100),
	source_db  VARCHAR(MAX),
	source_ref VARCHAR(MAX)
	constraint IOC_Clustered_Index primary key clustered (TableIndex)
)
create nonclustered index IX_NonClustered_Index_IndvOrgContacts_Indexed_CID on IndvOrgContacts_Indexed (CID);
create nonclustered index IX_NonClustered_Index_IndvOrgContacts_Indexed_CTG on IndvOrgContacts_Indexed (CTG);
create nonclustered index IX_NonClustered_Index_IndvOrgContacts_Indexed_AID on IndvOrgContacts_Indexed (AID);
create nonclustered index IX_NonClustered_Index_IndvOrgContacts_Indexed_UNID on IndvOrgContacts_Indexed (UNQCID);
create nonclustered index IX_NonClustered_Index_IndvOrgContacts_Indexed_SAGA on IndvOrgContacts_Indexed (saga_char);
go

insert into IndvOrgContacts_Indexed
	(
		CID,
		CTG,
		AID,
		UNQCID,
		Name,
		saga_char,
		source_db,
		source_ref
	)
	select
		ioc.cid				as cid,
		ioc.ctg				as ctg,
		a.addnAddressID		as aid,
		acf.UniqueContactId as unqcid,
		LEFT(ioc.name, 100) as name,
		ioc.saga_char		as saga_char,
		ioc.source_db		as source_db,
		ioc.source_ref		as source_ref
	from (
		select
			cinnContactID					   as cid,
			cinnContactCtg					   as ctg,
			cinsFirstName + ' ' + cinsLastName as name,
			saga_char						   as saga_char,
			source_db						   as source_db,
			source_ref						   as source_ref
		from [sma_MST_IndvContacts]
		union
		select
			connContactID  as cid,
			connContactCtg as ctg,
			consName	   as name,
			saga_char	   as saga_char,
			source_db	   as source_db,
			source_ref	   as source_ref
		from [sma_MST_OrgContacts]
	) ioc
	join [sma_MST_Address] a
		on a.addnContactID = ioc.cid
			and a.addnContactCtgID = ioc.ctg
			and a.addbPrimary = 1
	join [sma_MST_AllContactInfo] acf
		on acf.ContactId = ioc.cid
			and acf.ContactCtg = ioc.ctg
go

dbcc dbreindex ('IndvOrgContacts_Indexed', ' ', 90) with no_infomsgs
go


