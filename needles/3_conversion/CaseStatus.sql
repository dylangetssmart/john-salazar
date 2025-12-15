/*---
group: load
order: 6
description: Update contact types for attorneys
---*/

/* ######################################################################################
description: Create case statues from needles..class

steps:
	- create case status types
	- create case statuses
	- update statuses on cases

usage_instructions:

dependencies:
	- 2.02_std_Cases.sql

notes:

#########################################################################################
*/

use [SA]
go

/*
alter table [sma_TRN_CaseStatus] disable trigger all
delete from [sma_TRN_CaseStatus]
DBCC CHECKIDENT ('[sma_TRN_CaseStatus]', RESEED, 0);
alter table [sma_TRN_CaseStatus] enable trigger all
*/

/* ----------------------------------------------------------------------------------------------------
Create case status types - [sma_MST_CaseStatusType]
*/
with distinctdescriptions
as
(
	/* Retrieves distinct descriptions from Needles.dbo.class, 
       joining with the Needles.dbo.cases table to filter the classes associated with cases. */
	select distinct
		[description] as [name]
	from [Needles].[dbo].[class]
	join [Needles].[dbo].[cases] C
		on C.class = classcode

	/* Adds a hardcoded status description 'Conversion Case No Status' to the list of distinct descriptions. */
	union
	select
		'Conversion Case No Status'
),
excludeddescriptions
as
(
	/* Excludes any descriptions that already exist in the sma_MST_CaseStatus table 
       with a status type ID corresponding to 'Status'. */
	select
		csssDescription as [name]
	from sma_MST_CaseStatus
	where cssnStatusTypeID = (
			select
				stpnStatusTypeID
			from sma_MST_CaseStatusType
			where stpsStatusType = 'Status'
		)
),
newdescriptions
as
(
	/* Selects descriptions from DistinctDescriptions that are not in ExcludedDescriptions. */
	select
		[name]
	from distinctdescriptions
	except
	select
		[name]
	from excludeddescriptions
)
insert into sma_MST_CaseStatus
	(
	csssDescription,
	cssnStatusTypeID
	)
	select
		nd.[name],
		(
			/* Retrieves the status type ID corresponding to 'Status'. */
			select
				stpnStatusTypeID
			from sma_MST_CaseStatusType
			where stpsStatusType = 'Status'
		)
	from newdescriptions nd;
go

/* ----------------------------------------------------------------------------------------------------
Insert case statuses - [sma_TRN_CaseStatus]
*/
alter table [sma_TRN_CaseStatus] disable trigger all
go

insert into [sma_TRN_CaseStatus]
	(
	[cssnCaseID],
	[cssnStatusTypeID],
	[cssnStatusID],
	[cssnExpDays],
	[cssdFromDate],
	[cssdToDt],
	[csssComments],
	[cssnRecUserID],
	[cssdDtCreated],
	[cssnModifyUserID],
	[cssdDtModified],
	[cssnLevelNo],
	[cssnDelFlag]
	)
	select
		cas.casnCaseID,
		(
			select
				stpnStatusTypeID
			from sma_MST_CaseStatusType
			where stpsStatusType = 'Status'
		)		  as [cssnstatustypeid],
		case
			when c.close_date between '1900-01-01' and '2079-06-06'
				then (
						select
							cssnstatusid
						from sma_MST_CaseStatus
						where csssDescription = 'Closed Case'
					)
			when exists (
					select top 1
						*
					from sma_MST_CaseStatus
					where csssDescription = cl.[description]
				)
				then (
						select top 1
							cssnstatusid
						from sma_MST_CaseStatus
						where csssDescription = cl.[description]
					)
			else (
					select
						cssnstatusid
					from sma_MST_CaseStatus
					where csssDescription = 'Conversion Case No Status'
				)
		end		  as [cssnstatusid],
		''		  as [cssnexpdays],
		case
			when c.close_date between '1900-01-01' and '2079-06-06'
				then c.close_date
			else GETDATE()
		end		  as [cssdfromdate],
		null	  as [cssdtodt],
		case
			when c.close_date between '1900-01-01' and '2079-06-06'
				then 'Prior Status : ' + cl.[description]
			else ''
		end + CHAR(13) +
		''		  as [cssscomments],
		368,
		GETDATE() as [cssddtcreated],
		null,
		null,
		null,
		null
	from [sma_trn_cases] cas
	join [Needles].[dbo].[cases_Indexed] c
		on CONVERT(VARCHAR, c.casenum) = cas.cassCaseNumber
	left join [Needles].[dbo].[class] cl
		on c.class = cl.classcode
go

alter table [sma_TRN_CaseStatus] enable trigger all
go


/* ----------------------------------------------------------------------------------------------------
Update case statuses
*/
alter table [sma_trn_cases] disable trigger all
go

---------
update sma_trn_cases
set casnStatusValueID = STA.cssnStatusID
from sma_TRN_CaseStatus sta
where sta.cssnCaseID = casnCaseID
go

alter table [sma_trn_cases] enable trigger all
go


