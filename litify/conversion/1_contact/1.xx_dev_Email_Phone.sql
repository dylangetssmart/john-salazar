/* #######################################################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create individual and organization contacts


1. LitifyPhoneNumbers helper data table
2. Phone Numbers
3. Indv phone numbers
- 
- 
- 
- 
- 
sma_MST_ContactNumbers			LitifyPhoneNumbers
4. 
5. 
6. 


-------------------------------------------------------------------------------------------------
Step								Target							Source
-------------------------------------------------------------------------------------------------
[0.0] Schema Update					--								Source
[1.0] Address Types					--								Source
[2.0] Temp Table					#Address						dbo.Contact
									#Address						dbo.Account
[3.0] Indv Addresses				sma_MST_Address					sma_MST_IndvContacts
[4.0] Org Addresses					sma_MST_Address					sma_MST_OrgContacts

##########################################################################################################################
*/

USE ShinerSA
GO



IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE Name = 'LitifyPhoneNumbers'
			AND Type = 'U'
	)
BEGIN
	DROP TABLE LitifyPhoneNumbers
END
GO

CREATE TABLE LitifyPhoneNumbers (
	TableIndex [INT] IDENTITY (1, 1) NOT NULL
   ,ID VARCHAR(100)
   ,Phone VARCHAR(30)
   ,PhoneType VARCHAR(20)
	CONSTRAINT LitifyPhoneNumbers_Clustered_Index PRIMARY KEY CLUSTERED (TableIndex)
)
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_LitifyPhoneNumbers_ID ON LitifyPhoneNumbers (ID);
GO
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_LitifyPhoneNumbers_Phone ON LitifyPhoneNumbers (Phone);
GO
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_LitifyPhoneNumbers_PhoneType ON LitifyPhoneNumbers (PhoneType);
GO


INSERT INTO LitifyPhoneNumbers
	(
	ID
   ,Phone
   ,PhoneType
	)
	SELECT
		ID
	   ,Phone
	   ,PhoneType
	FROM (
		SELECT
			ID
		   ,CONVERT(VARCHAR, phone) AS phone
		   ,'Phone' AS PhoneType
		FROM ShinerLitify..Contact
		WHERE ISNULL(Phone, '') <> ''
		UNION
		SELECT
			ID
		   ,CONVERT(VARCHAR, MobilePhone) AS phone
		   ,'Cell' AS PhoneType
		FROM ShinerLitify..Contact
		WHERE ISNULL(MobilePhone, '') <> ''
		UNION
		SELECT
			ID
		   ,CONVERT(VARCHAR, Fax) AS phone
		   ,'Fax' AS PhoneType
		FROM ShinerLitify..Contact
		WHERE ISNULL(Fax, '') <> ''
		UNION
		SELECT
			ID
		   ,CONVERT(VARCHAR, HomePhone) AS phone
		   ,'Home' AS PhoneType
		FROM ShinerLitify..Contact
		WHERE ISNULL(HomePhone, '') <> ''
		UNION
		SELECT
			ID
		   ,CONVERT(VARCHAR, OtherPhone) AS phone
		   ,'Other' AS PhoneType
		FROM ShinerLitify..Contact
		WHERE ISNULL(OtherPhone, '') <> ''
		UNION
		SELECT
			ID
		   ,CONVERT(VARCHAR, Phone) AS phone
		   ,'Phone' AS PhoneType
		FROM ShinerLitify..Account
		WHERE ISNULL(Phone, '') <> ''
		UNION
		SELECT
			ID
		   ,CONVERT(VARCHAR, Fax) AS phone
		   ,'Fax' AS PhoneType
		FROM ShinerLitify..Account
		WHERE ISNULL(Fax, '') <> ''
		UNION
		SELECT
			ID
		   ,CONVERT(VARCHAR, litify_pm__Phone_Home__c) AS phone
		   ,'Home' AS PhoneType
		FROM ShinerLitify..Account
		WHERE ISNULL(litify_pm__Phone_Home__c, '') <> ''
		UNION
		SELECT
			ID
		   ,CONVERT(VARCHAR, litify_pm__Phone_Mobile__c) AS phone
		   ,'Cell' AS PhoneType
		FROM ShinerLitify..Account
		WHERE ISNULL(litify_pm__Phone_Mobile__c, '') <> ''
		UNION
		SELECT
			ID
		   ,CONVERT(VARCHAR, litify_pm__Phone_Other__c) AS phone
		   ,'Other' AS PhoneType
		FROM ShinerLitify..Account
		WHERE ISNULL(litify_pm__Phone_Other__c, '') <> ''
		UNION
		SELECT
			ID
		   ,CONVERT(VARCHAR, litify_pm__Phone_Work__c) AS phone
		   ,'Work' AS PhoneType
		FROM ShinerLitify..Account
		WHERE ISNULL(litify_pm__Phone_Work__c, '') <> ''
	) p
