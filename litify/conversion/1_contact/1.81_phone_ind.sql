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

ALTER TABLE [sma_MST_ContactNumbers] DISABLE TRIGGER ALL
GO

-------------------------------------
-- Home
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
	FROM conversion.litify_phone p
	JOIN [sma_MST_IndvContacts] ind
		ON ind.saga_char = p.contact_id
	JOIN [sma_MST_Address] A
		ON A.addnContactID = ind.cinnContactID
			AND A.addnContactCtgID = ind.cinnContactCtg
			AND A.addbPrimary = 1
	LEFT JOIN sma_MST_ContactNoType cnt
		ON cnt.ctynContactCategoryID = 1
			AND cnt.ctysDscrptn = CASE
				WHEN p.phone_type IN ('Phone', 'Home')
					THEN 'Home Primary Phone'
				ELSE p.phone_type
			END
GO

-------------------------------------
-- Work
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
		ON ind.saga_char = p.id
	JOIN [sma_MST_Address] A
		ON A.addnContactID = ind.cinnContactID
			AND A.addnContactCtgID = ind.cinnContactCtg
			AND A.addbPrimary = 1
	LEFT JOIN sma_MST_ContactNoType cnt
		ON cnt.ctynContactCategoryID = 1
			AND cnt.ctysDscrptn = 'Work'
	WHERE ISNULL(litify_pm__Primary_Contact_Phone__c, '') <> ''
GO




-----------------------------------------------------
---- [1.3] USERS Phone Numbers
-----------------------------------------------------
insert into sma_MST_ContactNoType
	(
	ctysDscrptn, ctynContactCategoryID, ctysDefaultTexting
	)
	select
		'Work Phone',
		1,
		0
	union
	select
		'Work Fax',
		1,
		0
	union
	select
		'Cell',
		1,
		0
	except
	select
		ctysDscrptn,
		ctynContactCategoryID,
		ctysDefaultTexting
	from sma_MST_ContactNoType
go

-- HQ/Main Office Phone
insert into [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID], [cnnnContactID], [cnnnPhoneTypeID], [cnnsContactNumber], [cnnsExtension], [cnnbPrimary], [cnnbVisible], [cnnnAddressID], [cnnsLabelCaption], [cnnnRecUserID], [cnndDtCreated], [cnnnModifyUserID], [cnndDtModified], [cnnnLevelNo], [caseNo]
	)
	select
		ind.cinnContactCtg		 as cnnncontactctgid,
		ind.cinnContactID		 as cnnncontactid,
		(
			select
				ctynContactNoTypeID
			from sma_MST_ContactNoType
			where ctysDscrptn = 'HQ/Main Office Phone'
				and ctynContactCategoryID = 1
		)						 as cnnnphonetypeid,   -- Home Phone 
		dbo.FormatPhone(u.Phone) as cnnscontactnumber,
		null					 as cnnsextension,
		1						 as cnnbprimary,
		null					 as cnnbvisible,
		a.addnAddressID			 as cnnnaddressid,
		'HQ/Main Office Phone'	 as cnnslabelcaption,
		368						 as cnnnrecuserid,
		GETDATE()				 as cnnddtcreated,
		368						 as cnnnmodifyuserid,
		GETDATE()				 as cnnddtmodified,
		null,
		null
	from ShinerLitify..[User] u
	join [sma_MST_IndvContacts] ind
		on ind.saga_char = u.[Id]
	join sma_MST_Address a
		on a.addnContactID = ind.cinnContactID
			and a.addnContactCtgID = ind.cinnContactCtg
	where ISNULL(u.Phone, '') <> ''
go

-- Work Fax
insert into [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID], [cnnnContactID], [cnnnPhoneTypeID], [cnnsContactNumber], [cnnsExtension], [cnnbPrimary], [cnnbVisible], [cnnnAddressID], [cnnsLabelCaption], [cnnnRecUserID], [cnndDtCreated], [cnnnModifyUserID], [cnndDtModified], [cnnnLevelNo], [caseNo]
	)
	select
		ind.cinnContactCtg	   as cnnncontactctgid,
		ind.cinnContactID	   as cnnncontactid,
		(
			select
				ctynContactNoTypeID
			from sma_MST_ContactNoType
			where ctysDscrptn = 'Work Fax'
				and ctynContactCategoryID = 1
		)					   as cnnnphonetypeid,   -- Home Phone 
		dbo.FormatPhone(u.Fax) as cnnscontactnumber,
		null				   as cnnsextension,
		1					   as cnnbprimary,
		null				   as cnnbvisible,
		a.addnAddressID		   as cnnnaddressid,
		'Work Fax'			   as cnnslabelcaption,
		368					   as cnnnrecuserid,
		GETDATE()			   as cnnddtcreated,
		368					   as cnnnmodifyuserid,
		GETDATE()			   as cnnddtmodified,
		null,
		null
	from ShinerLitify..[User] u
	join [sma_MST_IndvContacts] ind
		on ind.saga_char = u.[Id]
	join sma_MST_Address a
		on a.addnContactID = ind.cinnContactID
			and a.addnContactCtgID = ind.cinnContactCtg
	where ISNULL(u.Fax, '') <> ''
go

-- Cell
insert into [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID], [cnnnContactID], [cnnnPhoneTypeID], [cnnsContactNumber], [cnnsExtension], [cnnbPrimary], [cnnbVisible], [cnnnAddressID], [cnnsLabelCaption], [cnnnRecUserID], [cnndDtCreated], [cnnnModifyUserID], [cnndDtModified], [cnnnLevelNo], [caseNo]
	)
	select
		ind.cinnContactCtg			   as cnnncontactctgid,
		ind.cinnContactID			   as cnnncontactid,
		(
			select
				ctynContactNoTypeID
			from sma_MST_ContactNoType
			where ctysDscrptn = 'Cell'
				and ctynContactCategoryID = 1
		)							   as cnnnphonetypeid,   -- Home Phone 
		dbo.FormatPhone(u.MobilePhone) as cnnscontactnumber,
		null						   as cnnsextension,
		1							   as cnnbprimary,
		null						   as cnnbvisible,
		a.addnAddressID				   as cnnnaddressid,
		'Cell'						   as cnnslabelcaption,
		368							   as cnnnrecuserid,
		GETDATE()					   as cnnddtcreated,
		368							   as cnnnmodifyuserid,
		GETDATE()					   as cnnddtmodified,
		null,
		null
	from ShinerLitify..[User] u
	join [sma_MST_IndvContacts] ind
		on ind.saga_char = u.[Id]
	join sma_MST_Address a
		on a.addnContactID = ind.cinnContactID
			and a.addnContactCtgID = ind.cinnContactCtg
	where ISNULL(u.MobilePhone, '') <> ''
go
