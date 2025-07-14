/*
description: Populates PlaintiffUDF with fields from user_party_data

steps: >
  For each field in [user_party_matter] with [party_role] = 'Plaintiff',
  this process creates a UDF definition and populates UDF values from [user_party_data].

dependencies:
  - needles\conversion\utility\create__NeedlesUserFields.sql
  - needles\conversion\utility\create__PartyRoles.sql
  - needles\conversion\utility\create__CaseTypeMixture.sql
*/

--IF OBJECT_ID('plaintiff_user_party_data', 'U') IS NOT NULL
--	DROP TABLE plaintiff_user_party_data;

use [JohnSalazar_SA]
go

IF OBJECT_ID('PlaintiffUDF', 'U') IS NOT NULL
    DROP TABLE PlaintiffUDF;

DECLARE @cols NVARCHAR(MAX);
DECLARE @sql NVARCHAR(MAX);
DECLARE @unpivot_sql NVARCHAR(MAX);
DECLARE @select_expr NVARCHAR(MAX);

-- Get distinct column names from NeedlesUserFields filtered by party role,
-- but only keep those columns that exist in user_party_data table.
SELECT @cols = STRING_AGG(QUOTENAME(column_name), ', ')
FROM (
    SELECT DISTINCT F.column_name
    FROM NeedlesUserFields F
    JOIN [JohnSalazar_Needles]..user_party_matter M ON F.field_num = M.ref_num
    JOIN PartyRoles R ON R.[Needles Roles] = M.party_role
    WHERE R.[SA Party] = 'Plaintiff'
) AS FilteredCols
WHERE FilteredCols.column_name IN (
    SELECT COLUMN_NAME
    FROM [JohnSalazar_Needles].INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo'
      AND TABLE_NAME = 'user_party_data'
);
-- PRINT @cols; -- optional debug


-- Use @cols to generate expressions like: CONVERT(VARCHAR(MAX), [ColumnName]) AS [ColumnName]
SELECT @select_expr = STRING_AGG(
    CAST('CONVERT(VARCHAR(MAX), ' + LTRIM(value) + ') AS ' + LTRIM(value) AS NVARCHAR(MAX)),
    ', '
)
FROM STRING_SPLIT(@cols, ',');

-- Use same list for UNPIVOT
SET @unpivot_sql = @cols;

-- Final dynamic SQL
SET @sql = '
SELECT casnCaseID, casnOrgCaseTypeID, FieldTitle, FieldVal
INTO PlaintiffUDF
FROM ( 
    SELECT 
        cas.casnCaseID, 
        cas.casnOrgCaseTypeID, ' + @select_expr + '
    FROM [JohnSalazar_Needles]..user_party_data ud
    JOIN sma_TRN_Cases cas ON cas.cassCaseNumber = CONVERT(VARCHAR, ud.case_id)
) pv
UNPIVOT (FieldVal FOR FieldTitle IN (' + @unpivot_sql + ')) AS unpvt;
';

--PRINT @sql; -- optional debug
EXEC sp_executesql @sql;

-- Optional: View results
SELECT * FROM PlaintiffUDF order by FieldTitle
--SELECT distinct FieldTitle FROM PlaintiffUDF order by FieldTitle

/* ------------------------------------------------------------------------------
Create UDF Definitions
*/ ------------------------------------------------------------------------------

ALTER TABLE [sma_MST_UDFDefinition] DISABLE TRIGGER all
go

IF EXISTS (
		SELECT
			*
		FROM sys.tables
		WHERE name = 'PlaintiffUDF'
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
		   ,'Plaintiff'								   AS [udfsScreenName]
		   ,ucf.UDFType								   AS [udfsType]
		   ,ucf.field_len							   AS [udfsLength]
		   ,1										   AS [udfbIsActive]
		   ,'user_party_data' + ucf.column_name		   AS [udfshortName]
		   ,ucf.dropdownValues						   AS [udfsNewValues]
		   ,DENSE_RANK() OVER (ORDER BY M.field_title) AS udfnSortOrder
		FROM [sma_MST_CaseType] CST
		JOIN CaseTypeMixture mix
			ON mix.[SmartAdvocate Case Type] = CST.cstsType
		JOIN [JohnSalazar_Needles].[dbo].[user_party_matter] M
			ON M.mattercode = mix.matcode
				AND M.field_type <> 'label'
		JOIN (
			SELECT DISTINCT
				fieldTitle
			FROM PlaintiffUDF
		) vd
			ON vd.FieldTitle = M.field_title
		JOIN [dbo].[NeedlesUserFields] ucf
			ON ucf.field_num = M.ref_num
		LEFT JOIN (
			SELECT DISTINCT
				table_Name
			   ,column_name
			FROM [JohnSalazar_Needles].[dbo].[document_merge_params]
			WHERE table_Name = 'user_party_data'
		) dmp
			ON dmp.column_name = ucf.field_Title
		LEFT JOIN [sma_MST_UDFDefinition] def
			ON def.[udfnRelatedPK] = CST.cstnCaseTypeID
				AND def.[udfsUDFName] = M.field_title
				AND def.[udfsScreenName] = 'plaintiff'
				AND def.[udfsType] = ucf.UDFType
				AND def.udfnUDFID IS NULL
		ORDER BY M.field_title
end

/* ------------------------------------------------------------------------------
Insert UDF Values
*/ ------------------------------------------------------------------------------
if exists (
		select
			*
		from sys.tables
		where name = 'PlaintiffUDF'
			and type = 'U'
	)
begin
	insert into [sma_TRN_UDFValues]
		(
			[udvnUDFID],
			[udvsScreenName],
			[udvsUDFCtg],
			[udvnRelatedID],
			[udvnSubRelatedID],
			[udvsUDFValue],
			[udvnRecUserID],
			[udvdDtCreated],
			[udvnModifyUserID],
			[udvdDtModified],
			[udvnLevelNo]
		)
		select
			def.udfnUDFID		as [udvnUDFID],
			'Plaintiff'			as [udvsScreenName],
			'C'					as [udvsUDFCtg],
			casnCaseID			as [udvnRelatedID],
			pln.plnnPlaintiffID as [udvnSubRelatedID],
			udf.FieldVal		as [udvsUDFValue],
			368					as [udvnRecUserID],
			GETDATE()			as [udvdDtCreated],
			null				as [udvnModifyUserID],
			null				as [udvdDtModified],
			null				as [udvnLevelNo]
		--select *
		from PlaintiffUDF udf
		join sma_TRN_Plaintiff pln
			on pln.plnnCaseID = udf.casnCaseID
				and pln.plnbIsPrimary = 1
		 join sma_MST_UDFDefinition def
			on def.udfnRelatedPK = udf.casnOrgCaseTypeID
				and def.udfsUDFName = FieldTitle
				and def.udfsScreenName = 'Plaintiff'
end