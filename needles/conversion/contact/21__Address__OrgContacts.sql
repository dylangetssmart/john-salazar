/*---
group: load
order: 
description: Update contact types for attorneys
---*/

use VanceLawFirm_SA
go

/*
alter table [sma_MST_Address] disable trigger all
delete from [sma_MST_Address] 
DBCC CHECKIDENT ('[sma_MST_Address]', RESEED, 0);
alter table [sma_MST_Address] enable trigger all
*/
-- select distinct addr_Type from  [VanceLawFirm_Needles].[dbo].[multi_addresses]
-- select * from  [VanceLawFirm_Needles].[dbo].[multi_addresses] where addr_type not in ('Home','business', 'other')

alter table [sma_MST_Address] disable trigger all
go

-------------------------------------------------------
----(2)---- CONSTRUCT FROM SMA_MST_ORGCONTACTS
-------------------------------------------------------

-- Home from OrgContacts
insert into [sma_MST_Address]
	(
	[addnContactCtgID], [addnContactID], [addnAddressTypeID], [addsAddressType], [addsAddTypeCode], [addsAddress1], [addsAddress2], [addsAddress3], [addsStateCode], [addsCity], [addnZipID], [addsZip], [addsCounty], [addsCountry], [addbIsResidence], [addbPrimary], [adddFromDate], [adddToDate], [addnCompanyID], [addsDepartment], [addsTitle], [addnContactPersonID], [addsComments], [addbIsCurrent], [addbIsMailing], [addnRecUserID], [adddDtCreated], [addnModifyUserID], [adddDtModified], [addnLevelNo], [caseno], [addbDeleted], [addsZipExtn], [saga], [source_id], [source_db], [source_ref]
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
			when a.[default_addr] = 'Y'
				then 1
			else 0
		end					   as addbprimary,
		null,
		null,
		null,
		null,
		null,
		null,
		case
			when ISNULL(a.company, '') <> ''
				then (
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
		null				   as [saga],
		null				   as [source_id],
		'needles'			   as [source_db],
		'multi_addresses.home' as [source_ref]
	from [VanceLawFirm_Needles].[dbo].[multi_addresses] a
	join [sma_MST_Orgcontacts] o
		on o.saga = a.names_id
	join [sma_MST_AddressTypes] t
		on t.addnContactCategoryID = o.connContactCtg
			and t.addsCode = 'HO'
	where (a.[addr_type] = 'Home'
		and (ISNULL(a.[address], '') <> ''
		or ISNULL(a.[address_2], '') <> ''
		or ISNULL(a.[city], '') <> ''
		or ISNULL(a.[state], '') <> ''
		or ISNULL(a.[zipcode], '') <> ''
		or ISNULL(a.[county], '') <> ''
		or ISNULL(a.[country], '') <> ''))

-- Business from OrgContacts
insert into [sma_MST_Address]
	(
	[addnContactCtgID], [addnContactID], [addnAddressTypeID], [addsAddressType], [addsAddTypeCode], [addsAddress1], [addsAddress2], [addsAddress3], [addsStateCode], [addsCity], [addnZipID], [addsZip], [addsCounty], [addsCountry], [addbIsResidence], [addbPrimary], [adddFromDate], [adddToDate], [addnCompanyID], [addsDepartment], [addsTitle], [addnContactPersonID], [addsComments], [addbIsCurrent], [addbIsMailing], [addnRecUserID], [adddDtCreated], [addnModifyUserID], [adddDtModified], [addnLevelNo], [caseno], [addbDeleted], [addsZipExtn], [saga], [source_id], [source_db], [source_ref]
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
			when a.[default_addr] = 'Y'
				then 1
			else 0
		end						   as addbprimary,
		null,
		null,
		null,
		null,
		null,
		null,
		case
			when ISNULL(a.company, '') <> ''
				then 'Company : ' + CHAR(13) + a.company
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
		null					   as [saga],
		null					   as [source_id],
		'needles'				   as [source_db],
		'multi_addresses.business' as [source_ref]
	from [VanceLawFirm_Needles].[dbo].[multi_addresses] a
	join [sma_MST_Orgcontacts] o
		on o.saga = a.names_id
	join [sma_MST_AddressTypes] t
		on t.addnContactCategoryID = o.connContactCtg
			and t.addsCode = 'WRK'
	where (a.[addr_type] = 'Business'
		and (ISNULL(a.[address], '') <> ''
		or ISNULL(a.[address_2], '') <> ''
		or ISNULL(a.[city], '') <> ''
		or ISNULL(a.[state], '') <> ''
		or ISNULL(a.[zipcode], '') <> ''
		or ISNULL(a.[county], '') <> ''
		or ISNULL(a.[country], '') <> ''))

-- Other from OrgContacts
insert into [sma_MST_Address]
	(
	[addnContactCtgID], [addnContactID], [addnAddressTypeID], [addsAddressType], [addsAddTypeCode], [addsAddress1], [addsAddress2], [addsAddress3], [addsStateCode], [addsCity], [addnZipID], [addsZip], [addsCounty], [addsCountry], [addbIsResidence], [addbPrimary], [adddFromDate], [adddToDate], [addnCompanyID], [addsDepartment], [addsTitle], [addnContactPersonID], [addsComments], [addbIsCurrent], [addbIsMailing], [addnRecUserID], [adddDtCreated], [addnModifyUserID], [adddDtModified], [addnLevelNo], [caseno], [addbDeleted], [addsZipExtn], [saga], [source_id], [source_db], [source_ref]
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
			when a.[default_addr] = 'Y'
				then 1
			else 0
		end						as addbprimary,
		null,
		null,
		null,
		null,
		null,
		null,
		case
			when ISNULL(a.company, '') <> ''
				then (
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
		null					as [saga],
		null					as [source_id],
		'needles'				as [source_db],
		'multi_addresses.other' as [source_ref]
	from [VanceLawFirm_Needles].[dbo].[multi_addresses] a
	join [sma_MST_Orgcontacts] o
		on o.saga = a.names_id
	join [sma_MST_AddressTypes] t
		on t.addnContactCategoryID = o.connContactCtg
			and t.addsCode = 'BR'
	where (a.[addr_type] = 'Other'
		and (ISNULL(a.[address], '') <> ''
		or ISNULL(a.[address_2], '') <> ''
		or ISNULL(a.[city], '') <> ''
		or ISNULL(a.[state], '') <> ''
		or ISNULL(a.[zipcode], '') <> ''
		or ISNULL(a.[county], '') <> ''
		or ISNULL(a.[country], '') <> ''))


---
alter table [sma_MST_Address] enable trigger all
go
---



------------- Check Uniqueness------------
-- select I.cinnContactID
-- 	 from VanceLawFirm_SA.[dbo].[sma_MST_Indvcontacts] I 
--	 inner join VanceLawFirm_SA.[dbo].[sma_MST_Address] A on A.addnContactID=I.cinnContactID and A.addnContactCtgID=I.cinnContactCtg and A.addbPrimary=1 
--	 group by cinnContactID
--	 having count(cinnContactID)>1

-- select O.connContactID
-- 	 from VanceLawFirm_SA.[dbo].[sma_MST_OrgContacts] O 
--	 inner join VanceLawFirm_SA.[dbo].[sma_MST_Address] A on A.addnContactID=O.connContactID and A.addnContactCtgID=O.connContactCtg and A.addbPrimary=1 
--	 group by connContactID
--	 having count(connContactID)>1

