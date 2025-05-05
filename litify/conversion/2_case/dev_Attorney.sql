/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-23
Description: Create attorneys

--------------------------------------------------------------------------------------------------------------------------------------
Step								Object								Action			Source				
--------------------------------------------------------------------------------------------------------------------------------------
[1] Attorney Types					sma_MST_AttorneyTypes				insert			litify_pm__Role__c

[2] Plaintiff Attorneys
	[2.1]							sma_TRN_PlaintiffAttorney			insert			litify_pm__Originating_Attorney__c, litify_pm__Principal_Attorney__c
	[2.2]							sma_TRN_PlaintiffAttorney			insert			litify_pm__Role__c

[3] Defense Attorneys	
	[3.0]							sma_TRN_LawFirms					insert			litify_pm__Role__c

[4] Attorney Lists
	[4.1] Plaintiff Attorneys		sma_TRN_LawFirmAttorneys			insert			sma_TRN_LawFirms
	[4.2] Defense Attorneys			sma_TRN_LawFirmAttorneys			insert			sma_TRN_PlaintiffAttorney
						
##########################################################################################################################
*/

use ShinerSA
go

/*
alter table [sma_TRN_PlaintiffAttorney] disable trigger all
delete from [sma_TRN_PlaintiffAttorney] 
DBCC CHECKIDENT ('[sma_TRN_PlaintiffAttorney]', RESEED, 0);
alter table [sma_TRN_PlaintiffAttorney] enable trigger all

alter table [sma_TRN_LawFirms] disable trigger all
delete from [sma_TRN_LawFirms] 
DBCC CHECKIDENT ('[sma_TRN_LawFirms]', RESEED, 0);
alter table [sma_TRN_LawFirms] enable trigger all

alter table [sma_TRN_LawFirmAttorneys] disable trigger all
delete from [sma_TRN_LawFirmAttorneys] 
DBCC CHECKIDENT ('[sma_TRN_LawFirmAttorneys]', RESEED, 0);
alter table [sma_TRN_LawFirmAttorneys] enable trigger all
*/

-----------------------------------------------------------------------------------
-- Validation

--SELECT id, litify_pm__Originating_Attorney__c, litify_pm__Principal_Attorney__c, Hearing_Attorney__c, Dual_Rep_Attorney__c, Co_Counsel_Joint_Venture_Attorney__c
--FROM [ShinerLitify]..litify_pm__Matter__c 
--WHERE isnull(litify_pm__Originating_Attorney__c,'')<>'' or isnull(litify_pm__Principal_Attorney__c,'') <>'' or isnull(Hearing_Attorney__c,'') <> '' or isnull(Dual_Rep_Attorney__c,'') <> '' or isnull(Co_Counsel_Joint_Venture_Attorney__c,'') <> ''



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------
-- [1] INSERT ATTORNEY TYPES
-----------------------------------------------------------------------------------
insert into sma_MST_AttorneyTypes
	(
	atnsAtorneyDscrptn
	)
	select
		'Originating Attorney'
	union
	select
		'Principal Attorney'
	union
	select distinct
		litify_pm__Role__c
	from ShinerLitify..litify_pm__Role__c
	where litify_pm__Role__c in ('Attorney', 'Law Firm')
	except
	select
		atnsAtorneyDscrptn
	from sma_MST_AttorneyTypes


-- 0.0 Triggers
alter table [sma_TRN_PlaintiffAttorney] disable trigger all
go

alter table [sma_TRN_LawFirms] disable trigger all
go

alter table [sma_TRN_LawFirmAttorneys] disable trigger all
go


