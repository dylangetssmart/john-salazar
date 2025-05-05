/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create users and contacts

replace:
'OfficeName'
'StateDescription'
'VenderCaseType'
##########################################################################################################################
*/

use [[JohnSalazar_SA]]
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
		cas.casnCaseID as caseid,
		case
			when (c.[date_of_incident] between '1900-01-01' and '2079-06-06')
				then CONVERT(DATE, c.[date_of_incident])
			else null
		end			   as incidentdate,
		case
			when exists (
					select
						*
					from sma_MST_States
					where sttsCode = u.[State]
				)
				then (
						select
							sttnStateID
						from sma_MST_States
						where sttsCode = u.[State]
					)
			else (
					select
						sttnStateID
					from sma_MST_States
					where sttsDescription = (
							select
								StateName
							from conversion.office
						)
				)
		end			   as [stateid]
		-- ,(
		-- 	select sttnStateID
		-- 	from sma_MST_States
		-- 	where sttsCode='VA'
		-- )							as [StateID]
		,
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
	from [JohnSalazar_Needles].[dbo].[cases_Indexed] c
	join [JohnSalazar_Needles].[dbo].[user_case_data] u
		on u.casenum = c.casenum
	join [sma_TRN_cases] cas
		on cas.cassCaseNumber = CONVERT(VARCHAR, c.casenum)

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