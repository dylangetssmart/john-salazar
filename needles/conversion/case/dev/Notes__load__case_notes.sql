use [JohnSalazar_SA]
go

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

----(0)----
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

---
alter table [sma_TRN_Notes] disable trigger all
go

---

----(1)----
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
	SAGA
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
		note_key						as saga
	from [JohnSalazar_Needles].[dbo].[case_notes_Indexed] n
	join [sma_TRN_Cases] c
		on c.cassCaseNumber = n.case_num
	left join [sma_MST_Users] u
		on u.source_id = n.staff_id
	left join [sma_TRN_Notes] ns
		on ns.saga = note_key
	where ns.notnNoteID is null
go


--alter table sma_trn_notes disable trigger all
--update  sma_trn_notes set notmPlainText=replace(notmPlainText,char(10),'<br>') where  notmPlainText like '%'+char(10)+'%'
--alter table sma_trn_notes enable trigger all

---
alter table [sma_TRN_Notes] enable trigger all
go
---

