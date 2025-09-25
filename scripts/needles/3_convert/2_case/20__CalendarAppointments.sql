/*---
description: Insert [sma_TRN_CalendarAppointments] from [calendar]
steps:
    - 
    - 
usage_instructions:
    - 
dependencies:
    - 
    - 
notes: >
---*/

use JohnSalazar_SA
go

---
alter table [sma_TRN_CalendarAppointments] disable trigger all
go
exec AddBreadcrumbsToTable 'sma_TRN_CalendarAppointments'
go
---

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
from [JohnSalazar_Needles].[dbo].[calendar] cal
join [sma_TRN_Cases] cas
	on cas.cassCaseNumber = cal.casenum
where
	ISNULL(cal.casenum, 0) <> 0

-- Update Judge_Contact with cinnContactID from [sma_MST_IndvContacts]
-- calendar.judge_link = on [sma_MST_IndvContacts].saga
update CalendarJudgeStaffCourt
set Judge_Contact = I.cinnContactID
from [JohnSalazar_Needles].[dbo].[calendar] cal
join [sma_TRN_Cases] cas
	on cas.saga = cal.casenum
join [sma_MST_IndvContacts] i
	on i.saga = cal.judge_link
	and cal.judge_link <> 0
where cal.calendar_id = CalendarId

-- Set Staff_Contact [sma_MST_IndvContacts].cinnContactID
-- calendar.staff_id = [sma_MST_IndvContacts].cinsGrade
update CalendarJudgeStaffCourt
set Staff_Contact = smu.usrnContactID
from [JohnSalazar_Needles].[dbo].[calendar] cal
--join [sma_TRN_Cases] cas
--	on cas.cassCaseNumber = cal.casenum
join sma_MST_Users smu
	on smu.source_id = cal.staff_id
--join [sma_MST_IndvContacts] j
--	on j.source_id = cal.staff_id
--	and ISNULL(cal.staff_id, '') <> ''
where cal.calendar_id = CalendarId

-- Set Court_Contact to [sma_MST_OrgContacts].connContactID 
-- Set Court_Address to [sma_MST_Address].addnAddressID
update CalendarJudgeStaffCourt
set Court_Contact = O.connContactID,
	Court_Address = A.addnAddressID
from [JohnSalazar_Needles].[dbo].[calendar] cal
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
from [JohnSalazar_Needles].[dbo].[calendar] cal
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
	 from [JohnSalazar_Needles].[dbo].[calendar] cal
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
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		case
			when cal.[start_date] between '1900-01-01' and '2079-06-06' and
				CONVERT(TIME, ISNULL(cal.[start_time], '00:00:00')) <> CONVERT(TIME, '00:00:00') then CAST(CAST(cal.[start_date] as DATETIME) + CAST(cal.[start_time] as DATETIME) as DATETIME)
			--then cast(cal.[start_date] as datetime)
			when cal.[start_date] between '1900-01-01' and '2079-06-06' and
				CONVERT(TIME, ISNULL(cal.[start_time], '00:00:00')) = CONVERT(TIME, '00:00:00') then CAST(CAST(cal.[start_date] as DATETIME) + CAST('00:00:00' as DATETIME) as DATETIME)
			else '1900-01-01'
		end													as [fromdate],
		case
			when cal.[stop_date] between '1900-01-01' and '2079-06-06' and
				CONVERT(TIME, ISNULL(cal.[stop_time], '00:00:00')) <> CONVERT(TIME, '00:00:00') then CAST(CAST(cal.[stop_date] as DATETIME) + CAST(cal.[stop_time] as DATETIME) as DATETIME)
			--then cast(cal.[stop_date] as datetime)
			when cal.[stop_date] between '1900-01-01' and '2079-06-06' and
				CONVERT(TIME, ISNULL(cal.[stop_time], '00:00:00')) = CONVERT(TIME, '00:00:00') then CAST(CAST(cal.[stop_date] as DATETIME) + CAST('00:00:00' as DATETIME) as DATETIME)
			else '1900-01-01'
		end													as [todate],
		(
		 select
			 ID
		 from [sma_MST_CalendarAppointmentType]
		 where AppointmentType = 'Case-related'
		)													as [appointmenttypeid],
		case
			when ISNULL(cal.appointment_type, '') <> '' then (
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
			when cal.status = 'Canceled' then (
					 select
						 [statusid]
					 from [sma_MST_AppointmentStatus]
					 where [StatusName] = 'Canceled'
					)
			when cal.status = 'Done' then (
					 select
						 [statusid]
					 from [sma_MST_AppointmentStatus]
					 where [StatusName] = 'Completed'
					)
			when cal.status = 'No Show' then (
					 select
						 [statusid]
					 from [sma_MST_AppointmentStatus]
					 where [StatusName] = 'Open'
					)
			when cal.status = 'Open' then (
					 select
						 [statusid]
					 from [sma_MST_AppointmentStatus]
					 where [StatusName] = 'Open'
					)
			when cal.status = 'Postponed' then (
					 select
						 [statusid]
					 from [sma_MST_AppointmentStatus]
					 where [StatusName] = 'Adjourned'
					)
			when cal.status = 'Rescheduled' then (
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
		null												as [saga],
		'Case-related:' + CONVERT(VARCHAR, cal.calendar_id) as [source_id],
		null												as [source_db],
		null												as [source_ref]
	--select *
	from [JohnSalazar_Needles].[dbo].[calendar] cal
	join [sma_TRN_Cases] cas
		on cas.cassCaseNumber = cal.casenum
	join CalendarJudgeStaffCourt map
		on map.CalendarId = cal.calendar_id
	where
		ISNULL(cal.casenum, 0) <> 0
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
	join [JohnSalazar_Needles].[dbo].[calendar] cal
		on app.source_id = 'Case-related:' + CONVERT(VARCHAR, cal.calendar_id)
	join CalendarJudgeStaffCourt map
		on map.CalendarId = cal.calendar_id


/*
----(3)-----
insert into [JohnSalazar_SA].[dbo].[sma_trn_AppointmentStaff] ( [AppointmentId] ,[StaffContactId] ) 
select APP.AppointmentID, MAP.Party_Contact
from [JohnSalazar_SA].[dbo].[sma_TRN_CalendarAppointments] APP
inner join [JohnSalazar_Needles].[dbo].[calendar] CAL on APP.saga='Case-related:'+convert(varchar,CAL.calendar_id)
inner join CalendarJudgeStaffCourt MAP on MAP.CalendarId=CAL.calendar_id
*/
