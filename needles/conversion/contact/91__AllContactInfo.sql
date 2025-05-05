/*---
group: postload
order: 91
description:
---*/

use [JohnSalazar_SA]
go


set ansi_padding on
go

set quoted_identifier on
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
		CONVERT(BIGINT, ('2' + CONVERT(VARCHAR(30), sma_MST_OrgContacts.connContactID))) as uniquecontactid,
		CONVERT(BIGINT, sma_MST_OrgContacts.connContactID)								 as contactid,
		2																				 as contactctg,
		sma_MST_OrgContacts.consName													 as [name],
		sma_MST_OrgContacts.consName													 as [nameforletters],
		null																			 as firstname,
		null																			 as lastname,
		null																			 as othername,
		null																			 as addressid,
		null																			 as address1,
		null																			 as address2,
		null																			 as address3,
		null																			 as city,
		null																			 as [state],
		null																			 as zip,
		null																			 as contactnumber,
		null																			 as contactemail,
		sma_MST_OrgContacts.connContactTypeID											 as contacttypeid,
		sma_MST_OriginalContactTypes.octsDscrptn										 as contacttype,
		sma_MST_OrgContacts.consComments												 as comments,
		GETDATE()																		 as datemodified,
		347																				 as modifyuserid,
		0																				 as isdeleted,
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
	[DateOfBirth],
	[IsActive]
	)
	select
		CONVERT(BIGINT, ('1' + CONVERT(VARCHAR(30), sma_MST_IndvContacts.cinnContactID))) as uniquecontactid,
		CONVERT(BIGINT, sma_MST_IndvContacts.cinnContactID)								  as contactid,
		1																				  as contactctg,
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
		end																				  as [name],
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
		end																				  as [nameforletters],
		LEFT(ISNULL(sma_MST_IndvContacts.cinsFirstName, ''), 100)						  as firstname,
		LEFT(ISNULL(sma_MST_IndvContacts.cinsLastName, ''), 100)						  as lastname,
		LEFT(ISNULL(sma_MST_IndvContacts.cinsNickName, ''), 100)						  as othername,
		null																			  as addressid,
		null																			  as address1,
		null																			  as address2,
		null																			  as address3,
		null																			  as city,
		null																			  as [state],
		null																			  as zip,
		null																			  as contactnumber,
		null																			  as contactemail,
		sma_MST_IndvContacts.cinnContactTypeID											  as contacttypeid,
		sma_MST_OriginalContactTypes.octsDscrptn										  as contacttype,
		sma_MST_IndvContacts.cinsComments												  as comments,
		GETDATE()																		  as datemodified,
		347																				  as modifyuserid,
		0																				  as isdeleted,
		[cindBirthDate],
		[cinbStatus]
	--select max(len([cinsSSNNo]))
	from sma_MST_IndvContacts
	left join sma_MST_OriginalContactTypes
		on sma_MST_OriginalContactTypes.octnOrigContactTypeID = sma_MST_IndvContacts.cinnContactTypeID
go

--FILL OUT ADDRESS INFORMATION FOR ALL CONTACT TYPES
update [dbo].[sma_MST_AllContactInfo]
set [AddressId] = Addrr.addnAddressID,
	[Address1] = LEFT(Addrr.addsAddress1, 75),
	[Address2] = LEFT(Addrr.addsAddress2, 75),
	[Address3] = LEFT(Addrr.addsAddress3, 75),
	[City] = Addrr.addsCity,
	[State] = Addrr.addsStateCode,
	[Zip] = Addrr.addsZip,
	[County] = Addrr.addsCounty
from sma_MST_AllContactInfo allinfo
inner join sma_MST_Address addrr
	on (allinfo.ContactId = addrr.addnContactID)
	and (allinfo.ContactCtg = addrr.addnContactCtgID)
go

--fill out address information for all contact types, overwriting with primary addresses
update [dbo].[sma_MST_AllContactInfo]
set [AddressId] = Addrr.addnAddressID,
	[Address1] = LEFT(Addrr.addsAddress1, 75),
	[Address2] = LEFT(Addrr.addsAddress2, 75),
	[Address3] = LEFT(Addrr.addsAddress3, 75),
	[City] = Addrr.addsCity,
	[State] = Addrr.addsStateCode,
	[Zip] = Addrr.addsZip,
	[County] = Addrr.addsCounty
from sma_MST_AllContactInfo allinfo
inner join sma_MST_Address addrr
	on (allinfo.ContactId = addrr.addnContactID)
	and (allinfo.ContactCtg = addrr.addnContactCtgID)
	and addrr.addbPrimary = 1
go

--fill out email information
update [dbo].[sma_MST_AllContactInfo]
set [ContactEmail] = Email.cewsEmailWebSite
from sma_MST_AllContactInfo allinfo
inner join sma_MST_EmailWebsite email
	on (allinfo.ContactId = email.cewnContactID)
	and (allinfo.ContactCtg = email.cewnContactCtgID)
	and email.cewsEmailWebsiteFlag = 'E'
go

--fill out default email information
update [dbo].[sma_MST_AllContactInfo]
set [ContactEmail] = Email.cewsEmailWebSite
from sma_MST_AllContactInfo allinfo
inner join sma_MST_EmailWebsite email
	on (allinfo.ContactId = email.cewnContactID)
	and (allinfo.ContactCtg = email.cewnContactCtgID)
	and email.cewsEmailWebsiteFlag = 'E'
	and email.cewbDefault = 1
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
from sma_MST_AllContactInfo allinfo
inner join sma_MST_ContactNumbers phones
	on (allinfo.ContactId = phones.cnnnContactID)
	and (allinfo.ContactCtg = phones.cnnnContactCtgID)
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
from sma_MST_AllContactInfo allinfo
inner join sma_MST_ContactNumbers phones
	on (allinfo.ContactId = phones.cnnnContactID)
	and (allinfo.ContactCtg = phones.cnnnContactCtgID)
	and phones.cnnbPrimary = 1
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