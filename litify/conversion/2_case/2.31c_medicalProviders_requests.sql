use ShinerSA
go

--select
--	*
--from ShinerLitify..litify_pm__Damage__c
--where
--	Id = 'a0jnt000001qq9ziaw'
---- matter = a0LNt00000B4BoWMAV
---- provider = a0VNt000004BHEXMA4
--select
--	name
--from ShinerLitify..litify_pm__Matter__c lpmc
--where
--	id = 'a0LNt00000B4BoWMAV'

--select
--	*
--from ShinerLitify..litify_docs__File_Info__c
--select distinct
--	litify_docs__Related_To_Api_Name__c
--from ShinerLitify..litify_docs__File_Info__c


--select
--	*
--from ShinerLitify..litify_docs__File_Info__c
--where
--	litify_docs__Related_To_Api_Name__c = 'litify_pm__Damage__c'
--	and Matter__c = 'a0LNt00000B4BoWMAV'
--	and name like '%7.29.24 - BR%'


----exec [utility].[FindStringValue] 'a0VNt000004BHEXMA4', null, 1, 1,0
--/*
--FindString			databasename	schemaname	tablename				columnname				datatype_name
--a0VNt000004BHEXMA4	ShinerLitify	dbo			EntityHistory			ParentId				varchar			
--a0VNt000004BHEXMA4	ShinerLitify	dbo			litify_pm__Damage__c	litify_pm__Provider__c	varchar	
--a0VNt000004BHEXMA4	ShinerLitify	dbo			litify_pm__Role__c		Id						varchar	
--*/

--select
--	*
--from ShinerLitify..litify_pm__Role__c
--where
--	Id = 'a0VNt000004BHEXMA4'

--/*
--damage.provider > role.id
--litify_docs__File_Info__c has data I need. links to matter
--litify_docs__Folder_Path__c.["Requests"]
--link to damage: [litify_docs__Related_To__c].[a0jNt000001QQ9ZIAW]


--need:
--	MedPrvCaseID,
--	MedPrvPlaintiffID,
--	MedPrvhosnHospitalID,
--*/

--select
--	*
--from sma_TRN_Hospitals sth

--select
--	h.hosnCaseID	  as MedPrvCaseID,
--	h.hosnPlaintiffID as MedPrvPlaintiffID,
--	h.hosnHospitalID  as MedPrvhosnHospitalID,
--	file_info.CreatedDate,
--	file_info.CreatedById,
--	file_info.*
--from ShinerLitify..litify_pm__Damage__c d
--join sma_TRN_Cases cas
--	on cas.saga_char = d.litify_pm__Matter__c
---- h.saga_char is damage.id
--join [sma_TRN_Hospitals] h
--	on h.hosnCaseID = cas.casnCaseID
--		and h.saga_char = d.Id
---- file info
--join ShinerLitify..litify_docs__File_Info__c file_info
--	on file_info.litify_docs__Related_To__c = d.Id
----join ShinerLitify..litify_pm__Role__c role
----on d.provider
--where
--	file_info.litify_docs__Folder_Path__c = '["Requests"]'
--	and d.Id = 'a0jnt000001qq9ziaw'


--------------------------------------------------------------------------
-- schema
--------------------------------------------------------------------------

-- saga
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and object_id = OBJECT_ID(N'sma_TRN_MedicalProviderRequest')
	)
begin
	alter table [sma_TRN_MedicalProviderRequest] add [saga] VARCHAR(MAX) null;
end

go

-- saga_char
-- this should be source_id, but many scripts already use `saga_char`
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_TRN_MedicalProviderRequest')
	)
begin
	alter table [sma_TRN_MedicalProviderRequest] add [saga_char] VARCHAR(MAX) null;
end

go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and object_id = OBJECT_ID(N'sma_TRN_MedicalProviderRequest')
	)
begin
	alter table [sma_TRN_MedicalProviderRequest] add [source_db] VARCHAR(MAX) null;
end

go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and object_id = OBJECT_ID(N'sma_TRN_MedicalProviderRequest')
	)
begin
	alter table [sma_TRN_MedicalProviderRequest] add [source_ref] VARCHAR(MAX) null;
end

