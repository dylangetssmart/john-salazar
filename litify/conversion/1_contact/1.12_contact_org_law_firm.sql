/* #######################################################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create individual and organization contacts

[0.0] Update schema
- 

[1.0] Individual Contacts					Target							Source
	-------------------------------------------------------------------------------------------------
	[1.1] Litify Contacts					sma_MST_IndvContacts			dbo.Contact
	[1.2] Litify Individual accounts		sma_MST_IndvContacts			dbo.Account
	[1.3] Law Firm Primary Contacts			sma_MST_IndvContacts			dbo.litify_pm__firm__c

[2.0] Organization Contacts					Target							Source
	-------------------------------------------------------------------------------------------------
	[2.1] Litify Business accounts			sma_MST_OrgContacts				dbo.Account
	[2.2] Law Firms							sma_MST_OrgContacts				dbo.litify_pm__firm__c

########################################################################################################################
*/

use ShinerSA
go

alter table sma_MST_OrgContacts disable trigger all
go

-- [2.2] Law firms
insert into sma_MST_OrgContacts
	(
	[conbPrimary], [connContactTypeID], [connContactSubCtgID], [consName], [conbStatus], [consEINNO], [consComments], [connContactCtg], [connRefByCtgID], [connReferredBy], [connContactPerson], [consWorkPhone], [conbPreventMailing], [connRecUserID], [condDtCreated], [connModifyUserID], [condDtModified], [connLevelNo], [consOtherName], [saga_char], [source_db], [source_ref]
	)
	select
		1					 as [conbprimary],
		(
			select
				octnOrigContactTypeID
			from sma_MST_OriginalContactTypes
			where octnContactCtgID = 2
				and octsDscrptn = 'Law Firm'
		)					 as [conncontacttypeid],
		''					 as [conncontactsubctgid],
		c.[Name]			 as [consname], --100 
		1					 as [conbstatus],
		null				 as [conseinno],	--30
		--isnull('Description: ' + nullif(convert(varchar,c.[description]),'') + CHAR(13),'') +
		''					 as [conscomments],
		2					 as [conncontactctg],
		null				 as [connrefbyctgid],
		null				 as [connreferredby],
		null				 as [conncontactperson],
		null				 as [consworkphone],
		0					 as [conbpreventmailing],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga_char = c.CreatedById
		)					 as [connrecuserid],
		c.CreatedDate		 as [conddtcreated],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga_char = c.LastModifiedById
		)					 as [connmodifyuserid],
		c.LastModifiedDate	 as [conddtmodified],
		0					 as [connlevelno],
		null				 as [consothername],
		c.[Id]				 as [saga_char],
		'litify'			 as [source_db],
		'litify_pm__Firm__c' as [source_ref]
	from ShinerLitify..[litify_pm__Firm__c] c
	left join sma_MST_OrgContacts org
		on org.saga_char = c.Id
	where
		org.connContactID is null
go

alter table sma_MST_OrgContacts enable trigger all