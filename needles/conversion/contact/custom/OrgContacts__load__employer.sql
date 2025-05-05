use [SA]
go

/* ########################################################
1.0 - Create helper table
*/
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'Employer_Address_Helper' AND xtype = 'U')
BEGIN
    CREATE TABLE Employer_Address_Helper (
        party_id               INT,
        case_id                INT,
        Employer               NVARCHAR(255),
        Employers_Phone_Number NVARCHAR(50),
        Employers_Address      NVARCHAR(255),
        City                   NVARCHAR(100),
        StateCode              NVARCHAR(10),
        Zip                    NVARCHAR(10)
    );
END;

insert into Employer_Address_Helper
	(
		party_id,
		case_id,
		Employer,
		Employers_Phone_Number,
		Employers_Address,
		City,
		StateCode,
		Zip
	)
	select
		party_id,
		case_id,
		Employer,
		Employers_Phone_Number,
		Employers_Address,
		case
			when Employers_Address like '%,%,%,%'
				then REVERSE(SUBSTRING(REVERSE(Employers_Address), CHARINDEX(',', REVERSE(Employers_Address)) + 1, CHARINDEX(',', REVERSE(Employers_Address), CHARINDEX(',', REVERSE(Employers_Address)) + 1) - CHARINDEX(',', REVERSE(Employers_Address)) - 1))
			when Employers_Address like '%,%,%'
				then SUBSTRING(Employers_Address, CHARINDEX(',', Employers_Address) + 1, CHARINDEX(',', Employers_Address, CHARINDEX(',', Employers_Address) + 1) - CHARINDEX(',', Employers_Address) - 1)
			else ''
		end		   as City,
		s.sttsCode as StateCode,
		case
			when RTRIM(Employers_Address) like '%[0-9][0-9][0-9][0-9][0-9]'
				then RIGHT(RTRIM(Employers_Address), 5)
			when Employers_Address like '%[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'
				then RIGHT(Employers_Address, 10)
			else ''
		end		   as Zip
	from Needles..user_party_data d
	left join sma_MST_States s
		on Employers_Address like '% ' + s.sttsCode + ' %'
			or Employers_Address like '%,' + s.sttsCode + ' %'
	where
		ISNULL(Employer, '') <> ''

/* ------------------------------------------------------------------------------
Create Org contacts from user_paty_data.employer
*/

insert into [sma_MST_OrgContacts]
	(
		[consName],
		[connContactCtg],
		[connContactTypeID],
		[connRecUserID],
		[condDtCreated],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select distinct
		upd.Employer			   as [consName],
		2						   as [connContactCtg],
		(
			select
				octnOrigContactTypeID
			from [sma_MST_OriginalContactTypes]
			where octnContactCtgID = 2
				and octsDscrptn = 'General'
		)						   as [connContactTypeID],
		368						   as [connRecUserID],
		GETDATE()				   as [condDtCreated],
		null					   as [saga],
		upd.Employer			   as [source_id],
		'needles'				   as [source_db],
		'user_party_data.employer' as [source_ref]
	from Needles..user_party_data upd
	where
		ISNULL(upd.Employer, '') <> ''


/* ########################################################
3.0 - Add address to the employer org contacts
*/
insert into [dbo].[sma_MST_Address]
	(
		[addnContactCtgID],
		[addnContactID],
		[addnAddressTypeID],
		[addsAddressType],
		[addsAddTypeCode],
		[addsAddress1],
		[addsAddress2],
		[addsAddress3],
		[addsStateCode],
		[addsCity],
		[addnZipID],
		[addsZip],
		[addsCounty],
		[addsCountry],
		[addbIsResidence],
		[addbPrimary],
		[adddFromDate],
		[adddToDate],
		[addnCompanyID],
		[addsDepartment],
		[addsTitle],
		[addnContactPersonID],
		[addsComments],
		[addbIsCurrent],
		[addbIsMailing],
		[addnRecUserID],
		[adddDtCreated],
		[addnModifyUserID],
		[adddDtModified],
		[addnLevelNo],
		[caseno],
		[addbDeleted],
		[addsZipExtn],
		[saga]
	)
	select
		org.connContactCtg	   as addnContactCtgID,
		org.connContactID	   as addnContactID,
		T.addnAddTypeID		   as addnAddressTypeID,
		T.addsDscrptn		   as addsAddressType,
		T.addsCode			   as addsAddTypeCode,
		help.Employers_Address as addsAddress1,
		null				   as addsAddress2,
		null				   as addsAddress3,
		help.StateCode		   as addsStateCode,
		help.City			   as addsCity,
		null				   as addnZipID,
		help.Zip			   as addsZip,
		null				   as addsCounty,
		null				   as addsCountry,
		null				   as addbIsResidence,
		1					   as addbPrimary,
		null,
		null,
		null,
		null,
		null,
		null,
		null				   as [addsComments],
		null,
		null,
		368					   as addnRecUserID,
		GETDATE()			   as adddDtCreated,
		368					   as addnModifyUserID,
		GETDATE()			   as adddDtModified,
		null				   as addnLevelNo,
		null				   as caseno,
		null				   as addbDeleted,
		null				   as addsZipExtn,
		null				   as saga
	from Needles..user_party_data upd
	join sma_MST_OrgContacts org
		on org.source_id = upd.Employer
			and org.source_ref = 'user_party_data.employer'
	join [sma_MST_AddressTypes] T
		on T.addnContactCategoryID = org.connContactCtg
			and T.addsCode = 'WRK'
	join Employer_Address_Helper help
		on help.case_id = upd.case_id
			and help.party_id = upd.party_id

	where
		ISNULL(upd.Employers_Address, '') <> ''
go


/* ########################################################
4.0 - Add phone number to the employer org contacts
*/
insert into [dbo].[sma_MST_ContactNumbers]
	(
		[cnnnContactCtgID],
		[cnnnContactID],
		[cnnnPhoneTypeID],
		[cnnsContactNumber],
		[cnnsExtension],
		[cnnbPrimary],
		[cnnbVisible],
		[cnnnAddressID],
		[cnnsLabelCaption],
		[cnnnRecUserID],
		[cnndDtCreated],
		[cnnnModifyUserID],
		[cnndDtModified],
		[cnnnLevelNo],
		[caseNo]
	)
	select
		org.connContactCtg							 as cnnnContactCtgID,
		org.connContactID							 as cnnnContactID,
		(
			select
				ctynContactNoTypeID
			from sma_MST_ContactNoType
			where ctysDscrptn = 'Office Phone'
				and ctynContactCategoryID = 2
		)											 as cnnnPhoneTypeID,
		dbo.FormatPhone(help.Employers_Phone_Number) as cnnsContactNumber,
		null										 as cnnsExtension,
		1											 as cnnbPrimary,
		null										 as cnnbVisible,
		A.addnAddressID								 as cnnnAddressID,
		null										 as cnnsLabelCaption,
		368											 as cnnnRecUserID,
		GETDATE()									 as cnndDtCreated,
		368											 as cnnnModifyUserID,
		GETDATE()									 as cnndDtModified,
		null,
		null
	from Employer_Address_Helper help
	join sma_MST_OrgContacts org
		on org.source_id = help.Employer
			and org.source_ref = 'user_party_data.employer'
	join [sma_MST_Address] A
		on A.addnContactID = org.connContactID
			and A.addnContactCtgID = org.connContactCtg
			and A.addbPrimary = 1
	where
		ISNULL(help.Employers_Phone_Number, '') <> ''