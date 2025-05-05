/*---
priority: 1
sequence: 1
description: Create office record
data-source:
---*/

use [JohnSalazar_SA]
go

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
	from [[JohnSalazar_Needles]].[dbo].[cases_Indexed] c
	join [sma_trn_cases] cas
		on cas.cassCaseNumber = CONVERT(VARCHAR, c.casenum)
	where
		ISNULL(special_note, '') <> ''