/*


*/

use ShinerSA
go

--INSURANCE ADJUSTERS

insert into sma_TRN_InsuranceCoverageAdjusters
	(
	InsuranceCoverageId,
	AdjusterContactUID,
	IsPrimary
	)
	select
		ic.incnInsCovgID,
		ioc.UNQCID,
		1
	from sma_TRN_InsuranceCoverage ic
	join IndvOrgContacts_Indexed ioc
		on ioc.cid = ic.incnAdjContactId
			and ioc.AID = ic.incnAdjAddressID
	where incnAdjContactId is not null 
