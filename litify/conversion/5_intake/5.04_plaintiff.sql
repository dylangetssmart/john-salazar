use ShinerSA
go

--------------------------------------------------
--PLAINTIFFS
--------------------------------------------------
alter table [sma_TRN_Plaintiff] disable trigger all
go

insert into [sma_TRN_Plaintiff]
	(
		[plnnCaseID],
		[plnnContactCtg],
		[plnnContactID],
		[plnnAddressID],
		[plnnRole],
		[plnbIsPrimary],
		[plnbWCOut],
		[plnnPartiallySettled],
		[plnbSettled],
		[plnbOut],
		[plnbSubOut],
		[plnnSeatBeltUsed],
		[plnnCaseValueID],
		[plnnCaseValueFrom],
		[plnnCaseValueTo],
		[plnnPriority],
		[plnnDisbursmentWt],
		[plnbDocAttached],
		[plndFromDt],
		[plndToDt],
		[plnnRecUserID],
		[plndDtCreated],
		[plnnModifyUserID],
		[plndDtModified],
		[plnnLevelNo],
		[plnsMarked],
		[saga],
		[plnnNoInj],
		[plnnMissing],
		[plnnLIPBatchNo],
		[plnnPlaintiffRole],
		[plnnPlaintiffGroup],
		[plnnPrimaryContact],
		plnbIsClient
	)
	select distinct
		CAS.casnCaseID  as [plnnCaseID],
		CIO.CTG			as [plnnContactCtg],
		CIO.CID			as [plnnContactID],
		CIO.AID			as [plnnAddressID],
		S.sbrnSubRoleId as [plnnRole],
		1				as [plnbIsPrimary],
		0,
		0,
		0,
		0,
		0,
		0,
		null,
		null,
		null,
		null,
		null,
		null,
		GETDATE(),
		null,
		368				as [plnnRecUserID],
		GETDATE()		as [plndDtCreated],
		null,
		null,
		null			as [plnnLevelNo],
		null,
		'',
		null,
		null,
		null,
		null,
		null,
		1				as [plnnPrimaryContact],
		1				as plnbIsClient
	from [ShinerLitify]..[litify_pm__intake__c] m
	join [sma_TRN_cases] CAS
		on CAS.saga_char = m.id
	join [sma_MST_SubRole] S
		on CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID
	join IndvOrgContacts_Indexed CIO
		on CIO.saga_char = m.litify_pm__Client__c
	where
		s.sbrnRoleID = 4
		and s.sbrsDscrptn = '(P)-Plaintiff'
go

alter table [sma_TRN_Plaintiff] enable trigger all
go