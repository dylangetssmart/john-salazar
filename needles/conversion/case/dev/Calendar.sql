/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create users and contacts

replace:
'OfficeName'
'StateDescription'
'VenderCaseType'
##########################################################################################################################
*/

use [KurtYoung_SA]
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
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and object_id = OBJECT_ID(N'sma_TRN_CalendarAppointments')
	)
begin
	alter table [sma_TRN_CalendarAppointments] add [saga] [VARCHAR](100) null;
end
go

----(0)----
if exists (
		select
			*
		from sys.objects
		where name = 'CalendarJudgeStaffCourt'
			and type = 'U'
	)
begin
	drop table CalendarJudgeStaffCourt
end
go

-- Construct table
select
	cal.calendar_id as calendarid,
	cas.casnCaseID  as caseid,
	0				as judge_contact,
	0				as staff_contact,
	0				as court_contact,
	0				as court_address,
	0				as party_contact
into CalendarJudgeStaffCourt
from KurtYoung_Needles.[dbo].[calendar] cal
join [sma_TRN_Cases] cas
	on cas.cassCaseNumber = cal.casenum
where ISNULL(cal.casenum, 0) <> 0

-- Update Judge_Contact with cinnContactID from [sma_MST_IndvContacts]
-- calendar.judge_link = on [sma_MST_IndvContacts].saga
update CalendarJudgeStaffCourt
set Judge_Contact = I.cinnContactID
from KurtYoung_Needles.[dbo].[calendar] cal
join [sma_TRN_Cases] cas
	on cas.cassCaseNumber = cal.casenum
join [sma_MST_IndvContacts] i
	on i.saga = cal.judge_link
	and cal.judge_link <> 0
where cal.calendar_id = CalendarId

-- Set Staff_Contact [sma_MST_IndvContacts].cinnContactID
-- calendar.staff_id = [sma_MST_IndvContacts].cinsGrade
update CalendarJudgeStaffCourt
set Staff_Contact = J.cinnContactID
from KurtYoung_Needles.[dbo].[calendar] cal
join [sma_TRN_Cases] cas
	on cas.cassCaseNumber = cal.casenum
join [sma_MST_IndvContacts] j
	on j.source_id = cal.staff_id
	and ISNULL(cal.staff_id, '') <> ''
where cal.calendar_id = CalendarId

-- Set Court_Contact to [sma_MST_OrgContacts].connContactID 
-- Set Court_Address to [sma_MST_Address].addnAddressID
update CalendarJudgeStaffCourt
set Court_Contact = O.connContactID,
	Court_Address = A.addnAddressID
from KurtYoung_Needles.[dbo].[calendar] cal
join [sma_TRN_Cases] cas
	on cas.cassCaseNumber = cal.casenum
join [sma_MST_OrgContacts] o
	on o.saga = cal.court_link
join [sma_MST_Address] a
	on a.addnContactID = o.connContactID
	and a.addnContactCtgID = o.connContactCtg
	and a.addbPrimary = 1
where cal.calendar_id = CalendarId

-- Set Party_Contact to [sma_MST_IndvContacts].cinnContactID
update CalendarJudgeStaffCourt
set Party_Contact = J.cinnContactID
from KurtYoung_Needles.[dbo].[calendar] cal
join [sma_TRN_Cases] cas
	on cas.cassCaseNumber = cal.casenum
join [sma_MST_IndvContacts] j
	on j.saga = cal.party_id
where cal.calendar_id = CalendarId


---(0)---
insert into [sma_MST_ActivityType]
	(
	attsDscrptn,
	attnActivityCtg
	)
	select
		a.activitytype,
		(
			select
				atcnPKId
			from sma_MST_ActivityCategory
			where atcsDscrptn = 'Case-Related Appointment'
		)
	from (
		select distinct
			appointment_type as activitytype
		from KurtYoung_Needles.[dbo].[calendar] cal
		where ISNULL(appointment_type, '') <> ''
		except
		select
			attsDscrptn as activitytype
		from sma_MST_ActivityType
		where attnActivityCtg = (
				select
					atcnPKId
				from sma_MST_ActivityCategory
				where atcsDscrptn = 'Case-Related Appointment'
			)
			and ISNULL(attsDscrptn, '') <> ''
	) a
go