GO


---(0)---
INSERT INTO sma_MST_ContactNoType
	(
	ctysDscrptn
   ,ctynContactCategoryID
   ,ctysDefaultTexting
	)
	SELECT
		'Work'
	   ,1
	   ,0
	UNION
	SELECT
		'Home'
	   ,2
	   ,0
	UNION
	SELECT
		'Cell'
	   ,1
	   ,0
	UNION
	SELECT
		'Cell'
	   ,2
	   ,0
	UNION
	SELECT
		'Other'
	   ,1
	   ,0
	UNION
	SELECT
		'Other'
	   ,2
	   ,0
	UNION
	SELECT
		'Fax'
	   ,1
	   ,0
	UNION
	SELECT
		'Fax'
	   ,2
	   ,0
	EXCEPT
	SELECT
		ctysDscrptn
	   ,ctynContactCategoryID
	   ,ctysDefaultTexting
	FROM sma_MST_ContactNoType
GO


-------------------------------------
--PHONE NUMBERS
-------------------------------------
--INDIVIDUAL PHONE NUMBERS
ALTER TABLE [sma_MST_ContactNumbers] DISABLE TRIGGER ALL
GO

-- Home
INSERT INTO [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID]
   ,[cnnnContactID]
   ,[cnnnPhoneTypeID]
   ,[cnnsContactNumber]
   ,[cnnsExtension]
   ,[cnnbPrimary]
   ,[cnnbVisible]
   ,[cnnnAddressID]
   ,[cnnsLabelCaption]
   ,[cnnnRecUserID]
   ,[cnndDtCreated]
   ,[cnnnModifyUserID]
   ,[cnndDtModified]
   ,[cnnnLevelNo]
   ,[caseno]
	)
	SELECT
		ind.cinnContactCtg		 AS cnnnContactCtgID
	   ,ind.cinnContactID		 AS cnnnContactID
	   ,ctynContactNoTypeID		 AS cnnnPhoneTypeID
	   ,dbo.FormatPhone(p.Phone) AS cnnsContactNumber
	   ,NULL					 AS cnnsExtension
	   ,1						 AS cnnbPrimary
	   ,NULL					 AS cnnbVisible
	   ,A.addnAddressID			 AS cnnnAddressID
	   ,ctysDscrptn				 AS cnnsLabelCaption
	   ,ind.cinnRecUserID		 AS cnnnRecUserID
	   ,ind.cindDtCreated		 AS cnndDtCreated
	   ,NULL					 AS cnnnModifyUserID
	   ,ind.cindDtModified		 AS cnndDtModified
	   ,NULL
	   ,NULL
	FROM LitifyPhoneNumbers p
	JOIN [sma_MST_IndvContacts] ind
		ON ind.saga = p.Id
	JOIN [sma_MST_Address] A
		ON A.addnContactID = ind.cinnContactID
			AND A.addnContactCtgID = ind.cinnContactCtg
			AND A.addbPrimary = 1
	LEFT JOIN sma_MST_ContactNoType cnt
		ON cnt.ctynContactCategoryID = 1
			AND cnt.ctysDscrptn = CASE
				WHEN p.PhoneType IN ('Phone', 'Home')
					THEN 'Home Primary Phone'
				ELSE p.PhoneType
			END
