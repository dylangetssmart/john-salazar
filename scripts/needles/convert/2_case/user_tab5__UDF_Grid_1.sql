/*---
description:
steps:
	1. Pivot the EAV table and add context fields
	2. Create UDF Definitions
	3. Insert UDF Values
usage_instructions:
    1a. Fill out variables
	1b. Define excluded columns
	1e. Explicitly select fields as required
	2.  Construct [pivoted_enriched] with necessary fields 
dependencies:
    - [NeedlesUserFields]
    - [sma_TRN_Cases]
notes: >
    - EAV (Entity - Attribute - Value)
	- https://en.wikipedia.org/wiki/Entity%E2%80%93attribute%E2%80%93value_model
---*/


use JohnSalazar_SA
go


/* ------------------------------------------------------------------------------
1. Build the base table by pivoting EAV table 
------------------------------------------------------------------------------- */

-- 1a. Setup variables
----------------------------------------------------------------------
declare @DatabaseName SYSNAME = 'JohnSalazar_Needles';
declare @SchemaName SYSNAME = 'dbo';
declare @TableName SYSNAME = 'user_tab5_data';
declare @OutputTable SYSNAME = 'pivoted_data';

declare @DropSQL NVARCHAR(MAX) = 'IF OBJECT_ID(''' + @OutputTable + ''') IS NOT NULL DROP TABLE ' + @OutputTable + ';';
exec sp_executesql @DropSQL;

-- 1b. Define excluded columns
-- we definitely want to include [case_id] and [party_id] in the final output,
-- but they excluded here because they are explicitly selected in the dynamic SQL.
-- They are explicitly selected because we want them to be columns in the output, not data rows
----------------------------------------------------------------------
if OBJECT_ID('tempdb..#ExcludedColumns') is not null
	drop table #ExcludedColumns;

create table #ExcludedColumns (
	column_name SYSNAME
);

insert into #ExcludedColumns
	(
		column_name
	)
	values
		('case_id'),
		('tab_id'),
		('tab_id_location'),
		('party_id_location'),
		('modified_timestamp'),
		('show_on_status_tab'),
		('case_status_attn'),
		('case_status_client');

-- 1c. Build the dynamic SQL
--	CROSS APPLY to pivot the table
--	Update @SQL
----------------------------------------------------------------------
declare @UnpivotValueList NVARCHAR(MAX);
declare @SQL NVARCHAR(MAX);

-- 1d. Build the list of columns to unpivot
----------------------------------------------------------------------
select
	@UnpivotValueList = STRING_AGG(
	'(''' + column_name + ''', CONVERT(VARCHAR(MAX), ' + QUOTENAME(column_name) + '))',
	', '
	)
from [JohnSalazar_Needles].INFORMATION_SCHEMA.COLUMNS
where
	table_schema = @SchemaName
	and
	table_name = @TableName
	and
	column_name not in (select column_name from #ExcludedColumns);


-- 1e. Build the final SQL
-- Be sure to select any id fields that you want to be columns in the final output
-- specifically, any column you want to do a join on in a later step
----------------------------------------------------------------------
set @SQL = '
SELECT 
    t.case_id, 
	t.tab_id,
    v.Attribute, 
    v.Value
INTO ' + @OutputTable + ' 
FROM ' + QUOTENAME(@DatabaseName) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ' AS t
CROSS APPLY (VALUES ' + @UnpivotValueList + ') AS v(Attribute, Value)
WHERE isnull(v.Value, '''') <> ''''
ORDER BY 
    t.case_id, 
	t.tab_id,
    v.Attribute;
';

print @SQL;
exec sp_executesql @SQL;

select * from pivoted_data
go


/* ------------------------------------------------------------------------------
2. Create [pivoted_enriched]
------------------------------------------------------------------------------- */
declare @TableName SYSNAME = 'user_tab5_data';
declare @EnrichedTable SYSNAME = 'pivoted_enriched';

-- Drop the new enriched table first
declare @DropEnrichedSQL NVARCHAR(MAX) = 'IF OBJECT_ID(''' + @EnrichedTable + ''') IS NOT NULL DROP TABLE ' + @EnrichedTable + ';';
exec sp_executesql @DropEnrichedSQL;

-- Consolidate all enrichment joins into a single SELECT INTO operation
select
	pv.case_id,
	pv.tab_id,
	DENSE_RANK() over (order by pv.case_id, pv.tab_id) as ROW_ID,
	pv.Attribute,
	pv.Value,
	utn.user_name,
	nuf.field_title,
	nuf.field_num,
	nuf.UDFType,
	nuf.field_type,
	nuf.field_len,
	nuf.table_name,
	nuf.column_name,
	nuf.DropDownValues
into pivoted_enriched
from pivoted_data pv
join JohnSalazar_Needles..NeedlesUserFields nuf
	on nuf.column_name = pv.Attribute
		and nuf.table_name = @TableName -- Use the base table variable
left join JohnSalazar_Needles..user_tab5_name utn
	on utn.case_id = pv.case_id
		and utn.ref_num = nuf.field_num
		and utn.user_name <> 0;

-- Optional: Drop the temporary pivoted_data table if you no longer need it
if OBJECT_ID('pivoted_data') is not null
	drop table pivoted_data;

select * from pivoted_enriched;

/* ------------------------------------------------------------------------------
2. Create UDF Definitions
------------------------------------------------------------------------------- */
alter table [sma_MST_UDFDefinition] disable trigger all
go

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
		'C'											as [udfsUDFCtg],
		cas.casnOrgCaseTypeID						as [udfnRelatedPK],
		pe.field_title								as [udfsUDFName],
		'UDFs Grid1'								as [udfsScreenName],
		pe.UDFType									as [udfsType],
		pe.field_len								as [udfsLength],
		1											as [udfbIsActive],
		pe.table_name + '.' + pe.Attribute			as [udfshortName],
		pe.DropDownValues							as [udfsNewValues],
		DENSE_RANK() over (order by pe.field_title) as udfnSortOrder
	--select *
	from pivoted_enriched pe
	join sma_TRN_Cases cas
		on cas.saga = pe.case_id
	left join [sma_MST_UDFDefinition] def
		on def.[udfnRelatedPK] = cas.casnOrgCaseTypeID
			and def.[udfsUDFName] = pe.field_title
			and def.[udfsScreenName] = 'UDFs Grid1'
			and def.[udfsType] = pe.field_type
			and def.udfnUDFID is null
	order by pe.field_title
go

alter table [sma_MST_UDFDefinition] enable trigger all
go


/* ------------------------------------------------------------------------------
3. Insert GridRows
------------------------------------------------------------------------------- */
exec AddBreadcrumbsToTable 'sma_TRN_GridUdfsRows'
go

--alter table sma_TRN_GridUdfsRows
--add source_id varchar(255)

--alter table sma_TRN_GridUdfsRows
--add source_ref varchar(255)

insert into sma_TRN_GridUdfsRows
	(
		DtCreted,
		RecUserID,
		source_id,
		SOURCE_REF
	)
	select distinct
		GETDATE(),
		368,
		Row_ID,
		table_name
	from pivoted_enriched

select * from sma_TRN_GridUdfsRows

/* ------------------------------------------------------------------------------
4. Insert UDF Values
------------------------------------------------------------------------------- */
alter table sma_trn_udfvalues disable trigger all
go

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
		[udvnLevelNo],
		GridRowID
	)
	select distinct
		def.udfnUDFID  as [udvnUDFID],
		'UDFs Grid1'   as [udvsScreenName],
		'C'			   as [udvsUDFCtg],
		cas.casnCaseID as [udvnRelatedID],
		0			   as [udvnSubRelatedID],
		case
			when pe.field_type = 'name' then CONVERT(VARCHAR(MAX), ioci.UNQCID)
			else pe.Value
		end			   as [udvsUDFValue],
		368			   as [udvnRecUserID],
		GETDATE()	   as [udvdDtCreated],
		null		   as [udvnModifyUserID],
		null		   as [udvdDtModified],
		null		   as [udvnLevelNo],
		r.ID		   as GridRowID
	--select distinct cas.casnOrgCaseTypeID, pe.*	
	from pivoted_enriched pe
	join sma_TRN_Cases cas
		on cas.saga = pe.case_id
	left join IndvOrgContacts_Indexed ioci
		on ioci.SAGA = pe.user_name -- Joins on the populated user_name column in pivoted_data
	left join sma_MST_UDFDefinition def
		on def.udfnRelatedPK = cas.casnOrgCaseTypeID
			and def.udfsUDFName = pe.field_title
			and def.udfsScreenName = 'UDFs Grid1'
	join sma_TRN_GridUdfsRows r
		on r.source_ID = pe.Row_ID
			and r.source_ref = pe.table_name
go

alter table sma_trn_udfvalues enable trigger all
go