USE KurtYoung_SA
GO

/* ##############################################
Store applicable value codes
*/
CREATE TABLE #LienValueCodes (
	code VARCHAR(10)
);

INSERT INTO #LienValueCodes
	(
	code
	)
VALUES (
'LIE'
);

-- ds 2024-11-07 updated value codes
--('WC'), ('LIE');



/*
alter table [KurtYoung_Needles].[dbo].[sma_TRN_Lienors] disable trigger all
delete from [KurtYoung_Needles].[dbo].[sma_TRN_Lienors] 
DBCC CHECKIDENT ('[KurtYoung_Needles].[dbo].[sma_TRN_Lienors]', RESEED, 0);
alter table [KurtYoung_Needles].[dbo].[sma_TRN_Lienors] enable trigger all

alter table [KurtYoung_Needles].[dbo].[sma_TRN_LienDetails] disable trigger all
delete from [KurtYoung_Needles].[dbo].[sma_TRN_LienDetails] 
DBCC CHECKIDENT ('[KurtYoung_Needles].[dbo].[sma_TRN_LienDetails]', RESEED, 0);
alter table [KurtYoung_Needles].[dbo].[sma_TRN_LienDetails] enable trigger all


alter table [KurtYoung_Needles].[dbo].[sma_TRN_Lienors] disable trigger all

alter table [KurtYoung_Needles].[dbo].[sma_TRN_LienDetails] disable trigger all


select count(*) from [KurtYoung_Needles].[dbo].[sma_TRN_Lienors]

select * from value_tab_Liencheckbox_Helper 

select * from [KurtYoung_Needles].[dbo].[value_payment] where value_id=65990

*/



---(0)---
IF NOT EXISTS (
		SELECT
			*
		FROM sys.COLUMNS
		WHERE Name = N'saga'
			AND object_id = OBJECT_ID(N'sma_TRN_Lienors')
	)
BEGIN
	ALTER TABLE [sma_TRN_Lienors] ADD [saga] INT NULL;
END

---(0)---
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE name = 'value_tab_Liencheckbox_Helper'
			AND TYPE = 'U'
	)
BEGIN
	DROP TABLE value_tab_Liencheckbox_Helper
END
GO

---(0)---
CREATE TABLE value_tab_Liencheckbox_Helper (
	TableIndex INT IDENTITY (1, 1) NOT NULL
   ,value_id INT
   ,CONSTRAINT IOC_Clustered_Index_value_tab_Liencheckbox_Helper PRIMARY KEY CLUSTERED (TableIndex)
) ON [PRIMARY]
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Liencheckbox_Helper_value_id ON [KurtYoung_SA].[dbo].[value_tab_Liencheckbox_Helper] (value_id);
GO

---(0)---
INSERT INTO value_tab_Liencheckbox_Helper
	(
	value_id
	)
	SELECT
		VP1.value_id
	FROM [KurtYoung_Needles].[dbo].[value_payment] VP1
	LEFT JOIN (
		SELECT DISTINCT
			value_id
		FROM [KurtYoung_Needles].[dbo].[value_payment]
		WHERE lien = 'Y'
	) VP2
		ON VP1.value_id = VP2.value_id
			AND VP2.value_id IS NOT NULL
	WHERE VP2.value_id IS NOT NULL -- ( Lien checkbox got marked ) 
GO

---(0)---
DBCC DBREINDEX ('value_tab_Liencheckbox_Helper', ' ', 90) WITH NO_INFOMSGS
GO


---(0)---
INSERT INTO [KurtYoung_SA].[dbo].[sma_MST_LienType]
	(
	[lntsCode]
   ,[lntsDscrptn]
	)
	(
	SELECT DISTINCT
		'CONVERSION'
	   ,VC.[description]
	FROM [KurtYoung_Needles].[dbo].[value] V
	INNER JOIN [KurtYoung_Needles].[dbo].[value_code] VC
		ON VC.code = V.code
	WHERE ISNULL(V.code, '') IN (
			SELECT
				code
			FROM #LienValueCodes
		)
	)
	EXCEPT
	SELECT
		[lntsCode]
	   ,[lntsDscrptn]
	FROM [KurtYoung_SA].[dbo].[sma_MST_LienType]
GO


---(0)---
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE name = 'value_tab_Lien_Helper'
			AND TYPE = 'U'
	)
BEGIN
	DROP TABLE value_tab_Lien_Helper
END
GO

