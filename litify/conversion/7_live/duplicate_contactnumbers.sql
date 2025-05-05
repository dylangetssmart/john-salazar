SELECT * FROM sma_MST_IndvContacts smic where smic.cinnContactID = 4338
SELECT * FROM sma_MST_ContactNumbers cn where cn.cnnnContactID = 4338 and cn.cnnnContactCtgID = 1
SELECT * FROM sma_MST_Address sma where sma.addnContactID = 4338 and sma.addnContactCtgID = 1

SELECT * FROM sma_MST_IndvContacts smic where smic.cinnContactID = 3294
SELECT * FROM sma_MST_ContactNumbers cn where cn.cnnnContactID = 3294 and cn.cnnnContactCtgID = 1
SELECT * FROM sma_MST_Address sma where sma.addnContactID = 3294 and sma.addnContactCtgID = 1

SELECT * FROM sma_MST_IndvContacts smic where smic.cinnContactID = 37
SELECT * FROM sma_MST_ContactNumbers cn where cn.cnnnContactID = 37 and cn.cnnnContactCtgID = 1
SELECT * FROM sma_MST_Address sma where sma.addnContactID = 37 and sma.addnContactCtgID = 1

select cnnncontactCtgID, cnnnContactID, cnnnPhoneTypeID, cnnsContactNumber, count(*) ct
into #dupes
from sma_mst_contactNumbers
group by cnnncontactCtgID, cnnnContactID, cnnnPhoneTypeID, cnnsContactNumber
having count(*) >1

select * from #dupes d where d.cnnnContactID = 3380

-- does not exist
select
	cn.*
from #dupes d
join sma_mst_contactNumbers cn
	on d.cnnncontactCtgID = cn.cnnncontactCtgID
		and d.cnnnContactId = cn.cnnnContactID
		and d.cnnnPhoneTypeID = cn.cnnnPhoneTypeID
		and d.cnnsContactNumber = cn.cnnsContactNumber
left join sma_MST_Address sma
	on cn.cnnnAddressID = sma.addnAddressID
		and cn.cnnnContactID = sma.addnContactID
		and cn.cnnnContactCtgID = sma.addnContactCtgID
where
	sma.addnAddressID is null
order by cn.cnnncontactCtgID, cn.cnnnContactID, cn.cnnnPhoneTypeID, cn.cnnsContactNumber

delete cn
from #dupes d
join sma_mst_contactNumbers cn
	on d.cnnncontactCtgID = cn.cnnncontactCtgID
		and d.cnnnContactId = cn.cnnnContactID
		and d.cnnnPhoneTypeID = cn.cnnnPhoneTypeID
		and d.cnnsContactNumber = cn.cnnsContactNumber
left join sma_MST_Address sma
	on cn.cnnnAddressID = sma.addnAddressID
		and cn.cnnnContactID = sma.addnContactID
		and cn.cnnnContactCtgID = sma.addnContactCtgID
where
	sma.addnAddressID is null

-- deleted
select
	cn.*
from #dupes d
join sma_mst_contactNumbers cn
	on d.cnnncontactCtgID = cn.cnnncontactCtgID
		and d.cnnnContactId = cn.cnnnContactID
		and d.cnnnPhoneTypeID = cn.cnnnPhoneTypeID
		and d.cnnsContactNumber = cn.cnnsContactNumber
left join sma_MST_Address sma
	on cn.cnnnAddressID = sma.addnAddressID
		and cn.cnnnContactID = sma.addnContactID
		and cn.cnnnContactCtgID = sma.addnContactCtgID
where
	sma.addbDeleted = 1
order by cn.cnnncontactCtgID, cn.cnnnContactID, cn.cnnnPhoneTypeID, cn.cnnsContactNumber


delete cn
from #dupes d
join sma_mst_contactNumbers cn
	on d.cnnncontactCtgID = cn.cnnncontactCtgID
		and d.cnnnContactId = cn.cnnnContactID
		and d.cnnnPhoneTypeID = cn.cnnnPhoneTypeID
		and d.cnnsContactNumber = cn.cnnsContactNumber
left join sma_MST_Address sma
	on cn.cnnnAddressID = sma.addnAddressID
		and cn.cnnnContactID = sma.addnContactID
		and cn.cnnnContactCtgID = sma.addnContactCtgID
where
	sma.addbDeleted = 1






SELECT * FROM sma_MST_ContactNumbers smcn where smcn.cnnnContactID = 37



SELECT d.*
FROM sma_MST_Address a
join #dupes d
on d.cnnnContactID = a.addnContactID and d.cnnnContactCtgID = a.addnContactCtgID
where addbDeleted = 1


--------------------------------------------------------------------

select cn.*
FROM sma_MST_ContactNumbers cn
LEFT JOIN sma_MST_Address sma 
    ON cn.cnnnAddressID = sma.addnAddressID
	and cn.cnnnContactID = sma.addnContactID
	and cn.cnnnContactCtgID = sma.addnContactCtgID
WHERE sma.addnAddressID IS null
or sma.addbDeleted = 1



DELETE cn
FROM sma_MST_ContactNumbers cn
LEFT JOIN sma_MST_Address sma 
    ON cn.cnnnAddressID = sma.addnAddressID
	and cn.cnnnContactID = sma.addnContactID
	and cn.cnnnContactCtgID = sma.addnContactCtgID
WHERE sma.addnAddressID IS NULL
or sma.addbDeleted = 1