--------------------------------------
-- [2] PLAINTIFF ATTONEYS
--------------------------------------
insert into [sma_TRN_PlaintiffAttorney]
	(
	[planPlaintffID],
	[planCaseID],
	[planPlCtgID],
	[planPlContactID],
	[planLawfrmAddID],
	[planLawfrmContactID],
	[planAtorneyAddID],
	[planAtorneyContactID],
	[planAtnTypeID],
	[plasFileNo],
	[planRecUserID],
	[pladDtCreated],
	[planModifyUserID],
	[pladDtModified],
	[planLevelNo],
	[planRefOutID],
	[plasComments]
	)
	select distinct
		t.plnnPlaintiffID as [planplaintffid],
		cas.casnCaseID	  as [plancaseid],
		t.plnnContactCtg  as [planplctgid],
		t.plnnContactID	  as [planplcontactid],
		case
			when ioc.CTG = 2
				then ioc.AID
			else null
		end				  as [planlawfrmaddid],
		case
			when ioc.CTG = 2
				then ioc.CID
			else null
		end				  as [planlawfrmcontactid],
		case
			when ioc.CTG = 1
				then ioc.AID
			else null
		end				  as [planatorneyaddid],
		case
			when ioc.CTG = 1
				then ioc.CID
			else null
		end				  as [planatorneycontactid],
		(
			select
				atnnAtorneyTypeID
			from sma_MST_AttorneyTypes
			where atnsAtorneyDscrptn = m.attytype
		)				  as [planatntypeid],
		null			  as [plasfileno], --	 UD.Their_File_Number
		368				  as [planrecuserid],
		GETDATE()		  as [pladdtcreated],
		null			  as [planmodifyuserid],
		null			  as [pladdtmodified],
		0				  as [planlevelno],
		null			  as [planrefoutid],
		--isnull('comments : ' + nullif(convert(varchar(max),C.comments) ,'') + CHAR(13),'') +
		--isnull('Attorney for party : ' + nullif(convert(varchar(max),IOCP.name) ,'') + CHAR(13),'') +
		''				  as [plascomments]
	from (
		select
			Id,
			litify_pm__Originating_Attorney__c as atty,
			'Originating Attorney' as attytype
		from [ShinerLitify]..litify_pm__Matter__c
		where ISNULL(litify_pm__Originating_Attorney__c, '') <> ''
		union
		select
			Id,
			litify_pm__Principal_Attorney__c as atty,
			'Principal Attorney' as attytype
		from [ShinerLitify]..litify_pm__Matter__c
		where ISNULL(litify_pm__Principal_Attorney__c, '') <> ''
	) m
	join [sma_TRN_Cases] cas
		on cas.Litify_saga = m.Id
	left join IndvOrgContacts_Indexed ioc
		on ioc.saga_char = m.atty
			and ioc.CTG = 1
	left join IndvOrgContacts_Indexed iocp
		on iocp.SAGA_char = m.atty
			and iocp.CTG = 2
	join [sma_TRN_Plaintiff] t
		on t.plnnCaseID = cas.casnCaseID
			and t.plnbIsPrimary = 1
go


insert into [sma_TRN_PlaintiffAttorney]
	(
	[planPlaintffID],
	[planCaseID],
	[planPlCtgID],
	[planPlContactID],
	[planLawfrmAddID],
	[planLawfrmContactID],
	[planAtorneyAddID],
	[planAtorneyContactID],
	[planAtnTypeID],
	[plasFileNo],
	[planRecUserID],
	[pladDtCreated],
	[planModifyUserID],
	[pladDtModified],
	[planLevelNo],
	[planRefOutID],
	[plasComments]
	)
	select distinct
		ISNULL(t.plnnPlaintiffID, (
			select
				plnnPlaintiffID
			from [sma_TRN_Plaintiff] pl
			where pl.plnnCaseID = cas.casnCaseID
				and pl.plnbIsPrimary = 1
		))				 as [planplaintffid],
		cas.casnCaseID	 as [plancaseid],
		t.plnnContactCtg as [planplctgid],
		t.plnnContactID	 as [planplcontactid],
		iocp.AID		 as [planlawfrmaddid],
		iocp.CID		 as [planlawfrmcontactid],
		ioc.AID			 as [planatorneyaddid],
		ioc.CID			 as [planatorneycontactid],
		(
			select
				atnnAtorneyTypeID
			from sma_MST_AttorneyTypes
			where atnsAtorneyDscrptn = m.litify_pm__Role__c
		)				 as [planatntypeid],
		null			 as [plasfileno], --	 UD.Their_File_Number
		368				 as [planrecuserid],
		GETDATE()		 as [pladdtcreated],
		null			 as [planmodifyuserid],
		null			 as [pladdtmodified],
		0				 as [planlevelno],
		null			 as [planrefoutid],
		ISNULL('SubType: ' + NULLIF(CONVERT(VARCHAR(MAX), m.litify_pm__Subtype__c), '') + CHAR(13), '') +
		''				 as [plascomments]
	--select *
	from [ShinerLitify]..litify_pm__Role__c m
	join [sma_TRN_Cases] cas
		on cas.saga_char = m.litify_pm__Matter__c
	left join IndvOrgContacts_Indexed ioc
		on ioc.saga_char = m.litify_pm__Party__c
			and ioc.CTG = 1
	left join IndvOrgContacts_Indexed iocp
		on iocp.saga_char = m.litify_pm__Party__c
			and iocp.CTG = 2
	left join [ShinerLitify]..litify_pm__Role__c parent
		on parent.Id = m.litify_pm__Parent_Role__c
	left join IndvOrgContacts_Indexed parentioc
		on parentioc.SAGA_char = parent.litify_pm__Party__c
	left join [sma_TRN_Plaintiff] t
		on t.plnnCaseID = cas.casnCaseID
			and parentioc.CTG = t.[plnnContactCtg]
			and parentioc.CID = t.[plnnContactID]
	where m.litify_pm__Role__c in ('Attorney', 'Law Firm')


