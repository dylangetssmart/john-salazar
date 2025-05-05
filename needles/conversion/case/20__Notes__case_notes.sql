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

use [JohnSalazar_SA]
go

/*
alter table [sma_TRN_Notes] disable trigger all
delete from [sma_TRN_Notes] 
DBCC CHECKIDENT ('[sma_TRN_Notes]', RESEED, 0);
alter table [sma_TRN_Notes] enable trigger all
*/

/* ------------------------------------------------------------------------------
[sma_TRN_Notes] Schema
*/

-- saga
if not exists (
		select
			*
		from sys.tables t
		join sys.columns c
			on t.object_id = c.object_id
		where t.name = 'Sma_trn_notes'
			and c.name = 'saga'
	)
begin
	alter table sma_trn_notes
	add SAGA INT
end

go

if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and object_id = OBJECT_ID(N'sma_TRN_Notes')
	)
begin
	alter table [sma_TRN_Notes]
	add [saga] INT null;
end


-- source_id
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and object_id = OBJECT_ID(N'sma_TRN_Notes')
	)
begin
	alter table [sma_TRN_Notes] add [source_id] VARCHAR(MAX) null;
end

go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and object_id = OBJECT_ID(N'sma_TRN_Notes')
	)
begin
	alter table [sma_TRN_Notes] add [source_db] VARCHAR(MAX) null;
end

go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and object_id = OBJECT_ID(N'sma_TRN_Notes')
	)
begin
	alter table [sma_TRN_Notes] add [source_ref] VARCHAR(MAX) null;
end

go


/* ------------------------------------------------------------------------------
Create Note Types
*/
insert into [sma_MST_NoteTypes]
	(
		nttsDscrptn,
		nttsNoteText
	)
	select distinct
		topic as nttsdscrptn,
		topic as nttsnotetext
	from [JohnSalazar_Needles].[dbo].[case_notes_Indexed]
	except
	select
		nttsdscrptn,
		nttsnotetext
	from [sma_MST_NoteTypes]
go

/* ------------------------------------------------------------------------------
Insert Notes
*/
alter table [sma_TRN_Notes] disable trigger all
go

insert into [sma_TRN_Notes]
	(
		[notnCaseID],
		[notnNoteTypeID],
		[notmDescription],
		[notmPlainText],
		[notnContactCtgID],
		[notnContactId],
		[notsPriority],
		[notnFormID],
		[notnRecUserID],
		[notdDtCreated],
		[notnModifyUserID],
		[notdDtModified],
		[notnLevelNo],
		[notdDtInserted],
		[WorkPlanItemId],
		[notnSubject],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		casnCaseID						as [notncaseid],
		(
			select
				MIN(nttnNoteTypeID)
			from [sma_MST_NoteTypes]
			where nttsDscrptn = n.topic
		)								as [notnnotetypeid],
		note							as [notmdescription],
		REPLACE(note, CHAR(10), '<br>') as [notmplaintext],
		0								as [notncontactctgid],
		null							as [notncontactid],
		null							as [notspriority],
		null							as [notnformid],
		u.usrnUserID					as [notnrecuserid],
		case
			when n.note_date between '1900-01-01' and '2079-06-06' and
				CONVERT(TIME, ISNULL(n.note_time, '00:00:00')) <> CONVERT(TIME, '00:00:00')
				then CAST(CAST(n.note_date as DATETIME) + CAST(n.note_time as DATETIME) as DATETIME)
			when n.note_date between '1900-01-01' and '2079-06-06' and
				CONVERT(TIME, ISNULL(n.note_time, '00:00:00')) = CONVERT(TIME, '00:00:00')
				then CAST(CAST(n.note_date as DATETIME) + CAST('00:00:00' as DATETIME) as DATETIME)
			else '1900-01-01'
		end								as notddtcreated,
		null							as [notnmodifyuserid],
		null							as notddtmodified,
		null							as [notnlevelno],
		null							as [notddtinserted],
		null							as [workplanitemid],
		null							as [notnsubject],
		note_key						as saga,
		null							as [source_id],
		'needles'						as [source_db],
		'case_notes_indexed'			as [source_ref]
	from [JohnSalazar_Needles].[dbo].[case_notes_Indexed] n
	join [sma_TRN_Cases] c
		on c.cassCaseNumber = CONVERT(VARCHAR, n.case_num)
	left join [sma_MST_Users] u
		on u.source_id = n.staff_id
	left join [sma_TRN_Notes] ns
		on ns.saga = note_key
	where
		ns.notnNoteID is null
go

---
alter table [sma_TRN_Notes] enable trigger all
go