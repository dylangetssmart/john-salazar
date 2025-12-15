/*---
priority: 1
sequence: 1
description: Create office record
data-source:
---*/

use [SA]
go

/*
alter table [sma_TRN_CriticalDeadlines] disable trigger all
delete [sma_TRN_CriticalDeadlines]
DBCC CHECKIDENT ('[sma_TRN_CriticalDeadlines]', RESEED, 0);
alter table [sma_TRN_CriticalDeadlines] enable trigger all


(select cdtnCriticalTypeID FROM [sma_MST_CriticalDeadlineTypes] where cdtbActive = 1 and cdtsDscrptn='date due') 
*/


/*
Function to strip white spaces surrounding case_dates
*/
if OBJECT_ID(N'dbo.GMACaseDate', N'FN') is not null
	drop function GMACaseDate;

go

create function dbo.GMACaseDate (@str VARCHAR(MAX))
returns VARCHAR(MAX)
as
begin
	--set @str=replace(@str,'1.','');
	--set @str=replace(@str,'2.','');
	--set @str=replace(@str,'3.','');
	--set @str=replace(@str,'4.','');
	--set @str=replace(@str,'5.','');
	--set @str=replace(@str,'6.','');
	--set @str=replace(@str,'7.','');
	--set @str=replace(@str,'8.','');
	--set @str=replace(@str,'9.','');
	return RTRIM(LTRIM(@str));
end;
go

/* CRITICAL DEADLINE TYPES ##################################
Insert new Critical Deadline Types that don't yet exist
from matter.case_date_1 through case_date_10
*/

-- Disable triggers

---

insert into [sma_MST_CriticalDeadlineTypes]
	(
		cdtsDscrptn,
		cdtbActive
	)
	(
	select distinct
		dbo.GMACaseDate(M.case_date_1),
		1
	from [Needles].[dbo].[matter] M
	where ISNULL(dbo.GMACaseDate(M.case_date_1), '') <> ''

	union

	select distinct
		dbo.GMACaseDate(M.case_date_2),
		1
	from [Needles].[dbo].[Matter] M
	where ISNULL(dbo.GMACaseDate(M.case_date_2), '') <> ''

	union

	select distinct
		dbo.GMACaseDate(M.case_date_3),
		1
	from [Needles].[dbo].[Matter] M
	where ISNULL(dbo.GMACaseDate(M.case_date_3), '') <> ''

	union

	select distinct
		dbo.GMACaseDate(M.case_date_4),
		1
	from [Needles].[dbo].[Matter] M
	where ISNULL(dbo.GMACaseDate(M.case_date_4), '') <> ''

	union

	select distinct
		dbo.GMACaseDate(M.case_date_5),
		1
	from [Needles].[dbo].[Matter] M
	where ISNULL(dbo.GMACaseDate(M.case_date_5), '') <> ''

	union

	select distinct
		dbo.GMACaseDate(M.case_date_6),
		1
	from [Needles].[dbo].[Matter] M
	where ISNULL(dbo.GMACaseDate(M.case_date_6), '') <> ''

	union

	select distinct
		dbo.GMACaseDate(M.case_date_7),
		1
	from [Needles].[dbo].[Matter] M
	where ISNULL(dbo.GMACaseDate(M.case_date_7), '') <> ''

	union

	select distinct
		dbo.GMACaseDate(M.case_date_8),
		1
	from [Needles].[dbo].[Matter] M
	where ISNULL(dbo.GMACaseDate(M.case_date_8), '') <> ''

	union

	select distinct
		dbo.GMACaseDate(M.case_date_9),
		1
	from [Needles].[dbo].[Matter] M
	where ISNULL(dbo.GMACaseDate(M.case_date_9), '') <> ''

	---- ds 6/20/2024 // for user_case_data.date_application_filed
	--union
	--select
	--	'Date Application Filed',
	--	1

	---- ds 7/11/2024 // for user_case_data.date_application_denied
	--union
	--select
	--	'Date Application Denied',
	--	1
	)

	except

	select
		cdtsDscrptn,
		cdtbActive
	from [sma_MST_CriticalDeadlineTypes]
	where
		cdtbActive = 1


/* ------------------------------------------------------------------------------
Helper table
*/ ------------------------------------------------------------------------------
if exists (
		select
			*
		from sys.objects
		where name = 'criticalDeadline_Helper'
			and type = 'U'
	)
begin
	drop table criticalDeadline_Helper
end

go

---
create table criticalDeadline_Helper (
	TableIndex		INT identity (1, 1) not null,
	casnCaseID		INT,
	UniqueContactId BIGINT
	constraint IOC_Clustered_Index_criticalDeadline_Helper primary key clustered (TableIndex)
) on [PRIMARY]
go

