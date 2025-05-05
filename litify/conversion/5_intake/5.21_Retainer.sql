use [ShinerSA]
go

--SELECT
--	lpic.litify_pm__Retainer_Agreement_Signed__c
--   ,lpic.litify_pm__Matter__c
--FROM ShinerLitify..litify_pm__Intake__c lpic
--WHERE isnull(lpic.litify_pm__Retainer_Agreement_Signed__c,'')<>''

--rtndRcvdDt

insert into [dbo].[sma_TRN_Retainer]
	(
		[rtnnCaseID],
		[rtnnPlaintiffID],
		[rtndSentDt],
		[rtndRcvdDt],
		[rtndRetainerDt],
		[rtnbCopyRefAttFee],
		[rtnnFeeStru],
		[rtnbMultiFeeStru],
		[rtnnBeforeTrial],
		[rtnnAfterTrial],
		[rtnnAtAppeal],
		[rtnnUDF1],
		[rtnnUDF2],
		[rtnnUDF3],
		[rtnbComplexStru],
		[rtnbWrittenAgree],
		[rtnnStaffID],
		[rtnsComments],
		[rtnnUserID],
		[rtndDtCreated],
		[rtnnModifyUserID],
		[rtndDtModified],
		[rtnnLevelNo],
		[rtnnPlntfAdv],
		[rtnnFeeAmt],
		[rtnsRetNo],
		[rtndRetStmtSent],
		[rtndRetStmtRcvd],
		[rtndClosingStmtRcvd],
		[rtndClosingStmtSent],
		[rtnsClosingRetNo],
		[rtndSignDt],
		[rtnsDocuments],
		[rtndExecDt],
		[rtnsGrossNet],
		[rtnnFeeStruAlter],
		[rtnsGrossNetAlter],
		[rtnnFeeAlterAmt],
		[rtnbFeeConditionMet],
		[rtnsFeeCondition]
	)
	select
		stc.casnCaseID as rtnnCaseID,
		(
			select top 1
				plnnPlaintiffID
			from [sma_TRN_Plaintiff]
			where plnnCaseID = casnCaseID
				and plnbIsPrimary = 1
		)			   as hosnPlaintiffID,
		case
			when (i.litify_pm__Retainer_Agreement_Sent_Date__c not between '1900-01-01' and '2079-12-31')
				then GETDATE()
			else i.litify_pm__Retainer_Agreement_Sent_Date__c
		end			   as rtndSentDt,
		null		   as [rtndRcvdDt],
		null		   as rtndRetainerDt,
		null		   as rtnbCopyRefAttFee,
		null		   as rtnnFeeStru,
		null		   as rtnbMultiFeeStru,
		null		   as rtnnBeforeTrial,
		null		   as rtnnAfterTrial,
		null		   as rtnnAtAppeal,
		null		   as rtnnUDF1,
		null		   as rtnnUDF2,
		null		   as rtnnUDF3,
		null		   as rtnbComplexStru,
		null		   as rtnbWrittenAgree,
		null		   as rtnnStaffID,
		null		   as rtnsComments,
		null		   as rtnnUserID,
		null		   as rtndDtCreated,
		null		   as rtnnModifyUserID,
		null		   as rtndDtModified,
		null		   as rtnnLevelNo,
		null		   as rtnnPlntfAdv,
		null		   as rtnnFeeAmt,
		null		   as rtnsRetNo,
		null		   as rtndRetStmtSent,
		null		   as rtndRetStmtRcvd,
		null		   as rtndClosingStmtRcvd,
		null		   as rtndClosingStmtSent,
		null		   as rtnsClosingRetNo,
		case
			when (i.litify_pm__Retainer_Agreement_Signed__c not between '1900-01-01' and '2079-12-31')
				then GETDATE()
			else i.litify_pm__Retainer_Agreement_Signed__c
		end			   as rtndSignDt,
		null		   as rtnsDocuments,
		null		   as rtndExecDt,
		null		   as rtnsGrossNet,
		null		   as rtnnFeeStruAlter,
		null		   as rtnsGrossNetAlter,
		null		   as rtnnFeeAlterAmt,
		null		   as rtnbFeeConditionMet,
		null		   as rtnsFeeCondition
	from ShinerLitify..litify_pm__Intake__c i
	join sma_TRN_Cases stc
		on stc.saga_char = i.Id
	where
		ISNULL(i.litify_pm__Retainer_Agreement_Sent_Date__c, '') <> ''
		or ISNULL(i.litify_pm__Retainer_Agreement_Signed__c, '') <> ''
