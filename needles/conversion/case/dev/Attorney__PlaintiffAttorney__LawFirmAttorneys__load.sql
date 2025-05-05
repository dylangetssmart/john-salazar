/* ###################################################################################
description: Create plaintiff attorneys
steps:
	- Create plaintiff attorneys > [sma_TRN_PlaintiffAttorney]
	- Build plaintiff attorney list > [sma_TRN_LawFirmAttorneys]
usage_instructions:
	- 
dependencies:
	- 
notes:
	-
*/


use [SA]
go

---
alter table [sma_TRN_PlaintiffAttorney] disable trigger all
go

alter table [sma_TRN_LawFirmAttorneys] disable trigger all
go

-------------------------------------------------------------------------------
-- PLAINTIFF ATTONEYS
-------------------------------------------------------------------------------
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
			where atnsAtorneyDscrptn = 'Plaintiff Attorney'
		)				  as [planatntypeid],
		null			  as [plasfileno], --	 UD.Their_File_Number
		368				  as [planrecuserid],
		GETDATE()		  as [pladdtcreated],
		null			  as [planmodifyuserid],
		null			  as [pladdtmodified],
		0				  as [planlevelno],
		null			  as [planrefoutid],
		ISNULL('comments : ' + NULLIF(CONVERT(VARCHAR(MAX), c.comments), '') + CHAR(13), '') +
		ISNULL('Attorney for party : ' + NULLIF(CONVERT(VARCHAR(MAX), iocp.name), '') + CHAR(13), '') +
		''				  as [plascomments]
	from Needles..[counsel_Indexed] c
	left join Needles.[dbo].[user_counsel_data] ud
		on ud.counsel_id = c.counsel_id
			and c.case_num = ud.casenum
	join [sma_TRN_Cases] cas
		on cas.cassCaseNumber = convert(varchar,c.case_num)
	join IndvOrgContacts_Indexed ioc
		on ioc.SAGA = c.counsel_id
			and ISNULL(c.counsel_id, 0) <> 0
	join IndvOrgContacts_Indexed iocp
		on iocp.SAGA = c.party_id
			and ISNULL(c.party_id, 0) <> 0
	join [sma_TRN_Plaintiff] t
		on t.plnnContactID = iocp.CID
			and t.plnnContactCtg = iocp.CTG
			and t.plnnCaseID = cas.casnCaseID
go
--select * from Needles..user_counsel_data ucd where casenum = 229701
-------------------------------------------------------------------------------
-- Plaintiff Attorney list
-------------------------------------------------------------------------------
insert into sma_TRN_LawFirmAttorneys
	(
	SourceTableRowID,
	UniqueContactID,
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

alter table [sma_TRN_PlaintiffAttorney] enable trigger all
go

alter table [sma_TRN_LawFirmAttorneys] enable trigger all
go
---