---
insert into criticalDeadline_Helper
	(
		casnCaseID,
		UniqueContactId
	)
	select
		plnnCaseID,
		UniqueContactId
	from sma_TRN_Plaintiff
	join sma_MST_AllContactInfo
		on ContactCtg = plnnContactCtg
			and ContactId = plnnContactID
	where
		plnbIsPrimary = 1
go

dbcc dbreindex ('criticalDeadline_Helper', ' ', 90) with no_infomsgs
go


alter table [sma_TRN_CriticalDeadlines] disable trigger all
go

/* ------------------------------------------------------------------------------
Insert Critical Deadlines
- Loop through case_date_1 to case_date_10
*/ ------------------------------------------------------------------------------

declare @i INT = 1
declare @sql NVARCHAR(MAX)
declare @caseDate NVARCHAR(20)

while @i <= 9
begin
set @caseDate = 'case_date_' + CAST(@i as NVARCHAR(2))

set @sql = '
    INSERT INTO [sma_TRN_CriticalDeadlines] (
        [crdnCaseID]
        ,[crdnCriticalDeadlineTypeID]
        ,[crddDueDate]
        ,[crdsRequestFrom]
        ,[ResponderUID]
    )
    SELECT 
        CAS.casnCaseID as [crdnCaseID]
        ,(
            SELECT cdtnCriticalTypeID
            FROM [sma_MST_CriticalDeadlineTypes]
            WHERE cdtbActive = 1
                AND cdtsDscrptn = dbo.GMACaseDate(M.' + @caseDate + ')
        ) as [crdnCriticalDeadlineTypeID]
        ,CASE 
            WHEN C.' + @caseDate + ' BETWEEN ''1900-01-01'' AND ''2079-06-01''
                THEN C.' + @caseDate + '
            ELSE NULL
        END as [crddDueDate]
        ,(
            SELECT CONVERT(VARCHAR, MAP.UniqueContactId) + '';''
            FROM criticalDeadline_Helper MAP
            WHERE MAP.casnCaseID = CAS.casnCaseID
        ) as [crdsRequestFrom]
        ,(
            SELECT CONVERT(VARCHAR, MAP.UniqueContactId)
            FROM criticalDeadline_Helper MAP
            WHERE MAP.casnCaseID = CAS.casnCaseID
        ) as [ResponderUID]
    FROM [Needles].[dbo].[cases] C
    JOIN [Needles].[dbo].[matter] M
        ON M.matcode = C.matcode
    JOIN [sma_TRN_cases] CAS
        ON CAS.cassCaseNumber = casenum
    WHERE ISNULL(C.' + @caseDate + ', '''') <> ''''
    '

exec sp_executesql @sql

set @i = @i + 1
end


---(Appendix)---
update [sma_TRN_CriticalDeadlines]
set crddCompliedDate = GETDATE()
where crddDueDate < GETDATE()
go

alter table sma_TRN_CriticalDeadlines enable trigger all
go


/* ------------------------------------------------------------------------------
Insert SOL
*/ ------------------------------------------------------------------------------

alter table [sma_TRN_SOLs] disable trigger all
go

insert into [sma_TRN_SOLs]
	(
		[solnCaseID],
		[solnSOLTypeID],
		[soldSOLDate],
		[soldDateComplied],
		[soldSnCFilingDate],
		[soldServiceDate],
		[solnDefendentID],
		[soldToProcessServerDt],
		[soldRcvdDate],
		[solsType]
	)
	select distinct
		d.defnCaseID	  as [solncaseid],
		null			  as [solnsoltypeid],
		case
			when (c.[lim_date] not between '1900-01-01' and '2079-12-31')
				then null
			else c.[lim_date]
		end				  as [soldsoldate],
		null			  as [solddatecomplied],
		null			  as [soldsncfilingdate],
		null			  as [soldservicedate],
		d.defnDefendentID as [solndefendentid],
		null			  as [soldtoprocessserverdt],
		null			  as [soldrcvddate],
		'D'				  as [solstype]
	from [Needles].[dbo].[cases_Indexed] c
	join [sma_TRN_Cases] cas
		on cas.cassCaseNumber = CONVERT(VARCHAR, c.casenum)
	join [sma_TRN_Defendants] d
		on d.defnCaseID = cas.casnCaseID
	where
		c.lim_date is not null
go

-----
alter table [sma_TRN_SOLs] enable trigger all
go

----(Appendix)----
update sma_MST_SOLDetails
set sldnFromIncident = 0
where sldnFromIncident is null
and sldnRecUserID = 368