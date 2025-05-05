/* ########################################################
This script populates UDF Other8 with all columns from user_tab8_data
*/

use [JohnSalazar_SA]
go

if exists (
		select
			*
		from sys.tables
		where name = 'Other8UDF'
			and type = 'U'
	)
begin
	drop table Other8UDF
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
VALUES (
'case_id'
),
(
'tab_id'
),
(
'tab_id_location'
),
(
'modified_timestamp'
),
(
'show_on_status_tab'
),
(
'case_status_attn'
),
(
'case_status_client'
);
go

-- Dynamically get all columns from [JohnSalazar_Needles]..user_tab8_data for unpivoting
declare @sql NVARCHAR(MAX) = N'';
select
	@sql = STRING_AGG(CONVERT(VARCHAR(MAX),
	N'CONVERT(VARCHAR(MAX), ' + QUOTENAME(column_name) + N') AS ' + QUOTENAME(column_name)
	), ', ')
from [JohnSalazar_Needles].INFORMATION_SCHEMA.COLUMNS
where table_name = 'user_tab8_data'
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
where table_name = 'user_tab8_data'
	and column_name not in (
		select
			column_name
		from #ExcludedColumns
	);


-- Generate the dynamic SQL for creating the pivot table
set @sql = N'
SELECT casnCaseID, casnOrgCaseTypeID, FieldTitle, FieldVal
INTO Other8UDF
FROM ( 
    SELECT 
        cas.casnCaseID, 
        cas.casnOrgCaseTypeID, ' + @sql + N'
    FROM [JohnSalazar_Needles]..user_tab8_data ud
    JOIN [JohnSalazar_Needles]..cases_Indexed c ON c.casenum = ud.case_id
    JOIN sma_TRN_Cases cas ON cas.cassCaseNumber = CONVERT(VARCHAR, ud.case_id)
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
		where name = 'Other8UDF'
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
			'C'										   as [udfsudfctg],
			cst.cstnCaseTypeID						   as [udfnrelatedpk],
			m.field_title							   as [udfsudfname],
			'Other8'								   as [udfsscreenname],
			ucf.UDFType								   as [udfstype],
			ucf.field_len							   as [udfslength],
			1										   as [udfbisactive],
			'user_tab8_data' + ucf.column_name		   as [udfshortname],
			ucf.dropdownValues						   as [udfsnewvalues],
			DENSE_RANK() over (order by m.field_title) as udfnsortorder
		from [sma_MST_CaseType] cst
		join CaseTypeMixture mix
			on mix.[SmartAdvocate Case Type] = cst.cstsType
		join [[JohnSalazar_Needles]].[dbo].[user_tab8_matter] m
			on m.mattercode = mix.matcode
				and m.field_type <> 'label'
		join (
			select distinct
				REPLACE(fieldtitle, '_', ' ') as fieldtitle
			from Other8UDF
		) vd
			on vd.fieldtitle = REPLACE(REPLACE(m.field_title, '/', ''), '.', '')
		join [dbo].[NeedlesUserFields] ucf
			on ucf.field_num = m.ref_num
		left join (
			select distinct
				table_Name,
				column_name
			from [[JohnSalazar_Needles]].[dbo].[document_merge_params]
			where table_Name = 'user_tab8_data'
		) dmp
			on dmp.column_name = ucf.field_Title
		left join [sma_MST_UDFDefinition] def
			on def.[udfnrelatedpk] = cst.cstnCaseTypeID
				and def.[udfsudfname] = m.field_title
				and def.[udfsscreenname] = 'Other8'
				and def.[udfstype] = ucf.UDFType
				and def.udfnUDFID is null
		order by m.field_title
end


alter table sma_trn_udfvalues disable trigger all
go

-- Table will not exist if it's empty or only contains ExlucedColumns
if exists (
		select
			*
		from sys.tables
		where name = 'Other8UDF'
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
			def.udfnUDFID as [udvnudfid],
			'Other8'	  as [udvsscreenname],
			'C'			  as [udvsudfctg],
			casnCaseID	  as [udvnrelatedid],
			0			  as [udvnsubrelatedid],
			udf.FieldVal  as [udvsudfvalue],
			368			  as [udvnrecuserid],
			GETDATE()	  as [udvddtcreated],
			null		  as [udvnmodifyuserid],
			null		  as [udvddtmodified],
			null		  as [udvnlevelno]
		from Other8UDF udf
		left join sma_MST_UDFDefinition def
			on def.udfnRelatedPK = udf.casnOrgCaseTypeID
				and def.udfsUDFName = FieldTitle
				and def.udfsScreenName = 'Other8'
end

alter table sma_trn_udfvalues enable trigger all
go
