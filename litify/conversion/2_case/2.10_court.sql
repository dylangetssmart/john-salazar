/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-23
Description: Create attorneys


sma_TRN_Courts
sma_TRN_CourtDocket


--------------------------------------------------------------------------------------------------------------------------------------
Step								Object								Action			Source				
--------------------------------------------------------------------------------------------------------------------------------------
[1] Courts							sma_TRN_Courts				insert			litify_pm__Role__c

[2] Court Docket					sma_TRN_CourtDocket

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

--truncate table sma_trn_Courts
--truncate table [sma_TRN_CourtDocket]
--truncate table [sma_trn_caseJudgeorClerk]


/* ##############################################

[0.0] - Create temporary tables for mapping codes
- Temporary table to store applicable damage types
- Acts as as single patch point for updates
- Sample Usage:
	WHERE ISNULL(d.litify_pm__type__C, '') IN (SELECT code FROM #DamageTypes dt)
	WHERE litify_pm__role__c IN IN (SELECT code FROM #MedicalProviderRoles dt)
*/


if OBJECT_ID('conversion.court_roles') is not null
begin
	drop table conversion.court_roles;
end
go

---- Create table
--IF OBJECT_ID('tempdb..#CourtRoles') IS NOT NULL
--BEGIN
--	DROP TABLE #CourtRoles;
--END;

create table conversion.court_roles (
	code VARCHAR(25)
);

-- Insert codes from mapping spreadsheet
insert into conversion.court_roles
	(
	code
	)
values (
'Court'
)

-- Add saga_ref to Court
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_TRN_Courts')
	)
begin
	alter table [sma_TRN_Courts]
	add saga_char VARCHAR(100)
end
go


alter table [sma_TRN_Courts] disable trigger all
go

-------------------------
--INSERT COURT
-------------------------
insert into [sma_TRN_Courts]
	(
	crtnCaseID,
	crtnCourtID,
	crtnCourtAddId,
	crtsComment,
	crtnIsActive,
	crtnRecUserID,
	crtdDtCreated,
	crtnModifyUserID,
	crtdDtModified,
	saga_char
	)
	select distinct
		cas.casnCaseID as crtncaseid,
		ioc.CID		   as crtncourtid,
		ioc.AID		   as crtncourtaddid,
		ISNULL('Court Case Number: ' + NULLIF(CONVERT(VARCHAR(MAX), courtcasenum), '') + CHAR(13), '')
		+ ''		   as crtscomment,
		1			   as crtnisactive,
		368			   as crtnrecuserid,
		GETDATE()	   as crtddtcreated,
		null		   as crtnmodifyuserid,
		null		   as crtddtmodified,
		m.court		   as saga_char
	from (
		select
			m.id as matterid,
			litify_pm__Court__c as court,
			null as courtcasenum
		from [ShinerLitify]..[litify_pm__Matter__c] m
		where ISNULL(litify_pm__Court__c, '') <> ''

		union

		select
			litify_pm__Matter__c as matterid,
			litify_pm__Party__c as court,
			null as courtcasenum
		-- ,Court_Case_Number__c as courtCaseNum
		from ShinerLitify..litify_pm__role__c
		where litify_pm__role__c in (
				select
					code
				from conversion.court_roles cr
			)
	--WHERE litify_pm__role__c IN ( 'Court', 'Clerk Of Circuit Court', 'Clerk Of County Court')
	) m
	join sma_trn_Cases cas
		on cas.saga_char = m.matterid
	join IndvOrgContacts_Indexed ioc
		on ioc.saga_char = m.court		--, 'unidentifiedcourt')