alter table [sma_TRN_CalendarAppointments] disable trigger all

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
	[subject],
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
	[saga]
	)
	select
		case
			when cal.[start_date] between '1900-01-01' and '2079-06-06' and
				CONVERT(TIME, ISNULL(cal.[start_time], '00:00:00')) <> CONVERT(TIME, '00:00:00')
				then CAST(CAST(cal.[start_date] as DATETIME) + CAST(cal.[start_time] as DATETIME) as DATETIME)
			--then cast(cal.[start_date] as datetime)
			when cal.[start_date] between '1900-01-01' and '2079-06-06' and
				CONVERT(TIME, ISNULL(cal.[start_time], '00:00:00')) = CONVERT(TIME, '00:00:00')
				then CAST(CAST(cal.[start_date] as DATETIME) + CAST('00:00:00' as DATETIME) as DATETIME)
			else '1900-01-01'
		end													as [fromdate],
		case
			when cal.[stop_date] between '1900-01-01' and '2079-06-06' and
				CONVERT(TIME, ISNULL(cal.[stop_time], '00:00:00')) <> CONVERT(TIME, '00:00:00')
				then CAST(CAST(cal.[stop_date] as DATETIME) + CAST(cal.[stop_time] as DATETIME) as DATETIME)
			--then cast(cal.[stop_date] as datetime)
			when cal.[stop_date] between '1900-01-01' and '2079-06-06' and
				CONVERT(TIME, ISNULL(cal.[stop_time], '00:00:00')) = CONVERT(TIME, '00:00:00')
				then CAST(CAST(cal.[stop_date] as DATETIME) + CAST('00:00:00' as DATETIME) as DATETIME)
			else '1900-01-01'
		end													as [todate],
		(
			select
				ID
			from [sma_MST_CalendarAppointmentType]
			where AppointmentType = 'Case-related'
		)													as [appointmenttypeid],
		case
			when ISNULL(cal.appointment_type, '') <> ''
				then (
						select
							attnActivityTypeID
						from sma_MST_ActivityType
						where attnActivityCtg = (
								select
									atcnPKId
								from sma_MST_ActivityCategory
								where atcsDscrptn = 'Case-Related Appointment'
							)
							and attsDscrptn = cal.appointment_type
					)
			else (
					select
						attnActivityTypeID
					from [sma_MST_ActivityType]
					where attnActivityCtg = (
							select
								atcnPKId
							from sma_MST_ActivityCategory
							where atcsDscrptn = 'Case-Related Appointment'
						)
						and attsDscrptn = 'Appointment'
				)
		end													as [activitytypeid],
		cas.casnCaseID										as [caseid],
		map.Court_Contact									as [locationcontactid],
		2													as [locationcontactgtgid],
		map.Judge_Contact									as [judgeid],
		ISNULL('party name : ' + NULLIF(cal.[party_name], '') + CHAR(13), '') +
		ISNULL('short notes : ' + NULLIF(cal.[short_notes], '') + CHAR(13), '') +
		''													as [comments],
		case
			when cal.status = 'Canceled'
				then (
						select
							[statusid]
						from [sma_MST_AppointmentStatus]
						where [StatusName] = 'Canceled'
					)
			when cal.status = 'Done'
				then (
						select
							[statusid]
						from [sma_MST_AppointmentStatus]
						where [StatusName] = 'Completed'
					)
			when cal.status = 'No Show'
				then (
						select
							[statusid]
						from [sma_MST_AppointmentStatus]
						where [StatusName] = 'Open'
					)
			when cal.status = 'Open'
				then (
						select
							[statusid]
						from [sma_MST_AppointmentStatus]
						where [StatusName] = 'Open'
					)
			when cal.status = 'Postponed'
				then (
						select
							[statusid]
						from [sma_MST_AppointmentStatus]
						where [StatusName] = 'Adjourned'
					)
			when cal.status = 'Rescheduled'
				then (
						select
							[statusid]
						from [sma_MST_AppointmentStatus]
						where [StatusName] = 'Adjourned'
					)
			else (
					select
						[statusid]
					from [sma_MST_AppointmentStatus]
					where [StatusName] = 'Open'
				)
		end													as [statusid],
		null												as [address],
		LEFT(cal.[subject], 120)							as [subject],
		null,
		null,
		368													as [recuserid],
		cal.[date_created]									as [dtcreated],
		null												as [modifyuserid],
		null												as [dtmodified],
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		'Case-related:' + CONVERT(VARCHAR, cal.calendar_id) as [saga]
	from KurtYoung_Needles.[dbo].[calendar] cal
	join [sma_TRN_Cases] cas
		on cas.cassCaseNumber = cal.casenum
	join CalendarJudgeStaffCourt map
		on map.CalendarId = cal.calendar_id
	where ISNULL(cal.casenum, 0) <> 0
go

alter table [sma_TRN_CalendarAppointments] enable trigger all

----(2)-----
insert into [sma_trn_AppointmentStaff]
	(
	[AppointmentId],
	[StaffContactId]
	)
	select
		app.AppointmentID,
		map.Staff_Contact
	from [sma_TRN_CalendarAppointments] app
	join KurtYoung_Needles.[dbo].[calendar] cal
		on app.saga = 'Case-related:' + CONVERT(VARCHAR, cal.calendar_id)
	join CalendarJudgeStaffCourt map
		on map.CalendarId = cal.calendar_id


/*
----(3)-----
insert into [KurtYoung_SA].[dbo].[sma_trn_AppointmentStaff] ( [AppointmentId] ,[StaffContactId] ) 
select APP.AppointmentID, MAP.Party_Contact
from [KurtYoung_SA].[dbo].[sma_TRN_CalendarAppointments] APP
inner join KurtYoung_Needles.[dbo].[calendar] CAL on APP.saga='Case-related:'+convert(varchar,CAL.calendar_id)
inner join CalendarJudgeStaffCourt MAP on MAP.CalendarId=CAL.calendar_id
*/
