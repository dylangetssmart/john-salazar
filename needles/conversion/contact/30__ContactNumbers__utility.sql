/*---
group: setup
order: 
description: Update contact types for attorneys
---*/

/* ###################################################################################
description: Update contact phone numbers
steps:
	- [sma_MST_ContactNoType]
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

-- 
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