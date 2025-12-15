/*---
description: Insert Medical Requests from user_tab2_data
steps:
	- Disable triggers, add breadcrumbs, create staging table
	- Create Record Types from user_tab2_data.info_types
	- Insert [sma_TRN_Hospitals]
	- Insert [sma_TRN_MedicalProviderRequest] from the staging table
usage_instructions: >
	1. Update the stored procedure BuildNeedlesUserTabStagingTable arguments
	2. Configure [sma_TRN_MedicalProviderRequest] insert as per client specifications
dependencies:
	- 
notes: >
---*/

use [JohnSalazar_SA]
go

---
alter table [sma_TRN_Hospitals] disable trigger all
go

alter table [sma_TRN_MedicalProviderRequest] disable trigger all
go

exec AddBreadcrumbsToTable 'sma_TRN_MedicalProviderRequest'
exec AddBreadcrumbsToTable 'sma_TRN_Hospitals'
go

--exec dbo.BuildNeedlesUserTabStagingTable @SourceDatabase = 'JohnSalazar_Needles',
--										 @TargetDatabase = 'JohnSalazar_SA',
--										 @DataTableName	 = 'user_tab2_data',
--										 @StagingTable	 = 'staging_medical_requests',
--										 @ColumnList	 = '
--Date_Received,
--Date_Requested,
--Name,
--Date_Range,
--FUp_Notes,
--Fax,
--Value_Code,
--Latest_FollowUp,
--Info_Type,
--Staff_Rcvd,
--Aff_Rcvd,
--Billing_Company,
--Collection_Company,
--Billing_Exp,
--Collection_Exp,
--LOP_Sent,
--Aff_filed_in_court,
--LOP';
--go
---


--------------------------------------
----MEDICAL PROVIDER HELPER
--------------------------------------
--if exists (
--	 select
--		 *
--	 from sys.objects
--	 where name = 'user_tab2_MedicalProvider_Helper'
--		 and type = 'U'
--	)
--begin
--	drop table user_tab2_MedicalProvider_Helper
--end

--go

-----(0)---
--create table user_tab2_MedicalProvider_Helper (
--	TableIndex	   [INT] identity (1, 1) not null,
--	case_id		   INT,
--	tab_id		   INT,
--	ProviderNameId INT,
--	ProviderName   VARCHAR(200),
--	ProviderCID	   INT,
--	ProviderCTG	   INT,
--	ProviderAID	   INT,
--	casnCaseID	   INT,
--	constraint IOC_Clustered_Index_user_tab2_MedicalProvider_Helper primary key clustered (TableIndex)
--) on [PRIMARY]
--go

--create nonclustered index IX_NonClustered_Index_user_tab2_MedicalProvider_Helper_case_id on [user_tab2_MedicalProvider_Helper] (case_id);
--create nonclustered index IX_NonClustered_Index_user_tab2_MedicalProvider_Helper_tab_id on [user_tab2_MedicalProvider_Helper] (tab_id);
--create nonclustered index IX_NonClustered_Index_user_tab2_MedicalProvider_Helper_ProviderNameId on [user_tab2_MedicalProvider_Helper] (ProviderNameId);
--go

-----(0)---
--insert into user_tab2_MedicalProvider_Helper
--	(
--		case_id,
--		tab_id,
--		ProviderNameId,
--		ProviderName,
--		ProviderCID,
--		ProviderCTG,
--		ProviderAID,
--		casnCaseID
--	)
--	select
--		D.case_id	   as case_id,
--		D.tab_id	   as tab_id,		-- needles records TAB item
--		N.[user_name]  as ProviderNameId,
--		IOC.[Name]	   as ProviderName,
--		IOC.CID		   as ProviderCID,
--		IOC.CTG		   as ProviderCTG,
--		IOC.AID		   as ProviderAID,
--		CAS.casnCaseID as casnCaseID
--	from [JohnSalazar_Needles].[dbo].[user_tab2_data] D
--	join [JohnSalazar_Needles].[dbo].[user_tab2_name] N
--		on N.tab_id = D.tab_id
--			and N.user_name <> 0
--			and N.ref_num = (select top 1 M.ref_num from [JohnSalazar_Needles].[dbo].[user_tab2_matter] M where M.field_title in ('Provider Name', 'Billing Company', 'Record Provider'))
--	join [JohnSalazar_Needles].[dbo].[user_tab2_name] N2
--		on N2.tab_id = D.tab_id
--			and N2.user_name <> 0
--			and N2.ref_num = (select top 1 M.ref_num from [JohnSalazar_Needles].[dbo].[user_tab2_matter] M where M.field_title in ('Staff Making Request', 'Billing Company', 'Record Provider'))
--	join [IndvOrgContacts_Indexed] IOC
--		on IOC.SAGA = N.user_name
--	join [sma_TRN_Cases] CAS
--		on CAS.cassCaseNumber = D.case_id

