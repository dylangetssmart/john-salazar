/* 
###########################################################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-24
Description: Create tasks

------------------------------------------------------------------------------------------------------------------------------
Step										Object								Note
------------------------------------------------------------------------------------------------------------------------------
1. Task Category helper						helper_Task_Category
2. Task Status Types						[TaskStatusTypes]					yes, this is a generic SA table despite the name
3. Tasks Categories							[sma_MST_TaskCategory]
4. Tasks									[sma_TRN_TaskNew]
###########################################################################################################################



*/

use ShinerSA
go

/*
######################################################################
Task Status
	- [TaskStatusTypes]
######################################################################
*/

insert into [TaskStatusTypes]
	(
		[StatusType],
		[Description],
		IsFinal
	)
	select distinct
		[Status],
		[Status],
		0
	from ShinerLitify..[Task] t
	where
		ISNULL([Status], '') <> ''
		and [Status] not in (
			select
				[StatusType]
			from [TaskStatusTypes]
		)

/*
######################################################################
Task Types
	- [sma_MST_TaskCategory]
######################################################################
*/
insert into [sma_MST_TaskCategory]
	(
		tskCtgDescription
	)
	select
		tskCtgDescription
	from (
		select distinct
			ISNULL(type, 'Unspecified') as tskctgdescription
		from ShinerLitify..Task
		where type <> 'Outbound Email'

		union all

		select
			'Unspecified'
	) as source
	except
	select
		tskCtgDescription
	from [sma_MST_TaskCategory];


/*
######################################################################
Insert Tasks
[sma_TRN_TaskNew]

Tasks assigned to Teams in Litify:
see 1.02a_users.sql

OwnerID					"Team" user
-------------------------------------------
00GNt000000vMbiMAE		MedicalRecords
005Nt000003ZtpVIAS		Settlements

*/
alter table [sma_TRN_TaskNew] disable trigger all
go

-- [4.1] Add saga_char
if not exists (
		select
			*
		from sys.COLUMNS
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_TRN_TaskNew')
	)
begin
	alter table [sma_TRN_TaskNew] add [saga_char] VARCHAR(100);
end

go

-- [4.3] Create tasks from [Task]
insert into [sma_TRN_TaskNew]
	(
		[tskCaseID],
		[tskDueDate],
		[tskStartDate],
		[tskCompletedDt],
		[tskRequestorID],
		[tskAssigneeId],
		[tskReminderDays],
		[tskDescription],
		[tskCreatedDt],
		[tskCreatedUserID],
		[tskModifiedDt],
		[tskModifyUserID],
		[tskMasterID],
		[tskCtgID],
		[tskSummary],
		[tskPriority],
		[tskCompleted],
		[saga_char]
	)
	select
		cas.casnCaseID						  as [tskcaseid],
		t.ActivityDate						  as [tskduedate],
		case
			when (CONVERT(DATETIME, t.ActivityDate) between '1900-01-01' and '2079-06-06')
				then CONVERT(DATETIME, t.ActivityDate)
			else null
		end									  as [tskstartdate],
		case
			when (CONVERT(DATETIME, t.CompletedDateTime) between '1900-01-01' and '2079-06-06')
				then CONVERT(DATETIME, t.CompletedDateTime)
			else null
		end									  as [tskcompleteddt],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga_char = CreatedById
		)									  as [tskrequestorid],
		/*
		Tasks assigned to Teams in Litify:
		see 1.02a_users.sql

		OwnerID					"Team" user
		-------------------------------------------
		00GNt000000vMbiMAE		MedicalRecords
		005Nt000003ZtpVIAS		Settlements
		*/
		case
			when t.OwnerId = '00GNt000000vMbiMAE'
				then (
						select
							usrnUserID
						from sma_MST_Users
						where usrsLoginID = 'Records'
					)
			--when t.OwnerId = '005Nt000003ZtpVIAS'
			--	then (
			--			select
			--				usrnUserID
			--			from sma_MST_Users
			--			where usrsLoginID = 'Settlements'
			--		)
			else (
					select
						usrnUserID
					from sma_MST_Users
					where saga_char = OwnerId
				)
		end									  as [tskassigneeid],
		null								  as [tskreminderdays],
		ISNULL(NULLIF(CONVERT(VARCHAR(MAX), t.[Description]), '') + CHAR(13), '') +
		''									  as [tskdescription],
		CONVERT(DATETIME, t.CreatedDate)	  as [tskcreateddt],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga_char = CreatedById
		)									  as tskcreateduserid,
		CONVERT(DATETIME, t.LastModifiedDate) as [tskmodifieddt],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga_char = LastModifiedById
		)									  as [tskmodifyuserid],
		(
			select
				tskmasterid
			from sma_mst_Task_Template
			where tskMasterDetails = 'Custom Task'
		)									  as [tskmasterid],
		(
			select
				tskctgid
			from sma_MST_TaskCategory
			where tskCtgDescription = ISNULL(t.[Type], 'Unspecified')
		)									  as [tskctgid],
		ISNULL(NULLIF(CONVERT(VARCHAR(MAX), t.[Subject]), '') + CHAR(13), '') +
		--ISNULL('Who: ' + NULLIF(CONVERT(VARCHAR(MAX), ioc.[Name]), '') + CHAR(13), '') +
		''									  as [tsksummary],  --task subject--
		(
			select
				uId
			from PriorityTypes
			where PriorityType = t.[Priority]
		)									  as [tskpriority],
		(
			select
				StatusID
			from [TaskStatusTypes]
			where StatusType = t.[Status]
		)									  as [tskcompleted],
		t.ID								  as [saga_char]
	--SELECT *
	from ShinerLitify..[Task] t
	join sma_TRN_Cases cas
		on cas.saga_char = t.WhatId
	left join IndvOrgContacts_Indexed ioc
		on ioc.saga_char = WhoId
	where
		ISNULL(t.[Type], 'Other') <> 'Outbound Email';  -- ds 2024-09-05 Shiner custom - Exclude "Outbound Email"

go

alter table [sma_TRN_TaskNew] enable trigger all
go

