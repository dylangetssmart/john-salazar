use ShinerSA
go

------
alter table sma_MST_OrgContacts disable trigger all
go

alter table sma_MST_IndvContacts disable trigger all
go

-----

----(0)----

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


----(1)----

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



----(2)----

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


----(3)----

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



------
alter table sma_MST_OrgContacts enable trigger all
go

alter table sma_MST_IndvContacts enable trigger all
go
-----
