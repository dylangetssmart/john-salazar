/*---
description: Populate Other1UDF from [user_tab_data]
instructions:
	1. Find & Replace [Needles] with your needles database
	2. Update variables
dependencies:
    - [Needles]..[NeedlesUserFields]
notes: >
	- EAV table (Entity - Attribute - Value) is pivoted using CROSS APPLY and STRING_AGG.
	- https://en.wikipedia.org/wiki/Entity%E2%80%93attribute%E2%80%93value_model
	- See /needles/readme.md for more information
---*/


use [SA]
go


/* ------------------------------------------------------------------------------
Variables & helpers
*/ ------------------------------------------------------------------------------
declare @DatabaseName SYSNAME = 'Needles';	-- source needles database
declare @SchemaName SYSNAME = 'dbo';
declare @sourceTable SYSNAME = 'user_tab10_data';			-- source data EAV table
declare @targetTable NVARCHAR(25) = 'Other10'			-- target UDF screen				[sma_MST_UDFDefinition].[udfScreenName]
declare @targetTable_grid NVARCHAR(25) = 'UDFs Grid10'	-- target UDF screen (grid)			[sma_MST_UDFDefinition].[udfScreenName]

declare @UnpivotValueList NVARCHAR(MAX);
declare @SQL_populate_PivotedData NVARCHAR(MAX);
declare @SQL_populate_MultiRecord NVARCHAR(MAX);


-- Check for duplicates and populate ##multi_record with both the screen name and the flag.
if OBJECT_ID('tempdb..##MultiRecord') is not null
	drop table ##MultiRecord;

set @SQL_populate_MultiRecord = N'
WITH check_dupes AS (
	SELECT
        CASE WHEN EXISTS (
            SELECT 1
            FROM ' + QUOTENAME(@DatabaseName) + N'..' + QUOTENAME(@sourceTable) + N'
            GROUP BY case_id
            HAVING COUNT(*) > 1
        )
        THEN 1 ELSE 0 END AS IsMultiRecord
)
SELECT
    IsMultiRecord,
    CASE WHEN IsMultiRecord = 1
         THEN N''' + @targetTable_grid + N'''
         ELSE N''' + @targetTable + N'''
    END AS udfScreenName
INTO ##MultiRecord
FROM check_dupes;
';

exec sp_executesql @SQL_populate_MultiRecord;
--select * from ##MultiRecord;


-- define columns to exclude from the pivot.
-- we want to exclude identifying columns such as [case_id] and [tab_id]
-- as well as metadata columns such as [modified_timestamp] and [show_on_status_tab]
if OBJECT_ID('tempdb..#ExcludedCols') is not null
	drop table #ExcludedCols;

create table #ExcludedCols (
	column_name SYSNAME
);

insert into #ExcludedCols
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

/* ------------------------------------------------------------------------------
Create staging table ##Pivoted_Data
*/ ------------------------------------------------------------------------------

