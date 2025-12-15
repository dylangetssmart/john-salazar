USE JohnSalazar_Needles
GO

/* ######################################################################################
DESCRIPTION:
    Combines NeedlesUserFields and CustomFieldUsage into one table, including:
        - Field metadata (title, type, length, UDF type)
        - Dropdown/minidir values
        - Source table info (table_name, caseid_col)
        - Usage metric (ValueCount)
###################################################################################### */

-- Drop table if exists
IF OBJECT_ID('dbo.NeedlesUserFields', 'U') IS NOT NULL
    DROP TABLE dbo.NeedlesUserFields;
GO

-- Create table with sufficient column sizes
CREATE TABLE NeedlesUserFields (
    table_name      VARCHAR(100) NULL,
    caseid_col      VARCHAR(50) NULL,
    column_name     VARCHAR(100),
    field_title     VARCHAR(100),
    field_num       INT,
    field_type      VARCHAR(50),
    field_len       VARCHAR(20),
    mini_dir_id     INT NULL,
    mini_dir_title  VARCHAR(100) NULL,
    UDFType         VARCHAR(50),
    DropDownValues  VARCHAR(MAX),
    ValueCount      INT DEFAULT 0,
	SampleData NVARCHAR(MAX)
);
GO

-- Insert base metadata from user_case_fields
--INSERT INTO NeedlesUserFields (
--    field_num,
--    field_title,
--    column_name,
--    field_type,
--    field_len,
--    mini_dir_id,
--    mini_dir_title,
--    UDFType,
--    DropDownValues
--)
--SELECT
--    F.field_num,
--    F.field_title,
--    F.column_name,
--    F.field_type,
--    CASE 
--        WHEN F.field_type IN ('number','money') THEN CONVERT(VARCHAR, F.field_len) + ',2'
--        ELSE CONVERT(VARCHAR, F.field_len)
--    END AS field_len,
--    F.mini_dir_id,
--    F.mini_dir_title,
--    CASE
--        WHEN F.field_type IN ('alpha','state','valuecode','staff') THEN 'Text'
--        WHEN F.field_type IN ('number','money') THEN 'Number'
--        WHEN F.field_type IN ('boolean','checkbox') THEN 'CheckBox'
--        WHEN F.field_type='minidir' THEN 'Dropdown'
--        WHEN F.field_type='Date' THEN 'Date'
--        WHEN F.field_type='Time' THEN 'Time'
--        WHEN F.field_type='name' THEN 'Contact'
--        ELSE F.field_type
--    END AS UDFType,
--    ''
--select * FROM JohnSalazar_Needles.dbo.user_case_fields F order by F.field_title
--GO

--select * from NeedlesUserFields

-- Assign table_name and caseid_col from the *_matter tables
--UPDATE U
--SET 
--    table_name = M.tablename,
--    caseid_col = M.caseid
--FROM NeedlesUserFields U
--JOIN (
--    SELECT CAST(ref_num AS INT) AS ref_num, 'user_case_data' AS tablename, 'casenum' AS caseid FROM JohnSalazar_Needles..user_case_matter
--    UNION ALL
--    SELECT CAST(ref_num AS INT), 'user_tab_data', 'case_id' FROM JohnSalazar_Needles.dbo.user_tab_matter
--    UNION ALL
--    SELECT CAST(ref_num AS INT), 'user_tab2_data', 'case_id' FROM JohnSalazar_Needles.dbo.user_tab2_matter
--    UNION ALL
--    SELECT CAST(ref_num AS INT), 'user_tab3_data', 'case_id' FROM JohnSalazar_Needles.dbo.user_tab3_matter
--    UNION ALL
--    SELECT CAST(ref_num AS INT), 'user_tab4_data', 'case_id' FROM JohnSalazar_Needles.dbo.user_tab4_matter
--    UNION ALL
--    SELECT CAST(ref_num AS INT), 'user_tab5_data', 'case_id' FROM JohnSalazar_Needles.dbo.user_tab5_matter
--    UNION ALL
--    SELECT CAST(ref_num AS INT), 'user_tab6_data', 'case_id' FROM JohnSalazar_Needles.dbo.user_tab6_matter
--    UNION ALL
--    SELECT CAST(ref_num AS INT), 'user_tab7_data', 'case_id' FROM JohnSalazar_Needles.dbo.user_tab7_matter
--    UNION ALL
--    SELECT CAST(ref_num AS INT), 'user_tab8_data', 'case_id' FROM JohnSalazar_Needles.dbo.user_tab8_matter
--    UNION ALL
--    SELECT CAST(ref_num AS INT), 'user_tab9_data', 'case_id' FROM JohnSalazar_Needles.dbo.user_tab9_matter
--    UNION ALL
--    SELECT CAST(ref_num AS INT), 'user_tab10_data', 'case_id' FROM JohnSalazar_Needles.dbo.user_tab10_matter
--    UNION ALL
--    SELECT CAST(ref_num AS INT), 'user_insurance_data', 'casenum' FROM JohnSalazar_Needles.dbo.user_case_insurance_matter
--    UNION ALL
--    SELECT CAST(ref_num AS INT), 'user_party_data', 'case_id' FROM JohnSalazar_Needles.dbo.user_party_matter
--    UNION ALL
--    SELECT CAST(ref_num AS INT), 'user_value_data', 'case_id' FROM JohnSalazar_Needles.dbo.user_case_value_matter
--    UNION ALL
--    SELECT CAST(ref_num AS INT), 'user_counsel_data', 'casenum' FROM JohnSalazar_Needles.dbo.user_case_counsel_matter
--) M
--ON M.ref_num = U.field_num;
--GO

