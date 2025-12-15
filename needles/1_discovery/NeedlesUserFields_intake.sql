use [Needles]
go

-- Drop table if exists
if OBJECT_ID('dbo.NeedlesUserFields_intake', 'U') is not null
	drop table dbo.NeedlesUserFields_intake;

go

-- Create table with sufficient column sizes
create table NeedlesUserFields_intake (
	table_name	   VARCHAR(100) null,
	column_name	   VARCHAR(100),
	field_title	   VARCHAR(100),
	field_num	   INT,
	field_type	   VARCHAR(50),
	field_len	   VARCHAR(20),
	mini_dir_id	   INT			null,
	mini_dir_title VARCHAR(100) null,
	UDFType		   VARCHAR(50),
	DropDownValues VARCHAR(MAX),
	ValueCount	   INT			default 0,
	SampleData	   NVARCHAR(MAX)
);
go


insert into NeedlesUserFields_intake
	(
		field_num,
		field_title,
		mini_dir_id,
		column_name,
		field_type,
		table_name,
		ValueCount,
		UDFType,
		field_len,
		DropDownValues
	)
	select distinct
		m.ref_num																																																																  as field_num,
		m.field_title,
		m.mini_dir_id,
		-- Generate the cleaned column name
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(field_Title, '(', ''), ')', ''), ' ', '_'), '.', ''), '?', ''), ',', ''), '-', ''), '~', ''), '\', ''), '/', ''), '''', ''), '&', ''), ':', ''), '`', '') as column_name,

		m.field_type,
		'case_intake'																																																															  as table_name,
		0																																																																		  as ValueCount,

		-- UDFType
		case
			when m.field_type in ('alpha', 'state', 'valuecode', 'staff') then 'Text'
			when m.field_type in ('number', 'money') then 'Number'
			when m.field_type in ('boolean', 'checkbox') then 'CheckBox'
			when m.field_type = 'minidir' then 'Dropdown'
			when m.field_type = 'Date' then 'Date'
			when m.field_type = 'Time' then 'Time'
			when m.field_type = 'name' then 'Contact'
			else 'Text'
		end																																																																		  as UDFType,

		-- field_len
		case
			when m.field_type in ('number', 'money') then CONVERT(VARCHAR, m.field_len) + ',2'
			else CONVERT(VARCHAR, m.field_len)
		end																																																																		  as field_len,

		''																																																																		  as DropDownValues
	from [dbo].[user_case_intake_matter] m
	where
		field_type <> 'label';

--insert into NeedlesUserFields_intake
--select distinct
--	m.ref_num																																																																  as field_num,
--	m.ref_num_location,
--	m.field_title,
--	m.mini_dir_id,
--	m.mini_dir_id_location,
--	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(field_Title, '(', ''), ')', ''), ' ', '_'), '.', ''), '?', ''), ',', ''), '-', ''), '~', ''), '\', ''), '/', ''), '''', ''), '&', ''), ':', ''), '`', '') as column_name,
--	field_type,
--	'case_intake'																																																															  as table_name,
--	0																																																																		  as ValueCount,
--	case
--		when m.field_type in ('alpha', 'state', 'valuecode', 'staff') then 'Text'
--		when m.field_type in ('number', 'money') then 'Number'
--		when m.field_type in ('boolean', 'checkbox') then 'CheckBox'
--		when m.field_type = 'minidir' then 'Dropdown'
--		when m.field_type = 'Date' then 'Date'
--		when m.field_type = 'Time' then 'Time'
--		when m.field_type = 'name' then 'Contact'
--		else m.field_type
--	end																																																																		  as UDFType,
--	case
--		when m.field_type in ('number', 'money') then CONVERT(VARCHAR, m.field_len) + ',2'
--		else CONVERT(VARCHAR, m.field_len)
--	end																																																																		  as field_len,
--	''																																																																		  as DropDownValues
--from [dbo].[user_case_intake_matter] m
--where
--	field_type <> 'label'

--CURSOR
declare @table VARCHAR(100),
		@Field VARCHAR(100),
		@DataType VARCHAR(20),
		@sql VARCHAR(5000)

declare FieldUsage_Cursor cursor for select
	table_name,
	column_name,
	Field_Type
from NeedlesUserFields_intake

open FieldUsage_Cursor
fetch next from FieldUsage_Cursor into @table, @field, @datatype
while @@FETCH_STATUS = 0
begin

if COL_LENGTH('[Needles].dbo.case_intake', @field) is not null
begin

	if @datatype in ('varchar', 'nvarchar', 'date', 'datetime2', 'bit', 'ntext', 'datetime', 'time', 'Name', 'alpha', 'boolean', 'checkbox', 'minidir', 'staff', 'state', 'time', 'valuecode')
	begin
		set @SQL = 'UPDATE NeedlesUserFields_intake
						SET ValueCount = (
							Select count(*)
							FROM [' + @table + '] t
							WHERE isnull(t.[' + @field + '],'''') <> ''''
							) ' +
		'WHERE Table_Name = ''' + @table + ''' and Column_Name = ''' + @Field + ''''
	end
	else
	if @datatype in ('int', 'decimal', 'money', 'float', 'smallint', 'tinyint', 'numeric', 'bigint', 'smallint')
	begin

		set @SQL = 'UPDATE NeedlesUserFields_intake
						SET ValueCount = (
							Select count(*)
							FROM [' + @table + '] t
							WHERE isnull(t.[' + @field + '],0) <> 0
							) ' +
		'WHERE Table_Name = ''' + @table + ''' and Column_Name = ''' + @Field + ''''
	end

end

exec (@sql)
--select @sql


fetch next from FieldUsage_Cursor into @table, @field, @datatype
end
close FieldUsage_Cursor;
deallocate FieldUsage_Cursor;


-- Populate DropDownValues for mini directories
declare @miniDir VARCHAR(50),
		@fieldTitle VARCHAR(50);

declare curMiniDir cursor for select
	mini_dir_id,
	field_title
from NeedlesUserFields_intake
where field_type = 'minidir';

open curMiniDir;
fetch next from curMiniDir into @miniDir, @fieldTitle;

while @@FETCH_STATUS = 0
begin
select
	IDENTITY(int, 1, 1) as Number,
	gd.code
into #values
from [Needles].dbo.mini_general_dir gd
join [Needles].dbo.mini_dir_list dl
	on gd.num_assigned = dl.dir_key
where
	dl.dir_key = @miniDir;

declare @numberCt INT = (select MAX(Number) from #values);
declare @code VARCHAR(50);

while @numberCt >= 1
begin
select
	@code = code
from #values
where
	Number = @numberCt;

update NeedlesUserFields_intake
set DropDownValues =
case
	when DropDownValues is null then @code
	else DropDownValues + '~' + @code
end
where mini_dir_id = @miniDir
and field_title = @fieldTitle;

set @numberCt = @numberCt - 1;
end

drop table #values;

fetch next from curMiniDir into @miniDir, @fieldTitle;
end

close curMiniDir;
deallocate curMiniDir;
go



--select * from NeedlesUserFields

-- Populate ValueCount dynamically (skip missing tables)
--DECLARE @sql NVARCHAR(MAX), @table NVARCHAR(100), @field NVARCHAR(100), @caseid NVARCHAR(50), @datatype NVARCHAR(50);

--DECLARE curValue CURSOR FOR
--SELECT table_name, column_name, caseid_col, field_type
--FROM dbo.NeedlesUserFields
--WHERE table_name IS NOT NULL;

--OPEN curValue;
--FETCH NEXT FROM curValue INTO @table, @field, @caseid, @datatype;

--WHILE @@FETCH_STATUS = 0
--BEGIN
--    IF OBJECT_ID('[Needles].dbo.' + @table, 'U') IS NOT NULL
--    BEGIN
--        IF @datatype IN ('varchar','nvarchar','date','datetime2','bit','ntext','datetime','time','name','alpha','boolean','checkbox','minidir','staff','state','valuecode')
--        BEGIN
--            SET @sql = 'UPDATE dbo.NeedlesUserFields SET ValueCount = (' +
--                       'SELECT COUNT(*) FROM [Needles].dbo.' + @table + ' t ' +
--                       'JOIN [Needles].dbo.cases_Indexed ci ON ci.CaseNum = t.[' + @caseid + '] ' +
--                       'WHERE ISNULL([' + @field + '], '''') <> '''') ' +
--                       'WHERE table_name = ''' + @table + ''' AND column_name = ''' + @field + '''';
--        END
--        ELSE
--        BEGIN
--            SET @sql = 'UPDATE dbo.NeedlesUserFields SET ValueCount = (' +
--                       'SELECT COUNT(*) FROM [Needles].dbo.' + @table + ' t ' +
--                       'JOIN [Needles].dbo.cases_Indexed ci ON ci.CaseNum = t.[' + @caseid + '] ' +
--                       'WHERE ISNULL([' + @field + '], 0) <> 0 ) ' +
--                       'WHERE table_name = ''' + @table + ''' AND column_name = ''' + @field + '''';
--        END

--        EXEC(@sql);
--    END

--    FETCH NEXT FROM curValue INTO @table, @field, @caseid, @datatype;
--END
--CLOSE curValue;
--DEALLOCATE curValue;
--GO

----select * from NeedlesUserFields

---- Populate SampleData dynamically
--DECLARE @table NVARCHAR(100), 
--        @field NVARCHAR(100), 
--        @caseid NVARCHAR(50), 
--        @sql NVARCHAR(MAX);

--DECLARE sampleDataCursor CURSOR FOR
--SELECT table_name, column_name, caseid_col
--FROM dbo.NeedlesUserFields
--WHERE table_name IS NOT NULL;

--OPEN sampleDataCursor;
--FETCH NEXT FROM sampleDataCursor INTO @table, @field, @caseid;

--WHILE @@FETCH_STATUS = 0
--BEGIN
--    -- Only proceed if the table exists
--    IF OBJECT_ID('[Needles].dbo.' + @table, 'U') IS NOT NULL
--    BEGIN
--        SET @sql = '
--        UPDATE dbo.NeedlesUserFields
--        SET SampleData = (
--            SELECT TOP 1 TRY_CAST([' + @field + '] AS NVARCHAR(MAX))
--            FROM [Needles].dbo.' + @table + '
--            WHERE TRY_CAST([' + @field + '] AS NVARCHAR(MAX)) IS NOT NULL
--        )
--        WHERE table_name = ''' + @table + ''' AND column_name = ''' + @field + '''';

--        EXEC sp_executesql @sql;
--    END

--    FETCH NEXT FROM sampleDataCursor INTO @table, @field, @caseid;
--END

--CLOSE sampleDataCursor;
--DEALLOCATE sampleDataCursor;
--GO

--select * from NeedlesUserFields order by table_name, column_name