-- Build the list of columns to unpivot into (Attribute, Value) pairs
select
	@UnpivotValueList = STRING_AGG(
	CAST('(''' + column_name + ''', CONVERT(VARCHAR(MAX), ' + QUOTENAME(column_name) + '))' as NVARCHAR(MAX)),
	', '
	)
from [Needles].INFORMATION_SCHEMA.COLUMNS
where
	TABLE_SCHEMA = @SchemaName
	and
	table_name = @sourceTable
	and
	column_name not in (select column_name from #ExcludedCols);

print @UnpivotValueList

if OBJECT_ID('tempdb..##PivotedData') is not null
	drop table ##PivotedData;

-- Build the SQL statement to pivot the data into a temporary table
-- comment tab_id if your table doesn't have it
set @SQL_populate_PivotedData = '
SELECT 
    t.case_id, 
	t.tab_id,
    v.Attribute, 
    v.Value
INTO ##PivotedData
FROM ' + QUOTENAME(@DatabaseName) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@sourceTable) + ' AS t
CROSS APPLY (VALUES ' + @UnpivotValueList + ') AS v(Attribute, Value)
WHERE isnull(v.Value, '''') <> ''''
ORDER BY 
    t.case_id, 
	t.tab_id,
    v.Attribute;
';

--print @SQL_pivotedData;
exec sp_executesql @SQL_populate_PivotedData;

/* ------------------------------------------------------------------------------
Create final staging table [user_tab_data_pivoted]
- Add context to ##PivotedData such as [user_name] for Contact type UDFs and ROW_ID for Grid Row inserts
*/ ------------------------------------------------------------------------------
if OBJECT_ID('user_tab10_data_pivoted') is not null
	drop table user_tab10_data_pivoted;

select
	pv.case_id,
	pv.tab_id,
	case
		when (select udfScreenName from ##MultiRecord) = @targetTable_grid then DENSE_RANK() over (order by pv.case_id, pv.tab_id)
		else null
	end as ROW_ID,
	pv.Attribute,
	pv.value,
	utn.user_name,
	nuf.field_title,
	nuf.field_num,
	nuf.UDFType,
	nuf.field_type,
	nuf.field_len,
	nuf.table_name,
	nuf.column_name,
	nuf.DropDownValues
into user_tab10_data_pivoted
from ##PivotedData pv
join [Needles].[dbo].NeedlesUserFields nuf
	on nuf.column_name = pv.Attribute
		and nuf.table_name = @sourceTable
left join [Needles].[dbo].user_tab10_name utn		-- make sure this is correct: i.e. [user_tab2_name] matches with [user_tab2_data]
	on utn.case_id = pv.case_id
		and utn.tab_id = pv.tab_id
		and utn.ref_num = nuf.field_num
		and utn.user_name <> 0;
go

--select * from user_tab_data_pivoted

/* ------------------------------------------------------------------------------
Insert [sma_MST_UDFDefinition]
*/ ------------------------------------------------------------------------------
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
		'C'												as [udfsUDFCtg],
		cas.casnOrgCaseTypeID							as [udfnRelatedPK],
		pe.field_title									as [udfsUDFName],
		(select udfScreenName from ##MultiRecord)		as [udfsScreenName],
		pe.UDFType										as [udfsType],
		pe.field_len									as [udfsLength],
		1												as [udfbIsActive],
		pe.table_name + '.' + pe.column_name			as [udfshortName],
		pe.DropDownValues								as [udfsNewValues],
		DENSE_RANK() over (order by pe.field_title)		as udfnSortOrder
	--select *
	from user_tab_data_pivoted pe
	join sma_TRN_Cases cas
		on cas.saga = pe.case_id
	left join [sma_MST_UDFDefinition] def
		on def.[udfnRelatedPK] = cas.casnOrgCaseTypeID
			and def.[udfsUDFName] = pe.field_title
			and def.[udfsScreenName] = (select udfScreenName from ##MultiRecord)
			and def.[udfsType] = pe.field_type
			and def.udfnUDFID is null
	where
		def.udfnUDFID is null
	order by pe.field_title
go

alter table [sma_MST_UDFDefinition] enable trigger all
go


/* ------------------------------------------------------------------------------
Insert [sma_TRN_GridUdfsRows] if applicable
*/ ------------------------------------------------------------------------------
exec AddBreadcrumbsToTable 'sma_TRN_GridUdfsRows'
go

if (select IsMultiRecord from ##MultiRecord) = 1
begin

	insert into sma_TRN_GridUdfsRows
		(
			DtCreted,
			RecUserID,
			source_id,
			source_ref
		)
		select distinct
			GETDATE(),
			368,
			Row_ID,
			table_name
		from user_tab_data_pivoted
		where ROW_ID is not null
end

--select * from sma_TRN_GridUdfsRows


/* ------------------------------------------------------------------------------
Insert [sma_TRN_UDFValues]
*/ ------------------------------------------------------------------------------
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
		[GridRowID]
	)
	select
		def.udfnUDFID  as [udvnUDFID],
		(select udfScreenName from ##MultiRecord) as [udvsScreenName],
		'C'			   as [udvsUDFCtg],
		cas.casnCaseID as [udvnRelatedID],
		0			   as [udvnSubRelatedID],
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
		end			   as [udvsUDFValue],
		368			   as [udvnRecUserID],
		GETDATE()	   as [udvdDtCreated],
		null		   as [udvnModifyUserID],
		null		   as [udvdDtModified],
		null		   as [udvnLevelNo],
		r.ID		   as [GridRowID]
	--select *
	from user_tab_data_pivoted pe
	join sma_TRN_Cases cas
		on cas.saga = pe.case_id
	
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
			and def.[udfsScreenName] = (select udfScreenName from ##MultiRecord)
	left join sma_TRN_GridUdfsRows r
		on r.source_ID = pe.Row_ID
			and r.source_ref = pe.table_name
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
	join user_tab_data_pivoted pe
		on def.udfsUDFName = pe.field_title
		and def.udfsScreenName = (select udfScreenName from ##MultiRecord)
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
if OBJECT_ID('tempdb..##PivotedData') is not null
	drop table ##PivotedData;

if OBJECT_ID('tempdb..##MultiRecord') is not null
	drop table ##MultiRecord;

if OBJECT_ID('tempdb..#ExcludedCols') is not null
	drop table #ExcludedCols;

-- Final output
--select * from dbo.user_tab_data_pivoted; -- verify results