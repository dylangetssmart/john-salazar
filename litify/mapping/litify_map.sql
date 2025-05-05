-- Case Types
SELECT ct.name AS case_type_name, COUNT(m.Id) AS case_count
FROM litify_pm__Case_Type__c ct
LEFT JOIN litify_pm__Matter__c m
ON m.litify_pm__Case_Type__c = ct.Id
GROUP BY ct.name
ORDER BY case_count DESC;

-- Contact Types
SELECT
	a.Type
   ,COUNT(*) AS Count
FROM ShinerLitify..Account a
GROUP BY a.Type
ORDER BY Count DESC;

-- Party Roles
SELECT
	lprc.litify_pm__Role__c
   ,COUNT(*) AS Count
FROM ShinerLitify..litify_pm__Role__c lprc
GROUP BY lprc.litify_pm__Role__c
ORDER BY Count DESC;

-- Insurance Types
SELECT
	lpic.litify_pm__Insurance_Type__c
   ,COUNT(*) AS Count
FROM ShinerLitify..litify_pm__Insurance__c lpic
GROUP BY lpic.litify_pm__Insurance_Type__c
ORDER BY Count DESC;

-- Referral Sources
SELECT
	lpsc.litify_tso_Source_Type_Name__c
   ,COUNT(*) AS Count
FROM ShinerLitify..litify_pm__Source__c lpsc
GROUP BY lpsc.litify_tso_Source_Type_Name__c
ORDER BY Count DESC;

-- Damage Types
SELECT
	lpdc.litify_pm__Type__c
   ,COUNT(*) AS Count
FROM ShinerLitify..litify_pm__Damage__c lpdc
GROUP BY lpdc.litify_pm__Type__c
ORDER BY Count DESC;

-- Request Types
SELECT
	lprc.litify_pm__Request_Type__c
   ,COUNT(*) AS Count
FROM ShinerLitify..litify_pm__Request__c lprc
GROUP BY lprc.litify_pm__Request_Type__c
ORDER BY Count DESC;