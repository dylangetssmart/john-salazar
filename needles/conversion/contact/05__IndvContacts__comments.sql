/*---
group: load
order: 71
description: Update contact types for attorneys
---*/

use VanceLawFirm_SA
go

/*
update sma_MST_IndvContacts set cinsComments = NULL

*/
---
alter table sma_MST_IndvContacts disable trigger all
go

---

----(1)----
update sma_MST_IndvContacts
set cinsComments = ISNULL(cinsComments, '') + CHAR(13) + 'Age : ' + CONVERT(VARCHAR, A.Age)
from (
	select
		p.case_id as caseid,
		p.party_id as partyid,
		DATEPART(yyyy, GETDATE()) - DATEPART(yyyy, n.date_of_birth) - 1 as age

	from [VanceLawFirm_Needles].[dbo].[party_Indexed] p
	join [VanceLawFirm_Needles].[dbo].[names] n
		on n.names_id = p.party_id
	where n.date_of_birth is not null
) a
where a.partyid = saga


----(2)----
update sma_MST_IndvContacts
set cinsComments = ISNULL(cinsComments, '') + CHAR(13) + 'Age at DOI : ' + CONVERT(VARCHAR, A.DOI)
from (
	select
		p.case_id as caseid,
		p.party_id as partyid,
		DATEPART(yyyy, c.date_of_incident) - DATEPART(yyyy, n.date_of_birth) - 1 as doi
	from [VanceLawFirm_Needles].[dbo].[party_Indexed] p
	join [VanceLawFirm_Needles].[dbo].[names] n
		on n.names_id = p.party_id
	join [VanceLawFirm_Needles].[dbo].[cases] c
		on c.casenum = p.case_id
	where c.date_of_incident is not null
		and n.date_of_birth is not null
) a
where a.partyid = saga


----(3)----
update sma_MST_IndvContacts
set cinsComments = ISNULL(cinsComments, '') + CHAR(13) + 'Deceased : ' + CONVERT(VARCHAR, A.Deceased)
from (
	select
		p.case_id as caseid,
		p.party_id as partyid,
		n.deceased as deceased
	from [VanceLawFirm_Needles].[dbo].[party_Indexed] p
	join [VanceLawFirm_Needles].[dbo].[names] n
		on n.names_id = p.party_id
	where n.deceased is not null
) a
where a.partyid = saga


----(4)----
update sma_MST_IndvContacts
set cinsComments = ISNULL(cinsComments, '') + CHAR(13) + 'Date of Death : ' + CONVERT(VARCHAR, A.DOD)
from (
	select
		p.case_id as caseid,
		p.party_id as partyid,
		DATEPART(yyyy, n.date_of_death) as dod
	from [VanceLawFirm_Needles].[dbo].[party_Indexed] p
	join [VanceLawFirm_Needles].[dbo].[names] n
		on n.names_id = p.party_id
	where n.date_of_death is not null
) a
where a.partyid = saga



----(5)----
update sma_MST_IndvContacts
set cinsComments = ISNULL(cinsComments, '') + CHAR(13) + 'Incapacitated : ' + CONVERT(VARCHAR, A.incapacitated)
from (
	select
		p.case_id as caseid,
		p.party_id as partyid,
		p.incapacitated as incapacitated
	from [VanceLawFirm_Needles].[dbo].[party_Indexed] p
	join [VanceLawFirm_Needles].[dbo].[names] n
		on n.names_id = p.party_id
	where ISNULL(incapacitated, '') <> ''
) a
where a.partyid = saga


----(5)----
update sma_MST_IndvContacts
set cinsComments = ISNULL(cinsComments, '') + CHAR(13) + 'Incapacity : ' + CONVERT(VARCHAR, A.incapacity)
from (
	select
		p.case_id as caseid,
		p.party_id as partyid,
		p.incapacity as incapacity
	from [VanceLawFirm_Needles].[dbo].[party_Indexed] p
	join [VanceLawFirm_Needles].[dbo].[names] n
		on n.names_id = p.party_id
	where ISNULL(incapacity, '') <> ''
) a
where a.partyid = saga



----(6)----
update sma_MST_IndvContacts
set cinsComments = ISNULL(cinsComments, '') + CHAR(13) + 'Responsible for another party : ' + CONVERT(VARCHAR, A.responsibility)
from (
	select
		p.case_id as caseid,
		p.party_id as partyid,
		p.responsibility as responsibility
	from [VanceLawFirm_Needles].[dbo].[party_Indexed] p
	join [VanceLawFirm_Needles].[dbo].[names] n
		on n.names_id = p.party_id
	where ISNULL(p.responsibility, '') <> ''
) a
where a.partyid = saga


---
alter table sma_MST_IndvContacts enable trigger all
go
---
