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

---------------------------------------------------
-- [0.0] Update schema
---------------------------------------------------

begin
	-- sma_MST_IndvContacts
	if not exists (
			select
				*
			from sys.columns
			where Name = N'saga_ref'
				and object_id = OBJECT_ID(N'sma_MST_IndvContacts')
		)
	begin
		alter table sma_MST_IndvContacts
		add [saga_ref] NVARCHAR(50); -- ds 2024-09-12: add saga_ref to keep track of data source
	end


	--ALTER TABLE sma_MST_IndvContacts
	--ALTER COLUMN [cinsLastName] VARCHAR(70);

	-- sma_MST_OrgContacts
	--ALTER TABLE sma_MST_OrgContacts
	--ALTER COLUMN consName VARCHAR(110)

	alter table sma_MST_OrgContacts
	add [saga_ref] NVARCHAR(50); -- ds 2024-09-12: add saga_ref to keep track of data source
end

---------------------------------------------------
-- [1.0] Individual Contacts
---------------------------------------------------
alter table [sma_MST_IndvContacts] disable trigger all
go

-- [1.1] Litify Contacts
insert into [sma_MST_IndvContacts]
	(
	[cinbPrimary], [cinnContactTypeID], [cinnContactSubCtgID], [cinsPrefix], [cinsFirstName], [cinsMiddleName], [cinsLastName], [cinsSuffix], [cinsNickName], [cinbStatus], [cinsSSNNo], cinsEINNo, [cindBirthDate], [cinsComments], [cinnContactCtg], [cinnRefByCtgID], [cinnReferredBy], [cindDateOfDeath], [cinsCVLink], [cinnMaritalStatusID], [cinnGender], [cinsBirthPlace], [cinnCountyID], [cinsCountyOfResidence], [cinbFlagForPhoto], [cinsPrimaryContactNo], [cinsHomePhone], [cinsWorkPhone], [cinsMobile], [cinbPreventMailing], [cinnRecUserID], [cindDtCreated], [cinnModifyUserID], [cindDtModified], [cinnLevelNo], [cinsPrimaryLanguage], [cinsOtherLanguage], [cinbDeathFlag], [cinsCitizenship], [cinsHeight], [cinnWeight], [cinsReligion], [cindMarriageDate], [cinsMarriageLoc], [cinsDeathPlace], [cinsMaidenName], [cinsOccupation], [saga], [cinsSpouse], [cinsGrade], [saga_ref]
	)
	select distinct
		1				   as [cinbprimary],
		(
			select
				octnOrigContactTypeID
			from sma_MST_OriginalContactTypes
			where octnContactCtgID = 1
				and octsDscrptn = 'General'
		)				   as [cinncontacttypeid],
		null			   as [cinncontactsubctgid],
		''				   as [cinsprefix],
		FirstName		   as [cinsfirstname],	--30
		''				   as [cinsmiddlename],  --30
		LastName		   as [cinslastname],  --40
		''				   as [cinssuffix], -- 10
		null			   as [cinsnickname],
		1				   as [cinbstatus],
		null			   as [cinsssnno],
		null			   as cinseinno,
		c.Birthdate		   as [cindbirthdate],
		ISNULL('Description: ' + NULLIF(CONVERT(VARCHAR(MAX), c.[Description]), '') + CHAR(13), '') +
		''				   as [cinscomments],
		1				   as [cinncontactctg],
		''				   as [cinnrefbyctgid],
		''				   as [cinnreferredby],
		null			   as [cinddateofdeath],
		''				   as [cinscvlink],
		''				   as [cinnmaritalstatusid],
		case
			when c.litify_pm__Gender__c = 'female'
				then 2
			when c.litify_pm__Gender__c = 'male'
				then 1
			else 0
		end				   as [cinngender],
		''				   as [cinsbirthplace],
		1				   as [cinncountyid],
		1				   as [cinscountyofresidence],
		null			   as [cinbflagforphoto],
		null			   as [cinsprimarycontactno],
		''				   as [cinshomephone],
		''				   as [cinsworkphone],
		null			   as [cinsmobile],
		0				   as [cinbpreventmailing],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga = c.CreatedById
		)				   as [cinnrecuserid],
		--convert(datetime, left(created, 19))		as [cindDtCreated], 
		c.CreatedDate	   as [cinddtcreated],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga = c.LastModifiedById
		)				   as [cinnmodifyuserid],
		c.LastModifiedDate as [cinddtmodified],
		0				   as [cinnlevelno],
		''				   as [cinsprimarylanguage],
		''				   as [cinsotherlanguage],
		''				   as [cinbdeathflag],
		''				   as [cinscitizenship],
		null			   as [cinsheight],
		null			   as [cinnweight],
		''				   as [cinsreligion],
		null			   as [cindmarriagedate],
		''				   as [cinsmarriageloc],
		''				   as [cinsdeathplace],
		''				   as [cinsmaidenname],
		''				   as [cinsoccupation],
		[Id]			   as [saga],
		''				   as [cinsspouse],
		null			   as [cinsgrade],
		'contact'		   as [saga_ref]
	--Select max(len(lastname))
	from ShinerLitify..Contact c
	left join sma_MST_IndvContacts ind
		on ind.saga = c.Id
	where ind.cinnContactID is null
		and c.AccountId = '000000000000000AAA'	--only add records not associated with an account record
