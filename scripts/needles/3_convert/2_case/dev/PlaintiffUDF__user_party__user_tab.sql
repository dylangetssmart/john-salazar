/*
description: Populates PlaintiffUDF with fields from user_party_data

steps: >
  For each field in [user_party_matter] with [party_role] = 'Plaintiff',
  this process creates a UDF definition and populates UDF values from [user_party_data].
   The script uses a persistent mapping table (conversion.FieldTitleMap) to
  map original field titles (e.g., 'D/B/A') to SQL-safe aliases (e.g., 'D_B_A').

dependencies:
  - needles\conversion\utility\create__NeedlesUserFields.sql
  - needles\conversion\utility\create__PartyRoles.sql
  - needles\conversion\utility\create__CaseTypeMixture.sql
*/

use [JohnSalazar_SA]
go

---
alter table [sma_MST_UDFDefinition] disable trigger all
go
alter table [sma_TRN_UDFValues] disable trigger all
go
---

/* ---------------------------------------------------------------------------
Step 0: Create & populate persistent mapping table
--------------------------------------------------------------------------- */
if OBJECT_ID('conversion.FieldTitleMap', 'U') is null
begin
	create table conversion.FieldTitleMap (
		field_title		  NVARCHAR(255) not null,
		alias_field_title NVARCHAR(255) not null,
		column_name		  NVARCHAR(255) not null,
		source_table	  NVARCHAR(128) not null,
		constraint PK_FieldTitleMap primary key (alias_field_title, source_table)
	);
end

truncate table conversion.FieldTitleMap;

-- insert from user_party_data
insert into conversion.FieldTitleMap
	(
		field_title,
		alias_field_title,
		column_name,
		source_table
	)
	select distinct
		F.field_title,
		REPLACE(REPLACE(F.field_title, '/', '_'), ' ', '_') as alias_field_title,
		F.column_name,
		'user_party_data'									as source_table
	from [JohnSalazar_Needles].[dbo].[user_party_matter] M
	join [JohnSalazar_Needles].[dbo].NeedlesUserFields F
		on F.field_num = M.ref_num
	join PartyRoles R
		on R.[Needles Roles] = M.party_role
	where
		R.[SA Party] = 'Plaintiff'
		and
		F.column_name in (
		 select
			 COLUMN_NAME
		 from [JohnSalazar_Needles].INFORMATION_SCHEMA.COLUMNS
		 where TABLE_NAME = 'user_party_data'
		)
		and
		M.field_type <> 'label';

-- insert from user_tab9_data
insert into conversion.FieldTitleMap
	(
		field_title,
		alias_field_title,
		column_name,
		source_table
	)
	select distinct
		F.field_title,
		REPLACE(REPLACE(F.field_title, '/', '_'), ' ', '_') as alias_field_title,
		F.column_name,
		'user_tab9_data'									as source_table
	from [JohnSalazar_Needles].[dbo].[user_tab9_matter] M
	join [JohnSalazar_Needles].[dbo].NeedlesUserFields F
		on F.field_num = M.ref_num
	where
		F.table_name = 'user_tab9_data'
--join PartyRoles R
--	on R.[Needles Roles] = M.party_role
--where
--	R.[SA Party] = 'Plaintiff'
--	and
--	F.column_name in (
--	 select
--		 COLUMN_NAME
--	 from [JohnSalazar_Needles].INFORMATION_SCHEMA.COLUMNS
--	 where TABLE_NAME = 'user_party_data'
--	)
--	and
--	M.field_type <> 'label';


/* ---------------------------------------------------------------------------
Step 1: Populate PlaintiffUDF from [user_party_data]
--------------------------------------------------------------------------- */
if OBJECT_ID('PlaintiffUDF', 'U') is not null
	drop table PlaintiffUDF;

declare @cols NVARCHAR(MAX);
declare @sql NVARCHAR(MAX);
declare @select_expr NVARCHAR(MAX);
declare @unpivot_expr NVARCHAR(MAX);
declare @source_table NVARCHAR(25);
set @source_table = 'user_party_data';

-- Build SELECT and UNPIVOT expressions from the mapping table
select
	@select_expr  = STRING_AGG(
	'CONVERT(VARCHAR(MAX), [' + column_name + ']) AS [' + alias_field_title + ']',
	', '),
	@unpivot_expr = STRING_AGG('[' + alias_field_title + ']', ', ')
from conversion.FieldTitleMap
where
	source_table = @source_table;

set @sql = '
SELECT casnCaseID, casnOrgCaseTypeID, FieldTitle, FieldVal
INTO PlaintiffUDF
FROM ( 
    SELECT 
        cas.casnCaseID, 
        cas.casnOrgCaseTypeID, ' + @select_expr + '
    FROM [JohnSalazar_Needles]..' + @source_table + ' ud
    JOIN sma_TRN_Cases cas ON cas.cassCaseNumber = CONVERT(VARCHAR, ud.case_id)
) pv
UNPIVOT (FieldVal FOR FieldTitle IN (' + @unpivot_expr + ')) AS unpvt;
';

