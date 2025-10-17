SELECT
    m.matcode AS case_type,
    m.header,
    m.description,
    m.active,
    c.[count] as case_count,
    CASE WHEN show_value_tab = 'Y' THEN m.value_tab_title ELSE 'N/A' END AS Value_Tab,
    CASE WHEN show_insurance_tab = 'Y' THEN m.insurance_tab_title ELSE 'N/A' END AS Insurance_Tab,
    CASE WHEN show_negotiation_tab = 'Y' THEN m.negotiation_tab_title ELSE 'N/A' END AS Negotiation_Tab,
    CASE WHEN show_counsel_tab = 'Y' THEN m.counsel_tab_title ELSE 'N/A' END AS Counsel_Tab,
    CASE WHEN show_police_tab = 'Y' THEN m.police_tab_title ELSE 'N/A' END AS Police_Tab,
    CASE WHEN show_document_tab = 'Y' THEN m.documents_tab_title ELSE 'N/A' END AS Documents_Tab,
    CASE WHEN show_status_tab = 'Y' THEN m.status_title ELSE 'N/A' END AS Status_Tab,
    CASE WHEN show_crm_tab = 'Y' THEN m.crm_title ELSE 'N/A' END AS CRM_Tab,
    CASE WHEN show_time_tab = 'Y' then m.time_tab_title ELSE 'N/A' END AS Time_Tab,
	CASE WHEN show_user_tab = 'Y' THEN tab_title ELSE 'N/A' END AS user_tab_1,
    CASE WHEN show_user_tab2 = 'Y' THEN tab2_title ELSE 'N/A' END AS user_tab_2,
    CASE WHEN show_user_tab3 = 'Y' THEN tab3_title  ELSE 'N/A' END AS user_tab_3,
    CASE WHEN show_user_tab4 = 'Y' THEN tab4_title  ELSE 'N/A' END AS user_tab_4,
    CASE WHEN show_user_tab5 = 'Y' THEN tab5_title  ELSE 'N/A' END AS user_tab_5,
    CASE WHEN show_user_tab6 = 'Y' THEN tab6_title  ELSE 'N/A' END AS user_tab_6,
    CASE WHEN show_user_tab7 = 'Y' THEN tab7_title  ELSE 'N/A' END AS user_tab_7,
    CASE WHEN show_user_tab8 = 'Y' THEN tab8_title  ELSE 'N/A' END AS user_tab_8,
    CASE WHEN show_user_tab9 = 'Y' THEN tab9_title  ELSE 'N/A' END AS user_tab_9,
    CASE WHEN show_user_tab10 = 'Y' THEN tab10_title else 'N/A' END AS user_tab_10
FROM [JohnSalazar_Needles]..matter m
INNER JOIN (
    SELECT
        ci.matcode,
        COUNT(*) AS [count]
    FROM [JohnSalazar_Needles]..cases_indexed ci
    GROUP BY ci.matcode
) c
    ON m.matcode = c.matcode
ORDER BY m.matcode;


SELECT 
    Pvt.tab,
    Pvt.[A], 
    Pvt.[MMP], 
    Pvt.[MSC], 
    Pvt.[PI], 
    Pvt.[PL], 
    Pvt.[PRE] 
FROM 
(
    -- Step 1: Unpivot the user_tab columns into rows
    SELECT
        T.matcode, -- Column that holds the values (A, MMP, etc.)
        PvtData.tab,
        PvtData.tab_value
    FROM
        JohnSalazar_Needles..matter AS T -- Corrected alias
    CROSS APPLY (
        VALUES
            ('user_tab_2', T.tab2_title),
            ('user_tab_9', T.tab9_title),
            ('user_tab_10', T.tab10_title)
            -- Add all other user_tab columns here
    ) AS PvtData (tab, tab_value)
) AS Unpivoted
PIVOT 
(
    -- Step 2: Pivot the matcodes (matcode)
    MAX(tab_value) 
    FOR matcode IN ([A], [MMP], [MSC], [PI], [PL], [PRE]) -- <<== CHANGED to matcode
) AS Pvt
ORDER BY 
    Pvt.tab;



DECLARE @matcodes_list NVARCHAR(MAX);
DECLARE @SQL NVARCHAR(MAX);
DECLARE @SourceTable SYSNAME = 'JohnSalazar_Needles..matter'; -- Define your source table once

-- 1. Build the list of distinct matcodes (A, MMP, MSC, PI, PL, PRE, etc.) 
--    and format them for the PIVOT IN clause (e.g., [A], [MMP], ...)
SELECT 
    @matcodes_list = STRING_AGG(QUOTENAME(matcode), ', ')
FROM (
    -- Assuming case_type is the column that holds your matcode values
    SELECT DISTINCT matcode FROM JohnSalazar_Needles..matter
) AS DistinctMatcodes;

-- Check if matcodes were found
IF @matcodes_list IS NULL
BEGIN
    SELECT 'Error: No matcodes found in the source table.';
    RETURN;
END

