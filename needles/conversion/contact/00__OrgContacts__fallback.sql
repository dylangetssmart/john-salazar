/*---
group: setup
order: 
description:
---*/

/* ###################################################################################
description: Create unidentified contacts to be used as fallbacks where applicable
steps:
	- Insert [sma_MST_OrgContacts] fallback contacts
		- Unidentified Medical Provider
		- Unidentified Insurance
		- Unidentified Court
		- Unidentified Lienor
		- Unidentified School
		- Unidentified Employer
usage_instructions:
	-
dependencies:
	- 
notes:
	-
*/

use VanceLawFirm_SA
go

/* --------------------------------------------------------------------------------------------------------------
[sma_MST_OrgContacts] Unidentified Contacts
*/

---------------------------------------------------
-- [1] - Unidentified Medical Provider
---------------------------------------------------
if not exists (
		select
			*
		from [sma_MST_OrgContacts]
		where consName = 'Unidentified Medical Provider'
	)
begin
	insert into [sma_MST_OrgContacts]
		(
		[consName], [connContactCtg], [connContactTypeID], [connRecUserID], [condDtCreated]
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

---------------------------------------------------
-- [2] - Unidentified Insurance
---------------------------------------------------
if not exists (
		select
			*
		from [sma_MST_OrgContacts]
		where consName = 'Unidentified Insurance'
	)
begin
	insert into [sma_MST_OrgContacts]
		(
		[consName], [connContactCtg], [connContactTypeID], [connRecUserID], [condDtCreated]
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

---------------------------------------------------
-- [3] - Unidentified Court
---------------------------------------------------
if not exists (
		select
			*
		from [sma_MST_OrgContacts]
		where consName = 'Unidentified Court'
	)
begin
	insert into [sma_MST_OrgContacts]
		(
		[consName], [connContactCtg], [connContactTypeID], [connRecUserID], [condDtCreated]
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

---------------------------------------------------
-- [4] - Unidentified Lienor
---------------------------------------------------
if not exists (
		select
			*
		from [sma_MST_OrgContacts]
		where consName = 'Unidentified Lienor'
	)
begin
	insert into [sma_MST_OrgContacts]
		(
		[consName], [connContactCtg], [connContactTypeID], [connRecUserID], [condDtCreated]
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

---------------------------------------------------
-- [5] - Unidentified School
---------------------------------------------------
if not exists (
		select
			*
		from [sma_MST_OrgContacts]
		where consName = 'Unidentified School'
	)
begin
	insert into [sma_MST_OrgContacts]
		(
		[consName], [connContactCtg], [connContactTypeID], [connRecUserID], [condDtCreated]
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

---------------------------------------------------
-- [6] - Unidentified Employer
---------------------------------------------------
if not exists (
		select
			*
		from [sma_MST_OrgContacts]
		where consName = 'Unidentified Employer'
	)
begin
	insert into [sma_MST_OrgContacts]
		(
		[consName], [connContactCtg], [connContactTypeID], [connRecUserID], [condDtCreated]
		)
		select
			'Unidentified Employer' as [consname],
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