---(0)---
CREATE TABLE value_tab_Lien_Helper (
	TableIndex [INT] IDENTITY (1, 1) NOT NULL
   ,case_id INT
   ,value_id INT
   ,ProviderNameId INT
   ,ProviderName VARCHAR(200)
   ,ProviderCID INT
   ,ProviderCTG INT
   ,ProviderAID INT
   ,casnCaseID INT
   ,PlaintiffID INT
   ,Paid VARCHAR(20)
   ,CONSTRAINT IOC_Clustered_Index_value_tab_Lien_Helper PRIMARY KEY CLUSTERED (TableIndex)
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Lien_Helper_case_id ON [KurtYoung_SA].[dbo].[value_tab_Lien_Helper] (case_id);
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Lien_Helper_value_id ON [KurtYoung_SA].[dbo].[value_tab_Lien_Helper] (value_id);
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Lien_Helper_ProviderNameId ON [KurtYoung_SA].[dbo].[value_tab_Lien_Helper] (ProviderNameId);
GO

---(0)---
INSERT INTO value_tab_Lien_Helper
	(
	case_id
   ,value_id
   ,ProviderNameId
   ,ProviderName
   ,ProviderCID
   ,ProviderCTG
   ,ProviderAID
   ,casnCaseID
   ,PlaintiffID
   ,Paid
	)
	SELECT
		V.case_id	   AS case_id
	   ,	-- needles case
		V.value_id	   AS tab_id
	   ,		-- needles records TAB item
		V.provider	   AS ProviderNameId
	   ,IOC.Name	   AS ProviderName
	   ,IOC.CID		   AS ProviderCID
	   ,IOC.CTG		   AS ProviderCTG
	   ,IOC.AID		   AS ProviderAID
	   ,CAS.casnCaseID AS casnCaseID
	   ,NULL		   AS PlaintiffID
	   ,NULL		   AS Paid
	FROM [KurtYoung_Needles].[dbo].[value_Indexed] V
	INNER JOIN [KurtYoung_SA].[dbo].[sma_TRN_cases] CAS
		ON CAS.cassCaseNumber = V.case_id
	INNER JOIN [KurtYoung_SA].[dbo].[IndvOrgContacts_Indexed] IOC
		ON IOC.SAGA = V.provider
			AND ISNULL(V.provider, 0) <> 0
	WHERE code IN (
			SELECT
				code
			FROM #LienValueCodes
		)
		OR V.value_id IN (
			SELECT
				value_id
			FROM value_tab_Liencheckbox_Helper
		)

GO
---(0)---
DBCC DBREINDEX ('value_tab_Lien_Helper', ' ', 90) WITH NO_INFOMSGS
GO



---(0)---
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE Name = 'value_tab_Multi_Party_Helper_Temp'
	)
BEGIN
	DROP TABLE value_tab_Multi_Party_Helper_Temp
END
GO

SELECT
	V.case_id  AS cid
   ,V.value_id AS vid
   ,CONVERT(VARCHAR, ((
		SELECT
			SUM(payment_amount)
		FROM [KurtYoung_Needles].[dbo].[value_payment]
		WHERE value_id = V.value_id
	)
	)
	)		   AS Paid
   ,T.plnnPlaintiffID INTO value_tab_Multi_Party_Helper_Temp
FROM [KurtYoung_Needles].[dbo].[value_Indexed] V
INNER JOIN [KurtYoung_SA].[dbo].[sma_TRN_cases] CAS
	ON CAS.cassCaseNumber = V.case_id
INNER JOIN [KurtYoung_SA].[dbo].[IndvOrgContacts_Indexed] IOC
	ON IOC.SAGA = V.party_id
INNER JOIN [KurtYoung_SA].[dbo].[sma_TRN_Plaintiff] T
	ON T.plnnContactID = IOC.cid
		AND T.plnnContactCtg = IOC.CTG
		AND T.plnnCaseID = CAS.casnCaseID
GO


UPDATE value_tab_Lien_Helper
SET PlaintiffID = A.plnnPlaintiffID
   ,Paid = A.Paid
FROM value_tab_Multi_Party_Helper_Temp A
WHERE case_id = A.cid
AND value_id = A.vid
GO


IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE Name = 'value_tab_Multi_Party_Helper_Temp'
	)
BEGIN
	DROP TABLE value_tab_Multi_Party_Helper_Temp
END
GO

SELECT
	V.case_id  AS cid
   ,V.value_id AS vid
   ,CONVERT(VARCHAR, ((
		SELECT
			SUM(payment_amount)
		FROM [KurtYoung_Needles].[dbo].[value_payment]
		WHERE value_id = V.value_id
	)
	)
	)		   AS Paid
   ,(
		SELECT
			plnnPlaintiffID
		FROM [KurtYoung_SA].[dbo].[sma_TRN_Plaintiff]
		WHERE plnnCaseID = CAS.casnCaseID
			AND plnbIsPrimary = 1
	)		   
	AS plnnPlaintiffID INTO value_tab_Multi_Party_Helper_Temp
FROM [KurtYoung_Needles].[dbo].[value_Indexed] V
INNER JOIN [KurtYoung_SA].[dbo].[sma_TRN_cases] CAS
	ON CAS.cassCaseNumber = V.case_id
