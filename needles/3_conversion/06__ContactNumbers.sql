/*---
description: Insert [sma_MST_ContactNumbers]
steps:
	1. Insert Contact Race				[sma_MST_ContactRace]
	2. Insert Individual Contacts		[sma_MST_IndvContacts]
		- Unassigned Staff
		- Unidentified Individual
		- Unidentified Plaintiff
		- Unidentified Defendant
		- from [names]
		- from [police]
		- from [staff]
		- from [insurance]
	3. Update comments					[sma_MST_IndvContacts] 
instructions:
dependencies:
	- [Needles]..[names]
	- [Needles]..[police]
	- [Needles]..[staff]
	- [Needles]..[insurance]
notes: >
---*/

use [SA]
go


--
if OBJECT_ID(N'dbo.FormatPhone', N'FN') is not null
	drop function FormatPhone;

go

create function dbo.FormatPhone (@phone VARCHAR(MAX))
returns VARCHAR(MAX)
as
begin

	if LEN(@phone) = 10
		and ISNUMERIC(@phone) = 1
	begin
		return '(' + SUBSTRING(@phone, 1, 3) + ') ' + SUBSTRING(@phone, 4, 3) + '-' + SUBSTRING(@phone, 7, 4) ---> this is good for perecman
	end

	return @phone;
end;
go

---
alter table [sma_MST_ContactNumbers] disable trigger all
go

exec AddBreadcrumbsToTable 'sma_MST_ContactNumbers'
go

---

/* ------------------------------------------------------------------------------
Insert [sma_MST_ContactNoType]
*/ ------------------------------------------------------------------------------
insert into sma_MST_ContactNoType
	(
		ctysDscrptn,
		ctynContactCategoryID,
		ctysDefaultTexting
	)
	select
		'Work Phone',
		1,
		0
	union
	select
		'Work Fax',
		1,
		0
	union
	select
		'Cell Phone',
		1,
		0
	except
	select
		ctysDscrptn,
		ctynContactCategoryID,
		ctysDefaultTexting
	from sma_MST_ContactNoType

