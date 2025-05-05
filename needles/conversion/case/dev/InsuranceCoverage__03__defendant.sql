/* ###################################################################################
description: Insert defendants
steps:
	- Insert defendant insurance > [sma_TRN_InsuranceCoverage]
	
usage_instructions:
	- 
dependencies:
	- [conversion].[insurance_contacts_helper]
notes:
	-
*/

use [KurtYoung_SA]
go

alter table [sma_TRN_InsuranceCoverage] disable trigger all
go

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
	[incnUnderPolicyLimit],
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
	[incnUnInsPolicyLimitAcc],
	[incnUnderPolicyLimitAcc],
	[incb100Per],
	[incnMVLeased],
	[incnPriority],
	[incbDelete],
	[incnauthtodefcoun],
	[incnauthtodefcounDt],
	[incbPrimary],
	[saga]
	)
	select distinct
		map.caseID				 as [incncaseid],
		map.incninscontactid	 as [incninscontactid],
		map.incninsaddressid	 as [incninsaddressid],
		null					 as [incbcarrierhaslienyn],
		(
			select
				intnInsuranceTypeID
			from [sma_MST_InsuranceType]
			where intsDscrptn = case
					when ISNULL(ins.policy_type, '') <> ''
						then ins.policy_type
					else 'Unspecified'
				end
		)						 as [incninstype],
		map.incnadjcontactid	 as [incnadjcontactid],
		map.incnadjaddressid	 as [incnadjaddressid],
		ins.policy				 as [incspolicyno],
		ins.claim				 as [incsclaimno],
		null					 as [incnstackedtimes],
		--ISNULL('accept : ' + NULLIF(CONVERT(VARCHAR, ins.accept), '') + CHAR(13), '') +
		--ISNULL('actual : ' + NULLIF(CONVERT(VARCHAR, ins.actual), '') + CHAR(13), '') +
		--ISNULL('agent : ' + NULLIF(CONVERT(VARCHAR, ins.agent), '') + CHAR(13), '') +
		--ISNULL('date_settled : ' + NULLIF(CONVERT(VARCHAR, ins.date_settled), '') + CHAR(13), '') +
		--ISNULL('how_settled : ' + NULLIF(CONVERT(VARCHAR, ins.how_settled), '') + CHAR(13), '') +
		--ISNULL('maximum_amount : ' + NULLIF(CONVERT(VARCHAR, ins.maximum_amount), '') + CHAR(13), '') +
		--ISNULL('minimum_amount : ' + NULLIF(CONVERT(VARCHAR, ins.minimum_amount), '') + CHAR(13), '') +
		--ISNULL('policy : ' + NULLIF(CONVERT(VARCHAR, ins.policy), '') + CHAR(13), '') +
		--ISNULL('claim : ' + NULLIF(CONVERT(VARCHAR, ins.claim), '') + CHAR(13), '') +
		--ISNULL('insured : ' + NULLIF(CONVERT(VARCHAR, ins.insured), '') + CHAR(13), '') +
		--ISNULL('limits : ' + NULLIF(CONVERT(VARCHAR, ins.limits), '') + CHAR(13), '') +
		--ISNULL('comments : ' + NULLIF(CONVERT(VARCHAR, ins.comments), '') + CHAR(13), '') +
		--ISNULL('Value Date: ' + NULLIF(CONVERT(VARCHAR, ud.Value_date, 101), '') + CHAR(13), '') +
		--ISNULL('Requested Limits: ' + NULLIF(CONVERT(VARCHAR, ud.Requested_Limits), '') + CHAR(13), '') +
		--ISNULL('Projected Settlement Date: ' + NULLIF(CONVERT(VARCHAR, ud.Projected_Settlement_Date, 101), '') + CHAR(13), '') +
		--ISNULL('Medpay: ' + NULLIF(CONVERT(VARCHAR, ud.Medpay), '') + CHAR(13), '') +
		--ISNULL('About Limits: ' + NULLIF(CONVERT(VARCHAR, ud.About_Limits), '') + CHAR(13), '') +
		--ISNULL('ERISA Lien: ' + NULLIF(CONVERT(VARCHAR, ud.ERISA_Lien), '') + CHAR(13), '') +
		--ISNULL('Subro Provider: ' + NULLIF(CONVERT(VARCHAR, ud.Subro_Provider), '') + CHAR(13), '') +
		--ISNULL('Nurse Cas Manager: ' + NULLIF(CONVERT(VARCHAR, ud.Nurse_Case_Manager), '') + CHAR(13), '') +
		--ISNULL('NCM: ' + NULLIF(CONVERT(VARCHAR, ud.NCM), '') + CHAR(13), '') +
		--ISNULL('Credit Attorney: ' + NULLIF(CONVERT(VARCHAR, ud.Credit_Date, 101), '') + CHAR(13), '') +
		--ISNULL('Credit Date: ' + NULLIF(CONVERT(VARCHAR, ud.NCM), '') + CHAR(13), '') +
		--ISNULL('Red Folder Research: ' + NULLIF(CONVERT(VARCHAR, ud.Red_Folder_Research), '') + CHAR(13), '') +
		--ISNULL('Is_there_a_John_Doe: ' + NULLIF(CONVERT(VARCHAR, ud.Is_there_a_John_Doe), '') + CHAR(13), '') +
		''						 as [incscomments],
		map.incninsured			 as [incninsured],
		ins.actual				 as [incncovgamt],
		null					 as [incndeductible],
		--lim.[high]				 as [incnuninspolicylimit],
		--lim.[low]				 as [incnunderpolicylimit],
				0						 as [incnuninspolicylimit],
		0						 as [incnunderpolicylimit],
		0						 as [incbpolicyterm],
		0						 as [incbtotcovg],
		'D'						 as [incsplaintiffordef],
		map.PlaintiffDefendantID as [incnplaintiffidordefendantid],
		null					 as [incntpadminorgid],
		null					 as [incntpadminaddid],
		null					 as [incntpadjcontactid],
		null					 as [incntpadjaddid],
		null					 as [incstpaclaimno],
		368						 as [incnrecuserid],
		GETDATE()				 as [incddtcreated],
		null					 as [incnmodifyuserid],
		null					 as [incddtmodified],
		null					 as [incnlevelno],
		null					 as [incnuninspolicylimitacc],
		null					 as [incnunderpolicylimitacc],
		0						 as [incb100per],
		null					 as [incnmvleased],
		null					 as [incnpriority],
		0						 as [incbdelete],
		0						 as [incnauthtodefcoun],
		null					 as [incnauthtodefcoundt],
		0						 as [incbprimary],
		ins.insurance_id		 as [saga]
	from KurtYoung_Needles.[dbo].[insurance_Indexed] ins
	left join KurtYoung_Needles.[dbo].[user_insurance_data] ud
		on ins.insurance_id = ud.insurance_id
	--LEFT JOIN InsuranceLimMap LIM on LIM.case_num = ins.case_num and LIM.insurer_ID = ins.insurer_id
	join conversion.insurance_contacts_helper map
		on ins.insurance_id = map.insurance_id
			and map.pord = 'D'
go

---
alter table [sma_TRN_InsuranceCoverage] enable trigger all
go

