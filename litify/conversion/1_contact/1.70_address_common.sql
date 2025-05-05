/* #######################################################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create address records

-------------------------------------------------------------------------------------------------
Step								Target							Source
-------------------------------------------------------------------------------------------------
[0.0] Schema Update					--								Source
[1.0] Address Types					--								Source
[2.0] Temp Table					#Address						dbo.Contact
[2.0] Temp Table					#Address						dbo.Account
[3.0] Indv Addresses				sma_MST_Address					sma_MST_IndvContacts
[4.0] Org Addresses					sma_MST_Address					sma_MST_OrgContacts

##########################################################################################################################
*/

use ShinerSA
go

---------------------------------------------------
-- [0.0] Schema update
---------------------------------------------------
--alter table sma_MST_Address
--alter column [addsAddress1] VARCHAR(255)
--go

/* saga_char ---------------------------------------------------
- If saga_char exists and is not type VARCHAR(255), drop and re-add
---------------------------------------------------
*/
if exists (
		select
			1
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_MST_Address')
	)
begin
	if exists (
			select
				1
			from INFORMATION_SCHEMA.columns
			where TABLE_NAME = N'sma_MST_Address'
				and COLUMN_NAME = N'saga_char'
				and DATA_TYPE <> 'varchar(255)'
		)
	begin
		alter table [sma_MST_Address] drop column [saga_char];
		alter table [sma_MST_Address] add [saga_char] VARCHAR(255) null;
	end
end
else
begin
	alter table [sma_MST_Address] add [saga_char] VARCHAR(255) null;
end
go

-----------------------------------------------------
-- [1.0] Add address types
-----------------------------------------------------
insert sma_MST_AddressTypes
	(
	addsDscrptn,
	addnContactCategoryID
	)
	select
		'Other',
		1
	union
	select
		'Other',
		2
	union
	select
		'Billing',
		1
	union
	select
		'Billing',
		2
	union
	select
		'Shipping',
		1
	union
	select
		'Shipping',
		2
	union
	select
		'Office',
		1
	union
	select
		'Office',
		2
	except
	select
		addsDscrptn,
		addnContactCategoryID
	from sma_MST_AddressTypes
go

-----------------------------------------------------
-- [2.0] Temporary table to store address data
-----------------------------------------------------

-- Drop table if it exists
if OBJECT_ID('conversion.litify_address', 'U') is not null
begin
	drop table conversion.litify_address;
end
go

-- Create table
create table conversion.litify_address (
	id			 [INT] identity (1, 1) not null,
	contact_id	 VARCHAR(100),
	street		 VARCHAR(75),
	city		 VARCHAR(50),
	state		 VARCHAR(50),
	zip			 VARCHAR(10),
	country		 VARCHAR(30),
	address_type VARCHAR(20),
	source_table SYSNAME,
	constraint litify_address_Clustered_Index primary key clustered (id)
);
go

-- Create non-clustered indexes
create nonclustered index IX_litify_address_ContactID on conversion.litify_address (contact_id);
create nonclustered index IX_litify_address_Street on conversion.litify_address (street);
create nonclustered index IX_litify_address_City on conversion.litify_address (city);
create nonclustered index IX_litify_address_State on conversion.litify_address (state);
create nonclustered index IX_litify_address_Zip on conversion.litify_address (zip);
create nonclustered index IX_litify_address_Country on conversion.litify_address (country);
create nonclustered index IX_litify_address_AddressType on conversion.litify_address (address_type);
create nonclustered index IX_litify_address_SourceTable on conversion.litify_address (source_table);
go

insert into conversion.litify_address
	(
	contact_id,
	street,
	city,
	state,
	zip,
	country,
	address_type,
	source_table
	)
	select
		contact_id,
		street,
		city,
		state,
		zip,
		country,
		address_type,
		source_table
	from (
		-- Contact > Other
		select
			id as contact_id,
			LEFT(OtherStreet, 75) as street,
			LEFT(OtherCity, 50) as city,
			LEFT(OtherState, 50) as state,
			CAST(OtherPostalCode as VARCHAR(10)) as zip,
			LEFT(OtherCountry, 30) as country,
			'Other' as address_type,
			N'Contact' as source_table
		from ShinerLitify..Contact
		where ISNULL(OtherStreet, '') <> ''

		union

		-- Contact > Mailing
		select
			id as contact_id,
			LEFT(MailingStreet, 75) as street,
			LEFT(MailingCity, 50) as city,
			LEFT(MailingState, 50) as state,
			CAST([MailingPostalCode] as VARCHAR(10)) as zip,
			LEFT(MailingCountry, 30) as country,
			'Mailing' as address_type,
			N'Contact' as source_table
		from ShinerLitify..Contact
		where ISNULL(MailingStreet, '') <> ''

		union

		-- Account > Billing
		select
			id as contact_id,
			LEFT(BillingStreet, 75) as street,
			LEFT(BillingCity, 50) as city,
			LEFT(BillingState, 50) as state,
			CAST(BillingPostalCode as VARCHAR(10)) as zip,
			LEFT(BillingCountry, 30) as country,
			'Billing' as address_type,
			N'Account' as source_table
		from ShinerLitify..[Account]
		where ISNULL(BillingStreet, '') <> ''

		union

		-- Account > Shipping
		select
			id as contact_id,
			LEFT(ShippingStreet, 75) as street,
			LEFT(ShippingCity, 50) as city,
			LEFT(ShippingState, 50) as state,
			CAST(ShippingPostalCode as VARCHAR(10)) as zip,
			LEFT(ShippingCountry, 30) as country,
			'Shipping' as address_type,
			N'Account' as source_table
		from ShinerLitify..[Account]
		where ISNULL(ShippingStreet, '') <> ''

		union

		-- Firm > Office
		select
			id as contact_id,
			'' as street,
			LEFT(litify_pm__City__c, 50) as city,
			LEFT(litify_pm__State__c, 50) as state,
			'' as zip,
			'' as country,
			'Office' as address_type,
			N'litify_pm__Firm__c' as source_table
		from ShinerLitify..[litify_pm__Firm__c]
	) combined_addresses
go