go

-- [1.2] "Litify Individual" accounts
insert into [sma_MST_IndvContacts]
	(
	[cinbPrimary], [cinnContactTypeID], [cinnContactSubCtgID], [cinsPrefix], [cinsFirstName], [cinsMiddleName], [cinsLastName], [cinsSuffix], [cinsNickName], [cinbStatus], [cinsSSNNo], cinsEINNo, [cindBirthDate], [cinsComments], [cinnContactCtg], [cinnRefByCtgID], [cinnReferredBy], [cindDateOfDeath], [cinsCVLink], [cinnMaritalStatusID], [cinnGender], [cinsBirthPlace], [cinnCountyID], [cinsCountyOfResidence], [cinbFlagForPhoto], [cinsPrimaryContactNo], [cinsHomePhone], [cinsWorkPhone], [cinsMobile], [cinbPreventMailing], [cinnRecUserID], [cindDtCreated], [cinnModifyUserID], [cindDtModified], [cinnLevelNo], [cinsPrimaryLanguage], [cinsOtherLanguage], [cinbDeathFlag], [cinsCitizenship], [cinsHeight], [cinnWeight], [cinsReligion], [cindMarriageDate], [cinsMarriageLoc], [cinsDeathPlace], [cinsMaidenName], [cinsOccupation], [saga], [cinsSpouse], [cinsGrade], [saga_ref]
	)
	select distinct
		1									 as [cinbprimary],
		case
			when c.[Type] = 'Doctor'
				then (
						select
							octnOrigContactTypeID
						from sma_MST_OriginalContactTypes
						where octnContactCtgID = 1
							and octsDscrptn = 'Doctor'
					)
			when c.[Type] = 'Judge'
				then (
						select
							octnOrigContactTypeID
						from sma_MST_OriginalContactTypes
						where octnContactCtgID = 1
							and octsDscrptn = 'Judge'
					)
			when c.[Type] in ('Attorney', 'Co-Counsel')
				then (
						select
							octnOrigContactTypeID
						from sma_MST_OriginalContactTypes
						where octnContactCtgID = 1
							and octsDscrptn = 'Attorney'
					)
			when c.[Type] = 'Adjuster'
				then (
						select
							octnOrigContactTypeID
						from sma_MST_OriginalContactTypes
						where octnContactCtgID = 1
							and octsDscrptn = 'Adjuster'
					)
			when c.[Type] = 'Clerk'
				then (
						select
							octnOrigContactTypeID
						from sma_MST_OriginalContactTypes
						where octnContactCtgID = 1
							and octsDscrptn = 'Law Clerk'
					)
			else (
					select
						octnOrigContactTypeID
					from sma_MST_OriginalContactTypes
					where octnContactCtgID = 1
						and octsDscrptn = 'General'
				)
		end									 as [cinncontacttypeid],
		null								 as [cinncontactsubctgid],
		litify_pm__Salutation__c			 as [cinsprefix],
		litify_pm__First_Name__c			 as [cinsfirstname],	--30
		''									 as [cinsmiddlename],  --30
		litify_pm__Last_Name__c				 as [cinslastname],  --40
		null								 as [cinssuffix], -- 10
		null								 as [cinsnickname],
		1									 as [cinbstatus],
		litify_pm__Social_Security_Number__c as [cinsssnno],
		null								 as cinseinno,
		c.litify_pm__Date_of_birth__c		 as [cindbirthdate],
		ISNULL('Description: ' + NULLIF(CONVERT(VARCHAR(MAX), c.[Description]), '') + CHAR(13), '') +
		''									 as [cinscomments],
		1									 as [cinncontactctg],
		''									 as [cinnrefbyctgid],
		''									 as [cinnreferredby],
		null								 as [cinddateofdeath],
		''									 as [cinscvlink],
		''									 as [cinnmaritalstatusid],
		case
			when c.litify_pm__Gender__c = 'female'
				then 2
			when c.litify_pm__Gender__c = 'male'
				then 1
			else 0
		end									 as [cinngender],
		''									 as [cinsbirthplace],
		1									 as [cinncountyid],
		1									 as [cinscountyofresidence],
		null								 as [cinbflagforphoto],
		null								 as [cinsprimarycontactno],
		''									 as [cinshomephone],
		''									 as [cinsworkphone],
		null								 as [cinsmobile],
		0									 as [cinbpreventmailing],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga = c.CreatedById
		)									 as [cinnrecuserid],
		--convert(datetime, left(created, 19))		as [cindDtCreated], 
		c.CreatedDate						 as [cinddtcreated],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga = c.LastModifiedById
		)									 as [cinnmodifyuserid],
		c.LastModifiedDate					 as [cinddtmodified],
		0									 as [cinnlevelno],
		null								 as [cinsprimarylanguage],
		''									 as [cinsotherlanguage],
		litify_pm__lit_Is_Deceased__c		 as [cinbdeathflag],
		''									 as [cinscitizenship],
		null								 as [cinsheight],
		null								 as [cinnweight],
		''									 as [cinsreligion],
		null								 as [cindmarriagedate],
		''									 as [cinsmarriageloc],
		''									 as [cinsdeathplace],
		''									 as [cinsmaidenname],
		''									 as [cinsoccupation],
		c.[Id]								 as [saga],
		--case when isnull(Spouse_Name__c,'') not in ('','Y','N/A') then Spouse_Name__c else '' end	as [cinsSpouse], 
		null								 as [cinsspouse],
		null								 as [cinsgrade],
		'account:LitifyIndividual'			 as [saga_ref]
	from ShinerLitify..[Account] c
	left join ShinerLitify..Contact ct
		on c.Id = ct.AccountId
	join ShinerLitify..RecordType rt
		on c.RecordTypeId = LEFT(rt.Id, 15)
			and rt.SobjectType = 'Account'
	left join sma_MST_IndvContacts ind
		on ind.saga = c.Id
	where ind.cinnContactID is null
		and rt.[Name] = 'Litify Individual'
		and ISNULL(litify_pm__Last_Name__c, '') <> ''
