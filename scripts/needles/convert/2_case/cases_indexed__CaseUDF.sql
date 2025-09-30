/*---
description: Insert CaseUDF
steps:
	- Create exclusion list for columns
	- Build CaseUDF staging table dynamically per column/table
	- Insert missing UDF Definitions from CaseUDF into sma_MST_UDFDefinition
	- Insert UDF Values from CaseUDF into sma_TRN_UDFValues
usage_instructions: >
	1. Update ExcludedColumns list at the top of the script as needed
	2. Adjust SourceTables in cursor query if adding more user_tab tables
dependencies:
	- [NeedlesUserFields]
notes: >
---*/

use [JohnSalazar_SA]
go


--/* ======================================================================
--   1. CREATE EXCLUSION LIST
--   ----------------------------------------------------------------------
--   Hand-pick fields to exclude. Any column listed here will be ignored
--   in the CaseUDF build and all downstream inserts.
--   ====================================================================== */
--if OBJECT_ID('tempdb..#ExcludedColumns') is not null
--	drop table #ExcludedColumns;

--create table #ExcludedColumns (
--	column_name VARCHAR(128)
--);

---- Hand-pick fields to exclude here
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

--/* ======================================================================
--   2. BUILD CASEUDF TABLE
--   ----------------------------------------------------------------------
--   Creates CaseUDF staging table and dynamically inserts rows for all 
--   columns not listed in #ExcludedColumns, joining on the appropriate 
--   caseid_col for each source table.
--   ====================================================================== */
--if OBJECT_ID('CaseUDF') is not null
--	drop table CaseUDF;

--create table CaseUDF (
--	source_table	  NVARCHAR(128) not null,
--	casnCaseID		  INT			null,
--	casnOrgCaseTypeID INT			null,
--	field_title		  NVARCHAR(255) not null,
--	field_val		  NVARCHAR(MAX) null
--);

--declare @src NVARCHAR(128),
--		@col NVARCHAR(128),
--		@caseid_col NVARCHAR(128),
--		@sql NVARCHAR(MAX);

---- Cursor over distinct table/column combos with caseid_col
--declare cur cursor for select distinct
--	table_name,
--	column_name,
--	caseid_col
--from [JohnSalazar_Needles].[dbo].[NeedlesUserFields]
--where table_name in ('user_tab5_data', 'user_case_data')
--	and column_name not in (select column_name from #ExcludedColumns)
--order by table_name, column_name;

--open cur;
--fetch next from cur into @src, @col, @caseid_col;

--while @@FETCH_STATUS = 0
--begin

---- Build dynamic SQL per column with correct caseid_col join
--set @sql = '
--        insert into CaseUDF (source_table, casnCaseID, casnOrgCaseTypeID, field_title, field_val)
--        select ''' + @src + ''',
--               cas.casnCaseID,
--               cas.casnOrgCaseTypeID,
--               ''' + @col + ''',
--               convert(varchar(max), ud.' + QUOTENAME(@col) + ')
--        from [JohnSalazar_Needles]..' + QUOTENAME(@src) + ' ud
--        join sma_TRN_Cases cas on cas.cassCaseNumber = convert(varchar, ud.' + QUOTENAME(@caseid_col) + ')
--        where ud.' + QUOTENAME(@col) + ' is not null;
--    ';

---- Execute
--exec sp_executesql @sql;

--fetch next from cur into @src, @col, @caseid_col;
--end

--close cur;
--deallocate cur;


--select * from CaseUDF;


/* ======================================================================
   3. INSERT INTO sma_MST_UDFDefinition
   ----------------------------------------------------------------------
   Populates UDF Definition records for any fields in CaseUDF not already
   present in sma_MST_UDFDefinition.
   ====================================================================== */
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
		'C'										 as [udfsUDFCtg],
		cas.casnOrgCaseTypeID					 as [udfnRelatedPK],
		'Referred To'							 as [udfsUDFName],
		'Case'									 as [udfsScreenName],
		'Contact'								 as [udfsType],
		20										 as [udfsLength],
		1										 as [udfbIsActive],
		'cases_indexed' + '.' + 'referred_to_id' as [udfshortName],
		null									 as [udfsNewValues],
		null									 as udfnSortOrder
	from JohnSalazar_Needles..cases_Indexed ci
	join sma_TRN_Cases cas
		on cas.saga = ci.casenum
	left join [sma_MST_UDFDefinition] def
		on def.[udfnRelatedPK] = cas.casnOrgCaseTypeID
			and def.[udfsUDFName] = 'Referred To'
			and def.[udfsScreenName] = 'Case'
			and def.[udfsType] = 'Contact'
			and def.udfnUDFID is null

go

alter table [sma_MST_UDFDefinition] enable trigger all
go


/* ======================================================================
   4. INSERT INTO sma_TRN_UDFValues
   ----------------------------------------------------------------------
   Inserts all UDF values from CaseUDF into sma_TRN_UDFValues with correct
   mapping to UDF Definition IDs.
   ====================================================================== */
alter table [sma_TRN_UDFValues] disable trigger all
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
		def.udfnUDFID as [udvnUDFID],
		'Case'		  as [udvsScreenName],
		'C'			  as [udvsUDFCtg],
		casnCaseID	  as [udvnRelatedID],
		0			  as [udvnSubRelatedID],
		ioci.UNQCID	  as [udvsUDFValue],		-- and in udf values, the udvsUDFValue is the Unique contact ID for the person.
		368			  as [udvnRecUserID],
		GETDATE()	  as [udvdDtCreated],
		null		  as [udvnModifyUserID],
		null		  as [udvdDtModified],
		null		  as [udvnLevelNo]
	from JohnSalazar_Needles..cases_Indexed ci
	join sma_TRN_Cases cas
		on cas.saga = ci.casenum
	join IndvOrgContacts_Indexed ioci
		on ioci.SAGA = ci.referred_to_id
	left join sma_MST_UDFDefinition def
		on def.udfnRelatedPK = cas.casnOrgCaseTypeID
			and def.udfsUDFName = 'Referred To'
			and def.udfsScreenName = 'Case'
	where
		ci.referred_to_id <> 0

go

alter table [sma_TRN_UDFValues] enable trigger all
go
---