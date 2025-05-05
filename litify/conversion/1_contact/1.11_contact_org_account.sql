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

---------------------------------------------------
-- [2.0] Organization Contacts
---------------------------------------------------

-- [2.1] "Litify Business" accounts
insert into sma_MST_OrgContacts
	(
		[conbPrimary],
		[connContactTypeID],
		[connContactSubCtgID],
		[consName],
		[conbStatus],
		[consEINNO],
		[consComments],
		[connContactCtg],
		[connRefByCtgID],
		[connReferredBy],
		[connContactPerson],
		[consWorkPhone],
		[conbPreventMailing],
		[connRecUserID],
		[condDtCreated],
		[connModifyUserID],
		[condDtModified],
		[connLevelNo],
		[consOtherName],
		[saga_char],
		[source_db],
		[source_ref]
	)
	select distinct
		1						 as [conbprimary],
		case
			when a.[Type] = 'Court'
				then (
						select
							octnOrigContactTypeID
						from sma_MST_OriginalContactTypes
						where octnContactCtgID = 2
							and octsDscrptn = 'Court'
					)
			when a.[Type] = 'Insurance Company'
				then (
						select
							octnOrigContactTypeID
						from sma_MST_OriginalContactTypes
						where octnContactCtgID = 2
							and octsDscrptn = 'Insurance Company'
					)
			when a.[Type] in ('Health Care Facility', 'Medical Provider', 'Doctor')
				then (
						select
							octnOrigContactTypeID
						from sma_MST_OriginalContactTypes
						where octnContactCtgID = 2
							and octsDscrptn = 'Hospital'
					)
			when a.[Type] in ('Attorney', 'Law Firm', 'Co-Counsel')
				then (
						select
							octnOrigContactTypeID
						from sma_MST_OriginalContactTypes
						where octnContactCtgID = 2
							and octsDscrptn = 'Law Firm'
					)
			when a.[Type] = 'Pharmacy'
				then (
						select
							octnOrigContactTypeID
						from sma_MST_OriginalContactTypes
						where octnContactCtgID = 2
							and octsDscrptn = 'Pharmacy'
					)
			-- ds 2024-10-02
			when a.[Type] in ('Police', 'Police Department')
				then (
						select
							octnOrigContactTypeID
						from sma_MST_OriginalContactTypes
						where octnContactCtgID = 2
							and octsDscrptn = 'Police'
					)
			else (
					select
						octnOrigContactTypeID
					from sma_MST_OriginalContactTypes
					where octnContactCtgID = 2
						and octsDscrptn = 'General Unspecified'
				)
		end						 as [conncontacttypeid],
		''						 as [conncontactsubctgid],
		LEFT(a.[Name], 110)		 as [consname], --100 
		1						 as [conbstatus],
		null					 as [conseinno],	--30
		ISNULL('Contact: ' + NULLIF((ISNULL(litify_pm__First_Name__c, '') + ' ' + ISNULL(litify_pm__Last_Name__c, '')), '') + CHAR(13), '') +
		ISNULL('Description: ' + NULLIF(CONVERT(VARCHAR, a.[Description]), '') + CHAR(13), '') +
		''						 as [conscomments],
		2						 as [conncontactctg],
		null					 as [connrefbyctgid],
		null					 as [connreferredby],
		null					 as [conncontactperson],
		null					 as [consworkphone],
		0						 as [conbpreventmailing],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga_char = a.CreatedById
		)						 as [connrecuserid],
		a.CreatedDate			 as [conddtcreated],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga_char = a.LastModifiedById
		)						 as [connmodifyuserid],
		a.LastModifiedDate		 as [conddtmodified],
		0						 as [connlevelno],
		null					 as [consothername],
		a.[Id]					 as [saga_char],
		'litify'				 as [source_db],
		'account:Litify Business' as [source_ref]
	--select a.*
	from conversion.cases_to_convert ctc
	-- Role
	join ShinerLitify..litify_pm__Role__c role
		on role.litify_pm__Matter__c = ctc.matter_id
	-- Account
	join ShinerLitify..Account a
		on a.Id = role.litify_pm__Party__c
	-- RecordType
	join ShinerLitify..RecordType rt
		on a.RecordTypeId = LEFT(rt.Id, 15)
			and rt.SobjectType = 'Account'
	left join sma_MST_OrgContacts org
		on org.saga_char = a.Id
	-- where org.id doesnt exist
	-- and rt.Name = Litify Business
	where
		org.connContactID is null
		and (
			rt.[Name] = 'Litify Business' or (rt.[Name] = 'Litify Individual' and ISNULL(litify_pm__Last_Name__c, '') = '')
		)
		--and ctc.matter_id = 'a0L8Z00000eDaxBUAS'

--select *
--from ShinerLitify..[Account] c
--left join ShinerLitify..Contact ct
--	on ct.AccountId = c.Id
--join ShinerLitify..RecordType rt
--	on c.RecordTypeId = LEFT(rt.Id, 15)
--		and rt.SobjectType = 'Account'
---- Only convert contacts that exist as a party in a case
--join ShinerLitify..litify_pm__Role__c role
--	on role.litify_pm__Party__c = c.Id
--join conversion.cases_to_convert ctc
--	on ctc.matter_id = role.litify_pm__Matter__c
--left join sma_MST_OrgContacts org
--	on org.saga_char = c.Id
--where
--	org.connContactID is null
--	and
--	(rt.[Name] = 'Litify Business'
--	or
--	(rt.[Name] = 'Litify Individual'
--	and
--	ISNULL(litify_pm__Last_Name__c, '') = ''))
go

alter table sma_MST_OrgContacts enable trigger all