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

exec dbo.BuildNeedlesUserTabStagingTable @SourceDatabase = 'JohnSalazar_Needles',
										 @TargetDatabase = 'JohnSalazar_SA',
										 @DataTableName	 = 'user_tab2_data',
										 @StagingTable	 = 'staging_medical_requests',
										 @ColumnList	 = '
Date_Received,
Date_Requested,
Name,
Date_Range,
FUp_Notes,
Fax,
Value_Code,
Latest_FollowUp,
Info_Type,
Staff_Rcvd,
Aff_Rcvd,
Billing_Company,
Collection_Company,
Billing_Exp,
Collection_Exp,
LOP_Sent,
Aff_filed_in_court,
LOP';
go
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
	union select 'Unspecified'
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
		'user_tab2_data.tab_id = ' + CONVERT(VARCHAR, smr.tabid) as [source_id],
		'needles'												 as [source_db],
		'user_tab2_data'										 as [source_ref]
	--select *
	from staging_medical_requests smr
	join sma_TRN_Cases cas
		on cas.saga = smr.caseid
	join IndvOrgContacts_Indexed ioci
		on ioci.saga = smr.Name_CID
	left join [sma_TRN_Hospitals] H
		on H.hosnCaseID = cas.casnCaseID
			and H.hosnContactID = ioci.CID
			and H.hosnContactCtg = ioci.CTG
			and H.hosnAddressID = ioci.AID
	where
		H.hosnHospitalID is null	--only add the hospital if it does not already exist
		and
		ISNULL(smr.Name_CID, '') <> ''

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
		hosnCaseID																			as MedPrvCaseID,
		hosnPlaintiffID																		as MedPrvPlaintiffID,
		H.hosnHospitalID																	as MedPrvhosnHospitalID,
		COALESCE(
			(select uId from sma_MST_Request_RecordTypes where RecordType = smr.Info_Type),
			(select uId from sma_MST_Request_RecordTypes where RecordType = 'Unspecified')
		)																					as MedPrvRecordType,
		dbo.ValidDate(smr.Date_Requested)													as MedPrvRequestdate,
		(select u.usrnUserID from sma_MST_Users u where u.source_id = smr.Staff_Rcvd)		as MedPrvAssignee,
		null																				as MedPrvAssignedBy,		-- Requested By
		0																					as MedPrvHighPriority,		-- 1=high priority; 0=Normal
		null																				as MedPrvFromDate,
		null																				as MedPrvToDate,
		CONCAT_WS(CHAR(13),
			CONCAT('FUp Notes: ', NULLIF(CONVERT(VARCHAR(MAX), smr.FUp_Notes), '')),
			CONCAT('Fax: ', NULLIF(CONVERT(VARCHAR(MAX), smr.Fax), '')),
			CONCAT('Aff Rcvd: ', NULLIF(CONVERT(VARCHAR(MAX), smr.Aff_Rcvd), '')),
			CONCAT('Aff filed in court: ', NULLIF(CONVERT(VARCHAR(MAX), smr.Aff_filed_in_court), '')),
			CONCAT('Date Range: ', NULLIF(CONVERT(VARCHAR(MAX), smr.Date_Range), ''))
		)																					as MedPrvComments,
		CONCAT_WS(CHAR(13),
			CONCAT('LOP: ', NULLIF(CONVERT(VARCHAR(MAX), smr.LOP), '')),
			CONCAT('LOP Sent: ', NULLIF(CONVERT(VARCHAR(MAX), smr.LOP_Sent), ''))
		)																					as MedPrvNotes,
		null																				as MedPrvCompleteDate,
		case
			when isnull(smr.Date_Received,'') <> ''then
				(
					select
						uId
					from [sma_MST_RequestStatus]
					where [Status] = 'Received'
				)
			else null
		end																					as MedPrvStatusId,
		dbo.ValidDate(smr.Latest_FollowUp)													as MedPrvFollowUpDate,
		dbo.ValidDate(smr.Date_Received)													as MedPrvStatusDate,
		0																					as OrderAffidavit,
		null																				as FollowUpNotes,	--Retreival Provider Notes
		null																				as [saga],
		'user_tab2_data.tab_id = ' + CONVERT(VARCHAR, smr.tabid)							as [source_id],
		'needles'																			as [source_db],
		'user_tab2_data'																	as [source_ref]
	--select *
	from staging_medical_requests smr
	join sma_TRN_Cases cas
		on cas.saga = smr.caseid
	join IndvOrgContacts_Indexed ioci
		on ioci.saga = smr.Name_CID
	left join [sma_TRN_Hospitals] H
		on H.hosnCaseID = cas.casnCaseID
			and H.hosnContactID = ioci.CID
			and H.hosnContactCtg = ioci.CTG
			and H.hosnAddressID = ioci.AID
			and h.source_id = 'user_tab2_data.tab_id = ' + CONVERT(VARCHAR, smr.tabid)
	where smr.Value_Code = 'MEDICAL'

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