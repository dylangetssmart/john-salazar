/* #######################################################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-10-03
Description: 

[sma_TRN_Investigations]
[sma_TRN_PoliceReports]
[sma_TRN_CaseWitness]

1.0 - Unidentified Medical Provider
1.1 - Unidentified Insurance
1.2 - Unidentified Court
1.3 - Unid Lienor

#########################################################################################################################
*/

use ShinerSA
go

-----------------------------------------
-- Update Schema
-----------------------------------------
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_TRN_PoliceReports')
	)
begin
	alter table [sma_TRN_PoliceReports]
	add saga_char VARCHAR(100) null;
end
go

-- 
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_TRN_CaseWitness')
	)
begin
	alter table [sma_TRN_CaseWitness]
	add [saga_char] [VARCHAR](100) null;
end

-- 
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_TRN_Investigations')
	)
begin
	alter table [sma_TRN_Investigations]
	add [saga_char] [VARCHAR](100) null;
end

go


--ALTER TABLE [sma_TRN_PoliceReports]
--ALTER COLUMN saga VARCHAR(100)
--GO

--ALTER TABLE [sma_TRN_PoliceReports]
--ALTER COLUMN porsReportNo VARCHAR(35)
--GO

-----------------------------------------
-- Investigations
-----------------------------------------
insert into [dbo].[sma_TRN_Investigations]
	(
	[invnCaseID],
	[invnInvestigationTypeID],
	[invnContactAddressID],
	[invnContactID],
	[invnContactCtgID],
	[invbWillTestify],
	[invnExpertID],
	[invnReportByADID],
	[invnReportByID],
	[invnReportByCtgID],
	[invnSchedulingPartyContactID],
	[invnSchedulingPartyAddressID],
	[invnSchedulingPartyCtgID],
	[invsLocation],
	[invnInvestigatorID],
	[invnInvestigatorADID],
	[invnInvestigatorCtgID],
	[invdDateAssigned],
	[invnAssignmentMethodID],
	[invdExpCompletionDate],
	[invnAppointmentID],
	[invdDateCompleted],
	[invnStaffRequested],
	[invsComments],
	[invnRecUserID],
	[invdDtCreated],
	[invnModifyUserID],
	[invdDtModified],
	[invnLevelNo],
	[invdIsReferredBy],
	[saga_char]
	)
	select distinct
		cas.casnCaseID			  as [invncaseid],
		(
			select
				intnInvestigationTypeID
			from sma_MST_InvestigationTypes
			where intsDscrptn = 'Records'
		)						  as invninvestigationtypeid,
		null					  as invncontactaddressid,
		null					  as invncontactid,
		null					  as invncontactctgid,
		null					  as invbwilltestify,
		null					  as invnexpertid,
		null					  as invnreportbyadid,
		null					  as invnreportbyid,
		null					  as invnreportbyctgid,
		null					  as invnschedulingpartycontactid,
		null					  as invnschedulingpartyaddressid,
		null					  as invnschedulingpartyctgid,
		null					  as invslocation,
		ISNULL(ioc.cid, ioco.cid) as invninvestigatorid,
		ISNULL(ioc.AID, ioco.AID) as invninvestigatoradid,
		ISNULL(ioc.CTG, ioco.CTG) as invninvestigatorctgid,
		null					  as invddateassigned,
		null					  as invnassignmentmethodid,
		null					  as invdexpcompletiondate,
		null					  as invnappointmentid,
		null					  as invddatecompleted,
		null					  as invnstaffrequested,
		ISNULL(('Comments: ' + NULLIF(CONVERT(VARCHAR(MAX), m.[litify_pm__Comments__c]), '') + CHAR(13)), '') +
		''						  as invscomments,
		368						  as invnrecuserid,
		GETDATE()				  as invddtcreated,
		null					  as invnmodifyuserid,
		null					  as invddtmodified,
		null					  as invnlevelno,
		null					  as invdisreferredby,
		null					  as [saga_char]
	from [ShinerLitify]..litify_pm__role__c m
	join [sma_TRN_Cases] cas
		on cas.saga_char = m.litify_pm__Matter__c
	left join IndvOrgContacts_Indexed ioc
		on ioc.saga_char = m.litify_pm__Party__c
			and ioc.ctg = 1
	left join IndvOrgContacts_Indexed ioco
		on ioco.saga_char = m.litify_pm__Party__c
			and ioco.ctg = 2
	left join sma_TRN_Plaintiff p
		on p.plnnCaseID = cas.casnCaseID
			and p.plnbIsPrimary = 1
	where litify_pm__role__c in ('Investigator')
