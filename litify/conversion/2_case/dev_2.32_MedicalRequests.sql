/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-23
Description: Create attorneys


1.0 - Medical Providers > [sma_TRN_Hospitals]
1.1 - Medical Bills > [sma_TRN_SpDamages]

2.0 - Request Types > [sma_MST_Request_RecordTypes]
2.1 - Request Status > [sma_MST_RequestStatus]
2.2 - Medical Requests > [sma_trn_MedicalProviderRequest]


--------------------------------------------------------------------------------------------------------------------------------------
Step								Object								Action			Source				
--------------------------------------------------------------------------------------------------------------------------------------
[1] Attorney Types					sma_MST_AttorneyTypes				insert			litify_pm__Role__c

[2] Plaintiff Attorneys
	[2.1]							sma_TRN_PlaintiffAttorney			insert			litify_pm__Originating_Attorney__c, litify_pm__Principal_Attorney__c
	[2.2]							sma_TRN_PlaintiffAttorney			insert			litify_pm__Role__c

[3] Defense Attorneys	
	[3.0]							sma_TRN_LawFirms					insert			litify_pm__Role__c

[4] Attorney Lists
	[4.1] Plaintiff Attorneys		sma_TRN_LawFirmAttorneys			insert			sma_TRN_LawFirms
	[4.2] Defense Attorneys			sma_TRN_LawFirmAttorneys			insert			sma_TRN_PlaintiffAttorney
						
##########################################################################################################################
*/

use ShinerSA
go


/* ##############################################
[0.0] - Create temporary tables for mapping codes
- Temporary table to store applicable damage types
- Acts as as single patch point for updates
- Sample Usage:
	WHERE ISNULL(d.litify_pm__type__C, '') IN (SELECT code FROM #DamageTypes dt)
	WHERE litify_pm__role__c IN IN (SELECT code FROM #MedicalProviderRoles dt)
*/

-- [1.1] Request Type Mapping
if OBJECT_ID('tempdb..#RequestTypes') is not null
begin
	drop table #RequestTypes;
end;

create table #RequestTypes (
	code VARCHAR(25)
);

-- Values from mapping spreadsheet
insert into #RequestTypes
	(
	code
	)
values (
	   'Medical Records'
	   ),
	   (
'Medical Bills and Records'
),
	   (
'Medical Bills'
)


/*
alter table [sma_TRN_Hospitals] disable trigger all
delete [sma_TRN_Hospitals]
DBCC CHECKIDENT ('[sma_TRN_Hospitals]', RESEED, 0);
alter table [sma_TRN_Hospitals] enable trigger all


alter table [sma_trn_MedicalProviderRequest] disable trigger all
delete [sma_trn_MedicalProviderRequest]
DBCC CHECKIDENT ([sma_trn_MedicalProviderRequest]', RESEED, 0);
alter table [sma_trn_MedicalProviderRequest] enable trigger all
*/
/*
select ioc.name, ioc.saga, req.*
From ShinerLitify..[litify_pm__Request__c] req
LEFT JOIN ShinerLitify..[litify_pm__Role__c] ro on req.litify_pm__Facility__c = ro.Id
LEFT JOIN IndvOrgContacts_Indexed ioc on ioc.saga = ro.litify_pm__Party__c
WHERE isnull(litify_pm__Facility__c,'') = ''

select distinct litify_pm__Request_Type__c From ShinerLitify..[litify_pm__Request__c] req
*/

------------------------------------
--ADD SAGA TO MEDICAL REQUESTS TABLE
------------------------------------
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_trn_MedicalProviderRequest')
	)
begin
	alter table [sma_trn_MedicalProviderRequest]
	add [saga_char] [VARCHAR](100) null;
end

