/*---
group: load
order: 1
description: Update contact types for attorneys
---*/

use VanceLawFirm_SA
go

/* --------------------------------------------------------------------------------------------------------------
Insert Org Contacts from [names]
*/

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
	from [VanceLawFirm_Needles].[dbo].[names] n
	where n.[person] <> 'Y'
go