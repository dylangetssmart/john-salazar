/*
description: >
  Updates contact types in sma_MST_IndvContacts and sma_MST_OrgContacts
  based on related records in transactional tables.

mappings:
  - sma_TRN_InsuranceCoverage:
      - incnAdjContactId -> Adjuster (Indv)
      - incnInsContactID -> Insurance Company (Org)
  - sma_TRN_Hospitals:
      - hosnContactID (hosnContactCtg = 1) -> Doctor (Indv)
      - hosnContactID (hosnContactCtg = 2) -> Medical Office (Org)
  - sma_TRN_PlaintiffAttorney:
      - planAtorneyContactID -> Attorney (Indv)
      - planLawfrmContactID -> Law Firm (Org)
  - sma_TRN_LawFirms:
      - lwfnAttorneyContactID -> Attorney (Indv)
      - lwfnLawFirmContactID -> Law Firm (Org)
  - Needles.dbo.cases:
      - judge_link -> Judge (Indv)
  - sma_TRN_LawyerReferral
      - lwrnAttContactID -> Attorney (Indv)
      - lwrnRefLawFrmContactID -> Law Firm (Org)

notes:
  - Contact type IDs sourced from sma_MST_OriginalContactTypes
  - Triggers are disabled/enabled during update to prevent side effects
*/

use [SA]
go

------
alter table sma_MST_OrgContacts disable trigger all
go

alter table sma_MST_IndvContacts disable trigger all
go


/* ------------------------------------------------------------------------------
Insurance
*/ ------------------------------------------------------------------------------

-- Adjuster
-- [sma_TRN_InsuranceCoverage].[incnAdjContactId]
update [sma_MST_IndvContacts]
set cinnContactTypeID = (
	select
		octnOrigContactTypeID
	from [sma_MST_OriginalContactTypes]
	where octsDscrptn = 'Adjuster'
		and octnContactCtgID = 1
)
where cinnContactID in (
	select distinct
		incnAdjContactId
	from [sma_TRN_InsuranceCoverage] INS
	where incnAdjContactId is not null
)

go

-- Insurance Company
-- [sma_TRN_InsuranceCoverage].[incnInsContactID]
update [sma_MST_OrgContacts]
set connContactTypeID = (
	select
		octnOrigContactTypeID
	from [sma_MST_OriginalContactTypes]
	where octsDscrptn = 'Insurance Company'
		and octnContactCtgID = 2
)
where connContactID in (
	select distinct
		incnInsContactID
	from [sma_TRN_InsuranceCoverage] INS
	where incnInsContactID is not null
)
go


/* ------------------------------------------------------------------------------
Hospitals
*/ ------------------------------------------------------------------------------

-- Doctor (Individual Contacts)
-- [sma_TRN_Hospitals].[hosnContactID]
update [sma_MST_IndvContacts]
set cinnContactTypeID = (
	select
		octnOrigContactTypeID
	from [sma_MST_OriginalContactTypes]
	where octsDscrptn = 'Doctor'
		and octnContactCtgID = 1
)
where cinnContactID in (
	select distinct
		hosnContactID
	from [sma_TRN_Hospitals] HOS
	where hosnContactID is not null
		and hosnContactCtg = 1
)
go


-- Medical Office (Organization Contacts)
-- [sma_TRN_Hospitals].[hosnContactID]
update [sma_MST_OrgContacts]
set connContactTypeID = (
	select
		octnOrigContactTypeID
	from [sma_MST_OriginalContactTypes]
	where octsDscrptn = 'Medical Office'
		and octnContactCtgID = 2
)
where connContactID in (
	select distinct
		hosnContactID
	from [sma_TRN_Hospitals] HOS
	where hosnContactID is not null
		and hosnContactCtg = 2
)
go


/* ------------------------------------------------------------------------------
Plaintiff Attorney
*/ ------------------------------------------------------------------------------

