/*


*/

use ShinerSA
go

---
alter table [sma_TRN_InsuranceCoverage] disable trigger all
go

----------------------------
-- Insert Insurance Companies
----------------------------
insert into [sma_TRN_InsuranceCoverage]
	(
		[incnCaseID],
		[incnInsContactID],
		[incnInsAddressID],
		[incbCarrierHasLienYN],
		[incnInsType],
		[incnAdjContactId],
		[incnAdjAddressID],
		[incsPolicyNo],
		[incsClaimNo],
		[incnStackedTimes],
		[incsComments],
		[incnInsured],
		[incnCovgAmt],
		[incnDeductible],
		[incnUnInsPolicyLimit],
		[incnUnInsPolicyLimitAcc],
		[incnUnderPolicyLimit],
		[incnUnderPolicyLimitAcc],
		[incbPolicyTerm],
		[incbTotCovg],
		[incsPlaintiffOrDef],
		[incnPlaintiffIDOrDefendantID],
		[incnTPAdminOrgID],
		[incnTPAdminAddID],
		[incnTPAdjContactID],
		[incnTPAdjAddID],
		[incsTPAClaimNo],
		[incnRecUserID],
		[incdDtCreated],
		[incnModifyUserID],
		[incdDtModified],
		[incnLevelNo],
		[incb100Per],
		[incnMVLeased],
		[incnPriority],
		[incbDelete],
		[incnauthtodefcoun],
		[incnauthtodefcounDt],
		[incbPrimary],
		[saga],
		[saga_char],
		[source_db],
		[source_ref]
	)
	select distinct
		cas.casnCaseID							as [incncaseid],
		ISNULL(iocins.CID, unid.CID)			as [incninscontactid],
		ISNULL(iocins.AID, unid.AID)			as [incninsaddressid],
		null									as [incbcarrierhaslienyn],
		--(
		--	select top 1
		--		intnInsuranceTypeID
		--	from [sma_MST_InsuranceType]
		--	where intsDscrptn = ISNULL(i.litify_pm__Insurance_Type__c, 'Unknown')
		--)										as [incninstype],
		(
			select top 1
				intnInsuranceTypeID
			from [sma_MST_InsuranceType]
			where intsDscrptn = ISNULL(i.litify_pm__Coverages__c, 'Unspecified')
		)										as [incninstype],
		iocadj.CID								as [incnadjcontactid],
		iocadj.AID								as [incnadjaddressid],
		LEFT(i.litify_pm__Policy_Number__c, 30) as [incspolicyno],
		LEFT(i.litify_pm__Claim_Number__c, 30)  as [incsclaimno],
		null									as [incnstackedtimes],
		ISNULL('Name: ' + NULLIF(CONVERT(VARCHAR, i.[Name]), '') + CHAR(13), '') +
		ISNULL('Policy Number: ' + NULLIF(CONVERT(VARCHAR, i.litify_pm__Policy_Number__c), '') + CHAR(13), '') +
		ISNULL('Claim Number: ' + NULLIF(CONVERT(VARCHAR, i.litify_pm__Claim_Number__c), '') + CHAR(13), '') +
		ISNULL('Comments: ' + NULLIF(CONVERT(VARCHAR, i.[litify_pm__Comments__c]), '') + CHAR(13), '') +
		''										as [incscomments],
		insured.UNQCID							as [incninsured],
		null									as [incncovgamt],
		null									as [incndeductible],
		case
			when i.litify_pm__Coverages__c <> 'UM'
				then TRY_CONVERT(DECIMAL(18, 2), i.litify_pm__Per_Incident__c)
			else null
		end										as [incnUnInsPolicyLimit],		-- Policy Limits 1
		case
			when i.litify_pm__Coverages__c <> 'UM'
				then TRY_CONVERT(DECIMAL(18, 2), REPLACE(REPLACE(i.XPOLICIYLIMIT__c, '$', ''), ',', ''))
			else null
		end										as [incnUnInsPolicyLimitAcc],	-- Policy Limits 2
		case
			when i.litify_pm__Coverages__c = 'UM'
				then TRY_CONVERT(DECIMAL(18, 2), i.litify_pm__Per_Incident__c)
			else null
		end										as [incnUnderPolicyLimit],		-- UM/SUM Policy Limit 1
		case
			when i.litify_pm__Coverages__c = 'UM'
				then TRY_CONVERT(DECIMAL(18, 2), REPLACE(REPLACE(i.XPOLICIYLIMIT__c, '$', ''), ',', ''))
			else null
		end										as [incnUnderPolicyLimitAcc],	-- UM/SUM Policy Limit 2
		0										as [incbpolicyterm],
		0										as [incbtotcovg],
		'P'										as [incsplaintiffordef],
		(
			select
				plnnPlaintiffID
			from sma_trn_plaintiff
			where plnnCaseID = cas.casnCaseID
				and plnbIsPrimary = 1
		)										as [incnplaintiffidordefendantid],
		null									as [incntpadminorgid],
		null									as [incntpadminaddid],
		null									as [incntpadjcontactid],
		null									as [incntpadjaddid],
		null									as [incstpaclaimno],
		(
			select
				usrnUserID
			from sma_mst_users
			where saga_char = i.CreatedById
		)										as [incnrecuserid],
		i.CreatedDate							as [incddtcreated],
		(
			select
				usrnUserID
			from sma_mst_users
			where saga_char = i.LastModifiedById
		)										as [incnmodifyuserid],
		i.LastModifiedDate						as [incddtmodified],
		null									as [incnlevelno],
		0										as [incb100per],
		null									as [incnmvleased],
		null									as [incnpriority],
		0										as [incbdelete],
		0										as [incnauthtodefcoun],
		null									as [incnauthtodefcoundt],
		0										as [incbprimary],
		null									as [saga],
		i.id									as [saga_char],
		null									as [source_db],
		null									as [source_ref]
	--select *
	from ShinerLitify..litify_pm__Insurance__c i
	join sma_TRN_Cases cas
		on cas.saga_char = i.litify_pm__Matter__c
	left join vw_litifyRoleMapID iocins
		on iocins.ID = i.litify_pm__Insurance_Company__c
			and iocins.CTG = 2
	-- Unidentified Insurance fallback
	left join IndvOrgContacts_Indexed unid
		on unid.name = 'Unidentified Insurance'
	-- Adjuster
	left join vw_litifyRoleMapID iocadj
		on iocadj.ID = i.litify_pm__Adjuster__c
	left join vw_litifyRoleMapID insured
		on insured.ID = i.litify_ext__Policy_Holder_Party__c
	--join ShinerLitify.dbo.RecordType rt
	--	on i.RecordTypeId = LEFT(rt.Id, 15)
	--where i.litify_pm__Insurance_Type__c in ('Health',
	--	'Medicare',
	--	'Medicaid',
	--	'PPO',
	--	'HMO')
	where
		i.litify_pm__Coverages__c in ('UM',
		'PIP;No UM',
		'Health',
		'No UM',
		'PIP',
		'PIP;Med Pay;No UM',
		'PIP;Med Pay',
		'Med Pay',
		'UM;PIP',
		'PIP;BI')
