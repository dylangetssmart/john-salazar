select distinct type from ShinerLitify..Account a

INSERT INTO sma_MST_OriginalContactTypes (octsDscrptn)  -- Assuming 'octsDscrptn' stores the Type name
SELECT DISTINCT a.Type
FROM ShinerLitify..Account a
WHERE NOT EXISTS (
    SELECT 1 
    FROM sma_MST_OriginalContactTypes smoct
    WHERE smoct.octsDscrptn = a.Type
);

USE [ShinerSA]
GO

/* ---------------------------------------------------------------------------------------------------------------------------------------
Create contact types as necessary
*/
delete from sma_MST_OriginalContactTypes where octdDtCreated = '2025-03-27 12:40:00'

select * from sma_MST_OriginalContactTypes smoct
insert into [dbo].[sma_MST_OriginalContactTypes]
	(
		[octsCode],
		[octnContactCtgID],
		[octsDscrptn],
		[octnRecUserID],
		[octdDtCreated],
		[octnModifyUserID],
		[octdDtModified],
		[octnLevelNo]
	)
	select distinct
		null	  as [octsCode],
		1		  as octnContactCtgID, -- int,>
		a.Type	  as octsDscrptn, -- varchar(50),>
		368		  as octnRecUserID, -- int,>
		GETDATE() as octdDtCreated, -- smalldatetime,>
		null	  as octnModifyUserID, -- int,>
		null	  as octdDtModified, -- smalldatetime,>
		null	  as octnLevelNo -- int,>)
	from ShinerLitify..Account a
	join sma_MST_IndvContacts ind
		on ind.saga_char = a.Id
	where
		a.Type is not null
		and not exists (
			select
				1
			from sma_MST_OriginalContactTypes smoct
			where smoct.octsDscrptn = a.Type
			and smoct.octnContactCtgID = 1
		);
go


insert into [dbo].[sma_MST_OriginalContactTypes]
	(
		[octsCode],
		[octnContactCtgID],
		[octsDscrptn],
		[octnRecUserID],
		[octdDtCreated],
		[octnModifyUserID],
		[octdDtModified],
		[octnLevelNo]
	)
	select distinct
		null	  as [octsCode],
		2		  as octnContactCtgID, -- int,>
		a.Type	  as octsDscrptn, -- varchar(50),>
		368		  as octnRecUserID, -- int,>
		GETDATE() as octdDtCreated, -- smalldatetime,>
		null	  as octnModifyUserID, -- int,>
		null	  as octdDtModified, -- smalldatetime,>
		null	  as octnLevelNo -- int,>)
	from ShinerLitify..Account a
	join sma_MST_OrgContacts org
		on org.saga_char = a.Id
	where
		a.Type is not null
		and not exists (
			select
				1
			from sma_MST_OriginalContactTypes smoct
			where smoct.octsDscrptn = a.Type
			and smoct.octnContactCtgID = 2
		);
go

/* ---------------------------------------------------------------------------------------------------------------------------------------
Update individual contacts
*/

SELECT  
	ind.cinsFirstName,  
    ind.cinsLastName,  
    a.Name,  
    oct.octnOrigContactTypeID,  
    oct.octsDscrptn  ,
    a.Type,  
    a.id,  
    ind.cinnContactID
FROM sma_MST_IndvContacts ind  
JOIN ShinerLitify..Account a  
    ON a.id = ind.saga_char  
LEFT JOIN sma_MST_OriginalContactTypes oct  
    ON oct.octnOrigContactTypeID = ind.cinnContactTypeID;


update ind
set cinnContactTypeID = COALESCE((
	select
		octnOrigContactTypeID
	from sma_MST_OriginalContactTypes
	where octsDscrptn = a.Type
	and octnContactCtgID = 1
), (
	select
		octnOrigContactTypeID
	from sma_MST_OriginalContactTypes
	where octsDscrptn = 'General Unspecified'
		and octnContactCtgID = 1
))
from sma_MST_IndvContacts ind
join ShinerLitify..Account a
	on ind.saga_char = a.Id
where a.Type is not null;

/* ---------------------------------------------------------------------------------------------------------------------------------------
Update individual contacts
*/

SELECT  
	org.consName,  
    a.Name,  
    oct.octnOrigContactTypeID,  
    oct.octsDscrptn as SAType,
    a.Type as LitifyType,  
    a.id,  
    org.connContactID
FROM sma_MST_OrgContacts org
JOIN ShinerLitify..Account a  
    ON a.id = org.saga_char  
LEFT JOIN sma_MST_OriginalContactTypes oct  
    ON oct.octnOrigContactTypeID = org.connContactTypeID;


update org
set connContactTypeID = COALESCE((
	select
		octnOrigContactTypeID
	from sma_MST_OriginalContactTypes
	where octsDscrptn = a.Type
	and octnContactCtgID = 2
), (
	select
		octnOrigContactTypeID
	from sma_MST_OriginalContactTypes
	where octsDscrptn = 'General Unspecified'
	and octnContactCtgID = 2
))
from sma_MST_OrgContacts org
join ShinerLitify..Account a
	on org.saga_char = a.Id
where a.Type is not null;
