CREATE OR ALTER PROCEDURE dbo.BuildNeedlesUserTabStagingTable
    @SourceDatabase SYSNAME,
    @TargetDatabase SYSNAME,
    @DataTableName SYSNAME,
    @StagingTable SYSNAME,
    @ColumnList NVARCHAR(MAX) -- comma-separated column names
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MatterTable SYSNAME = REPLACE(@DataTableName, '_data', '_matter');
    DECLARE @NameTable SYSNAME   = REPLACE(@DataTableName, '_data', '_name');
    --DECLARE @StagingTable SYSNAME = 'stg_' + REPLACE(@DataTableName, 'user_tab_', '');
	
	-- Drop staging table if exists
	DECLARE @dropSQL NVARCHAR(MAX);
    SET @DropSql = '
    IF OBJECT_ID(''' + @TargetDatabase + '.dbo.' + @StagingTable + ''', ''U'') IS NOT NULL
        DROP TABLE ' + @TargetDatabase + '.dbo.' + @StagingTable + ';';
    EXEC(@DropSql);

	-- Clean and split column list into a table
	CREATE TABLE #Cols (colname NVARCHAR(255));
    INSERT INTO #Cols (colname)
    SELECT LTRIM(RTRIM(REPLACE(REPLACE(value, CHAR(10), ''), CHAR(13), '')))
    FROM STRING_SPLIT(@ColumnList, ',')
    WHERE LTRIM(RTRIM(REPLACE(REPLACE(value, CHAR(10), ''), CHAR(13), ''))) <> '';
	--Select * from #Cols c

    -- IN clause for mapping query
    DECLARE @InClause NVARCHAR(MAX);
    SELECT @InClause = STRING_AGG('''' + colname + '''', ',') FROM #Cols;

    -- Mapping table
    CREATE TABLE #Mapping (
        table_name  VARCHAR(100),
        column_name VARCHAR(100),
        field_type  VARCHAR(25),
        caseid_col  VARCHAR(10)
    );

    DECLARE @MappingSQL NVARCHAR(MAX) = '
        INSERT INTO #Mapping (table_name, column_name, field_type, caseid_col)
        SELECT DISTINCT nuf.table_name, nuf.column_name, utm.field_type, nuf.caseid_col
        FROM ' + QUOTENAME(@SourceDatabase) + '..NeedlesUserFields nuf
        JOIN ' + QUOTENAME(@SourceDatabase) + '..' + QUOTENAME(@MatterTable) + ' utm
            ON nuf.field_num = utm.ref_num
        WHERE nuf.table_name = @tbl
          AND nuf.column_name IN (' + @InClause + ')';
	--print @MappingSQL
    EXEC sp_executesql @MappingSQL, N'@tbl SYSNAME', @tbl=@DataTableName;
	--Select * from #Mapping m

	 -- Get caseid column
    DECLARE @CaseIdCol SYSNAME = (SELECT TOP 1 caseid_col FROM #Mapping);

    -- Build select columns
    DECLARE @SelectCols NVARCHAR(MAX);
    SELECT @SelectCols = STRING_AGG(
        CASE 
            WHEN field_type = 'name' THEN 'ioci.CID AS [' + column_name + '_CID]'
            ELSE 'utd.[' + column_name + '] AS [' + column_name + ']'
        END, ', '
    )
    FROM #Mapping;

    -- Build WHERE clause
    DECLARE @Where NVARCHAR(MAX);
    SELECT @Where = STRING_AGG(
        '(' + CASE 
            WHEN field_type = 'name' THEN 'ioci.CID'
            ELSE 'utd.[' + column_name + ']'
        END + ' IS NOT NULL)', ' OR '
    )
    FROM #Mapping;

    -- Assemble final SQL
    DECLARE @FinalSQL NVARCHAR(MAX) = '
        SELECT DISTINCT
            utd.' + @CaseIdCol + ' AS caseid,
            utd.tab_id AS tabid,
            ' + @SelectCols + '
        INTO ' + QUOTENAME(@TargetDatabase) + '.dbo.' + QUOTENAME(@StagingTable) + '
        FROM ' + QUOTENAME(@SourceDatabase) + '..' + QUOTENAME(@DataTableName) + ' utd
        LEFT JOIN ' + QUOTENAME(@SourceDatabase) + '..' + QUOTENAME(@NameTable) + ' utn
            ON utd.' + @CaseIdCol + ' = utn.case_id AND utd.tab_id = utn.tab_id
        LEFT JOIN ' + QUOTENAME(@SourceDatabase) + '..' + QUOTENAME(@MatterTable) + ' utm
            ON utn.ref_num = utm.ref_num
        LEFT JOIN ' + QUOTENAME(@SourceDatabase) + '..names n
            ON utn.user_name = n.names_id
        LEFT JOIN IndvOrgContacts_Indexed ioci
            ON ioci.SAGA = n.names_id
        WHERE ' + @Where + '
        ORDER BY utd.' + @CaseIdCol + ';';

    -- Execute dynamic SQL
    EXEC(@FinalSQL);

    -- Return staging table
    DECLARE @ReturnSQL NVARCHAR(MAX) = 'SELECT * FROM ' + QUOTENAME(@TargetDatabase) + '.dbo.' + QUOTENAME(@StagingTable) + ' ORDER BY caseid;';
    EXEC(@ReturnSQL);
END;
GO