use [SA]
go


/* ------------------------------------------------------------------------------
Insert Task Category
*/ ------------------------------------------------------------------------------

--select * from sma_MST_TaskCategory smtc

insert into [sma_MST_TaskCategory]
	(
		tskCtgDescription
	)

	select
		'Conversion'

	--union

	--select distinct
	--	description
	--from VanceLawFirm_Needles..case_checklist cc
	--join sma_TRN_Cases cas
	--	on cas.cassCaseNumber = CONVERT(VARCHAR, cc.case_id)

	except
	select
		tskCtgDescription
	from [sma_MST_TaskCategory]
go


/* ------------------------------------------------------------------------------
Insert Tasks
*/ ------------------------------------------------------------------------------
ALTER TABLE [sma_TRN_TaskNew] DISABLE TRIGGER ALL
GO

insert into [dbo].[sma_TRN_TaskNew]
	(
		[tskCaseID],
		[tskDueDate],
		[tskStartDate],
		[tskRequestorID],
		[tskAssigneeId],
		[tskReminderDays],
		[tskDescription],
		[tskCreatedDt],
		[tskCreatedUserID],
		[tskCompleted],
		[tskCompletedDt],
		[tskMasterID],
		[tskCtgID],
		[tskSummary],
		[tskModifiedDt],
		[tskModifyUserID],
		[tskPriority],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		cas.casncaseid							 as [tskCaseID],
		case
			when cc.due_date between '1900-01-01' and '2079-06-01'
				then TRY_CONVERT(SMALLDATETIME, cc.due_date)
			else null
		end										 as [tskDueDate],
		case
			when cc.date_of_modification between '1900-01-01' and '2079-06-01'
				then TRY_CONVERT(SMALLDATETIME, cc.date_of_modification)
			else null
		end										 as [tskStartDate],
		368										 as [tskRequestorID],
		--RequestorUserID
		--case
		--	when u.usrsLoginID is null
		--		then 368
		--	else u.usrnUserID
		--end										 as [tskAssigneeId],
		(
			select
				usrnUserID
			from sma_MST_Users
			where source_id = cc.staff_assigned
		)										 as [tskAssigneeId],
		null									 as [tskReminderDays],
		CONVERT(VARCHAR(MAX), cc.[description])	 as [tskDescription],
		case
			when cc.date_of_modification between '1900-01-01' and '2079-06-01'
				then TRY_CONVERT(SMALLDATETIME, cc.date_of_modification)
			else null
		end										 as [tskCreatedDt],
		368										 as [tskCreatedUserID],
		case
			when cc.[status] is not null and
				cc.[status] = 'Done'
				then (
						select
							statusID
						from TaskStatusTypes
						where StatusType = 'Completed'
					)
			else (
					select
						statusID
					from TaskStatusTypes
					where StatusType = 'Not Started'
				)
		end										 as [tskCompleted],
		null									 as [tskCompletedDt],
		null									 as [tskMasterID],
		(
			select
				tskCtgID
			from sma_MST_TaskCategory
			where tskCtgDescription = 'Conversion'
		)										 as [tskCtgID],
		CONVERT(VARCHAR(6000), cc.[Description]) as [tskSummary],
		case
			when cc.date_of_modification between '1900-01-01' and '2079-06-01'
				then TRY_CONVERT(SMALLDATETIME, cc.date_of_modification)
			else null
		end										 as [tskModifiedDt],
		(
			select
				usrnUserID
			from sma_MST_Users
			where source_id = cc.staff_modified
		)										 as [tskModifyUserID],
		3										 as [tskPriority],
		cc.checklist_id							 as [saga],
		null									 as [source_id],
		'needles'								 as [source_db],
		'case_checklist'						 as [source_ref]
	-- select * 
	from [Needles]..case_checklist cc
	join sma_trn_Cases cas
		on cas.cassCaseNumber = CONVERT(VARCHAR, cc.case_id)
go

ALTER TABLE [sma_TRN_TaskNew] ENABLE TRIGGER ALL
GO