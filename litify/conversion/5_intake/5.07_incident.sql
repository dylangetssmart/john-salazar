use shinersa
go

------------------------------------
--INCIDENT
------------------------------------

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
		[DtModified]
	)
	select
		cas.casnCaseID				as caseid,
		litify_pm__Incident_date__c as IncidentDate,
		case
			when ISNULL(m.litify_pm__Case_State__c, '') <> ''
				then (
						select
							[sttnStateID]
						from [sma_MST_States]
						where sttsCode = LEFT(m.litify_pm__Case_State__c, 2)
					)
			else (
					select
						[sttnStateID]
					from [sma_MST_States]
					where [sttsDescription] = (
							select
								o.StateName
							from conversion.office o
						)
				)
		end							as StateID,
		0							as LiabilityCodeId,
		m.litify_pm__Description__c as [IncidentFacts],
		''							as [MergedFacts],
		''							as [Comments],
		null						as [IncidentTime],
		368							as [RecUserID],
		GETDATE()					as [DtCreated],
		null						as [ModifyUserID],
		null						as [DtModified]
	from ShinerLitify..[litify_pm__intake__c] m
	join sma_trn_Cases cas
		on cas.saga_char = m.Id


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