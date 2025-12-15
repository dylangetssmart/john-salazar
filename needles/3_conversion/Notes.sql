use [SA]
go

/* ------------------------------------------------------------------------------
Create Note Types
*/
insert into [sma_MST_NoteTypes]
	(
		nttsDscrptn,
		nttsNoteText
	)
	-- from [case_notes].[topic]
	select distinct
		topic as nttsdscrptn,
		topic as nttsnotetext
	from [Needles].[dbo].[case_notes_Indexed]
	union all
	-- from [value_notes].[topic]
	select distinct
		vn.topic,
		vn.topic
	from [Needles]..value_notes vn
	except
	select
		nttsDscrptn,
		nttsNoteText
	from [sma_MST_NoteTypes]
go

/* ------------------------------------------------------------------------------
Insert Notes 
*/
alter table [sma_TRN_Notes] disable trigger all
go

-- from [case_notes_indexed]
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
	from [Needles].[dbo].[case_notes_Indexed] n
	join [sma_TRN_Cases] c
		on c.cassCaseNumber = CONVERT(VARCHAR, n.case_num)
	left join [sma_MST_Users] u
		on u.source_id = n.staff_id
	left join [sma_TRN_Notes] ns
		on ns.saga = note_key
	where
		ns.notnNoteID is null
go

-------------------------------------------------
-- from [value_notes]
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
		casnCaseID	  as [notncaseid],
		(
			select top 1
				nttnNoteTypeID
			from [sma_MST_NoteTypes]
			where nttsDscrptn = n.topic
		)			  as [notnnotetypeid],
		note		  as [notmdescription],
		note		  as [notmplaintext],
		0			  as [notncontactctgid],
		null		  as [notncontactid],
		null		  as [notspriority],
		null		  as [notnformid],
		u.usrnUserID  as [notnrecuserid],
		case
			when n.note_date between '1900-01-01' and '2079-06-06' and
				CONVERT(TIME, ISNULL(n.note_time, '00:00:00')) <> CONVERT(TIME, '00:00:00')
				then CAST(CAST(n.note_date as DATE) as DATETIME) + CAST(CAST(n.note_time as TIME) as DATETIME)
			else null
		end			  as notddtcreated,
		null		  as [notnmodifyuserid],
		null		  as notddtmodified,
		null		  as [notnlevelno],
		null		  as [notddtinserted],
		null		  as [workplanitemid],
		null		  as [notnsubject],
		n.note_key	  as [saga],
		null		  as [source_id],
		'needles'	  as [source_db],
		'value_notes' as [source_ref]
	from [Needles].[dbo].[value_notes] n
	join [Needles].[dbo].[value_Indexed] v
		on v.value_id = n.value_num
	join [sma_TRN_Cases] c
		on c.cassCaseNumber = CONVERT(VARCHAR, v.case_id)
	join [sma_MST_Users] u
		on u.source_id = n.staff_id
go

---
alter table [sma_TRN_Notes] enable trigger all
go

/* ------------------------------------------------------------------------------
Insert "Related To"
*/ ------------------------------------------------------------------------------
insert into sma_TRN_NoteContacts
	(
		NoteID,
		UniqueContactID
	)
	select distinct
		note.notnNoteID,
		ioc.UNQCID
	--select v.provider, ioc.*, n.note, note.*
	from [Needles]..[value_notes] n
	join [Needles]..value_Indexed v
		on v.value_id = n.value_num
	join sma_trn_Cases cas
		on cas.cassCaseNumber = v.case_id
	join IndvOrgContacts_Indexed ioc
		on ioc.saga = v.[provider]
	join [sma_TRN_Notes] note
		on note.saga = n.note_key
			and note.[notnNoteTypeID] = (
				select top 1
					nttnNoteTypeID
				from [sma_MST_NoteTypes]
				where nttsDscrptn = n.topic
			)