go

-- 	[1.3] Law firm primary contacts
insert into [sma_MST_IndvContacts]
	(
	[cinbPrimary], [cinnContactTypeID], [cinnContactSubCtgID], [cinsPrefix], [cinsFirstName], [cinsMiddleName], [cinsLastName], [cinsSuffix], [cinsNickName], [cinbStatus], [cinsSSNNo], cinsEINNo, [cindBirthDate], [cinsComments], [cinnContactCtg], [cinnRefByCtgID], [cinnReferredBy], [cindDateOfDeath], [cinsCVLink], [cinnMaritalStatusID], [cinnGender], [cinsBirthPlace], [cinnCountyID], [cinsCountyOfResidence], [cinbFlagForPhoto], [cinsPrimaryContactNo], [cinsHomePhone], [cinsWorkPhone], [cinsMobile], [cinbPreventMailing], [cinnRecUserID], [cindDtCreated], [cinnModifyUserID], [cindDtModified], [cinnLevelNo], [cinsPrimaryLanguage], [cinsOtherLanguage], [cinbDeathFlag], [cinsCitizenship], [cinsHeight], [cinnWeight], [cinsReligion], [cindMarriageDate], [cinsMarriageLoc], [cinsDeathPlace], [cinsMaidenName], [cinsOccupation], [saga], [cinsSpouse], [cinsGrade], [saga_ref]
	)
	select distinct
		1										 as [cinbprimary],
		(
			select
				octnOrigContactTypeID
			from sma_MST_OriginalContactTypes
			where octnContactCtgID = 1
				and octsDscrptn = 'General'
		)										 as [cinncontacttypeid],
		null									 as [cinncontactsubctgid],
		''										 as [cinsprefix],
		litify_pm__Primary_Contact_First_Name__c as [cinsfirstname],	--30
		''										 as [cinsmiddlename],  --30
		litify_pm__Primary_Contact_Last_Name__c	 as [cinslastname],  --40
		''										 as [cinssuffix], -- 10
		''										 as [cinsnickname],
		1										 as [cinbstatus],
		null									 as [cinsssnno],
		null									 as cinseinno,
		null									 as [cindbirthdate],
		--isnull('Description: ' + nullif(convert(varchar(max),c.[Description]),'') + CHAR(13),'') +
		''										 as [cinscomments],
		1										 as [cinncontactctg],
		''										 as [cinnrefbyctgid],
		''										 as [cinnreferredby],
		null									 as [cinddateofdeath],
		''										 as [cinscvlink],
		''										 as [cinnmaritalstatusid],
		0										 as [cinngender],
		''										 as [cinsbirthplace],
		1										 as [cinncountyid],
		1										 as [cinscountyofresidence],
		null									 as [cinbflagforphoto],
		null									 as [cinsprimarycontactno],
		''										 as [cinshomephone],
		''										 as [cinsworkphone],
		null									 as [cinsmobile],
		0										 as [cinbpreventmailing],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga = c.CreatedById
		)										 as [cinnrecuserid],
		--convert(datetime, left(created, 19))		as [cindDtCreated], 
		c.CreatedDate							 as [cinddtcreated],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga = c.LastModifiedById
		)										 as [cinnmodifyuserid],
		c.LastModifiedDate						 as [cinddtmodified],
		0										 as [cinnlevelno],
		''										 as [cinsprimarylanguage],
		''										 as [cinsotherlanguage],
		''										 as [cinbdeathflag],
		''										 as [cinscitizenship],
		null									 as [cinsheight],
		null									 as [cinnweight],
		''										 as [cinsreligion],
		null									 as [cindmarriagedate],
		''										 as [cinsmarriageloc],
		''										 as [cinsdeathplace],
		''										 as [cinsmaidenname],
		''										 as [cinsoccupation],
		c.[Id]									 as [saga],
		''										 as [cinsspouse],
		null									 as [cinsgrade],
		'litify_pm__Firm__c.primary_contact'	 as [saga_ref]
	--Select *
	from ShinerLitify..[litify_pm__Firm__c] c
	left join sma_MST_IndvContacts ind
		on ind.saga = c.Id
	where ind.cinnContactID is null
		and (ISNULL(litify_pm__Primary_Contact_First_Name__c, '') <> ''
		or ISNULL(litify_pm__Primary_Contact_Last_Name__c, '') <> '')