--go

-----(0)---
--dbcc dbreindex ('user_tab2_MedicalProvider_Helper', ' ', 90) with no_infomsgs
--go



use JohnSalazar_SA
go


-------------------------------------------------------------------------------
-- Setup variables
-------------------------------------------------------------------------------
declare @DatabaseName SYSNAME = 'JohnSalazar_Needles';
declare @SchemaName SYSNAME = 'dbo';
declare @TableName SYSNAME = 'user_tab2_data'; -- source EAV table
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
		('case_id'),
		('tab_id'),
		('tab_id_location'),
		('party_id_location'),
		('modified_timestamp'),
		('show_on_status_tab'),
		('case_status_attn'),
		('case_status_client');

-------------------------------------------------------------------------------
-- 2. Build the Dynamic SQL for Pivoting the EAV Table
-------------------------------------------------------------------------------

-- 2a. Build the list of columns to unpivot into (Attribute, Value) pairs
select
	@UnpivotValueList = STRING_AGG(
	CAST('(''' + column_name + ''', CONVERT(VARCHAR(MAX), ' + QUOTENAME(column_name) + '))' as NVARCHAR(MAX)),
	', '
	)
from [JohnSalazar_Needles].INFORMATION_SCHEMA.COLUMNS
where
	TABLE_SCHEMA = @SchemaName
	and
	table_name = @TableName
	and
	column_name not in (select column_name from #ExcludedColumns);


-- 2b. Build the final SQL statement to pivot the data into a temporary table
set @SQL = '
SELECT 
    t.case_id, 
	t.tab_id,
    v.Attribute, 
    v.Value
INTO ##Pivoted_Data
FROM ' + QUOTENAME(@DatabaseName) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ' AS t
CROSS APPLY (VALUES ' + @UnpivotValueList + ') AS v(Attribute, Value)
WHERE isnull(v.Value, '''') <> ''''
ORDER BY 
    t.case_id, 
	t.tab_id,
    v.Attribute;
';

print @SQL; -- uncomment to debug
exec sp_executesql @SQL;


-------------------------------------------------------------------------------
-- 3. Enrich the Pivoted Data and Create Final Output
-------------------------------------------------------------------------------
if OBJECT_ID('user_tab_data_pivoted') is not null
	drop table user_tab_data_pivoted;

select
	pv.case_id,
	pv.tab_id,
	DENSE_RANK() over (order by pv.case_id, pv.tab_id) as ROW_ID,	-- used for UDF Grid
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
into user_tab2_data_pivoted
from ##Pivoted_Data pv
join [JohnSalazar_Needles].[dbo].NeedlesUserFields nuf
	on nuf.column_name = pv.Attribute
		and nuf.table_name = 'user_tab_data'
left join [JohnSalazar_Needles].[dbo].user_tab2_name utn
	on utn.case_id = pv.case_id
		and utn.ref_num = nuf.field_num
		and utn.tab_id = pv.tab_id
		and utn.user_name <> 0;
go
--if OBJECT_ID('tempdb..##Pivoted_Data') is not null drop table ##Pivoted_Data;
--drop table user_tab2_data_pivoted

select
	*
from user_tab2_data_pivoted
where
	case_id = 215400

/* ------------------------------------------------------------------------------
RECORD REQUEST TYPES
*/ ------------------------------------------------------------------------------
--select * from sma_MST_Request_RecordTypes

insert into sma_MST_Request_RecordTypes
	(
		RecordType
	)
	(select distinct
		smr.Info_Type
	from staging_medical_requests smr
	where ISNULL(smr.Info_Type, '') <> ''
	)
	union
	select
		'Unspecified'
	except
	select
		RecordType
	from sma_MST_Request_RecordTypes


/* ------------------------------------------------------------------------------
REQUEST STATUS
*/ ------------------------------------------------------------------------------

insert into sma_MST_RequestStatus
	(
		Status,
		Description
	)
	select
		'No Records Available',
		'No Records Available'
	except
	select
		Status,
		Description
	from sma_MST_RequestStatus
go


--------------------------------------------------------------------------
---------------------------- MEDICAL PROVIDERS ---------------------------
--------------------------------------------------------------------------
insert into [sma_TRN_Hospitals]
	(
		[hosnCaseID],
		[hosnContactID],
		[hosnContactCtg],
		[hosnAddressID],
		[hossMedProType],
		[hosdStartDt],
		[hosdEndDt],
		[hosnPlaintiffID],
		[hosnComments],
		[hosnHospitalChart],
		[hosnRecUserID],
		[hosdDtCreated],
		[hosnModifyUserID],
		[hosdDtModified],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select distinct
		casnCaseID												 as [hosnCaseID],
		ioci.CID												 as [hosnContactID],
		ioci.CTG												 as [hosnContactCtg],
		ioci.AID												 as [hosnAddressID],
		'M'														 as [hossMedProType],			--M or P (P for Prior Medical Provider)
		null													 as [hosdStartDt],
		null													 as [hosdEndDt],
		(
		 select
			 plnnPlaintiffID
		 from [sma_TRN_Plaintiff]
		 where plnnCaseID = casnCaseID
			 and plnbIsPrimary = 1
		)														 as hosnPlaintiffID,
		''														 as [hosnComments],
		null													 as [hosnHospitalChart],
		368														 as [hosnRecUserID],
		GETDATE()												 as [hosdDtCreated],
		null													 as [hosnModifyUserID],
		null													 as [hosdDtModified],
		null													 as [saga],
		'user_tab2_data.tab_id = ' + CONVERT(VARCHAR, pe.tab_id) as [source_id],
		'needles'												 as [source_db],
		'user_tab2_data'										 as [source_ref]
	--select *
	from user_tab2_data_pivoted pe
	join sma_TRN_Cases cas
		on cas.saga = pe.case_id
	join IndvOrgContacts_Indexed ioci
		on ioci.saga = pe.user_name
			and pe.field_type = 'name'
	left join [sma_TRN_Hospitals] H
		on H.hosnCaseID = cas.casnCaseID
			and H.hosnContactID = ioci.CID
			and H.hosnContactCtg = ioci.CTG
			and H.hosnAddressID = ioci.AID
	where
		H.hosnHospitalID is null	--only add the hospital if it does not already exist
		and
		ISNULL(pe.user_name, 0) <> 0

--select *
--from staging_medical_requests smr
--where smr.caseid=215400
--join sma_TRN_Cases cas
--	on cas.saga = smr.caseid
--join IndvOrgContacts_Indexed ioci
--	on ioci.saga = smr.Name_CID
--left join [sma_TRN_Hospitals] H
--	on H.hosnCaseID = cas.casnCaseID
--		and H.hosnContactID = ioci.CID
--		and H.hosnContactCtg = ioci.CTG
--		and H.hosnAddressID = ioci.AID
--where
--	H.hosnHospitalID is null	--only add the hospital if it does not already exist
--	and
--	ISNULL(smr.Name_CID, '') <> ''

--from [JohnSalazar_Needles].[dbo].[user_tab2_data] D
--join user_tab2_MedicalProvider_Helper MAP
--	on MAP.case_id = D.case_id
--		and MAP.tab_id = D.tab_id
--left join [sma_TRN_Hospitals] H
--	on H.hosnCaseID = MAP.casnCaseID
--		and H.hosnContactID = MAP.ProviderCID
--		and H.hosnContactCtg = MAP.ProviderCTG
--		and H.hosnAddressID = MAP.ProviderAID
--where
--	H.hosnHospitalID is null	--only add the hospital if it does not already exist
--	and
--	(   ISNULL(d.Provider_Name, '') <> ''
--		or
--		ISNULL(d.Billing_Company, '') <> ''
--		or
--		ISNULL(d.Record_Provider, '') <> ''
--	)



/* ------------------------------------------------------------------------------
Medical Requests

  - [Staff_Making_Request] and [Ordered_By] do not link to name records,
  - so a custom map is used to find the associated [staff] records

*/ ------------------------------------------------------------------------------

--IF OBJECT_ID('MedicalRequest_staff_map', 'U') IS NOT NULL
--    DROP TABLE MedicalRequest_staff_map;
--GO

--create table MedicalRequest_staff_map (
--    input_string varchar(100),
--    staff_code varchar(50),
--    full_name varchar(200)
--);

--insert into MedicalRequest_staff_map (input_string, staff_code, full_name)
--values
--('mglarrow', 'MATTHEW', 'Matthew Glarrow'),
--('qgamble',  'QUEENIE', 'Queenie Gamble'),
--('chowe',    'CARSON',  'Carson Howe'),
--('DORIS',    'DORIS',   'Doris Billups'),
--('lwesson',  'LAUREN',  'Lauren Wesson'),
--('bpierce',  'BILLIE',  'Billie Pierce'),
--('Michele',  'MICHELE', 'Michele Webb'),
--('Stewart',  'STEWART', 'Stewart E. Vance'),
--('Kyle',     'KYLE',    'Kyle D. Weidman'),
--('Jabeka',   'JABEKA',  'Jabeka Macklin');
--go


insert into [sma_trn_MedicalProviderRequest]
	(
		MedPrvCaseID,
		MedPrvPlaintiffID,
		MedPrvhosnHospitalID,
		MedPrvRecordType,
		MedPrvRequestdate,
		MedPrvAssignee,
		MedPrvAssignedBy,
		MedPrvHighPriority,
		MedPrvFromDate,
		MedPrvToDate,
		MedPrvComments,
		MedPrvNotes,
		MedPrvCompleteDate,
		MedPrvStatusId,
		MedPrvFollowUpDate,
		MedPrvStatusDate,
		OrderAffidavit,
		FollowUpNotes,		--Retrieval Provider Notes
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		hosnCaseID												  as MedPrvCaseID,
		hosnPlaintiffID											  as MedPrvPlaintiffID,
		H.hosnHospitalID										  as MedPrvhosnHospitalID,
		COALESCE((
		 select
			 uId
		 from sma_MST_Request_RecordTypes
		 where RecordType = utd.Info_Type
		), (
		 select
			 uId
		 from sma_MST_Request_RecordTypes
		 where RecordType = 'Unspecified'
		))														  as MedPrvRecordType,
		dbo.ValidDate(utd.Date_Requested)						  as MedPrvRequestdate,
		--		(select u.usrnUserID from sma_MST_Users u where u.source_id = utd.Staff_Rcvd)		as MedPrvAssignee,
		u.usrnUserID											  as MedPrvAssignee,
		null													  as MedPrvAssignedBy,		-- Requested By
		0														  as MedPrvHighPriority,		-- 1=high priority; 0=Normal
		null													  as MedPrvFromDate,
		null													  as MedPrvToDate,
		CONCAT_WS(CHAR(13),
		CONCAT('FUp Notes: ', NULLIF(CONVERT(VARCHAR(MAX), utd.FUp_Notes), '')),
		CONCAT('Fax: ', NULLIF(CONVERT(VARCHAR(MAX), utd.Fax), '')),
		CONCAT('Aff Rcvd: ', NULLIF(CONVERT(VARCHAR(MAX), utd.Aff_Rcvd), '')),
		CONCAT('Aff filed in court: ', NULLIF(CONVERT(VARCHAR(MAX), utd.Aff_filed_in_court), '')),
		CONCAT('Date Range: ', NULLIF(CONVERT(VARCHAR(MAX), utd.Date_Range), ''))
		)														  as MedPrvComments,
		CONCAT_WS(CHAR(13),
		CONCAT('LOP: ', NULLIF(CONVERT(VARCHAR(MAX), utd.LOP), '')),
		CONCAT('LOP Sent: ', NULLIF(CONVERT(VARCHAR(MAX), utd.LOP_Sent), ''))
		)														  as MedPrvNotes,
		null													  as MedPrvCompleteDate,
		case
			when ISNULL(utd.Date_Received, '') <> '' then (
					 select
						 uId
					 from [sma_MST_RequestStatus]
					 where [Status] = 'Received'
					)
			else null
		end														  as MedPrvStatusId,
		dbo.ValidDate(utd.Latest_FollowUp)						  as MedPrvFollowUpDate,
		dbo.ValidDate(utd.Date_Received)						  as MedPrvStatusDate,
		0														  as OrderAffidavit,
		null													  as FollowUpNotes,	--Retreival Provider Notes
		null													  as [saga],
		'user_tab2_data.tab_id = ' + CONVERT(VARCHAR, utd.tab_id) as [source_id],
		'needles'												  as [source_db],
		'user_tab2_data'										  as [source_ref]
	--select *
	from JohnSalazar_Needles..user_tab2_data utd
	join sma_TRN_Cases cas
		on cas.saga = utd.case_id
	join JohnSalazar_Needles..user_tab2_name utn
		on utn.case_id = utd.case_id
			and utn.tab_id = utd.tab_id

	left join JohnSalazar_sa..sma_MST_Users u
		on u.source_id = utd.Staff_Rcvd

	join IndvOrgContacts_Indexed ioci
		on ioci.saga = utn.user_name
	--and pe.field_type = 'name'
	left join [sma_TRN_Hospitals] H
		on H.hosnCaseID = cas.casnCaseID
			and H.hosnContactID = ioci.CID
			and H.hosnContactCtg = ioci.CTG
			and H.hosnAddressID = ioci.AID
	where
		H.hosnHospitalID is null	--only add the hospital if it does not already exist
		and
		utd.Value_Code = 'MEDICAL'


----select *
--from staging_medical_requests smr
--join sma_TRN_Cases cas
--	on cas.saga = smr.caseid
--join IndvOrgContacts_Indexed ioci
--	on ioci.saga = smr.Name_CID
--left join [sma_TRN_Hospitals] H
--	on H.hosnCaseID = cas.casnCaseID
--		and H.hosnContactID = ioci.CID
--		and H.hosnContactCtg = ioci.CTG
--		and H.hosnAddressID = ioci.AID
--		and h.source_id = 'user_tab2_data.tab_id = ' + CONVERT(VARCHAR, smr.tabid)
--where smr.Value_Code = 'MEDICAL'

--where
--	H.hosnHospitalID is null	--only add the hospital if it does not already exist
--	and
--	ISNULL(smr.Name_CID, '') <> ''


--from [JohnSalazar_Needles].[dbo].[user_tab2_data] UD
--join [JohnSalazar_Needles].[dbo].[cases] C
--	on C.casenum = ud.case_id
--join user_tab2_MedicalProvider_Helper MAP
--	on MAP.case_id = UD.case_id
--		and MAP.tab_id = UD.tab_id
--join [sma_TRN_Hospitals] H
--	on H.hosnContactID = MAP.ProviderCID
--		and H.hosnContactCtg = MAP.ProviderCTG
--		and H.hosnCaseID = MAP.casnCaseID
--		and h.source_id = 'user_tab2_data.tab_id = ' + CONVERT(VARCHAR, UD.tab_id)



--join VanceLawFirm_Needles..user_tab2_name utn
--	on utn.tab_id = ud.tab_id
--		and utn.case_id = ud.case_id
--		and utn.[user_name] <> 0
--join VanceLawFirm_Needles..user_tab2_matter utm
--	on utn.ref_num = utm.ref_num
--		and utm.mattercode = c.matcode
--		and utm.field_title = 'Staff Making Request'
-- join IndvOrgContacts_Indexed ioc
--	 on ioc.saga = utn.[user_name]



--join VanceLawFirm_Needles..user_tab2_name utn2
--	on utn.tab_id = ud.tab_id
--		and utn.case_id = ud.case_id
--		and utn.[user_name] <> 0
--join VanceLawFirm_Needles..user_tab2_matter utm2
--	on utn.ref_num = utm.ref_num
--		and utm.mattercode = c.matcode
--		and utm.field_title = 'Ordered By'
--join IndvOrgContacts_Indexed ioc2
--	 on ioc.saga = utn2.[user_name]

go



---
alter table [sma_TRN_Hospitals] enable trigger all
go

alter table [sma_trn_MedicalProviderRequest] enable trigger all
go
---