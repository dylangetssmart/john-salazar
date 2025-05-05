/* 




*/

use ShinerSA
go


/***********************************************************************
**  Status Types:  [litify_pm__Matter__c].[litify_pm__Status__c]
**	Sub Status Types:  Litify Stage
***********************************************************************/


-- source_id
-- this should be source_id, but many scripts already use `saga_char`
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_TRN_CaseStatus')
	)
begin
	alter table [sma_TRN_CaseStatus] add [saga_char] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and object_id = OBJECT_ID(N'sma_TRN_CaseStatus')
	)
begin
	alter table [sma_TRN_CaseStatus] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and object_id = OBJECT_ID(N'sma_TRN_CaseStatus')
	)
begin
	alter table [sma_TRN_CaseStatus] add [source_ref] VARCHAR(MAX) null;
end
go

------------------------------------------------
--MAKE SURE ALL STATUSES EXIST IN SA
------------------------------------------------
insert into sma_mst_casestatus
	(
		csssDescription,
		cssnStatusTypeID
	)
	select distinct
		ISNULL(litify_pm__Status__c, 'LIT 00 - Lawsuit Needed'),
		1
	from ShinerLitify..[litify_pm__Matter__c]
	where
		litify_pm__Status__c <> 'Closed'
	except
	select
		csssDescription,
		cssnStatusTypeID
	from sma_mst_casestatus

--SUB STATUSES
insert into sma_mst_casestatus
	(
		csssDescription,
		cssnStatusTypeID
	)
	select distinct
		st.[name] as [stage],
		2
	from ShinerLitify..litify_pm__Matter_plan__c p
	join ShinerLitify..litify_pm__Matter_Stage__c st
		on p.id = st.litify_pm__Matter_Plan__c
	join ShinerLitify..litify_pm__Matter_stage_activity__c sta
		on sta.litify_pm__Original_Matter_Stage__c = st.Id
	where
		sta.litify_pm__Stage_Status__c = 'Active'
	except
	select
		csssDescription,
		cssnStatusTypeID
	from sma_mst_casestatus

---------
alter table [sma_TRN_CaseStatus] disable trigger all
go

---------

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
		cas.casnCaseID		   as [cssncaseid],
		(
			select
				stpnStatusTypeID
			from sma_MST_CaseStatusType
			where stpsStatusType = 'Status'
		)					   as [cssnstatustypeid],
		case
			when litify_pm__Status__c = 'Closed'
				then (
						select
							cssnstatusid
						from sma_MST_CaseStatus
						where csssDescription = 'Closed Case'
					)
			when litify_pm__Status__c is null
				then (
						select
							cssnstatusid
						from sma_MST_CaseStatus
						where csssDescription = 'LIT 00 - Lawsuit Needed'
							and cssnstatustypeid = 1
					)
			else (
					select
						cssnstatusid
					from sma_MST_CaseStatus
					where csssDescription = [litify_pm__Status__c]
						and cssnstatustypeid = 1
				)
		end					   as [cssnstatusid],
		''					   as [cssnexpdays],
		case
			when litify_pm__Status__c = 'Closed'
				then ISNULL(m.litify_pm__Closed_Date__c, litify_pm__Close_Date__c)
			else GETDATE()
		end					   as [cssdfromdate],
		null				   as [cssdtodt],
		ISNULL('Closed Reason: ' + NULLIF(CONVERT(VARCHAR, m.[litify_pm__Closed_Reason__c]), '') + CHAR(13), '')
		+ ISNULL('Closed Details: ' + NULLIF(CONVERT(VARCHAR, m.[litify_pm__Closed_Reason_Details__c]), '') + CHAR(13), '')
		+ ''				   as [cssscomments],
		368					   as [cssnrecuserid],
		GETDATE()			   as [cssddtcreated],
		null,
		null,
		null,
		null,
		[litify_pm__Status__c] as saga_char,
		'litify'			   as source_db,
		'litify_pm__Matter__c' as source_ref
	from [sma_trn_cases] cas
	join ShinerLitify..[litify_pm__Matter__c] m
		on m.Id = cas.saga_char
go

---------------------------
--SUB STATUS
---------------------------
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
		cas.casnCaseID				 as [cssncaseid],
		(
			select
				stpnStatusTypeID
			from sma_MST_CaseStatusType
			where stpsStatusType = 'Sub Status'
		)							 as [cssnstatustypeid],
		(
			select
				cssnstatusid
			from sma_MST_CaseStatus
			where csssDescription = st.[name]
				and cssnstatustypeid = (
					select
						stpnStatusTypeID
					from sma_MST_CaseStatusType
					where stpsStatusType = 'Sub Status'
				)
		)							 as [cssnstatusid],
		''							 as [cssnexpdays],
		case
			when [litify_pm__Set_As_Active_At__c] between '1/1/1900' and '6/6/2079'
				then [litify_pm__Set_As_Active_At__c]
			else GETDATE()
		end							 as [cssdfromdate],
		null						 as [cssdtodt],
		''							 as [cssscomments],
		368							 as [cssnrecuserid],
		GETDATE()					 as [cssddtcreated],
		null						 as [cssnModifyUserID],
		null						 as [cssdDtModified],
		null						 as [cssnLevelNo],
		null						 as [cssnDelFlag],
		st.Name						 as saga_char,
		'litify'					 as source_db,
		'litify_pm__Matter_stage__c' as source_ref
	from [ShinerLitify]..[litify_pm__Matter_plan__c] p
	join [ShinerLitify]..[litify_pm__Matter_stage__c] st
		on p.id = st.litify_pm__Matter_Plan__c
	join [ShinerLitify]..[litify_pm__Matter_stage_activity__c] sta
		on sta.litify_pm__Original_Matter_Stage__c = st.Id
	join [sma_trn_cases] cas
		on cas.saga_char = sta.litify_pm__Matter__c
	where
		sta.litify_pm__Stage_Status__c = 'Active'
go


--------
alter table [sma_TRN_CaseStatus] enable trigger all
go

--------


---(2)---
alter table [sma_trn_cases] disable trigger all
go

---------
update sma_trn_cases
set casnStatusValueID = STA.cssnStatusID
from sma_TRN_CaseStatus sta
where sta.cssnCaseID = casnCaseID

alter table [sma_trn_cases] enable trigger all
go


