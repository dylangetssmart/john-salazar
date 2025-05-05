/* ######################################################################################
description: Email addresses
steps:
	- Insert [sma_MST_EmailWebsite]
usage_instructions:
	-
dependencies:
	- 
notes:
	-
#########################################################################################
*/

use ShinerSA
go

-----------------------------------------
-- [ 2.0] EMAIL ADDRESSES
-----------------------------------------

-----------------------------------------------------
-- [2.0] Temporary table to store address data
-----------------------------------------------------

-- Drop table if it exists
if OBJECT_ID('conversion.litify_email_address', 'U') is not null
begin
	drop table conversion.litify_email_address;
end
go

-- Create table
create table conversion.litify_email_address (
	id			  [INT] identity (1, 1) not null,
	contact_id	  VARCHAR(100),
	email_address VARCHAR(255),
	source_table  SYSNAME
	constraint litify_email_address_Clustered_Index primary key clustered (id)
);
go

-- Create non-clustered indexes
create nonclustered index IX_litify_email_address_contact_id on conversion.litify_email_address (contact_id);
create nonclustered index IX_litify_email_address_email_address on conversion.litify_email_address (email_address);
create nonclustered index IX_litify_email_address_source_table on conversion.litify_email_address (source_table);
go

insert into conversion.litify_email_address
	(
	contact_id,
	email_address,
	source_table
	)
	select
		contact_id,
		email_address,
		source_table
	from (
		-- Contact Email
		select
			id as contact_id,
			LEFT(Email, 255) as email_address,
			N'Contact' as source_table
		from ShinerLitify..Contact
		where ISNULL(Email, '') <> ''

		union

		-- Account Email
		select
			id as contact_id,
			LEFT(litify_pm__Email__c, 255) as email_address,
			N'Account' as source_table
		from ShinerLitify..Account a
		where ISNULL(a.litify_pm__Email__c, '') <> ''

		union

		-- Firm Primary Contact Email
		select
			id as contact_id,
			LEFT(firm.litify_pm__Primary_Contact_Email__c, 255) as email_address,
			N'litify_pm__Firm__c' as source_table
		from ShinerLitify..litify_pm__Firm__c firm
		where ISNULL(firm.litify_pm__Primary_Contact_Email__c, '') <> ''
	) email_addresses
go

-- [2.1] Indv Email
insert into [sma_MST_EmailWebsite]
	(
	[cewnContactCtgID],
	[cewnContactID],
	[cewsEmailWebsiteFlag],
	[cewsEmailWebSite],
	[cewbDefault],
	[cewnComments],
	[cewnRecUserID],
	[cewdDtCreated],
	[cewnModifyUserID],
	[cewdDtModified],
	[cewnLevelNo],
	[saga]
	)
	select
		ind.cinnContactCtg as cewncontactctgid,
		ind.cinnContactID  as cewncontactid,
		'E'				   as cewsemailwebsiteflag,
		lea.email_address  as cewsemailwebsite,
		null			   as cewbdefault,
		''				   as [cewncomments],
		ind.cinnRecUserID  as cewnrecuserid,
		ind.cindDtCreated  as cewddtcreated,
		null			   as cewnmodifyuserid,
		ind.cindDtModified as cewddtmodified,
		null,
		lea.contact_id	   as saga -- indicate email
	from conversion.litify_email_address lea
	join sma_MST_IndvContacts ind
		on ind.saga_char = lea.contact_id
--FROM (
--	SELECT
--		ID
--	   ,Email AS email
--	FROM ShinerLitify..Contact
--	WHERE ISNULL(email, '') <> ''
--	UNION
--	SELECT
--		ID
--	   ,litify_pm__Email__c AS email
--	FROM ShinerLitify..Account
--	WHERE ISNULL(litify_pm__Email__c, '') <> ''
--	UNION
--	SELECT
--		ID
--	   ,litify_pm__Primary_Contact_Email__c AS email
--	FROM ShinerLitify..litify_pm__Firm__c
--	WHERE ISNULL(litify_pm__Primary_Contact_Email__c, '') <> ''
--) e
--JOIN [sma_MST_IndvContacts] ind
--	ON ind.saga_char = e.ID
go

-- [2.2] ORG EMAIL
insert into [sma_MST_EmailWebsite]
	(
	[cewnContactCtgID],
	[cewnContactID],
	[cewsEmailWebsiteFlag],
	[cewsEmailWebSite],
	[cewbDefault],
	[cewnComments],
	[cewnRecUserID],
	[cewdDtCreated],
	[cewnModifyUserID],
	[cewdDtModified],
	[cewnLevelNo],
	[saga]
	)
	select
		org.connContactCtg as cewncontactctgid,
		org.connContactID  as cewncontactid,
		'E'				   as cewsemailwebsiteflag,
		lea.email_address  as cewsemailwebsite,
		null			   as cewbdefault,
		''				   as [cewncomments],
		org.connRecUserID  as cewnrecuserid,
		org.condDtCreated  as cewddtcreated,
		null			   as cewnmodifyuserid,
		org.condDtModified as cewddtmodified,
		null,
		lea.contact_id	   as saga -- indicate email
	from conversion.litify_email_address lea
	join sma_MST_OrgContacts org
		on org.saga_char = lea.contact_id
--FROM (
--	SELECT
--		ID
--	   ,Email AS email
--	FROM ShinerLitify..Contact
--	WHERE ISNULL(email, '') <> ''
--	UNION
--	SELECT
--		ID
--	   ,litify_pm__Email__c AS email
--	FROM ShinerLitify..Account
--	WHERE ISNULL(litify_pm__Email__c, '') <> ''
--) e
--JOIN [sma_MST_OrgContacts] org
--	ON org.saga_char = e.Id
go

---------------------------------------------------
-- [1.2] Users
---------------------------------------------------
insert into [sma_MST_EmailWebsite]
	(
	[cewnContactCtgID],
	[cewnContactID],
	[cewsEmailWebsiteFlag],
	[cewsEmailWebSite],
	[cewbDefault],
	[cewnRecUserID],
	[cewdDtCreated],
	[cewnModifyUserID],
	[cewdDtModified],
	[cewnLevelNo],
	[saga]
	)
	select
		ind.cinnContactCtg as cewncontactctgid,
		ind.cinnContactID  as cewncontactid,
		'E'				   as cewsemailwebsiteflag,
		u.Email			   as cewsemailwebsite,
		null			   as cewbdefault,
		368				   as cewnrecuserid,
		GETDATE()		   as cewddtcreated,
		368				   as cewnmodifyuserid,
		GETDATE()		   as cewddtmodified,
		null,
		null			   as saga -- indicate email
	from ShinerLitify..[User] u
	join [sma_MST_IndvContacts] ind
		on ind.saga_char = u.[Id]
go