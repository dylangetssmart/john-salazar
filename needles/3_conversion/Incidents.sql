use [SA]
go


/* ------------------------------------------------------------------------------
Insert [sma_TRN_Incidents]
*/ ------------------------------------------------------------------------------
alter table [sma_TRN_Incidents] disable trigger all
go

insert into [sma_TRN_Incidents]
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
		cas.casnCaseID as caseid,
		case
			when (c.[date_of_incident] between '1900-01-01' and '2079-06-06') then CONVERT(DATE, c.[date_of_incident])
			else null
		end			   as incidentdate,
		(
		 select
			 smo.state_id
		 from sma_mst_offices smo
		 where smo.is_default = 1
		)			   as [stateid],
		0			   as liabilitycodeid,
		c.synopsis + CHAR(13) +
		--isnull('Description of Accident:' + nullif(u.Description_of_Accident,'') + CHAR(13),'') + 
		''			   as incidentfacts,
		''			   as [mergedfacts],
		null		   as [comments],
		null		   as [incidenttime],
		368			   as [recuserid],
		GETDATE()	   as [dtcreated],
		null		   as [modifyuserid],
		null		   as [dtmodified]
	from [Needles].[dbo].[cases_Indexed] c
	join [sma_TRN_cases] cas
		on cas.cassCaseNumber = CONVERT(VARCHAR, c.casenum)
go

alter table [sma_TRN_Incidents] enable trigger all
go


/* ------------------------------------------------------------------------------
Update case incident date
*/ ------------------------------------------------------------------------------

alter table [sma_TRN_Cases] disable trigger all
go

update CAS
set CAS.casdIncidentDate = INC.IncidentDate,
	CAS.casnStateID = INC.StateID,
	CAS.casnState = INC.StateID
from sma_trn_cases as cas
left join sma_TRN_Incidents as inc
	on casnCaseID = CaseId
where inc.CaseId = cas.casncaseid
go

alter table [sma_TRN_Cases] enable trigger all
go