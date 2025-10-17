use [JohnSalazar_SA]
go

-- Drop temporary table for excluded columns
if OBJECT_ID('tempdb..#ExcludedColumns') is not null
	drop table #ExcludedColumns;

-- Create temporary table for excluded columns
create table #ExcludedColumns (
	column_name VARCHAR(128)
);
go

-- Insert columns to be excluded from the UNPIVOT operation
insert into #ExcludedColumns
	(
		column_name
	)
	values
		('casenum'),
		('tab_id'),
		('tab_id_location'),
		('modified_timestamp'),
		('show_on_status_tab'),
		('case_status_attn'),
		('case_status_client');
go

--------------------------------------------------------------------------------
-- Create or Recreate the Staging Table (CaseUDF)
--------------------------------------------------------------------------------

if OBJECT_ID('CaseUDF') is not null
	drop table CaseUDF;

create table CaseUDF (
	table_name			  NVARCHAR(128) null,
	column_name			  NVARCHAR(255) null, -- Added column_name
	field_title			  NVARCHAR(255) null,
	field_title_sanitized NVARCHAR(255) null,
	field_type			  NVARCHAR(20)  null,
	casnCaseID			  INT			null,
	casnOrgCaseTypeID	  INT			null,
	tab_id				  INT			null, -- Included tab_id
	user_name			  INT,
	FieldVal			  NVARCHAR(MAX) null,
	case_id				  INT -- Included case_id (from casenum)
);
go

--------------------------------------------------------------------------------
-- Dynamic SQL Generation for UNPIVOT
--------------------------------------------------------------------------------

-- Dynamically get all columns from [JohnSalazar_Needles]..user_case_data for UNPIVOTING
declare @select_list NVARCHAR(MAX) = N'';
select
	@select_list = STRING_AGG(CONVERT(VARCHAR(MAX),
	N'CONVERT(NVARCHAR(MAX), ' + QUOTENAME(column_name) + N') AS ' + QUOTENAME(column_name)
	), ', ')
from [JohnSalazar_Needles].INFORMATION_SCHEMA.COLUMNS
where
	table_name = 'user_case_data'
	and
	column_name not in (select column_name from #ExcludedColumns);
--print @select_list

-- Dynamically create the UNPIVOT list
declare @unpivot_list NVARCHAR(MAX) = N'';
select
	@unpivot_list = STRING_AGG(QUOTENAME(column_name), ', ')
from [JohnSalazar_Needles].INFORMATION_SCHEMA.COLUMNS
where
	table_name = 'user_case_data'
	and
	column_name not in (select column_name from #ExcludedColumns);


-- Generate the dynamic SQL for inserting into existing CaseUDF table
declare @sql_dynamic NVARCHAR(MAX) = N'';
set @sql_dynamic = N'
INSERT INTO CaseUDF
(
    table_name,
	column_name,
	field_title,
	field_title_sanitized,
	field_type,
    casnCaseID,
	casnOrgCaseTypeID,
	tab_id,
	case_id,
	user_name,
	FieldVal
)
SELECT 
    nf.table_name,
    nf.column_name,
    pv.field_title,
    REPLACE(REPLACE(pv.field_title, ''/'', ''_''), '' '', ''_'') AS field_title_sanitized,
    nf.field_type,
    pv.casnCaseID,
    pv.casnOrgCaseTypeID,
    NULL		as tab_id,
	pv.casenum,
    NULL		as user_name,
    pv.FieldVal
FROM (
    SELECT 
        cas.casnCaseID, 
        cas.casnOrgCaseTypeID,
        ud.casenum, ' + @select_list + '
    FROM [JohnSalazar_Needles]..user_case_data ud
    JOIN sma_TRN_Cases cas ON cas.cassCaseNumber = CONVERT(VARCHAR, ud.casenum)
) AS base
UNPIVOT (
    FieldVal FOR field_title IN (' + @unpivot_list + ')
) AS pv
JOIN [JohnSalazar_Needles].[dbo].[NeedlesUserFields] nf
    ON nf.table_name = ''user_case_data''
   AND nf.column_name = pv.field_title
   AND nf.field_type <> ''label'';';



exec sp_executesql @sql_dynamic;
go

-- Sanity check (optional)
--select * from CaseUDF;


update c
set c.user_name = ucn.user_name
from CaseUDF c
join JohnSalazar_Needles..user_case_matter ucm
	on ucm.field_title = c.field_title
join JohnSalazar_Needles..user_case_name ucn
	on ucn.ref_num = ucm.ref_num
	and ucn.casenum = c.case_id
where ucn.user_name <> 0

--select * from CaseUDF


----------------------------
--UDF DEFINITION
----------------------------
alter table [sma_MST_UDFDefinition] disable trigger all
go

if exists (select * from sys.tables where name = 'CaseUDF' and type = 'U')
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
			'C'											 as [udfsUDFCtg],
			udf.casnOrgCaseTypeID						 as [udfnRelatedPK],
			udf.field_title								 as [udfsUDFName],
			'Case'										 as [udfsScreenName],
			nuf.UDFType									 as [udfsType],
			nuf.field_len								 as [udfsLength],
			1											 as [udfbIsActive],
			nuf.table_name + '.' + nuf.column_name		 as [udfshortName],
			nuf.dropdownValues							 as [udfsNewValues],
			DENSE_RANK() over (order by udf.field_title) as udfnSortOrder
		--select *
		from CaseUDF udf
		join [JohnSalazar_Needles].[dbo].[NeedlesUserFields] nuf
			on nuf.table_name = 'user_case_data'
				and nuf.column_name = udf.column_name
		left join [sma_MST_UDFDefinition] def
			on def.[udfnRelatedPK] = udf.casnOrgCaseTypeID
				and def.[udfsUDFName] = udf.field_title
				and def.[udfsScreenName] = 'Case'
				and def.[udfsType] = nuf.UDFType
				and def.udfnUDFID is null
		order by udf.field_title
end


alter table sma_trn_udfvalues disable trigger all
go

-- Table will not exist if it's empty or only contains ExlucedColumns
if exists (select * from sys.tables where name = 'CaseUDF' and type = 'U')
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
			def.udfnUDFID as [udvnUDFID],
			'Case'		  as [udvsScreenName],
			'C'			  as [udvsUDFCtg],
			casnCaseID	  as [udvnRelatedID],
			0			  as [udvnSubRelatedID],
			case
				when udf.field_type = 'name' then CONVERT(VARCHAR(MAX), ioci.UNQCID)
				else udf.FieldVal
			end			  as [udvsUDFValue],
			368			  as [udvnRecUserID],
			GETDATE()	  as [udvdDtCreated],
			null		  as [udvnModifyUserID],
			null		  as [udvdDtModified],
			null		  as [udvnLevelNo]
		--select * 
		from CaseUDF udf
		join IndvOrgContacts_Indexed ioci
			on ioci.SAGA = udf.user_name
		left join sma_MST_UDFDefinition def
			on def.udfnRelatedPK = udf.casnOrgCaseTypeID
				and def.udfsUDFName = udf.field_title
				and def.udfsScreenName = 'Case'
end

alter table sma_trn_udfvalues enable trigger all
go
