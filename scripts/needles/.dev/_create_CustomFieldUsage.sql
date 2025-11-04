/* ######################################################################################
description: Creates table [CustomFieldUsage] and seeds it with all fields from the needles user tabs. Includes sample data.

steps:
	- Create CustomFieldUsage
	- Seed CustomFieldUsage
	- Create CustomFieldSampleData
	- Output results

usage_instructions:
	- update hardcoded values in #TempVariables

dependencies:
	- 

notes:
	- 
#########################################################################################
*/

use JohnSalazar_SA
go


if OBJECT_ID('dbo.CustomFieldUsage', 'U') is not null
	drop table dbo.CustomFieldUsage;

select
	A.*,
	0 as ValueCount
into CustomFieldUsage
from (
	select
		F.*,
		M.tablename,
		m.caseid
	from [JohnSalazar_Needles].[dbo].[user_case_fields] F
	join (
		select ref_num, 'user_case_data'			as tablename, 'casenum'		as caseid from [JohnSalazar_Needles].[dbo].[user_case_matter]
		union select ref_num, 'user_tab_data'		as tablename, 'case_id'		as caseid from [JohnSalazar_Needles].[dbo].[user_tab_matter]
		union select ref_num, 'user_tab2_data'		as tablename, 'case_id'		as caseid from [JohnSalazar_Needles].[dbo].[user_tab2_matter]
		union select ref_num, 'user_tab3_data'		as tablename, 'case_id'		as caseid from [JohnSalazar_Needles].[dbo].[user_tab3_matter]
		union select ref_num, 'user_tab4_data'		as tablename, 'case_id'		as caseid from [JohnSalazar_Needles].[dbo].[user_tab4_matter]
		union select ref_num, 'user_tab5_data'		as tablename, 'case_id'		as caseid from [JohnSalazar_Needles].[dbo].[user_tab5_matter]
		union select ref_num, 'user_tab6_data'		as tablename, 'case_id'		as caseid from [JohnSalazar_Needles].[dbo].[user_tab6_matter]
		union select ref_num, 'user_tab7_data'		as tablename, 'case_id'		as caseid from [JohnSalazar_Needles].[dbo].[user_tab7_matter]
		union select ref_num, 'user_tab8_data'		as tablename, 'case_id'		as caseid from [JohnSalazar_Needles].[dbo].[user_tab8_matter]
		union select ref_num, 'user_tab9_data'		as tablename, 'case_id'		as caseid from [JohnSalazar_Needles].[dbo].[user_tab9_matter]
		union select ref_num, 'user_tab10_data'		as tablename, 'case_id'		as caseid from [JohnSalazar_Needles].[dbo].[user_tab10_matter]
		union select ref_num, 'user_insurance_data' as tablename, 'casenum'		as caseid from [JohnSalazar_Needles].[dbo].[user_case_insurance_matter]
		union select ref_num, 'user_party_data'		as tablename, 'case_id'		as caseid from [JohnSalazar_Needles].[dbo].[user_party_matter]
		union select ref_num, 'user_value_data'		as tablename, 'case_id'		as caseid from [JohnSalazar_Needles].[dbo].[user_case_value_matter]
		union select ref_num, 'user_counsel_data'	as tablename, 'casenum'		as caseid from [JohnSalazar_Needles].[dbo].[user_case_counsel_matter]
	) M
	 on M.ref_num = F.field_num
) A
order by
	A.tablename,
	A.field_num
go

/*
2. Seed CustomFieldUsage
*/
declare @table VARCHAR(100),
		@Field VARCHAR(100),
		@caseid VARCHAR(20),
		@DataType VARCHAR(20),
		@sql VARCHAR(5000)

declare FieldUsage_Cursor cursor for select
	TableName,
	Column_Name,
	caseid,
	Field_Type
from CustomFieldUsage

open FieldUsage_Cursor
fetch next from FieldUsage_Cursor into @table, @field, @caseid, @datatype
while @@FETCH_STATUS = 0
begin

