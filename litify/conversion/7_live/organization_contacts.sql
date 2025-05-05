/* ---------------------------------------------------------------------------------------------------------------------------------------
Delete all "Other" addresses added by appendix
*/
SELECT *
FROM sma_MST_Address
where 
addnContactCtgID = 2
and addsAddressType = 'other'
and addnRecUserID = 368
-- 7074

update a
set addbDeleted = 1
from sma_MST_Address a
where 
addnContactCtgID = 2
and addsAddressType = 'other'
and addnRecUserID = 368

--update a
--set addbDeleted = 1
--from sma_MST_Address a
--where addnContactCtgID = 2
--and addsAddressType = 'other'
--and addnRecUserID = 368

/* ---------------------------------------------------------------------------------------------------------------------------------------
2. update org addresses that mistakenly were assigned ctg = 1
*/

SELECT * FROM sma_MST_Address sma
join sma_MST_AddressTypes smat
on sma.addnAddressTypeID = smat.addnAddTypeID
where sma.addnContactCtgID = 1
and smat.addnContactCategoryID = 2

-- spot check
SELECT * FROM sma_MST_Address sma
join sma_MST_AddressTypes smat
on sma.addnAddressTypeID = smat.addnAddTypeID
where sma.addnContactID = 5607
and smat.addnContactCategoryID = 2

-- final update query
UPDATE sma
set addnContactCtgID = 2
from sma_MST_Address sma
join sma_MST_AddressTypes smat
on sma.addnAddressTypeID = smat.addnAddTypeID
where sma.addnContactCtgID = 1
and smat.addnContactCategoryID = 2



---------------------------------------------------------------------------------------------------------------------------------------

SELECT * FROM ShinerSA_finalupload..[sma_MST_Address] where addncontactid = 63 and addncontactctgid = 2



SELECT * FROM sma_MST_OriginalContactTypes smoct

SELECT distinct a.Type FROM ShinerLitify..Account a order by a.Type where id = '0018Z00002ryuXvQAI'


SELECT * FROM ShinerLitify..contact a where a.AccountId = '0018Z00002ryuXvQAI'



select * from sma_MST_AddressTypes 





SELECT * FROM sma_MST_OrgContacts smoc where smoc.connContactID = 63
-- 0018Z00002ryuXvQAI

SELECT * FROM ShinerSA..[sma_MST_Address] where addncontactid = 63 and addncontactctgid = 1

SELECT * FROM sma_MST_IndvContacts smic where smic.cinnContactID = 63

SELECT * FROM ShinerSA..[sma_MST_Address] where addncontactid = 63 and addncontactctgid = 1
SELECT id, name, a.BillingStreet, a.BillingCity, a.BillingState, a.BillingPostalCode FROM ShinerLitify..Account a where id = '0018Z00002ryuXvQAI'

SELECT * FROM conversion.litify_address la where la.contact_id = '0018Z00002ryuXvQAI'

select a.*
	from conversion.litify_address a
	join sma_MST_OrgContacts oc
		on a.contact_id = oc.saga_char
	join sma_MST_AddressTypes adt
		on adt.addsDscrptn = a.address_type
			and addnContactCategoryID = 2
	where a.contact_id = 'a0B8Z00000QH2HgUAL'


SELECT * FROM sma_MST_Address where  addnContactCtgID = 2 and addsAddressType <> 'other'
-- only one org address was created?
-- addnAddressID	addnContactCtgID	addnContactID	addnAddressTypeID	addsAddressType		addsAddTypeCode		addsAddress1	addsAddress2	addsAddress3	addsStateCode	addsCity	addnZipID	addsZip	addsCounty	addsCountry	addbIsResidence	addbPrimary	adddFromDate	adddToDate	addnCompanyID	addsDepartment	addsTitle	addnContactPersonID	addsComments	addbIsCurrent	addbIsMailing	addnRecUserID	adddDtCreated	addnModifyUserID	adddDtModified	addnLevelNo	caseno	addbDeleted	addsZipExtn	saga	saga_char
-- 50504			2					6637			2					Office				NULL				515 East Las Olas Boulevard	Suite 1200	NULL	FL	Fort Lauderdale	31698	33301	Broward	UNITED STATES OF AMERICA	NULL	1	NULL	NULL	0	NULL	NULL	NULL	NULL	1	1	368	2025-03-21 14:41:00	376	2025-03-24 17:18:00	NULL	NULL	NULL	NULL	NULL	NULL
-- was this address in litify_address?
SELECT * FROM sma_MST_OrgContacts smoc where smoc.connContactID = 6637
-- a0B8Z00000QH2HgUAL
SELECT * FROM conversion.litify_address la where la.contact_id = 'a0B8Z00000QH2HgUAL'





select sma.*
	from conversion.litify_address a
	join sma_MST_OrgContacts oc
		on a.contact_id = oc.saga_char
	join sma_MST_Address sma
		on sma.saga_char = oc.connContactID
		and sma.addsAddress1 = a.street
-- 8380

update sma
set sma.addnContactCtgID = 2
	from conversion.litify_address a
	join sma_MST_OrgContacts oc
		on a.contact_id = oc.saga_char
	join sma_MST_Address sma
		on sma.saga_char = oc.connContactID
		and sma.addsAddress1 = a.street


SELECT *
FROM sma_MST_Address a
join sma_MST_OrgContacts o
on o.connContactID = a.saga_char
and o.connContactID = a.addnContactID
--10238

--1480 address records from Firm don't have street
select
			id as contact_id,
			'' as street,
			LEFT(litify_pm__City__c, 50) as city,
			LEFT(litify_pm__State__c, 50) as state,
			'' as zip,
			'' as country,
			'Office' as address_type,
			N'litify_pm__Firm__c' as source_table
		from ShinerLitify..[litify_pm__Firm__c]


	SELECT *
	FROM conversion.litify_address a
	join sma_MST_OrgContacts o
	on o.saga_char = a.contact_id
	-- 7202 org address records




	

select a.*
from sma_MST_Address a
join sma_MST_OrgContacts org
on org.connContactID = a.saga_char
and a.addnContactID = org.connContactID

where addnContactCtgID = 1





