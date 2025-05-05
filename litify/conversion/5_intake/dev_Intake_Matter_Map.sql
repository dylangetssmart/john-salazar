select DISTINCT ID as LitifyIntakeID, litify_pm__Matter__c LitifyMatterID, cas.casnCaseID, cas.cassCaseNumber, cas.cassCaseName
From ShinerLitify..litify_pm__Intake__c
JOIN sma_trn_cases cas on cas.saga_char = litify_pm__Matter__c



select *
from sma_trn_cases 
where litify_Saga= 'a0L4z00000J9lEnEAJ'


SELECT * FROM ShinerLitify..litify_pm__Intake__c lpic

SELECT count(*) FROM ShinerLitify..litify_pm__Intake__c lpic
-- 14,930

-- linked to cases
select 
	ID					 as LitifyIntakeID,
	litify_pm__Matter__c LitifyMatterID,
	cas.casnCaseID,
	cas.cassCaseNumber,
	cas.cassCaseName
from ShinerLitify..litify_pm__Intake__c
join sma_trn_cases cas
	on cas.saga_char = litify_pm__Matter__c
-- 1,671

-- not linked to cases
select distinct
	ID					 as LitifyIntakeID,
	litify_pm__Matter__c LitifyMatterID,
	cas.casnCaseID,
	cas.cassCaseNumber,
	cas.cassCaseName
from ShinerLitify..litify_pm__Intake__c
LEFT join sma_trn_cases cas
	on cas.saga_char = litify_pm__Matter__c
	where cas.casnCaseID is null
-- 13,259

-- IsConvert is not reliable
SELECT id, lpic.litify_pm__IsConverted__c, lpic.litify_pm__Status__c, lpic.litify_pm__Matter_Created_Date__c, lpic.litify_pm__Matter__c
FROM ShinerLitify..litify_pm__Intake__c lpic
where lpic.litify_pm__IsConverted__c = 0

-- id					litify_pm__IsConverted__c	litify_pm__Status__c	litify_pm__Matter_Created_Date__c	litify_pm__Matter__c
-- a0C8Z00000daPptUAE	0							Converted				2023-01-13 00:00:00					a0L8Z00000fKLrhUAG

SELECT id, lpic.litify_pm__IsConverted__c, lpic.litify_pm__Status__c, lpic.litify_pm__Matter_Created_Date__c, lpic.litify_pm__Matter__c
FROM ShinerLitify..litify_pm__Intake__c lpic
where lpic.litify_pm__Matter__c is null

