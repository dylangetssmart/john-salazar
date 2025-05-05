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
go

set ansi_padding on
go

alter table [dbo].[sma_MST_AllContactInfo] disable trigger all
delete from [dbo].[sma_MST_AllContactInfo]
dbcc checkident ('[dbo].[sma_MST_AllContactInfo]', reseed, 0);
alter table [dbo].[sma_MST_AllContactInfo] enable trigger all

set ansi_padding off
go

--insert org contacts

insert into [dbo].[sma_MST_AllContactInfo]
	(
		[UniqueContactId],
		[ContactId],
		[ContactCtg],
		[Name],
		[NameForLetters],
		[FirstName],
		[LastName],
		[OtherName],
		[AddressId],
		[Address1],
		[Address2],
		[Address3],
		[City],
		[State],
		[Zip],
		[ContactNumber],
		[ContactEmail],
		[ContactTypeId],
		[ContactType],
		[Comments],
		[DateModified],
		[ModifyUserId],
		[IsDeleted],
		[IsActive]
	)
	select
		CONVERT(BIGINT, ('2' + CONVERT(VARCHAR(30), sma_MST_OrgContacts.connContactID))) as UniqueContactId,
		CONVERT(BIGINT, sma_MST_OrgContacts.connContactID)								 as ContactId,
		2																				 as ContactCtg,
		sma_MST_OrgContacts.consName													 as [Name],
		sma_MST_OrgContacts.consName													 as [NameForLetters],
		null																			 as FirstName,
		null																			 as LastName,
		null																			 as OtherName,
		null																			 as AddressId,
		null																			 as Address1,
		null																			 as Address2,
		null																			 as Address3,
		null																			 as City,
		null																			 as [State],
		null																			 as Zip,
		null																			 as ContactNumber,
		null																			 as ContactEmail,
		sma_MST_OrgContacts.connContactTypeID											 as ContactTypeId,
		sma_MST_OriginalContactTypes.octsDscrptn										 as ContactType,
		sma_MST_OrgContacts.consComments												 as Comments,
		GETDATE()																		 as DateModified,
		347																				 as ModifyUserId,
		0																				 as IsDeleted,
		[conbStatus]
	--select max(len(consName))
	from sma_MST_OrgContacts
	left join sma_MST_OriginalContactTypes
		on sma_MST_OriginalContactTypes.octnOrigContactTypeID = sma_MST_OrgContacts.connContactTypeID
go