go

-----------------------------------------
-- Police Reports
-----------------------------------------
insert into [sma_TRN_PoliceReports]
	(
	[pornCaseID],
	[pornPoliceID],
	[pornPoliceAdID],
	[porsReportNo],
	pornReportTypeID,
	[porsComments],
	[pornPOContactID],
	[pornPOCtgID],
	[pornPOAddressID],
	[pordRepReceivedDate],
	[saga_char]
	)
	select distinct
		cas.casnCaseID as porncaseid,
		ioc.CID		   as pornpoliceid,
		ioc.AID		   as pornpoliceadid,
		null		   as porsreportno,	--35
		(
			select
				rptnreporttypeID
			from sma_MST_ReportTypes
			where rptsDscrptn = 'Accident Report'
		)			   as pornreporttypeid,
		ISNULL(('Comments: ' + NULLIF(CONVERT(VARCHAR(MAX), m.[litify_pm__Comments__c]), '') + CHAR(13)), '') +
		''			   as porscomments,
		null		   as [pornpocontactid],
		null		   as [pornpoctgid],
		null		   as [pornpoaddressid],
		null		   as [pordrepreceiveddate],
		m.id		   as [saga_char]
	from [ShinerLitify]..litify_pm__role__c m
	join [sma_TRN_Cases] cas
		on cas.saga_char = m.litify_pm__Matter__c
	join IndvOrgContacts_Indexed ioc
		on ioc.saga_char = m.litify_pm__Party__c
	left join sma_TRN_Plaintiff p
		on p.plnnCaseID = cas.casnCaseID
			and p.plnbIsPrimary = 1
	where litify_pm__role__c in ('Police Department')
go

-----------------------------------------
-- Witnesses
-----------------------------------------
insert into [dbo].[sma_TRN_CaseWitness]
	(
	[witnCaseID],
	[witnWitnesContactID],
	[witnWitnesAdID],
	[witnRoleID],
	[witnFavorable],
	[witnTestify],
	[witdStmtReqDate],
	[witdStmtDate],
	[witbHasRec],
	[witsDoc],
	[witsComment],
	[witnRecUserID],
	[witdDtCreated],
	[witnModifyUserID],
	[witdDtModified],
	[witnLevelNo],
	[saga_char]
	)
	select
		cas.casnCaseid as [witncaseid],
		ioc.CID		   as [witnwitnescontactid],
		ioc.AID		   as [witnwitnesadid],
		(
			select
				ID
			from SMA_MST_WitnessType
			where WitnessType = 'Unknown'
		)			   as [witnroleid],
		--NULL			as [witnRoleID],
		null		   as [witnfavorable],  --(0 Plaintiff, 1 for Defendant, 2 Neutral)
		null		   as [witntestify],
		null		   as [witdstmtreqdate],
		null		   as [witdstmtdate],
		null		   as [witbhasrec],
		null		   as [witsdoc],
		ISNULL(('Comments: ' + NULLIF(CONVERT(VARCHAR(MAX), m.[litify_pm__Comments__c]), '') + CHAR(13)), '') +
		''			   as [witscomment],		--200
		368			   as [witnrecuserid],
		GETDATE()	   as [witddtcreated],
		null		   as [witnmodifyuserid],
		null		   as [witddtmodified],
		1			   as [witnlevelno],
		m.Id		   as [saga_char]
	--select *
	from [ShinerLitify]..litify_pm__role__c m
	join [sma_TRN_Cases] cas
		on cas.saga_char = m.litify_pm__Matter__c
	join IndvOrgContacts_Indexed ioc
		on ioc.saga_char = m.litify_pm__Party__c
	where litify_pm__role__c in ('Witness')
go