USE ShinerSA
GO

-----------------------------------------
---(1)--- PHONE NUMBER UNIQUENESS
-----------------------------------------
UPDATE [dbo].[sma_MST_ContactNumbers]
SET cnnbPrimary = 0
WHERE cnnnContactCtgID = 1

UPDATE [dbo].[sma_MST_ContactNumbers]
SET cnnbPrimary = 0
WHERE cnnnContactCtgID = 2


---(Note: If cell phone exists, set the first cell phone primary or the only one. )
UPDATE [dbo].[sma_MST_ContactNumbers]
SET cnnbPrimary =
CASE
	WHEN A.RowNumber = 1
		THEN 1
	ELSE 0
END
FROM (
	SELECT
		ROW_NUMBER() OVER (PARTITION BY cnnnContactID ORDER BY cnnnContactNumberID ASC) AS RowNumber
	   ,cnnnContactNumberID AS ContactNumberID
	FROM [dbo].[sma_MST_ContactNumbers] CN
	JOIN [dbo].[sma_MST_ContactNoType] CT
		ON CT.ctynContactNoTypeID = CN.cnnnPhoneTypeID
	WHERE ctysDscrptn = 'Work Phone'
		AND ctynContactCategoryID = 1
) A
WHERE A.ContactNumberID = cnnnContactNumberID


UPDATE [dbo].[sma_MST_ContactNumbers]
SET cnnbPrimary =
CASE
	WHEN A.RowNumber = 1
		THEN 1
	ELSE 0
END
FROM (
	SELECT
		ROW_NUMBER() OVER (PARTITION BY cnnnContactID ORDER BY cnnnContactNumberID ASC) AS RowNumber
	   ,cnnnContactNumberID AS ContactNumberID
	FROM [dbo].[sma_MST_ContactNumbers]
	WHERE cnnnContactCtgID = 1
		AND cnnnContactID NOT IN (
			SELECT DISTINCT
				cnnnContactID
			FROM [dbo].[sma_MST_ContactNumbers] CN
			JOIN [dbo].[sma_MST_ContactNoType] CT
				ON CT.ctynContactNoTypeID = CN.cnnnPhoneTypeID
			WHERE ctysDscrptn = 'Work Phone'
				AND ctynContactCategoryID = 1
		)
		AND cnnnContactCtgID = 1
) A
WHERE A.ContactNumberID = cnnnContactNumberID


---(Note: If cell phone exists, set the first cell phone primary or the only one.)
UPDATE [dbo].[sma_MST_ContactNumbers]
SET cnnbPrimary =
CASE
	WHEN A.RowNumber = 1
		THEN 1
	ELSE 0
END
FROM (
	SELECT
		ROW_NUMBER() OVER (PARTITION BY cnnnContactID ORDER BY cnnnContactNumberID ASC) AS RowNumber
	   ,cnnnContactNumberID AS ContactNumberID
	FROM [dbo].[sma_MST_ContactNumbers] CN
	JOIN [dbo].[sma_MST_ContactNoType] CT
		ON CT.ctynContactNoTypeID = CN.cnnnPhoneTypeID
	WHERE ctysDscrptn = 'Cell'
		AND ctynContactCategoryID = 2
) A
WHERE A.ContactNumberID = cnnnContactNumberID


UPDATE [dbo].[sma_MST_ContactNumbers]
SET cnnbPrimary =
CASE
	WHEN A.RowNumber = 1
		THEN 1
	ELSE 0
END
FROM (
	SELECT
		ROW_NUMBER() OVER (PARTITION BY cnnnContactID ORDER BY cnnnContactNumberID ASC) AS RowNumber
	   ,cnnnContactNumberID AS ContactNumberID
	FROM [dbo].[sma_MST_ContactNumbers]
	WHERE cnnnContactCtgID = 2
		AND cnnnContactID NOT IN (
			SELECT DISTINCT
				cnnnContactID
			FROM [dbo].[sma_MST_ContactNumbers] CN
			JOIN [dbo].[sma_MST_ContactNoType] CT
				ON CT.ctynContactNoTypeID = CN.cnnnPhoneTypeID
			WHERE ctysDscrptn = 'Cell'
				AND ctynContactCategoryID = 2
		)
		AND cnnnContactCtgID = 2
) A
WHERE A.ContactNumberID = cnnnContactNumberID


-------------------------
---CHECK RESULT
-------------------------
SELECT
	COUNT(*)
FROM [dbo].[sma_MST_ContactNumbers]
WHERE cnnnContactCtgID = 2
	AND cnnbPrimary = 1

SELECT
	COUNT(DISTINCT cnnnContactID)
