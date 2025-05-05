/* ######################################################################################
description: Create sma_MST_AllContactInfo
steps:
	-
usage_instructions:
	-
dependencies:
	- [sma_MST_AllContactInfo]
    - [sma_MST_IndvContacts]
    - [sma_MST_Address]
    - [sma_MST_ContactNumbers]
    - [sma_MST_EmailWebsite]
notes:
	-
######################################################################################
*/

use [ShinerSA]
Go

SET ANSI_PADDING ON
GO

set QUOTED_IDENTIFIER ON
GO

alter table [dbo].[sma_MST_AllContactInfo] disable trigger all
delete from [dbo].[sma_MST_AllContactInfo] 
DBCC CHECKIDENT ('[dbo].[sma_MST_AllContactInfo]', RESEED, 0);
alter table [dbo].[sma_MST_AllContactInfo] enable trigger all

SET ANSI_PADDING OFF
GO

--insert org contacts

INSERT INTO [dbo].[sma_MST_AllContactInfo] (
			[UniqueContactId]
           ,[ContactId]
           ,[ContactCtg]
           ,[Name]
		   ,[NameForLetters]
           ,[FirstName]
           ,[LastName]
	       ,[OtherName]
           ,[AddressId]
           ,[Address1]
           ,[Address2]
           ,[Address3]
           ,[City]
           ,[State]
           ,[Zip]
           ,[ContactNumber]
           ,[ContactEmail]
           ,[ContactTypeId]
           ,[ContactType]
           ,[Comments]
           ,[DateModified]
           ,[ModifyUserId]
           ,[IsDeleted]
           ,[IsActive]  )
SELECT convert(bigint, ('2' + convert(varchar(30),sma_MST_OrgContacts.connContactID))) as UniqueContactId,
		convert(bigint,sma_MST_OrgContacts.connContactID)			as ContactId,
		2															as ContactCtg ,
		sma_MST_OrgContacts.consName 								as [Name],
		sma_MST_OrgContacts.consName								as [NameForLetters],
		null 														as FirstName,
		null  														as LastName, 
		null  														as OtherName, 
        null  														as AddressId,
        null  														as Address1,
        null  														as Address2,
        null 														as Address3,
        null  														as City,
        null  														as [State],
        null  														as Zip,
        null 														as ContactNumber,
        null  														as ContactEmail,
        sma_MST_OrgContacts.connContactTypeID						as ContactTypeId,
        sma_MST_OriginalContactTypes.octsDscrptn					as ContactType,
        sma_MST_OrgContacts.consComments							as Comments, 
        GetDate()  													as DateModified,
        347  														as ModifyUserId,
        0  															as IsDeleted,
        [conbStatus]
--select max(len(consName))
FROM sma_MST_OrgContacts
LEFT JOIN sma_MST_OriginalContactTypes on sma_MST_OriginalContactTypes.octnOrigContactTypeID = sma_MST_OrgContacts.connContactTypeID
GO

-------------------------------------
--INSERT INDIVIDUAL CONTACTS
-------------------------------------
INSERT INTO [dbo].[sma_MST_AllContactInfo] (
			[UniqueContactId]
           ,[ContactId]
           ,[ContactCtg]
           ,[Name]
           ,[NameForLetters]
           ,[FirstName]
           ,[LastName]
		   ,[OtherName]
           ,[AddressId]
           ,[Address1]
           ,[Address2]
           ,[Address3]
           ,[City]
           ,[State]
           ,[Zip]
           ,[ContactNumber]
           ,[ContactEmail]
           ,[ContactTypeId]
           ,[ContactType]
           ,[Comments]
           ,[DateModified]
           ,[ModifyUserId]
           ,[IsDeleted]
           ,[DateOfBirth]
		   ,[SSNNo]
		   ,[IsActive] )
SELECT convert(bigint, ('1' + convert(varchar(30),sma_MST_IndvContacts.cinnContactID)))	as UniqueContactId,
		convert(bigint,sma_MST_IndvContacts.cinnContactID)								as ContactId,
		1																				as ContactCtg ,
		CASE ISNULL(cinsLastName,'') WHEN  '' THEN '' ELSE cinsLastName + ', ' END
			+ CASE ISNULL([cinsFirstName],'') WHEN '' THEN '' ELSE [cinsFirstName] END 
			+ CASE ISNULL(cinsMiddleName, '') WHEN '' THEN '' ELSE  ' ' + SUBSTRING(cinsMiddleName, 1, 1) + '.' END 
			+ CASE ISNULL(cinsSuffix, '') WHEN '' THEN '' ELSE  ', ' + cinsSuffix END   as [Name],
		CASE ISNULL([cinsFirstName],'') WHEN '' THEN '' ELSE [cinsFirstName] END 
			+ CASE ISNULL(cinsMiddleName, '') WHEN '' THEN '' ELSE  ' ' + SUBSTRING(cinsMiddleName, 1, 1) + '.' END 
            + CASE ISNULL(cinsLastName,'') WHEN '' THEN '' ELSE ' ' + cinsLastName END 
            + CASE ISNULL(cinsSuffix, '') WHEN '' THEN '' ELSE ', ' + cinsSuffix END	as [NameForLetters],
		isnull(sma_MST_IndvContacts.cinsFirstName, '')									as FirstName,
		isnull(sma_MST_IndvContacts.cinsLastName, '') 									as LastName,
		isnull(sma_MST_IndvContacts.cinsNickName, '') 									as OtherName,
        null 																			as AddressId,
		null 																			as Address1,
		null 																			as Address2,
		null 																			as Address3,
		null 																			as City,
        null 																			as [State],
		null 																			as Zip,
		null 																			as ContactNumber,
        null 																			as ContactEmail,
        sma_MST_IndvContacts.cinnContactTypeID 											as ContactTypeId,
        sma_MST_OriginalContactTypes.octsDscrptn 										as ContactType,
        sma_MST_IndvContacts.cinsComments 												as Comments, 
        getDate() 																		as DateModified,
		347 																			as ModifyUserId,
		0 																				as IsDeleted,
		[cindBirthDate],
		left([cinsSSNNo],20),
        [cinbStatus]
