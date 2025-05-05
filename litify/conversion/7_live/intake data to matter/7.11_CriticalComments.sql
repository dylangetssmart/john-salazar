select * from ShinerLitify..litify_pm__Matter__c lpmc where name = 'MAT-25030629566'
-- a0LNt00000QFd8XMAT

SELECT * FROM ShinerLitify..litify_pm__Intake__c lpic where lpic.litify_pm__Matter__c = 'a0LNt00000QFd8XMAT'
-- a0CNt00002K7ePoMAJ


SELECT lpic.lps_Special_Notes__c FROM ShinerLitify..litify_pm__Intake__c lpic where lpic.litify_pm__Matter__c = 'a0LNt00000QFd8XMAT'


-- find examples
select --top 5
	i.id   as intake_id,
	m.id   as matter_id,
	cas.casnCaseID,
	m.Name as case_number,
	i.litify_pm__Source__c,
	i.litify_pm__Source_Type__c,
	i.lps_Source_Details__c
from ShinerLitify..litify_pm__Intake__c i
join ShinerLitify..litify_pm__Matter__c m
	on i.litify_pm__Matter__c = m.Id
join sma_TRN_Cases cas
	on cas.saga_char = m.Id
where
	ISNULL(i.lps_Special_Notes__c, '') <> ''


SELECT * FROM sma_TRN_CriticalComments stcc


/* ---------------------------------------------------------------------------------------------------------------
[sma_TRN_CriticalComments] Schema
*/

-- saga_char
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_TRN_CriticalComments')
	)
begin
	alter table [sma_TRN_CriticalComments] add [saga_char] VARCHAR(MAX) null;
end

go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and object_id = OBJECT_ID(N'sma_TRN_CriticalComments')
	)
begin
	alter table [sma_TRN_CriticalComments] add [source_db] VARCHAR(MAX) null;
end

go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and object_id = OBJECT_ID(N'sma_TRN_CriticalComments')
	)
begin
	alter table [sma_TRN_CriticalComments] add [source_ref] VARCHAR(MAX) null;
end

go

/* ---------------------------------------------------------------------------------------------------------------
Insert critical comments
*/
alter table sma_TRN_CriticalComments disable trigger all
go

insert into [sma_TRN_CriticalComments]
	(
		[ctcnCaseID],
		[ctcnCommentTypeID],
		[ctcsText],
		[ctcbActive],
		[ctcnRecUserID],
		[ctcdDtCreated],
		[ctcnModifyUserID],
		[ctcdDtModified],
		[ctcnLevelNo],
		[ctcsCommentType],
		[saga_char],
		[source_db],
		[source_ref]
	)
	select
		cas.casnCaseID		   as [ctcncaseid],
		0					   as [ctcncommenttypeid],
		i.lps_Special_Notes__c as [ctcstext],
		1					   as [ctcbactive],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga_char = i.OwnerId
		)					   as [ctcnrecuserid],
		case
			when i.CreatedDate between '1900-01-01' and '2079-06-01'
				then i.CreatedDate
			else null
		end					   as [ctcddtcreated],
		null				   as [ctcnmodifyuserid],
		null				   as [ctcddtmodified],
		null				   as [ctcnlevelno],
		null				   as [ctcscommenttype],
		i.Id				   as [saga_char],
		'litify'			   as [source_db],
		'post live - litify_pm__Intake__c' as [source_ref]
	--select *
	from ShinerLitify..litify_pm__Intake__c i
	join ShinerLitify..litify_pm__Matter__c m
		on m.id = i.litify_pm__Matter__c
	join sma_trn_Cases cas
		on cas.saga_char = m.Id
	--where i.litify_pm__Display_Name__c like '%Mariela Ekladious%'
	where
		ISNULL(i.lps_Special_Notes__c, '') <> ''
	and not exists (
			select
				1
			from sma_TRN_CriticalComments cc
			where cc.ctcnCaseID = cas.casnCaseID
				and cc.ctcsText = i.lps_Special_Notes__c
		)
	order by ctcncaseid

alter table sma_TRN_CriticalComments enable trigger all
go