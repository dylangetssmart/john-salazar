/* ######################################################################################
description: Create note records from needles..value_notes

steps:
	- create note types from distinct instances of value_notes.topic
	- insert trn_notes

dependencies:
	- sma_TRN_Cases
	- sma_MST_users

notes:
	- value_notes appears to contain comments about specific value transactions using key value_num
	- value transactions may be mapped to disbursements, lien tracking, etc
	- each of those locations may or may not have a comment/description field large enough to hold the data from value_notes
	- therefore it is cleaner & easier to import these as TRN_Notes instead
	- but it technically should be possible/feasible to use value_notes to update a comment or description field for the associated value transaction

#########################################################################################
*/

use [SA]
go

-- Create note types that don't yet exist
insert into [sma_MST_NoteTypes]
	(
	nttsDscrptn, nttsNoteText
	)
	select distinct
		vn.topic,
		vn.topic
	from Needles..value_notes vn
	except
	select
		nttsDscrptn,
		nttsNoteText
	from [sma_MST_NoteTypes]


---
alter table [sma_TRN_Notes] disable trigger all
go

---
--SELECT nttsDscrptn, count(*)
--FROM [sma_MST_NoteTypes]
--group by nttsDscrptn
--having count(*) > 1

----(1)----
insert into [sma_TRN_Notes]
	(
	[notnCaseID], [notnNoteTypeID], [notmDescription], [notmPlainText], [notnContactCtgID], [notnContactId], [notsPriority], [notnFormID], [notnRecUserID], [notdDtCreated], [notnModifyUserID], [notdDtModified], [notnLevelNo], [notdDtInserted], [WorkPlanItemId], [notnSubject], [saga], [source_id], [source_db], [source_ref]

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
	from Needles.[dbo].[value_notes] n
	join Needles.[dbo].[value_Indexed] v
		on v.value_id = n.value_num
	join [sma_TRN_Cases] c
		on c.cassCaseNumber = v.case_id
	join [sma_MST_Users] u
		on u.source_id = n.staff_id
go

---
alter table [sma_TRN_Notes] enable trigger all
go

-----------------------------------------
--INSERT RELATED TO FIELD FOR NOTES
-----------------------------------------
insert into sma_TRN_NoteContacts
	(
	NoteID, UniqueContactID
	)
	select distinct
		note.notnNoteID,
		ioc.UNQCID
	--select v.provider, ioc.*, n.note, note.*
	from Needles..[value_notes] n
	join Needles..value_Indexed v
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