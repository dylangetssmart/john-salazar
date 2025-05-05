/* #######################################################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-19
Description: Create individual and organization contacts

--------------------------------------------------------------------------------------------------------------------------------------
Step				Object							Action			Source				Notes
--------------------------------------------------------------------------------------------------------------------------------------
[0] Placeholder Individual Contacts			
	[0.0]			sma_MST_IndvContacts			insert			hardcode			Unassigned Staff
	[0.1]			sma_MST_IndvContacts			insert			hardcode			Unidentified Individual

########################################################################################################################
*/

use ShinerSA
go


-----
alter table [sma_TRN_SOLs] disable trigger all
go


--select
--	id,
--	lpmc.litify_pm__Filed_Date__c,
--	lpmc.litify_pm__Moved_to_Litigation__c,
--	lpmc.litify_pm__Open_Date__c
--from ShinerLitify..litify_pm__Matter__c lpmc
--where lpmc.litify_pm__Filed_Date__c = '2023-05-25 00:00:00'
-- a0L8Z00000fe5hnUAA

----(2)----
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
		d.defnCaseID			   as [solncaseid],
		null					   as [solnsoltypeid],
		case
			when (m.litify_pm__Statute_Of_Limitations__c not between '1900-01-01' and '2079-12-31')
				then null
			else m.litify_pm__Statute_Of_Limitations__c
		end						   as [soldsoldate],
		m.litify_pm__Filed_Date__c as [solddatecomplied],
		m.litify_pm__Filed_Date__c as [soldsncfilingdate],
		null					   as [soldservicedate],
		d.defnDefendentID		   as [solndefendentid],
		null					   as [soldtoprocessserverdt],
		null					   as [soldrcvddate],
		'D'						   as [solstype],
		''						   as [soldcomments]
	from ShinerLitify..litify_pm__Matter__c m
	join [sma_TRN_Cases] cas
		on cas.saga_char = m.Id
	join [sma_TRN_Defendants] d
		on d.defnCaseID = cas.casnCaseID
			and d.defbIsPrimary = 1
	where ISNULL(litify_pm__Statute_Of_Limitations__c, '') <> ''
--and m.id = 'a0L8Z00000fe5hnUAA'

-----
alter table [sma_TRN_SOLs] enable trigger all
go

-----


----(Appendix)----
update sma_MST_SOLDetails
set sldnFromIncident = 0
where sldnFromIncident is null
and sldnRecUserID = 368