-- 2. Construct the Dynamic SQL
SET @SQL = 
    N'
    SELECT 
        Pvt.tab, ' + @matcodes_list + ',
		NULL as Target
    FROM 
    (
        -- Step 1: Unpivot the user_tab columns into rows
        SELECT
            T.matcode, -- This is the column that holds the matcode values
            PvtData.tab,
            PvtData.tab_value
        FROM
            ' + @SourceTable + ' AS T
        CROSS APPLY (
            VALUES
				(''user_tab_1'', T.tab_title),
				(''user_tab_2'', T.tab2_title),
				(''user_tab_3'', T.tab3_title),
				(''user_tab_4'', T.tab4_title),
				(''user_tab_5'', T.tab5_title),
				(''user_tab_6'', T.tab6_title),
                (''user_tab_7'', T.tab7_title),
                (''user_tab_8'', T.tab8_title),
				(''user_tab_9'', T.tab9_title),
                (''user_tab_10'', T.tab10_title)
                -- Add all other user_tab columns here
        ) AS PvtData (tab, tab_value)
    ) AS Unpivoted
    PIVOT 
    (
        -- Step 2: Pivot the matcodes (case_type)
        MAX(tab_value) 
        FOR matcode IN (' + @matcodes_list + ') -- Use the dynamically generated list
    ) AS Pvt
    ORDER BY 
        Pvt.tab;';

-- 3. Execute the Dynamic SQL
-- PRINT @SQL; -- Uncomment this line to see the SQL before execution
EXEC sp_executesql @SQL;




-- Analyze each user tab to see if data is multi-record

SELECT
    KnownTables.TableName,
    CASE 
        -- Check if any row exists for this table in the MultiRecordCases subquery
        WHEN EXISTS (
            SELECT 1
            FROM (
                -- Your analysis: identifies cases with multiple records
                SELECT 'user_tab_data' AS TableName, case_id FROM JohnSalazar_Needles..user_tab_data GROUP BY case_id HAVING COUNT(case_id) > 1
                UNION ALL
				SELECT 'user_tab2_data' AS TableName, case_id FROM JohnSalazar_Needles..user_tab2_data GROUP BY case_id HAVING COUNT(case_id) > 1
                UNION ALL
				SELECT 'user_tab3_data' AS TableName, case_id FROM JohnSalazar_Needles..user_tab3_data GROUP BY case_id HAVING COUNT(case_id) > 1
                UNION ALL
				SELECT 'user_tab4_data' AS TableName, case_id FROM JohnSalazar_Needles..user_tab4_data GROUP BY case_id HAVING COUNT(case_id) > 1
                UNION ALL
				SELECT 'user_tab5_data' AS TableName, case_id FROM JohnSalazar_Needles..user_tab5_data GROUP BY case_id HAVING COUNT(case_id) > 1
                UNION ALL
				SELECT 'user_tab6_data' AS TableName, case_id FROM JohnSalazar_Needles..user_tab6_data GROUP BY case_id HAVING COUNT(case_id) > 1
                UNION ALL
				SELECT 'user_tab7_data' AS TableName, case_id FROM JohnSalazar_Needles..user_tab7_data GROUP BY case_id HAVING COUNT(case_id) > 1
                UNION ALL
				SELECT 'user_tab8_data' AS TableName, case_id FROM JohnSalazar_Needles..user_tab8_data GROUP BY case_id HAVING COUNT(case_id) > 1
                UNION ALL
                SELECT 'user_tab9_data' AS TableName, case_id FROM JohnSalazar_Needles..user_tab9_data GROUP BY case_id HAVING COUNT(case_id) > 1
                UNION ALL
                SELECT 'user_tab10_data' AS TableName, case_id FROM JohnSalazar_Needles..user_tab10_data GROUP BY case_id HAVING COUNT(case_id) > 1
                -- Add all other user_tabX_data checks here
            ) AS MultiRecordAnalysis
            -- The crucial step: filter the analysis results by the current TableName being processed
            WHERE MultiRecordAnalysis.TableName = KnownTables.TableName
        ) THEN 'Yes'
        ELSE 'No'
    END AS IsMultiRecord
FROM (
    -- Hardcoded list of ALL tables you want to check (The source of all output rows)
    VALUES 
        ('user_tab_data'), 
		('user_tab2_data'), 
		('user_tab3_data'), 
		('user_tab4_data'), 
		('user_tab5_data'), 
		('user_tab6_data'), 
		('user_tab7_data'), 
		('user_tab8_data'), 
        ('user_tab9_data'), 
        ('user_tab10_data')
    -- Add all other user_tabX_data table names here
) AS KnownTables(TableName)


go

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @matcodes_list NVARCHAR(MAX);
DECLARE @SQL NVARCHAR(MAX);
DECLARE @SourceTable SYSNAME = 'JohnSalazar_Needles..matter'; 

-- 1. Build the list of distinct matcodes
SELECT 
    @matcodes_list = STRING_AGG(QUOTENAME(matcode), ', ')
FROM (
    SELECT DISTINCT matcode FROM JohnSalazar_Needles..matter
) AS DistinctMatcodes;

-- Check if matcodes were found
IF @matcodes_list IS NULL
BEGIN
    SELECT 'Error: No matcodes found in the source table.';
    RETURN;
