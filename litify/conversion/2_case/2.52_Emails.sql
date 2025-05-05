use ShinerSA
go

if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_trn_Emails')
	)
begin
	alter table [sma_TRN_Emails]
	add saga_char VARCHAR(100)
end

go

--ALTER TABLE [sma_TRN_Emails]
--ALTER COLUMN SAGA VARCHAR(100)
--GO

--ALTER TABLE sma_trn_emails
--ALTER COLUMN [emlsSubject] VARCHAR(1000)
--GO
--ALTER TABLE sma_trn_emails
--ALTER COLUMN [emlsOutLookUserEmailID] VARCHAR(4000)
--GO

--ALTER TABLE sma_trn_emails
--ALTER COLUMN [emlsCCAddresses] VARCHAR(MAX)
--GO

--ALTER TABLE sma_trn_emails
--ALTER COLUMN [emlsBCCAddresses] VARCHAR(MAX)
--GO

--sp_help sma_trn_emails
alter table sma_trn_emails disable trigger all
go

insert into [dbo].[sma_TRN_Emails]
	(
		[emlnCaseID],
		[emlnFrom],
		[emlsTableName],
		[emlsColumnName],
		[emlnRecordID],
		[emlsSubject],
		[emlsSentReceived],
		[emlsContents],
		[emlbAcknowledged],
		[emldDate],
		[emlsFromEmailID],
		[emlsOutLookUserEmailID],
		[emlnTemplateID],
		[emlnPriority],
		[emlnRecUserID],
		[emldDtCreated],
		[emlnModifyUserID],
		[emldDtModified],
		[emlnLevelNo],
		[emlnReviewerContactId],
		[emlnReviewDate],
		[emlnDocumentAnalysisResultId],
		[emlnIsReviewed],
		[emlnToContactID],
		[emlnToContactCtgID],
		[emlnDocPriority],
		[emlnDocumentID],
		[emlnDeleteFlag],
		[emlsCCAddresses],
		[emlsBCCAddresses],
		[saga_char]
	)
	select
		casnCaseID				  as [emlncaseid],
		(
			select
				usrnUserID
			from sma_mst_users
			where saga_char = a.CreatedById
		)						  as [emlnfrom],
		''						  as [emlstablename],
		''						  as [emlscolumnname],
		0						  as [emlnrecordid],
		LEFT([subject], 200)	  as [emlssubject],	--nvarchar 400
		case
			when [incoming] = '1'
				then 'R'
			else 'S'
		end						  as [emlssentreceived],
		CONVERT(TEXT, [TextBody]) as [emlscontents],
		null					  as [emlbacknowledged],
		case
			when ISDATE(LEFT(MessageDate, 15)) = 1 and
				messagedate between '1/1/1900' and '6/6/2079'
				then MessageDate
			else null
		end						  as [emlddate],
		case
			when LEN(FromAddress) < 100
				then [FromAddress]
			else null
		end						  as [emlsfromemailid],	--100
		case
			when LEN([ToAddress]) < 4000
				then [ToAddress]
			else null
		end						  as [emlsoutlookuseremailid],	--4000
		0						  as [emlntemplateid],
		0						  as [emlnpriority],
		(
			select
				usrnUserID
			from sma_mst_users
			where saga_char = a.CreatedById
		)						  as [emlnrecuserid],
		case
			when ISDATE(CreatedDate) = 1 and
				CreatedDate between '1/1/1900' and '6/6/2079'
				then CreatedDate
			else null
		end						  as [emlddtcreated],
		(
			select
				usrnUserID
			from sma_mst_users
			where saga_char = a.LastModifiedById
		)						  as [emlnmodifyuserid],
		case
			when ISDATE(LastModifiedDate) = 1 and
				LastModifiedDate between '1/1/1900' and '6/6/2079'
				then LastModifiedDate
			else null
		end						  as [emlddtmodified],
		null					  as [emlnlevelno],
		null					  as [emlnreviewercontactid],
		null					  as [emlnreviewdate],
		null					  as [emlndocumentanalysisresultid],
		null					  as [emlnisreviewed],
		null					  as [emlntocontactid],
		null					  as [emlntocontactctgid],
		3						  as [emlndocpriority],
		null					  as [emlndocumentid],
		null					  as [emlndeleteflag],
		LEFT(CcAddress, 2000)	  as [emlsccaddresses],
		LEFT(BccAddress, 2000)	  as [emlsbccaddresses],
		LEFT(a.Id, 100)			  as [saga_char]
	--select *
	from ShinerLitify..[emailmessage] a
	join sma_trn_cases b
		on b.saga_char = CONVERT(VARCHAR(100), a.RelatedToId)
	where
		LEN(a.[id]) <= 100
go

alter table sma_trn_emails enable trigger all
go

