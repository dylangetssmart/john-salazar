use ShinerSA
go


-- id = a0CNt0000210NnQMAU
--select
--	*
--from sma_TRN_CaseStatus stcs
--where
--	stcs.cssnCaseID = 16585
--select
--	*
--from sma_MST_CaseStatus



/* ---------------------------------------------------------------------------------------------------------------------------------
Create missing case statuses

select distinct
	lpic.litify_pm__Status__c
from ShinerLitify..litify_pm__Intake__c lpic
--litify_pm__Status__c
--Retainer Signed
--Intake Follow Up
--Turned Down
--Under Review
--Open
--Converted
--Retainer Sent
--Referred Out
*/


insert into sma_mst_casestatus
	(
		csssDescription,
		cssnStatusTypeID
	)
	select distinct
		ISNULL(litify_pm__Status__c, 'LIT 00 - Lawsuit Needed'),
		1
	from ShinerLitify..litify_pm__Intake__c lpic
	--where litify_pm__Status__c <> 'Closed'
	except
	select
		csssDescription,
		cssnStatusTypeID
	from sma_mst_casestatus


/* ---------------------------------------------------------------------------------------------------------------------------------
Insert Case Status
*/

alter table [sma_TRN_CaseStatus] disable trigger all
go

insert into [sma_TRN_CaseStatus]
	(
		[cssnCaseID],
		[cssnStatusTypeID],
		[cssnStatusID],
		[cssnExpDays],
		[cssdFromDate],
		[cssdToDt],
		[csssComments],
		[cssnRecUserID],
		[cssdDtCreated],
		[cssnModifyUserID],
		[cssdDtModified],
		[cssnLevelNo],
		[cssnDelFlag],
		saga_char,
		source_db,
		source_ref
	)
	select distinct
		CAS.casnCaseID		   as [cssnCaseID],
		(
			select
				stpnStatusTypeID
			from sma_MST_CaseStatusType
			where stpsStatusType = 'Status'
		)					   as [cssnStatusTypeID],
		case
			when litify_pm__Status__c = 'Closed'
				then (
						select
							cssnStatusID
						from sma_MST_CaseStatus
						where csssDescription = 'Closed Case'
					)
			when litify_pm__Status__c is null
				then (
						select
							cssnStatusID
						from sma_MST_CaseStatus
						where csssDescription = 'LIT 00 - Lawsuit Needed'
							and cssnStatusTypeID = 1
					)
			else (
					select
						cssnStatusID
					from sma_MST_CaseStatus
					where csssDescription = [litify_pm__Status__c]
						and cssnStatusTypeID = 1
				)
		end					   as [cssnStatusID],
		''					   as [cssnExpDays],
		case
			when litify_pm__Status__c = 'Closed'
				then m.litify_pm__Turned_Down_Date__c
			else GETDATE()
		end					   as [cssdFromDate],
		null				   as [cssdToDt],
		--   isnull('Closed Reason: ' + nullif(convert(varchar,m.[litify_pm__Closed_Reason__c]),'') + CHAR(13),'') +
		--isnull('Closed Details: ' + nullif(convert(varchar,m.[litify_pm__Closed_Reason_Details__c]),'') + CHAR(13),'') +
		''					   as [csssComments],
		368					   as [cssnRecUserID],
		GETDATE()			   as [cssdDtCreated],
		null				   as [cssnModifyUserID],
		null				   as [cssdDtModified],
		null				   as [cssnLevelNo],
		null				   as [cssnDelFlag],
		[litify_pm__Status__c] as saga_char,
		'litify'			   as source_db,
		'litify_pm__intake__c' as source_ref
	from [sma_trn_cases] CAS
	join ShinerLitify..[litify_pm__intake__c] m
		on m.Id = CAS.saga_char
go

alter table [sma_TRN_CaseStatus] enable trigger all
go

/* ---------------------------------------------------------------------------------------------------------------------------------
Update cases
*/

alter table [sma_trn_cases] disable trigger all
go

update sma_trn_cases
set casnStatusValueID = STA.cssnStatusID
from sma_TRN_CaseStatus STA
where STA.cssnCaseID = casnCaseID

alter table [sma_trn_cases] enable trigger all
go