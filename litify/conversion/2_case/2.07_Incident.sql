use ShinerSA
go

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
		litify_pm__Incident_date__c as incidentdate,
		case
			when ISNULL(m.litify_pm__Matter_State__c, '') <> ''
				then (
						select
							[sttnStateID]
						from [sma_MST_States]
						where sttsCode = LEFT(m.litify_pm__Matter_State__c, 2)
					)
			else (
					select
						[sttnStateID]
					from [sma_MST_States]
					where [sttsDescription] = (
							select
								StateName
							from conversion.office
						)
				)
		end							as stateid,
		0							as liabilitycodeid,
		m.litify_pm__Description__c as [incidentfacts],
		''							as [mergedfacts],
		''							as [comments],
		null						as [incidenttime],
		368							as [recuserid],
		GETDATE()					as [dtcreated],
		null						as [modifyuserid],
		null						as [dtmodified]
	from ShinerLitify..litify_pm__Matter__c m
	join sma_trn_Cases cas
		on cas.saga_char = m.Id

update CAS
set CAS.casdIncidentDate = INC.IncidentDate,
	CAS.casnStateID = INC.StateID,
	CAS.casnState = INC.StateID
from sma_trn_cases as cas
left join sma_TRN_Incidents as inc
	on casnCaseID = CaseId
where inc.CaseId = cas.casncaseid

---
alter table [sma_TRN_Incidents] enable trigger all
go

alter table [sma_TRN_Cases] enable trigger all
go
