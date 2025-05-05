/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create users and contacts

replace:
'OfficeName'
'StateDescription'
'VenderCaseType'
##########################################################################################################################
*/

use [SA]
go


---
alter table [sma_trn_caseJudgeorClerk] disable trigger all
go

alter table [sma_TRN_CourtDocket] disable trigger all
go

alter table [sma_TRN_Courts] disable trigger all
go

---

--SELECT * FROM sma_MST_IndvContacts smic where smic.cinnContactTypeID = (select
--					octnOrigContactTypeID
--				from [dbo].[sma_MST_OriginalContactTypes]
--				where octsDscrptn = 'Law Clerk'
--					and octnContactCtgID = 1)



---(1)---
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
		from [Needles].[dbo].[cases] c
		join [sma_TRN_cases] cas
			on cas.cassCaseNumber = convert(varchar,c.casenum)
		join IndvOrgContacts_Indexed ioc
			on ioc.SAGA = c.court_link
		where ISNULL(court_link, 0) <> 0

		union

		select
			cas.casnCaseID,
			ioc.CID,
			ioc.AID,
			c.judge_link
		from [Needles].[dbo].[cases] c
		join [sma_TRN_cases] cas
			on cas.cassCaseNumber = convert(varchar,c.casenum)
		join IndvOrgContacts_Indexed ioc
			on ioc.SAGA = -1
			and ioc.[Name] = 'Unidentified Court'
		where ISNULL(court_link, 0) = 0
			and (
			ISNULL(judge_link, 0) <> 0
			or docket <> ''
			)
	) a
go


---(2)---
insert into [sma_TRN_CourtDocket]
	(
	crdnCourtsID,
	crdnIndexTypeID,
	crdnDocketNo,
	crdnPrice,
	crdbActiveInActive,
	crdsEfile,
	crdsComments
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
			when ISNULL(c.docket, '') <> ''
				then LEFT(c.docket, 30)
			else 'Case-' + cas.cassCaseNumber
		end			   as crdndocketno,
		0			   as crdnprice,
		1			   as crdbactiveinactive,
		0			   as crdsefile,
		'Docket Number:' + LEFT(c.docket, 30)
		as crdscomments
	from [sma_TRN_Courts] crt
	join [sma_TRN_cases] cas
		on cas.casnCaseID = crt.crtnCaseID
	join [Needles].[dbo].[cases] c
		on convert(varchar,c.casenum) = cas.cassCaseNumber
go

---(3)---
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
	where ISNULL(crtnLevelNo, 0) <> 0