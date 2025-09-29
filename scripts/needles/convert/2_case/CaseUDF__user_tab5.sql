use [JohnSalazar_SA]
go


/* ------------------------------------------------------------------------------
Use this block if you need to exclude specific columns from being pushed to CaseUDF
*/ ------------------------------------------------------------------------------
if OBJECT_ID('tempdb..#ExcludedColumns') is not null
	drop table #ExcludedColumns;

create table #ExcludedColumns (
	column_name VARCHAR(128)
);
go

insert into #ExcludedColumns
	(
		column_name
	)
	values
		('case_id'),
		('tab_id'),
		('tab_id_location'),
		('modified_timestamp'),
		('show_on_status_tab'),
		('case_status_attn'),
		('case_status_client');
go



if OBJECT_ID('CaseUDF') is not null
	drop table CaseUDF;

create table CaseUDF (
	source_table		  NVARCHAR(128) null,
	column_name			  NVARCHAR(255) null,
	field_title			  NVARCHAR(255) null,
	field_title_sanitized NVARCHAR(255) null,
	field_type			  NVARCHAR(20)  null,
	casnCaseID			  INT			null,
	casnOrgCaseTypeID	  INT			null,
	tab_id				  INT			null,
	user_name			  INT,
	FieldVal			  NVARCHAR(MAX) null,
	case_id				  INT
);
go


/* ----------------------------------------------------------------------
   Dynamically unpivot user_tab5_data and insert into CaseUDF
---------------------------------------------------------------------- */
declare @cols NVARCHAR(MAX),
		@colsUnpivot NVARCHAR(MAX),
		@sql NVARCHAR(MAX);

-- Convert all columns to VARCHAR(MAX) for unpivot
select
	@cols = STRING_AGG(
	'CONVERT(VARCHAR(MAX), ' + QUOTENAME(column_name) + ') AS ' + QUOTENAME(column_name),
	', '
	)
from [JohnSalazar_Needles].INFORMATION_SCHEMA.COLUMNS
where
	table_name = 'user_tab5_data'
	and
	column_name not in (select column_name from #ExcludedColumns);

-- Unpivot list
select
	@colsUnpivot = STRING_AGG(QUOTENAME(column_name), ', ')
from [JohnSalazar_Needles].INFORMATION_SCHEMA.COLUMNS
where
	table_name = 'user_tab5_data'
	and
	column_name not in (select column_name from #ExcludedColumns);

-- Dynamic SQL to insert unpivoted data with metadata, tab_id, and user_name
set @sql = N'
INSERT INTO CaseUDF (
    source_table, column_name, field_title, field_title_sanitized, field_type,
    casnCaseID, casnOrgCaseTypeID, tab_id, case_id, user_name, FieldVal
)
SELECT 
    nf.table_name AS source_table,
    nf.column_name,
    pv.field_title,
    REPLACE(REPLACE(pv.field_title, ''/'', ''_''), '' '', ''_'') AS field_title_sanitized,
    nf.field_type,
    pv.casnCaseID,
    pv.casnOrgCaseTypeID,
    pv.tab_id,
	pv.case_id,
    NULL as user_name,
    pv.FieldVal
FROM (
    SELECT 
        cas.casnCaseID, 
        cas.casnOrgCaseTypeID,
        ud.tab_id, ud.case_id, ' + @cols + '
    FROM [JohnSalazar_Needles]..user_tab5_data ud
    JOIN [JohnSalazar_Needles]..cases_Indexed c ON c.casenum = ud.case_id
    JOIN sma_TRN_Cases cas ON cas.cassCaseNumber = CONVERT(VARCHAR, ud.case_id)
) AS base
UNPIVOT (
    FieldVal FOR field_title IN (' + @colsUnpivot + ')
) AS pv
JOIN [JohnSalazar_Needles].[dbo].[NeedlesUserFields] nf
    ON nf.table_name = ''user_tab5_data''
   AND nf.column_name = pv.field_title
   AND nf.field_type <> ''label'';';

exec sp_executesql @sql;
go

--select * from CaseUDF


update c
set c.user_name = utn.user_name
from CaseUDF c
join JohnSalazar_Needles..user_tab5_name utn
	on utn.case_id = c.case_id
	and utn.tab_id = c.tab_id
where utn.user_name <> 0

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
			on nuf.table_name = 'user_tab5_data'
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