alter table [sma_MST_IndvContacts] enable trigger all
go


---------------------------------------------------
-- [2.0] Organization Contacts
---------------------------------------------------

-- [2.1] "Litify Business" accounts
insert into sma_MST_OrgContacts
	(
	[conbPrimary], [connContactTypeID], [connContactSubCtgID], [consName], [conbStatus], [consEINNO], [consComments], [connContactCtg], [connRefByCtgID], [connReferredBy], [connContactPerson], [consWorkPhone], [conbPreventMailing], [connRecUserID], [condDtCreated], [connModifyUserID], [condDtModified], [connLevelNo], [consOtherName], [saga], [saga_ref]
	)
	select
		1						 as [conbprimary],
		case
			when c.[Type] = 'Court'
				then (
						select
							octnOrigContactTypeID
						from sma_MST_OriginalContactTypes
						where octnContactCtgID = 2
							and octsDscrptn = 'Court'
					)
			when c.[Type] = 'Insurance Company'
				then (
						select
							octnOrigContactTypeID
						from sma_MST_OriginalContactTypes
						where octnContactCtgID = 2
							and octsDscrptn = 'Insurance Company'
					)
			when c.[Type] in ('Health Care Facility', 'Medical Provider', 'Doctor')
				then (
						select
							octnOrigContactTypeID
						from sma_MST_OriginalContactTypes
						where octnContactCtgID = 2
							and octsDscrptn = 'Hospital'
					)
			when c.[Type] in ('Attorney', 'Law Firm', 'Co-Counsel')
				then (
						select
							octnOrigContactTypeID
						from sma_MST_OriginalContactTypes
						where octnContactCtgID = 2
							and octsDscrptn = 'Law Firm'
					)
			when c.[Type] = 'Pharmacy'
				then (
						select
							octnOrigContactTypeID
						from sma_MST_OriginalContactTypes
						where octnContactCtgID = 2
							and octsDscrptn = 'Pharmacy'
					)
			-- ds 2024-10-02
			when c.[Type] in ('Police', 'Police Department')
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
						and octsDscrptn = 'General'
				)
		end						 as [conncontacttypeid],
		''						 as [conncontactsubctgid],
		LEFT(c.[Name], 110)		 as [consname], --100 
		1						 as [conbstatus],
		null					 as [conseinno],	--30
		ISNULL('Contact: ' + NULLIF((ISNULL(litify_pm__First_Name__c, '') + ' ' + ISNULL(litify_pm__Last_Name__c, '')), '') + CHAR(13), '') +
		ISNULL('Description: ' + NULLIF(CONVERT(VARCHAR, c.[Description]), '') + CHAR(13), '') +
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
			where saga = c.CreatedById
		)						 as [connrecuserid],
		c.CreatedDate			 as [conddtcreated],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga = c.LastModifiedById
		)						 as [connmodifyuserid],
		c.LastModifiedDate		 as [conddtmodified],
		0						 as [connlevelno],
		null					 as [consothername],
		c.[Id]					 as [saga],
		'account:LitifyBusiness' as [saga_ref]
	--Select max(len(name))
	from ShinerLitify..[Account] c
	left join ShinerLitify..Contact ct
		on ct.AccountId = c.Id
	join ShinerLitify..RecordType rt
		on c.RecordTypeId = LEFT(rt.Id, 15)
			and rt.SobjectType = 'Account'
	left join sma_MST_OrgContacts org
		on org.saga = c.Id
	where org.connContactID is null
		and (rt.[Name] = 'Litify Business'
		or (rt.[Name] = 'Litify Individual'
		and ISNULL(litify_pm__Last_Name__c, '') = ''))
go

--SELECT * from  ShinerLitify..[Account] WHERE type = 'police'

-- [2.2] Law firms
insert into sma_MST_OrgContacts
	(
	[conbPrimary], [connContactTypeID], [connContactSubCtgID], [consName], [conbStatus], [consEINNO], [consComments], [connContactCtg], [connRefByCtgID], [connReferredBy], [connContactPerson], [consWorkPhone], [conbPreventMailing], [connRecUserID], [condDtCreated], [connModifyUserID], [condDtModified], [connLevelNo], [consOtherName], [saga], [saga_ref]
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
			where saga = c.CreatedById
		)					 as [connrecuserid],
		c.CreatedDate		 as [conddtcreated],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga = c.LastModifiedById
		)					 as [connmodifyuserid],
		c.LastModifiedDate	 as [conddtmodified],
		0					 as [connlevelno],
		null				 as [consothername],
		c.[Id]				 as [saga],
		'litify_pm__Firm__c' as [saga_ref]
	from ShinerLitify..[litify_pm__Firm__c] c
	left join sma_MST_OrgContacts org
		on org.saga = c.Id
	where org.connContactID is null
