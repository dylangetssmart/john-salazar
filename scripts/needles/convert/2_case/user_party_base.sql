/*---
description: Base script to collect data from [user_party_data]
steps:
	1. Pivot the EAV table and add context fields
	2. Create UDF Definitions
	3. Insert UDF Values
usage_instructions:
    1a. Fill out variables
	1b. Define excluded columns
	1e. Explicitly select fields as required
	1g. Add [user_name] from the associated [name] table
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
declare @TableName SYSNAME = 'user_party_data';
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
		('party_id'),
		('case_id'),
		('party_id_location'),
		('modified_timestamp');

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
    t.party_id, 
    t.case_id, 
    v.Attribute, 
    v.Value
INTO ' + @OutputTable + ' 
FROM ' + QUOTENAME(@DatabaseName) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ' AS t
CROSS APPLY (VALUES ' + @UnpivotValueList + ') AS v(Attribute, Value)
WHERE isnull(v.Value, '''') <> ''''
ORDER BY 
    t.case_id, 
	t.party_id,
    v.Attribute;
';

print @SQL;
exec sp_executesql @SQL;

select * from pivoted_data
go

/* ------------------------------------------------------------------------------
2. Create [pivoted_enriched]
------------------------------------------------------------------------------- */
declare @TableName SYSNAME = 'user_party_data';
declare @EnrichedTable SYSNAME = 'pivoted_enriched';

-- Drop the new enriched table first
declare @DropEnrichedSQL NVARCHAR(MAX) = 'IF OBJECT_ID(''' + @EnrichedTable + ''') IS NOT NULL DROP TABLE ' + @EnrichedTable + ';';
exec sp_executesql @DropEnrichedSQL;

-- Consolidate all enrichment joins into a single SELECT INTO operation
select distinct
	pv.case_id,
	pv.Attribute,
	pv.Value,
	upm.party_role,
	upn.user_name,
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
join [JohnSalazar_Needles].[dbo].NeedlesUserFields nuf
	on nuf.column_name = pv.Attribute
		and nuf.table_name = @TableName -- Use the base table variable
join [JohnSalazar_Needles].[dbo].user_party_matter upm
	on upm.ref_num = nuf.field_num
join PartyRoles pr
	on pr.[Needles Roles] = upm.party_role
left join [JohnSalazar_Needles].[dbo].user_party_name upn
	on upn.case_id = pv.case_id
		and upn.party_id = pv.party_id
		and upn.ref_num = nuf.field_num
		and upn.user_name <> 0
go

select * from pivoted_enriched;

-- Optional: Drop the temporary pivoted_data table if you no longer need it
if OBJECT_ID('pivoted_data') is not null
	drop table pivoted_data;

-- Cleanup temp table
if OBJECT_ID('tempdb..#ExcludedColumns') is not null
	drop table #ExcludedColumns;