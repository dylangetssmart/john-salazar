/* ######################################################################################
description: Phone numbers for individual contacts
steps:
	- Insert [sma_MST_ContactNumbers]
usage_instructions:
	-
dependencies:
	- 
notes:
	-
#########################################################################################
*/

USE ShinerSA
GO

-------------------------------------
-- Office
-------------------------------------
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
	FROM conversion.litify_phone p
	JOIN [sma_MST_OrgContacts] org
		ON org.saga_char = p.contact_id
	JOIN [sma_MST_Address] A
		ON A.addnContactID = org.connContactID
			AND A.addnContactCtgID = org.connContactCtg
			AND A.addbPrimary = 1
	LEFT JOIN sma_MST_ContactNoType cnt
		ON cnt.ctynContactCategoryID = 2
			AND cnt.ctysDscrptn = CASE
				WHEN p.phone_type IN ('Phone', 'Work')
					THEN 'Office Phone'
				ELSE p.phone_type
			END
GO


ALTER TABLE [sma_MST_ContactNumbers] ENABLE TRIGGER ALL
GO