go

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
		SAGA,
		saga_char,
		source_db,
		source_ref
	)
	select
		hosnCaseID			   as MedPrvCaseID,
		hosnPlaintiffID		   as MedPrvPlaintiffID,
		H.hosnHospitalID	   as MedPrvhosnHospitalID,
		(
			select
				uId
			from sma_MST_Request_RecordTypes
			where RecordType = 'Hospital Records'
		)					   as MedPrvRecordType,
		case
			when (file_info.CreatedDate between '1900-01-01' and '2079-06-06')
				then file_info.CreatedDate
			else null
		end					   as MedPrvRequestdate,
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga_char = file_info.CreatedById
		)					   as MedPrvAssignee,
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga_char = file_info.CreatedById
		)					   as MedPrvAssignedBy,
		0					   as MedPrvHighPriority,		--1=high priority; 0=Normal
		--case
		--	when litify_pm__Record_Start_Date__c between '1900-01-01' and '2079-06-06'
		--		then litify_pm__Record_Start_Date__c
		--	else null
		--end				 as MedPrvFromDate,
		null				   as MedPrvFromDate,
		--case
		--	when litify_pm__Record_End_Date__c between '1900-01-01' and '2079-06-06'
		--		then litify_pm__Record_End_Date__c
		--	else null
		--end				 as MedPrvToDate,
		null				   as MedPrvToDate,
		ISNULL('File Name: ' + NULLIF(CONVERT(VARCHAR(MAX), file_info.Name), '') + CHAR(13), '') +
		ISNULL('Source: ' + NULLIF(CONVERT(VARCHAR(MAX), file_info.litify_docs__Source__c), '') + CHAR(13), '') +
		''					   as MedPrvComments,
		--ISNULL('Bill Satus: ' + NULLIF(CONVERT(VARCHAR(MAX), req.Medical_records_Bills_Status__c), '') + CHAR(13), '') +
		--ISNULL('Affidavit for Record: ' + NULLIF(CONVERT(VARCHAR(MAX), req.Affidavit_for_Record__c), '') + CHAR(13), '') +
		--ISNULL('Affidavit for Billing: ' + NULLIF(CONVERT(VARCHAR(MAX), req.Affidavit_for_Billing__c), '') + CHAR(13), '') +
		--ISNULL('Name: ' + NULLIF(CONVERT(VARCHAR(MAX), req.[Name]), '') + CHAR(13), '') +
		''					   as MedPrvNotes,
		--case
		--	when (req.litify_pm__Date_Received__c between '1900-01-01' and '2079-06-06')
		--		then req.litify_pm__Date_Received__c
		--	else null
		--end					   as MedPrvCompleteDate,
		null				   as MedPrvCompleteDate,
		(
			select
				uId
			from [sma_MST_RequestStatus]
			where [Status] = 'Internal Waiting'
		)					   as MedPrvStatusId,
		null				   as MedPrvFollowUpDate,
		--case
		--	when (litify_pm__Date_Received__c between '1900-01-01' and '2079-06-06')
		--		then (
		--				select
		--					uId
		--				from [sma_MST_RequestStatus]
		--				where [Status] = 'Received'
		--			)
		--	else null
		--end					   as MedPrvStatusDate,
		null				   as MedPrvStatusDate,
		null				   as OrderAffidavit,	--bit
		''					   as FollowUpNotes,	--Retreival Provider Notes
		null				   as SAGA,
		d.id				   as saga_char,
		'litify'			   as source_db,
		'litify_pm__Damage__c' as source_ref
	--select ioc.*
	--	select
	--h.hosnCaseID as MedPrvCaseID,
	--h.hosnPlaintiffID as 	MedPrvPlaintiffID,
	--h.hosnHospitalID as	MedPrvhosnHospitalID,
	--file_info.CreatedDate,
	--file_info.CreatedById,
	--file_info.*
	from ShinerLitify..litify_pm__Damage__c d
	join sma_TRN_Cases cas
		on cas.saga_char = d.litify_pm__Matter__c
	-- h.saga_char is damage.id
	join [sma_TRN_Hospitals] h
		on h.hosnCaseID = cas.casnCaseID
			and h.saga_char = d.Id
	-- file info
	join ShinerLitify..litify_docs__File_Info__c file_info
		on file_info.litify_docs__Related_To__c = d.Id
	--join ShinerLitify..litify_pm__Role__c role
	--on d.provider
	where
		file_info.litify_docs__Folder_Path__c = '["Requests"]'
--and d.Id = 'a0jnt000001qq9ziaw'


--from ShinerLitify..[litify_pm__Request__c] req
--join sma_TRN_Cases cas
--	on cas.Litify_saga = req.litify_pm__Matter__c
--join [sma_TRN_Hospitals] H
--	on H.hosnCaseID = cas.casnCaseID
--		and h.saga = req.litify_pm__Facility__c
--where
--	litify_pm__Request_Type__c not in ('Property Damage Photos', 'Police Report', 'ESI Estimate Report')
go