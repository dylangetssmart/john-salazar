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

----------------------------------------------------------------------------
-- Defendant Attorneys from matter
	-- m.Opposing Party Attorney
----------------------------------------------------------------------------
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
			where atnsAtorneyDscrptn = 'Opposing Party Attorney'
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
	from ShinerLitify..litify_pm__Matter__c m
	join [sma_TRN_Cases] cas
		on cas.saga_char = m.id
	left join IndvOrgContacts_Indexed ioc
		on ioc.saga_char = m.Opposing_Party_Attorney__c
			and ioc.CTG = 1
	left join IndvOrgContacts_Indexed iocp
		on iocp.saga_char = m.Opposing_Party_Attorney__c
			and iocp.CTG = 2
	join [sma_TRN_Defendants] t
		on t.defnCaseID = cas.casnCaseID
			and defbIsPrimary = 1
	where ISNULL(m.Opposing_Party_Attorney__c, '') <> ''
go

----------------------------------------------------------------------------
-- Defendant Attorneys from party role
	-- litify_pm__Role__c in ('Law Firm', 'Attorney')
----------------------------------------------------------------------------
--insert into [sma_TRN_LawFirms]
--	(
--	[lwfnLawFirmContactID],
--	[lwfnLawFirmAddressID],
--	[lwfnAttorneyContactID],
--	[lwfnAttorneyAddressID],
--	[lwfnAttorneyTypeID],
--	[lwfsFileNumber],
--	[lwfnRoleType],
--	[lwfnContactID],
--	[lwfnRecUserID],
--	[lwfdDtCreated],
--	[lwfnModifyUserID],
--	[lwfdDtModified],
--	[lwfnLevelNo],
--	[lwfnAdjusterID],
--	[lwfsComments]
--	)
--	select distinct
--		case
--			when ioc.CTG = 2
--				then ioc.CID
--			else null
--		end				  as [lwfnlawfirmcontactid],
--		case
--			when ioc.CTG = 2
--				then ioc.AID
--			else null
--		end				  as [lwfnlawfirmaddressid],
--		case
--			when ioc.CTG = 1
--				then ioc.CID
--			else null
--		end				  as [lwfnattorneycontactid],
--		case
--			when ioc.CTG = 1
--				then ioc.AID
--			else null
--		end				  as [lwfnattorneyaddressid],
--		(
--			select
--				atnnAtorneyTypeID
--			from [sma_MST_AttorneyTypes]
--			where atnsAtorneyDscrptn = m.litify_pm__Role__c
--		)				  as [lwfnattorneytypeid],
--		null			  as [lwfsfilenumber],
--		2				  as [lwfnroletype],
--		t.defnDefendentID as [lwfncontactid],
--		368				  as [lwfnrecuserid],
--		GETDATE()		  as [lwfddtcreated],
--		cas.casnCaseID	  as [lwfnmodifyuserid],
--		GETDATE()		  as [lwfddtmodified],
--		null			  as [lwfnlevelno],
--		null			  as [lwfnadjusterid],
--		--isnull('comments : ' + nullif(convert(varchar(max),C.comments) ,'') + CHAR(13),'') +
--		--isnull('Attorney for party : ' + nullif(convert(varchar(max),IOCD.name) ,'') + CHAR(13),'') +
--		''				  as [lwfscomments]
--	from [ShinerLitify]..litify_pm__Role__c m
--	join [sma_TRN_Cases] cas
--		on cas.saga_char = m.litify_pm__Matter__c
--	left join IndvOrgContacts_Indexed ioc
--		on ioc.saga_char = m.litify_pm__Party__c
--			and ioc.CTG = 1
--	left join IndvOrgContacts_Indexed iocp
--		on iocp.saga_char = m.litify_pm__Party__c
--			and iocp.CTG = 2
--	join [sma_TRN_Defendants] t
--		on t.defnCaseID = cas.casnCaseID
--			and defbIsPrimary = 1
--	where litify_pm__Role__c in ('Law Firm', 'Attorney')
--go

----------------------------------------------------------------------------
-- Defense Attorney list
	-- isDefendant = 1
----------------------------------------------------------------------------
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

alter table [sma_TRN_LawFirms] enable trigger all
go

alter table [sma_TRN_LawFirmAttorneys] enable trigger all
go
---

