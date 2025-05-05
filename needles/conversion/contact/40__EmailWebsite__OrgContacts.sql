/*---
group: load
order: 50
description: Update contact types for attorneys
---*/

/* ###################################################################################
description: update contact email addresses
steps:
	-
usage_instructions:
	-
dependencies:
	- 
notes:
	-
######################################################################################
*/

use VanceLawFirm_SA
go

/*
alter table [sma_MST_EmailWebsite] disable trigger all
delete from [sma_MST_EmailWebsite] 
DBCC CHECKIDENT ('[sma_MST_EmailWebsite]', RESEED, 0);
alter table [sma_MST_EmailWebsite] enable trigger all
*/

---
alter table [sma_MST_EmailWebsite] disable trigger all
go

--------------------------------------------------------------------
----- (2/3) CONSTRUCT SMA_MST_EMAILWEBSITE FOR ORGANIZATION ------
--------------------------------------------------------------------

-- Email
insert into [sma_MST_EmailWebsite]
	(
	[cewnContactCtgID], [cewnContactID], [cewsEmailWebsiteFlag], [cewsEmailWebSite], [cewbDefault], [cewnRecUserID], [cewdDtCreated], [cewnModifyUserID], [cewdDtModified], [cewnLevelNo], [saga], [source_id], [source_db], [source_ref]

	)
	select
		c.connContactCtg as cewncontactctgid,
		c.connContactID	 as cewncontactid,
		'E'				 as cewsemailwebsiteflag,
		n.email			 as cewsemailwebsite,
		null			 as cewbdefault,
		368				 as cewnrecuserid,
		GETDATE()		 as cewddtcreated,
		368				 as cewnmodifyuserid,
		GETDATE()		 as cewddtmodified,
		null			 as cewnlevelno,
		1				 as saga, -- indicate email
		null			 as [source_id],
		'needles'		 as [source_db],
		'names.email'	 as [source_ref]
	from [VanceLawFirm_Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	where ISNULL(email, '') <> ''

-- Work Email
insert into [sma_MST_EmailWebsite]
	(
	[cewnContactCtgID], [cewnContactID], [cewsEmailWebsiteFlag], [cewsEmailWebSite], [cewbDefault], [cewnRecUserID], [cewdDtCreated], [cewnModifyUserID], [cewdDtModified], [cewnLevelNo], [saga], [source_id], [source_db], [source_ref]

	)
	select
		c.connContactCtg   as cewncontactctgid,
		c.connContactID	   as cewncontactid,
		'E'				   as cewsemailwebsiteflag,
		n.email_work	   as cewsemailwebsite,
		null			   as cewbdefault,
		368				   as cewnrecuserid,
		GETDATE()		   as cewddtcreated,
		368				   as cewnmodifyuserid,
		GETDATE()		   as cewddtmodified,
		null			   as cewnlevelno,
		2				   as saga, -- indicate email_work
		null			   as [source_id],
		'needles'		   as [source_db],
		'names.email_work' as [source_ref]
	from [VanceLawFirm_Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	where ISNULL(email_work, '') <> ''

-- Other Email
insert into [sma_MST_EmailWebsite]
	(
	[cewnContactCtgID], [cewnContactID], [cewsEmailWebsiteFlag], [cewsEmailWebSite], [cewbDefault], [cewnRecUserID], [cewdDtCreated], [cewnModifyUserID], [cewdDtModified], [cewnLevelNo], [saga], [source_id], [source_db], [source_ref]

	)
	select
		c.connContactCtg	as cewncontactctgid,
		c.connContactID		as cewncontactid,
		'E'					as cewsemailwebsiteflag,
		n.other_email		as cewsemailwebsite,
		null				as cewbdefault,
		368					as cewnrecuserid,
		GETDATE()			as cewddtcreated,
		368					as cewnmodifyuserid,
		GETDATE()			as cewddtmodified,
		null				as cewnlevelno,
		3					as saga, -- indicate other_email
		null				as [source_id],
		'needles'			as [source_db],
		'names.other_email' as [source_ref]
	from [VanceLawFirm_Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	where ISNULL(other_email, '') <> ''

-- Website
insert into [sma_MST_EmailWebsite]
	(
	[cewnContactCtgID], [cewnContactID], [cewsEmailWebsiteFlag], [cewsEmailWebSite], [cewbDefault], [cewnRecUserID], [cewdDtCreated], [cewnModifyUserID], [cewdDtModified], [cewnLevelNo], [saga], [source_id], [source_db], [source_ref]
	)
	select
		c.connContactCtg as cewncontactctgid,
		c.connContactID	 as cewncontactid,
		'W'				 as cewsemailwebsiteflag,
		n.website		 as cewsemailwebsite,
		null			 as cewbdefault,
		368				 as cewnrecuserid,
		GETDATE()		 as cewddtcreated,
		368				 as cewnmodifyuserid,
		GETDATE()		 as cewddtmodified,
		null			 as cewnlevelno,
		4				 as saga, -- indicate website
		null			 as [source_id],
		'needles'		 as [source_db],
		'names.website'	 as [source_ref]
	from [VanceLawFirm_Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	where ISNULL(website, '') <> ''

---
alter table [sma_MST_EmailWebsite] enable trigger all
go
 ---


 /*
---- (3/3 set default)

update [sma_MST_EmailWebsite] set cewbDefault=0  
update [sma_MST_EmailWebsite] set cewbDefault=1 where cewsEmailWebsiteFlag='W'

declare @cewnContactID int;
declare @email_Count int;
declare @email_work_Count int;
declare @other_email_Count int;

declare @email_cewnEmlWSID int;
declare @email_work_cewnEmlWSID int;
declare @other_email_cewnEmlWSID int;
 
DECLARE EmailWebsite_cursor CURSOR FOR 
select distinct cewnContactID from [sma_MST_EmailWebsite]

OPEN EmailWebsite_cursor 

FETCH NEXT FROM EmailWebsite_cursor
INTO @cewnContactID

WHILE @@FETCH_STATUS = 0
BEGIN

select @email_Count=count(*),@email_cewnEmlWSID=min(cewnEmlWSID) from [sma_MST_EmailWebsite] where cewnContactID=@cewnContactID and saga=1 
select @email_work_Count=count(*),@email_work_cewnEmlWSID=min(cewnEmlWSID) from [sma_MST_EmailWebsite] where cewnContactID=@cewnContactID and saga=2
select @other_email_Count=count(*),@other_email_cewnEmlWSID=min(cewnEmlWSID) from [sma_MST_EmailWebsite] where cewnContactID=@cewnContactID and saga=3

if ( @email_Count != 0 )
begin
update [sma_MST_EmailWebsite] set cewbDefault=1 where cewnEmlWSID=@email_cewnEmlWSID
end

if ( @email_Count = 0 and @email_work_Count != 0)
begin
update [sma_MST_EmailWebsite] set cewbDefault=1 where cewnEmlWSID=@email_work_cewnEmlWSID
end

if ( @email_Count = 0 and @email_work_Count = 0 and @other_email_Count <> 0)
begin
update [sma_MST_EmailWebsite] set cewbDefault=1 where cewnEmlWSID=@other_email_cewnEmlWSID
end


FETCH NEXT FROM EmailWebsite_cursor
INTO @cewnContactID

END 

CLOSE EmailWebsite_cursor;
DEALLOCATE EmailWebsite_cursor;

*/


