/*---
group: misc
order: 1
description: Update contact types for attorneys
---*/

use [JohnSalazar_SA]
go

/* ------------------------------------------------------------------------------
Plaintiff Attorneys
*/ ------------------------------------------------------------------------------
alter table [sma_TRN_PlaintiffAttorney] disable trigger all
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
		t.plnnPlaintiffID as [planplaintffid],
		cas.casnCaseID	  as [plancaseid],
		t.plnnContactCtg  as [planplctgid],
		t.plnnContactID	  as [planplcontactid],
		case
			when ioc.CTG = 2 then ioc.AID
			else null
		end				  as [planlawfrmaddid],
		case
			when ioc.CTG = 2 then ioc.CID
			else null
		end				  as [planlawfrmcontactid],
		case
			when ioc.CTG = 1 then ioc.AID
			else null
		end				  as [planatorneyaddid],
		case
			when ioc.CTG = 1 then ioc.CID
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
	from [JohnSalazar_Needles]..[counsel_Indexed] c
	left join [JohnSalazar_Needles].[dbo].[user_counsel_data] ud
		on ud.counsel_id = c.counsel_id
			and c.case_num = ud.casenum
	join [sma_TRN_Cases] cas
		on cas.cassCaseNumber = c.case_num
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

alter table [sma_TRN_PlaintiffAttorney] enable trigger all
go

/* ------------------------------------------------------------------------------
Plaintiff Attorney list
*/ ------------------------------------------------------------------------------

alter table [sma_TRN_LawFirmAttorneys] disable trigger all
go

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
			when a.sequencenumber = 1 then 1
			else 0
		end					as isprimary
	from (
	 select
		 f.planAtnID														as lawfirmid,
		 ac.UniqueContactId													as attorneycontactid,
		 ROW_NUMBER() over (partition by f.planCaseID order by f.planAtnID) as sequencenumber
	 from [sma_TRN_PlaintiffAttorney] f
	 left join sma_MST_AllContactInfo ac
		 on ac.ContactCtg = 1
		 and ac.ContactId = f.planAtorneyContactID
	) a
	where
		a.attorneycontactid is not null
go

alter table [sma_TRN_LawFirmAttorneys] enable trigger all
go


/* ------------------------------------------------------------------------------
Defense Attorneys
*/ ------------------------------------------------------------------------------

alter table [sma_TRN_LawFirms] disable trigger all
go

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
			when ioc.CTG = 2 then ioc.CID
			else null
		end				  as [lwfnlawfirmcontactid],
		case
			when ioc.CTG = 2 then ioc.AID
			else null
		end				  as [lwfnlawfirmaddressid],
		case
			when ioc.CTG = 1 then ioc.CID
			else null
		end				  as [lwfnattorneycontactid],
		case
			when ioc.CTG = 1 then ioc.AID
			else null
		end				  as [lwfnattorneyaddressid],
		(
		 select
			 atnnAtorneyTypeID
		 from [sma_MST_AttorneyTypes]
		 where atnsAtorneyDscrptn = 'Defense Attorney'
		)				  as [lwfnattorneytypeid],
		null			  as [lwfsfilenumber],
		2				  as [lwfnroletype],
		d.defnDefendentID as [lwfncontactid],
		368				  as [lwfnrecuserid],
		GETDATE()		  as [lwfddtcreated],
		cas.casnCaseID	  as [lwfnmodifyuserid],
		GETDATE()		  as [lwfddtmodified],
		null			  as [lwfnlevelno],
		null			  as [lwfnadjusterid],
		ISNULL('comments : ' + NULLIF(CONVERT(VARCHAR(MAX), c.comments), '') + CHAR(13), '') +
		ISNULL('Attorney for party : ' + NULLIF(CONVERT(VARCHAR(MAX), iocd.name), '') + CHAR(13), '') +
		''				  as [lwfscomments]
	--select ioc.*
	from [JohnSalazar_Needles].[dbo].[counsel_Indexed] c
	left join [JohnSalazar_Needles].[dbo].[user_counsel_data] ud
		on ud.counsel_id = c.counsel_id
			and c.case_num = ud.casenum
	join [sma_TRN_Cases] cas
		on cas.cassCaseNumber = CONVERT(VARCHAR, c.case_num)
	join IndvOrgContacts_Indexed ioc
		on ioc.SAGA = c.counsel_id
			and ISNULL(c.counsel_id, 0) <> 0
	join IndvOrgContacts_Indexed iocd
		on iocd.SAGA = c.party_id
			and ISNULL(c.party_id, 0) <> 0
	join [sma_TRN_Defendants] d
		on d.defnContactID = iocd.CID
			and d.defnContactCtgID = iocd.CTG
			and d.defnCaseID = cas.casnCaseID
--where c.case_num = 214476
go

alter table [sma_TRN_LawFirms] enable trigger all
go

/* ------------------------------------------------------------------------------
Defense Attorney List
*/ ------------------------------------------------------------------------------

alter table [sma_TRN_LawFirmAttorneys] disable trigger all
go

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
		1					as isdefendant,
		case
			when a.sequencenumber = 1 then 1
			else 0
		end					as isprimary
	from (
	 select
		 f.lwfnLawFirmID															  as lawfirmid,
		 ac.UniqueContactID															  as attorneycontactid,
		 ROW_NUMBER() over (partition by f.lwfnModifyUserID order by f.lwfnLawFirmID) as sequencenumber
	 from [sma_TRN_LawFirms] f
	 left join sma_MST_AllContactInfo ac
		 on ac.ContactCtg = 1
		 and ac.ContactId = f.lwfnAttorneyContactID
	) a
	where
		a.attorneycontactid is not null
go

alter table [sma_TRN_LawFirmAttorneys] enable trigger all
go


/* ------------------------------------------------------------------------------
Appendix
- update contact types
*/ ------------------------------------------------------------------------------

update sma_MST_IndvContacts
set cinnContactTypeID = (
 select
	 octnOrigContactTypeID
 from [sma_MST_OriginalContactTypes]
 where octsDscrptn = 'Attorney'
	 and octnContactCtgID = 1
)
from (
 select
	 I.cinnContactID as ID
 from [JohnSalazar_Needles].[dbo].[counsel] C
 join [JohnSalazar_Needles].[dbo].[names] L
	 on C.counsel_id = L.names_id
 join [dbo].[sma_MST_IndvContacts] I
	 on saga = L.names_id
 where L.person = 'Y'
) A
where cinnContactID = A.ID
go
