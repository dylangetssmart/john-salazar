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

-----------------------------------------------------
-- [3.0] Create addresses for Individual Contacts from litify_address
-----------------------------------------------------
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
		[saga_char]
	)
	select distinct
		ind.cinnContactCtg as [addncontactctgid],
		ind.cinnContactID  as [addncontactid],
		adt.addnAddTypeID  as [addnaddresstypeid],
		adt.addsDscrptn	   as [addsaddresstype],
		adt.addsCode	   as [addsaddtypecode],
		a.street		   as [addsaddress1],
		''				   as [addsaddress2],
		''				   as [addsaddress3],
		case
			when a.state like '[a-z][a-z] %'
				then LEFT(a.state, 2)
			else a.state
		end				   as [addsstatecode],
		a.city			   as [addscity],
		''				   as [addnzipid],
		a.zip			   as [addszip],
		''				   as [addscounty],
		a.country		   as [addscountry],
		1				   as [addbisresidence],
		1				   as [addbprimary],
		GETDATE()		   as [adddfromdate],
		null			   as [adddtodate],
		null			   as [addncompanyid],
		null			   as [addsdepartment],
		null			   as [addstitle],
		null			   as [addncontactpersonid],
		''				   as [addscomments],
		1				   as [addbiscurrent],
		1				   as [addbismailing],
		cinnRecUserID	   as [addnrecuserid],
		cindDtCreated	   as [addddtcreated],
		null			   as [addnmodifyuserid],
		null			   as [addddtmodified],
		''				   as [addnlevelno],
		''				   as [caseno],
		null			   as [addbdeleted],
		''				   as [addszipextn],
		a.contact_id	   as [saga_char]
	--select max(len([zip]))
	from conversion.litify_address a
	join sma_MST_IndvContacts ind
		on a.contact_id = ind.saga_char
	join sma_MST_AddressTypes adt
		on adt.addsDscrptn = a.address_type
			and addnContactCategoryID = 1
go

-----------------------------------------------
-- [1.1] USERS Address
---------------------------------------------------
alter table sma_MST_Address disable trigger all
go

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
		[saga_char]
	)
	select
		ind.cinnContactCtg as addncontactctgid,
		ind.cinnContactID  as addncontactid,
		adt.addnAddTypeID  as addnaddresstypeid,
		adt.addsDscrptn	   as addsaddresstype,
		adt.addsCode	   as addsaddtypecode,
		u.[Street]		   as addsaddress1,
		''				   as addsaddress2,
		null			   as addsaddress3,
		u.[State]		   as addsstatecode,
		u.[City]		   as addscity,
		null			   as addnzipid,
		u.[PostalCode]	   as addszip,
		''				   as addscounty,
		u.[Country]		   as addscountry,
		null			   as addbisresidence,
		1				   as addbprimary,
		null,
		null,
		null,
		null,
		null,
		null,
		case
			when ISNULL(u.CompanyName, '') <> ''
				then 'Company : ' + CHAR(13) + u.CompanyName
			else ''
		end				   as [addscomments],
		null,
		null,
		368				   as addnrecuserid,
		GETDATE()		   as addddtcreated,
		368				   as addnmodifyuserid,
		GETDATE()		   as addddtmodified,
		null,
		null,
		null,
		null,
		ind.cinnContactID  as [saga_char]
	from ShinerLitify..[User] u
	join [sma_MST_IndvContacts] ind
		on ind.saga_char = u.[Id]
	join [sma_MST_AddressTypes] adt
		on adt.addnContactCategoryID = ind.cinnContactCtg
			and adt.addsCode = 'WORK'

alter table sma_MST_Address enable trigger all
go