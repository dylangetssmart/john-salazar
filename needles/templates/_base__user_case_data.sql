/*---
description: Base script to pivot and enrich EAV data from [user_case_data]
steps:
	1. Pivot the EAV table
	2. Enrich the pivoted data with context and UDF definitions
usage_instructions:
	1. Adjust variables and excluded columns
	2. Review field selections for the final output table
dependencies:
    - [NeedlesUserFields]
notes: >
	- EAV (Entity - Attribute - Value) is pivoted using CROSS APPLY and STRING_AGG.
	- https://en.wikipedia.org/wiki/Entity%E2%80%93attribute%E2%80%93value_model
---*/


use [SA]
go


-------------------------------------------------------------------------------
-- Setup variables
-------------------------------------------------------------------------------
declare @DatabaseName SYSNAME = 'Needles';
declare @SchemaName SYSNAME = 'dbo';
declare @TableName SYSNAME = 'user_case_data'; -- source EAV table
declare @UnpivotValueList NVARCHAR(MAX);
declare @SQL NVARCHAR(MAX);

-- Define excluded columns for the pivot (columns NOT to be treated as EAV attributes)
if OBJECT_ID('tempdb..#ExcludedColumns') is not null drop table #ExcludedColumns;
create table #ExcludedColumns (column_name SYSNAME);

insert into #ExcludedColumns (column_name)
values
	('casenum'), -- Excluded from EAV attributes but explicitly selected later
	('modified_timestamp');

-------------------------------------------------------------------------------
-- 2. Build the Dynamic SQL for Pivoting the EAV Table
-------------------------------------------------------------------------------

-- 2a. Build the list of columns to unpivot into (Attribute, Value) pairs
select
	@UnpivotValueList = STRING_AGG(
	CAST('(''' + column_name + ''', CONVERT(VARCHAR(MAX), ' + QUOTENAME(column_name) + '))' as NVARCHAR(MAX)),
	', '
	)
from [Needles].INFORMATION_SCHEMA.COLUMNS
where
	table_schema = @SchemaName
	and
	table_name = @TableName
	and
	column_name not in (select column_name from #ExcludedColumns);

-- 2b. Build the final SQL statement to pivot the data into a temporary table
set @SQL = '
SELECT 
    t.casenum, 
    v.Attribute, 
    v.Value
INTO ##Pivoted_Data
FROM ' + QUOTENAME(@DatabaseName) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ' AS t
CROSS APPLY (VALUES ' + @UnpivotValueList + ') AS v(Attribute, Value)
WHERE isnull(v.Value, '''') <> '''';
';

print @SQL; -- uncomment to debug
exec sp_executesql @SQL;


-------------------------------------------------------------------------------
-- 3. Enrich the Pivoted Data and Create Final Output
-------------------------------------------------------------------------------
if OBJECT_ID('user_case_data_pivoted') is not null drop table user_case_data_pivoted;

select
	pv.casenum,
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
into user_case_data_pivoted
from ##Pivoted_Data pv
join [Needles].[dbo].NeedlesUserFields nuf
	on nuf.column_name = pv.Attribute
		and nuf.table_name = 'user_case_data'
left join [Needles].[dbo].user_case_name utn
	on utn.casenum = pv.casenum
		and utn.ref_num = nuf.field_num
		and utn.user_name <> 0;
go

-------------------------------------------------------------------------------
-- 4. Clean Up
-------------------------------------------------------------------------------

-- Drop temp tables
if OBJECT_ID('tempdb..##Pivoted_Data') is not null drop table ##Pivoted_Data;
if OBJECT_ID('tempdb..#ExcludedColumns') is not null drop table #ExcludedColumns;

-- Final output
select * from dbo.user_case_data_pivoted; -- verify results