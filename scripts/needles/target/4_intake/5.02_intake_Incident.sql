use [JohnSalazar_SA]
go

/*
alter table [sma_TRN_Incidents] disable trigger all
delete [sma_TRN_Incidents]
DBCC CHECKIDENT ('[sma_TRN_Incidents]', RESEED, 0);
alter table [sma_TRN_Incidents] enable trigger all
*/

---
alter table [sma_TRN_Incidents] disable trigger all
go

alter table [sma_TRN_Cases] disable trigger all
go

---
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
		C.casnCaseID as CaseId,
		case
			when (N.[date_of_incident] between '1900-01-01' and '2079-06-06') then CONVERT(DATE, N.[date_of_incident])
			else null
		end			 as IncidentDate,
		(
		 select
			 sttnStateID
		 from sma_MST_States
		 where sttsCode = 'TX'
		)			 as [StateID],
		0			 as LiabilityCodeId,
		N.synopsis	 as IncidentFacts,
		''			 as [MergedFacts],
		null		 as comments,
		null		 as [IncidentTime],
		368			 as [RecUserID],
		GETDATE()	 as [DtCreated],
		null		 as [ModifyUserID],
		null		 as [DtModified]
	from [JohnSalazar_Needles].[dbo].case_intake N
	join [sma_TRN_Cases] C
		on C.saga = N.ROW_ID
	where
		ISNULL(N.synopsis, '') <> ''
		or
		ISNULL(N.date_of_incident, '') <> ''






update CAS
set CAS.casdIncidentDate = INC.IncidentDate,
	CAS.casnStateID = INC.StateID,
	CAS.casnState = INC.StateID
from sma_trn_cases as CAS
left join sma_TRN_Incidents as INC
	on casnCaseID = caseid
where INC.CaseId = CAS.casncaseid

---
alter table [sma_TRN_Incidents] enable trigger all
go

alter table [sma_TRN_Cases] enable trigger all
go