-------------------------------------
--INSERT INDIVIDUAL CONTACTS
-------------------------------------
insert into [dbo].[sma_MST_AllContactInfo]
	(
		[UniqueContactId],
		[ContactId],
		[ContactCtg],
		[Name],
		[NameForLetters],
		[FirstName],
		[LastName],
		[OtherName],
		[AddressId],
		[Address1],
		[Address2],
		[Address3],
		[City],
		[State],
		[Zip],
		[ContactNumber],
		[ContactEmail],
		[ContactTypeId],
		[ContactType],
		[Comments],
		[DateModified],
		[ModifyUserId],
		[IsDeleted],
		[DateOfBirth]
		--   ,[SSNNo]
		,
		[IsActive]
	)
	select
		CONVERT(BIGINT, ('1' + CONVERT(VARCHAR(30), sma_MST_IndvContacts.cinnContactID))) as UniqueContactId,
		CONVERT(BIGINT, sma_MST_IndvContacts.cinnContactID)								  as ContactId,
		1																				  as ContactCtg,
		case ISNULL(cinsLastName, '')
			when ''
				then ''
			else cinsLastName + ', '
		end
		+
		case ISNULL([cinsFirstName], '')
			when ''
				then ''
			else [cinsFirstName]
		end
		+
		case ISNULL(cinsMiddleName, '')
			when ''
				then ''
			else ' ' + SUBSTRING(cinsMiddleName, 1, 1) + '.'
		end
		+
		case ISNULL(cinsSuffix, '')
			when ''
				then ''
			else ', ' + cinsSuffix
		end																				  as [Name],
		case ISNULL([cinsFirstName], '')
			when ''
				then ''
			else [cinsFirstName]
		end
		+
		case ISNULL(cinsMiddleName, '')
			when ''
				then ''
			else ' ' + SUBSTRING(cinsMiddleName, 1, 1) + '.'
		end
		+
		case ISNULL(cinsLastName, '')
			when ''
				then ''
			else ' ' + cinsLastName
		end
		+
		case ISNULL(cinsSuffix, '')
			when ''
				then ''
			else ', ' + cinsSuffix
		end																				  as [NameForLetters],
		ISNULL(sma_MST_IndvContacts.cinsFirstName, '')									  as FirstName,
		ISNULL(sma_MST_IndvContacts.cinsLastName, '')									  as LastName,
		ISNULL(sma_MST_IndvContacts.cinsNickName, '')									  as OtherName,
		null																			  as AddressId,
		null																			  as Address1,
		null																			  as Address2,
		null																			  as Address3,
		null																			  as City,
		null																			  as [State],
		null																			  as Zip,
		null																			  as ContactNumber,
		null																			  as ContactEmail,
		sma_MST_IndvContacts.cinnContactTypeID											  as ContactTypeId,
		sma_MST_OriginalContactTypes.octsDscrptn										  as ContactType,
		sma_MST_IndvContacts.cinsComments												  as Comments,
		GETDATE()																		  as DateModified,
		347																				  as ModifyUserId,
		0																				  as IsDeleted,
		[cindBirthDate],
		--[cinsSSNNo],
		[cinbStatus]
	--select max(len([cinsSSNNo]))
	from sma_MST_IndvContacts
	left join sma_MST_OriginalContactTypes
		on sma_MST_OriginalContactTypes.octnOrigContactTypeID = sma_MST_IndvContacts.cinnContactTypeID
go

--FILL OUT ADDRESS INFORMATION FOR ALL CONTACT TYPES
update [dbo].[sma_MST_AllContactInfo]
set [AddressId] = Addrr.addnAddressID,
	[Address1] = Addrr.addsAddress1,
	[Address2] = Addrr.addsAddress2,
	[Address3] = Addrr.addsAddress3,
	[City] = Addrr.addsCity,
	[State] = Addrr.addsStateCode,
	[Zip] = Addrr.addsZip,
	[County] = Addrr.addsCounty
from sma_MST_AllContactInfo AllInfo
inner join sma_MST_Address Addrr
	on (AllInfo.ContactId = Addrr.addnContactID)
	and (AllInfo.ContactCtg = Addrr.addnContactCtgID)
where ISNULL(addbDeleted, 0) <> 1
go

--FILL OUT ADDRESS INFORMATION FOR ALL CONTACTS - ORG PRIMARY ADDRESS, IF NO ADDRESS EXISTS
update [dbo].[sma_MST_AllContactInfo]
set [AddressId] = Addrr.addnAddressID,
	[Address1] = Addrr.addsAddress1,
	[Address2] = Addrr.addsAddress2,
	[Address3] = Addrr.addsAddress3,
	[City] = Addrr.addsCity,
	[State] = Addrr.addsStateCode,
	[Zip] = Addrr.addsZip,
	[County] = Addrr.addsCounty
--select allinfo.*
from sma_MST_AllContactInfo AllInfo
join sma_MST_RelContacts rc
	on (AllInfo.ContactId = rc.rlcnPrimaryContactID)
	and (AllInfo.ContactCtg = rc.rlcnPrimaryCtgID)
join sma_MST_Address Addrr
	on (rc.rlcnRelContactID = Addrr.addnContactID)
	and (rc.rlcnRelCtgID = Addrr.addnContactCtgID)
	and addbPrimary = 1
where allinfo.addressID is null
go


