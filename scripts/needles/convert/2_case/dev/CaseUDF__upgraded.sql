/*
Populates CaseUDF with all columns from [user_case_data]
*/

use [JohnSalazar_SA]
go

if exists (
		select
			*
		from sys.tables
		where name = 'CaseUDF'
			and type = 'U'
	)
begin
	drop table CaseUDF
end


if OBJECT_ID('tempdb..#ExcludedColumns') is not null
	drop table #ExcludedColumns;

create table #ExcludedColumns (
	column_name VARCHAR(128)
);
go

/* ------------------------------------------------------------------------------
Use this block if you need to exclude specific columns from being pushed to CaseUDF
*/ ------------------------------------------------------------------------------
---- Insert columns to exclude
insert into #ExcludedColumns
	(
		column_name
	)
	values
	('casenum'),
	('modified_timestamp')
--	('a_field_to_exclude')
go

-- Fetch all columns from [user_case_data] for unpivoting
declare @sql NVARCHAR(MAX) = N'';
select
	@sql = STRING_AGG(CONVERT(VARCHAR(MAX),
	N'CONVERT(VARCHAR(MAX), ' + QUOTENAME(column_name) + N') AS ' + QUOTENAME(column_name)
	), ', ')
from [JohnSalazar_Needles].INFORMATION_SCHEMA.COLUMNS
where
	table_name = 'user_case_data'
	and TABLE_SCHEMA = 'dbo'
	and column_name not in (
		select
			column_name
		from #ExcludedColumns
	);


-- Dynamically create the UNPIVOT list
declare @unpivot_list NVARCHAR(MAX) = N'';
select
	@unpivot_list = STRING_AGG(QUOTENAME(column_name), ', ')
from [JohnSalazar_Needles].INFORMATION_SCHEMA.COLUMNS
where
	table_name = 'user_case_data'
	and TABLE_SCHEMA = 'dbo'
	and column_name not in (
		select
			column_name
		from #ExcludedColumns
	);


-- Generate the dynamic SQL for creating the pivot table
set @sql = N'
SELECT casnCaseID, casnOrgCaseTypeID, FieldTitle, FieldVal
INTO CaseUDF
FROM ( 
    SELECT 
        cas.casnCaseID, 
        cas.casnOrgCaseTypeID, ' + @sql + N'
    FROM [JohnSalazar_Needles]..user_case_data ud
    JOIN sma_TRN_Cases cas ON cas.cassCaseNumber = CONVERT(VARCHAR, ud.casenum)
) pv
UNPIVOT (FieldVal FOR FieldTitle IN (' + @unpivot_list + N')) AS unpvt;';

exec sp_executesql @sql;
go

--select * from CaseUDF

----------------------------
--UDF DEFINITION
----------------------------
alter table [sma_MST_UDFDefinition] disable trigger all
go

if exists (
		select
			*
		from sys.tables
		where name = 'CaseUDF'
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
			'Case'									   as [udfsScreenName],
			ucf.UDFType								   as [udfsType],
			ucf.field_len							   as [udfsLength],
			1										   as [udfbIsActive],
			'user_case_data' + ucf.column_name		   as [udfshortName],
			ucf.dropdownValues						   as [udfsNewValues],
			DENSE_RANK() over (order by M.field_title) as udfnSortOrder
		from [sma_MST_CaseType] CST
		join CaseTypeMixture mix
			on mix.[SmartAdvocate Case Type] = CST.cstsType
		join [JohnSalazar_Needles].[dbo].[user_case_matter] M			-- user_case_matter defines the user fields per mattercode (case type)
			on M.mattercode = mix.matcode
				and M.field_type <> 'label'
		join (
			select distinct
				fieldTitle
			from CaseUDF
		) vd
			on vd.FieldTitle = M.field_title
		join [JohnSalazar_Needles].[dbo].[NeedlesUserFields] ucf
			on ucf.field_num = M.ref_num
		left join (
			select distinct
				table_Name,
				column_name
			from [JohnSalazar_Needles].[dbo].[document_merge_params]
			where table_Name = 'user_case_data'
		) dmp
			on dmp.column_name = ucf.field_Title
		left join [sma_MST_UDFDefinition] def
			on def.[udfnRelatedPK] = CST.cstnCaseTypeID
				and def.[udfsUDFName] = M.field_title
				and def.[udfsScreenName] = 'Case'
				and def.[udfsType] = ucf.UDFType
				and def.udfnUDFID is null
		order by M.field_title
end


alter table sma_trn_udfvalues disable trigger all
go

-- Table will not exist if it's empty or only contains ExlucedColumns
if exists (
		select
			*
		from sys.tables
		where name = 'CaseUDF'
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
			def.udfnUDFID as [udvnUDFID],
			'Case'		  as [udvsScreenName],
			'C'			  as [udvsUDFCtg],
			casnCaseID	  as [udvnRelatedID],
			0			  as [udvnSubRelatedID],
			udf.FieldVal  as [udvsUDFValue],
			368			  as [udvnRecUserID],
			GETDATE()	  as [udvdDtCreated],
			null		  as [udvnModifyUserID],
			null		  as [udvdDtModified],
			null		  as [udvnLevelNo]
		from CaseUDF udf
		left join sma_MST_UDFDefinition def
			on def.udfnRelatedPK = udf.casnOrgCaseTypeID
				and def.udfsUDFName = FieldTitle
				and def.udfsScreenName = 'Case'
end

alter table sma_trn_udfvalues enable trigger all
go
