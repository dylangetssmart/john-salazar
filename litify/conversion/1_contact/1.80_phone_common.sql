/* ######################################################################################
description: Handles common operations related to [sma_MST_IndvContacts]
steps:
	- Create helper table [LitifyPhoneNumbers]
	- Insert [sma_MST_ContactNoType]
usage_instructions:
	-
dependencies:
	- 
notes:
	- LitifyPhoneNumbers
	- sma_MST_ContactNoType
#########################################################################################
*/

use ShinerSA
go

-----------------------------------------------------
-- Contact Number types
-----------------------------------------------------
insert into sma_MST_ContactNoType
	(
	ctysDscrptn,
	ctynContactCategoryID,
	ctysDefaultTexting
	)
	select
		'Work',
		1,
		0
	union
	select
		'Home',
		2,
		0
	union
	select
		'Cell',
		1,
		0
	union
	select
		'Cell',
		2,
		0
	union
	select
		'Other',
		1,
		0
	union
	select
		'Other',
		2,
		0
	union
	select
		'Fax',
		1,
		0
	union
	select
		'Fax',
		2,
		0
	except
	select
		ctysDscrptn,
		ctynContactCategoryID,
		ctysDefaultTexting
	from sma_MST_ContactNoType
go

-----------------------------------------------------
-- Helper table [litify_phone]
-----------------------------------------------------

-- Drop table if it exists
if OBJECT_ID('conversion.litify_phone', 'U') is not null
begin
	drop table conversion.litify_phone;
end
go

create table conversion.litify_phone (
	id			 [INT] identity (1, 1) not null,
	contact_id	 VARCHAR(100),
	phone		 VARCHAR(30),
	phone_type	 VARCHAR(20),
	source_table SYSNAME
	constraint litify_phone_Clustered_Index primary key clustered (id)
)
create nonclustered index IX_NonClustered_Index_litify_phone_ID on conversion.litify_phone (ID);
create nonclustered index IX_NonClustered_Index_litify_phone_Phone on conversion.litify_phone (phone);
create nonclustered index IX_NonClustered_Index_litify_phone_PhoneType on conversion.litify_phone (phone_type);
create nonclustered index IX_NonClustered_Index_litify_phone_SourceTable on conversion.litify_phone (source_table);
go


insert into conversion.litify_phone
	(
	contact_id,
	phone,
	phone_type,
	source_table
	)
	select
		contact_id,
		phone,
		phone_type,
		source_table
	from (
		-- Contact > Phone
		select
			id as contact_id,
			CONVERT(VARCHAR, phone) as phone,
			'Phone' as phone_type,
			N'Contact' as source_table
		from ShinerLitify..Contact
		where ISNULL(phone, '') <> ''
		union
		-- Contact > Cell
		select
			id as contact_id,
			CONVERT(VARCHAR, MobilePhone) as phone,
			'Cell' as phone_type,
			N'Contact' as source_table
		from ShinerLitify..Contact
		where ISNULL(MobilePhone, '') <> ''
		union
		-- Contact > Fax
		select
			id as contact_id,
			CONVERT(VARCHAR, Fax) as phone,
			'Fax' as phone_type,
			N'Contact' as source_table
		from ShinerLitify..Contact
		where ISNULL(Fax, '') <> ''
		union
		-- Contact > Home
		select
			id as contact_id,
			CONVERT(VARCHAR, HomePhone) as phone,
			'Home' as phone_type,
			N'Contact' as source_table
		from ShinerLitify..Contact
		where ISNULL(HomePhone, '') <> ''
		union
		-- Contact > Other
		select
			id as contact_id,
			CONVERT(VARCHAR, OtherPhone) as phone,
			'Other' as phone_type,
			N'Contact' as source_table
		from ShinerLitify..Contact
		where ISNULL(OtherPhone, '') <> ''
		union
		-- Account > Phone
		select
			id as contact_id,
			CONVERT(VARCHAR, phone) as phone,
			'Phone' as phone_type,
			N'Account' as source_table
		from ShinerLitify..Account
		where ISNULL(phone, '') <> ''
		union
		-- Account > Fax
		select
			id as contact_id,
			CONVERT(VARCHAR, Fax) as phone,
			'Fax' as phone_type,
			N'Account' as source_table
		from ShinerLitify..Account
		where ISNULL(Fax, '') <> ''
		union
		-- Account > Home
		select
			id as contact_id,
			CONVERT(VARCHAR, litify_pm__Phone_Home__c) as phone,
			'Home' as phone_type,
			N'Account' as source_table
		from ShinerLitify..Account
		where ISNULL(litify_pm__Phone_Home__c, '') <> ''
		union
		-- Account > Cell
		select
			id as contact_id,
			CONVERT(VARCHAR, litify_pm__Phone_Mobile__c) as phone,
			'Cell' as phone_type,
			N'Account' as source_table
		from ShinerLitify..Account
		where ISNULL(litify_pm__Phone_Mobile__c, '') <> ''
		union
		-- Account > Other
		select
			id as contact_id,
			CONVERT(VARCHAR, litify_pm__Phone_Other__c) as phone,
			'Other' as phone_type,
			N'Account' as source_table
		from ShinerLitify..Account
		where ISNULL(litify_pm__Phone_Other__c, '') <> ''
		union
		-- Account > Work
		select
			id as contact_id,
			CONVERT(VARCHAR, litify_pm__Phone_Work__c) as phone,
			'Work' as phone_type,
			N'Account' as source_table
		from ShinerLitify..Account
		where ISNULL(litify_pm__Phone_Work__c, '') <> ''
	) p
go