-- Attorney (Individual Contacts)
-- [sma_TRN_PlaintiffAttorney].[planAtorneyContactID]
update [sma_MST_IndvContacts]
set cinnContactTypeID = (
	select
		octnOrigContactTypeID
	from [sma_MST_OriginalContactTypes]
	where octsDscrptn = 'Attorney'
		and octnContactCtgID = 1
)
where cinnContactID in (
	select distinct
		planAtorneyContactID
	from [sma_TRN_PlaintiffAttorney]
	where planAtorneyContactID is not null
)


-- Law Firm (Organization Contacts)
-- [sma_TRN_PlaintiffAttorney].[planLawfrmContactID]
update [sma_MST_OrgContacts]
set connContactTypeID = (
	select
		octnOrigContactTypeID
	from [sma_MST_OriginalContactTypes]
	where octsDscrptn = 'Law Firm'
		and octnContactCtgID = 2
)
where connContactID in (
	select distinct
		planLawfrmContactID
	from [sma_TRN_PlaintiffAttorney]
	where planLawfrmContactID is not null
)


/* ------------------------------------------------------------------------------
Defense Attorneys
*/ ------------------------------------------------------------------------------

-- Attorney (Individual Contacts)
-- [sma_TRN_LawFirms].[lwfnAttorneyContactID]
update [sma_MST_IndvContacts]
set cinnContactTypeID = (
	select
		octnOrigContactTypeID
	from [sma_MST_OriginalContactTypes]
	where octsDscrptn = 'Attorney'
		and octnContactCtgID = 1
)
where cinnContactID in (
	select distinct
		lwfnAttorneyContactID
	from [sma_TRN_LawFirms]
	where lwfnAttorneyContactID is not null
)

-- Law Firm (Individual Contacts)
-- [sma_TRN_LawFirms].[lwfnLawFirmContactID]
update [sma_MST_OrgContacts]
set connContactTypeID = (
	select
		octnOrigContactTypeID
	from [sma_MST_OriginalContactTypes]
	where octsDscrptn = 'Law Firm'
		and octnContactCtgID = 2
)
where connContactID in (
	select distinct
		lwfnLawFirmContactID
	from [sma_TRN_LawFirms]
	where lwfnLawFirmContactID is not null
)


/* ------------------------------------------------------------------------------
Judge
*/ ------------------------------------------------------------------------------

-- Judge
-- [sma_TRN_PlaintiffAttorney].[planAtorneyContactID]
update [sma_MST_IndvContacts]
set cinnContactTypeID = (
	select
		octnOrigContactTypeID
	from [sma_MST_OriginalContactTypes]
	where octsDscrptn = 'Judge'
)
from (
	select distinct
		judge_link
	from [Schechter_Needles].[dbo].[cases]
) A
where A.judge_link = saga
and ISNULL(saga, 0) <> 0


/* ------------------------------------------------------------------------------
Referring Attorney
*/ ------------------------------------------------------------------------------

-- Attorney (Individual Contacts)
-- [sma_TRN_LawyerReferral].[lwrnAttContactID]
update [sma_MST_IndvContacts]
set cinnContactTypeID = (
	select
		octnOrigContactTypeID
	from [sma_MST_OriginalContactTypes]
	where octsDscrptn = 'Attorney'
		and octnContactCtgID = 1
)
where cinnContactID in (
	select distinct
		lwrnAttContactID
	from [sma_TRN_LawyerReferral]
	where lwrnAttContactID is not null
)

-- Law Firm (Individual Contacts)
-- [sma_TRN_LawyerReferral].[lwrnRefLawFrmContactID]
update [sma_MST_OrgContacts]
set connContactTypeID = (
	select
		octnOrigContactTypeID
	from [sma_MST_OriginalContactTypes]
	where octsDscrptn = 'Law Firm'
		and octnContactCtgID = 2
)
where connContactID in (
	select distinct
		lwrnRefLawFrmContactID
	from [sma_TRN_LawyerReferral]
	where lwrnRefLawFrmContactID is not null
)



-----
alter table sma_MST_OrgContacts enable trigger all
go

alter table sma_MST_IndvContacts enable trigger all
go
-----