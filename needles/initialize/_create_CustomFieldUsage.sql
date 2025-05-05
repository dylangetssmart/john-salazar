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

USE [Needles]
GO

/*
1. Create [CustomFieldUsage]
*/

IF OBJECT_ID('dbo.CustomFieldUsage', 'U') IS NOT NULL
    DROP TABLE dbo.CustomFieldUsage;

select A.*, 0 as ValueCount
INTO CustomFieldUsage
FROM (
		SELECT 
			F.*,
			M.tablename,
			m.caseid
			--ROW_NUMBER() over(partition by F.field_num order by F.field_num ) as rowindex
		FROM [dbo].[user_case_fields] F
		JOIN (
				select
					ref_num
					,'user_case_data' as tablename
					,'casenum' as caseid
				from [dbo].[user_case_matter]

				union

				select
					ref_num
					,'user_tab_data' as tablename
					,'case_id' as caseid
				from [dbo].[user_tab_matter] 
				
				union

				select
					ref_num
					,'user_tab2_data' as tablename
					,'case_id' as caseid
				from [dbo].[user_tab2_matter] 
				
				union

				select
					ref_num
					,'user_tab3_data' as tablename
					,'case_id' as caseid
				from [dbo].[user_tab3_matter] 
				
				union

				select
					ref_num
					,'user_tab4_data' as tablename
					,'case_id' as caseid
				from [dbo].[user_tab4_matter] 
				
				union

				select
					ref_num
					,'user_tab5_data' as tablename
					,'case_id' as caseid
				from [dbo].[user_tab5_matter]

				union

				select
					ref_num
					,'user_tab6_data' as tablename
					,'case_id' as caseid
				from [dbo].[user_tab6_matter]

				union

				select
					ref_num
					,'user_tab7_data' as tablename
					,'case_id' as caseid
				from [dbo].[user_tab7_matter]
			
				union

				select
					ref_num
					,'user_tab8_data' as tablename
					,'case_id' as caseid
				from [dbo].[user_tab8_matter]

				union

				select
					ref_num
					,'user_tab9_data' as tablename
					,'case_id' as caseid
				from [dbo].[user_tab9_matter]

				union

				select
					ref_num
					,'user_tab10_data' as tablename
					,'case_id' as caseid
				from [dbo].[user_tab10_matter]

				union

				select
					ref_num
					,'user_insurance_data' as tablename
					,'casenum' as caseid
				from [dbo].[user_case_insurance_matter]

				union
				
				select
					ref_num
					,'user_party_data' as tablename
					,'case_id' as caseid
				from [dbo].[user_party_matter]

				union

				select
					ref_num
					,'user_value_data' as tablename
					,'case_id' as caseid
				from [dbo].[user_case_value_matter] 
			
				union

				select
					ref_num
					,'user_counsel_data' as tablename
					,'casenum' as caseid
				from [dbo].[user_case_counsel_matter]
			) M on M.ref_num=F.field_num
	) A-- where A.rowindex=1
order by
	A.tablename
	,A.field_num
GO

/*
2. Seed CustomFieldUsage
*/
DECLARE @table varchar(100), 
		@Field varchar(100),
		@caseid varchar(20),
		@DataType varchar(20),
		@sql varchar(5000)

DECLARE FieldUsage_Cursor CURSOR FOR 
SELECT TableName,Column_Name, caseid,Field_Type FROM CustomFieldUsage
 