/* ------------------------------------------------------------------------------
Individual Contacts
*/ ------------------------------------------------------------------------------
-- Home Phone
insert into [sma_MST_ContactNumbers]
	(
		[cnnnContactCtgID],
		[cnnnContactID],
		[cnnnPhoneTypeID],
		[cnnsContactNumber],
		[cnnsExtension],
		[cnnbPrimary],
		[cnnbVisible],
		[cnnnAddressID],
		[cnnsLabelCaption],
		[cnnnRecUserID],
		[cnndDtCreated],
		[cnnnModifyUserID],
		[cnndDtModified],
		[cnnnLevelNo],
		[caseNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.cinnContactCtg			as cnnncontactctgid,
		c.cinnContactID				as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'Home Primary Phone'
			 and ctynContactCategoryID = 1
		)							as cnnnphonetypeid   -- Home Phone 
		,
		dbo.FormatPhone(home_phone) as cnnscontactnumber,
		home_ext					as cnnsextension,
		1							as cnnbprimary,
		null						as cnnbvisible,
		a.addnAddressID				as cnnnaddressid,
		'Home Phone'				as cnnslabelcaption,
		368							as cnnnrecuserid,
		GETDATE()					as cnnddtcreated,
		368							as cnnnmodifyuserid,
		GETDATE()					as cnnddtmodified,
		null						as cnnnlevelno,
		null						as caseno,
		n.names_id					as [saga],
		null						as [source_id],
		'needles'					as [source_db],
		'names.home_phone'			as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.cinnContactID
			and a.addnContactCtgID = c.cinnContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(n.home_phone, '') <> ''
go

-- Work Phone
insert into [sma_MST_ContactNumbers]
	(
		[cnnnContactCtgID],
		[cnnnContactID],
		[cnnnPhoneTypeID],
		[cnnsContactNumber],
		[cnnsExtension],
		[cnnbPrimary],
		[cnnbVisible],
		[cnnnAddressID],
		[cnnsLabelCaption],
		[cnnnRecUserID],
		[cnndDtCreated],
		[cnnnModifyUserID],
		[cnndDtModified],
		[cnnnLevelNo],
		[caseNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.cinnContactCtg			as cnnncontactctgid,
		c.cinnContactID				as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'Work Phone'
			 and ctynContactCategoryID = 1
		)							as cnnnphonetypeid,
		dbo.FormatPhone(work_phone) as cnnscontactnumber,
		work_extension				as cnnsextension,
		1							as cnnbprimary,
		null						as cnnbvisible,
		a.addnAddressID				as cnnnaddressid,
		'Work Phone'				as cnnslabelcaption,
		368							as cnnnrecuserid,
		GETDATE()					as cnnddtcreated,
		368							as cnnnmodifyuserid,
		GETDATE()					as cnnddtmodified,
		null						as cnnnlevelno,
		null						as caseno,
		n.names_id					as [saga],
		null						as [source_id],
		'needles'					as [source_db],
		'names.work_phone'			as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.cinnContactID
			and a.addnContactCtgID = c.cinnContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(work_phone, '') <> ''
go

-- Cell Phone
insert into [sma_MST_ContactNumbers]
	(
		[cnnnContactCtgID],
		[cnnnContactID],
		[cnnnPhoneTypeID],
		[cnnsContactNumber],
		[cnnsExtension],
		[cnnbPrimary],
		[cnnbVisible],
		[cnnnAddressID],
		[cnnsLabelCaption],
		[cnnnRecUserID],
		[cnndDtCreated],
		[cnnnModifyUserID],
		[cnndDtModified],
		[cnnnLevelNo],
		[caseNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.cinnContactCtg		   as cnnncontactctgid,
		c.cinnContactID			   as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'Cell Phone'
			 and ctynContactCategoryID = 1
		)						   as cnnnphonetypeid,
		dbo.FormatPhone(car_phone) as cnnscontactnumber,
		car_ext					   as cnnsextension,
		1						   as cnnbprimary,
		null					   as cnnbvisible,
		a.addnAddressID			   as cnnnaddressid,
		'Mobile Phone'			   as cnnslabelcaption,
		368						   as cnnnrecuserid,
		GETDATE()				   as cnnddtcreated,
		368						   as cnnnmodifyuserid,
		GETDATE()				   as cnnddtmodified,
		null					   as cnnnlevelno,
		null					   as caseno,
		n.names_id				   as [saga],
		null					   as [source_id],
		'needles'				   as [source_db],
		'names.car_phone'		   as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.cinnContactID
			and a.addnContactCtgID = c.cinnContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(car_phone, '') <> ''
go

-- Home Primary Fax
insert into [sma_MST_ContactNumbers]
	(
		[cnnnContactCtgID],
		[cnnnContactID],
		[cnnnPhoneTypeID],
		[cnnsContactNumber],
		[cnnsExtension],
		[cnnbPrimary],
		[cnnbVisible],
		[cnnnAddressID],
		[cnnsLabelCaption],
		[cnnnRecUserID],
		[cnndDtCreated],
		[cnnnModifyUserID],
		[cnndDtModified],
		[cnnnLevelNo],
		[caseNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.cinnContactCtg			as cnnncontactctgid,
		c.cinnContactID				as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'Home Primary Fax'
			 and ctynContactCategoryID = 1
		)							as cnnnphonetypeid,
		dbo.FormatPhone(fax_number) as cnnscontactnumber,
		fax_ext						as cnnsextension,
		1							as cnnbprimary,
		null						as cnnbvisible,
		a.addnAddressID				as cnnnaddressid,
		'Fax'						as cnnslabelcaption,
		368							as cnnnrecuserid,
		GETDATE()					as cnnddtcreated,
		368							as cnnnmodifyuserid,
		GETDATE()					as cnnddtmodified,
		null						as cnnnlevelno,
		null						as caseno,
		n.names_id					as [saga],
		null						as [source_id],
		'needles'					as [source_db],
		'names.fax_number'			as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.cinnContactID
			and a.addnContactCtgID = c.cinnContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(fax_number, '') <> ''
go

-- Home Vacation Phone
insert into [sma_MST_ContactNumbers]
	(
		[cnnnContactCtgID],
		[cnnnContactID],
		[cnnnPhoneTypeID],
		[cnnsContactNumber],
		[cnnsExtension],
		[cnnbPrimary],
		[cnnbVisible],
		[cnnnAddressID],
		[cnnsLabelCaption],
		[cnnnRecUserID],
		[cnndDtCreated],
		[cnnnModifyUserID],
		[cnndDtModified],
		[cnnnLevelNo],
		[caseNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.cinnContactCtg			   as cnnncontactctgid,
		c.cinnContactID				   as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'Home Vacation Phone'
			 and ctynContactCategoryID = 1
		)							   as cnnnphonetypeid,
		dbo.FormatPhone(beeper_number) as cnnscontactnumber,
		beeper_ext					   as cnnsextension,
		1							   as cnnbprimary,
		null						   as cnnbvisible,
		a.addnAddressID				   as cnnnaddressid,
		'Pager'						   as cnnslabelcaption,
		368							   as cnnnrecuserid,
		GETDATE()					   as cnnddtcreated,
		368							   as cnnnmodifyuserid,
		GETDATE()					   as cnnddtmodified,
		null						   as cnnnlevelno,
		null						   as caseno,
		n.names_id					   as [saga],
		null						   as [source_id],
		'needles'					   as [source_db],
		'names.beeper_number'		   as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.cinnContactID
			and a.addnContactCtgID = c.cinnContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(beeper_number, '') <> ''
go

-- Other 1
insert into [sma_MST_ContactNumbers]
	(
		[cnnnContactCtgID],
		[cnnnContactID],
		[cnnnPhoneTypeID],
		[cnnsContactNumber],
		[cnnsExtension],
		[cnnbPrimary],
		[cnnbVisible],
		[cnnnAddressID],
		[cnnsLabelCaption],
		[cnnnRecUserID],
		[cnndDtCreated],
		[cnnnModifyUserID],
		[cnndDtModified],
		[cnnnLevelNo],
		[caseNo],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.cinnContactCtg			  as cnnncontactctgid,
		c.cinnContactID				  as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'Home Vacation Phone'
			 and ctynContactCategoryID = 1
		)							  as cnnnphonetypeid,   -- Home Phone 
		dbo.FormatPhone(other_phone1) as cnnscontactnumber,
		other1_ext					  as cnnsextension,
		0							  as cnnbprimary,
		null						  as cnnbvisible,
		a.addnAddressID				  as cnnnaddressid,
		phone_title1				  as cnnslabelcaption,
		368							  as cnnnrecuserid,
		GETDATE()					  as cnnddtcreated,
		368							  as cnnnmodifyuserid,
		GETDATE()					  as cnnddtmodified,
		null,
		null						  as caseNo,
		null						  as [source_id],
		'needles'					  as [source_db],
		'names.other_phone1'		  as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.cinnContactID
			and a.addnContactCtgID = c.cinnContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(n.other_phone1, '') <> ''
go

-- Other 2
insert into [dbo].[sma_MST_ContactNumbers]
	(
		[cnnnContactCtgID],
		[cnnnContactID],
		[cnnnPhoneTypeID],
		[cnnsContactNumber],
		[cnnsExtension],
		[cnnbPrimary],
		[cnnbVisible],
		[cnnnAddressID],
		[cnnsLabelCaption],
		[cnnnRecUserID],
		[cnndDtCreated],
		[cnnnModifyUserID],
		[cnndDtModified],
		[cnnnLevelNo],
		[caseNo],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.cinnContactCtg			  as cnnncontactctgid,
		c.cinnContactID				  as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'Home Vacation Phone'
			 and ctynContactCategoryID = 1
		)							  as cnnnphonetypeid,   -- Home Phone 
		dbo.FormatPhone(other_phone2) as cnnscontactnumber,
		other2_ext					  as cnnsextension,
		0							  as cnnbprimary,
		null						  as cnnbvisible,
		a.addnAddressID				  as cnnnaddressid,
		phone_title2				  as cnnslabelcaption,
		368							  as cnnnrecuserid,
		GETDATE()					  as cnnddtcreated,
		368							  as cnnnmodifyuserid,
		GETDATE()					  as cnnddtmodified,
		null,
		null						  as caseno,
		null						  as [source_id],
		'needles'					  as [source_db],
		'names.other_phone2'		  as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.cinnContactID
			and a.addnContactCtgID = c.cinnContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(n.other_phone2, '') <> ''
go

-- Other 3
insert into [dbo].[sma_MST_ContactNumbers]
	(
		[cnnnContactCtgID],
		[cnnnContactID],
		[cnnnPhoneTypeID],
		[cnnsContactNumber],
		[cnnsExtension],
		[cnnbPrimary],
		[cnnbVisible],
		[cnnnAddressID],
		[cnnsLabelCaption],
		[cnnnRecUserID],
		[cnndDtCreated],
		[cnnnModifyUserID],
		[cnndDtModified],
		[cnnnLevelNo],
		[caseNo],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.cinnContactCtg			  as cnnncontactctgid,
		c.cinnContactID				  as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'Home Vacation Phone'
			 and ctynContactCategoryID = 1
		)							  as cnnnphonetypeid,   -- Home Phone 
		dbo.FormatPhone(other_phone3) as cnnscontactnumber,
		other3_ext					  as cnnsextension,
		0							  as cnnbprimary,
		null						  as cnnbvisible,
		a.addnAddressID				  as cnnnaddressid,
		phone_title3				  as cnnslabelcaption,
		368							  as cnnnrecuserid,
		GETDATE()					  as cnnddtcreated,
		368							  as cnnnmodifyuserid,
		GETDATE()					  as cnnddtmodified,
		null,
		null						  as caseno,
		null						  as [source_id],
		'needles'					  as [source_db],
		'names.other_phone3'		  as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.cinnContactID
			and a.addnContactCtgID = c.cinnContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(n.other_phone3, '') <> ''
go

-- Other 4
insert into [dbo].[sma_MST_ContactNumbers]
	(
		[cnnnContactCtgID],
		[cnnnContactID],
		[cnnnPhoneTypeID],
		[cnnsContactNumber],
		[cnnsExtension],
		[cnnbPrimary],
		[cnnbVisible],
		[cnnnAddressID],
		[cnnsLabelCaption],
		[cnnnRecUserID],
		[cnndDtCreated],
		[cnnnModifyUserID],
		[cnndDtModified],
		[cnnnLevelNo],
		[caseNo],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.cinnContactCtg			  as cnnncontactctgid,
		c.cinnContactID				  as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'Home Vacation Phone'
			 and ctynContactCategoryID = 1
		)							  as cnnnphonetypeid,   -- Home Phone 
		dbo.FormatPhone(other_phone4) as cnnscontactnumber,
		other4_ext					  as cnnsextension,
		0							  as cnnbprimary,
		null						  as cnnbvisible,
		a.addnAddressID				  as cnnnaddressid,
		phone_title4				  as cnnslabelcaption,
		368							  as cnnnrecuserid,
		GETDATE()					  as cnnddtcreated,
		368							  as cnnnmodifyuserid,
		GETDATE()					  as cnnddtmodified,
		null,
		null						  as caseno,
		null						  as [source_id],
		'needles'					  as [source_db],
		'names.other_phone4'		  as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.cinnContactID
			and a.addnContactCtgID = c.cinnContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(n.other_phone4, '') <> ''
go

-- Other 5
insert into [dbo].[sma_MST_ContactNumbers]
	(
		[cnnnContactCtgID],
		[cnnnContactID],
		[cnnnPhoneTypeID],
		[cnnsContactNumber],
		[cnnsExtension],
		[cnnbPrimary],
		[cnnbVisible],
		[cnnnAddressID],
		[cnnsLabelCaption],
		[cnnnRecUserID],
		[cnndDtCreated],
		[cnnnModifyUserID],
		[cnndDtModified],
		[cnnnLevelNo],
		[caseNo],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.cinnContactCtg			  as cnnncontactctgid,
		c.cinnContactID				  as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'Home Vacation Phone'
			 and ctynContactCategoryID = 1
		)							  as cnnnphonetypeid,   -- Home Phone 
		dbo.FormatPhone(other_phone5) as cnnscontactnumber,
		other5_ext					  as cnnsextension,
		0							  as cnnbprimary,
		null						  as cnnbvisible,
		a.addnAddressID				  as cnnnaddressid,
		phone_title5				  as cnnslabelcaption,
		368							  as cnnnrecuserid,
		GETDATE()					  as cnnddtcreated,
		368							  as cnnnmodifyuserid,
		GETDATE()					  as cnnddtmodified,
		null,
		null						  as caseno,
		null						  as [source_id],
		'needles'					  as [source_db],
		'names.other_phone5'		  as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.cinnContactID
			and a.addnContactCtgID = c.cinnContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(n.other_phone5, '') <> ''
go

/* ------------------------------------------------------------------------------
Organization Contacts
*/ ------------------------------------------------------------------------------

-- Office Phone
insert into [sma_MST_ContactNumbers]
	(
		[cnnnContactCtgID],
		[cnnnContactID],
		[cnnnPhoneTypeID],
		[cnnsContactNumber],
		[cnnsExtension],
		[cnnbPrimary],
		[cnnbVisible],
		[cnnnAddressID],
		[cnnsLabelCaption],
		[cnnnRecUserID],
		[cnndDtCreated],
		[cnnnModifyUserID],
		[cnndDtModified],
		[cnnnLevelNo],
		[caseNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.connContactCtg			as cnnncontactctgid,
		c.connContactID				as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'Office Phone'
			 and ctynContactCategoryID = 2
		)							as cnnnphonetypeid,
		dbo.FormatPhone(home_phone) as cnnscontactnumber,
		home_ext					as cnnsextension,
		1							as cnnbprimary,
		null						as cnnbvisible,
		a.addnAddressID				as cnnnaddressid,
		'Home'						as cnnslabelcaption,
		368							as cnnnrecuserid,
		GETDATE()					as cnnddtcreated,
		368							as cnnnmodifyuserid,
		GETDATE()					as cnnddtmodified,
		null						as cnnnlevelno,
		null						as caseno,
		n.names_id					as [saga],
		null						as [source_id],
		'needles'					as [source_db],
		'names.home_phone'			as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(home_phone, '') <> ''
go

-- HQ/Main Office Phone
insert into [sma_MST_ContactNumbers]
	(
		[cnnnContactCtgID],
		[cnnnContactID],
		[cnnnPhoneTypeID],
		[cnnsContactNumber],
		[cnnsExtension],
		[cnnbPrimary],
		[cnnbVisible],
		[cnnnAddressID],
		[cnnsLabelCaption],
		[cnnnRecUserID],
		[cnndDtCreated],
		[cnnnModifyUserID],
		[cnndDtModified],
		[cnnnLevelNo],
		[caseNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.connContactCtg			as cnnncontactctgid,
		c.connContactID				as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'HQ/Main Office Phone'
			 and ctynContactCategoryID = 2
		)							as cnnnphonetypeid,   -- Office Phone 
		dbo.FormatPhone(work_phone) as cnnscontactnumber,
		work_extension				as cnnsextension,
		1							as cnnbprimary,
		null						as cnnbvisible,
		a.addnAddressID				as cnnnaddressid,
		'Business'					as cnnslabelcaption,
		368							as cnnnrecuserid,
		GETDATE()					as cnnddtcreated,
		368							as cnnnmodifyuserid,
		GETDATE()					as cnnddtmodified,
		null,
		null						as caseno,
		n.names_id					as [saga],
		null						as [source_id],
		'needles'					as [source_db],
		'names.work_phone'			as [source_ref]
	from [Needles]..[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(work_phone, '') <> ''
go

-- Cell Phone
insert into [sma_MST_ContactNumbers]
	(
		[cnnnContactCtgID],
		[cnnnContactID],
		[cnnnPhoneTypeID],
		[cnnsContactNumber],
		[cnnsExtension],
		[cnnbPrimary],
		[cnnbVisible],
		[cnnnAddressID],
		[cnnsLabelCaption],
		[cnnnRecUserID],
		[cnndDtCreated],
		[cnnnModifyUserID],
		[cnndDtModified],
		[cnnnLevelNo],
		[caseNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.connContactCtg		   as cnnncontactctgid,
		c.connContactID			   as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'Cell'
			 and ctynContactCategoryID = 2
		)						   as cnnnphonetypeid,   -- Office Phone 
		dbo.FormatPhone(car_phone) as cnnscontactnumber,
		car_ext					   as cnnsextension,
		1						   as cnnbprimary,
		null					   as cnnbvisible,
		a.addnAddressID			   as cnnnaddressid,
		'Mobile'				   as cnnslabelcaption,
		368						   as cnnnrecuserid,
		GETDATE()				   as cnnddtcreated,
		368						   as cnnnmodifyuserid,
		GETDATE()				   as cnnddtmodified,
		null,
		null					   as caseno,
		n.names_id				   as [saga],
		null					   as [source_id],
		'needles'				   as [source_db],
		'names.car_phone'		   as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(car_phone, '') <> ''
go

-- Office Fax
insert into [sma_MST_ContactNumbers]
	(
		[cnnnContactCtgID],
		[cnnnContactID],
		[cnnnPhoneTypeID],
		[cnnsContactNumber],
		[cnnsExtension],
		[cnnbPrimary],
		[cnnbVisible],
		[cnnnAddressID],
		[cnnsLabelCaption],
		[cnnnRecUserID],
		[cnndDtCreated],
		[cnnnModifyUserID],
		[cnndDtModified],
		[cnnnLevelNo],
		[caseNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.connContactCtg			as cnnncontactctgid,
		c.connContactID				as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'Office Fax'
			 and ctynContactCategoryID = 2
		)							as cnnnphonetypeid,   -- Office Phone 
		dbo.FormatPhone(fax_number) as cnnscontactnumber,
		fax_ext						as cnnsextension,
		1							as cnnbprimary,
		null						as cnnbvisible,
		a.addnAddressID				as cnnnaddressid,
		'Fax'						as cnnslabelcaption,
		368							as cnnnrecuserid,
		GETDATE()					as cnnddtcreated,
		368							as cnnnmodifyuserid,
		GETDATE()					as cnnddtmodified,
		null,
		null						as caseno,
		n.names_id					as [saga],
		null						as [source_id],
		'needles'					as [source_db],
		'names.fax_number'			as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(fax_number, '') <> ''
go

-- HQ/Main Office Fax
insert into [sma_MST_ContactNumbers]
	(
		[cnnnContactCtgID],
		[cnnnContactID],
		[cnnnPhoneTypeID],
		[cnnsContactNumber],
		[cnnsExtension],
		[cnnbPrimary],
		[cnnbVisible],
		[cnnnAddressID],
		[cnnsLabelCaption],
		[cnnnRecUserID],
		[cnndDtCreated],
		[cnnnModifyUserID],
		[cnndDtModified],
		[cnnnLevelNo],
		[caseNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.connContactCtg			   as cnnncontactctgid,
		c.connContactID				   as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'HQ/Main Office Fax'
			 and ctynContactCategoryID = 2
		)							   as cnnnphonetypeid,   -- Office Phone 
		dbo.FormatPhone(beeper_number) as cnnscontactnumber,
		beeper_ext					   as cnnsextension,
		1							   as cnnbprimary,
		null						   as cnnbvisible,
		a.addnAddressID				   as cnnnaddressid,
		'Pager'						   as cnnslabelcaption,
		368							   as cnnnrecuserid,
		GETDATE()					   as cnnddtcreated,
		368							   as cnnnmodifyuserid,
		GETDATE()					   as cnnddtmodified,
		null,
		null						   as caseno,
		n.names_id					   as [saga],
		null						   as [source_id],
		'needles'					   as [source_db],
		'names.beeper_number'		   as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(beeper_number, '') <> ''
go

-- Other 1
insert into [dbo].[sma_MST_ContactNumbers]
	(
		[cnnnContactCtgID],
		[cnnnContactID],
		[cnnnPhoneTypeID],
		[cnnsContactNumber],
		[cnnsExtension],
		[cnnbPrimary],
		[cnnbVisible],
		[cnnnAddressID],
		[cnnsLabelCaption],
		[cnnnRecUserID],
		[cnndDtCreated],
		[cnnnModifyUserID],
		[cnndDtModified],
		[cnnnLevelNo],
		[caseNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.connContactCtg			  as cnnncontactctgid,
		c.connContactID				  as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'Office Phone'
			 and ctynContactCategoryID = 2
		)							  as cnnnphonetypeid,   -- Office Phone 
		dbo.FormatPhone(other_phone1) as cnnscontactnumber,
		other1_ext					  as cnnsextension,
		0							  as cnnbprimary,
		null						  as cnnbvisible,
		a.addnAddressID				  as cnnnaddressid,
		phone_title1				  as cnnslabelcaption,
		368							  as cnnnrecuserid,
		GETDATE()					  as cnnddtcreated,
		368							  as cnnnmodifyuserid,
		GETDATE()					  as cnnddtmodified,
		null,
		null						  as caseno,
		n.names_id					  as [saga],
		null						  as [source_id],
		'needles'					  as [source_db],
		'names.other_phone1'		  as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(other_phone1, '') <> ''
go

-- Other 2
insert into [dbo].[sma_MST_ContactNumbers]
	(
		[cnnnContactCtgID],
		[cnnnContactID],
		[cnnnPhoneTypeID],
		[cnnsContactNumber],
		[cnnsExtension],
		[cnnbPrimary],
		[cnnbVisible],
		[cnnnAddressID],
		[cnnsLabelCaption],
		[cnnnRecUserID],
		[cnndDtCreated],
		[cnnnModifyUserID],
		[cnndDtModified],
		[cnnnLevelNo],
		[caseNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.connContactCtg			  as cnnncontactctgid,
		c.connContactID				  as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'Office Phone'
			 and ctynContactCategoryID = 2
		)							  as cnnnphonetypeid,   -- Office Phone 
		dbo.FormatPhone(other_phone2) as cnnscontactnumber,
		other2_ext					  as cnnsextension,
		0							  as cnnbprimary,
		null						  as cnnbvisible,
		a.addnAddressID				  as cnnnaddressid,
		phone_title2				  as cnnslabelcaption,
		368							  as cnnnrecuserid,
		GETDATE()					  as cnnddtcreated,
		368							  as cnnnmodifyuserid,
		GETDATE()					  as cnnddtmodified,
		null,
		null						  as caseno,
		n.names_id					  as [saga],
		null						  as [source_id],
		'needles'					  as [source_db],
		'names.other_phone2'		  as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(other_phone2, '') <> ''
go

-- Other 3
insert into [dbo].[sma_MST_ContactNumbers]
	(
		[cnnnContactCtgID],
		[cnnnContactID],
		[cnnnPhoneTypeID],
		[cnnsContactNumber],
		[cnnsExtension],
		[cnnbPrimary],
		[cnnbVisible],
		[cnnnAddressID],
		[cnnsLabelCaption],
		[cnnnRecUserID],
		[cnndDtCreated],
		[cnnnModifyUserID],
		[cnndDtModified],
		[cnnnLevelNo],
		[caseNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.connContactCtg			  as cnnncontactctgid,
		c.connContactID				  as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'Office Phone'
			 and ctynContactCategoryID = 2
		)							  as cnnnphonetypeid,   -- Office Phone 
		dbo.FormatPhone(other_phone3) as cnnscontactnumber,
		other3_ext					  as cnnsextension,
		0							  as cnnbprimary,
		null						  as cnnbvisible,
		a.addnAddressID				  as cnnnaddressid,
		phone_title3				  as cnnslabelcaption,
		368							  as cnnnrecuserid,
		GETDATE()					  as cnnddtcreated,
		368							  as cnnnmodifyuserid,
		GETDATE()					  as cnnddtmodified,
		null,
		null						  as caseno,
		n.names_id					  as [saga],
		null						  as [source_id],
		'needles'					  as [source_db],
		'names.other_phone3'		  as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(other_phone3, '') <> ''
go

-- Other 4
insert into [dbo].[sma_MST_ContactNumbers]
	(
		[cnnnContactCtgID],
		[cnnnContactID],
		[cnnnPhoneTypeID],
		[cnnsContactNumber],
		[cnnsExtension],
		[cnnbPrimary],
		[cnnbVisible],
		[cnnnAddressID],
		[cnnsLabelCaption],
		[cnnnRecUserID],
		[cnndDtCreated],
		[cnnnModifyUserID],
		[cnndDtModified],
		[cnnnLevelNo],
		[caseNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.connContactCtg			  as cnnncontactctgid,
		c.connContactID				  as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'Office Phone'
			 and ctynContactCategoryID = 2
		)							  as cnnnphonetypeid,   -- Office Phone 
		dbo.FormatPhone(other_phone4) as cnnscontactnumber,
		other4_ext					  as cnnsextension,
		0							  as cnnbprimary,
		null						  as cnnbvisible,
		a.addnAddressID				  as cnnnaddressid,
		phone_title4				  as cnnslabelcaption,
		368							  as cnnnrecuserid,
		GETDATE()					  as cnnddtcreated,
		368							  as cnnnmodifyuserid,
		GETDATE()					  as cnnddtmodified,
		null,
		null						  as caseno,
		n.names_id					  as [saga],
		null						  as [source_id],
		'needles'					  as [source_db],
		'names.other_phone4'		  as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(other_phone4, '') <> ''
go

-- Other 5
insert into [dbo].[sma_MST_ContactNumbers]
	(
		[cnnnContactCtgID],
		[cnnnContactID],
		[cnnnPhoneTypeID],
		[cnnsContactNumber],
		[cnnsExtension],
		[cnnbPrimary],
		[cnnbVisible],
		[cnnnAddressID],
		[cnnsLabelCaption],
		[cnnnRecUserID],
		[cnndDtCreated],
		[cnnnModifyUserID],
		[cnndDtModified],
		[cnnnLevelNo],
		[caseNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.connContactCtg			  as cnnncontactctgid,
		c.connContactID				  as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'Office Phone'
			 and ctynContactCategoryID = 2
		)							  as cnnnphonetypeid,   -- Office Phone 
		dbo.FormatPhone(other_phone5) as cnnscontactnumber,
		other5_ext					  as cnnsextension,
		0							  as cnnbprimary,
		null						  as cnnbvisible,
		a.addnAddressID				  as cnnnaddressid,
		phone_title5				  as cnnslabelcaption,
		368							  as cnnnrecuserid,
		GETDATE()					  as cnnddtcreated,
		368							  as cnnnmodifyuserid,
		GETDATE()					  as cnnddtmodified,
		null,
		null						  as caseno,
		n.names_id					  as [saga],
		null						  as [source_id],
		'needles'					  as [source_db],
		'names.other_phone5'		  as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(other_phone5, '') <> ''
go


/* ------------------------------------------------------------------------------
Update primary contact numbers
*/ ------------------------------------------------------------------------------

-- Ind
update [sma_MST_ContactNumbers]
set cnnbPrimary = 0
from (
 select
	 ROW_NUMBER() over (partition by cnnnContactID order by cnnnContactNumberID) as rownumber,
	 cnnnContactNumberID														 as contactnumberid
 from [sma_MST_ContactNumbers]
 where cnnnContactCtgID = (
	  select
		  ctgnCategoryID
	  from [dbo].[sma_MST_ContactCtg]
	  where ctgsDesc = 'Individual'
	 )
) a
where a.rownumber <> 1
and a.contactnumberid = cnnnContactNumberID
go

-- Org
update [sma_MST_ContactNumbers]
set cnnbPrimary = 0
from (
 select
	 ROW_NUMBER() over (partition by cnnnContactID order by cnnnContactNumberID) as RowNumber,
	 cnnnContactNumberID														 as ContactNumberID
 from [sma_MST_ContactNumbers]
 where cnnnContactCtgID = (
	  select
		  ctgnCategoryID
	  from [dbo].[sma_MST_ContactCtg]
	  where ctgsDesc = 'Organization'
	 )
) A
where A.RowNumber <> 1
and A.ContactNumberID = cnnnContactNumberID
go

---
alter table [sma_MST_ContactNumbers] enable trigger all
go
---