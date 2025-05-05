/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create individual contacts and users

--------------------------------------------------------------------------------------------------------------------------------------
Step				Object						Action			Source							Notes
--------------------------------------------------------------------------------------------------------------------------------------
[1.0]				sma_MST_NoteTypes			insert			litify_pm__lit_note__c
[2.1]				sma_TRN_Notes				schema			--								saga
[2.2]				sma_TRN_Notes				insert			litify_pm__lit_note__c

##########################################################################################################################
*/

use ShinerSA
go

/*
alter table [sma_TRN_Notes] disable trigger all
delete from [sma_TRN_Notes] 
DBCC CHECKIDENT ('[sma_TRN_Notes]', RESEED, 0);
alter table [sma_TRN_Notes] enable trigger all
*/


------------------------
-- [1.0] NoteTypes
------------------------
insert into [sma_MST_NoteTypes]
	(
	nttsDscrptn,
	nttsNoteText
	)
	select distinct
		ISNULL(litify_pm__lit_Topic__c, 'Other') as nttsdscrptn,
		ISNULL(litify_pm__lit_Topic__c, 'Other') as nttsnotetext
	from ShinerLitify..litify_pm__lit_note__c
	except
	select
		nttsdscrptn,
		nttsnotetext
	from [sma_MST_NoteTypes]
go

------------------------
-- [2.0] Notes
------------------------

-- [2.1] Saga
if not exists (
		select
			*
		from sys.tables t
		join sys.columns c
			on t.object_id = c.object_id
		where t.name = 'sma_trn_notes'
			and c.name = 'saga_char'
	)
begin
	alter table sma_trn_notes
	add saga_char VARCHAR(100)
end
go

-- [2.2] Notes
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
	[saga_char]
	)
	select
		casnCaseID									as [notncaseid],
		(
			select
				MIN(nttnNoteTypeID)
			from [sma_MST_NoteTypes]
			where nttsDscrptn = ISNULL(n.litify_pm__lit_Topic__c, 'Other')
		)											as [notnnotetypeid]
		--,ISNULL('Action Date: ' + NULLIF(CONVERT(VARCHAR(MAX), n.action_Date__c), '') + CHAR(13), '') +
		,
		ISNULL(NULLIF(CONVERT(VARCHAR(MAX), n.litify_pm__lit_Note__c), '') + CHAR(13), '') +
		''											as [notmdescription],
		dbo.udf_StripHTML(n.litify_pm__lit_Note__c) as [notmplaintext],
		0											as [notncontactctgid],
		null										as [notncontactid],
		null										as [notspriority],
		null										as [notnformid],
		(
			select
				usrnUserID
			from sma_mst_users
			where saga_char = n.CreatedById
		)											as [notnrecuserid],
		n.CreatedDate								as notddtcreated,
		(
			select
				usrnUserID
			from sma_mst_users
			where saga_char = n.LastModifiedById
		)											as [notnmodifyuserid],
		n.LastModifiedDate							as notddtmodified,
		null										as [notnlevelno],
		null										as [notddtinserted],
		null										as [workplanitemid],
		n.[name]									as [notnsubject],
		n.Id										as [saga_char]
	--select * 
	from [ShinerLitify]..[litify_pm__lit_note__c] n
	join [sma_TRN_Cases] c
		on c.saga_char = n.litify_pm__lit_Matter__c
	--where c.casnCaseID = 2549
	--LEFT JOIN [sma_TRN_Notes] ns
	--	ON ns.saga = n.Id
	--WHERE ns.notnNoteID IS NULL
	--AND ISNULL(CONVERT(VARCHAR(MAX), litify_pm__lit_Note__c), '') <> ''
	where ISNULL(CONVERT(VARCHAR(MAX), litify_pm__lit_Note__c), '') <> ''
go

---
alter table [sma_TRN_Notes] enable trigger all
go
---

