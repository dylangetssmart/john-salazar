use [SA]
go

/* ------------------------------------------------------------------------------
Insert expected [sma_MST_UDFPossibleValues]
*/ ------------------------------------------------------------------------------

-- CheckBox
insert into sma_MST_UDFPossibleValues
	(
		UDFDefinitionId,
		PossibleValue
	)
	select
		d.udfnUDFId,
		v.PossibleValue
	from sma_MST_UDFDefinition d
	cross join (
	values
		('checked'),
		('unchecked')
	) v (PossibleValue)
	where
		d.udfsType = 'CheckBox'

	EXCEPT

	SELECT 
	    UDFDefinitionId, 
	    PossibleValue
	FROM sma_MST_UDFPossibleValues;

-- YesNoRadioButton
insert into sma_MST_UDFPossibleValues
	(
		UDFDefinitionId,
		PossibleValue
	)
	select
		d.udfnUDFId,
		v.PossibleValue
	from sma_MST_UDFDefinition d
	cross join (
	values
		('Yes'),
		('No'),
		('Unknown'),
		('N/A')
	) v (PossibleValue)
	where
		d.udfsType = 'YesNoRadioButton'

	EXCEPT

	SELECT 
	    UDFDefinitionId, 
	    PossibleValue
	FROM sma_MST_UDFPossibleValues;


/* ------------------------------------------------------------------------------
Convert invalid UDFValues into expected formats
*/ ------------------------------------------------------------------------------

-- Date: expected MM/DD/YYYY
update v
set v.udvsUDFValue = CONVERT(VARCHAR(10), TRY_CONVERT(DATE, v.udvsUDFValue), 101)
from sma_TRN_UDFValues v
join sma_MST_UDFDefinition d
	on v.udvnUDFID = d.udfnUDFID
where d.udfsType = 'Date'
and TRY_CONVERT(DATE, v.udvsUDFValue) is not null;

-- Time: expected '1:00 PM'
UPDATE v
SET v.udvsUDFValue =
    REPLACE(
        REPLACE(
            LTRIM(RIGHT(CONVERT(VARCHAR(20),
                                TRY_CONVERT(TIME, v.udvsUDFValue),
                                100), 7)),
            'AM', ' AM'
        ),
        'PM', ' PM'
    )
FROM sma_TRN_UDFValues v
JOIN sma_MST_UDFDefinition d
    ON v.udvnUDFID = d.udfnUDFID
WHERE d.udfsType = 'Time'
  AND TRY_CONVERT(TIME, v.udvsUDFValue) IS NOT NULL;

-- CheckBox: expected 1/0
update v
set v.udvsUDFValue =
case
	when UPPER(LTRIM(RTRIM(v.udvsUDFValue))) in ('1', 'Y', 'YES', 'TRUE', 'T') then '1'
	when UPPER(LTRIM(RTRIM(v.udvsUDFValue))) in ('0', 'N', 'NO', 'FALSE', 'F', '') then '0'
	else v.udvsUDFValue
end
from sma_TRN_UDFValues v
join sma_MST_UDFDefinition d
	on v.udvnUDFID = d.udfnUDFID
where d.udfsType = 'CheckBox'
and v.udvsUDFValue is not null;