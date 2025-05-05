/* #######################################################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create address records

-------------------------------------------------------------------------------------------------
Step								Target							Source
-------------------------------------------------------------------------------------------------
[0.0] Schema Update					--								Source
[1.0] Address Types					--								Source
[2.0] Temp Table					#Address						dbo.Contact
[2.0] Temp Table					#Address						dbo.Account
[3.0] Indv Addresses				sma_MST_Address					sma_MST_IndvContacts
[4.0] Org Addresses					sma_MST_Address					sma_MST_OrgContacts

##########################################################################################################################
*/

use ShinerSA
go


alter table sma_MST_Address disable trigger all
go


---(A.0)
insert into [sma_MST_Address]
	(
	addnContactCtgID, addnContactID, addnAddressTypeID, addsAddressType, addsAddTypeCode, addbPrimary, addnRecUserID, adddDtCreated
	)
	select
		i.cinnContactCtg as addncontactctgid,
		i.cinnContactID	 as addncontactid,
		(
			select top 1
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
go

insert into [sma_MST_Address]
	(
	addnContactCtgID, addnContactID, addnAddressTypeID, addsAddressType, addsAddTypeCode, addbPrimary, addnRecUserID, adddDtCreated
	)
	select
		o.connContactCtg as addncontactctgid,
		o.connContactID	 as addncontactid,
		(
			select top 1
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
go

----(Appendix)----
update [sma_MST_Address]
set addbPrimary = 1
from (
	select
		i.cinnContactID as cid,
		a.addnAddressID as aid,
		ROW_NUMBER() over (partition by i.cinnContactID order by a.addnAddressID asc) as rownumber
	from [sma_MST_IndvContacts] i
	join [sma_MST_Address] a
		on a.addnContactID = i.cinnContactID
		and a.addnContactCtgID = i.cinnContactCtg
		and a.addbPrimary <> 1
	where i.cinnContactID not in (
			select
				i.cinnContactID
			from [sma_MST_IndvContacts] i
			join [sma_MST_Address] a
				on a.addnContactID = i.cinnContactID
				and a.addnContactCtgID = i.cinnContactCtg
				and a.addbPrimary = 1
		)
) a
where a.rownumber = 1
and a.aid = addnAddressID
go

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
go

alter table sma_MST_Address enable trigger all
go
