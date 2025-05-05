/* 
For intake cases that were converted into matters, push all intake data into UDF
*/

--select top 5
--	ID					 as LitifyIntakeID,
--	litify_pm__Matter__c LitifyMatterID,
--	cas.casnCaseID,
--	cas.cassCaseNumber,
--	cas.cassCaseName
--from ShinerLitify..litify_pm__Intake__c
--join sma_trn_cases cas
--	on cas.saga_char = litify_pm__Matter__c
-- 1,671

use ShinerSA
go

if exists (
		select
			*
		from sys.tables
		where name = 'Other1UDF'
			and type = 'U'
	)
begin
	drop table Other1UDF
end

-- Create temporary table for columns to exclude
if OBJECT_ID('tempdb..#ExcludedColumns') is not null
	drop table #ExcludedColumns;

create table #ExcludedColumns (
	column_name VARCHAR(128)
);
go

-- Insert columns to exclude
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

-- Dynamically get all columns from JoelBieberNeedles..user_tab_data for unpivoting
declare @sql NVARCHAR(MAX) = N'';
select
	@sql = STRING_AGG(CONVERT(VARCHAR(MAX),
	N'CONVERT(VARCHAR(MAX), ' + QUOTENAME(column_name) + N') AS ' + QUOTENAME(column_name)
	), ', ')
from ShinerLitify.INFORMATION_SCHEMA.COLUMNS
where
	TABLE_NAME = 'litify_pm__Intake__c'
	and column_name not in (
		select
			column_name
		from #ExcludedColumns
	);


-- Dynamically create the UNPIVOT list
declare @unpivot_list NVARCHAR(MAX) = N'';
select
	@unpivot_list = STRING_AGG(QUOTENAME(column_name), ', ')
from ShinerLitify.INFORMATION_SCHEMA.COLUMNS
where
	TABLE_NAME = 'litify_pm__Intake__c'
	and column_name not in (
		select
			column_name
		from #ExcludedColumns
	);


-- Generate the dynamic SQL for creating the pivot table
set @sql = N'
SELECT casnCaseID, casnOrgCaseTypeID, FieldTitle, FieldVal
INTO Other1UDF
FROM ( 
    SELECT 
        cas.casnCaseID, 
        cas.casnOrgCaseTypeID, ' + @sql + N'
    FROM ShinerLitify..litify_pm__Intake__c i
    JOIN sma_TRN_Cases cas ON cas.saga_char = i.litify_pm__Matter__c
) pv
UNPIVOT (FieldVal FOR FieldTitle IN (' + @unpivot_list + N')) AS unpvt;';

exec sp_executesql @sql;
go

----------------------------
--UDF DEFINITION
----------------------------
alter table [sma_MST_UDFDefinition] disable trigger all
go

if exists (
		select
			*
		from sys.tables
		where name = 'Other1UDF'
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
			FieldTitle							   as [udfsUDFName],
			'Other12'								   as [udfsScreenName],
			'Text'									   as [udfsType],
			1000							   as [udfsLength],
			1										   as [udfbIsActive],
			'litify_pm__Intake__c.' + udf.FieldTitle   as [udfshortName],
			''					   as [udfsNewValues],
			DENSE_RANK() over (order by udf.FieldTitle) as udfnSortOrder
		from [sma_MST_CaseType] CST
		join CaseTypeMap mix
			on mix.[SmartAdvocate Case Type] = CST.cstsType
		join Other1UDF udf
			on udf.casnOrgCaseTypeID = cst.cstnCaseTypeID
		--JOIN [JoelBieberNeedles].[dbo].[user_tab_matter] M
		--	ON M.mattercode = mix.matcode
		--		AND M.field_type <> 'label'
		--JOIN (
		--	SELECT DISTINCT
		--		fieldTitle
		--	FROM Other1UDF
		--) vd
		--	ON vd.FieldTitle = M.field_title
		--JOIN [dbo].[NeedlesUserFields] ucf
		--	ON ucf.field_num = M.ref_num
		--LEFT JOIN (
		--	SELECT DISTINCT
		--		table_Name
		--	   ,column_name
		--	FROM [JoelBieberNeedles].[dbo].[document_merge_params]
		--	WHERE table_Name = 'user_tab_data'
		--) dmp
		--	ON dmp.column_name = ucf.field_Title
		
		--left join [sma_MST_UDFDefinition] def
		--	on def.[udfnRelatedPK] = CST.cstnCaseTypeID
		--		and def.[udfsUDFName] = M.field_title
		--		and def.[udfsScreenName] = 'Other1'
		--		and def.[udfsType] = ucf.UDFType
		--		and def.udfnUDFID is null
		--order by M.field_title
end

alter table [sma_MST_UDFDefinition] enable trigger all
go


alter table sma_trn_udfvalues disable trigger all
go

-- Table will not exist if it's empty or only contains ExlucedColumns
if exists (
		select
			*
		from sys.tables
		where name = 'Other1UDF'
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
			'Other12'	  as [udvsScreenName],
			'C'			  as [udvsUDFCtg],
			casnCaseID	  as [udvnRelatedID],
			0			  as [udvnSubRelatedID],
			udf.FieldVal  as [udvsUDFValue],
			368			  as [udvnRecUserID],
			GETDATE()	  as [udvdDtCreated],
			null		  as [udvnModifyUserID],
			null		  as [udvdDtModified],
			null		  as [udvnLevelNo]
		from Other1UDF udf
		left join sma_MST_UDFDefinition def
			on def.udfnRelatedPK = udf.casnOrgCaseTypeID
				and def.udfsUDFName = FieldTitle
				and def.udfsScreenName = 'Other12'
end

alter table sma_trn_udfvalues enable trigger all
go
