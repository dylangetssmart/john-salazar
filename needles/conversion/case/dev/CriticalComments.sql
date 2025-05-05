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

use [KurtYoung_SA]
go

/*
alter table [sma_TRN_CriticalComments] disable trigger all
delete from [sma_TRN_CriticalComments] 
DBCC CHECKIDENT ('[sma_TRN_CriticalComments]', RESEED, 0);
alter table [sma_TRN_CriticalComments] enable trigger all
*/

insert into [sma_TRN_CriticalComments]
	(
	[ctcnCaseID],
	[ctcnCommentTypeID],
	[ctcsText],
	[ctcbActive],
	[ctcnRecUserID],
	[ctcdDtCreated],
	[ctcnModifyUserID],
	[ctcdDtModified],
	[ctcnLevelNo],
	[ctcsCommentType]
	)
	select
		cas.casnCaseID as [ctcncaseid],
		0			   as [ctcncommenttypeid],
		special_note   as [ctcstext],
		1			   as [ctcbactive],
		(
			select
				usrnUserID
			from sma_MST_Users
			where source_id = c.staff_1
		)			   as [ctcnrecuserid],
		case
			when date_of_incident between '1900-01-01' and '2079-06-01'
				then date_of_incident
			else null
		end			   as [ctcddtcreated],
		null		   as [ctcnmodifyuserid],
		null		   as [ctcddtmodified],
		null		   as [ctcnlevelno],
		null		   as [ctcscommenttype]
	from KurtYoung_Needles.[dbo].[cases_Indexed] c
	join [sma_trn_cases] cas
		on cas.cassCaseNumber = c.casenum
	where ISNULL(special_note, '') <> ''