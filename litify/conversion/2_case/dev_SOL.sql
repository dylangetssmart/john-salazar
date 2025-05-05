use ShinerSA
go

---------------------------------------------------------------------------------
--INSERT SOL 000 FOR CONVERSION ONLY - DO NOT ADD FOR EVERY SINGLE CASE TYPE
---------------------------------------------------------------------------------
if not exists (
		select
			*
		from [sma_MST_SOLDetails]
		where sldnSOLTypeID = 16
			and sldnCaseTypeID = -1
			and sldsDorP = 'D'
	)
begin
	insert into [dbo].[sma_MST_SOLDetails]
		(
		[sldnSOLTypeID],
		[sldnCaseTypeID],
		[sldnDefRole],
		[sldnStateID],
		[sldnYears],
		[sldnMonths],
		[sldnDays],
		[sldnSOLDays],
		[sldnRecUserID],
		[slddDtCreated],
		[sldnModifyUserID],
		[slddDtModified],
		[sldnLevelNo],
		[sldsDorP],
		[sldsSOLName],
		[sldbIsIncidDtEffect],
		[sldbDefualt],
		[sldnFromIncident]
		)
		select
			16,
			-1,
			-1,
			-1,
			0,
			0,
			0,
			null,
			368,
			GETDATE(),
			null,
			null,
			null,
			'D',
			'SOL',
			0,
			0,
			0
end
go


-----
alter table [sma_TRN_SOLs] disable trigger all
go
-----

select
	id,
	lpmc.litify_pm__Filed_Date__c,
	lpmc.litify_pm__Moved_to_Litigation__c,
	lpmc.litify_pm__Open_Date__c
from ShinerLitify..litify_pm__Matter__c lpmc
where lpmc.litify_pm__Filed_Date__c = '2023-05-25 00:00:00'
-- a0L8Z00000fe5hnUAA

----(2)----
--INSERT INTO [sma_TRN_SOLs]
--(
--	[solnCaseID],
--	[solnSOLTypeID],
--	[soldSOLDate],
--	[soldDateComplied],
--	[soldSnCFilingDate],
--	[soldServiceDate],
--	[solnDefendentID],
--	[soldToProcessServerDt],
--	[soldRcvdDate],
--	[solsType],
--	[soldComments]
--)
--SELECT DISTINCT
--    D.defnCaseID		   as [solnCaseID],
--    (SELECT sldnSOLDetID FROM sma_MST_SOLDetails WHERE sldnSOLTypeID = 16 and sldnCaseTypeID = -1 and sldsDorP = 'D' )		   as [solnSOLTypeID],
--    CASE WHEN ( m.litify_pm__Statute_Of_Limitations__c not between '1900-01-01' and '2079-12-31' ) THEN NULL ELSE m.litify_pm__Statute_Of_Limitations__c END as [soldSOLDate],
--    null				   as [soldDateComplied],
--    NULL				   as [soldSnCFilingDate],
--    null				   as [soldServiceDate],
--    D.defnDefendentID	   as [solnDefendentID],
--    null				   as [soldToProcessServerDt],
--    null				   as [soldRcvdDate],
--    'D'					   as [solsType],
--	--convert(varchar(max),m.SOL_Notes__c)	   as [soldComments]
--	''					   as [soldComments]
--FROM LitifySalinas..litify_pm__Matter__c M
--JOIN [sma_TRN_cases] CAS on CAS.Litify_saga=m.ID
--JOIN [sma_TRN_Defendants] D on D.defnCaseID=CAS.casnCaseID 
--WHERE isnull( litify_pm__Statute_Of_Limitations__c,'') <> ''



insert into [sma_TRN_SOLs]
	(
	[solnCaseID],
	[solnSOLTypeID],
	[soldSOLDate],
	[soldDateComplied],
	[soldSnCFilingDate],
	[soldServiceDate],
	[solnDefendentID],
	[soldToProcessServerDt],
	[soldRcvdDate],
	[solsType],
	[soldComments]
	)
	select distinct
		d.defnCaseID	  as [solncaseid],
		(
			select
				sldnSOLDetID
			from sma_MST_SOLDetails
			where sldnSOLTypeID = 16
				and sldnCaseTypeID = -1
				and sldsDorP = 'D'
		)				  as [solnsoltypeid],
		case
			when (m.litify_pm__Statute_Of_Limitations__c not between '1900-01-01' and '2079-12-31')
				then null
			else m.litify_pm__Statute_Of_Limitations__c
		end				  as [soldsoldate],
		m.litify_pm__Filed_Date__c			  as [solddatecomplied],
		m.litify_pm__Filed_Date__c			  as [soldsncfilingdate],
		null			  as [soldservicedate],
		d.defnDefendentID as [solndefendentid],
		null			  as [soldtoprocessserverdt],
		null			  as [soldrcvddate],
		'D'				  as [solstype],
		--convert(varchar(max),m.SOL_Notes__c)	   as [soldComments]
		''				  as [soldcomments]
	from ShinerLitify..litify_pm__Matter__c m
	join [sma_TRN_cases] cas
		on cas.saga_char = m.ID
	join [sma_TRN_Defendants] d
		on d.defnCaseID = cas.casnCaseID
	where ISNULL(litify_pm__Statute_Of_Limitations__c, '') <> ''


-----
alter table [sma_TRN_SOLs] enable trigger all
go

-----


----(Appendix)----
update sma_MST_SOLDetails
set sldnFromIncident = 0
where sldnFromIncident is null
and sldnRecUserID = 368

