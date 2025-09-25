/*---
description: Insert individual contacts from [staff] that don't match existing users
steps:
	- Insert [sma_MST_IndvContacts]
usage_instructions:
	-
dependencies:
    - [JohnSalazar_Needles]..staff
    - [sma_MST_IndvContacts]
    - [sma_MST_OriginalContactTypes] (for default contact type)
notes: >
	This script links individual contacts back to the [staff] table using source_id, 
    and stamps the source_db as 'needles'. The 'aadmin' account is excluded. 
    Only contacts that do not already exist are inserted to prevent duplicates.
---*/


use [JohnSalazar_SA]
go

alter table [sma_MST_IndvContacts] disable trigger all
go

/* --------------------------------------------------------------------------------------------------------------
Insert Individual Contacts from [staff]
*/
insert into [sma_MST_IndvContacts]
	(
		[cinsPrefix],
		[cinsSuffix],
		[cinsFirstName],
		[cinsMiddleName],
		[cinsLastName],
		[cinsHomePhone],
		[cinsWorkPhone],
		[cinsSSNNo],
		[cindBirthDate],
		[cindDateOfDeath],
		[cinnGender],
		[cinsMobile],
		[cinsComments],
		[cinnContactCtg],
		[cinnContactTypeID],
		[cinnRecUserID],
		[cindDtCreated],
		[cinbStatus],
		[cinbPreventMailing],
		[cinsNickName],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		LEFT(s.prefix, 20)											 as [cinsprefix],
		LEFT(s.suffix, 10)											 as [cinssuffix],
		LEFT(ISNULL(first_name, dbo.get_firstword(s.full_name)), 30) as [cinsfirstname],
		LEFT(s.middle_name, 100)									 as [cinsmiddlename],
		LEFT(ISNULL(last_name, dbo.get_lastword(s.full_name)), 40)	 as [cinslastname],
		null														 as [cinshomephone],
		LEFT(s.phone_number, 20)									 as [cinsworkphone],
		null														 as [cinsssnno],
		null														 as [cindbirthdate],
		null														 as [cinddateofdeath],
		case s.sex
			when 'M' then 1
			when 'F' then 2
			else 0
		end															 as [cinngender],
		LEFT(s.mobil_phone, 20)										 as [cinsmobile],
		null														 as [cinscomments],
		1															 as [cinncontactctg],
		(
		 select
			 octnOrigContactTypeID
		 from sma_MST_OriginalContactTypes
		 where octsDscrptn = 'General'
			 and octnContactCtgID = 1
		)															 as [cinncontacttypeid],
		368															 as [cinnrecuserid],
		GETDATE()													 as [cinddtcreated],
		1															 as [cinbstatus],
		0															 as [cinbpreventmailing],
		CONVERT(VARCHAR(15), s.full_name)							 as [cinsnickname],
		null														 as [saga],
		s.staff_code												 as [source_id],
		'needles'													 as [source_db],
		'staff'														 as [source_ref]
	from [JohnSalazar_Needles]..staff s
	left join [sma_MST_IndvContacts] ind
		on ind.source_id = s.staff_code
	where
		ind.source_id is null         -- only create contacts that don't exist
		and s.staff_code not in ('aadmin');  -- exclude system user

go

alter table [sma_MST_IndvContacts] enable trigger all
go