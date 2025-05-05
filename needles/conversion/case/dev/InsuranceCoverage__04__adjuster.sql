/* ###################################################################################
description: Insert defendants
steps:
	- Insert related contacts > [sma_MST_RelContacts]
	- Insert insurance adjusters > [sma_TRN_InsuranceCoverageAdjusters]
usage_instructions:
	- 
dependencies:
	- 
notes:
	-
*/

use [JohnSalazar_SA]
go

-------------------------------------------------------------------------------
-- Adjuster/Insurer association
-------------------------------------------------------------------------------
insert into [sma_MST_RelContacts]
	(
	[rlcnPrimaryCtgID],
	[rlcnPrimaryContactID],
	[rlcnPrimaryAddressID],
	[rlcnRelCtgID],
	[rlcnRelContactID],
	[rlcnRelAddressID],
	[rlcnRelTypeID],
	[rlcnRecUserID],
	[rlcdDtCreated],
	[rlcnModifyUserID],
	[rlcdDtModified],
	[rlcnLevelNo],
	[rlcsBizFam],
	[rlcnOrgTypeID]
	)
	select distinct
		1					  as [rlcnprimaryctgid],
		ic.[incnAdjContactId] as [rlcnprimarycontactid],
		ic.[incnAdjAddressID] as [rlcnprimaryaddressid],
		2					  as [rlcnrelctgid],
		ic.[incnInsContactID] as [rlcnrelcontactid],
		ic.[incnAdjAddressID] as [rlcnreladdressid],
		2					  as [rlcnreltypeid],
		368					  as [rlcnrecuserid],
		GETDATE()			  as [rlcddtcreated],
		null				  as [rlcnmodifyuserid],
		null				  as [rlcddtmodified],
		null				  as [rlcnlevelno],
		'Business'			  as [rlcsbizfam],
		null				  as [rlcnorgtypeid]
	from [sma_TRN_InsuranceCoverage] ic
	where ISNULL(ic.[incnAdjContactId], 0) <> 0
		and ISNULL(ic.[incnInsContactID], 0) <> 0


-------------------------------------------------------------------------------
-- INSURANCE ADJUSTERS
-------------------------------------------------------------------------------
insert into [sma_TRN_InsuranceCoverageAdjusters]
	(
	InsuranceCoverageId,
	AdjusterContactUID
	)
	select
		incnInsCovgID,
		ioc2.UNQCID
	from sma_TRN_InsuranceCoverage ic
	join IndvOrgContacts_Indexed ioc2
		on ioc2.CID = ic.incnAdjContactId
			and ioc2.AID = ic.[incnAdjAddressID]
	left join sma_TRN_InsuranceCoverageAdjusters ca
		on ca.InsuranceCoverageId = incnInsCovgID
			and ca.AdjusterContactUID = ioc2.UNQCID
	where ca.InsuranceCoverageId is null