END

-- Drop temp table if it exists (for clean execution)
IF OBJECT_ID('tempdb..#MultiRecordStatus') IS NOT NULL DROP TABLE #MultiRecordStatus;

-- 2. Define the Multi-Record Analysis CTE and insert results into a temp table
WITH MultiRecordStatus AS
(
    SELECT
        KnownTables.TableName,
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM (
                    -- Your analysis: identifies cases with multiple records (The inner UNION ALL block)
                    SELECT 'user_tab_data' AS TableName, case_id FROM JohnSalazar_Needles..user_tab_data GROUP BY case_id HAVING COUNT(case_id) > 1
                    UNION ALL
                    SELECT 'user_tab2_data' AS TableName, case_id FROM JohnSalazar_Needles..user_tab2_data GROUP BY case_id HAVING COUNT(case_id) > 1
                    UNION ALL
                    SELECT 'user_tab3_data' AS TableName, case_id FROM JohnSalazar_Needles..user_tab3_data GROUP BY case_id HAVING COUNT(case_id) > 1
                    UNION ALL
                    SELECT 'user_tab4_data' AS TableName, case_id FROM JohnSalazar_Needles..user_tab4_data GROUP BY case_id HAVING COUNT(case_id) > 1
                    UNION ALL
                    SELECT 'user_tab5_data' AS TableName, case_id FROM JohnSalazar_Needles..user_tab5_data GROUP BY case_id HAVING COUNT(case_id) > 1
                    UNION ALL
                    SELECT 'user_tab6_data' AS TableName, case_id FROM JohnSalazar_Needles..user_tab6_data GROUP BY case_id HAVING COUNT(case_id) > 1
                    UNION ALL
                    SELECT 'user_tab7_data' AS TableName, case_id FROM JohnSalazar_Needles..user_tab7_data GROUP BY case_id HAVING COUNT(case_id) > 1
                    UNION ALL
                    SELECT 'user_tab8_data' AS TableName, case_id FROM JohnSalazar_Needles..user_tab8_data GROUP BY case_id HAVING COUNT(case_id) > 1
                    UNION ALL
                    SELECT 'user_tab9_data' AS TableName, case_id FROM JohnSalazar_Needles..user_tab9_data GROUP BY case_id HAVING COUNT(case_id) > 1
                    UNION ALL
                    SELECT 'user_tab10_data' AS TableName, case_id FROM JohnSalazar_Needles..user_tab10_data GROUP BY case_id HAVING COUNT(case_id) > 1
                ) AS MultiRecordAnalysis
                -- The crucial WHERE clause must be outside the UNION ALL block
                WHERE MultiRecordAnalysis.TableName = KnownTables.TableName
            ) THEN 'Yes'
            ELSE 'No'
        END AS IsMultiRecord
    FROM (
        -- Hardcoded list of ALL tables
        VALUES
            ('user_tab_data'), 
            ('user_tab2_data'), 
            ('user_tab3_data'), 
            ('user_tab4_data'), 
            ('user_tab5_data'), 
            ('user_tab6_data'), 
            ('user_tab7_data'), 
            ('user_tab8_data'), 
            ('user_tab9_data'), 
            ('user_tab10_data')
    ) AS KnownTables(TableName)
)
-- EXECUTE THE CTE and save the results
SELECT TableName, IsMultiRecord
INTO #MultiRecordStatus -- NEW STEP: Use the CTE and save data
FROM MultiRecordStatus;


-- 3. Construct the Dynamic SQL (now using the #MultiRecordStatus temp table)
SET @SQL = 
    N'
    SELECT 
        Pvt.tab, 
        M.IsMultiRecord AS "multi-record", -- Join result here
        ' + @matcodes_list + ',
        NULL AS Target
    FROM 
    (
        -- Step 1: Unpivot the user_tab columns into rows
        SELECT
            T.matcode, 
            PvtData.tab,
            PvtData.tab_value
        FROM
            ' + @SourceTable + ' AS T
        CROSS APPLY (
            VALUES
				(''user_tab_1'', T.tab_title),
				(''user_tab_2'', T.tab2_title),
				(''user_tab_3'', T.tab3_title),
				(''user_tab_4'', T.tab4_title),
				(''user_tab_5'', T.tab5_title),
				(''user_tab_6'', T.tab6_title),
				(''user_tab_7'', T.tab7_title),
				(''user_tab_8'', T.tab8_title),                
                (''user_tab_9'', T.tab9_title),
                (''user_tab_10'', T.tab10_title)
        ) AS PvtData (tab, tab_value)
    ) AS Unpivoted
    PIVOT 
    (
        MAX(tab_value) 
        FOR matcode IN (' + @matcodes_list + ') 
    ) AS Pvt
    INNER JOIN #MultiRecordStatus M -- Joining the TEMP TABLE
        ON M.TableName = REPLACE(REPLACE(Pvt.tab, ''_data'', ''''), ''user_tab_'', ''user_tab'') + ''_data'';';

-- 4. Execute the Dynamic SQL
EXEC sp_executesql @SQL;