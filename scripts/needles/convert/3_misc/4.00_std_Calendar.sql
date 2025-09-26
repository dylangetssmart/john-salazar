use [JohnSalazar_SA]
go

set quoted_identifier on;
/*
alter table [sma_TRN_CalendarAppointments] disable trigger all
delete from [sma_TRN_CalendarAppointments]
DBCC CHECKIDENT ('[sma_TRN_CalendarAppointments]', RESEED, 0);
alter table [sma_TRN_CalendarAppointments] disable trigger all

alter table [sma_trn_AppointmentStaff] disable trigger all
delete from [sma_trn_AppointmentStaff]
DBCC CHECKIDENT ('[sma_trn_AppointmentStaff]', RESEED, 0);
alter table [sma_trn_AppointmentStaff] disable trigger all
*/

---(0)---
insert into [sma_MST_ActivityType]
	(
		attsDscrptn,
		attnActivityCtg
	)
	select
		A.ActivityType,
		(
		 select
			 atcnPKId
		 from sma_MST_ActivityCategory
		 where atcsDscrptn = 'Non-Case Related Appointment'
		)
	from (
	 select distinct
		 appointment_type as ActivityType
	 from [JohnSalazar_Needles].[dbo].[calendar] CAL
	 where ISNULL(CAL.appointment_type, '') <> ''
		 and ISNULL(CAL.casenum, 0) = 0
	 except
	 select
		 attsDscrptn as ActivityType
	 from sma_MST_ActivityType
	 where attnActivityCtg = (
		  select
			  atcnPKId
		  from sma_MST_ActivityCategory
		  where atcsDscrptn = 'Non-Case Related Appointment'
		 )
		 and ISNULL(attsDscrptn, '') <> ''
	) A
go

---(0)---
if not exists (
	 select
		 *
	 from sys.COLUMNS
	 where Name = N'saga'
		 and Object_ID = OBJECT_ID(N'sma_TRN_CalendarAppointments')
	)
begin
	alter table [sma_TRN_CalendarAppointments] add [saga] [VARCHAR](100) null;
end

go


----(1)-----
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
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)

	select
		case -- FromDate
			when CAL.[start_date] between '1900-01-01' and '2079-06-06' and CONVERT(TIME, ISNULL(CAL.[start_time], '00:00:00')) <> CONVERT(TIME, '00:00:00') then CAST(CAST(CAL.[start_date] as DATETIME) + CAST(CAL.[start_time] as DATETIME) as DATETIME)
			when CAL.[start_date] between '1900-01-01' and '2079-06-06' and CONVERT(TIME, ISNULL(CAL.[start_time], '00:00:00')) = CONVERT(TIME, '00:00:00') then CAST(CAST(CAL.[start_date] as DATETIME) + CAST('00:00:00' as DATETIME) as DATETIME)
			else '1900-01-01'
		end												as [FromDate],
		case -- ToDate
			when CAL.[stop_date] between '1900-01-01' and '2079-06-06' and CONVERT(TIME, ISNULL(CAL.[stop_time], '00:00:00')) <> CONVERT(TIME, '00:00:00') then CAST(CAST(CAL.[stop_date] as DATETIME) + CAST(CAL.[stop_time] as DATETIME) as DATETIME)
			when CAL.[stop_date] between '1900-01-01' and '2079-06-06' and CONVERT(TIME, ISNULL(CAL.[stop_time], '00:00:00')) = CONVERT(TIME, '00:00:00') then CAST(CAST(CAL.[stop_date] as DATETIME) + CAST('00:00:00' as DATETIME) as DATETIME)
			else '1900-01-01'
		end												as [ToDate],
		(
		 select
			 ID
		 from [sma_MST_CalendarAppointmentType]
		 where AppointmentType = 'Non-Case related Office'
		)												as [AppointmentTypeID],
		case -- ActivityTypeID
			when ISNULL(CAL.appointment_type, '') <> '' then (
					 select
						 attnActivityTypeID
					 from sma_MST_ActivityType
					 where attnActivityCtg = (
						  select
							  atcnPKId
						  from sma_MST_ActivityCategory
						  where atcsDscrptn = 'Non-Case Related Appointment'
						 )
						 and attsDscrptn = CAL.appointment_type
					)
			else (
				 select
					 attnActivityTypeID
				 from [sma_MST_ActivityType]
				 where attnActivityCtg = (
					  select
						  atcnPKId
					  from sma_MST_ActivityCategory
					  where atcsDscrptn = 'Non-Case Related Appointment'
					 )
					 and attsDscrptn = 'Appointment'
				)
		end												as [ActivityTypeID],
		null											as [CaseID],
		null											as [LocationContactID],
		null											as [LocationContactGtgID],
		null											as [JudgeID],
		ISNULL('party name : ' + NULLIF(CAL.[party_name], '')
		+ CHAR(13), '')
		+ ISNULL('short notes : ' + NULLIF(CAL.[short_notes], '') + CHAR(13), '')
		+ ''											as [Comments],
		case  --StatusID
			when CAL.status = 'Canceled' then (
					 select
						 [StatusId]
					 from [sma_MST_AppointmentStatus]
					 where [StatusName] = 'Canceled'
					)
			when CAL.status = 'Done' then (
					 select
						 [StatusId]
					 from [sma_MST_AppointmentStatus]
					 where [StatusName] = 'Completed'
					)
			when CAL.status = 'No Show' then (
					 select
						 [StatusId]
					 from [sma_MST_AppointmentStatus]
					 where [StatusName] = 'Open'
					)
			when CAL.status = 'Open' then (
					 select
						 [StatusId]
					 from [sma_MST_AppointmentStatus]
					 where [StatusName] = 'Open'
					)
			when CAL.status = 'Postponed' then (
					 select
						 [StatusId]
					 from [sma_MST_AppointmentStatus]
					 where [StatusName] = 'Adjourned'
					)
			when CAL.status = 'Rescheduled' then (
					 select
						 [StatusId]
					 from [sma_MST_AppointmentStatus]
					 where [StatusName] = 'Adjourned'
					)
			else (
				 select
					 [StatusId]
				 from [sma_MST_AppointmentStatus]
				 where [StatusName] = 'Open'
				)
		end												as [StatusID],
		null											as [Address],
		LEFT(CAL.subject, 120)							as [Subject],
		null											as [RecurranceParentID],
		null											as [AdjournedID],
		368												as [RecUserID],
		GETDATE()										as [DtCreated],
		null											as [ModifyUserID],
		null											as [DtModified],
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null											as [saga],
		'Non-Case:' + CONVERT(VARCHAR, cal.calendar_id) as [source_id],
		'needles'										as [source_db],
		'calendar'										as [source_ref]

	from [JohnSalazar_Needles].[dbo].[calendar] CAL
	where
		ISNULL(CAL.casenum, 0) = 0

------(2)-----
insert into [sma_trn_AppointmentStaff]
	(
		[AppointmentId],
		[StaffContactId]
	)
	select
		APP.AppointmentID,
		I.cinnContactID
	from [sma_TRN_CalendarAppointments] APP
	join [JohnSalazar_Needles].[dbo].[calendar] CAL
		on APP.source_id = 'Non-Case:' + CONVERT(VARCHAR, CAL.calendar_id)
	join [sma_MST_IndvContacts] I
		on I.cinsGrade = CAL.staff_id
			and ISNULL(CAL.staff_id, '') <> '' 

