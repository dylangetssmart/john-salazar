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

-----------------------------------------------------
-- [3.0] Create addresses for Organization Contacts from litify_address
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
		oc.connContactCtg as [addncontactctgid],
		oc.connContactID  as [addncontactid],
		adt.addnAddTypeID as [addnaddresstypeid],
		adt.addsDscrptn	  as [addsaddresstype],
		adt.addsCode	  as [addsaddtypecode],
		a.street		  as [addsaddress1],
		''				  as [addsaddress2],
		''				  as [addsaddress3],
		case
			when a.state like '[a-z][a-z] %'
				then LEFT(a.state, 2)
			else a.state
		end				  as [addsstatecode],
		a.city			  as [addscity],
		''				  as [addnzipid],
		a.zip			  as [addszip],
		''				  as [addscounty],
		a.country		  as [addscountry],
		1				  as [addbisresidence],
		1				  as [addbprimary],
		GETDATE()		  as [adddfromdate],
		null			  as [adddtodate],
		null			  as [addncompanyid],
		null			  as [addsdepartment],
		null			  as [addstitle],
		null			  as [addncontactpersonid],
		''				  as [addscomments],
		1				  as [addbiscurrent],
		1				  as [addbismailing],
		connRecUserID	  as [addnrecuserid],
		condDtCreated	  as [addddtcreated],
		null			  as [addnmodifyuserid],
		null			  as [addddtmodified],
		''				  as [addnlevelno],
		''				  as [caseno],
		null			  as [addbdeleted],
		''				  as [addszipextn],
		a.contact_id	  as [saga_char]
	--select *
	from conversion.litify_address a
	join sma_MST_OrgContacts oc
		on a.contact_id = oc.saga_char
	join sma_MST_AddressTypes adt
		on adt.addsDscrptn = a.address_type
			and addnContactCategoryID = 2
go


--select * 	from conversion.litify_address a

--SELECT * FROM sma_MST_Address sma

--select *--sma.*
-- 	from conversion.litify_address a
--	join sma_MST_OrgContacts oc
--		on a.contact_id = oc.saga_char
--	join sma_MST_Address sma
--		on sma.saga_char = oc.connContactID
--		and sma.addnContactID = oc.connContactID
--		and sma.addsAddress1 = a.street
--		and sma.addsCity = a.city
--		and sma.addnContactCtgID = 1
--	join sma_MST_AddressTypes adt
--		on adt.addnAddTypeID = sma.addnAddressTypeID
--		--on adt.addsDscrptn = a.address_type
--			and addnContactCategoryID = 2



--SELECT * FROM sma_MST_Address sma
--join sma_MST_AddressTypes smat
--on sma.addnAddressTypeID = smat.addnAddTypeID
--where sma.addnContactCtgID = 1
--and smat.addnContactCategoryID = 2

---- spot check
--SELECT * FROM sma_MST_Address sma
--join sma_MST_AddressTypes smat
--on sma.addnAddressTypeID = smat.addnAddTypeID
--where sma.addnContactID = 5607
--and smat.addnContactCategoryID = 2

---- final update query
--UPDATE sma
--set addnContactCtgID = 2
--from sma_MST_Address sma
--join sma_MST_AddressTypes smat
--on sma.addnAddressTypeID = smat.addnAddTypeID
--where sma.addnContactCtgID = 1
--and smat.addnContactCategoryID = 2