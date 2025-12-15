/*---
description: Insert organization contacts
steps:
	1. Insert [sma_MST_OrgContacts]
		- Unidentified Medical Provider
		- Unidentified Insurance
		- Unidentified Court
		- Unidentified Lienor
		- Unidentified School
		- Unidentified Employer
		- from [names]
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


---
exec AddBreadcrumbsToTable 'sma_MST_OrgContacts'
go

alter table [sma_MST_OrgContacts] alter column saga INT
go
---

/* ------------------------------------------------------------------------------
Insert Organization Contacts
*/ ------------------------------------------------------------------------------
alter table [sma_MST_OrgContacts] disable trigger all
go
-- Unidentified Medical Provider
if not exists (
	 select
		 *
	 from [sma_MST_OrgContacts]
	 where consName = 'Unidentified Medical Provider'
	)
begin
	insert into [sma_MST_OrgContacts]
		(
			[consName],
			[connContactCtg],
			[connContactTypeID],
			[connRecUserID],
			[condDtCreated]
		)
		select
			'Unidentified Medical Provider' as [consname],
			2								as [conncontactctg],
			(
			 select
				 octnOrigContactTypeID
			 from [sma_MST_OriginalContactTypes]
			 where octnContactCtgID = 2
				 and octsDscrptn = 'Hospital'
			)								as [conncontacttypeid],
			368								as [connrecuserid],
			GETDATE()						as [conddtcreated]
end

go

-- Unidentified Insurance
if not exists (
	 select
		 *
	 from [sma_MST_OrgContacts]
	 where consName = 'Unidentified Insurance'
	)
begin
	insert into [sma_MST_OrgContacts]
		(
			[consName],
			[connContactCtg],
			[connContactTypeID],
			[connRecUserID],
			[condDtCreated]
		)
		select
			'Unidentified Insurance' as [consname],
			2						 as [conncontactctg],
			(
			 select
				 octnOrigContactTypeID
			 from [sma_MST_OriginalContactTypes]
			 where octnContactCtgID = 2
				 and octsDscrptn = 'Insurance Company'
			)						 as [conncontacttypeid],
			368						 as [connrecuserid],
			GETDATE()				 as [conddtcreated]
end

go

-- Unidentified Court
if not exists (
	 select
		 *
	 from [sma_MST_OrgContacts]
	 where consName = 'Unidentified Court'
	)
begin
	insert into [sma_MST_OrgContacts]
		(
			[consName],
			[connContactCtg],
			[connContactTypeID],
			[connRecUserID],
			[condDtCreated]
		)
		select
			'Unidentified Court' as [consname],
			2					 as [conncontactctg],
			(
			 select
				 octnOrigContactTypeID
			 from [sma_MST_OriginalContactTypes]
			 where octnContactCtgID = 2
				 and octsDscrptn = 'Court'
			)					 as [conncontacttypeid],
			368					 as [connrecuserid],
			GETDATE()			 as [conddtcreated]
end

go

-- Unidentified Lienor
if not exists (
	 select
		 *
	 from [sma_MST_OrgContacts]
	 where consName = 'Unidentified Lienor'
	)
begin
	insert into [sma_MST_OrgContacts]
		(
			[consName],
			[connContactCtg],
			[connContactTypeID],
			[connRecUserID],
			[condDtCreated]
		)
		select
			'Unidentified Lienor' as [consname],
			2					  as [conncontactctg],
			(
			 select
				 octnOrigContactTypeID
			 from [sma_MST_OriginalContactTypes]
			 where octnContactCtgID = 2
				 and octsDscrptn = 'General'
			)					  as [conncontacttypeid],
			368					  as [connrecuserid],
			GETDATE()			  as [conddtcreated]
end

go

-- Unidentified School
if not exists (
	 select
		 *
	 from [sma_MST_OrgContacts]
	 where consName = 'Unidentified School'
	)
begin
	insert into [sma_MST_OrgContacts]
		(
			[consName],
			[connContactCtg],
			[connContactTypeID],
			[connRecUserID],
			[condDtCreated]
		)
		select
			'Unidentified School' as [consname],
			2					  as [conncontactctg],
			(
			 select
				 octnOrigContactTypeID
			 from [sma_MST_OriginalContactTypes]
			 where octnContactCtgID = 2
				 and octsDscrptn = 'General'
			)					  as [conncontacttypeid],
			368					  as [connrecuserid],
			GETDATE()			  as [conddtcreated]
end

go

-- Unidentified Employer
if not exists (
	 select
		 *
	 from [sma_MST_OrgContacts]
	 where consName = 'Unidentified Employer'
	)
begin
	insert into [sma_MST_OrgContacts]
		(
			[consName],
			[connContactCtg],
			[connContactTypeID],
			[connRecUserID],
			[condDtCreated]
		)
		select
			'Unidentified Employer' as [consname],
			2						as [conncontactctg],
			(
			 select
				 octnOrigContactTypeID
			 from [sma_MST_OriginalContactTypes]
			 where octnContactCtgID = 2
				 and octsDscrptn = 'General'
			)						as [conncontacttypeid],
			368						as [connrecuserid],
			GETDATE()				as [conddtcreated]
end

go

-- Insert from [names]
insert into [sma_MST_OrgContacts]
	(
	[consName],
	[consWorkPhone],
	[consComments],
	[connContactCtg],
	[connContactTypeID],
	[connRecUserID],
	[condDtCreated],
	[conbStatus],
	[saga],
	[source_id],
	[source_db],
	[source_ref]
	)
	select
		n.[last_long_name] as [consname],
		n.[work_phone]	   as [consworkphone],
		case
			when ISNULL(n.[aka_full], '') <> '' and
				ISNULL(n.[email], '') = ''
				then (
					'AKA: ' + n.[aka_full]
					)
			when ISNULL(n.[aka_full], '') = '' and
				ISNULL(n.[email], '') <> ''
				then (
					'EMAIL: ' + n.[email]
					)
			when ISNULL(n.[aka_full], '') <> '' and
				ISNULL(n.[email], '') <> ''
				then (
					'AKA: ' + n.[aka_full] + ' EMAIL: ' + n.[email]
					)
		end				   as [conscomments],
		2				   as [conncontactctg],
		(
			select
				octnOrigContactTypeID
			from.[sma_MST_OriginalContactTypes]
			where octsDscrptn = 'General'
				and octnContactCtgID = 2
		)				   as [conncontacttypeid],

		368				   as [connrecuserid],
		GETDATE()		   as [conddtcreated],
		1				   as [conbstatus],
		n.[names_id]	   as [saga],
		null			   as [source_id],
		'needles'		   as [source_db],
		'names'			   as [source_ref]
	from [Needles].[dbo].[names] n
	where n.[person] <> 'Y'
go

---
alter table [sma_MST_OrgContacts] ENABLE trigger all
go
---