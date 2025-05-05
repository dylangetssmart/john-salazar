/* ######################################################################################
description: Insert plaintiffs
steps:
	- Plaintiffs from matter
	- Plaintiffs from party roles
	- Plaintiff Non-Party Contact
	- at least one plaintiff
	- one primary plaintiff
usage_instructions:
	-
dependencies:
	- 
notes:
	-
#########################################################################################
*/

use ShinerSA
go

alter table [sma_TRN_Plaintiff] disable trigger all
go

------------------------------------------------------------------
-- Plaintiff from [litify_pm__Matter__c].[litify_pm__Client__c]
------------------------------------------------------------------
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
		cas.casnCaseID  as [plnncaseid],
		cio.CTG			as [plnncontactctg],
		cio.CID			as [plnncontactid],
		cio.AID			as [plnnaddressid],
		s.sbrnSubRoleId as [plnnrole],
		1				as [plnbisprimary],
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
		368				as [plnnrecuserid],
		GETDATE()		as [plnddtcreated],
		null,
		null,
		null			as [plnnlevelno],
		null,
		'',
		null,
		null,
		null,
		null,
		null,
		1				as [plnnprimarycontact],
		1				as plnbisclient
	--select *
	from ShinerLitify..litify_pm__Matter__c m
	join [sma_TRN_cases] cas
		on cas.saga_char = m.ID
	join [sma_MST_SubRole] s
		on cas.casnOrgCaseTypeID = s.sbrnCaseTypeID
			and s.sbrnRoleID = 4
			and s.sbrsDscrptn = '(P)-Plaintiff'
	join IndvOrgContacts_Indexed cio
		on cio.saga_char = m.litify_pm__Client__c
	where ISNULL(litify_pm__Client__c, '') <> ''
--and m.litify_pm__Client__c = '0018Z00002rywgsQAA'
go

------------------------------------------------------------------
-- Plaintiff from Roles
-- standard but takes Party Role Mapping
-- [litify_pm__role__c].[litify_pm__role__c]
-- [litify_pm__role__c] in ('Plaintiff', 'Client')
-- Expected count = 14332
------------------------------------------------------------------
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
		cas.casnCaseID  as [plnncaseid],
		cio.CTG			as [plnncontactctg],
		cio.CID			as [plnncontactid],
		cio.AID			as [plnnaddressid],
		s.sbrnSubRoleId as [plnnrole],
		1				as [plnbisprimary],
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
		368				as [plnnrecuserid],
		GETDATE()		as [plnddtcreated],
		null,
		null,
		null			as [plnnlevelno],
		null,
		'',
		null,
		null,
		null,
		null,
		null,
		1				as [plnnprimarycontact],
		1				as plnbisclient
	from ShinerLitify..litify_pm__role__c m
	join [sma_TRN_cases] cas
		on cas.saga_char = m.litify_pm__Matter__c
	join [sma_MST_SubRole] s
		on cas.casnOrgCaseTypeID = s.sbrnCaseTypeID
			and s.sbrnRoleID = 4
			and s.sbrsDscrptn = '(P)-Plaintiff'
	join IndvOrgContacts_Indexed cio
		on cio.saga_char = m.litify_pm__Party__c
	left join [sma_TRN_Plaintiff] pl
		on pl.plnncaseid = cas.casncaseid
			and pl.plnncontactctg = cio.ctg
			and pl.plnncontactid = cio.cid
	where pl.plnnPlaintiffID is null		--DO NOT ADD IF ALREADY EXISTS
		and litify_pm__role__c in ('Plaintiff', 'Client')
go

