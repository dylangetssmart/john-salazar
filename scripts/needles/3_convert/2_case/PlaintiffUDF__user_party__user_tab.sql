use [JohnSalazar_SA];
go

/*
description: Populates PlaintiffUDF and related UDF tables from multiple source tables
steps: >
  Dynamically unpivots fields from source tables, populates a persistent mapping table, 
  creates/updates UDF definitions and UDF values.
dependencies:
  - NeedlesUserFields
  - PartyRoles
  - CaseTypeMixture
*/

-- ---------------------------------------------------------------------------
-- Step 0: Disable triggers for bulk inserts
-- ---------------------------------------------------------------------------
alter table [sma_MST_UDFDefinition] disable trigger all;
alter table [sma_TRN_UDFValues] disable trigger all;
go

-- ---------------------------------------------------------------------------
-- Step 1: Ensure FieldTitleMap exists
-- ---------------------------------------------------------------------------
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

-- ---------------------------------------------------------------------------
-- Step 2: Populate FieldTitleMap for all source tables
-- ---------------------------------------------------------------------------
truncate table conversion.FieldTitleMap;

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
	join [JohnSalazar_Needles].[dbo].[NeedlesUserFields] F
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
		M.field_type <> 'label'
	union all
	select distinct
		F.field_title,
		REPLACE(REPLACE(F.field_title, '/', '_'), ' ', '_') as alias_field_title,
		F.column_name,
		'user_tab9_data'									as source_table
	from [JohnSalazar_Needles].[dbo].[user_tab9_matter] M
	join [JohnSalazar_Needles].[dbo].[NeedlesUserFields] F
		on F.field_num = M.ref_num
	where
		F.table_name = 'user_tab9_data'
		and
		M.field_type <> 'label';

-- ---------------------------------------------------------------------------
-- Step 3: Create/Populate PlaintiffUDF dynamically for each source table
-- ---------------------------------------------------------------------------
-- Drop the table if it already exists to ensure a clean run.
if OBJECT_ID('PlaintiffUDF', 'U') is not null
	drop table PlaintiffUDF;

-- Declare a table variable to hold the source table names.
declare @SourceTables table (
	SourceTable NVARCHAR(128)
);
insert into @SourceTables
	values
		('user_party_data'),
		('user_tab9_data');

-- Declare variables for the loop and dynamic SQL.
declare @src NVARCHAR(128);
declare @select_expr NVARCHAR(MAX);
declare @unpivot_expr NVARCHAR(MAX);
declare @sql NVARCHAR(MAX);
declare @first BIT = 1;

-- Set up and open the cursor.
declare src_cursor cursor for select
	SourceTable
from @SourceTables;
open src_cursor;
fetch next from src_cursor into @src;

while @@FETCH_STATUS = 0
begin
-- Build the SELECT expression to convert and alias columns from the source table.
select
	@select_expr = STRING_AGG(
	'CONVERT(VARCHAR(MAX), [' + column_name + ']) AS [' + alias_field_title + ']', ', ')
from conversion.FieldTitleMap
where
	source_table = @src;

-- Build the UNPIVOT expression with the list of alias field titles.
select
	@unpivot_expr = STRING_AGG('[' + alias_field_title + ']', ', ')
from conversion.FieldTitleMap
where
	source_table = @src;

-- Build the dynamic SQL.
-- The first loop uses SELECT INTO to create the table, the rest use INSERT INTO.

if @first = 1
begin
	print 'Processing ' + @src + ' with SELECT INTO...';
	set @sql = '
			SELECT casnCaseID, casnOrgCaseTypeID, FieldTitle, FieldVal
			INTO PlaintiffUDF
			FROM (
				SELECT
					cas.casnCaseID,
					cas.casnOrgCaseTypeID, ' + @select_expr + '
				FROM [JohnSalazar_Needles]..' + @src + ' ud
				JOIN sma_TRN_Cases cas
					ON cas.cassCaseNumber = CONVERT(VARCHAR, ud.case_id)
			) pv
			UNPIVOT (FieldVal FOR FieldTitle IN (' + @unpivot_expr + ')) AS unpvt;';
	set @first = 0;