OPEN FieldUsage_Cursor 
FETCH NEXT FROM FieldUsage_Cursor INTO @table,@field, @caseid,@datatype
WHILE @@FETCH_STATUS = 0
BEGIN
	IF @datatype IN (
					'varchar'
					,'nvarchar'
					,'date'
					,'datetime2'
					,'bit'
					,'ntext'
					,'datetime'
					,'time'
					,'Name'
					,'alpha'
					,'boolean'
					,'checkbox'
					,'minidir'
					,'staff'
					,'state'
					,'time'
					,'valuecode'
					)
	BEGIN
		SET @SQL = 'UPDATE CustomFieldUsage SET ValueCount = ( Select count(*) FROM cases_Indexed ci JOIN [' + @table +'] t on [ci].CaseNum = t.[' + @caseid +'] WHERE isnull(['+@field+'],'''')<>'''') ' +
					'WHERE TableName = '''+@table + ''' and Column_Name = ''' + @Field + ''''
	END
	ELSE IF @datatype IN (
						'int'
						,'decimal'
						,'money'
						,'float'
						,'smallint'
						,'tinyint'
						,'numeric'
						,'bigint'
						,'smallint'
						)
	BEGIN

		SET @SQL = 'UPDATE CustomFieldUsage SET ValueCount = ( Select count(*) FROM cases_Indexed ci JOIN [' + @table +'] t on [ci].CaseNum = t.[' + @caseid +'] WHERE isnull(['+@field+'],0)<>0 ) ' + 
					'WHERE TableName = '''+@table + ''' and Column_Name = ''' + @Field + ''''
	END

	exec(@sql)
	
	FETCH NEXT
	FROM FieldUsage_Cursor
	INTO
		@table
		,@field
		,@caseid
		,@datatype
END 
CLOSE FieldUsage_Cursor;
DEALLOCATE FieldUsage_Cursor;

GO


/*
3. Create CustomFieldSampleData
	3.1 - Create a cursor to iterate through all fields in [CustomFieldUsage]
	3.2 - Grab first non-null record for each field and insert into [CustomFieldSampleData]
*/

-- 3.1 CustomFieldSampleData
IF OBJECT_ID('dbo.CustomFieldSampleData') IS NOT NULL
BEGIN
    DROP TABLE dbo.CustomFieldSampleData;
END

CREATE TABLE dbo.CustomFieldSampleData (
    column_name NVARCHAR(255),
    tablename NVARCHAR(255),
    field_value NVARCHAR(MAX)
);

-- 3.2 CustomFieldUsage cursor
DECLARE @column_name NVARCHAR(255), @tablename NVARCHAR(255);
DECLARE customFieldCursor CURSOR FOR
SELECT column_name, tablename FROM CustomFieldUsage;

DECLARE @sampleDataSql NVARCHAR(MAX);

OPEN customFieldCursor;

FETCH NEXT FROM customFieldCursor INTO @column_name, @tablename;

WHILE @@FETCH_STATUS = 0
BEGIN
SET @sampleDataSql = 'INSERT INTO CustomFieldSampleData (column_name, tablename, field_value) ' +
               'SELECT TOP 1 ''' + @column_name + ''', ''' + @tablename + ''', TRY_CAST([' + @column_name + '] AS NVARCHAR(MAX)) ' +
               'FROM ' + @tablename +
               ' WHERE TRY_CAST([' + @column_name + '] AS NVARCHAR(MAX)) IS NOT NULL AND TRY_CAST([' + @column_name + '] AS NVARCHAR(MAX)) <> ''''';

    PRINT @sampleDataSql;

    EXEC sp_executesql @sampleDataSql;

    FETCH NEXT FROM customFieldCursor INTO @column_name, @tablename;
END;

CLOSE customFieldCursor;
DEALLOCATE customFieldCursor;


/* -------------------------------------------------------------------------------------------------
4. Output Results
*/

 SELECT 
	[field_num]
     ,[field_num_location]
     ,[field_title]
     ,[field_type]
     ,[field_len]
     ,[mini_dir_id]
     ,[mini_dir_title]
     ,cfu.[column_name]
     ,[mini_dir_id_location]
     ,cfu.[tablename]
     ,[caseid]
     ,[ValueCount]
	 ,CFSD.field_value AS [Sample Data]
FROM 
    CustomFieldUsage CFU
	LEFT JOIN CustomFieldSampleData CFSD
		ON CFU.column_name = CFSD.column_name
		AND CFU.tablename = CFSD.tablename
order by CFU.tablename, CFU.field_num