--select max(len([cinsSSNNo]))
FROM sma_MST_IndvContacts
LEFT JOIN sma_MST_OriginalContactTypes on sma_MST_OriginalContactTypes.octnOrigContactTypeID = sma_MST_IndvContacts.cinnContactTypeID		
GO

--FILL OUT ADDRESS INFORMATION FOR ALL CONTACT TYPES
UPDATE [dbo].[sma_MST_AllContactInfo]
   SET [AddressId] = Addrr.addnAddressID
      ,[Address1] = left(Addrr.addsAddress1,75)
      ,[Address2] = left(Addrr.addsAddress2,75)
      ,[Address3] = left(Addrr.addsAddress3,75)
      ,[City] = Addrr.addsCity
      ,[State] = Addrr.addsStateCode
      ,[Zip] = Addrr.addsZip
,[County] = Addrr.addsCounty
FROM
    sma_MST_AllContactInfo AllInfo
INNER JOIN sma_MST_Address Addrr ON (AllInfo.ContactId = Addrr.addnContactID)  AND (AllInfo.ContactCtg = Addrr.addnContactCtgID) 
GO

--fill out address information for all contact types, overwriting with primary addresses
UPDATE [dbo].[sma_MST_AllContactInfo]
   SET [AddressId] = Addrr.addnAddressID
      ,[Address1] = left(Addrr.addsAddress1,75)
      ,[Address2] = left(Addrr.addsAddress2,75)
      ,[Address3] = left(Addrr.addsAddress3,75)
      ,[City] = Addrr.addsCity
      ,[State] = Addrr.addsStateCode
      ,[Zip] = Addrr.addsZip
,[County] = Addrr.addsCounty
FROM
    sma_MST_AllContactInfo AllInfo
INNER JOIN sma_MST_Address Addrr ON (AllInfo.ContactId = Addrr.addnContactID)  AND (AllInfo.ContactCtg = Addrr.addnContactCtgID) AND Addrr.addbPrimary = 1
GO
--fill out email information
UPDATE [dbo].[sma_MST_AllContactInfo]
   SET [ContactEmail] = Email.cewsEmailWebSite
  FROM
    sma_MST_AllContactInfo AllInfo
INNER JOIN sma_MST_EmailWebsite Email ON (AllInfo.ContactId = Email.cewnContactID)  AND (AllInfo.ContactCtg = Email.cewnContactCtgID) AND Email.cewsEmailWebsiteFlag = 'E' 
GO

--fill out default email information
UPDATE [dbo].[sma_MST_AllContactInfo]
   SET [ContactEmail] = Email.cewsEmailWebSite
  FROM
    sma_MST_AllContactInfo AllInfo
INNER JOIN sma_MST_EmailWebsite Email ON (AllInfo.ContactId = Email.cewnContactID)  AND (AllInfo.ContactCtg = Email.cewnContactCtgID) AND Email.cewsEmailWebsiteFlag = 'E' AND Email.cewbDefault = 1
GO
--fill out phone information
UPDATE [dbo].[sma_MST_AllContactInfo]
   SET ContactNumber = Phones.cnnsContactNumber + (CASE WHEN Phones.[cnnsExtension] IS NULL THEN '' WHEN Phones.[cnnsExtension] = '' THEN '' ELSE ' x' + Phones.[cnnsExtension] + '' END) 
  FROM
    sma_MST_AllContactInfo AllInfo
INNER JOIN sma_MST_ContactNumbers Phones ON (AllInfo.ContactId = Phones.cnnnContactID)  AND (AllInfo.ContactCtg = Phones.cnnnContactCtgID) 
GO

--fill out default phone information
UPDATE [dbo].[sma_MST_AllContactInfo]
   SET ContactNumber = Phones.cnnsContactNumber+ (CASE WHEN Phones.[cnnsExtension] IS NULL THEN '' WHEN Phones.[cnnsExtension] = '' THEN '' ELSE ' x' + Phones.[cnnsExtension] + '' END) 
  FROM
    sma_MST_AllContactInfo AllInfo
INNER JOIN sma_MST_ContactNumbers Phones ON (AllInfo.ContactId = Phones.cnnnContactID)  AND (AllInfo.ContactCtg = Phones.cnnnContactCtgID)  AND Phones.cnnbPrimary = 1
GO
GO
delete from [sma_MST_ContactTypesForContact]
INSERT INTO [sma_MST_ContactTypesForContact]
([ctcnContactCtgID],[ctcnContactID],[ctcnContactTypeID],[ctcnRecUserID],[ctcdDtCreated])
Select distinct  advnSrcContactCtg,advnSrcContactID,71,368,getdate() from sma_TRN_PdAdvt
Union
Select distinct 2,lwfnLawFirmContactID,9,368,GETDATE() from sma_TRN_LawFirms
Union
Select distinct 1,lwfnAttorneyContactID,7,368,GETDATE() from sma_TRN_LawFirms    
Union
Select distinct 2,incnInsContactID,11,368,GETDATE() from sma_TRN_InsuranceCoverage
Union
Select distinct 1,incnAdjContactId,8,368,GETDATE() from sma_TRN_InsuranceCoverage
Union
select distinct 1,pornPOContactID,86,368,GETDATE() from sma_TRN_PoliceReports
Union
Select distinct 1,usrncontactid,44,368,GETDATE() from sma_mst_users
go