;WITH FieldMapping AS (
    SELECT 
        F.field_num,
        F.field_title,
        F.column_name,
        F.field_type,
        CASE 
            WHEN F.field_type IN ('number','money') THEN CONVERT(VARCHAR, F.field_len) + ',2'
            ELSE CONVERT(VARCHAR, F.field_len)
        END AS field_len,
        F.mini_dir_id,
        F.mini_dir_title,
        CASE
            WHEN F.field_type IN ('alpha','state','valuecode') THEN 'Text'
            WHEN F.field_type IN ('number','money') THEN 'Number'
            WHEN F.field_type IN ('boolean','checkbox') THEN 'CheckBox'
            WHEN F.field_type='minidir' THEN 'RealDropdown'
            WHEN F.field_type='Date' THEN 'Date'
            WHEN F.field_type='Time' THEN 'Time'
            WHEN F.field_type in ('name', 'staff') THEN 'Contact'
            ELSE F.field_type
        END AS UDFType,
        '' AS DropDownValues,
        M.table_name,
        M.caseid,
        ROW_NUMBER() OVER(
            PARTITION BY F.field_num, M.table_name  -- <-- key fix: partition by field_num + table_name
            ORDER BY M.table_name
        ) AS rn
    FROM [JohnSalazar_Needles].[dbo].[user_case_fields] F
    JOIN (
        SELECT ref_num, 'user_case_data' AS table_name, 'casenum' AS caseid FROM [JohnSalazar_Needles].[dbo].[user_case_matter]
        UNION ALL SELECT ref_num, 'user_tab_data', 'case_id' FROM [JohnSalazar_Needles].[dbo].[user_tab_matter]
        UNION ALL SELECT ref_num, 'user_tab2_data', 'case_id' FROM [JohnSalazar_Needles].[dbo].[user_tab2_matter]
        UNION ALL SELECT ref_num, 'user_tab3_data', 'case_id' FROM [JohnSalazar_Needles].[dbo].[user_tab3_matter]
        UNION ALL SELECT ref_num, 'user_tab4_data', 'case_id' FROM [JohnSalazar_Needles].[dbo].[user_tab4_matter]
        UNION ALL SELECT ref_num, 'user_tab5_data', 'case_id' FROM [JohnSalazar_Needles].[dbo].[user_tab5_matter]
        UNION ALL SELECT ref_num, 'user_tab6_data', 'case_id' FROM [JohnSalazar_Needles].[dbo].[user_tab6_matter]
        UNION ALL SELECT ref_num, 'user_tab7_data', 'case_id' FROM [JohnSalazar_Needles].[dbo].[user_tab7_matter]
        UNION ALL SELECT ref_num, 'user_tab8_data', 'case_id' FROM [JohnSalazar_Needles].[dbo].[user_tab8_matter]
        UNION ALL SELECT ref_num, 'user_tab9_data', 'case_id' FROM [JohnSalazar_Needles].[dbo].[user_tab9_matter]
        UNION ALL SELECT ref_num, 'user_tab10_data', 'case_id' FROM [JohnSalazar_Needles].[dbo].[user_tab10_matter]
        UNION ALL SELECT ref_num, 'user_insurance_data', 'casenum' FROM [JohnSalazar_Needles].[dbo].[user_case_insurance_matter]
        UNION ALL SELECT ref_num, 'user_party_data', 'case_id' FROM [JohnSalazar_Needles].[dbo].[user_party_matter]
        UNION ALL SELECT ref_num, 'user_value_data', 'case_id' FROM [JohnSalazar_Needles].[dbo].[user_case_value_matter]
        UNION ALL SELECT ref_num, 'user_counsel_data', 'casenum' FROM [JohnSalazar_Needles].[dbo].[user_case_counsel_matter]
    ) M ON M.ref_num = F.field_num
)
INSERT INTO NeedlesUserFields
SELECT 
    table_name,
    caseid,
    column_name,
    field_title,
    field_num,
    field_type,
    field_len,
    mini_dir_id,
    mini_dir_title,
    UDFType,
    DropDownValues,
    0 AS ValueCount,
    NULL AS SampleData
FROM FieldMapping
WHERE rn = 1 -- only keep first record per field_num per table
ORDER BY table_name, field_num;
GO

-- View final table
--SELECT * FROM NeedlesUserFields ORDER BY table_name, field_num;


-- Populate DropDownValues for mini directories
DECLARE @miniDir VARCHAR(50), @fieldTitle VARCHAR(50);