GO

-- Work
INSERT INTO [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID]
   ,[cnnnContactID]
   ,[cnnnPhoneTypeID]
   ,[cnnsContactNumber]
   ,[cnnsExtension]
   ,[cnnbPrimary]
   ,[cnnbVisible]
   ,[cnnnAddressID]
   ,[cnnsLabelCaption]
   ,[cnnnRecUserID]
   ,[cnndDtCreated]
   ,[cnnnModifyUserID]
   ,[cnndDtModified]
   ,[cnnnLevelNo]
   ,[caseno]
	)
	SELECT
		ind.cinnContactCtg									   AS cnnnContactCtgID
	   ,ind.cinnContactID									   AS cnnnContactID
	   ,ctynContactNoTypeID									   AS cnnnPhoneTypeID
	   ,dbo.FormatPhone(p.litify_pm__Primary_Contact_Phone__c) AS cnnsContactNumber
	   ,NULL												   AS cnnsExtension
	   ,1													   AS cnnbPrimary
	   ,NULL												   AS cnnbVisible
	   ,A.addnAddressID										   AS cnnnAddressID
	   ,ctysDscrptn											   AS cnnsLabelCaption
	   ,ind.cinnRecUserID									   AS cnnnRecUserID
	   ,ind.cindDtCreated									   AS cnndDtCreated
	   ,NULL												   AS cnnnModifyUserID
	   ,ind.cindDtModified									   AS cnndDtModified
	   ,NULL
	   ,NULL
	--select ID, litify_pm__Primary_Contact_Phone__c as phone, 'Phone' 
	FROM ShinerLitify..litify_pm__Firm__c p
	JOIN [sma_MST_IndvContacts] ind
		ON ind.saga = p.Id
	JOIN [sma_MST_Address] A
		ON A.addnContactID = ind.cinnContactID
			AND A.addnContactCtgID = ind.cinnContactCtg
			AND A.addbPrimary = 1
	LEFT JOIN sma_MST_ContactNoType cnt
		ON cnt.ctynContactCategoryID = 1
			AND cnt.ctysDscrptn = 'Work'
	WHERE ISNULL(litify_pm__Primary_Contact_Phone__c, '') <> ''
GO

-------------------------------------
-- [1.4] ORG PHONE NUMBERS
-------------------------------------

-- Office
INSERT INTO [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID]
   ,[cnnnContactID]
   ,[cnnnPhoneTypeID]
   ,[cnnsContactNumber]
   ,[cnnsExtension]
   ,[cnnbPrimary]
   ,[cnnbVisible]
   ,[cnnnAddressID]
   ,[cnnsLabelCaption]
   ,[cnnnRecUserID]
   ,[cnndDtCreated]
   ,[cnnnModifyUserID]
   ,[cnndDtModified]
   ,[cnnnLevelNo]
   ,[caseno]
	)
	SELECT
		org.connContactCtg		 AS cnnnContactCtgID
	   ,org.connContactID		 AS cnnnContactID
	   ,ctynContactNoTypeID		 AS cnnnPhoneTypeID
	   ,dbo.FormatPhone(p.Phone) AS cnnsContactNumber
	   ,NULL					 AS cnnsExtension
	   ,1						 AS cnnbPrimary
	   ,NULL					 AS cnnbVisible
	   ,A.addnAddressID			 AS cnnnAddressID
	   ,ctysDscrptn				 AS cnnsLabelCaption
	   ,org.connRecUserID		 AS cnnnRecUserID
	   ,org.condDtCreated		 AS cnndDtCreated
	   ,NULL					 AS cnnnModifyUserID
	   ,org.condDtModified		 AS cnndDtModified
	   ,NULL
	   ,NULL
	FROM LitifyPhoneNumbers p
	JOIN [sma_MST_OrgContacts] org
		ON org.saga = p.Id
	JOIN [sma_MST_Address] A
		ON A.addnContactID = org.connContactID
			AND A.addnContactCtgID = org.connContactCtg
			AND A.addbPrimary = 1
	LEFT JOIN sma_MST_ContactNoType cnt
		ON cnt.ctynContactCategoryID = 2
			AND cnt.ctysDscrptn = CASE
				WHEN p.PhoneType IN ('Phone', 'Work')
					THEN 'Office Phone'
				ELSE p.PhoneType
			END
