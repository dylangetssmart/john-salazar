/*---
description: >
  Insert Courts, Dockets, and Judges
source_tables:
  - [cases]
target_tables:
  - [sma_TRN_Courts]
target_screen:
  - Courts
depends_on:
---*/

use [JohnSalazar_SA]
go

---
exec AddBreadcrumbsToTable 'sma_TRN_Courts'
go

---

/* ------------------------------------------------------------------------------
Insert [sma_TRN_Courts]
*/ ------------------------------------------------------------------------------
alter table [sma_TRN_Courts] disable trigger all
go

insert into [sma_TRN_Courts]
	(
		crtnCaseID,
		crtnCourtID,
		crtnCourtAddId,
		crtnIsActive,
		crtnLevelNo,
		source_id,
		source_db,
		source_ref
	)
	select
		a.casnCaseID as crtncaseid,
		a.CID		 as crtncourtid,
		a.AID		 as crtncourtaddid,
		1			 as crtnisactive,
		a.judge_link as crtnlevelno, -- remembering judge_link
		null		 as source_id,
		'needles'	 as source_db,
		null		 as source_ref
	from (
	 select
		 cas.casnCaseID,
		 ioc.CID,
		 ioc.AID,
		 c.judge_link
	 from [JohnSalazar_Needles].[dbo].[cases] c
	 join [sma_TRN_cases] cas
		 on cas.cassCaseNumber = CONVERT(VARCHAR, c.casenum)
	 join IndvOrgContacts_Indexed ioc
		 on ioc.SAGA = c.court_link
	 where ISNULL(court_link, 0) <> 0

	 union

	 select
		 cas.casnCaseID,
		 ioc.CID,
		 ioc.AID,
		 c.judge_link
	 from [JohnSalazar_Needles].[dbo].[cases] c
	 join [sma_TRN_cases] cas
		 on cas.saga = c.casenum
	 join IndvOrgContacts_Indexed ioc
		 on ioc.CTG = 2
		 and ioc.[Name] = 'Unidentified Court'
	 where ISNULL(court_link, 0) = 0
		 and (
		 ISNULL(judge_link, 0) <> 0
		 or docket <> ''
		 )
	) a
go

alter table [sma_TRN_Courts] enable trigger all
go


/* ------------------------------------------------------------------------------
Insert [sma_TRN_CourtDocket]
*/ ------------------------------------------------------------------------------
alter table [sma_TRN_CourtDocket] disable trigger all
go

insert into [sma_TRN_CourtDocket]
	(
		crdnCourtsID,
		crdnIndexTypeID,
		crdnDocketNo,
		crdnPrice,
		crdbActiveInActive,
		crdsEfile,
		crdsComments,
		crddDate
	)
	select
		crtnPKCourtsID as crdncourtsid,
		(
		 select
			 idtnIndexTypeID
		 from sma_MST_IndexType
		 where idtsDscrptn = 'Index Number'
		)			   as crdnindextypeid,
		case
			when ISNULL(c.docket, '') <> '' then LEFT(c.docket, 30)
			else 'Case-' + cas.cassCaseNumber
		end			   as crdndocketno,
		0			   as crdnprice,
		1			   as crdbactiveinactive,
		0			   as crdsefile,
		ISNULL('Docket Number: ' + NULLIF(CONVERT(VARCHAR(MAX), c.docket), '') + CHAR(13), '') +
		ISNULL('How Resolved: ' + NULLIF(CONVERT(VARCHAR(MAX), ucd.How_Resolved), '') + CHAR(13), '') +
		ISNULL('County of Suit: ' + NULLIF(CONVERT(VARCHAR(MAX), ucd.County_of_Suit), '') + CHAR(13), '') +
		ISNULL('County Ct No: ' + NULLIF(CONVERT(VARCHAR(MAX), ucd.County_Ct_No), '') + CHAR(13), '') +
		''			   as crdscomments,
		--'Docket Number:' + LEFT(c.docket, 30) as crdscomments,
		c.case_date_3  as crddDate		-- Filing Date
	-- SELECT ucd.How_Resolved, ucd.County_of_Suit, ucd.County_Ct_No FROM JohnSalazar_Needles..user_case_data ucd
	from [sma_TRN_Courts] crt
	join [sma_TRN_cases] cas
		on cas.casnCaseID = crt.crtnCaseID
	join [JohnSalazar_Needles].[dbo].[cases] c
		on cas.saga = c.casenum
	left join JohnSalazar_Needles..user_case_data ucd
		on ucd.casenum = c.casenum
go

alter table [sma_TRN_CourtDocket] enable trigger all
go


/* ------------------------------------------------------------------------------
Insert [sma_trn_caseJudgeorClerk]
*/ ------------------------------------------------------------------------------
alter table [sma_trn_caseJudgeorClerk] disable trigger all
go

insert into [sma_trn_caseJudgeorClerk]
	(
		crtDocketID,
		crtJudgeorClerkContactID,
		crtJudgeorClerkContactCtgID,
		crtJudgeorClerkRoleID
	)
	select distinct
		crd.crdnCourtDocketID as crtdocketid,
		ioc.CID				  as crtjudgeorclerkcontactid,
		ioc.CTG				  as crtjudgeorclerkcontactctgid,
		(
		 select
			 octnOrigContactTypeID
		 from sma_MST_OriginalContactTypes
		 where octsDscrptn = 'Judge'
		)					  as crtjudgeorclerkroleid
	from [sma_TRN_CourtDocket] crd
	join [sma_TRN_Courts] crt
		on crt.crtnPKCourtsID = crd.crdnCourtsID
	join IndvOrgContacts_Indexed ioc
		on ioc.SAGA = crt.crtnLevelNo  -- ( crtnLevelNo --> C.judge_link )
	where
		ISNULL(crtnLevelNo, 0) <> 0
go

alter table [sma_trn_caseJudgeorClerk] enable trigger all
go