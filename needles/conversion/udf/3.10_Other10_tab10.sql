/* ########################################################
This script populates UDF Other10 with all columns from user_tab10_data
*/

USE KurtYoung_SA
GO

IF EXISTS (
		SELECT
			*
		FROM sys.tables
		WHERE name = 'Other10UDF'
			AND type = 'U'
	)
BEGIN
	DROP TABLE Other10UDF
END

-- Create temporary table for columns to exclude
IF OBJECT_ID('tempdb..#ExcludedColumns') IS NOT NULL
	DROP TABLE #ExcludedColumns;

CREATE TABLE #ExcludedColumns (
	column_name VARCHAR(128)
);
GO

-- Insert columns to exclude
INSERT INTO #ExcludedColumns
	(
	column_name
	)
VALUES (
'case_id'
),
(
'tab_id'
),
(
'tab_id_location'
),
(
'modified_timestamp'
),
(
'show_on_status_tab'
),
(
'case_status_attn'
),
(
'case_status_client'
);
GO

-- Dynamically get all columns from KurtYoung_Needles..user_tab10_data for unpivoting
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT
	@sql = STRING_AGG(CONVERT(VARCHAR(MAX),
	N'CONVERT(VARCHAR(MAX), ' + QUOTENAME(column_name) + N') AS ' + QUOTENAME(column_name)
	), ', ')
FROM KurtYoung_Needles.INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'user_tab10_data'
	AND column_name NOT IN (
		SELECT
			column_name
		FROM #ExcludedColumns
	);


-- Dynamically create the UNPIVOT list
DECLARE @unpivot_list NVARCHAR(MAX) = N'';
SELECT
	@unpivot_list = STRING_AGG(QUOTENAME(column_name), ', ')
FROM KurtYoung_Needles.INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'user_tab10_data'
	AND column_name NOT IN (
		SELECT
			column_name
		FROM #ExcludedColumns
	);


-- Generate the dynamic SQL for creating the pivot table
SET @sql = N'
SELECT casnCaseID, casnOrgCaseTypeID, FieldTitle, FieldVal
INTO Other10UDF
FROM ( 
    SELECT 
        cas.casnCaseID, 
        cas.casnOrgCaseTypeID, ' + @sql + N'
    FROM KurtYoung_Needles..user_tab10_data ud
    JOIN KurtYoung_Needles..cases_Indexed c ON c.casenum = ud.case_id
    JOIN sma_TRN_Cases cas ON cas.cassCaseNumber = CONVERT(VARCHAR, ud.case_id)
) pv
UNPIVOT (FieldVal FOR FieldTitle IN (' + @unpivot_list + N')) AS unpvt;';

EXEC sp_executesql @sql;
GO

----------------------------
--UDF DEFINITION
----------------------------
ALTER TABLE [sma_MST_UDFDefinition] DISABLE TRIGGER ALL
GO

IF EXISTS (
		SELECT
			*
		FROM sys.tables
		WHERE name = 'Other10UDF'
			AND type = 'U'
	)
BEGIN
	INSERT INTO [sma_MST_UDFDefinition]
		(
		[udfsUDFCtg]
	   ,[udfnRelatedPK]
	   ,[udfsUDFName]
	   ,[udfsScreenName]
	   ,[udfsType]
	   ,[udfsLength]
	   ,[udfbIsActive]
	   ,[udfshortName]
	   ,[udfsNewValues]
	   ,[udfnSortOrder]
		)
		SELECT DISTINCT
			'C'										   AS [udfsUDFCtg]
		   ,CST.cstnCaseTypeID						   AS [udfnRelatedPK]
		   ,M.field_title							   AS [udfsUDFName]
		   ,'Other10'								   AS [udfsScreenName]
		   ,ucf.UDFType								   AS [udfsType]
		   ,ucf.field_len							   AS [udfsLength]
		   ,1										   AS [udfbIsActive]
		   ,'user_tab10_data' + ucf.column_name		   AS [udfshortName]
		   ,ucf.dropdownValues						   AS [udfsNewValues]
		   ,DENSE_RANK() OVER (ORDER BY M.field_title) AS udfnSortOrder
		FROM [sma_MST_CaseType] CST
		JOIN CaseTypeMixture mix
			ON mix.[SmartAdvocate Case Type] = cst.cstsType
		JOIN [KurtYoung_Needles].[dbo].[user_tab10_matter] M
			ON M.mattercode = mix.matcode
				AND M.field_type <> 'label'
		JOIN (
			SELECT DISTINCT
				fieldTitle
			FROM Other10UDF
		) vd
			ON vd.FieldTitle = M.field_title
		JOIN [dbo].[NeedlesUserFields] ucf
			ON ucf.field_num = M.ref_num
		LEFT JOIN (
			SELECT DISTINCT
				table_Name
			   ,column_name
			FROM [KurtYoung_Needles].[dbo].[document_merge_params]
			WHERE table_Name = 'user_tab10_data'
		) dmp
			ON dmp.column_name = ucf.field_Title
		LEFT JOIN [sma_MST_UDFDefinition] def
			ON def.[udfnRelatedPK] = CST.cstnCaseTypeID
				AND def.[udfsUDFName] = M.field_title
				AND def.[udfsScreenName] = 'Other10'
				AND def.[udfsType] = ucf.UDFType
				AND def.udfnUDFID IS NULL
		ORDER BY M.field_title
END


ALTER TABLE sma_trn_udfvalues DISABLE TRIGGER ALL
GO

-- Table will not exist if it's empty or only contains ExlucedColumns
IF EXISTS (
		SELECT
			*
		FROM sys.tables
		WHERE name = 'Other10UDF'
			AND type = 'U'
	)
BEGIN
	INSERT INTO [sma_TRN_UDFValues]
		(
		[udvnUDFID]
	   ,[udvsScreenName]
	   ,[udvsUDFCtg]
	   ,[udvnRelatedID]
	   ,[udvnSubRelatedID]
	   ,[udvsUDFValue]
	   ,[udvnRecUserID]
	   ,[udvdDtCreated]
	   ,[udvnModifyUserID]
	   ,[udvdDtModified]
	   ,[udvnLevelNo]
		)
		SELECT
			def.udfnUDFID AS [udvnUDFID]
		   ,'Other10'	  AS [udvsScreenName]
		   ,'C'			  AS [udvsUDFCtg]
		   ,casnCaseID	  AS [udvnRelatedID]
		   ,0			  AS [udvnSubRelatedID]
		   ,udf.FieldVal  AS [udvsUDFValue]
		   ,368			  AS [udvnRecUserID]
		   ,GETDATE()	  AS [udvdDtCreated]
		   ,NULL		  AS [udvnModifyUserID]
		   ,NULL		  AS [udvdDtModified]
		   ,NULL		  AS [udvnLevelNo]
		FROM Other10UDF udf
		LEFT JOIN sma_MST_UDFDefinition def
			ON def.udfnRelatedPK = udf.casnOrgCaseTypeID
				AND def.udfsUDFName = FieldTitle
				AND def.udfsScreenName = 'Other10'
END

ALTER TABLE sma_trn_udfvalues ENABLE TRIGGER ALL
GO
