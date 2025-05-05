/*---
group: load
order: 30
description:
---*/

use [JohnSalazar_SA]
go


---
alter table [sma_MST_ContactNumbers] disable trigger all
---


/*
ORG CONTACTS  ###################################################################################################
*/

-- Office Phone
insert into [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID], [cnnnContactID], [cnnnPhoneTypeID], [cnnsContactNumber], [cnnsExtension], [cnnbPrimary], [cnnbVisible], [cnnnAddressID], [cnnsLabelCaption], [cnnnRecUserID], [cnndDtCreated], [cnnnModifyUserID], [cnndDtModified], [cnnnLevelNo], [caseNo], [source_id], [source_db], [source_ref]
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
		null						as [source_id],
		'needles'					as [source_db],
		'names.home_phone'			as [source_ref]
	from [JohnSalazar_Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where ISNULL(home_phone, '') <> ''


insert into [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID], [cnnnContactID], [cnnnPhoneTypeID], [cnnsContactNumber], [cnnsExtension], [cnnbPrimary], [cnnbVisible], [cnnnAddressID], [cnnsLabelCaption], [cnnnRecUserID], [cnndDtCreated], [cnnnModifyUserID], [cnndDtModified], [cnnnLevelNo], [caseNo], [source_id], [source_db], [source_ref]
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
		null						as [source_id],
		'needles'					as [source_db],
		'names.work_phone'			as [source_ref]
	from [JohnSalazar_Needles]..[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where ISNULL(work_phone, '') <> ''


insert into [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID], [cnnnContactID], [cnnnPhoneTypeID], [cnnsContactNumber], [cnnsExtension], [cnnbPrimary], [cnnbVisible], [cnnnAddressID], [cnnsLabelCaption], [cnnnRecUserID], [cnndDtCreated], [cnnnModifyUserID], [cnndDtModified], [cnnnLevelNo], [caseNo], [source_id], [source_db], [source_ref]
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
		null					   as [source_id],
		'needles'				   as [source_db],
		'names.car_phone'		   as [source_ref]
	from [JohnSalazar_Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where ISNULL(car_phone, '') <> ''


insert into [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID], [cnnnContactID], [cnnnPhoneTypeID], [cnnsContactNumber], [cnnsExtension], [cnnbPrimary], [cnnbVisible], [cnnnAddressID], [cnnsLabelCaption], [cnnnRecUserID], [cnndDtCreated], [cnnnModifyUserID], [cnndDtModified], [cnnnLevelNo], [caseNo], [source_id], [source_db], [source_ref]
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
		null						as [source_id],
		'needles'					as [source_db],
		'names.fax_number'			as [source_ref]
	from [JohnSalazar_Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where ISNULL(fax_number, '') <> ''


insert into [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID], [cnnnContactID], [cnnnPhoneTypeID], [cnnsContactNumber], [cnnsExtension], [cnnbPrimary], [cnnbVisible], [cnnnAddressID], [cnnsLabelCaption], [cnnnRecUserID], [cnndDtCreated], [cnnnModifyUserID], [cnndDtModified], [cnnnLevelNo], [caseNo], [source_id], [source_db], [source_ref]
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
		null						   as [source_id],
		'needles'					   as [source_db],
		'names.beeper_number'		   as [source_ref]
	from [JohnSalazar_Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where ISNULL(beeper_number, '') <> ''




--(Org 1)--
insert into [dbo].[sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID], [cnnnContactID], [cnnnPhoneTypeID], [cnnsContactNumber], [cnnsExtension], [cnnbPrimary], [cnnbVisible], [cnnnAddressID], [cnnsLabelCaption], [cnnnRecUserID], [cnndDtCreated], [cnnnModifyUserID], [cnndDtModified], [cnnnLevelNo], [caseNo], [source_id], [source_db], [source_ref]
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
		null						  as [source_id],
		'needles'					  as [source_db],
		'names.other_phone1'		  as [source_ref]
	from [JohnSalazar_Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where ISNULL(other_phone1, '') <> ''

--(Org 2)--
insert into [dbo].[sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID], [cnnnContactID], [cnnnPhoneTypeID], [cnnsContactNumber], [cnnsExtension], [cnnbPrimary], [cnnbVisible], [cnnnAddressID], [cnnsLabelCaption], [cnnnRecUserID], [cnndDtCreated], [cnnnModifyUserID], [cnndDtModified], [cnnnLevelNo], [caseNo], [source_id], [source_db], [source_ref]
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
		null						  as [source_id],
		'needles'					  as [source_db],
		'names.other_phone2'		  as [source_ref]
	from [JohnSalazar_Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where ISNULL(other_phone2, '') <> ''

--(Org 3)--
insert into [dbo].[sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID], [cnnnContactID], [cnnnPhoneTypeID], [cnnsContactNumber], [cnnsExtension], [cnnbPrimary], [cnnbVisible], [cnnnAddressID], [cnnsLabelCaption], [cnnnRecUserID], [cnndDtCreated], [cnnnModifyUserID], [cnndDtModified], [cnnnLevelNo], [caseNo], [source_id], [source_db], [source_ref]
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
		null						  as [source_id],
		'needles'					  as [source_db],
		'names.other_phone3'		  as [source_ref]
	from [JohnSalazar_Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where ISNULL(other_phone3, '') <> ''

--(Org 4)--
insert into [dbo].[sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID], [cnnnContactID], [cnnnPhoneTypeID], [cnnsContactNumber], [cnnsExtension], [cnnbPrimary], [cnnbVisible], [cnnnAddressID], [cnnsLabelCaption], [cnnnRecUserID], [cnndDtCreated], [cnnnModifyUserID], [cnndDtModified], [cnnnLevelNo], [caseNo], [source_id], [source_db], [source_ref]
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
		null						  as [source_id],
		'needles'					  as [source_db],
		'names.other_phone4'		  as [source_ref]
	from [JohnSalazar_Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where ISNULL(other_phone4, '') <> ''


--(Org 5)--
insert into [dbo].[sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID], [cnnnContactID], [cnnnPhoneTypeID], [cnnsContactNumber], [cnnsExtension], [cnnbPrimary], [cnnbVisible], [cnnnAddressID], [cnnsLabelCaption], [cnnnRecUserID], [cnndDtCreated], [cnnnModifyUserID], [cnndDtModified], [cnnnLevelNo], [caseNo], [source_id], [source_db], [source_ref]
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
		null						  as [source_id],
		'needles'					  as [source_db],
		'names.other_phone5'		  as [source_ref]
	from [JohnSalazar_Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where ISNULL(other_phone5, '') <> ''


update [sma_MST_ContactNumbers]
set cnnbPrimary = 0
from (
	select
		ROW_NUMBER() over (partition by cnnnContactID order by cnnnContactNumberID) as RowNumber,
		cnnnContactNumberID															as ContactNumberID
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

alter table [sma_MST_ContactNumbers] enable trigger all