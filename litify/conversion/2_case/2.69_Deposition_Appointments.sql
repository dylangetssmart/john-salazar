use ShinerSA
go

/* ---------------------------------------------------------------------------------------------------------------
Create Appointment
*/
alter table [sma_TRN_CalendarAppointments] disable trigger all
go

insert into [sma_TRN_CalendarAppointments]
	(
		[FromDate],
		[ToDate],
		[AppointmentTypeID],
		[ActivityTypeID],
		[CaseID],
		[LocationContactID],
		[LocationContactGtgID],
		[JudgeID],
		[Comments],
		[StatusID],
		[Address],
		[Subject],
		[ReminderTime],
		[RecurranceParentID],
		[AdjournedID],
		[RecUserID],
		[DtCreated],
		[ModifyUserID],
		[DtModified],
		[DepositionType],
		[Deponants],
		[OriginalAppointmentID],
		[OriginalAdjournedID],
		[RecurrenceId],
		[WorkPlanItemId],
		[AutoUpdateAppId],
		[AutoUpdated],
		[AutoUpdateProviderId],
		[AllDayEvent],
		[saga],
		[saga_char],
		[source_db],
		[source_ref]
	)
	select
		case
			when (dep.litify_ext__Deposition_Date_Only__c not between '1900-01-01' and '2079-12-31')
				then null
			else dep.litify_ext__Deposition_Date_Only__c
		end							  as [fromdate],
		case
			when (dep.litify_ext__Deposition_Date_Only__c not between '1900-01-01' and '2079-12-31')
				then null
			else dep.litify_ext__Deposition_Date_Only__c
		end							  as [todate],
		(
			select
				ID
			from [sma_MST_CalendarAppointmentType]
			where AppointmentType = 'Case-related'
		)							  as [appointmenttypeid],
		(
			select
				attnActivityTypeID
			from [sma_MST_ActivityType]
			where attnActivityCtg = (
					select
						atcnPKId
					from sma_MST_ActivityCategory
					where atcsDscrptn = 'Case-Related Appointment'
				)
				and attsDscrptn = 'Deposition – Other'
		)							  as [activitytypeid],
		cas.casnCaseID				  as [caseid],
		null						  as [locationcontactid],
		null						  as [locationcontactgtgid],
		null						  as [judgeid],
		ISNULL('Deposition Name: ' + NULLIF(CONVERT(VARCHAR(MAX), dep.Name), '') + CHAR(13), '') +
		''							  as [comments],
		(
			select
				[statusid]
			from [sma_MST_AppointmentStatus]
			where [StatusName] = 'Open'
		)							  as [statusid],
		null						  as [address],
		LEFT('Deposition-' + dep.Name, 120) as [subject],
		null						  as [remindertime],
		null,
		null,
		(
			select
				usrnUserID
			from sma_mst_users
			where saga_char = dep.CreatedById
		)							  as [recuserid],
		dep.CreatedDate				  as [dtcreated],
		(
			select
				usrnUserID
			from sma_mst_users
			where saga_char = dep.LastModifiedById
		)							  as [modifyuserid],
		dep.LastModifiedDate			  as [dtmodified],
		null						  as [DepositionType],
		null						  as [Deponants],
		null						  as [OriginalAppointmentID],
		null						  as [OriginalAdjournedID],
		null						  as [RecurrenceId],
		null						  as [WorkPlanItemId],
		null						  as [AutoUpdateAppId],
		null						  as [AutoUpdated],
		null						  as [AutoUpdateProviderId],
		1							  as [AllDayEvent],
		null						  as [saga],
		dep.Id						  as [saga_char],
		'litify'					  as [source_db],
		'litify_ext__Deposition__c'						  as [source_ref]
	--select * 
	from [ShinerLitify]..litify_ext__Deposition__c dep
	join [sma_TRN_Cases] cas
		on cas.saga_char = dep.litify_ext__Matter__c
	where
		ISNULL(dep.litify_ext__Deposition_Date_Only__c, '') <> ''
go

alter table [sma_TRN_CalendarAppointments] enable trigger all
go



/* ---------------------------------------------------------------------------------------------------------------
AppointmentStaff
*/
insert into [sma_trn_AppointmentStaff]
	(
		[AppointmentId],
		[StaffContactId],
		StaffContactCtg
	)
	select
		app.AppointmentID,
		u.usrnContactID,
		1
	from [sma_TRN_CalendarAppointments] app
	join ShinerLitify..litify_ext__Deposition__c dep
		on app.saga_char = dep.Id
	join sma_MST_Users u
		on u.saga_char = dep.litify_ext__Assigned_Attorney__c
	where
		ISNULL(dep.litify_ext__Deposition_Date_Only__c, '') <> ''

--join [ShinerLitify]..[event] cal
--	on app.saga_char = cal.id
--join sma_mst_users u
--	on u.saga_char = cal.OwnerId



/* ---------------------------------------------------------------------------------------------------------------
Update Motion with appointment
*/

alter table sma_TRN_Depositions disable trigger all
go

update dep
set dpsnAppointmentIDNew = cal.AppointmentID
from sma_TRN_Depositions dep
join sma_TRN_CalendarAppointments cal
	on cal.saga_char = dep.saga_char
	and dep.[source_ref] = 'litify_ext__Deposition__c'

alter table sma_TRN_Depositions enable trigger all
go