exec sp_executesql @sql;

-- Second source table: user_tab9_data
SET @source_table = 'user_tab9_data';

SELECT
    @select_expr  = STRING_AGG(
        'CONVERT(VARCHAR(MAX), [' + column_name + ']) AS [' + alias_field_title + ']',
        ', '
    ),
    @unpivot_expr = STRING_AGG('[' + alias_field_title + ']', ', ')
FROM conversion.FieldTitleMap
WHERE source_table = @source_table;

SET @sql = '
INSERT INTO PlaintiffUDF (casnCaseID, casnOrgCaseTypeID, FieldTitle, FieldVal)
SELECT casnCaseID, casnOrgCaseTypeID, FieldTitle, FieldVal
FROM ( 
    SELECT 
        cas.casnCaseID, 
        cas.casnOrgCaseTypeID, ' + @select_expr + '
    FROM [JohnSalazar_Needles]..' + @source_table + ' ud
    JOIN sma_TRN_Cases cas 
        ON cas.cassCaseNumber = CONVERT(VARCHAR, ud.case_id)
) pv
UNPIVOT (FieldVal FOR FieldTitle IN (' + @unpivot_expr + ')) AS unpvt;
';

EXEC sp_executesql @sql;

-- View final combined table
SELECT * FROM PlaintiffUDF;




--/* ---------------------------------------------------------------------------
--Step 1: Populate PlaintiffUDF from [user_tab9_data]
----------------------------------------------------------------------------- */

---- Create temporary table for columns to exclude
--if OBJECT_ID('tempdb..#ExcludedColumns') is not null
--	drop table #ExcludedColumns;

--create table #ExcludedColumns (
--	column_name VARCHAR(128)
--);
--go

---- Insert columns to exclude
--insert into #ExcludedColumns
--	(
--		column_name
--	)
--	values
--		('case_id'),
--		('tab_id'),
--		('tab_id_location'),
--		('modified_timestamp'),
--		('show_on_status_tab'),
--		('case_status_attn'),
--		('case_status_client');
--go