end
else
begin
	print 'Processing ' + @src + ' with INSERT INTO...';
	set @sql = '
			INSERT INTO PlaintiffUDF (casnCaseID, casnOrgCaseTypeID, FieldTitle, FieldVal)
			SELECT casnCaseID, casnOrgCaseTypeID, FieldTitle, FieldVal
			FROM (
				SELECT
					cas.casnCaseID,
					cas.casnOrgCaseTypeID, ' + @select_expr + '
				FROM [JohnSalazar_Needles]..' + @src + ' AS ud
				JOIN sma_TRN_Cases cas
					ON cas.cassCaseNumber = CONVERT(VARCHAR, ud.case_id)
			) pv
			UNPIVOT (FieldVal FOR FieldTitle IN (' + @unpivot_expr + ')) AS unpvt;';
end

-- Execute the dynamic SQL.
exec sp_executesql @sql;

fetch next from src_cursor into @src;
end

-- Close and deallocate the cursor.
close src_cursor;
deallocate src_cursor;

-- Optional: verify results
select
	*
from PlaintiffUDF;

-- ---------------------------------------------------------------------------
-- Step 4: Insert UDF Definitions dynamically
-- ---------------------------------------------------------------------------
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
		'C'											 as [udfsUDFCtg],
		CST.cstnCaseTypeID							 as [udfnRelatedPK],
		map.field_title								 as [udfsUDFName],
		'Plaintiff'									 as [udfsScreenName],
		ucf.UDFType									 as [udfsType],
		ucf.field_len								 as [udfsLength],
		1											 as [udfbIsActive],
		map.source_table + ucf.column_name			 as [udfshortName],
		ucf.dropdownValues							 as [udfsNewValues],
		DENSE_RANK() over (order by map.field_title) as udfnSortOrder
	from PlaintiffUDF udf
	join conversion.FieldTitleMap map
		on udf.FieldTitle = map.alias_field_title
	join [JohnSalazar_Needles].[dbo].[NeedlesUserFields] ucf
		on ucf.column_name = map.column_name
		and ucf.table_name = map.source_table
	join [sma_MST_CaseType] CST
		on CST.cstsType in (
			 select
				 mix.[SmartAdvocate Case Type]
			 from CaseTypeMixture mix
			)
	left join [sma_MST_UDFDefinition] def
		on def.[udfnRelatedPK] = CST.cstnCaseTypeID
			and def.[udfsUDFName] = map.field_title
			and def.[udfsScreenName] = 'Plaintiff'
			and def.[udfsType] = ucf.UDFType
	where
		def.udfnUDFID is null
	order by map.field_title;


-- ---------------------------------------------------------------------------
-- Step 5: Insert UDF Values dynamically
-- ---------------------------------------------------------------------------
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
		udf.casnCaseID		as [udvnRelatedID],
		pln.plnnPlaintiffID as [udvnSubRelatedID],
		udf.FieldVal		as [udvsUDFValue],
		368					as [udvnRecUserID],  -- Or use current user
		GETDATE()			as [udvdDtCreated],
		null				as [udvnModifyUserID],
		null				as [udvdDtModified],
		null				as [udvnLevelNo]
	from PlaintiffUDF udf
	join conversion.FieldTitleMap map
		on udf.FieldTitle = map.alias_field_title
	join sma_TRN_Plaintiff pln
		on pln.plnnCaseID = udf.casnCaseID
			and pln.plnbIsPrimary = 1
	join sma_MST_UDFDefinition def
		on def.udfnRelatedPK = udf.casnOrgCaseTypeID
			and def.udfsUDFName = map.field_title
			and def.udfsScreenName = 'Plaintiff'
			and def.udfsType = (
			 select top 1
				 UDFType
			 from [JohnSalazar_Needles].[dbo].[NeedlesUserFields]
			 where column_name = map.column_name
			);

-- ---------------------------------------------------------------------------
-- Step 6: Re-enable triggers
-- ---------------------------------------------------------------------------
alter table [sma_MST_UDFDefinition] enable trigger all;
alter table [sma_TRN_UDFValues] enable trigger all;
go
