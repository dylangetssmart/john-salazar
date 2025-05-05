use [JohnSalazar_SA]
go


if exists (
		select
			*
		from sys.tables
		where name = 'NeedlesUserFields'
			and type = 'U'
	)
begin
	drop table NeedlesUserFields
end
-------------------------------------------
--CREATE TABLE NEEDLES USER FIELDS
-------------------------------------------

create table NeedlesUserFields (
	field_num	   INT,
	field_title	   VARCHAR(30),
	column_name	   VARCHAR(30),
	field_Type	   VARCHAR(20),
	field_len	   VARCHAR(10),
	mini_Dir	   VARCHAR(50),
	UDFType		   VARCHAR(30),
	DropDownValues VARCHAR(MAX)
)
-------------------------------------------------------------------
--BUILD USER FIELDS PLUS DROP DOWNS FOR UDF DEFINITION PURPOSES
-------------------------------------------------------------------
insert into NeedlesUserFields
	(
		field_num,
		field_title,
		column_name,
		field_Type,
		field_len,
		mini_Dir,
		UDFType
	)
	select
		field_num,
		field_title,
		column_name,
		field_Type,
		case
			when field_Type in ('number', 'money')
				then CONVERT(VARCHAR, field_len) + ',2'
			else CONVERT(VARCHAR, field_len)
		end,
		Mini_Dir_Title,
		case
			when field_Type in ('name', 'alpha', 'state', 'valuecode', 'staff')
				then 'Text'
			when field_Type in ('number', 'money')
				then 'Number'
			when field_Type in ('boolean', 'checkbox')
				then 'CheckBox'
			when field_Type = 'minidir'
				then 'Dropdown'
			when field_Type = 'Date'
				then 'Date'
			when field_Type = 'Time'
				then 'Time'
			else field_Type
		end
	--Select *
	from Skolrood_Needles..[user_case_fields]


-----------------------------------------------------
--CURSOR TO FILL IN DROP DOWN VALUES FOR MINI DIRS
-----------------------------------------------------
declare @miniDir VARCHAR(30),
		@fieldTitle VARCHAR(50),
		@numberCt INT,
		@code VARCHAR(30)

declare userFields_cursor cursor for select
	mini_Dir,
	field_title
from NeedlesUserFields
where field_type = 'minidir'

open userFields_cursor
fetch next from userFields_cursor into @miniDir, @fieldTitle
while @@FETCH_STATUS = 0
begin

select
	IDENTITY(INT, 1, 1) as Number,
	gd.code
into #values
from Skolrood_Needles..mini_general_dir gd
join Skolrood_Needles..mini_dir_list dl
	on gd.num_assigned = dl.dir_key
where
	dir_name = @miniDir


set @numberCt = (
	select
		MAX(number)
	from #values
) while @numberCt >= 1
begin

set @code = (
	select
		code
	from #values
	where Number = @numberCt
) update NeedlesUserFields
set DropDownValues =
case
	when DropDownValues is null
		then @code
	else DropDownValues + '~' + @code
end
where mini_Dir = @miniDir
and field_title = @fieldTitle

set @numberCt = @numberCt - 1

end

drop table #values

fetch next from userFields_cursor into @miniDir, @fieldTitle
end
close userFields_cursor;
deallocate userFields_cursor;


--select * from NeedlesUserFields

/*
select dl.dir_name, item_id, gd.code
from Skolrood_Needles..mini_general_dir gd
JOIN Skolrood_Needles..mini_dir_list dl on gd.num_assigned = dl.dir_key
where dir_name = 'Living with'  --(Field_title)
*/