--fill out address information for all contact types, overwriting with primary addresses
update [dbo].[sma_MST_AllContactInfo]
set [AddressId] = Addrr.addnAddressID,
	[Address1] = Addrr.addsAddress1,
	[Address2] = Addrr.addsAddress2,
	[Address3] = Addrr.addsAddress3,
	[City] = Addrr.addsCity,
	[State] = Addrr.addsStateCode,
	[Zip] = Addrr.addsZip,
	[County] = Addrr.addsCounty
from sma_MST_AllContactInfo AllInfo
inner join sma_MST_Address Addrr
	on (AllInfo.ContactId = Addrr.addnContactID)
	and (AllInfo.ContactCtg = Addrr.addnContactCtgID)
	and Addrr.addbPrimary = 1
where ISNULL(addbDeleted, 0) <> 1
go

--fill out email information
update [dbo].[sma_MST_AllContactInfo]
set [ContactEmail] = Email.cewsEmailWebSite
from sma_MST_AllContactInfo AllInfo
inner join sma_MST_EmailWebsite Email
	on (AllInfo.ContactId = Email.cewnContactID)
	and (AllInfo.ContactCtg = Email.cewnContactCtgID)
	and Email.cewsEmailWebsiteFlag = 'E'
go

--fill out default email information
update [dbo].[sma_MST_AllContactInfo]
set [ContactEmail] = Email.cewsEmailWebSite
from sma_MST_AllContactInfo AllInfo
inner join sma_MST_EmailWebsite Email
	on (AllInfo.ContactId = Email.cewnContactID)
	and (AllInfo.ContactCtg = Email.cewnContactCtgID)
	and Email.cewsEmailWebsiteFlag = 'E'
	and Email.cewbDefault = 1
go

--fill out phone information
update [dbo].[sma_MST_AllContactInfo]
set ContactNumber = Phones.cnnsContactNumber + (case
	when Phones.[cnnsExtension] is null
		then ''
	when Phones.[cnnsExtension] = ''
		then ''
	else ' x' + Phones.[cnnsExtension] + ''
end)
from sma_MST_AllContactInfo AllInfo
inner join sma_MST_ContactNumbers Phones
	on (AllInfo.ContactId = Phones.cnnnContactID)
	and (AllInfo.ContactCtg = Phones.cnnnContactCtgID)
go

--fill out default phone information
update [dbo].[sma_MST_AllContactInfo]
set ContactNumber = Phones.cnnsContactNumber + (case
	when Phones.[cnnsExtension] is null
		then ''
	when Phones.[cnnsExtension] = ''
		then ''
	else ' x' + Phones.[cnnsExtension] + ''
end)
from sma_MST_AllContactInfo AllInfo
inner join sma_MST_ContactNumbers Phones
	on (AllInfo.ContactId = Phones.cnnnContactID)
	and (AllInfo.ContactCtg = Phones.cnnnContactCtgID)
	and Phones.cnnbPrimary = 1
go

go

delete from [sma_MST_ContactTypesForContact]
insert into [sma_MST_ContactTypesForContact]
	(
		[ctcnContactCtgID],
		[ctcnContactID],
		[ctcnContactTypeID],
		[ctcnRecUserID],
		[ctcdDtCreated]
	)
	select distinct
		advnSrcContactCtg,
		advnSrcContactID,
		71,
		368,
		GETDATE()
	from sma_TRN_PdAdvt
	union
	select distinct
		2,
		lwfnLawFirmContactID,
		9,
		368,
		GETDATE()
	from sma_TRN_LawFirms
	union
	select distinct
		1,
		lwfnAttorneyContactID,
		7,
		368,
		GETDATE()
	from sma_TRN_LawFirms
	union
	select distinct
		2,
		incnInsContactID,
		11,
		368,
		GETDATE()
	from sma_TRN_InsuranceCoverage
	union
	select distinct
		1,
		incnAdjContactId,
		8,
		368,
		GETDATE()
	from sma_TRN_InsuranceCoverage
	union
	select distinct
		1,
		pornPOContactID,
		86,
		368,
		GETDATE()
	from sma_TRN_PoliceReports
	union
	select distinct
		1,
		usrncontactid,
		44,
		368,
		GETDATE()
	from sma_mst_users
go