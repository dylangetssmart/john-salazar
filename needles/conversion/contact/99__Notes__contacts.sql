/*---
group: load
order: 70
description: Update contact types for attorneys
---*/

use [JohnSalazar_SA]
go

alter table [sma_TRN_Notes] disable trigger all
go

insert into sma_TRN_Notes
	(
	notnCaseID, notnNoteTypeID, notmDescription, notmPlainText, notnContactCtgID, notnContactId, notsPriority, notnFormID, notnRecUserID, notdDtCreated, notnModifyUserID, notdDtModified, saga, [source_id], [source_db], [source_ref]

	)
	select
		0				 as notnCaseID,
		(
			select
				nttnNoteTypeID
			from sma_MST_NoteTypes
			where nttsCode = 'CONTACT'
		)				 as notnNoteTypeID,
		case
			when ISNULL(date_of_majority, '') = ''
				then 'Date of Majority : N/A'
			else 'Date of Majority : ' + CONVERT(VARCHAR, date_of_majority)
		end				 as notmDescription,

		case
			when ISNULL(date_of_majority, '') = ''
				then 'Date of Majority : N/A'
			else 'Date of Majority : ' + CONVERT(VARCHAR, date_of_majority)
		end				 as notmPlainText,
		I.cinnContactCtg as notnContactCtgID,
		I.cinnContactID	 as notnContactId,
		'Normal'		 as notsPriority,
		0				 as notnFormID,
		368				 as notnRecUserID,
		GETDATE()		 as notdDtCreated,
		null			 as notnModifyUserID,
		null			 as notdDtModified,
		p.party_id		 as saga,
		null			 as [source_id],
		'needles'		 as [source_db],
		'party'			 as [source_ref]
	from [JohnSalazar_Needles].[dbo].[party] P
	join sma_MST_IndvContacts I
		on I.saga = P.party_id

----(2)----
insert into sma_TRN_Notes
	(
	notnCaseID, notnNoteTypeID, notmDescription, notmPlainText, notnContactCtgID, notnContactId, notsPriority, notnFormID, notnRecUserID, notdDtCreated, notnModifyUserID, notdDtModified, saga, [source_id], [source_db], [source_ref]
	)
	select
		0				 as notnCaseID,
		(
			select
				nttnNoteTypeID
			from sma_MST_NoteTypes
			where nttsCode = 'CONTACT'
		)				 as notnNoteTypeID,
		case
			when ISNULL(minor, '') = ''
				then 'Minor : N'
			else 'Minor : ' + CONVERT(VARCHAR, minor)
		end				 as notmDescription,
		case
			when ISNULL(minor, '') = ''
				then 'Minor : N'
			else 'Minor : ' + CONVERT(VARCHAR, minor)
		end				 as notmPlainText,
		I.cinnContactCtg as notnContactCtgID,
		I.cinnContactID	 as notnContactId,
		'Normal'		 as notsPriority,
		0				 as notnFormID,
		368				 as notnRecUserID,
		GETDATE()		 as notdDtCreated,
		null			 as notnModifyUserID,
		null			 as notdDtModified,
		p.party_id		 as saga,
		null			 as [source_id],
		'needles'		 as [source_db],
		'party'			 as [source_ref]
	from [JohnSalazar_Needles].[dbo].[party] P
	join sma_MST_IndvContacts I
		on I.saga = P.party_id


---(3)--- 
insert into sma_TRN_Notes
	(
	notnCaseID, notnNoteTypeID, notmDescription, notmPlainText, notnContactCtgID, notnContactId, notsPriority, notnFormID, notnRecUserID, notdDtCreated, notnModifyUserID, notdDtModified, saga, [source_id], [source_db], [source_ref]
	)
	select
		0				 as notnCaseID,
		(
			select
				nttnNoteTypeID
			from sma_MST_NoteTypes
			where nttsCode = 'CONTACT'
		)				 as notnNoteTypeID,
		PN.note			 as notmDescription,
		PN.note			 as notmPlainText,
		IOC.CTG			 as notnContactCtgID,
		IOC.CID			 as notnContactId,
		'Normal'		 as notsPriority,
		0				 as notnFormID,
		368				 as notnRecUserID,
		GETDATE()		 as notdDtCreated,
		null			 as notnModifyUserID,
		null			 as notdDtModified,
		pn.note_key		 as saga,
		null			 as [source_id],
		'needles'		 as [source_db],
		'provider_notes' as [source_ref]
	from [JohnSalazar_Needles].[dbo].[provider_notes] PN
	join IndvOrgContacts_Indexed IOC
		on IOC.SAGA = PN.name_id

---
alter table [sma_TRN_Notes] enable trigger all
go
---