GO


ALTER TABLE [sma_MST_ContactNumbers] ENABLE TRIGGER ALL
GO
-----------------------------------------
-- [ 2.0] EMAIL ADDRESSES
-----------------------------------------

-- [2.1] Indv Email
INSERT INTO [sma_MST_EmailWebsite]
	(
	[cewnContactCtgID]
   ,[cewnContactID]
   ,[cewsEmailWebsiteFlag]
   ,[cewsEmailWebSite]
   ,[cewbDefault]
   ,[cewnComments]
   ,[cewnRecUserID]
   ,[cewdDtCreated]
   ,[cewnModifyUserID]
   ,[cewdDtModified]
   ,[cewnLevelNo]
   ,[saga]
	)
	SELECT
		ind.cinnContactCtg AS cewnContactCtgID
	   ,ind.cinnContactID  AS cewnContactID
	   ,'E'				   AS cewsEmailWebsiteFlag
	   ,e.Email			   AS cewsEmailWebSite
	   ,NULL			   AS cewbDefault
	   ,''				   AS [cewnComments]
	   ,ind.cinnRecUserID  AS cewnRecUserID
	   ,ind.cindDtCreated  AS cewdDtCreated
	   ,NULL			   AS cewnModifyUserID
	   ,ind.cindDtModified AS cewdDtModified
	   ,NULL
	   ,e.ID			   AS saga -- indicate email
	FROM (
		SELECT
			ID
		   ,Email AS email
		FROM ShinerLitify..Contact
		WHERE ISNULL(email, '') <> ''
		UNION
		SELECT
			ID
		   ,litify_pm__Email__c AS email
		FROM ShinerLitify..Account
		WHERE ISNULL(litify_pm__Email__c, '') <> ''
		UNION
		SELECT
			ID
		   ,litify_pm__Primary_Contact_Email__c AS email
		FROM ShinerLitify..litify_pm__Firm__c
		WHERE ISNULL(litify_pm__Primary_Contact_Email__c, '') <> ''
	) e
	JOIN [sma_MST_IndvContacts] ind
		ON ind.saga = e.ID
GO

-- [2.2] ORG EMAIL
INSERT INTO [sma_MST_EmailWebsite]
	(
	[cewnContactCtgID]
   ,[cewnContactID]
   ,[cewsEmailWebsiteFlag]
   ,[cewsEmailWebSite]
   ,[cewbDefault]
   ,[cewnComments]
   ,[cewnRecUserID]
   ,[cewdDtCreated]
   ,[cewnModifyUserID]
   ,[cewdDtModified]
   ,[cewnLevelNo]
   ,[saga]
	)
	SELECT
		org.connContactCtg AS cewnContactCtgID
	   ,org.connContactID  AS cewnContactID
	   ,'E'				   AS cewsEmailWebsiteFlag
	   ,e.Email			   AS cewsEmailWebSite
	   ,NULL			   AS cewbDefault
	   ,''				   AS [cewnComments]
	   ,org.connRecUserID  AS cewnRecUserID
	   ,org.condDtCreated  AS cewdDtCreated
	   ,NULL			   AS cewnModifyUserID
	   ,org.condDtModified AS cewdDtModified
	   ,NULL
	   ,e.Id			   AS saga -- indicate email
	FROM (
		SELECT
			ID
		   ,Email AS email
		FROM ShinerLitify..Contact
		WHERE ISNULL(email, '') <> ''
		UNION
		SELECT
			ID
		   ,litify_pm__Email__c AS email
		FROM ShinerLitify..Account
		WHERE ISNULL(litify_pm__Email__c, '') <> ''
	) e
	JOIN [sma_MST_OrgContacts] org
		ON org.saga = e.Id
GO