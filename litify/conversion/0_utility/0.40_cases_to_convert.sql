/*
build a list of cases that are applicable for conversion based on client criteria
this list of cases is used to filter out contacts
*/

use ShinerSA
go

-- Drop table if it exists
IF OBJECT_ID('conversion.cases_to_convert', 'U') IS NOT NULL
    DROP TABLE conversion.cases_to_convert;
GO

-- Create table
CREATE TABLE conversion.cases_to_convert (
    matter_id                      VARCHAR(255) PRIMARY KEY, -- Store original Id from the Matter table
    Name                    VARCHAR(MAX) NULL,
    litify_pm__Case_Type__c VARCHAR(MAX) NULL,
    litify_pm__Client__c    VARCHAR(MAX) NULL,
    OwnerId                 VARCHAR(MAX) NULL,
    litify_pm__Status__c    VARCHAR(MAX) NULL
);

insert into conversion.cases_to_convert
	(
	matter_id, Name, litify_pm__Case_Type__c, litify_pm__Client__c, OwnerId, litify_pm__Status__c
	)
	select
		m.Id,
		m.Name,
		m.litify_pm__Case_Type__c,
		m.litify_pm__Client__c,
		m.OwnerId,
		m.litify_pm__Status__c
	from ShinerLitify..litify_pm__Matter__c m
	join CaseTypeMap mix
		on mix.LitifyCaseTypeID = m.litify_pm__Case_Type__c
	left join sma_MST_CaseType cst
		on cst.cstsType = mix.[SmartAdvocate Case Type]
			and VenderCaseType = (
				select
					VenderCaseType
				from conversion.office so
			)
	WHERE 
		/*
		- There are two close dates:
			- litify_pm__Close_Date__c
			- litify_pm__Closed_Date__c
		- Exclude cases where either close date is on or before 1/5/2023
		*/
    NOT (
        (m.litify_pm__Close_Date__c IS NOT NULL AND m.litify_pm__Close_Date__c <= '2023-01-05') 
        OR 
        (m.litify_pm__Closed_Date__c IS NOT NULL AND m.litify_pm__Closed_Date__c <= '2023-01-05')
    )
    -- Exclude cases where both close dates are NULL AND the status is 'Closed'
    AND NOT (
        m.litify_pm__Close_Date__c IS NULL 
        AND m.litify_pm__Closed_Date__c IS NULL
        AND m.litify_pm__Status__c = 'Closed'
    );