/*
INSERT INTO [sma_TRN_Courts] ( 
	crtnCaseID,
	crtnCourtID,
	crtnCourtAddId,
	crtsComment,
	crtnIsActive,
	crtnRecUserID,
	crtdDtCreated, 
	crtnModifyUserID,
	crtdDtModified
)
SELECT DISTINCT 
	cas.casnCaseID	    as crtnCaseID, 
	ioc.CID		    as crtnCourtID, 
	ioc.AID		    as crtnCourtAddId,  
	''				as crtsComment,
	1			    as crtnIsActive,
	368				as crtnRecUserID,
	getdate()		as crtdDtCreated, 
	NULL			as crtnModifyUserID,
	NULL			as crtdDtModified
 --SELECT * 
FROM [ShinerLitify]..[litify_pm__Matter__c] m
JOIN sma_trn_Cases cas on cas.Litify_saga = m.id
JOIN IndvOrgContacts_Indexed ioc on ioc.saga = 'unidentifiedcourt'
LEFT JOIN sma_TRN_Courts ct on ct. crtnCaseID = cas.casnCaseID
WHERE (isnull(litify_pm__Docket_Number__c,'') <> ''
or isnull(Judge__c,'') <> ''
or isnulL(clerk__c,'') <> '' )
and ct.crtnCourtID IS NULL
*/



--INSERT INTO [sma_TRN_Courts]
--( 
--	crtnCaseID,
--	crtnCourtID,
--	crtnCourtAddId,
--	crtsComment,
--	crtnIsActive,
--	crtnRecUserID,
--	crtdDtCreated, 
--	crtnModifyUserID,
--	crtdDtModified,
--	saga_ref
--)
--SELECT DISTINCT
--	cas.casnCaseID			as crtnCaseID
--	,ioc.CID		    	as crtnCourtID
--	,ioc.AID				as crtnCourtAddId
--	,''						as crtsComment
--	,1			    		as crtnIsActive
--	,368					as crtnRecUserID
--	,getdate()				as crtdDtCreated
--	,NULL					as crtnModifyUserID
--	,NULL					as crtdDtModified
--	,'unidentifiedCourt'	as saga_ref
--FROM [ShinerLitify]..[litify_pm__role__c] m
--	JOIN sma_trn_Cases cas
--		on cas.Litify_saga = m.litify_pm__Matter__c
--	JOIN IndvOrgContacts_Indexed ioc
--		on ioc.saga = 'unidentifiedcourt'
--LEFT JOIN sma_TRN_Courts ct on ct. crtnCaseID = cas.casnCaseID
--WHERE litify_pm__role__c IN ('Judge')
--	and m.litify_pm__Parent_Role__c IS NULL
--	and ct.crtnCourtID IS NULL


------------------------------------
--COURT DOCKET
------------------------------------
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
		crtnPKCourtsID									as crdncourtsid,
		(
			select
				idtnIndexTypeID
			from sma_MST_IndexType
			where idtsDscrptn = 'Docket Number'
		)												as crdnindextypeid,
		LEFT(m.litify_pm__Docket_Number__c, 30)			as crdndocketno,
		0												as crdnprice,
		1												as crdbactiveinactive,
		0												as crdsefile,
		'Docket Number: ' + litify_pm__Docket_Number__c as crdscomments
	from [sma_TRN_Courts] crt
	join sma_trn_Cases cas
		on cas.casnCaseID = crt.crtnCaseID
	join [ShinerLitify]..[litify_pm__Matter__c] m
		on m.id = cas.saga_char
WHERE isnull(litify_pm__Docket_Number__c,'') <> ''
go

