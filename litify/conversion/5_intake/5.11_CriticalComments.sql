use ShinerSA
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
		cas.casnCaseID		   as [ctcncaseid],
		0					   as [ctcncommenttypeid],
		i.lps_Special_Notes__c as [ctcstext],
		1					   as [ctcbactive],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga_char = i.OwnerId
		)					   as [ctcnrecuserid],
		--COALESCE(m.SAUserID, u.usrnUserID) as ctcnrecuserid, -- Use SAUserID if available, otherwise fallback to usrnUserID
		case
			when i.CreatedDate between '1900-01-01' and '2079-06-01'
				then i.CreatedDate
			else null
		end					   as [ctcddtcreated],
		null				   as [ctcnmodifyuserid],
		null				   as [ctcddtmodified],
		null				   as [ctcnlevelno],
		null				   as [ctcscommenttype]
	--select *
	from ShinerLitify..litify_pm__Intake__c i
	join sma_trn_Cases cas
		on cas.saga_char = i.Id
	--where i.litify_pm__Display_Name__c like '%Mariela Ekladious%'
	where
		ISNULL(i.lps_Special_Notes__c, '') <> ''
	
	--from JoelBieberNeedles.[dbo].[cases_Indexed] c
	--join [sma_trn_cases] cas
	--	on cas.cassCaseNumber = c.casenum
	--left join [conversion].[imp_user_map] m
	--	on m.StaffCode = c.staff_1
	--left join [sma_MST_Users] u
	--	on u.source_id = c.staff_1
	--where ISNULL(special_note, '') <> ''