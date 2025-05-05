
use KurtYoung_SA
go

/*
alter table [sma_TRN_Documents] disable trigger all
delete from [sma_TRN_Documents] 
DBCC CHECKIDENT ('[sma_TRN_Documents]', RESEED, 0);
alter table [sma_TRN_Documents] enable trigger all
*/

---(0)----

if OBJECT_ID(N'dbo.FileNamePart', N'FN') is not null
	drop function FileNamePart;
go

create function dbo.FileNamePart (@parameter VARCHAR(MAX))
returns VARCHAR(MAX)
as

begin
	declare @trimParameter VARCHAR(MAX) = LTRIM(RTRIM(@parameter));
	declare @return VARCHAR(MAX);
	declare @position INT = CONVERT(INT, (
		select
			CHARINDEX('\', REVERSE(@trimParameter), 0)
	))
	set @return = SUBSTRING(RIGHT(@trimParameter, @position), 2, 1000)
	return @return;
end;
go

---(0)---

if OBJECT_ID(N'dbo.PathPart', N'FN') is not null
	drop function PathPart;
go

create function dbo.PathPart (@parameter VARCHAR(MAX))
returns VARCHAR(MAX)
as

begin
	declare @trimParameter VARCHAR(MAX) = LTRIM(RTRIM(@parameter));
	declare @return VARCHAR(MAX);
	if ((LEN(@trimParameter) + 2 - CONVERT(INT, (
			select
				CHARINDEX('\', REVERSE(@trimParameter), 0)
		))) < 0)
	begin
		set @return = @trimParameter
	end
	else
	begin
		set @return = SUBSTRING(@trimParameter, 0, LEN(@trimParameter) + 2 - CONVERT(INT, (
			select
				CHARINDEX('\', REVERSE(@trimParameter), 0)
		)))
	end
	return @return;
end;
go

---(0)---
insert into [sma_MST_ScannedDocCategories]
	(
	sctgsCategoryName
	)
	(
	select distinct
		Category as sctgscategoryname
	from KurtYoung_Needles.[dbo].[documents]
	where ISNULL(category, '') <> ''
	union
	select
		'Other'
	)
	except
	select
		sctgscategoryname
	from [sma_MST_ScannedDocCategories]
go

alter table [dbo].[sma_TRN_Documents]
alter column [docsToContact] [VARCHAR](120) null
go

----

if not exists (
		select
			*
		from sys.COLUMNS
		where Name = N'saga'
			and object_id = OBJECT_ID(N'sma_TRN_Documents')
	)
begin
	alter table [sma_TRN_Documents] add [saga] [VARCHAR](500) null;
end

go

----

alter table [sma_TRN_Documents] disable trigger all
go

set quoted_identifier on

---(1)---


/*
alter table [sma_TRN_Documents] disable trigger all
delete from [sma_TRN_Documents] 
DBCC CHECKIDENT ('[sma_TRN_Documents]', RESEED, 0);
alter table [sma_TRN_Documents] enable trigger all
*/

insert into [sma_TRN_Documents]
	(
	[docnCaseID],
	[docsDocumentName],
	[docsDocumentPath],
	[docsDocumentData],
	[docnCategoryID],
	[docnSubCategoryID],
	[docnFromContactCtgID],
	[docnFromContactID],
	[docsToContact],
	[docsDocType],
	[docnTemplateID],
	[docbAttachFlag],
	[docsDescrptn],
	[docnAuthor],
	[docsDocsrflag],
	[docnRecUserID],
	[docdDtCreated],
	[docnModifyUserID],
	[docdDtModified],
	[docnLevelNo],
	[ctgnCategoryID],
	[sctnSubCategoryID],
	[sctssSubSubCategoryID],
	[sctsssSubSubSubCategoryID],
	[docnMedProvContactctgID],
	[docnMedProvContactID],
	[docnComments],
	[docnReasonReject],
	[docsReviewerContactId],
	[docsReviewDate],
	[docsDocumentAnalysisResultId],
	[docsIsReviewed],
	[docsToContactID],
	[docsToContactCtgID],
	[docdLastUpdated],
	[docnPriority],
	[saga]
	)

	select
		cas.casnCaseID					  as [docncaseid],
		dbo.FileNamePart(doc.[file_path]) as [docsdocumentname],
		dbo.PathPart(doc.[file_path])	  as [docsdocumentpath],
		''								  as [docsdocumentdata],
		null							  as [docncategoryid],
		null							  as [docnsubcategoryid],
		1								  as [docnfromcontactctgid],
		null							  as docnfromcontactid,
		null							  as [docstocontact],
		'Doc'							  as [docsdoctype],
		null							  as [docntemplateid],
		null							  as [docbattachflag],
		LEFT(doc.[notes], 4000)			  as [docsdescrptn],
		0								  as [docnauthor],
		''								  as [docsdocsrflag],
		--(select usrnUserID from sma_MST_Users where saga=DOC.Staff_Created)	as [docnRecUserID],
		--case
		--when DOC.Date_Added between '1900-01-01' and '2079-06-06' then DOC.Date_Added
		--else null
		--end						 as [docdDtCreated],

		null							  as [docnrecuserid],
		null							  as [docddtcreated],
		null							  as [docnmodifyuserid],
		null							  as [docddtmodified],
		''								  as [docnlevelno],
		case
			when exists (
					select
						*
					from sma_MST_ScannedDocCategories
					where sctgsCategoryName = doc.category
				)
				then (
						select
							sctgnCategoryID
						from sma_MST_ScannedDocCategories
						where sctgsCategoryName = doc.category
					)
			else (
					select
						sctgnCategoryID
					from sma_MST_ScannedDocCategories
					where sctgsCategoryName = 'Other/Misc'
				)
		end								  as [ctgncategoryid],
		null							  as [sctnsubcategoryid],
		'',
		'',
		'',
		'',
		'',
		'',
		null,
		null,
		null,
		null,
		null,
		null,
		GETDATE(),
		3								  as [docnpriority],  -- normal priority
		null							  as [saga]
	from KurtYoung_Needles.[dbo].[documents] doc
	join [sma_TRN_Cases] cas
		on cas.cassCaseNumber = doc.case_id
go

alter table [sma_TRN_Documents] enable trigger all
go


/*

select
    DOC.[case_id],
    DOC.[file_path],
    dbo.FileNamePart(DOC.[file_path])	as [docsDocumentName],
    dbo.PathPart(DOC.[file_path])	 as [docsDocumentPath]
FROM KurtYoung_Needles.[dbo].[documents] DOC
where case_id=200133

*/

/*
select 
    DOC.Category,
    (select sctgnCategoryID FROM sma_MST_ScannedDocCategories where sctgsCategoryName=DOC.Category),
    case
	   when exists (select * FROM sma_MST_ScannedDocCategories where sctgsCategoryName=DOC.Category) 
		  then (select sctgnCategoryID FROM sma_MST_ScannedDocCategories where sctgsCategoryName=DOC.Category)
	   else (select sctgnCategoryID FROM sma_MST_ScannedDocCategories where sctgsCategoryName='Other')
    end						 as [ctgnCategoryID]
FROM KurtYoung_Needles.[dbo].[documents] DOC
*/