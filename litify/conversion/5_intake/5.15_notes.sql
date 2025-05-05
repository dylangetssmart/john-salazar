use ShinerSA
go

----------------------------------
--INTAKE NOTE
----------------------------------
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
		saga_char
	)
	select
		casnCaseID												   as [notnCaseID],
		(
			select
				MIN(nttnNoteTypeID)
			from [sma_MST_NoteTypes]
			where nttsDscrptn = 'Intake'
		)														   as [notnNoteTypeID],
		ISNULL('Start Date: ' + NULLIF(CONVERT(VARCHAR(MAX), n.litify_pm__Questionnaire_Start_Date__c), '') + CHAR(13), '') +
		ISNULL('End Date: ' + NULLIF(CONVERT(VARCHAR(MAX), n.litify_pm__Questionnaire_End_Date__c), '') + CHAR(13), '') +
		ISNULL('Last Modified Date: ' + NULLIF(CONVERT(VARCHAR(MAX), n.litify_pm__Questionnaire_Last_Modified__c), '') + CHAR(13), '') +
		''														   as [notmDescription],
		CONVERT(VARCHAR(MAX), litify_pm__Questions_and_answers__c) as [notmPlainText],
		0														   as [notnContactCtgID],
		null													   as [notnContactId],
		null													   as [notsPriority],
		null													   as [notnFormID],
		(
			select
				usrnUserID
			from sma_mst_users
			where saga_char = n.CreatedById
		)														   as [notnRecUserID],
		n.CreatedDate											   as notdDtCreated,
		(
			select
				usrnUserID
			from sma_mst_users
			where saga_char = n.LastModifiedById
		)														   as [notnModifyUserID],
		n.LastModifiedDate										   as notdDtModified,
		null													   as [notnLevelNo],
		null													   as [notdDtInserted],
		null													   as [WorkPlanItemId],
		n.[name]												   as [notnSubject],
		n.id													   as saga_char
	--select *
	from [ShinerLitify]..[litify_pm__intake__c] N
	join [sma_TRN_Cases] C
		on C.saga_char = n.id
	where
		ISNULL(litify_pm__Questionnaire_Start_Date__c, '') <> ''
		or ISNULL(litify_pm__Questionnaire_End_Date__c, '') <> ''
		or ISNULL(CONVERT(VARCHAR(MAX), litify_pm__Questions_and_answers__c), '') <> ''