--------------------------------------
-- [3] DEFENSE ATTORNEYS
--------------------------------------
insert into [sma_TRN_LawFirms]
	(
	[lwfnLawFirmContactID],
	[lwfnLawFirmAddressID],
	[lwfnAttorneyContactID],
	[lwfnAttorneyAddressID],
	[lwfnAttorneyTypeID],
	[lwfsFileNumber],
	[lwfnRoleType],
	[lwfnContactID],
	[lwfnRecUserID],
	[lwfdDtCreated],
	[lwfnModifyUserID],
	[lwfdDtModified],
	[lwfnLevelNo],
	[lwfnAdjusterID],
	[lwfsComments]
	)
	select distinct
		case
			when ioc.CTG = 2
				then ioc.CID
			else null
		end				  as [lwfnlawfirmcontactid],
		case
			when ioc.CTG = 2
				then ioc.AID
			else null
		end				  as [lwfnlawfirmaddressid],
		case
			when ioc.CTG = 1
				then ioc.CID
			else null
		end				  as [lwfnattorneycontactid],
		case
			when ioc.CTG = 1
				then ioc.AID
			else null
		end				  as [lwfnattorneyaddressid],
		(
			select
				atnnAtorneyTypeID
			from [sma_MST_AttorneyTypes]
			where atnsAtorneyDscrptn = m.litify_pm__Role__c
		)				  as [lwfnattorneytypeid],
		null			  as [lwfsfilenumber],
		2				  as [lwfnroletype],
		t.defnDefendentID as [lwfncontactid],
		368				  as [lwfnrecuserid],
		GETDATE()		  as [lwfddtcreated],
		cas.casnCaseID	  as [lwfnmodifyuserid],
		GETDATE()		  as [lwfddtmodified],
		null			  as [lwfnlevelno],
		null			  as [lwfnadjusterid],
		--isnull('comments : ' + nullif(convert(varchar(max),C.comments) ,'') + CHAR(13),'') +
		--isnull('Attorney for party : ' + nullif(convert(varchar(max),IOCD.name) ,'') + CHAR(13),'') +
		''				  as [lwfscomments]
	from [ShinerLitify]..litify_pm__Role__c m
	join [sma_TRN_Cases] cas
		on cas.saga_char = m.litify_pm__Matter__c
	left join IndvOrgContacts_Indexed ioc
		on ioc.saga_char = m.litify_pm__Party__c
			and ioc.CTG = 1
	left join IndvOrgContacts_Indexed iocp
		on iocp.saga_char = m.litify_pm__Party__c
			and iocp.CTG = 2
	join [sma_TRN_Defendants] t
		on t.defnCaseID = cas.casnCaseID
			and defbIsPrimary = 1
	where litify_pm__Role__c in ('Law Firm', 'Attorney')
go

--select
--	*
--from [ShinerLitify]..litify_pm__Role__c

--------------------------------------
-- [4] Attorney List
--------------------------------------

-- [4.1] Plaintiff Attorney list
insert into sma_TRN_LawFirmAttorneys
	(
	SourceTableRowID,
	UniqueContactId,
	IsDefendant,
	IsPrimary
	)
	select
		a.lawfirmid			as sourcetablerowid,
		a.attorneycontactid as uniqueaontactid,
		0					as isdefendant, --0:Plaintiff
		case
			when a.sequencenumber = 1
				then 1
			else 0
		end					as isprimary
	from (
		select
			f.planAtnID as lawfirmid,
			ac.UniqueContactId as attorneycontactid,
			ROW_NUMBER() over (partition by f.planCaseID order by f.planAtnID) as sequencenumber
		from [sma_TRN_PlaintiffAttorney] f
		left join sma_MST_AllContactInfo ac
			on ac.ContactCtg = 1
			and ac.ContactId = f.planAtorneyContactID
	) a
	where a.attorneycontactid is not null
go

-- [4.2] Defense Attorney list
insert into sma_TRN_LawFirmAttorneys
	(
	SourceTableRowID,
	UniqueContactId,
	IsDefendant,
	IsPrimary
	)
	select
		a.lawfirmid			as sourcetablerowid,
		a.attorneycontactid as uniqueaontactid,
		1					as isdefendant,
		case
			when a.sequencenumber = 1
				then 1
			else 0
		end					as isprimary
	from (
		select
			f.lwfnLawFirmID as lawfirmid,
			ac.UniqueContactId as attorneycontactid,
			ROW_NUMBER() over (partition by f.lwfnModifyUserID order by f.lwfnLawFirmID) as sequencenumber
		from [sma_TRN_LawFirms] f
		left join sma_MST_AllContactInfo ac
			on ac.ContactCtg = 1
			and ac.ContactId = f.lwfnAttorneyContactID
	) a
	where a.attorneycontactid is not null
go


---
alter table [sma_TRN_PlaintiffAttorney] enable trigger all
go

alter table [sma_TRN_LawFirms] enable trigger all
go

alter table [sma_TRN_LawFirmAttorneys] enable trigger all
go
---

