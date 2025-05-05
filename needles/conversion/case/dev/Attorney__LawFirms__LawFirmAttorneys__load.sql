/* ###################################################################################
description: Create defense attorneys
steps:
	- Insert defense attorneys > [sma_TRN_LawFirms]
	- Build defense attorney list > [sma_TRN_LawFirmAttorneys]
usage_instructions:
	- 
dependencies:
	- 
notes:
	-
*/

use [SA]
go

alter table [sma_TRN_LawFirms] disable trigger all
go

alter table [sma_TRN_LawFirmAttorneys] disable trigger all
go

-------------------------------------------------------------------------------
-- DEFENSE ATTORNEYS
-- [counsel_Indexed]
-------------------------------------------------------------------------------
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
	from Needles.[dbo].[counsel_Indexed] c
	left join Needles.[dbo].[user_counsel_data] ud
		on ud.counsel_id = c.counsel_id
			and c.case_num = ud.casenum
	join [sma_TRN_Cases] cas
		on cas.cassCaseNumber = convert(varchar,c.case_num)
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
go

-------------------------------------------------------------------------------
-- Defense Attorney list
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
		1					as isdefendant,
		case
			when a.sequencenumber = 1
				then 1
			else 0
		end					as isprimary
	from (
		select
			f.lwfnLawFirmID																 as lawfirmid,
			ac.UniqueContactID															 as attorneycontactid,
			ROW_NUMBER() over (partition by f.lwfnModifyUserID order by f.lwfnLawFirmID) as sequencenumber
		from [sma_TRN_LawFirms] f
		left join sma_MST_AllContactInfo ac
			on ac.ContactCtg = 1
			and ac.ContactId = f.lwfnAttorneyContactID
	) a
	where
		a.attorneycontactid is not null
go


alter table [sma_TRN_LawFirms] enable trigger all
go

alter table [sma_TRN_LawFirmAttorneys] enable trigger all
go
---

