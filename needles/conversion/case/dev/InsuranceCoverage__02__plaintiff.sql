/* ###################################################################################
description: Insert defendants
steps:
	- Insert plantiff insurance > [sma_TRN_InsuranceCoverage]
	
usage_instructions:
	- 
dependencies:
	- [conversion].[insurance_contacts_helper]
notes:
	-
*/

use [[JohnSalazar_SA]]
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
	select
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
		null					 as [incnstackedtimes]
		--  ,ISNULL('accept: ' + NULLIF(CONVERT(VARCHAR, INS.accept), '') + CHAR(13), '') +
		--ISNULL('actual: ' + NULLIF(CONVERT(VARCHAR, INS.actual), '') + CHAR(13), '') +
		--ISNULL('agent: ' + NULLIF(CONVERT(VARCHAR, INS.agent), '') + CHAR(13), '') +
		--ISNULL('date_settled: ' + NULLIF(CONVERT(VARCHAR, INS.date_settled), '') + CHAR(13), '') +
		--ISNULL('how_settled: ' + NULLIF(CONVERT(VARCHAR, INS.how_settled), '') + CHAR(13), '') +
		--ISNULL('maximum_amount: ' + NULLIF(CONVERT(VARCHAR, INS.maximum_amount), '') + CHAR(13), '') +
		--ISNULL('minimum_amount: ' + NULLIF(CONVERT(VARCHAR, INS.minimum_amount), '') + CHAR(13), '') +
		--ISNULL('policy: ' + NULLIF(CONVERT(VARCHAR, INS.policy), '') + CHAR(13), '') +
		--ISNULL('claim: ' + NULLIF(CONVERT(VARCHAR, INS.claim), '') + CHAR(13), '') +
		--ISNULL('insured: ' + NULLIF(CONVERT(VARCHAR, INS.insured), '') + CHAR(13), '') +
		--ISNULL('limits: ' + NULLIF(CONVERT(VARCHAR, INS.limits), '') + CHAR(13), '') +
		--ISNULL('comments : ' + NULLIF(CONVERT(VARCHAR, INS.comments), '') + CHAR(13), '') +
		--ISNULL('Value Date: ' + NULLIF(CONVERT(VARCHAR, Ud.Value_date, 101), '') + CHAR(13), '') +
		--ISNULL('Requested Limits: ' + NULLIF(CONVERT(VARCHAR, Ud.Requested_Limits), '') + CHAR(13), '') +
		--ISNULL('Projected Settlement Date: ' + NULLIF(CONVERT(VARCHAR, Ud.Projected_Settlement_Date, 101), '') + CHAR(13), '') +
		--ISNULL('Medpay: ' + NULLIF(CONVERT(VARCHAR, ud.Medpay), '') + CHAR(13), '') +
		--ISNULL('About Limits: ' + NULLIF(CONVERT(VARCHAR, Ud.About_Limits), '') + CHAR(13), '') +
		--ISNULL('ERISA Lien: ' + NULLIF(CONVERT(VARCHAR, Ud.ERISA_Lien), '') + CHAR(13), '') +
		--ISNULL('Subro Provider: ' + NULLIF(CONVERT(VARCHAR, Ud.Subro_Provider), '') + CHAR(13), '') +
		--ISNULL('Nurse Case Manager: ' + NULLIF(CONVERT(VARCHAR, Ud.Nurse_Case_Manager), '') + CHAR(13), '') +
		--ISNULL('NCM: ' + NULLIF(CONVERT(VARCHAR, Ud.NCM), '') + CHAR(13), '') +
		--ISNULL('Credit Attorney: ' + NULLIF(CONVERT(VARCHAR, Ud.Credit_Date, 101), '') + CHAR(13), '') +
		--ISNULL('Credit Date: ' + NULLIF(CONVERT(VARCHAR, Ud.NCM), '') + CHAR(13), '') +
		--ISNULL('Red Folder Research: ' + NULLIF(CONVERT(VARCHAR, Ud.Red_Folder_Research), '') + CHAR(13), '') +
		--ISNULL('Is_there_a_John_Doe: ' + NULLIF(CONVERT(VARCHAR, Ud.Is_there_a_John_Doe), '') + CHAR(13), '') +
		,
		''						 as [incscomments],
		map.incninsured			 as [incninsured],
		ins.actual				 as [incncovgamt],
		null					 as [incndeductible],
		--lim.[high]						as [incnUnInsPolicyLimit],
		--lim.[low]						as [incnUnderPolicyLimit],
		0						 as [incnuninspolicylimit],
		0						 as [incnunderpolicylimit],
		0						 as [incbpolicyterm],
		0						 as [incbtotcovg],
		'P'						 as [incsplaintiffordef],
		--    ( select plnnPlaintiffID from sma_TRN_Plaintiff where plnnCaseID=MAP.caseID and plnbIsPrimary=1 )  
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
	--select *
	from [JohnSalazar_Needles].[dbo].[insurance_Indexed] ins
	left join [JohnSalazar_Needles].[dbo].[user_insurance_data] ud
		on ins.insurance_id = ud.insurance_id
	--LEFT JOIN InsuranceLimMap LIM on LIM.case_num = ins.case_num and LIM.insurer_ID = ins.insurer_id
	join conversion.insurance_contacts_helper map
		on ins.insurance_id = map.insurance_id
			and map.pord = 'P'
go

--
alter table [sma_TRN_InsuranceCoverage] enable trigger all
go