DECLARE curMiniDir CURSOR FOR
SELECT mini_dir_title, field_title
FROM NeedlesUserFields
WHERE field_type = 'minidir';

OPEN curMiniDir;
FETCH NEXT FROM curMiniDir INTO @miniDir, @fieldTitle;

WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT IDENTITY(INT,1,1) AS Number, gd.code
    INTO #values
    FROM JohnSalazar_Needles.dbo.mini_general_dir gd
    JOIN JohnSalazar_Needles.dbo.mini_dir_list dl
        ON gd.num_assigned = dl.dir_key
    WHERE dl.dir_name = @miniDir;

    DECLARE @numberCt INT = (SELECT MAX(Number) FROM #values);
    DECLARE @code VARCHAR(50);

    WHILE @numberCt >= 1
    BEGIN
        SELECT @code = code FROM #values WHERE Number = @numberCt;

        UPDATE NeedlesUserFields
        SET DropDownValues = CASE 
                                WHEN DropDownValues IS NULL THEN @code
                                ELSE DropDownValues + '~' + @code
                             END
        WHERE mini_dir_title = @miniDir AND field_title = @fieldTitle;

        SET @numberCt = @numberCt - 1;
    END

    DROP TABLE #values;

    FETCH NEXT FROM curMiniDir INTO @miniDir, @fieldTitle;
END

CLOSE curMiniDir;
DEALLOCATE curMiniDir;
GO

--select * from NeedlesUserFields

-- Populate ValueCount dynamically (skip missing tables)
DECLARE @sql NVARCHAR(MAX), @table NVARCHAR(100), @field NVARCHAR(100), @caseid NVARCHAR(50), @datatype NVARCHAR(50);

DECLARE curValue CURSOR FOR
SELECT table_name, column_name, caseid_col, field_type
FROM dbo.NeedlesUserFields
WHERE table_name IS NOT NULL;

OPEN curValue;
FETCH NEXT FROM curValue INTO @table, @field, @caseid, @datatype;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF OBJECT_ID('JohnSalazar_Needles.dbo.' + @table, 'U') IS NOT NULL
    BEGIN
        IF @datatype IN ('varchar','nvarchar','date','datetime2','bit','ntext','datetime','time','name','alpha','boolean','checkbox','minidir','staff','state','valuecode')
        BEGIN
            SET @sql = 'UPDATE dbo.NeedlesUserFields SET ValueCount = (' +
                       'SELECT COUNT(*) FROM JohnSalazar_Needles.dbo.' + @table + ' t ' +
                       'JOIN JohnSalazar_Needles.dbo.cases_Indexed ci ON ci.CaseNum = t.[' + @caseid + '] ' +
                       'WHERE ISNULL([' + @field + '], '''') <> '''') ' +
                       'WHERE table_name = ''' + @table + ''' AND column_name = ''' + @field + '''';
        END
        ELSE
        BEGIN
            SET @sql = 'UPDATE dbo.NeedlesUserFields SET ValueCount = (' +
                       'SELECT COUNT(*) FROM JohnSalazar_Needles.dbo.' + @table + ' t ' +
                       'JOIN JohnSalazar_Needles.dbo.cases_Indexed ci ON ci.CaseNum = t.[' + @caseid + '] ' +
                       'WHERE ISNULL([' + @field + '], 0) <> 0 ) ' +
                       'WHERE table_name = ''' + @table + ''' AND column_name = ''' + @field + '''';
        END

        EXEC(@sql);
    END

    FETCH NEXT FROM curValue INTO @table, @field, @caseid, @datatype;
END
CLOSE curValue;
DEALLOCATE curValue;
GO

--select * from NeedlesUserFields

-- Populate SampleData dynamically
DECLARE @table NVARCHAR(100), 
        @field NVARCHAR(100), 
        @caseid NVARCHAR(50), 
        @sql NVARCHAR(MAX);

DECLARE sampleDataCursor CURSOR FOR
SELECT table_name, column_name, caseid_col
FROM dbo.NeedlesUserFields
WHERE table_name IS NOT NULL;

OPEN sampleDataCursor;
FETCH NEXT FROM sampleDataCursor INTO @table, @field, @caseid;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Only proceed if the table exists
    IF OBJECT_ID('JohnSalazar_Needles.dbo.' + @table, 'U') IS NOT NULL
    BEGIN
        SET @sql = '
        UPDATE dbo.NeedlesUserFields
        SET SampleData = (
            SELECT TOP 1 TRY_CAST([' + @field + '] AS NVARCHAR(MAX))
            FROM JohnSalazar_Needles.dbo.' + @table + '
            WHERE TRY_CAST([' + @field + '] AS NVARCHAR(MAX)) IS NOT NULL
        )
        WHERE table_name = ''' + @table + ''' AND column_name = ''' + @field + '''';

        EXEC sp_executesql @sql;
    END

    FETCH NEXT FROM sampleDataCursor INTO @table, @field, @caseid;
END

CLOSE sampleDataCursor;
DEALLOCATE sampleDataCursor;
GO

select * from NeedlesUserFields order by table_name, column_name