FROM [dbo].[sma_MST_ContactNumbers]
WHERE cnnnContactCtgID = 2
GO

---------------------------------
---(2)--- EMAIL UNIQUENESS
---------------------------------
UPDATE [sma_MST_EmailWebsite]
SET cewbDefault =
CASE
	WHEN A.RowNumber = 1
		THEN 1
	ELSE 0
END
FROM (
	SELECT
		ROW_NUMBER() OVER (PARTITION BY cewnContactID ORDER BY cewnEmlWSID ASC) AS RowNumber
	   ,cewnEmlWSID AS EmlWSID
	FROM [sma_MST_EmailWebsite]
	WHERE cewnContactCtgID = (
			SELECT
				ctgnCategoryID
			FROM sma_MST_ContactCtg
			WHERE ctgsDesc = 'Individual'
		)
) A
WHERE A.EmlWSID = cewnEmlWSID

---
UPDATE [sma_MST_EmailWebsite]
SET cewbDefault =
CASE
	WHEN A.RowNumber = 1
		THEN 1
	ELSE 0
END
FROM (
	SELECT
		ROW_NUMBER() OVER (PARTITION BY cewnContactID ORDER BY cewnEmlWSID ASC) AS RowNumber
	   ,cewnEmlWSID AS EmlWSID
	FROM [sma_MST_EmailWebsite]
	WHERE cewnContactCtgID = (
			SELECT
				ctgnCategoryID
			FROM sma_MST_ContactCtg
			WHERE ctgsDesc = 'Organization'
		)
) A
WHERE A.EmlWSID = cewnEmlWSID
GO

---------------------------------
---(3)--- ADDRESS UNIQUENESS
---------------------------------
ALTER TABLE sma_mst_address DISABLE TRIGGER ALL
GO

UPDATE [sma_MST_Address]
SET addbPrimary =
CASE
	WHEN A.RowNumber = 1
		THEN 1
	ELSE 0
END
FROM (
	SELECT
		ROW_NUMBER() OVER (PARTITION BY addnContactID ORDER BY addnAddressID ASC) AS RowNumber
	   ,addnAddressID AS AddressID
	FROM [sma_MST_Address]
	WHERE addnContactCtgID = (
			SELECT
				ctgnCategoryID
			FROM sma_MST_ContactCtg
			WHERE ctgsDesc = 'Individual'
		)
) A
WHERE A.AddressID = addnAddressID


UPDATE [sma_MST_Address]
SET addbPrimary =
CASE
	WHEN A.RowNumber = 1
		THEN 1
	ELSE 0
END
FROM (
	SELECT
		ROW_NUMBER() OVER (PARTITION BY addnContactID ORDER BY addnAddressID ASC) AS RowNumber
	   ,addnAddressID AS AddressID
	FROM [sma_MST_Address]
	WHERE addnContactCtgID = (
			SELECT
				ctgnCategoryID
			FROM sma_MST_ContactCtg
			WHERE ctgsDesc = 'Organization'
		)
) A
WHERE A.AddressID = addnAddressID

ALTER TABLE sma_mst_address ENABLE TRIGGER ALL
GO

---(Appendix)--- normalize phone format
ALTER TABLE sma_MST_ContactNumbers DISABLE TRIGGER ALL
GO

UPDATE sma_MST_ContactNumbers
SET cnnsContactNumber =
CASE
	WHEN LEN(dbo.RemoveAlphaCharactersN(cnnsContactNumber)) = 10
		THEN '(' + SUBSTRING(dbo.RemoveAlphaCharactersN(cnnsContactNumber), 1, 3) + ') ' + SUBSTRING(dbo.RemoveAlphaCharactersN(cnnsContactNumber), 4, 3) + '-' + SUBSTRING(dbo.RemoveAlphaCharactersN(cnnsContactNumber), 7, 4)
	WHEN LEN(dbo.RemoveAlphaCharactersN(cnnsContactNumber)) = 11 AND
		LEFT(dbo.RemoveAlphaCharactersN(cnnsContactNumber), 1) = '1'
		THEN '(' + SUBSTRING(dbo.RemoveAlphaCharactersN(cnnsContactNumber), 2, 3) + ') ' + SUBSTRING(dbo.RemoveAlphaCharactersN(cnnsContactNumber), 5, 3) + '-' + SUBSTRING(dbo.RemoveAlphaCharactersN(cnnsContactNumber), 8, 4)
	ELSE dbo.RemoveAlphaCharactersN(cnnsContactNumber)
END

ALTER TABLE sma_MST_ContactNumbers ENABLE TRIGGER ALL
GO