INNER JOIN [KurtYoung_SA].[dbo].[IndvOrgContacts_Indexed] IOC
	ON IOC.SAGA = V.party_id
INNER JOIN [KurtYoung_SA].[dbo].[sma_TRN_Defendants] D
	ON D.defnContactID = IOC.cid
		AND D.defnContactCtgID = IOC.CTG
		AND D.defnCaseID = CAS.casnCaseID
GO


UPDATE value_tab_Lien_Helper
SET PlaintiffID = A.plnnPlaintiffID
   ,Paid = A.Paid
FROM value_tab_Multi_Party_Helper_Temp A
WHERE case_id = A.cid
AND value_id = A.vid
GO


---------------------------------------------------------------------------------------
ALTER TABLE [KurtYoung_SA].[dbo].[sma_TRN_Lienors] DISABLE TRIGGER ALL
ALTER TABLE [KurtYoung_SA].[dbo].[sma_TRN_LienDetails] DISABLE TRIGGER ALL

GO
---(1)---
INSERT INTO [dbo].[sma_TRN_Lienors]
	(
	[lnrnCaseID]
   ,[lnrnLienorTypeID]
   ,[lnrnLienorContactCtgID]
   ,[lnrnLienorContactID]
   ,[lnrnLienorAddressID]
   ,[lnrnLienorRelaContactID]
   ,[lnrnPlaintiffID]
   ,[lnrnCnfrmdLienAmount]
   ,[lnrnNegLienAmount]
   ,[lnrsComments]
   ,[lnrnRecUserID]
   ,[lnrdDtCreated]
   ,[lnrnFinal]
   ,[saga]
	)

	SELECT
		MAP.casnCaseID			 AS [lnrnCaseID]
	   ,(
			SELECT TOP 1
				lntnLienTypeID
			FROM [KurtYoung_SA].[dbo].[sma_MST_LienType]
			WHERE lntsDscrptn = (
					SELECT TOP 1
						[description]
					FROM [KurtYoung_Needles].[dbo].[value_code]
					WHERE [code] = V.code
				)
		)						 
		AS [lnrnLienorTypeID]
	   ,MAP.ProviderCTG			 AS [lnrnLienorContactCtgID]
	   ,MAP.ProviderCID			 AS [lnrnLienorContactID]
	   ,MAP.ProviderAID			 AS [lnrnLienorAddressID]
	   ,0						 AS [lnrnLienorRelaContactID]
	   ,MAP.PlaintiffID			 AS [lnrnPlaintiffID]
	   ,ISNULL(V.total_value, 0) AS [lnrnCnfrmdLienAmount]
	   ,ISNULL(V.due, 0)		 AS [lnrnNegLienAmount]
	   ,ISNULL('Memo : ' + ISNULL(V.memo, '') + CHAR(13), '') +
		ISNULL('From : ' + CONVERT(VARCHAR(10), V.start_date) + CHAR(13), '') +
		ISNULL('To : ' + CONVERT(VARCHAR(10), V.stop_date) + CHAR(13), '') +
		ISNULL('Value Total : ' + CONVERT(VARCHAR, V.total_value) + CHAR(13), '') +
		ISNULL('Reduction : ' + CONVERT(VARCHAR, V.reduction) + CHAR(13), '') +
		ISNULL('Paid : ' + MAP.Paid, '')
		AS [lnrsComments]
	   ,368						 AS [lnrnRecUserID]
	   ,GETDATE()				 AS [lnrdDtCreated]
	   ,0						 AS [lnrnFinal]
	   ,V.value_id				 AS [saga]
	FROM [KurtYoung_Needles].[dbo].[value_Indexed] V
	INNER JOIN [KurtYoung_SA].[dbo].[value_tab_Lien_Helper] MAP
		ON MAP.case_id = V.case_id
			AND MAP.value_id = V.value_id

---(2)---
INSERT INTO [dbo].[sma_TRN_LienDetails]
	(
	lndnLienorID
   ,lndnLienTypeID
   ,lndnCnfrmdLienAmount
   ,lndsRefTable
   ,lndnRecUserID
   ,lnddDtCreated
	)
	SELECT
		lnrnLienorID		 AS lndnLienorID
	   , --> same as lndnRecordID
		lnrnLienorTypeID	 AS lndnLienTypeID
	   ,lnrnCnfrmdLienAmount AS lndnCnfrmdLienAmount
	   ,'sma_TRN_Lienors'	 AS lndsRefTable
	   ,368					 AS lndnRecUserID
	   ,GETDATE()			 AS lnddDtCreated
	FROM [KurtYoung_SA].[dbo].[sma_TRN_Lienors]


----
ALTER TABLE [KurtYoung_SA].[dbo].[sma_TRN_Lienors] ENABLE TRIGGER ALL
ALTER TABLE [KurtYoung_SA].[dbo].[sma_TRN_LienDetails] ENABLE TRIGGER ALL

GO





