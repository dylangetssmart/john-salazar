/*
SELECT * FROM Skolrood_Needles..s
- update source_id on both sma_mst_users and sma_mst_indvcontacts

because users were created manually in the implementation system,
we need to update both the user and indvContact records with a reference to the associated needles user

1. update sma_MST_Users.source_id
2. update sma_MST_IndvContacts.source_id from users


*/

--SELECT u.usrsLoginID, u.source_id, indv.cinsFirstName, indv.source_id, indv.cinnContactID
--FROM sma_MST_Users u
--join sma_MST_IndvContacts indv
--on u.usrnContactID = indv.cinnContactID


use [JohnSalazar_SA]
go


--SELECT smu.usrnUserID, smu.usrnContactID, smu.usrsLoginID, saga, source_id FROM sma_MST_Users smu
--SELECT * FROM Conversion.imp_user_map

-- Attempt to match via name
--update sma_mst_users
--set source_id = (
--		select top 1
--			s.staff_code
--		from Skolrood_Needles..staff s
--		join [JohnSalazar_SA]..sma_MST_IndvContacts indv
--			on s.full_name = indv.cinsFirstName + ' ' + indv.cinsLastName
--		where indv.cinnContactID = sma_MST_Users.usrnContactID
--	),
--	source_db = 'needles';

-- Use mapping spreadsheet
update sma_MST_Users
set source_id = imp.staffcode,
	source_db = 'needles'
from sma_mst_users u
join conversion.imp_user_map imp
	on u.usrnUserID = imp.SAUserID
where u.source_id is null

--UPDATE sma_MST_IndvContacts
--set source_id = (
--	select top 1 
--	source_id
--	from sma_MST_Users u
--	where u.usrnContactID = sma_MST_IndvContacts.cinnContactID
--),
--source_db = 'needles'


-- Step 1: Create a temporary table for mapping contact IDs to source IDs
if OBJECT_ID('tempdb..#ContactSourceMap') is not null
	drop table #ContactSourceMap;

select
	indv.cinnContactID as ContactID,
	u.source_id		   as SourceID
into #ContactSourceMap
from sma_MST_Users u
join sma_MST_IndvContacts indv
	on u.usrnContactID = indv.cinnContactID;

-- Step 2: Create an index on the temporary table for faster joins
create index idx_ContactID on #ContactSourceMap (ContactID);

-- Step 3: Update sma_MST_IndvContacts using the temporary table
update indv
set indv.source_id = map.SourceID,
	indv.source_db = 'needles'
from sma_MST_IndvContacts indv
join #ContactSourceMap map
	on indv.cinnContactID = map.ContactID;

-- Step 4: Clean up the temporary table
drop table #ContactSourceMap;

--SELECT smu.usrsLoginID, smu.source_id FROM [JohnSalazar_SA]..sma_MST_Users smu order by smu.usrsLoginID

--select s.staff_code, u.*
--	FROM [JohnSalazar_SA]..sma_mst_users u
--		JOIN [JohnSalazar_SA]..sma_MST_IndvContacts smic
--			ON smic.cinnContactID = u.usrnContactID
--		LEFT JOIN Skolrood_Needles..staff s
--			ON s.full_name = smic.cinsFirstName + ' ' + smic.cinsLastName