if @datatype in (
	'varchar'
	, 'nvarchar'
	, 'date'
	, 'datetime2'
	, 'bit'
	, 'ntext'
	, 'datetime'
	, 'time'
	, 'Name'
	, 'alpha'
	, 'boolean'
	, 'checkbox'
	, 'minidir'
	, 'staff'
	, 'state'
	, 'time'
	, 'valuecode'
	)
begin
	set @SQL = 'UPDATE CustomFieldUsage SET ValueCount = ( Select count(*) FROM cases_Indexed ci JOIN [' + @table + '] t on [ci].CaseNum = t.[' + @caseid + '] WHERE isnull([' + @field + '],'''')<>'''') ' +
	'WHERE TableName = ''' + @table + ''' and Column_Name = ''' + @Field + ''''
end
else
if @datatype in (
	'int'
	, 'decimal'
	, 'money'
	, 'float'
	, 'smallint'
	, 'tinyint'
	, 'numeric'
	, 'bigint'
	, 'smallint'
	)
begin

	set @SQL = 'UPDATE CustomFieldUsage SET ValueCount = ( Select count(*) FROM cases_Indexed ci JOIN [' + @table + '] t on [ci].CaseNum = t.[' + @caseid + '] WHERE isnull([' + @field + '],0)<>0 ) ' +
	'WHERE TableName = ''' + @table + ''' and Column_Name = ''' + @Field + ''''
end

exec (@sql)

fetch next
from FieldUsage_Cursor
into
@table
, @field
, @caseid
, @datatype
end
close FieldUsage_Cursor;
deallocate FieldUsage_Cursor;

go


/*
3. Create CustomFieldSampleData
	3.1 - Create a cursor to iterate through all fields in [CustomFieldUsage]
	3.2 - Grab first non-null record for each field and insert into [CustomFieldSampleData]
*/

-- 3.1 CustomFieldSampleData
if OBJECT_ID('dbo.CustomFieldSampleData') is not null
begin
	drop table dbo.CustomFieldSampleData;
end

create table dbo.CustomFieldSampleData (
	column_name NVARCHAR(255),
	tablename   NVARCHAR(255),
	field_value NVARCHAR(MAX)
);

-- 3.2 CustomFieldUsage cursor
declare @column_name NVARCHAR(255),
		@tablename NVARCHAR(255);
declare customFieldCursor cursor for select
	column_name,
	tablename
from CustomFieldUsage;

declare @sampleDataSql NVARCHAR(MAX);

open customFieldCursor;

fetch next from customFieldCursor into @column_name, @tablename;

while @@FETCH_STATUS = 0
begin
set @sampleDataSql = 'INSERT INTO CustomFieldSampleData (column_name, tablename, field_value) ' +
'SELECT TOP 1 ''' + @column_name + ''', ''' + @tablename + ''', TRY_CAST([' + @column_name + '] AS NVARCHAR(MAX)) ' +
'FROM ' + @tablename +
' WHERE TRY_CAST([' + @column_name + '] AS NVARCHAR(MAX)) IS NOT NULL AND TRY_CAST([' + @column_name + '] AS NVARCHAR(MAX)) <> ''''';

print @sampleDataSql;

exec sp_executesql @sampleDataSql;

fetch next from customFieldCursor into @column_name, @tablename;
end;

close customFieldCursor;
deallocate customFieldCursor;


/* -------------------------------------------------------------------------------------------------
4. Output Results
*/

select
	[field_num],
	[field_num_location],
	[field_title],
	[field_type],
	[field_len],
	[mini_dir_id],
	[mini_dir_title],
	cfu.[column_name],
	[mini_dir_id_location],
	cfu.[tablename],
	[caseid],
	[ValueCount],
	CFSD.field_value as [Sample Data]
from CustomFieldUsage CFU
left join CustomFieldSampleData CFSD
	on CFU.column_name = CFSD.column_name
		and CFU.tablename = CFSD.tablename
order by CFU.tablename, CFU.field_num
