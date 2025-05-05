USE ShinerSA
GO

-- saga (INT)
-- Check if the column 'saga' exists and if it's not of type INT, change its type
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and object_id = OBJECT_ID(N'sma_TRN_InsuranceCoverage')
	)
begin
	-- Add the 'saga' column if it does not exist
	alter table [sma_TRN_InsuranceCoverage] add [saga] INT null;
end
go

-- saga_char
-- this should be source_id, but many scripts already use `saga_char`
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_TRN_InsuranceCoverage')
	)
begin
	alter table [sma_TRN_InsuranceCoverage] add [saga_char] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and object_id = OBJECT_ID(N'sma_TRN_InsuranceCoverage')
	)
begin
	alter table [sma_TRN_InsuranceCoverage] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and object_id = OBJECT_ID(N'sma_TRN_InsuranceCoverage')
	)
begin
	alter table [sma_TRN_InsuranceCoverage] add [source_ref] VARCHAR(MAX) null;
end
go

----------------------------
--INSURANCE TYPE
----------------------------
INSERT INTO [sma_MST_InsuranceType]
	(
	intsDscrptn
	)
	SELECT
		'Unspecified'
	UNION
	-- Adding the specific insurance types from the table
	SELECT
		'Health Insurance'
	UNION
	SELECT
		'Medicare'
	UNION
	SELECT
		'Medicaid'
	UNION
	SELECT
		'Preferred Provider Organization'
	UNION
	SELECT
		'Health Maintenance Organization'
	UNION
	SELECT
		'Liability'
	union
	
	-- Adding any other distinct insurance types not present in the table
	SELECT DISTINCT
		litify_pm__Insurance_Type__c
	FROM [ShinerLitify]..litify_pm__Insurance__c i
	WHERE ISNULL(litify_pm__Insurance_Type__c, '') <> ''

	union

	-- Adding "coverages"
	SELECT DISTINCT
		i.litify_pm__Coverages__c
	FROM [ShinerLitify]..litify_pm__Insurance__c i
	where ISNULL(i.litify_pm__Coverages__c, '') <> ''

	EXCEPT
	-- Exclude insurance types that are already in the sma_MST_InsuranceType table
	SELECT
		intsDscrptn
	FROM [sma_MST_InsuranceType]
GO


--SELECT * FROM sma_MST_InsuranceType smit