------------------------------------
--RECORD REQUEST TYPES
------------------------------------
insert into sma_MST_Request_RecordTypes
	(
	RecordType
	)
	(select distinct
		litify_pm__Request_Type__c
	from ShinerLitify..[litify_pm__Request__c]
	where litify_pm__Request_Type__c in (
			select
				code
			from #RequestTypes rt
		)
	--WHERE litify_pm__Request_Type__c IN ('Autopsy', 'Updated Medical Bills', 'Updated Medical Records', 'Medical Bills',
	--	'Physical Therapy', 'Medical', 'Prior Medical', 'Medical Records')
	)
	except
	select
		RecordType
	from sma_MST_Request_RecordTypes
go

--select distinct litify_pm__Request_Type__c From ShinerLitify..[litify_pm__Request__c]
------------------------------------
--REQUEST STATUS
------------------------------------
insert into sma_MST_RequestStatus
	(
	Status,
	Description
	)
	select
		'No Record Available',
		'No Record Available'
	except
	select
		Status,
		Description
	from sma_MST_RequestStatus
go


---
alter table [sma_TRN_Hospitals] disable trigger all
go

alter table [sma_trn_MedicalProviderRequest] disable trigger all
go

--------------------------------------------------------------------------
---------------------------- MEDICAL PROVIDERS ---------------------------
--------------------------------------------------------------------------

--HOSPITALS FROM REQUEST TABLE
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
	[saga_char]
	)
	select distinct
		casnCaseID			   as [hosncaseid],
		ioc.CID				   as [hosncontactid],
		ioc.CTG				   as [hosncontactctg],
		ioc.AID				   as [hosnaddressid],
		'M'					   as [hossmedprotype],			--M or P (P for Prior Medical Provider)
		null				   as [hosdstartdt],
		null				   as [hosdenddt],
		(
			select top 1
				plnnPlaintiffID
			from [sma_TRN_Plaintiff]
			where plnnCaseID = casnCaseID
				and plnbIsPrimary = 1
		)					   as hosnplaintiffid,
		''					   as [hosncomments],
		null				   as [hosnhospitalchart],
		368					   as [hosnrecuserid],
		GETDATE()			   as [hosddtcreated],
		null				   as [hosnmodifyuserid],
		null				   as [hosddtmodified],
		litify_pm__Facility__c as [saga_char]
	--'tab2:'+convert(varchar,UD.tab_id)	as [saga]
	--select *
	from ShinerLitify..[litify_pm__Request__c] req
	--JOIN ShinerLitify..[litify_pm__pro] ro on req.Provider__c = ro.Id
	join IndvOrgContacts_Indexed ioc
		on ioc.saga_char = req.Medical_Provider__c
	join sma_TRN_Cases cas
		on cas.saga_char = req.litify_pm__Matter__c
	where ISNULL(Medical_Provider__c, '') <> ''
		and litify_pm__Request_Type__c in (
			select
				code
			from #RequestTypes rt
		)
go


----------------------------------------------------------------------
--INSERT UNIDENTIFIED MEDICAL PROVIDERS WHERE NO FACILITY ID EXISTS
----------------------------------------------------------------------
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
	[saga_char]
	)
	select distinct
		casnCaseID			   as [hosncaseid],
		ioc.CID				   as [hosncontactid],
		ioc.CTG				   as [hosncontactctg],
		ioc.AID				   as [hosnaddressid],
		'M'					   as [hossmedprotype],			--M or P (P for Prior Medical Provider)
		null				   as [hosdstartdt],
		null				   as [hosdenddt],
		(
			select top 1
				plnnPlaintiffID
			from [sma_TRN_Plaintiff]
			where plnnCaseID = casnCaseID
				and plnbIsPrimary = 1
		)					   as hosnplaintiffid,
		''					   as [hosncomments],
		null				   as [hosnhospitalchart],
		368					   as [hosnrecuserid],
		GETDATE()			   as [hosddtcreated],
		null				   as [hosnmodifyuserid],
		null				   as [hosddtmodified],
		litify_pm__Facility__c as [saga_char]
	--'tab2:'+convert(varchar,UD.tab_id)	as [saga]
	from ShinerLitify..[litify_pm__Request__c] req
	join IndvOrgContacts_Indexed ioc
		on ioc.Name = 'Unidentified Hospital'
	join sma_TRN_Cases cas
		on cas.saga_char = req.litify_pm__Matter__c
	where ISNULL(Medical_Provider__c, '') = ''
		and litify_pm__Request_Type__c in (
			select
				code
			from #RequestTypes rt
		)
