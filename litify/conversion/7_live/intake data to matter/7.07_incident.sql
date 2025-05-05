-- find examples
select --top 5
	i.id   as intake_id,
	m.id   as matter_id,
	cas.casnCaseID,
	m.Name as case_number,
	i.litify_pm__Description__c
from ShinerLitify..litify_pm__Intake__c i
join ShinerLitify..litify_pm__Matter__c m
	on i.litify_pm__Matter__c = m.Id
join sma_TRN_Cases cas
	on cas.saga_char = m.Id
join sma_TRN_Incidents inc
on inc.CaseId = cas.casnCaseID
where
	ISNULL(i.litify_pm__Description__c, '') <> ''
	and inc.IncidentFacts is null


select --top 5
	i.id   as intake_id,
	m.id   as matter_id,
	cas.casnCaseID,
	m.Name as case_number,
	inc.IncidentFacts,
	i.litify_pm__Description__c
from ShinerLitify..litify_pm__Intake__c i
join ShinerLitify..litify_pm__Matter__c m
	on i.litify_pm__Matter__c = m.Id
join sma_TRN_Cases cas
	on cas.saga_char = m.Id
join sma_TRN_Incidents inc
	on inc.CaseId = cas.casnCaseID
where
	ISNULL(i.litify_pm__Description__c, '') <> ''
	and inc.IncidentFacts is not null
	and inc.IncidentFacts <> i.litify_pm__Description__c


SELECT m.litify_pm__Description__c, i.litify_pm__Description__c
FROM ShinerLitify..litify_pm__Matter__c m
join ShinerLitify..litify_pm__Intake__c i
on i.litify_pm__Matter__c = m.Id



/* ---------------------------------------------------------------------------------------------------------------
[sma_TRN_Incidents] Schema
*/

-- saga_char
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_TRN_Incidents')
	)
begin
	alter table [sma_TRN_Incidents] add [saga_char] VARCHAR(MAX) null;
end

go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and object_id = OBJECT_ID(N'sma_TRN_Incidents')
	)
begin
	alter table [sma_TRN_Incidents] add [source_db] VARCHAR(MAX) null;
end

go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and object_id = OBJECT_ID(N'sma_TRN_Incidents')
	)
begin
	alter table [sma_TRN_Incidents] add [source_ref] VARCHAR(MAX) null;
end

go

/* ---------------------------------------------------------------------------------------------------------------
Update cases with no facts
*/
select 
	i.id   as intake_id,
	m.id   as matter_id,
	cas.casnCaseID,
	m.Name as case_number,
	i.litify_pm__Description__c
from ShinerLitify..litify_pm__Intake__c i
join ShinerLitify..litify_pm__Matter__c m
	on i.litify_pm__Matter__c = m.Id
join sma_TRN_Cases cas
	on cas.saga_char = m.Id
join sma_TRN_Incidents inc
on inc.CaseId = cas.casnCaseID
where
	ISNULL(i.litify_pm__Description__c, '') <> ''
	and inc.IncidentFacts is null

update inc
set IncidentFacts = i.litify_pm__Description__c,
	[saga_char] = i.id,
	[source_db] = 'litify',
	[source_ref] = 'post live - litify_pm__Matter__c'
from ShinerLitify..litify_pm__Intake__c i
join ShinerLitify..litify_pm__Matter__c m
	on m.id = i.litify_pm__Matter__c
join sma_trn_Cases cas
	on cas.saga_char = m.Id
join sma_TRN_Incidents inc
	on inc.CaseId = cas.casnCaseID
where ISNULL(i.litify_pm__Description__c, '') <> ''
and inc.IncidentFacts is null

/* ---------------------------------------------------------------------------------------------------------------
Update cases with existing facts
*/

select --top 5
	i.id   as intake_id,
	m.id   as matter_id,
	cas.casnCaseID,
	m.Name as case_number,
	inc.IncidentFacts,
	i.litify_pm__Description__c
from ShinerLitify..litify_pm__Intake__c i
join ShinerLitify..litify_pm__Matter__c m
	on i.litify_pm__Matter__c = m.Id
