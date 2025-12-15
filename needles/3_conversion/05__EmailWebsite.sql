/*---
description: Insert Email Addresses
steps:
instructions:
dependencies:
notes: >
---*/

use [SA]
go

---
alter table [sma_MST_EmailWebsite] disable trigger all
go

exec AddBreadcrumbsToTable 'sma_MST_EmailWebsite'
go

---

/* ------------------------------------------------------------------------------
Individual Contacts
*/ ------------------------------------------------------------------------------
-- Email Address
insert into [sma_MST_EmailWebsite]
	(
		[cewnContactCtgID],
		[cewnContactID],
		[cewsEmailWebsiteFlag],
		[cewsEmailWebSite],
		[cewbDefault],
		[cewnRecUserID],
		[cewdDtCreated],
		[cewnModifyUserID],
		[cewdDtModified],
		[cewnLevelNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.cinnContactCtg as cewncontactctgid,
		c.cinnContactID	 as cewncontactid,
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
	from [Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	where
		ISNULL(email, '') <> ''
go

-- Work Email
insert into [sma_MST_EmailWebsite]
	(
		[cewnContactCtgID],
		[cewnContactID],
		[cewsEmailWebsiteFlag],
		[cewsEmailWebSite],
		[cewbDefault],
		[cewnRecUserID],
		[cewdDtCreated],
		[cewnModifyUserID],
		[cewdDtModified],
		[cewnLevelNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.cinnContactCtg   as cewncontactctgid,
		c.cinnContactID	   as cewncontactid,
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
	from [Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	where
		ISNULL(email_work, '') <> ''
go

-- Other Email
insert into [sma_MST_EmailWebsite]
	(
		[cewnContactCtgID],
		[cewnContactID],
		[cewsEmailWebsiteFlag],
		[cewsEmailWebSite],
		[cewbDefault],
		[cewnRecUserID],
		[cewdDtCreated],
		[cewnModifyUserID],
		[cewdDtModified],
		[cewnLevelNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.cinnContactCtg	as cewncontactctgid,
		c.cinnContactID		as cewncontactid,
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
	from [Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	where
		ISNULL(other_email, '') <> ''
go

-- Website
insert into [sma_MST_EmailWebsite]
	(
		[cewnContactCtgID],
		[cewnContactID],
		[cewsEmailWebsiteFlag],
		[cewsEmailWebSite],
		[cewbDefault],
		[cewnRecUserID],
		[cewdDtCreated],
		[cewnModifyUserID],
		[cewdDtModified],
		[cewnLevelNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.cinnContactCtg as cewncontactctgid,
		c.cinnContactID	 as cewncontactid,
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
	from [Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	where
		ISNULL(website, '') <> ''
go

-- Insert [sma_MST_EmailWebsite] from [staff]
insert into [sma_MST_EmailWebsite]
	(
		[cewnContactCtgID],
		[cewnContactID],
		[cewsEmailWebsiteFlag],
		[cewsEmailWebSite],
		[cewbDefault],
		[cewnRecUserID],
		[cewdDtCreated],
		[cewnModifyUserID],
		[cewdDtModified],
		[cewnLevelNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		ic.cinnContactCtg as cewncontactctgid,
		ic.cinnContactID  as cewncontactid,
		'E'				  as cewsemailwebsiteflag,
		s.email			  as cewsemailwebsite,
		null			  as cewbdefault,
		368				  as cewnrecuserid,
		GETDATE()		  as cewddtcreated,
		368				  as cewnmodifyuserid,
		GETDATE()		  as cewddtmodified,
		null,
		1				  as saga, -- indicate email
		null			  as [source_id],
		'needles'		  as [source_db],
		'staff.email'	  as [source_ref]
	from [Needles].[dbo].[staff] s
	join [sma_MST_IndvContacts] ic
		on ic.source_id = s.staff_code
			and ic.source_ref = 'staff'
	--on c.cinsGrade = s.staff_code
	where
		ISNULL(email, '') <> ''
go

/* ------------------------------------------------------------------------------
Organization Contacts
*/ ------------------------------------------------------------------------------
-- Email Address
insert into [sma_MST_EmailWebsite]
	(
		[cewnContactCtgID],
		[cewnContactID],
		[cewsEmailWebsiteFlag],
		[cewsEmailWebSite],
		[cewbDefault],
		[cewnRecUserID],
		[cewdDtCreated],
		[cewnModifyUserID],
		[cewdDtModified],
		[cewnLevelNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]

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
	from [Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	where
		ISNULL(email, '') <> ''
go

-- Work Email
insert into [sma_MST_EmailWebsite]
	(
		[cewnContactCtgID],
		[cewnContactID],
		[cewsEmailWebsiteFlag],
		[cewsEmailWebSite],
		[cewbDefault],
		[cewnRecUserID],
		[cewdDtCreated],
		[cewnModifyUserID],
		[cewdDtModified],
		[cewnLevelNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]

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
	from [Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	where
		ISNULL(email_work, '') <> ''
go

-- Other Email
insert into [sma_MST_EmailWebsite]
	(
		[cewnContactCtgID],
		[cewnContactID],
		[cewsEmailWebsiteFlag],
		[cewsEmailWebSite],
		[cewbDefault],
		[cewnRecUserID],
		[cewdDtCreated],
		[cewnModifyUserID],
		[cewdDtModified],
		[cewnLevelNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]

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
	from [Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	where
		ISNULL(other_email, '') <> ''
go

-- Website
insert into [sma_MST_EmailWebsite]
	(
		[cewnContactCtgID],
		[cewnContactID],
		[cewsEmailWebsiteFlag],
		[cewsEmailWebSite],
		[cewbDefault],
		[cewnRecUserID],
		[cewdDtCreated],
		[cewnModifyUserID],
		[cewdDtModified],
		[cewnLevelNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
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
	from [Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	where
		ISNULL(website, '') <> ''
go

---
alter table [sma_MST_EmailWebsite] enable trigger all
go
---