--AND litify_pm__Request_Type__c IN ('Autopsy', 'Updated Medical Bills', 'Updated Medical Records', 'Medical Bills',
--'Physical Therapy', 'Billing', 'Medical', 'Prior Medical', 'Medical Records')

--------------------------------------------------------------------------
---------------------------- MEDICAL REQUESTS ----------------------------
--------------------------------------------------------------------------

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
	saga_char
	)
	select
		hosnCaseID		 as medprvcaseid,
		hosnPlaintiffID	 as medprvplaintiffid,
		h.hosnHospitalID as medprvhosnhospitalid,
		(
			select
				uId
			from sma_MST_Request_RecordTypes
			where RecordType = req.litify_pm__Request_Type__c
		)				 as medprvrecordtype,
		case
			when (req.litify_pm__Date_Requested__c between '1900-01-01' and '2079-06-06')
				then req.litify_pm__Date_Requested__c
			else null
		end				 as medprvrequestdate,
		null			 as medprvassignee,
		(
			select
				usrnUserID
			from sma_mst_users
			where saga_char = req.litify_pm__Requested_by__c
		)				 as medprvassignedby,
		0				 as medprvhighpriority,		--1=high priority; 0=Normal
		case
			when litify_pm__Record_Start_Date__c between '1900-01-01' and '2079-06-06'
				then litify_pm__Record_Start_Date__c
			else null
		end				 as medprvfromdate,
		case
			when litify_pm__Record_End_Date__c between '1900-01-01' and '2079-06-06'
				then litify_pm__Record_End_Date__c
			else null
		end				 as medprvtodate,
		ISNULL(NULLIF(CONVERT(VARCHAR(MAX), req.litify_pm__comments__c), '') + CHAR(13), '') +
		''				 as medprvcomments,
		ISNULL('Name: ' + NULLIF(CONVERT(VARCHAR(MAX), req.[Name]), '') + CHAR(13), '') +
		''				 as medprvnotes,
		case
			when (req.litify_pm__Date_Received__c between '1900-01-01' and '2079-06-06')
				then req.litify_pm__Date_Received__c
			else null
		end				 as medprvcompletedate,
		case
			when (req.litify_pm__Date_Received__c between '1900-01-01' and '2079-06-06')
				then (
						select
							uId
						from [sma_MST_RequestStatus]
						where [status] = 'Received'
					)
			else null
		end				 as medprvstatusid,
		null			 as medprvfollowupdate,
		case
			when (litify_pm__Date_Received__c between '1900-01-01' and '2079-06-06')
				then (
						select
							uId
						from [sma_MST_RequestStatus]
						where [status] = 'Received'
					)
			else null
		end				 as medprvstatusdate,
		null			 as orderaffidavit,	--bit
		''				 as followupnotes,	--Retreival Provider Notes
		req.Id			 as saga_char
	--select *
	from ShinerLitify..[litify_pm__Request__c] req
	join sma_TRN_Cases cas
		on cas.saga_char = req.litify_pm__Matter__c
	join [sma_TRN_Hospitals] h
		on h.hosnCaseID = cas.casnCaseID
			and h.saga_char = req.litify_pm__Facility__c
	where litify_pm__Request_Type__c in (
			select
				code
			from #RequestTypes rt
		)
--WHERE litify_pm__Request_Type__c IN ('Autopsy', 'Updated Medical Bills', 'Updated Medical Records', 'Medical Bills',
--	'Physical Therapy', 'Medical', 'Prior Medical', 'Medical Records')
go


---
alter table [sma_trn_MedicalProviderRequest] enable trigger all
go

alter table [sma_TRN_Hospitals] enable trigger all
go
