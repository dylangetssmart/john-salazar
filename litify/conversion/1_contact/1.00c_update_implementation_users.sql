/*
- update source_id on both sma_mst_users and sma_mst_indvcontacts

because users were created manually in the implementation system,
we need to update both the user and indvContact records with a reference to the associated source user

steps:
1. update sma_MST_Users.saga_char
2. update sma_MST_IndvContacts.saga_char from users

*/

use ShinerSA
go


----------------------------------------------------------------------------------------------------
-- Update sma_mst_users.saga_char
----------------------------------------------------------------------------------------------------

-- join on email
--select
--	u.Username,
--	LEFT(LEFT(Username, CHARINDEX('@', Username) - 1), 20) as converted_login_id,
--	u.FirstName,
--	u.LastName,
--	Alias,
--	u.Id,
--	email.cewsEmailWebSite,
--	email.cewnContactID,
--	indv.cinsFirstName,
--	indv.cinsLastName
--from ShinerLitify..[User] u
--LEFT join shinersa..sma_mst_emailwebsite email
--	on email.cewsemailwebsite = u.Username
--LEFT join shinersa..sma_mst_indvcontacts indv
--	on email.cewncontactid = indv.cinncontactid
--where Alias <> 'APP'
--order by u.Username

--SELECT * FROM sma_MST_Users smu


--select sau.usrnUserID, sau.usrsLoginID, u.Username
--from sma_mst_users sau
--join sma_mst_indvcontacts indv
--on indv.cinnContactID = sau.usrnContactID
--LEFT join sma_MST_EmailWebsite email
--on email.cewnContactID = indv.cinnContactID
--LEFT join ShinerLitify..[User] u
--on email.cewsemailwebsite = u.Username
--order by sau.usrsLoginID

--SELECT * FROM sma_MST_IndvContacts smic where smic.cinsLastName like 'broadway'
--SELECT * FROM sma_MST_EmailWebsite smew where smew.cewnContactID = 38

update sma_mst_users
set saga_char = (
		select
			U.Id
		from ShinerLitify..[User] u
		join shinersa..sma_mst_emailwebsite email
			on email.cewsemailwebsite = u.Username
		join shinersa..sma_mst_indvcontacts indv
			on email.cewncontactid = indv.cinncontactid
		where indv.cinnContactID = sma_MST_Users.usrnContactID
	),
	source_db = 'litify';

----------------------------------------------------------------------------------------------------
-- Manually update users where email link fails
----------------------------------------------------------------------------------------------------
-- David Shiner
update sma_mst_users
set saga_char = '0058Z000008r7IZQAY'
where usrnUserID = 372

-- Kelsey Brown
update sma_mst_users
set saga_char = '0058Z000009jYi9QAE'
where usrnUserID = 376

-- Lourdy
update sma_mst_users
set saga_char = '0058Z000008qiQDQAY'
where usrnUserID = 377

-- MGarcia
update sma_mst_users
set saga_char = '0058Z000009SpjaQAC'
where usrnUserID = 394

-- MReagan
update sma_mst_users
set saga_char = '0058Z000008qiQmQAI'
where usrnUserID = 374

-- SRodriguez
update sma_mst_users
set saga_char = '0058Z000007WT7zQAG'
where usrnUserID = 389

-- WBroadway
update sma_mst_users
set saga_char = '0058Z000009TKgXQAW'
where usrnUserID = 395

-- SOrmachea (married name of sbueno)
update sma_mst_users
set saga_char = '005Nt000006E1OzIAK'
where usrnUserID = 393

-- CQuintanilla
update sma_mst_users
set saga_char = '0058Z000008sEqVQAU'
where usrnUserID = 405

-- Records
--update sma_mst_users
--set saga_char = '005Nt000006E1OzIAK'
--where usrnUserID = 414

-- LegalClerks
update sma_mst_users
set saga_char = '005Nt000002dCWPIA2'
where usrnUserID = 415

-- Settlements
update sma_mst_users
set saga_char = '005Nt000003ZtpVIAS'
where usrnUserID = 416

--UPDATE sma_MST_IndvContacts
--set source_id = (
--	select top 1 
--	source_id
--	from sma_MST_Users u
--	where u.usrnContactID = sma_MST_IndvContacts.cinnContactID
--),
--source_db = 'needles'

----------------------------------------------------------------------------------------------------
-- Update sma_MST_IndvContacts.saga_char
----------------------------------------------------------------------------------------------------
-- Step 1: Create a temporary table for mapping contact IDs to source IDs
IF OBJECT_ID('tempdb..#ContactSourceMap') IS NOT NULL
    DROP TABLE #ContactSourceMap;

SELECT 
    indv.cinnContactID AS ContactID,
    u.saga_char AS saga_char
INTO #ContactSourceMap
FROM sma_MST_Users u
JOIN sma_MST_IndvContacts indv
    ON u.usrnContactID = indv.cinnContactID;

-- Step 2: Create an index on the temporary table for faster joins
CREATE INDEX idx_ContactID ON #ContactSourceMap(ContactID);

-- Step 3: Update sma_MST_IndvContacts using the temporary table
UPDATE indv
SET indv.saga_char = map.saga_char,
    indv.source_db = 'litify'
FROM sma_MST_IndvContacts indv
JOIN #ContactSourceMap map
    ON indv.cinnContactID = map.ContactID;

-- Step 4: Clean up the temporary table
DROP TABLE #ContactSourceMap;

--SELECT smu.usrsLoginID, smu.source_id FROM ShinerSA..sma_MST_Users smu order by smu.usrsLoginID

--select s.staff_code, u.*
--	FROM [ShinerSA]..sma_mst_users u
--		JOIN [ShinerSA]..sma_MST_IndvContacts smic
--			ON smic.cinnContactID = u.usrnContactID
--		LEFT JOIN JoelBieberNeedles..staff s
--			ON s.full_name = smic.cinsFirstName + ' ' + smic.cinsLastName