-------------------------
--INSERT JUDGE
---------------------------
--INSERT INTO [sma_trn_caseJudgeorClerk] 
--( 
--	crtDocketID,
--	crtJudgeorClerkContactID,
--	crtJudgeorClerkContactCtgID,
--	crtJudgeorClerkRoleID
--) 
--SELECT DISTINCT
--	CRD.crdnCourtDocketID		as crtDocketID
--	,IOC.CID					as crtJudgeorClerkContactID
--	,IOC.CTG					as crtJudgeorClerkContactCtgID
--	,(
--		SELECT top 1 octnOrigContactTypeID
--		FROM sma_MST_OriginalContactTypes
--		WHERE octsDscrptn = 'Judge'
--	)							as crtJudgeorClerkRoleID 
----select *
--FROM [sma_TRN_CourtDocket] CRD
--	JOIN [sma_TRN_Courts] CRT
--		on CRT.crtnPKCourtsID = CRD.crdnCourtsID
--	JOIN sma_trn_Cases cas
--		on cas.casnCaseID = crt.crtnCaseID
--	JOIN [ShinerLitify]..litify_pm__role__c m
--		on m.litify_pm__Matter__c = cas.Litify_saga
--			and m.litify_pm__Party__c = crt.saga_ref
--	JOIN [ShinerLitify]..litify_pm__role__c mc
--		on mc.litify_pm__Parent_Role__c = m.id
--	JOIN IndvOrgContacts_Indexed IOC
--		on IOC.SAGA = mc.litify_pm__Party__c
--WHERE mc.litify_pm__Role__c IN ('Judge')

--select DISTINCT lprc.litify_pm__Role__c FROM ShinerLitify..litify_pm__Role__c lprc


-----------------------------------------------
--INSERT JUDGE WITH NO COURT ASSIGNED
-----------------------------------------------
--INSERT INTO [sma_trn_caseJudgeorClerk] 
--( 
--	crtDocketID,
--	crtJudgeorClerkContactID,
--	crtJudgeorClerkContactCtgID,
--	crtJudgeorClerkRoleID
--) 
--SELECT DISTINCT
--	CRD.crdnCourtDocketID		as crtDocketID
--	,IOC.CID					as crtJudgeorClerkContactID
--	,IOC.CTG					as crtJudgeorClerkContactCtgID
--	,(
--		SELECT top 1 octnOrigContactTypeID
--		FROM sma_MST_OriginalContactTypes
--		WHERE octsDscrptn = 'Judge'
--	)							as crtJudgeorClerkRoleID 
--FROM [sma_TRN_CourtDocket] CRD
--	JOIN [sma_TRN_Courts] CRT
--		on CRT.crtnPKCourtsID = CRD.crdnCourtsID
--			and crt.saga_Ref = 'unidentifiedCourt'
--	JOIN sma_trn_Cases cas
--		on cas.casnCaseID = crt.crtnCaseID
--	JOIN [ShinerLitify]..litify_pm__role__c m
--		on m.litify_pm__Matter__c = cas.Litify_saga
--		and m.litify_pm__Parent_Role__c IS NULL
--	JOIN IndvOrgContacts_Indexed IOC
--		on IOC.SAGA = m.litify_pm__Party__c
--WHERE litify_pm__Role__c IN ('Judge')




--------------------------------
--INSERT CLERK
--------------------------------
/*
INSERT INTO [sma_trn_caseJudgeorClerk] 
( 
	crtDocketID,
	crtJudgeorClerkContactID,
	crtJudgeorClerkContactCtgID,
	crtJudgeorClerkRoleID
) 
SELECT DISTINCT
	CRD.crdnCourtDocketID	as crtDocketID,
	IOC.CID					as crtJudgeorClerkContactID,
	IOC.CTG					as crtJudgeorClerkContactCtgID,
	(SELECT octnOrigContactTypeID FROM sma_MST_OriginalContactTypes WHERE octsDscrptn='Courtroom Clerk') as crtJudgeorClerkRoleID 
FROM [sma_TRN_CourtDocket] CRD
JOIN [sma_TRN_Courts] CRT on CRT.crtnPKCourtsID=CRD.crdnCourtsID  
JOIN sma_trn_Cases cas on cas.casnCaseID = crt.crtnCaseID
JOIN [ShinerLitify]..[litify_pm__Matter__c] m on m.id = cas.Litify_saga
JOIN IndvOrgContacts_Indexed IOC on IOC.SAGA = m.Clerk__c
WHERE isnull(Clerk__c,'')<> ''
*/

alter table [sma_TRN_Courts] enable trigger all
go