---- Dynamically get all columns from [JohnSalazar_Needles]..user_tab9_data for unpivoting
--declare @sql NVARCHAR(MAX) = N'';
--select
--	@sql = STRING_AGG(CONVERT(VARCHAR(MAX),
--	N'CONVERT(VARCHAR(MAX), ' + QUOTENAME(column_name) + N') AS ' + QUOTENAME(column_name)
--	), ', ')
--from [JohnSalazar_Needles].INFORMATION_SCHEMA.COLUMNS
--where
--	table_name = 'user_tab9_data'
--	and
--	column_name not in (select column_name from #ExcludedColumns);


---- Dynamically create the UNPIVOT list
--declare @unpivot_list NVARCHAR(MAX) = N'';
--select
--	@unpivot_list = STRING_AGG(QUOTENAME(column_name), ', ')
--from [JohnSalazar_Needles].INFORMATION_SCHEMA.COLUMNS
--where
--	table_name = 'user_tab9_data'
--	and
--	column_name not in (select column_name from #ExcludedColumns);


---- Generate the dynamic SQL for creating the pivot table
--set @sql = N'
--SELECT casnCaseID, casnOrgCaseTypeID, FieldTitle, FieldVal
--INTO PlaintiffUDF
--FROM ( 
--    SELECT 
--        cas.casnCaseID, 
--        cas.casnOrgCaseTypeID, ' + @sql + N'
--    FROM [JohnSalazar_Needles]..user_tab9_data ud
--    JOIN [JohnSalazar_Needles]..cases_Indexed c ON c.casenum = ud.case_id
--    JOIN sma_TRN_Cases cas ON cas.cassCaseNumber = CONVERT(VARCHAR, ud.case_id)
--) pv
--UNPIVOT (FieldVal FOR FieldTitle IN (' + @unpivot_list + N')) AS unpvt;';

--exec sp_executesql @sql;
--go

--select
--	*
--from PlaintiffUDF

/* ---------------------------------------------------------------------------
Step 2: Insert [sma_MST_UDFDefinition] from [user_party_data]
--------------------------------------------------------------------------- */
alter table [sma_MST_UDFDefinition] disable trigger all
go

if exists (
	 select
		 *
	 from sys.tables
	 where name = 'PlaintiffUDF'
		 and type = 'U'
	)
begin
	insert into [sma_MST_UDFDefinition]
		(
			[udfsUDFCtg],
			[udfnRelatedPK],
			[udfsUDFName],
			[udfsScreenName],
			[udfsType],
			[udfsLength],
			[udfbIsActive],
			[udfshortName],
			[udfsNewValues],
			[udfnSortOrder]
		)
		select distinct
			'C'										   as [udfsUDFCtg],
			CST.cstnCaseTypeID						   as [udfnRelatedPK],
			M.field_title							   as [udfsUDFName],
			'Plaintiff'								   as [udfsScreenName],
			ucf.UDFType								   as [udfsType],
			ucf.field_len							   as [udfsLength],
			1										   as [udfbIsActive],
			'user_party_data' + ucf.column_name		   as [udfshortName],
			ucf.dropdownValues						   as [udfsNewValues],
			DENSE_RANK() over (order by M.field_title) as udfnSortOrder
		from [sma_MST_CaseType] CST
		join CaseTypeMixture mix
			on mix.[SmartAdvocate Case Type] = CST.cstsType
		join [JohnSalazar_Needles].[dbo].[user_party_matter] M
			on M.mattercode = mix.matcode
				and M.field_type <> 'label'
		join conversion.FieldTitleMap map
			on map.field_title = M.field_title
				and map.source_table = 'user_party_data'
		join (select distinct FieldTitle from PlaintiffUDF) vd
			on vd.FieldTitle = map.alias_field_title
		join [JohnSalazar_Needles].[dbo].[NeedlesUserFields] ucf
			on ucf.field_num = M.ref_num
		--left join (
		-- select distinct
		--	 table_Name,
		--	 column_name
		-- from [JohnSalazar_Needles].[dbo].[document_merge_params]
		-- where table_Name = 'user_party_data'
		--) dmp
		--	on dmp.column_name = ucf.field_Title
		left join [sma_MST_UDFDefinition] def
			on def.[udfnRelatedPK] = CST.cstnCaseTypeID
				and def.[udfsUDFName] = M.field_title
				and def.[udfsScreenName] = 'Plaintiff'
				and def.[udfsType] = ucf.UDFType
				and def.udfnUDFID is null
		order by M.field_title;
end


/* ---------------------------------------------------------------------------
Step 2: Insert [sma_MST_UDFDefinition] from [user_tab9_data] fields
--------------------------------------------------------------------------- */
alter table [sma_MST_UDFDefinition] disable trigger all
go

if exists (
	 select
		 *
	 from sys.tables
	 where name = 'PlaintiffUDF'
		 and type = 'U'
	)
begin
	insert into [sma_MST_UDFDefinition]
		(
			[udfsUDFCtg],
			[udfnRelatedPK],
			[udfsUDFName],
			[udfsScreenName],
			[udfsType],
			[udfsLength],
			[udfbIsActive],
			[udfshortName],
			[udfsNewValues],
			[udfnSortOrder]
		)
		select distinct
			'C'										   as [udfsUDFCtg],
			CST.cstnCaseTypeID						   as [udfnRelatedPK],
			M.field_title							   as [udfsUDFName],
			'Plaintiff'								   as [udfsScreenName],
			ucf.UDFType								   as [udfsType],
			ucf.field_len							   as [udfsLength],
			1										   as [udfbIsActive],
			'user_tab9_data' + ucf.column_name		   as [udfshortName],
			ucf.dropdownValues						   as [udfsNewValues],
			DENSE_RANK() over (order by M.field_title) as udfnSortOrder
		from [sma_MST_CaseType] CST
		join CaseTypeMixture mix
			on mix.[SmartAdvocate Case Type] = CST.cstsType
		join [JohnSalazar_Needles].[dbo].[user_tab9_matter] M
			on M.mattercode = mix.matcode
				and M.field_type <> 'label'
		join conversion.FieldTitleMap map
			on map.field_title = M.field_title
				and map.source_table = 'user_tab9_data'
		join (select distinct FieldTitle from PlaintiffUDF) vd
			on vd.FieldTitle = map.alias_field_title
		join [JohnSalazar_Needles].[dbo].[NeedlesUserFields] ucf
			on ucf.field_num = M.ref_num
		--left join (
		-- select distinct
		--	 table_Name,
		--	 column_name
		-- from [JohnSalazar_Needles].[dbo].[document_merge_params]
		-- where table_Name = 'user_party_data'
		--) dmp
		--	on dmp.column_name = ucf.field_Title
		left join [sma_MST_UDFDefinition] def
			on def.[udfnRelatedPK] = CST.cstnCaseTypeID
				and def.[udfsUDFName] = M.field_title
				and def.[udfsScreenName] = 'Plaintiff'
				and def.[udfsType] = ucf.UDFType
				and def.udfnUDFID is null
		order by M.field_title;
end

/* ------------------------------------------------------------------------------
Insert UDF Values
*/ ------------------------------------------------------------------------------
alter table sma_TRN_UDFValues disable trigger all
go

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
		join conversion.FieldTitleMap map
			on udf.FieldTitle = map.alias_field_title
				and map.source_table = 'user_party_data'
		join sma_TRN_Plaintiff pln
			on pln.plnnCaseID = udf.casnCaseID
				and pln.plnbIsPrimary = 1
		join sma_MST_UDFDefinition def
			on def.udfnRelatedPK = udf.casnOrgCaseTypeID
				and def.udfsUDFName = map.field_title
end

---
alter table [sma_MST_UDFDefinition] enable trigger all
go

alter table [sma_TRN_UDFValues] enable trigger all
go
---