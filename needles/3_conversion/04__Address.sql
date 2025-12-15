/*---
description: Insert Addresses
steps:
instructions:
dependencies:
notes: >
---*/


use [SA]
go


---
alter table [sma_MST_Address] disable trigger all
go

exec AddBreadcrumbsToTable 'sma_MST_Address'
go

---

/* ------------------------------------------------------------------------------
Individual Contact Addresses
*/ ------------------------------------------------------------------------------

-- Home from IndvContacts
insert into [sma_MST_Address]
	(
		[addnContactCtgID],
		[addnContactID],
		[addnAddressTypeID],
		[addsAddressType],
		[addsAddTypeCode],
		[addsAddress1],
		[addsAddress2],
		[addsAddress3],
		[addsStateCode],
		[addsCity],
		[addnZipID],
		[addsZip],
		[addsCounty],
		[addsCountry],
		[addbIsResidence],
		[addbPrimary],
		[adddFromDate],
		[adddToDate],
		[addnCompanyID],
		[addsDepartment],
		[addsTitle],
		[addnContactPersonID],
		[addsComments],
		[addbIsCurrent],
		[addbIsMailing],
		[addnRecUserID],
		[adddDtCreated],
		[addnModifyUserID],
		[adddDtModified],
		[addnLevelNo],
		[caseno],
		[addbDeleted],
		[addsZipExtn],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		i.cinnContactCtg	   as addncontactctgid,
		i.cinnContactID		   as addncontactid,
		t.addnAddTypeID		   as addnaddresstypeid,
		t.addsDscrptn		   as addsaddresstype,
		t.addsCode			   as addsaddtypecode,
		a.[address]			   as addsaddress1,
		a.[address_2]		   as addsaddress2,
		null				   as addsaddress3,
		a.[state]			   as addsstatecode,
		a.[city]			   as addscity,
		null				   as addnzipid,
		a.[zipcode]			   as addszip,
		a.[county]			   as addscounty,
		a.[country]			   as addscountry,
		null				   as addbisresidence,
		case
			when a.[default_addr] = 'Y' then 1
			else 0
		end					   as addbprimary,
		null,
		null,
		null,
		null,
		null,
		null,
		case
			when ISNULL(a.company, '') <> '' then (
					'Company : ' + CHAR(13) + a.company
					)
			else ''
		end					   as [addscomments],
		null,
		null,
		368					   as addnrecuserid,
		GETDATE()			   as addddtcreated,
		368					   as addnmodifyuserid,
		GETDATE()			   as addddtmodified,
		null,
		null,
		null,
		null,
		a.names_id			   as [saga],
		null				   as [source_id],
		'needles'			   as [source_db],
		'multi_addresses.home' as [source_ref]
	from [Needles].[dbo].[multi_addresses] a
	join [sma_MST_Indvcontacts] i
		on i.saga = a.names_id
	join [sma_MST_AddressTypes] t
		on t.addnContactCategoryID = i.cinnContactCtg
			and t.addsCode = 'HM'
	where
		(   a.[addr_type] = 'Home'
			and
			(   ISNULL(a.[address], '') <> ''
				or
				ISNULL(a.[address_2], '') <> ''
				or
				ISNULL(a.[city], '') <> ''
				or
				ISNULL(a.[state], '') <> ''
				or
				ISNULL(a.[zipcode], '') <> ''
				or
				ISNULL(a.[county], '') <> ''
				or
				ISNULL(a.[country], '') <> ''))
go

-- Business from IndvContacts
insert into [sma_MST_Address]
	(
		[addnContactCtgID],
		[addnContactID],
		[addnAddressTypeID],
		[addsAddressType],
		[addsAddTypeCode],
		[addsAddress1],
		[addsAddress2],
		[addsAddress3],
		[addsStateCode],
		[addsCity],
		[addnZipID],
		[addsZip],
		[addsCounty],
		[addsCountry],
		[addbIsResidence],
		[addbPrimary],
		[adddFromDate],
		[adddToDate],
		[addnCompanyID],
		[addsDepartment],
		[addsTitle],
		[addnContactPersonID],
		[addsComments],
		[addbIsCurrent],
		[addbIsMailing],
		[addnRecUserID],
		[adddDtCreated],
		[addnModifyUserID],
		[adddDtModified],
		[addnLevelNo],
		[caseno],
		[addbDeleted],
		[addsZipExtn],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		i.cinnContactCtg		   as addncontactctgid,
		i.cinnContactID			   as addncontactid,
		t.addnAddTypeID			   as addnaddresstypeid,
		t.addsDscrptn			   as addsaddresstype,
		t.addsCode				   as addsaddtypecode,
		a.[address]				   as addsaddress1,
		a.[address_2]			   as addsaddress2,
		null					   as addsaddress3,
		a.[state]				   as addsstatecode,
		a.[city]				   as addscity,
		null					   as addnzipid,
		a.[zipcode]				   as addszip,
		a.[county]				   as addscounty,
		a.[country]				   as addscountry,
		null					   as addbisresidence,
		case
			when a.[default_addr] = 'Y' then 1
			else 0
		end						   as addbprimary,
		null,
		null,
		null,
		null,
		null,
		null,
		case
			when ISNULL(a.company, '') <> '' then (
					'Company : ' + CHAR(13) + a.company
					)
			else ''
		end						   as [addscomments],
		null,
		null,
		368						   as addnrecuserid,
		GETDATE()				   as addddtcreated,
		368						   as addnmodifyuserid,
		GETDATE()				   as addddtmodified,
		null,
		null,
		null,
		null,
		a.names_id				   as [saga],
		null					   as [source_id],
		'needles'				   as [source_db],
		'multi_addresses.business' as [source_ref]
	from [Needles].[dbo].[multi_addresses] a
	join [sma_MST_Indvcontacts] i
		on i.saga = a.names_id
	join [sma_MST_AddressTypes] t
		on t.addnContactCategoryID = i.cinnContactCtg
			and t.addsCode = 'WORK'
	where
		(   a.[addr_type] = 'Business'
			and
			(   ISNULL(a.[address], '') <> ''
				or
				ISNULL(a.[address_2], '') <> ''
				or
				ISNULL(a.[city], '') <> ''
				or
				ISNULL(a.[state], '') <> ''
				or
				ISNULL(a.[zipcode], '') <> ''
				or
				ISNULL(a.[county], '') <> ''
				or
				ISNULL(a.[country], '') <> ''))
go

-- Other from IndvContacts
insert into [sma_MST_Address]
	(
		[addnContactCtgID],
		[addnContactID],
		[addnAddressTypeID],
		[addsAddressType],
		[addsAddTypeCode],
		[addsAddress1],
		[addsAddress2],
		[addsAddress3],
		[addsStateCode],
		[addsCity],
		[addnZipID],
		[addsZip],
		[addsCounty],
		[addsCountry],
		[addbIsResidence],
		[addbPrimary],
		[adddFromDate],
		[adddToDate],
		[addnCompanyID],
		[addsDepartment],
		[addsTitle],
		[addnContactPersonID],
		[addsComments],
		[addbIsCurrent],
		[addbIsMailing],
		[addnRecUserID],
		[adddDtCreated],
		[addnModifyUserID],
		[adddDtModified],
		[addnLevelNo],
		[caseno],
		[addbDeleted],
		[addsZipExtn],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		i.cinnContactCtg		as addncontactctgid,
		i.cinnContactID			as addncontactid,
		t.addnAddTypeID			as addnaddresstypeid,
		t.addsDscrptn			as addsaddresstype,
		t.addsCode				as addsaddtypecode,
		a.[address]				as addsaddress1,
		a.[address_2]			as addsaddress2,
		null					as addsaddress3,
		a.[state]				as addsstatecode,
		a.[city]				as addscity,
		null					as addnzipid,
		a.[zipcode]				as addszip,
		a.[county]				as addscounty,
		a.[country]				as addscountry,
		null					as addbisresidence,
		case
			when a.[default_addr] = 'Y' then 1
			else 0
		end						as addbprimary,
		null,
		null,
		null,
		null,
		null,
		null,
		case
			when ISNULL(a.company, '') <> '' then (
					'Company : ' + CHAR(13) + a.company
					)
			else ''
		end						as [addscomments],
		null,
		null,
		368						as addnrecuserid,
		GETDATE()				as addddtcreated,
		368						as addnmodifyuserid,
		GETDATE()				as addddtmodified,
		null,
		null,
		null,
		null,
		a.names_id				as [saga],
		null					as [source_id],
		'needles'				as [source_db],
		'multi_addresses.other' as [source_ref]
	from [Needles].[dbo].[multi_addresses] a
	join [sma_MST_Indvcontacts] i
		on i.saga = a.names_id
	join [sma_MST_AddressTypes] t
		on t.addnContactCategoryID = i.cinnContactCtg
			and t.addsCode = 'OTH'
	where
		(   a.[addr_type] = 'Other'
			and
			(   ISNULL(a.[address], '') <> ''
				or
				ISNULL(a.[address_2], '') <> ''
				or
				ISNULL(a.[city], '') <> ''
				or
				ISNULL(a.[state], '') <> ''
				or
				ISNULL(a.[zipcode], '') <> ''
				or
				ISNULL(a.[county], '') <> ''
				or
				ISNULL(a.[country], '') <> ''))
go


/* ------------------------------------------------------------------------------
Organization Contact Addresses
*/ ------------------------------------------------------------------------------
-- Home from OrgContacts
insert into [sma_MST_Address]
	(
		[addnContactCtgID],
		[addnContactID],
		[addnAddressTypeID],
		[addsAddressType],
		[addsAddTypeCode],
		[addsAddress1],
		[addsAddress2],
		[addsAddress3],
		[addsStateCode],
		[addsCity],
		[addnZipID],
		[addsZip],
		[addsCounty],
		[addsCountry],
		[addbIsResidence],
		[addbPrimary],
		[adddFromDate],
		[adddToDate],
		[addnCompanyID],
		[addsDepartment],
		[addsTitle],
		[addnContactPersonID],
		[addsComments],
		[addbIsCurrent],
		[addbIsMailing],
		[addnRecUserID],
		[adddDtCreated],
		[addnModifyUserID],
		[adddDtModified],
		[addnLevelNo],
		[caseno],
		[addbDeleted],
		[addsZipExtn],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		o.connContactCtg	   as addncontactctgid,
		o.connContactID		   as addncontactid,
		t.addnAddTypeID		   as addnaddresstypeid,
		t.addsDscrptn		   as addsaddresstype,
		t.addsCode			   as addsaddtypecode,
		a.[address]			   as addsaddress1,
		a.[address_2]		   as addsaddress2,
		null				   as addsaddress3,
		a.[state]			   as addsstatecode,
		a.[city]			   as addscity,
		null				   as addnzipid,
		a.[zipcode]			   as addszip,
		a.[county]			   as addscounty,
		a.[country]			   as addscountry,
		null				   as addbisresidence,
		case
			when a.[default_addr] = 'Y' then 1
			else 0
		end					   as addbprimary,
		null,
		null,
		null,
		null,
		null,
		null,
		case
			when ISNULL(a.company, '') <> '' then (
					'Company : ' + CHAR(13) + a.company
					)
			else ''
		end					   as [addscomments],
		null,
		null,
		368					   as addnrecuserid,
		GETDATE()			   as addddtcreated,
		368					   as addnmodifyuserid,
		GETDATE()			   as addddtmodified,
		null,
		null,
		null,
		null,
		a.names_id			   as [saga],
		null				   as [source_id],
		'needles'			   as [source_db],
		'multi_addresses.home' as [source_ref]
	from [Needles].[dbo].[multi_addresses] a
	join [sma_MST_Orgcontacts] o
		on o.saga = a.names_id
	join [sma_MST_AddressTypes] t
		on t.addnContactCategoryID = o.connContactCtg
			and t.addsCode = 'HO'
	where
		(   a.[addr_type] = 'Home'
			and
			(   ISNULL(a.[address], '') <> ''
				or
				ISNULL(a.[address_2], '') <> ''
				or
				ISNULL(a.[city], '') <> ''
				or
				ISNULL(a.[state], '') <> ''
				or
				ISNULL(a.[zipcode], '') <> ''
				or
				ISNULL(a.[county], '') <> ''
				or
				ISNULL(a.[country], '') <> ''))
go

-- Business from OrgContacts
insert into [sma_MST_Address]
	(
		[addnContactCtgID],
		[addnContactID],
		[addnAddressTypeID],
		[addsAddressType],
		[addsAddTypeCode],
		[addsAddress1],
		[addsAddress2],
		[addsAddress3],
		[addsStateCode],
		[addsCity],
		[addnZipID],
		[addsZip],
		[addsCounty],
		[addsCountry],
		[addbIsResidence],
		[addbPrimary],
		[adddFromDate],
		[adddToDate],
		[addnCompanyID],
		[addsDepartment],
		[addsTitle],
		[addnContactPersonID],
		[addsComments],
		[addbIsCurrent],
		[addbIsMailing],
		[addnRecUserID],
		[adddDtCreated],
		[addnModifyUserID],
		[adddDtModified],
		[addnLevelNo],
		[caseno],
		[addbDeleted],
		[addsZipExtn],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		o.connContactCtg		   as addncontactctgid,
		o.connContactID			   as addncontactid,
		t.addnAddTypeID			   as addnaddresstypeid,
		t.addsDscrptn			   as addsaddresstype,
		t.addsCode				   as addsaddtypecode,
		a.[address]				   as addsaddress1,
		a.[address_2]			   as addsaddress2,
		null					   as addsaddress3,
		a.[state]				   as addsstatecode,
		a.[city]				   as addscity,
		null					   as addnzipid,
		a.[zipcode]				   as addszip,
		a.[county]				   as addscounty,
		a.[country]				   as addscountry,
		null					   as addbisresidence,
		case
			when a.[default_addr] = 'Y' then 1
			else 0
		end						   as addbprimary,
		null,
		null,
		null,
		null,
		null,
		null,
		case
			when ISNULL(a.company, '') <> '' then 'Company : ' + CHAR(13) + a.company
			else ''
		end						   as [addscomments],
		null,
		null,
		368						   as addnrecuserid,
		GETDATE()				   as addddtcreated,
		368						   as addnmodifyuserid,
		GETDATE()				   as addddtmodified,
		null,
		null,
		null,
		null,
		a.names_id				   as [saga],
		null					   as [source_id],
		'needles'				   as [source_db],
		'multi_addresses.business' as [source_ref]
	from [Needles].[dbo].[multi_addresses] a
	join [sma_MST_Orgcontacts] o
		on o.saga = a.names_id
	join [sma_MST_AddressTypes] t
		on t.addnContactCategoryID = o.connContactCtg
			and t.addsCode = 'WRK'
	where
		(   a.[addr_type] = 'Business'
			and
			(   ISNULL(a.[address], '') <> ''
				or
				ISNULL(a.[address_2], '') <> ''
				or
				ISNULL(a.[city], '') <> ''
				or
				ISNULL(a.[state], '') <> ''
				or
				ISNULL(a.[zipcode], '') <> ''
				or
				ISNULL(a.[county], '') <> ''
				or
				ISNULL(a.[country], '') <> ''))
go

-- Other from OrgContacts
insert into [sma_MST_Address]
	(
		[addnContactCtgID],
		[addnContactID],
		[addnAddressTypeID],
		[addsAddressType],
		[addsAddTypeCode],
		[addsAddress1],
		[addsAddress2],
		[addsAddress3],
		[addsStateCode],
		[addsCity],
		[addnZipID],
		[addsZip],
		[addsCounty],
		[addsCountry],
		[addbIsResidence],
		[addbPrimary],
		[adddFromDate],
		[adddToDate],
		[addnCompanyID],
		[addsDepartment],
		[addsTitle],
		[addnContactPersonID],
		[addsComments],
		[addbIsCurrent],
		[addbIsMailing],
		[addnRecUserID],
		[adddDtCreated],
		[addnModifyUserID],
		[adddDtModified],
		[addnLevelNo],
		[caseno],
		[addbDeleted],
		[addsZipExtn],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		o.connContactCtg		as addncontactctgid,
		o.connContactID			as addncontactid,
		t.addnAddTypeID			as addnaddresstypeid,
		t.addsDscrptn			as addsaddresstype,
		t.addsCode				as addsaddtypecode,
		a.[address]				as addsaddress1,
		a.[address_2]			as addsaddress2,
		null					as addsaddress3,
		a.[state]				as addsstatecode,
		a.[city]				as addscity,
		null					as addnzipid,
		a.[zipcode]				as addszip,
		a.[county]				as addscounty,
		a.[country]				as addscountry,
		null					as addbisresidence,
		case
			when a.[default_addr] = 'Y' then 1
			else 0
		end						as addbprimary,
		null,
		null,
		null,
		null,
		null,
		null,
		case
			when ISNULL(a.company, '') <> '' then (
					'Company : ' + CHAR(13) + a.company
					)
			else ''
		end						as [addscomments],
		null,
		null,
		368						as addnrecuserid,
		GETDATE()				as addddtcreated,
		368						as addnmodifyuserid,
		GETDATE()				as addddtmodified,
		null,
		null,
		null,
		null,
		a.names_id				as [saga],
		null					as [source_id],
		'needles'				as [source_db],
		'multi_addresses.other' as [source_ref]
	from [Needles].[dbo].[multi_addresses] a
	join [sma_MST_Orgcontacts] o
		on o.saga = a.names_id
	join [sma_MST_AddressTypes] t
		on t.addnContactCategoryID = o.connContactCtg
			and t.addsCode = 'BR'
	where
		(   a.[addr_type] = 'Other'
			and
			(   ISNULL(a.[address], '') <> ''
				or
				ISNULL(a.[address_2], '') <> ''
				or
				ISNULL(a.[city], '') <> ''
				or
				ISNULL(a.[state], '') <> ''
				or
				ISNULL(a.[zipcode], '') <> ''
				or
				ISNULL(a.[county], '') <> ''
				or
				ISNULL(a.[country], '') <> ''))
go



/* ------------------------------------------------------------------------------
Appendix
Insert 'Other' addresses for contacts without any
*/ ------------------------------------------------------------------------------

---(APPENDIX)---
---(A.0)
insert into [sma_MST_Address]
	(
		addnContactCtgID,
		addnContactID,
		addnAddressTypeID,
		addsAddressType,
		addsAddTypeCode,
		addbPrimary,
		addnRecUserID,
		adddDtCreated
	)
	select
		i.cinnContactCtg as addncontactctgid,
		i.cinnContactID	 as addncontactid,
		(
		 select
			 addnAddTypeID
		 from [sma_MST_AddressTypes]
		 where addsDscrptn = 'Other'
			 and addnContactCategoryID = i.cinnContactCtg
		)				 as addnaddresstypeid,
		'Other'			 as addsaddresstype,
		'OTH'			 as addsaddtypecode,
		1				 as addbprimary,
		368				 as addnrecuserid,
		GETDATE()		 as addddtcreated
	from [sma_MST_IndvContacts] i
	left join [sma_MST_Address] a
		on a.addncontactid = i.cinnContactID
			and a.addncontactctgid = i.cinnContactCtg
	where
		a.addnAddressID is null

---(A.1)
insert into [sma_MST_AddressTypes]
	(
		addsCode,
		addsDscrptn,
		addnContactCategoryID,
		addbIsWork
	)
	select
		'OTH_O',
		'Other',
		2,
		0
	except
	select
		addsCode,
		addsDscrptn,
		addnContactCategoryID,
		addbIsWork
	from [sma_MST_AddressTypes]


insert into [sma_MST_Address]
	(
		addnContactCtgID,
		addnContactID,
		addnAddressTypeID,
		addsAddressType,
		addsAddTypeCode,
		addbPrimary,
		addnRecUserID,
		adddDtCreated
	)
	select
		o.connContactCtg as addncontactctgid,
		o.connContactID	 as addncontactid,
		(
		 select
			 addnAddTypeID
		 from [sma_MST_AddressTypes]
		 where addsDscrptn = 'Other'
			 and addnContactCategoryID = o.connContactCtg
		)				 as addnaddresstypeid,
		'Other'			 as addsaddresstype,
		'OTH_O'			 as addsaddtypecode,
		1				 as addbprimary,
		368				 as addnrecuserid,
		GETDATE()		 as addddtcreated
	from [sma_MST_OrgContacts] o
	left join [sma_MST_Address] a
		on a.addncontactid = o.connContactID
			and a.addncontactctgid = o.connContactCtg
	where
		a.addnAddressID is null

----(APPENDIX)----
update [sma_MST_Address]
set addbPrimary = 1
from (
 select
	 i.cinnContactID															   as cid,
	 a.addnAddressID															   as aid,
	 ROW_NUMBER() over (partition by i.cinnContactID order by a.addnAddressID asc) as rownumber
 from [sma_MST_Indvcontacts] i
 join [sma_MST_Address] a
	 on a.addnContactID = i.cinnContactID
	 and a.addnContactCtgID = i.cinnContactCtg
	 and a.addbPrimary <> 1
 where i.cinnContactID not in (
	  select
		  i.cinnContactID
	  from [sma_MST_Indvcontacts] i
	  join [sma_MST_Address] a
		  on a.addnContactID = i.cinnContactID
		  and a.addnContactCtgID = i.cinnContactCtg
		  and a.addbPrimary = 1
	 )
) a
where a.rownumber = 1
and a.aid = addnAddressID

update [sma_MST_Address]
set addbPrimary = 1
from (
 select
	 o.connContactID															   as cid,
	 a.addnAddressID															   as aid,
	 ROW_NUMBER() over (partition by o.connContactID order by a.addnAddressID asc) as rownumber
 from [sma_MST_OrgContacts] o
 join [sma_MST_Address] a
	 on a.addnContactID = o.connContactID
	 and a.addnContactCtgID = o.connContactCtg
	 and a.addbPrimary <> 1
 where o.connContactID not in (
	  select
		  o.connContactID
	  from [sma_MST_OrgContacts] o
	  join [sma_MST_Address] a
		  on a.addnContactID = o.connContactID
		  and a.addnContactCtgID = o.connContactCtg
		  and a.addbPrimary = 1
	 )
) a
where a.rownumber = 1
and a.aid = addnAddressID


---
alter table [sma_MST_Address] enable trigger all
go
---

------------- Check Uniqueness------------
-- select I.cinnContactID
-- 	 from [SA].[dbo].[sma_MST_Indvcontacts] I 
--	 inner join [SA].[dbo].[sma_MST_Address] A on A.addnContactID=I.cinnContactID and A.addnContactCtgID=I.cinnContactCtg and A.addbPrimary=1 
--	 group by cinnContactID
--	 having count(cinnContactID)>1

-- select O.connContactID
-- 	 from [SA].[dbo].[sma_MST_OrgContacts] O 
--	 inner join [SA].[dbo].[sma_MST_Address] A on A.addnContactID=O.connContactID and A.addnContactCtgID=O.connContactCtg and A.addbPrimary=1 
--	 group by connContactID
--	 having count(connContactID)>1

