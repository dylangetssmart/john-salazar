/*---
group: load
order: 3
description: Update contact types for attorneys
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
			when 'M'
				then 1
			when 'F'
				then 2
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
	--select *
	from [[JohnSalazar_Needles]]..staff s
	left join conversion.imp_user_map m
		on s.staff_code = m.StaffCode
	left join [sma_MST_IndvContacts] ind
		on m.SAContactID = ind.cinnContactID
	where
		m.StaffCode is null  -- Staff does not exist in imp_user_map
		and (ind.cinnContactID is null or m.SAContactID is null)  -- No contact in sma_MST_IndvContacts
		and s.staff_code not in ('aadmin');  -- Exclude 'aadmin'

/* ds 2025-02-07
Identify staff members that are not in imp_user_map and do not have an individual contact


from [[JohnSalazar_Needles]].[dbo].[staff] s
left join [sma_MST_IndvContacts] indv
on indv.source_id = s.staff_code
where cinnContactID is null
*/
go

alter table [sma_MST_IndvContacts] enable trigger all
go