-- Retainer Agreement Sent Date in Litify = Retainer Sent Date in SA
-- Retainer Agreement Signed in Litify = Retainer Date in SA (edited) 

-- find examples
select --top 5
	i.id   as intake_id,
	m.id   as matter_id,
	cas.casnCaseID,
	m.Name as case_number,
	i.litify_pm__Retainer_Agreement_Sent_Date__c,
	i.litify_pm__Retainer_Agreement_Signed__c
from ShinerLitify..litify_pm__Intake__c i
join ShinerLitify..litify_pm__Matter__c m
	on i.litify_pm__Matter__c = m.Id
join sma_TRN_Cases cas
	on cas.saga_char = m.Id
where
	ISNULL(i.litify_pm__Retainer_Agreement_Sent_Date__c, '') <> '' or ISNULL(i.litify_pm__Retainer_Agreement_Signed__c,'')<>''

--intake_id				matter_id			casnCaseID	case_number			litify_pm__Retainer_Agreement_Sent_Date__c	litify_pm__Retainer_Agreement_Signed__c
--a0CNt00001mM9LzMAK	a0LNt00000OKpbeMAD	1582		MAT-24123129404		2025-01-06 22:40:43							2025-01-13 20:33:43
--a0C8Z00000jtvM5UAI	a0L8Z00000gcMfjUAE	602			MAT-23073128305		2023-07-29 13:41:52							2023-07-30 02:09:44
--a0C8Z00000ju9cEUAQ	a0L8Z00000gdrYgUAI	637			MAT-23081128340		2023-08-11 12:57:55							2023-08-11 13:56:37
--a0CNt00001mMHFwMAO	a0LNt00000OKtFRMA1	1589		MAT-24123129412		2025-01-06 22:37:26							2025-01-14 16:36:12

/* ---------------------------------------------------------------------------------------------------------------
[sma_TRN_Retainer] Schema
*/

-- saga_char
--if not exists (
--		select
--			*
--		from sys.columns
--		where Name = N'saga_char'
--			and object_id = OBJECT_ID(N'sma_TRN_Retainer')
--	)
--begin
--	alter table [sma_TRN_Retainer] add [saga_char] VARCHAR(MAX) null;
--end

--go

---- source_db
--if not exists (
--		select
--			*
--		from sys.columns
--		where Name = N'source_db'
--			and object_id = OBJECT_ID(N'sma_TRN_Retainer')
--	)
--begin
--	alter table [sma_TRN_Retainer] add [source_db] VARCHAR(MAX) null;
--end

--go

---- source_ref
--if not exists (
--		select
--			*
--		from sys.columns
--		where Name = N'source_ref'
--			and object_id = OBJECT_ID(N'sma_TRN_Retainer')
--	)
--begin
--	alter table [sma_TRN_Retainer] add [source_ref] VARCHAR(MAX) null;
--end

--go

/* ---------------------------------------------------------------------------------------------------------------
Update existing retainers
*/

select
	COUNT(*)
from ShinerLitify..litify_pm__Intake__c i
join ShinerLitify..litify_pm__Matter__c m
	on m.id = i.litify_pm__Matter__c
join sma_trn_Cases cas
	on cas.saga_char = m.Id
join sma_TRN_Retainer ret
	on ret.rtnnCaseID = cas.casnCaseID
join IndvOrgContacts_Indexed CIO
		on CIO.saga_char = m.litify_pm__Client__c
join sma_TRN_Plaintiff p
	on p.plnnContactID = cio.CID
	and p.plnnContactCtg = cio.CTG
	and ret.rtnnPlaintiffID = p.plnnPlaintiffID
where
	i.litify_pm__Retainer_Agreement_Sent_Date__c between '1900-01-01' and '2079-12-31'
	and ret.rtndSentDt is null
-- 921



update ret
set ret.rtndSentDt =
case
	when (i.litify_pm__Retainer_Agreement_Sent_Date__c not between '1900-01-01' and '2079-12-31')
		then GETDATE()
	else i.litify_pm__Retainer_Agreement_Sent_Date__c
end
from ShinerLitify..litify_pm__Intake__c i
join ShinerLitify..litify_pm__Matter__c m
	on m.id = i.litify_pm__Matter__c
join sma_trn_Cases cas
	on cas.saga_char = m.Id
join sma_TRN_Retainer ret
	on ret.rtnnCaseID = cas.casnCaseID
join IndvOrgContacts_Indexed CIO
	on CIO.saga_char = m.litify_pm__Client__c
join sma_TRN_Plaintiff p
	on p.plnnContactID = cio.CID
	and p.plnnContactCtg = cio.CTG
	and ret.rtnnPlaintiffID = p.plnnPlaintiffID
where ISNULL(i.litify_pm__Retainer_Agreement_Sent_Date__c, '') <> ''
and ret.rtndSentDt is null


