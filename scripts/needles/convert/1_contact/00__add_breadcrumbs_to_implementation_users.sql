/*---
description: Add breadcrumbs to users and individual contacts created in the implementation system
steps:
	- Update [sma_MST_Users]
	- Update [sma_MST_IndvContacts]
usage_instructions:
	-
dependencies:
	- 
notes: >
	If users were created manually in the implementation system by the client and training team,
	we need to stamp those users and their associated individual contact with breadcrumbs (source_id)
	linking back to the [staff] table so that they can be properly assigned across the system.
---*/


use [JohnSalazar_SA]
go

exec AddBreadcrumbsToTable 'sma_MST_Users'
exec AddBreadcrumbsToTable 'sma_MST_IndvContacts'
go

/*===========================================================
 Update [sma_MST_Users]
===========================================================*/

--  Stamp all users with source_db = 'implementation'
update u
set u.source_db = 'implementation'
from sma_MST_Users u
where u.source_db is null;

-- Update sma_MST_Users.source_id by matching names
-- Inline parse of staff.full_name to ignore middle initials
update u
set u.source_id = s.staff_code
from sma_MST_Users u
join sma_MST_IndvContacts smic
    on smic.cinnContactID = u.usrnContactID
join JohnSalazar_Needles..staff s
    on smic.cinsFirstName = LEFT(s.full_name, CHARINDEX(' ', s.full_name + ' ') - 1)
   and smic.cinsLastName  = RIGHT(s.full_name, CHARINDEX(' ', REVERSE(s.full_name) + ' ') - 1)
where u.source_id is null;


/*===========================================================
 Manual adjustments for non-matches
===========================================================*/
update u
set u.source_id = 'VIRIA'
from sma_MST_Users u
where u.usrnUserID = 383


/*===========================================================
 Update [sma_MST_IndvContacts]
===========================================================*/

-- Stamp all users with source_db = 'implementation'
update indv
set indv.source_db = 'implementation'
from sma_MST_IndvContacts indv
where indv.source_db is null;

-- Sync sma_MST_IndvContacts.source_id from Users
update indv
set indv.source_id = u.source_id
from sma_MST_IndvContacts indv
join sma_MST_Users u
    on u.usrnContactID = indv.cinnContactID
where indv.source_id is null
  and u.source_id is not null;




/*===========================================================
 Verification Queries
===========================================================*/

-- Show how staff.full_name is parsed into first/last
select 
    s.staff_code,
    s.full_name,
    LEFT(s.full_name, CHARINDEX(' ', s.full_name + ' ') - 1) as ParsedFirstName,
    RIGHT(s.full_name, CHARINDEX(' ', REVERSE(s.full_name) + ' ') - 1) as ParsedLastName
from JohnSalazar_Needles..staff s
order by s.full_name;

-- Show users with mapped source_id
select 
    u.usrsLoginID,
    u.source_id,
    smic.cinsFirstName,
    smic.cinsLastName,
    s.full_name as staff_fullname,
    LEFT(s.full_name, CHARINDEX(' ', s.full_name + ' ') - 1) as ParsedFirstName,
    RIGHT(s.full_name, CHARINDEX(' ', REVERSE(s.full_name) + ' ') - 1) as ParsedLastName
from sma_MST_Users u
join sma_MST_IndvContacts smic
    on smic.cinnContactID = u.usrnContactID
left join JohnSalazar_Needles..staff s
    on smic.cinsFirstName = LEFT(s.full_name, CHARINDEX(' ', s.full_name + ' ') - 1)
   and smic.cinsLastName  = RIGHT(s.full_name, CHARINDEX(' ', REVERSE(s.full_name) + ' ') - 1)
where u.source_id is not null
order by u.usrsLoginID;

-- Show contacts with mapped source_id
select 
    smic.cinnContactID,
    smic.cinsFirstName,
    smic.cinsLastName,
    smic.source_id
from sma_MST_IndvContacts smic
where smic.source_id is not null
order by smic.cinnContactID;