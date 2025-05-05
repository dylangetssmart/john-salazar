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

---------------------------------------------------
-- [0.0] Schema update
---------------------------------------------------
alter table sma_MST_Address
alter column [addsAddress1] VARCHAR(255)
go

-----------------------------------------------------
-- [1.0] Add address types
-----------------------------------------------------
insert sma_MST_AddressTypes
	(
	addsDscrptn, addnContactCategoryID
	)
	select
		'Other',
		1
	union
	select
		'Other',
		2
	union
	select
		'Billing',
		1
	union
	select
		'Billing',
		2
	union
	select
		'Shipping',
		1
	union
	select
		'Shipping',
		2
	union
	select
		'Office',
		1
	union
	select
		'Office',
		2
	except
	select
		addsDscrptn,
		addnContactCategoryID
	from sma_MST_AddressTypes
go

-----------------------------------------------------
-- [2.0] Temporary table to store address data
-----------------------------------------------------
drop table if exists #Address;

select
	* into #Address
from (
	-- Contact > Other
	select
		Id,
		OtherStreet as street,
		OtherCity as city,
		OtherState as st,
		CAST(OtherPostalCode as VARCHAR(50)) as zip,
		OtherCountry as country,
		'Other' as addrtype
	from ShinerLitify..Contact
	where ISNULL(OtherStreet, '') <> ''

	union

	-- Contact > Mailing
	select
		Id,
		MailingStreet as street,
		MailingCity as city,
		MailingState as st,
		LEFT([MailingPostalCode], 12) as zip,
		MailingCountry as country,
		'Mailing' as addrtype
	from ShinerLitify..Contact
	where ISNULL(MailingStreet, '') <> ''

	union

	-- Account > Billing
	select
		Id,
		BillingStreet as street,
		BillingCity as city,
		BillingState as st,
		LEFT(BillingPostalCode, 12) as zip,
		BillingCountry as country,
		'Billing' as addrtype
	from ShinerLitify..[Account]
	where ISNULL(BillingStreet, '') <> ''

	union

	-- Account > Shipping
	select
		Id,
		ShippingStreet as street,
		ShippingCity as city,
		ShippingState as st,
		LEFT(ShippingPostalCode, 12) as zip,
		ShippingCountry as country,
		'Shipping' as addrtype
	from ShinerLitify..[Account]
	where ISNULL(ShippingStreet, '') <> ''

	union

	--SELECT
	--	Id
	--   ,Additional_Address_Street__c AS Street
	--   ,Additional_Address_City__c AS City
	--   ,Additional_Address_State__c AS St
	--   ,Additional_Address_Zip__c AS Zip
	--   ,'' AS Country
	--   ,'Shipping' AS AddrType
	--FROM ShinerLitify..[Account]
	--WHERE ISNULL(Additional_Address_Street__c, '') NOT IN ('', 'Y')

	-- UNION

	-- Firm > Office
	select
		Id,
		'' as street,
		litify_pm__City__c as city,
		litify_pm__State__c as st,
		'' as zip,
		'' as country,
		'Office' as addrtype
	from ShinerLitify..[litify_pm__Firm__c]
) a

alter table sma_MST_Address disable trigger all
go

-----------------------------------------------------
-- [3.0] Create addresses for Individual Contacts from #Address
-----------------------------------------------------
insert into [sma_MST_Address]
	(
	[addnContactCtgID], [addnContactID], [addnAddressTypeID], [addsAddressType], [addsAddTypeCode], [addsAddress1], [addsAddress2], [addsAddress3], [addsStateCode], [addsCity], [addnZipID], [addsZip], [addsCounty], [addsCountry], [addbIsResidence], [addbPrimary], [adddFromDate], [adddToDate], [addnCompanyID], [addsDepartment], [addsTitle], [addnContactPersonID], [addsComments], [addbIsCurrent], [addbIsMailing], [addnRecUserID], [adddDtCreated], [addnModifyUserID], [adddDtModified], [addnLevelNo], [caseno], [addbDeleted], [addsZipExtn], [saga]
	)
	select distinct
		1,
		cinnContactID,
		addnAddTypeID,
		addsDscrptn,
		addsCode,
		[Street],
		'',
		'',
		case
			when [st] like '[a-z][a-z] %'
				then LEFT([ST], 2)
			else [ST]
		end,
		[City],
		'',
		CONVERT(VARCHAR, [zip]),
		'',
		[Country],
		1,
		1,
		GETDATE(),
		null,
		null,
		null,
		null,
		null,
		'',
		1,
		1,
		cinnRecUserID,
		cindDtCreated,
		null,
		null,
		'',
		'',
		null,
		'',
		''
	--select max(len([zip]))
	from #Address a
	join sma_MST_IndvContacts ind
		on a.Id = ind.saga
	join sma_MST_AddressTypes adt
		on adt.addsDscrptn = a.AddrType
			and addnContactCategoryID = 1
go

-----------------------------------------------------
-- [4.0] Create addresses for Organization Contacts from #Address
-----------------------------------------------------
insert into [sma_MST_Address]
	(
	[addnContactCtgID], [addnContactID], [addnAddressTypeID], [addsAddressType], [addsAddTypeCode], [addsAddress1], [addsAddress2], [addsAddress3], [addsStateCode], [addsCity], [addnZipID], [addsZip], [addsCounty], [addsCountry], [addbIsResidence], [addbPrimary], [adddFromDate], [adddToDate], [addnCompanyID], [addsDepartment], [addsTitle], [addnContactPersonID], [addsComments], [addbIsCurrent], [addbIsMailing], [addnRecUserID], [adddDtCreated], [addnModifyUserID], [adddDtModified], [addnLevelNo], [caseno], [addbDeleted], [addsZipExtn], [saga]
	)
	select distinct
		2,
		connContactID,
		addnAddTypeID,
		addsDscrptn,
		addsCode,
		[Street],
		'',
		'',
		case
			when [st] like '[a-z][a-z] %'
				then LEFT([ST], 2)
			else [ST]
		end,
		[City],
		'',
		case
			when LEN([zip]) > 12
				then ''
			else [zip]
		end,
		'',
		[Country],
		1,
		1,
		GETDATE(),
		null,
		null,
		null,
		null,
		null,
		case
			when LEN([zip]) > 12
				then 'Zip: ' + [Zip]
			else ''
		end,
		1,
		1,
		connRecUserID,
		condDtCreated,
		null,
		null,
		'',
		'',
		null,
		'',
		''
	--select max(len([city]))
	from #Address a
	join sma_MST_OrgContacts org
		on a.Id = org.saga
	join sma_MST_AddressTypes adt
		on adt.addsDscrptn = a.AddrType
			and addnContactCategoryID = 2
go


---(Appendix)---

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
