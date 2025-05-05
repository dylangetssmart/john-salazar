/* ###################################################################################
description: Create Medical Providers and Medical Bills

- Create medical providers from litify_pm__Damage__c
- Create medical providers from litify_pm__Role__c
- Create medical bills from damages

*/

use ShinerSA
go

---------------------------------
--MEDICAL BILLS 
---------------------------------
insert into [sma_TRN_SpDamages]
	(
	[spdsRefTable],
	[spdnRecordID],
	[spdnBillAmt]
	--,[spdnadditionalField2] --written off
	,
	[spdsAccntNo],
	[spddNegotiatedBillAmt],
	[spdnAmtPaid],
	[spddDateFrom],
	[spddDateTo],
	[spddDamageSubType],
	[spdnVisitId],
	[spdsComments],
	[spdnRecUserID],
	[spddDtCreated],
	[spdnModifyUserID],
	[spddDtModified],
	[spdnBalance],
	[spdbLienConfirmed],
	[spdbDocAttached],
	[saga_bill_id]
	)
	select
		'Hospitals'																	 as spdsreftable,
		h.hosnHospitalID															 as spdnrecordid,
		d.litify_pm__Amount_Billed__c												 as spdnbillamt
		--,d.litify_pm__Reduction_Amount__c											 AS [spdnadditionalField2]
		,
		null																		 as spdsaccntno,
		null																		 as spddnegotiatedbillamt,
		d.litify_pm__Amount_Paid__c													 as [spdnamtpaid],
		case
			when d.litify_pm__Service_Start_Date__c between '1900-01-01' and '2079-06-06'
				then d.litify_pm__Service_Start_Date__c
			else null
		end																			 as spdddatefrom,
		case
			when d.litify_pm__Service_End_Date__c between '1900-01-01' and '2079-06-06'
				then d.litify_pm__Service_End_Date__c
			else null
		end																			 as spdddateto,
		null																		 as spdddamagesubtype,
		null																		 as spdnvisitid,
		ISNULL(NULLIF(CONVERT(VARCHAR, d.litify_pm__Comments__c), ''), 'conversion') as spdscomments,
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga_char = d.CreatedById
		)																			 as spdnrecordid,
		case
			when d.CreatedDate between '1900-01-01' and '2079-06-06'
				then d.CreatedDate
			else GETDATE()
		end																			 as spdddtcreated,
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga_char = d.LastModifiedById
		)																			 as spdnmodifyuserid,
		case
			when d.LastModifiedDate between '1900-01-01' and '2079-06-06'
				then d.LastModifiedDate
			else GETDATE()
		end																			 as spdddtmodified,
		null																		 as spdnbalance,
		0																			 as spdblienconfirmed,
		0																			 as spdbdocattached,
		d.Id																		 as saga_bill_id  -- one bill one value
	--select *
	from ShinerLitify..[litify_pm__Damage__c] d
	join vw_litifyRoleMapID r
		on d.litify_pm__Provider__c = r.Id
	join [sma_TRN_Cases] cas
		on cas.saga_char = d.litify_pm__Matter__c
	join [sma_TRN_Hospitals] h
		on h.hosnCaseID = cas.casnCaseID
			and h.hosnContactCtg = r.ctg
			and h.hosnContactID = r.CID
	where ISNULL(d.litify_pm__Type__c, '') in ('Medical Bill'
		--select
		--	code
		--from #DamageTypes dt
		)
		or d.litify_pm__Type__c is null		-- ds 2024-10-21 include null values, which should not exist during live conversion
--WHERE ISNULL(d.litify_pm__type__C, '') IN ('', 'Medical Bill')


alter table [sma_TRN_Hospitals] enable trigger all
go