join sma_TRN_Cases cas
	on cas.saga_char = m.Id
join sma_TRN_Incidents inc
	on inc.CaseId = cas.casnCaseID
where
	ISNULL(i.litify_pm__Description__c, '') <> ''
	and inc.IncidentFacts is not null
	and inc.IncidentFacts <> i.litify_pm__Description__c
-- 309 total
-- ids:
--		578
--		547
--		450
--		475
--		490

update inc
set IncidentFacts = inc.IncidentFacts + CHAR(13) + CHAR(13) + i.litify_pm__Description__c,
	[saga_char] = i.id,
	[source_db] = 'litify',
	[source_ref] = 'post live - litify_pm__Matter__c'
from ShinerLitify..litify_pm__Intake__c i
join ShinerLitify..litify_pm__Matter__c m
	on m.id = i.litify_pm__Matter__c
join sma_trn_Cases cas
	on cas.saga_char = m.Id
join sma_TRN_Incidents inc
	on inc.CaseId = cas.casnCaseID
where ISNULL(i.litify_pm__Description__c, '') <> ''
and inc.IncidentFacts is not null
and inc.IncidentFacts <> i.litify_pm__Description__c

/* ---------------------------------------------------------------------------------------------------------------
Insert missing facts
*/

alter table [sma_TRN_Incidents] disable trigger all
go

alter table [sma_TRN_Cases] disable trigger all
go

insert into sma_trn_Incidents
	(
		[CaseId],
		[IncidentDate],
		[StateID],
		[LiabilityCodeId],
		[IncidentFacts],
		[MergedFacts],
		[Comments],
		[IncidentTime],
		[RecUserID],
		[DtCreated],
		[ModifyUserID],
		[DtModified],
		[saga_char],
		[source_db],
		[source_ref]
	)
	select
		cas.casnCaseID				as caseid,
		litify_pm__Incident_date__c as IncidentDate,
		--case
		--	when ISNULL(m.litify_pm__Case_State__c, '') <> ''
		--		then (
		--				select
		--					[sttnStateID]
		--				from [sma_MST_States]
		--				where sttsCode = LEFT(m.litify_pm__Case_State__c, 2)
		--			)
		--	else (
		--			select
		--				[sttnStateID]
		--			from [sma_MST_States]
		--			where [sttsDescription] = (
		--					select
		--						o.StateName
		--					from conversion.office o
		--				)
		--		)
		--end							as StateID,
		null as 					as StateID,
		0							as LiabilityCodeId,
		i.litify_pm__Description__c as [IncidentFacts],
		''							as [MergedFacts],
		''							as [Comments],
		null						as [IncidentTime],
		368							as [RecUserID],
		GETDATE()					as [DtCreated],
		null						as [ModifyUserID],
		null						as [DtModified],
		null						as [saga_char],
		null						as [source_db],
		null						as [source_ref]
	from ShinerLitify..litify_pm__Intake__c i
	join ShinerLitify..litify_pm__Matter__c m
		on m.id = i.litify_pm__Matter__c
	join sma_trn_Cases cas
		on cas.saga_char = m.Id
	join sma_TRN_Incidents inc
		on inc.CaseId = cas.casnCaseID
	where
		ISNULL(i.litify_pm__Description__c, '') <> ''
		and inc.IncidentFacts is null

			--and not exists (
			--	select
			--		1
			--	from sma_TRN_CriticalComments cc
			--	where cc.ctcnCaseID = cas.casnCaseID
			--		and cc.ctcsText = i.lps_Special_Notes__c
			--)




update CAS
set CAS.casdIncidentDate = INC.IncidentDate,
	CAS.casnStateID = INC.StateID,
	CAS.casnState = INC.StateID
from sma_trn_cases as CAS
left join sma_TRN_Incidents as INC
	on casnCaseID = CaseId
where INC.CaseId = CAS.casncaseid

---
alter table [sma_TRN_Incidents] enable trigger all
go

alter table [sma_TRN_Cases] enable trigger all
go