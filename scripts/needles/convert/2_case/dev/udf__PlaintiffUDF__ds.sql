IF EXISTS (
	SELECT 1
	FROM sys.tables
	WHERE name = 'PlaintiffUDF__user_party'
		AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
	DROP TABLE dbo.PlaintiffUDF__user_party;
END;

-- Create table to hold applicable fields
DECLARE @fields TABLE (column_name VARCHAR(100));

-- Paste column_name values from mapping Excel sheet
INSERT INTO @fields (column_name)
VALUES
	('Ambulance'),
	('Broken_BonesFractures'),
	('BruisingLacerations'),
	('Children'),
	('Chiro'),
	('Client_highly_satisfied'),
	('Contact_Name'),
	('Contact_Phone_Number'),
	('Dates_of_Employment'),
	('DL__ID_#'),
	('Employer_Name'),
	('ER'),
	('Facebook_Page'),
	('Family_Dr'),
	('Gap_in_Treatment'),
	('Head_Injury'),
	('HIPAA_Form_Signed'),
	('Hospital_Admission_DOI'),
	('Hospital_Name'),
	('Injured_Person_is_Their'),
	('Injuries'),
	('Job_Description'),
	('Loss_of__Consciousness'),
	('Lost_income'),
	('Marital_Status'),
	('NamePhoneRelationship'),
	('NamePhoneRelationship_2'),
	('NeckBack'),
	('Other_Employment'),
	('Party_Notes'),
	('Pay_Period'),
	('Phys_Therapy'),
	('Prior_Medical_History'),
	('Rate_of_Pay'),
	('Reason_for_Gap'),
	('Relationship_of_Contact'),
	('Send_Ltrs_in_Spanish'),
	('Send_Mail_To'),
	('Service_Received_at_Hosp'),
	('Specialist'),
	('Spouse'),
	('Supervisor__Manager_Name'),
	('Surgery'),
	('Time_Out_of_Work'),
	('Trtmt_Since_Accident'),
	('Twitter_Page');

-- Build dynamic SQL
DECLARE @sql NVARCHAR(MAX) = '';
DECLARE @selectList NVARCHAR(MAX) = '';
DECLARE @unpivotList NVARCHAR(MAX) = '';

-- Loop over @fields to build select and unpivot sections
SELECT
	@selectList += CONCAT('        CONVERT(VARCHAR(MAX), ud.', QUOTENAME(column_name), ') AS ', QUOTENAME(column_name), ',', CHAR(13)),
	@unpivotList += CONCAT(QUOTENAME(column_name), ',', CHAR(13))
FROM @fields;

-- Trim trailing commas
SET @selectList = LEFT(@selectList, LEN(@selectList) - 2);
SET @unpivotList = LEFT(@unpivotList, LEN(@unpivotList) - 2);

-- Final dynamic SQL
SET @sql = '
SELECT
    casnCaseID,
    casnOrgCaseTypeID,
    FieldTitle,
    FieldVal
INTO dbo.PlaintiffUDF__user_party
FROM (
    SELECT
        cas.casnCaseID,
        cas.casnOrgCaseTypeID,
' + @selectList + '
    FROM [JohnSalazar_Needles]..user_case_data ud
    JOIN sma_TRN_Cases cas ON cas.cassCaseNumber = CONVERT(VARCHAR, ud.casenum)
) pv
UNPIVOT (
    FieldVal FOR FieldTitle IN (
' + @unpivotList + '
    )
) AS unpvt;
';

-- Optional: print for debugging or uncomment to run
-- PRINT @sql;
EXEC sp_executesql @sql;
