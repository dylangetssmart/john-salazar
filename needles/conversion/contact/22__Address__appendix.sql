/*---
group: postload
order: 70
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
	where a.addnAddressID is null

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
	where a.addnAddressID is null

----(APPENDIX)----
update [sma_MST_Address]
set addbPrimary = 1
from (
	select
		i.cinnContactID as cid,
		a.addnAddressID as aid,
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
		o.connContactID as cid,
		a.addnAddressID as aid,
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
-- 	 from VanceLawFirm_SA.[dbo].[sma_MST_Indvcontacts] I 
--	 inner join VanceLawFirm_SA.[dbo].[sma_MST_Address] A on A.addnContactID=I.cinnContactID and A.addnContactCtgID=I.cinnContactCtg and A.addbPrimary=1 
--	 group by cinnContactID
--	 having count(cinnContactID)>1

-- select O.connContactID
-- 	 from VanceLawFirm_SA.[dbo].[sma_MST_OrgContacts] O 
--	 inner join VanceLawFirm_SA.[dbo].[sma_MST_Address] A on A.addnContactID=O.connContactID and A.addnContactCtgID=O.connContactCtg and A.addbPrimary=1 
--	 group by connContactID
--	 having count(connContactID)>1

