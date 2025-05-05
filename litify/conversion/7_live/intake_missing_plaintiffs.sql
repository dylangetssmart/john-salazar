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
		cas.casnCaseID					as [plnncaseid],
		COALESCE(cio.CTG, cio_unid.ctg) as [plnncontactctg],
		COALESCE(cio.CID, cio_unid.cid) as [plnncontactid],
		COALESCE(cio.AID, cio_unid.aid) as [plnnaddressid],
		s.sbrnSubRoleId					as [plnnrole],
		1								as [plnbisprimary],
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
		368								as [plnnrecuserid],
		GETDATE()						as [plnddtcreated],
		null,
		null,
		null							as [plnnlevelno],
		null,
		'',
		null,
		null,
		null,
		null,
		null,
		1								as [plnnprimarycontact],
		1								as plnbisclient
	--select	*
	from ShinerLitify..litify_pm__role__c m
	join [sma_TRN_cases] cas
		on cas.saga_char = m.litify_pm__Intake__c
	join [sma_MST_SubRole] s
		on cas.casnOrgCaseTypeID = s.sbrnCaseTypeID
			and s.sbrnRoleID = 4
			and s.sbrsDscrptn = '(P)-Plaintiff'
	left join IndvOrgContacts_Indexed cio
		on cio.saga_char = m.litify_pm__Party__c
	left join IndvOrgContacts_Indexed cio_unid
		on cio_unid.Name = 'Plaintiff Unidentified'
	left join [sma_TRN_Plaintiff] pl
		on pl.plnncaseid = cas.casncaseid
			and pl.plnncontactctg = cio.ctg
			and pl.plnncontactid = cio.cid
	where
		pl.plnnPlaintiffID is null		--DO NOT ADD IF ALREADY EXISTS
		and litify_pm__role__c in ('Plaintiff', 'Client')

alter table [sma_TRN_Plaintiff] enable trigger all
go


SELECT *
from sma_TRN_Cases cas
LEFT join sma_TRN_Plaintiff p
on p.plnnCaseID = cas.casnCaseID
where p.plnnPlaintiffID is null
and cas.source_ref = 'litify_pm__intake__c'
-- id: 2638

--select top 5
--	*
--from sma_MST_IndvContacts smic
--where
--	smic.source_ref = 'role: missing intake'
--select
--	*
--from IndvOrgContacts_Indexed ioci
--where
--	ioci.CID in (20462,
--	20463,
--	20464,
--	20465,
--	20466)