------------------------------------------------------------------
-- Plaintiff Non-Party Contacts
-- Custom for Shiner from Party Role mapping
-- [litify_pm__role__c].[litify_pm__role__c]
-- [litify_pm__role__c] in ('Passenger', 'Client')
-- Expected count = 3
------------------------------------------------------------------
insert into [dbo].[sma_TRN_NonPlaintiffParty]
	(
	[nppnNonPartyUniqueID],
	[nppnPlaintiffId],
	[nppsNonPartyComments],
	[nppdDateCreated],
	[nppdDateModified],
	[nppnCreatedBy],
	[nppnModifiedBy],
	[nppbPrimaryContact]
	)

	select distinct
		allcon.UniqueContactId as nppnnonpartyuniqueid,
		pl.plnnPlaintiffID	   as nppnplaintiffid,
		null				   as nppsnonpartycomments,
		null				   as nppddatecreated,
		null				   as nppddatemodified,
		null				   as nppncreatedby,
		null				   as nppnmodifiedby,
		null				   as nppbprimarycontact
	-- role.party > contact > allcontactinfo
	--select *
	from ShinerLitify..litify_pm__role__c m
	join [sma_TRN_cases] cas
		on cas.saga_char = m.litify_pm__Matter__c
	--select * FROM sma_MST_AllContactInfo 
	--JOIN [sma_MST_SubRole] S
	--	ON CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID
	--		AND s.sbrnRoleID = 4
	--		AND s.sbrsDscrptn = CASE
	--			WHEN litify_pm__role__c = 'Plaintiff 2'
	--				THEN '(P)-Plaintiff 2'
	--			WHEN litify_pm__role__c = 'Petitioner'
	--				THEN '(P)-Petitioner'
	--			WHEN litify_pm__role__c = 'Claimant'
	--				THEN '(P)-Claimant'
	--			WHEN litify_pm__role__c = 'Deceased'
	--				THEN '(P)-Deceased'
	--			ELSE '(P)-Plaintiff'
	--		END
	join IndvOrgContacts_Indexed cio
		on cio.saga_char = m.litify_pm__Party__c
	join sma_MST_AllContactInfo allcon
		on allcon.ContactId = cio.CID
			and allcon.ContactCtg = 1
	left join [sma_TRN_Plaintiff] pl
		on pl.plnnCaseID = cas.casncaseid
	--AND pl.plnncontactctg = cio.ctg
	--AND pl.plnncontactID = cio.cid
	--WHERE pl.plnnPlaintiffID IS NULL		--DO NOT ADD IF ALREADY EXISTS
	where litify_pm__role__c in ('Passenger')
go

alter table [sma_TRN_Plaintiff] enable trigger all
go

----------------------------------------------------------------
---(APPENDIX A)-- EVERY CASE NEED AT LEAST ONE PLAINTIFF
----------------------------------------------------------------
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
	[plnnPrimaryContact]
	)
	select
		casnCaseID as [plnncaseid],
		1		   as [plnncontactctg],
		(
			select
				cinncontactid
			from sma_MST_IndvContacts
			where cinsFirstName = 'Plaintiff'
				and cinsLastName = 'Unidentified'
		)		   as [plnncontactid],   -- Unidentified Plaintiff
		null	   as [plnnaddressid],
		(
			select
				sbrnSubRoleId
			from sma_MST_SubRole s
			join sma_MST_SubRoleCode c
				on c.srcnCodeId = s.sbrnTypeCode
				and c.srcsDscrptn = '(P)-Plaintiff'
			where s.sbrnCaseTypeID = cas.casnOrgCaseTypeID
		)		   as plnnrole,
		1		   as [plnbisprimary],
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
		368		   as [plnnrecuserid],
		GETDATE()  as [plnddtcreated],
		null,
		null,
		'',
		null,
		'',
		null,
		null,
		null,
		null,
		null,
		1		   as [plnnprimarycontact]
	from sma_trn_cases cas
	left join [sma_TRN_Plaintiff] t
		on t.plnncaseid = cas.casnCaseID
	where plnncaseid is null
go


----------------------------------------
--ONLY ONE PRIMARY PLAINTIFF
----------------------------------------
update sma_TRN_Plaintiff
set plnbIsPrimary = 0
go

update sma_TRN_Plaintiff
set plnbIsPrimary = 1
from (
	select distinct
		t.plnnCaseID,
		ROW_NUMBER() over (partition by t.plnnCaseID order by t.plnnPlaintiffID asc) as rownumber,
		t.plnnPlaintiffID as id
	from sma_TRN_Plaintiff t
) a
where a.rownumber = 1
and plnnPlaintiffID = a.id
go