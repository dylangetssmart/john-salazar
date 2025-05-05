USE [Needles]
GO

--drop table CustomFieldUsage_intake
SELECT DISTINCT
	m.ref_num																																																																  AS field_num
   ,m.ref_num_location
   ,m.field_title
   ,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(field_Title, '(', ''), ')', ''), ' ', '_'), '.', ''), '?', ''), ',', ''), '-', ''), '~', ''), '\', ''), '/', ''), '''', ''), '&', ''), ':', ''), '`', '') AS column_name
   ,field_type
   ,'case_intake'																																																															  AS tablename
   ,0																																																																		  AS ValueCount INTO CustomFieldUsage_intake
FROM [dbo].[user_case_intake_matter] m
WHERE field_type <> 'label'

--CURSOR
DECLARE @table VARCHAR(100)
	   ,@Field VARCHAR(100)
	   ,@DataType VARCHAR(20)
	   ,@sql VARCHAR(5000)

DECLARE FieldUsage_Cursor CURSOR FOR SELECT
	tablename
   ,column_name
   ,Field_Type
FROM CustomFieldUsage_intake

OPEN FieldUsage_Cursor
FETCH NEXT FROM FieldUsage_Cursor INTO @table, @field, @datatype
WHILE @@FETCH_STATUS = 0
BEGIN
IF @datatype IN ('varchar', 'nvarchar', 'date', 'datetime2', 'bit', 'ntext', 'datetime', 'time', 'Name', 'alpha', 'boolean', 'checkbox', 'minidir', 'staff', 'state', 'time', 'valuecode')
BEGIN
	SET @SQL = 'UPDATE CustomFieldUsage_intake SET ValueCount = ( Select count(*) FROM [' + @table + '] t WHERE isnull([' + @field + '],'''')<>'''') ' +
	'WHERE TableName = ''' + @table + ''' and Column_Name = ''' + @Field + ''''
END
ELSE
IF @datatype IN ('int', 'decimal', 'money', 'float', 'smallint', 'tinyint', 'numeric', 'bigint', 'smallint')
BEGIN

	SET @SQL = 'UPDATE CustomFieldUsage_intake SET ValueCount = ( Select count(*) FROM [' + @table + '] t WHERE isnull([' + @field + '],0)<>0 ) ' +
	'WHERE TableName = ''' + @table + ''' and Column_Name = ''' + @Field + ''''
END

EXEC (@sql)
--select @sql


FETCH NEXT FROM FieldUsage_Cursor INTO @table, @field, @datatype
END
CLOSE FieldUsage_Cursor;
DEALLOCATE FieldUsage_Cursor;


--SELECT
--	*
--FROM CustomFieldUsage_intake
--ORDER BY tablename, field_num

