------------------------------------------------------------------------------------------------------------------------------------------------
select stc.casnCaseID, saga_char FROM sma_TRN_Cases stc where stc.cassCaseNumber = 'MAT-24101529250'
-- 1408
-- a0LNt00000LpydxMAB

select
	stic.incnCaseID,
	stic.incnUnderPolicyLimit,
	stic.incnUnderPolicyLimitAcc,
	stic.incnUnInsPolicyLimit,
	stic.incnUnInsPolicyLimitAcc,
	stic.saga_char
FROM sma_TRN_InsuranceCoverage stic
where stic.incnCaseID = 1408

SELECT i.id, i.litify_pm__Coverages__c, i.litify_pm__Per_Incident__c, i.XPOLICIYLIMIT__c
FROM ShinerLitify..litify_pm__Insurance__c i
where i.litify_pm__Matter__c = 'a0LNt00000LpydxMAB'

-- per incident			->	 [incnUnderPolicyLimitAcc]
-- XPOLICIYLIMIT__c		->	 [incnUnderPolicyLimit]

select top 10
	stic.incnCaseID,
	stic.incnUnderPolicyLimit,
	stic.incnUnderPolicyLimitAcc,
	stic.incnUnInsPolicyLimit,
	stic.incnUnInsPolicyLimitAcc,
	stic.saga_char
FROM sma_TRN_InsuranceCoverage stic
--incnCaseID	incnUnderPolicyLimit	incnUnderPolicyLimitAcc		incnUnInsPolicyLimit	incnUnInsPolicyLimitAcc		saga_char
--11			NULL					NULL						15000.00				15000.00					a0kNt00000YLcxVIAT
--23			NULL					NULL						NULL					NULL						a0k8Z00000CHThWQAX
--34			NULL					NULL						NULL					NULL						a0k8Z00000CHTdZQAX
--34			NULL					NULL						NULL					NULL						a0k8Z00000JA3dZQAT
--38			NULL					NULL						NULL					100000.00					a0k8Z00000CHTaqQAH
--60			NULL					NULL						NULL					NULL						a0k8Z00000CHTPzQAP
--95			NULL					NULL						10000.00				10000.00					a0k8Z00000CHTERQA5
--95			20000.00				10000.00					NULL					NULL						a0k8Z00000CHTEPQA5
--114			NULL					NULL						NULL					0.00						a0k8Z00000CHT9nQAH
--120			NULL					NULL						NULL					NULL						a0k8Z00000HgY6EQAV

UPDATE sma_TRN_InsuranceCoverage
set incnUnderPolicyLimit = incnUnderPolicyLimitAcc,
	incnUnderPolicyLimitAcc = incnUnderPolicyLimit,
	incnUnInsPolicyLimit = incnUnInsPolicyLimitAcc,
	incnUnInsPolicyLimitAcc = incnUnInsPolicyLimit

select top 10
	stic.incnCaseID,
	stic.incnUnderPolicyLimit,
	stic.incnUnderPolicyLimitAcc,
	stic.incnUnInsPolicyLimit,
	stic.incnUnInsPolicyLimitAcc,
	stic.saga_char
FROM sma_TRN_InsuranceCoverage stic
--incnCaseID	incnUnderPolicyLimit	incnUnderPolicyLimitAcc		incnUnInsPolicyLimit	incnUnInsPolicyLimitAcc		saga_char
--11			NULL					NULL						15000.00				15000.00					a0kNt00000YLcxVIAT
--23			NULL					NULL						NULL					NULL						a0k8Z00000CHThWQAX
--34			NULL					NULL						NULL					NULL						a0k8Z00000CHTdZQAX
--34			NULL					NULL						NULL					NULL						a0k8Z00000JA3dZQAT
--38			NULL					NULL						100000.00				NULL						a0k8Z00000CHTaqQAH
--60			NULL					NULL						NULL					NULL						a0k8Z00000CHTPzQAP
--95			NULL					NULL						10000.00				10000.00					a0k8Z00000CHTERQA5
--95			10000.00				20000.00					NULL					NULL						a0k8Z00000CHTEPQA5
--114			NULL					NULL						0.00					NULL						a0k8Z00000CHT9nQAH
--120			NULL					NULL						NULL					NULL						a0k8Z00000HgY6EQAV