/* ---------------------------------------------------------------------------------------------------------------
Create Missing Referral Types 
*/

--insert into [dbo].[sma_TRN_Retainer]
--	(
--		[rtnnCaseID],
--		[rtnnPlaintiffID],
--		[rtndSentDt],
--		[rtndRcvdDt],
--		[rtndRetainerDt],
--		[rtnbCopyRefAttFee],
--		[rtnnFeeStru],
--		[rtnbMultiFeeStru],
--		[rtnnBeforeTrial],
--		[rtnnAfterTrial],
--		[rtnnAtAppeal],
--		[rtnnUDF1],
--		[rtnnUDF2],
--		[rtnnUDF3],
--		[rtnbComplexStru],
--		[rtnbWrittenAgree],
--		[rtnnStaffID],
--		[rtnsComments],
--		[rtnnUserID],
--		[rtndDtCreated],
--		[rtnnModifyUserID],
--		[rtndDtModified],
--		[rtnnLevelNo],
--		[rtnnPlntfAdv],
--		[rtnnFeeAmt],
--		[rtnsRetNo],
--		[rtndRetStmtSent],
--		[rtndRetStmtRcvd],
--		[rtndClosingStmtRcvd],
--		[rtndClosingStmtSent],
--		[rtnsClosingRetNo],
--		[rtndSignDt],
--		[rtnsDocuments],
--		[rtndExecDt],
--		[rtnsGrossNet],
--		[rtnnFeeStruAlter],
--		[rtnsGrossNetAlter],
--		[rtnnFeeAlterAmt],
--		[rtnbFeeConditionMet],
--		[rtnsFeeCondition],
--		[saga_char],
--		[source_db],
--		[source_ref]
--	)
--	select
--		cas.casnCaseID		   as rtnnCaseID,
--		(
--			select top 1
--				plnnPlaintiffID
--			from [sma_TRN_Plaintiff]
--			where plnnCaseID = casnCaseID
--				and plnbIsPrimary = 1
--		)					   as hosnPlaintiffID,
--		case
--			when (i.litify_pm__Retainer_Agreement_Sent_Date__c not between '1900-01-01' and '2079-12-31')
--				then GETDATE()
--			else i.litify_pm__Retainer_Agreement_Sent_Date__c
--		end					   as rtndSentDt,
--		case
--			when (i.litify_pm__Retainer_Agreement_Signed__c not between '1900-01-01' and '2079-12-31')
--				then GETDATE()
--			else i.litify_pm__Retainer_Agreement_Signed__c
--		end					   as [rtndRcvdDt],
--		null				   as rtndRetainerDt,
--		null				   as rtnbCopyRefAttFee,
--		8				   as rtnnFeeStru,
--		null				   as rtnbMultiFeeStru,
--		null				   as rtnnBeforeTrial,
--		null				   as rtnnAfterTrial,
--		null				   as rtnnAtAppeal,
--		null				   as rtnnUDF1,
--		null				   as rtnnUDF2,
--		null				   as rtnnUDF3,
--		null				   as rtnbComplexStru,
--		null				   as rtnbWrittenAgree,
--		null				   as rtnnStaffID,
--		null				   as rtnsComments,
--		null				   as rtnnUserID,
--		null				   as rtndDtCreated,
--		null				   as rtnnModifyUserID,
--		null				   as rtndDtModified,
--		null				   as rtnnLevelNo,
--		null				   as rtnnPlntfAdv,
--		null				   as rtnnFeeAmt,
--		null				   as rtnsRetNo,
--		null				   as rtndRetStmtSent,
--		null				   as rtndRetStmtRcvd,
--		null				   as rtndClosingStmtRcvd,
--		null				   as rtndClosingStmtSent,
--		null				   as rtnsClosingRetNo,
--		null				   as rtndSignDt,
--		null				   as rtnsDocuments,
--		null				   as rtndExecDt,
--		null				   as rtnsGrossNet,
--		null				   as rtnnFeeStruAlter,
--		null				   as rtnsGrossNetAlter,
--		null				   as rtnnFeeAlterAmt,
--		null				   as rtnbFeeConditionMet,
--		null				   as rtnsFeeCondition,
--		i.Id				   as [saga_char],
--		'litify'			   as [source_db],
--		'litify_pm__Intake__c' as [source_ref]
--	from ShinerLitify..litify_pm__Intake__c i
--	join ShinerLitify..litify_pm__Matter__c m
--		on m.id = i.litify_pm__Matter__c
--	join sma_trn_Cases cas
--		on cas.saga_char = m.Id
--	where
--		ISNULL(i.litify_pm__Retainer_Agreement_Sent_Date__c, '') <> ''
--		or ISNULL(i.litify_pm__Retainer_Agreement_Signed__c, '') <> ''