--and i.litify_pm__Policy_Number__c = '942767165'
--and i.litify_pm__Matter__c = 'a0L8Z00000hOJNgUAO'






-------------------------------------------------------------------------------------------------------------
-- MAT-23082228360
-- CaseID=4125
/*
select
	*
from shinersa..vw_litifyRoleMapID vrmi
where vrmi.litify_pm__Matter__c = 'a0L8Z00000hOJNgUAO'


select
	lprc.litify_pm__Party__c,
	lprc.litify_pm__Role__c,
	lprc.litify_pm__Subtype__c,
	a.Name
from ShinerLitify..litify_pm__Role__c lprc
join ShinerLitify..Account a
	on a.id = lprc.litify_pm__Party__c
where lprc.litify_pm__Matter__c = 'a0L8Z00000hOJNgUAO'

select
	i.name,
	rt.name,
	i.litify_pm__Coverages__c,
	i.litify_pm__Insurance_Type__c,
	i.litify_pm__Claim_Number__c,
	i.litify_pm__Policy_Number__c,
	i.litify_pm__Adjuster__c,
	i.litify_ext__Adjuster_Party__c,
	a_adj.name			 as adjustername,
	i.litify_pm__Insurance_Company__c,
	i.litify_ext__Insurance_Company_Party__c,
	a_ins_company.name	 as insurancecompanyname,
	i.litify_pm__Policy_Holder__c,
	i.litify_ext__Policy_Holder_Party__c,
	a_policy_holder.name as policyholdername
from ShinerLitify..litify_pm__Insurance__c i
join ShinerLitify..Account a_adj
	on a_adj.id = i.litify_ext__Adjuster_Party__c
join ShinerLitify..Account a_policy_holder
	on a_policy_holder.Id = i.litify_ext__Policy_Holder_Party__c
join ShinerLitify..Account a_ins_company
	on a_ins_company.id = i.litify_ext__Insurance_Company_Party__c
join ShinerLitify.dbo.RecordType rt
	on i.RecordTypeId = LEFT(rt.Id, 15)
where i.litify_pm__Matter__c = 'a0L8Z00000hOJNgUAO'
*/
-------------------------------------------------------------------------------------------------------------

alter table [sma_TRN_InsuranceCoverage] enable trigger all
go