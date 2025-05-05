/*
For all Users, can you please update their contacts to:
1. Add Shiner Law Group as the organization
2. User the Shiner Law Group (contact ID: 2) organization address and contact info as the primary contact info for the user
3. remove any other addresses
4. delete the second duplicate email address for each user
*/

SELECT * FROM sma_MST_Users smu where smu.usrbActiveState = 1

SELECT * FROM sma_MST_RelContacts smrc where smrc.rlcnRelContactID = 13

SELECT * FROM sma_MST_IndvContacts smic where smic.cinnContactID = 13
SELECT * FROM sma_MST_Address sma where sma.addnContactID = 13 and sma.addnContactCtgID = 1
SELECT * FROM sma_MST_Address sma where sma.addnAddressID = 27038
SELECT * FROM sma_MST_ContactNumbers smcn where smcn.cnnnContactID = 13
SELECT * FROM sma_MST_EmailWebsite smew where smew.cewnContactID = 13


SELECT * FROM sma_MST_IndvContacts smic where smic.cinnContactID = 1049
SELECT * FROM sma_MST_RelContacts smrc where smrc.rlcnRelContactID = 1049
SELECT * FROM sma_MST_Address sma where sma.addnAddressID = 27058
/* ---------------------------------------------------------------------------------------------------------------------------------------
1. Add Shiner Law Group as the organization
- insert sma_MST_RelContacts
*/
SELECT * FROM sma_MST_OrgContacts smoc
-- Shiner Law Group: connContactID = 2
SELECT * FROM sma_MST_RelationShips smrs

insert into [dbo].[sma_MST_RelContacts]
	(
		[rlcnPrimaryCtgID],
		[rlcnPrimaryContactID],
		[rlcnPrimaryAddressID],
		[rlcnRelCtgID],
		[rlcnRelContactID],
		[rlcnRelAddressID],
		[rlcnRelTypeID],
		[rlcnRecUserID],
		[rlcdDtCreated],
		[rlcsBizFam]
	)
	select
		org.CTG	   as rlcnPrimaryCtgID,		-- 2
		org.CID	   as rlcnPrimaryContactID,	-- 2
		org.AID	   as rlcnPrimaryAddressID,	-- 5
		ioci.CTG   as rlcnRelCtgID,
		ioci.CID   as rlcnRelContactID,
		ioci.AID   as rlcnRelAddressID,
		1		   as rlcnRelTypeID,	-- Employee
		368		   as rlcnRecUserID,
		GETDATE()  as rlcdDtCreated,
		'Business' as rlcsBizFam
	--select *
	from sma_MST_Users u
	join IndvOrgContacts_Indexed ioci
		on ioci.CID = u.usrnContactID
			and ioci.CTG = 1
	join IndvOrgContacts_Indexed org
		on org.Name = 'Shiner Law Group'
		and org.CTG = 2
	where u.usrbActiveState = 1
go




/* ---------------------------------------------------------------------------------------------------------------------------------------
set phone from org as primary
*/
SELECT * FROM sma_MST_ContactNumbers smcn where smcn.cnnnContactID = 13

SELECT *
FROM sma_MST_ContactNumbers cn
join sma_MST_Users u
on u.usrnContactID = cn.cnnnContactID
where cn.cnnnContactCtgID = 1
and cn.cnnbPrimary = 1

UPDATE cn
set cnnbPrimary = 0
FROM sma_MST_ContactNumbers cn
join sma_MST_Users u
on u.usrnContactID = cn.cnnnContactID
where cn.cnnnContactCtgID = 1
and cn.cnnbPrimary = 1


/* ---------------------------------------------------------------------------------------------------------------------------------------
Delete addresses
*/
SELECT * FROM sma_MST_Address sma where sma.addnContactID = 23

SELECT *
FROM sma_MST_Address a
join sma_MST_Users u
on a.addnContactID = u.usrnContactID
and a.addnContactCtgID = 1
where u.usrbActiveState = 1

update a
set addbDeleted = 1
FROM sma_MST_Address a
join sma_MST_Users u
on a.addnContactID = u.usrnContactID
and a.addnContactCtgID = 1
where u.usrbActiveState = 1


/* ---------------------------------------------------------------------------------------------------------------------------------------
Delete duplicate email addresses
*/
SELECT * FROM sma_MST_EmailWebsite smew where smew.cewnContactID = 14

SELECT *
FROM sma_MST_EmailWebsite e
join sma_MST_Users u
on e.cewnContactID = u.usrnContactID
and e.cewnContactCtgID = 1
order by e.cewsEmailWebSite



SELECT * INTO sma_MST_EmailWebsite_Backup
FROM sma_MST_EmailWebsite;


;
with Duplicates
as
(
	select
		e.*,
		ROW_NUMBER() over (
		partition by e.cewsEmailWebSite
		order by
		case
			when e.cewnRecUserID = 368
				then 2
			else 1
		end,
		e.cewnEmlWSID
		) as rn
	from sma_MST_EmailWebsite e
	join sma_MST_Users u
		on e.cewnContactID = u.usrnContactID
	where e.cewnContactCtgID = 1
)
delete from sma_MST_EmailWebsite
where
	cewnEmlWSID in (
		select
			cewnEmlWSID
		from Duplicates
		where rn > 1
	);