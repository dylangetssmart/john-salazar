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
	TABLE_SCHEMA = @SchemaName
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
if OBJECT_ID('user_case_data_pivoted') is not null
	drop table user_case_data_pivoted;

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


/* ------------------------------------------------------------------------------
2. Insert [sma_MST_UDFDefinition]
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
		'Case'										as [udfsScreenName],
		pe.UDFType									as [udfsType],
		pe.field_len								as [udfsLength],
		1											as [udfbIsActive],
		pe.table_name + '.' + pe.column_name		as [udfshortName],
		pe.DropDownValues							as [udfsNewValues],
		DENSE_RANK() over (order by pe.field_title) as udfnSortOrder
	--select *
	from user_case_data_pivoted pe
	join sma_TRN_Cases cas
		on cas.saga = pe.casenum
	left join [sma_MST_UDFDefinition] def
		on def.[udfnRelatedPK] = cas.casnOrgCaseTypeID
			and def.[udfsUDFName] = pe.field_title
			and def.[udfsScreenName] = 'Case'
			and def.[udfsType] = pe.field_type
			and def.udfnUDFID is null
	order by pe.field_title
go

alter table [sma_MST_UDFDefinition] enable trigger all
go

/* ------------------------------------------------------------------------------
3. Insert [sma_TRN_UDFValues]
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
		[udvnLevelNo]
	)
	select
		def.udfnUDFID		as [udvnUDFID],
		'Case'				as [udvsScreenName],
		'C'					as [udvsUDFCtg],
		cas.casnCaseID		as [udvnRelatedID],
		0					as [udvnSubRelatedID],
		case
			when pe.field_type = 'name' then CONVERT(VARCHAR(MAX), ioci.UNQCID)
			when pe.field_type = 'staff' then CONVERT(VARCHAR(MAX), ioci_staff.UNQCID)
			when pe.field_type = 'checkbox' then CONVERT(VARCHAR(1),		-- IMPORTANT: cast the INT result from this branch to ensure the entire CASE evauates to VARCHAR across all branches
					case
						when UPPER(LTRIM(RTRIM(pe.value))) in ('0', 'NO', 'N', 'FALSE') then 0
						when UPPER(LTRIM(RTRIM(pe.value))) in ('1', 'YES', 'Y', 'TRUE') then 1
					end
					)
			when pe.field_type = 'date' then CONVERT(VARCHAR(10), TRY_CONVERT(DATE, pe.value), 101)
			when pe.field_type = 'time' then dbo.FormatUDFTime(pe.value)
			else pe.value
		end			   		as [udvsUDFValue],
		368					as [udvnRecUserID],
		GETDATE()			as [udvdDtCreated],
		null				as [udvnModifyUserID],
		null				as [udvdDtModified],
		null				as [udvnLevelNo]
	--select *
	from user_case_data_pivoted pe
	join sma_TRN_Cases cas
		on cas.saga = pe.casenum
	left join IndvOrgContacts_Indexed ioci
		on ioci.SAGA = pe.user_name

	-- fetch UNQCID for user_name
	left join IndvOrgContacts_Indexed ioci
	on ioci.SAGA = pe.user_name
		and pe.field_type = 'name'

	-- fetch UNQCID for staff record
	left join IndvOrgContacts_Indexed ioci_staff
	on ioci_staff.source_id = pe.Value
		and ioci_staff.source_ref = 'staff'
		and pe.field_type = 'staff'

	left join sma_MST_UDFDefinition def
		on def.udfnRelatedPK = cas.casnOrgCaseTypeID
			and def.udfsUDFName = pe.field_title
			and def.udfsScreenName = 'Case'
go

alter table sma_trn_udfvalues enable trigger all
go


/* ------------------------------------------------------------------------------
Insert [sma_MST_UDFPossibleValues] for dropdown/selection type UDFs
*/ ------------------------------------------------------------------------------
alter table [sma_MST_UDFPossibleValues] disable trigger all
go

-- Process each UDF definition that has dropdown values
declare @udfnUDFID INT;
declare @udfsType NVARCHAR(50);
declare @DropDownValues NVARCHAR(MAX);
declare @PossibleValue NVARCHAR(255);

declare udf_cursor cursor for select distinct
		def.udfnUDFID,
		def.udfsType,
		pe.DropDownValues
	from [sma_MST_UDFDefinition] def
	join user_case_data_pivoted pe
		on def.udfsUDFName = pe.field_title
		and def.udfsScreenName = 'Case'
	where def.udfsType in ('Dropdown', 'Multiselect', 'RadioButton', 'MultiselectDropDown', 'YesNoRadioButton', 'RealDropdown', 'Combobox', 'CheckBox')
		and pe.DropDownValues is not null
		and pe.DropDownValues <> '';

open udf_cursor;
fetch next from udf_cursor into @udfnUDFID, @udfsType, @DropDownValues;

while @@FETCH_STATUS = 0
begin
-- Parse dropdown values and insert them

if @DropDownValues is not null
	and @DropDownValues <> ''
begin
	-- Create a table variable to hold parsed values
	declare @udfsPossibleValues table (
			PossibleValue NVARCHAR(255)
		);

	-- Parse the dropdown values (using tilde '~' as delimiter based on data format)
	-- Split the dropdown values and insert into temp table
	insert into @udfsPossibleValues
		(
			PossibleValue
		)
		select
			LTRIM(RTRIM(value)) as PossibleValue
		from STRING_SPLIT(@DropDownValues, '~')
		where
			LTRIM(RTRIM(value)) <> ''
			and
			LTRIM(RTRIM(value)) <> '~';

	-- Insert into sma_MST_UDFPossibleValues

	if exists (select * from @udfsPossibleValues)
	begin
		insert into sma_MST_UDFPossibleValues
			(
				UDFDefinitionId,
				PossibleValue
			)
			select
				@udfnUDFID as UDFDefinitionId,
				pv.PossibleValue
			from @udfsPossibleValues as pv
			where
				not exists (
				 select
					 1
				 from sma_MST_UDFPossibleValues existing
				 where existing.UDFDefinitionId = @udfnUDFID
					 and existing.PossibleValue = pv.PossibleValue
				);
	end;

	-- Clear the table variable for next iteration

	delete from @udfsPossibleValues;
end;

fetch next from udf_cursor into @udfnUDFID, @udfsType, @DropDownValues;
end;

close udf_cursor;
deallocate udf_cursor;
go

alter table [sma_MST_UDFPossibleValues] enable trigger all
go


/* ------------------------------------------------------------------------------
Clean Up
*/ ------------------------------------------------------------------------------

-- Drop temp tables
if OBJECT_ID('tempdb..##Pivoted_Data') is not null
	drop table ##Pivoted_Data;

if OBJECT_ID('tempdb..#ExcludedColumns') is not null
	drop table #ExcludedColumns;

-- Final output
--select * from dbo.user_case_data_pivoted; -- verify results