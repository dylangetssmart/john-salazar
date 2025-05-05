use ShinerSA
go

/*
alter table [dbo].[sma_TRN_Plaintiff] disable trigger all
delete from [dbo].[sma_TRN_Plaintiff] 
DBCC CHECKIDENT ('[dbo].[sma_TRN_Plaintiff]', RESEED, 0);
alter table [dbo].[sma_TRN_Plaintiff] enable trigger all

alter table [dbo].[sma_TRN_Defendants] disable trigger all
delete from [dbo].[sma_TRN_Defendants] 
DBCC CHECKIDENT ('[dbo].[sma_TRN_Defendants]', RESEED, 0);
alter table [dbo].[sma_TRN_Defendants] enable trigger all
*/
alter table [sma_TRN_Plaintiff] disable trigger all
go

alter table [sma_TRN_Defendants] disable trigger all
go

--------------------------------------------------
--PLAINTIFFS FROM MATTER and ROLES TABLES
--------------------------------------------------
--PLAINTIFF FROM MATTER CLIENT
---------------------------------
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
go

---------------------------------
--PLAINTIFF FROM ROLES
---------------------------------
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

----------------------------------------------
-- Plaintiff Non-Party Contacts
----------------------------------------------
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

		allcon.uniquecontactid as nppnnonpartyuniqueid,
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
		on pl.plnncaseid = cas.casncaseid
	--AND pl.plnncontactctg = cio.ctg
	--AND pl.plnncontactID = cio.cid
	--WHERE pl.plnnPlaintiffID IS NULL		--DO NOT ADD IF ALREADY EXISTS
	where litify_pm__role__c in ('Passenger')
go



----------------------------------------------
--DEFENDANTS FROM MATTER.DEFENDANT
----------------------------------------------
insert into [sma_TRN_Defendants]
	(
	[defnCaseID],
	[defnContactCtgID],
	[defnContactID],
	[defnAddressID],
	[defnSubRole],
	[defbIsPrimary],
	[defbCounterClaim],
	[defbThirdParty],
	[defsThirdPartyRole],
	[defnPriority],
	[defdFrmDt],
	[defdToDt],
	[defnRecUserID],
	[defdDtCreated],
	[defnModifyUserID],
	[defdDtModified],
	[defnLevelNo],
	[defsMarked],
	[saga],
	defbIsClient
	)
	select distinct
		cas.casnCaseID  as [defncaseid],
		cio.ctg			as [defncontactctgid],
		cio.cid			as [defncontactid],
		cio.aid			as [defnaddressid],
		s.sbrnSubRoleId as [defnsubrole],
		1				as [defbisprimary],
		null,
		null,
		null,
		null,
		null,
		null,
		368				as [defnrecuserid],
		GETDATE()		as [defddtcreated],
		null			as [defnmodifyuserid],
		null			as [defddtmodified],
		null,
		null,
		null,
		0				as defbisclient
	--FROM  (SELECT id as matterID, Primary_Defendant__c as Defendant, 'Primary Defendant' as [type] FROM ShinerLitify..litify_pm__Matter__c  WHERE isnull(Primary_Defendant__c,'')<>'' --or isnull(Legacy_Plaintiff__c,'') <>''
	--	UNION
	from (
		select
			litify_pm__Matter__c,
			litify_pm__Party__c as defendant,
			case
				when litify_pm__role__c = 'Defendant Driver'
					then '(D)-Driver'
				when litify_pm__role__c = 'Defendant Owner'
					then '(D)-Owner'
				when litify_pm__role__c = 'Respondent'
					then '(D)-Respondent'
				else '(D)-' + litify_pm__role__c
			end as [role]
		from ShinerLitify..litify_pm__role__c
		where litify_pm__role__c in ('Defendant')
	) m
	join sma_trn_Cases cas
		on cas.saga_char = m.litify_pm__Matter__c
	join [sma_MST_SubRole] s
		on cas.casnOrgCaseTypeID = s.sbrnCaseTypeID
			and s.sbrsDscrptn = m.[role]
			and s.sbrnRoleID = 5
	join IndvOrgContacts_Indexed cio
		on cio.saga_char = m.defendant
go

----------------------------------------------
--DEFENDANTS FROM Party Role
----------------------------------------------
insert into [sma_TRN_Defendants]
	(
	[defnCaseID],
	[defnContactCtgID],
	[defnContactID],
	[defnAddressID],
	[defnSubRole],
	[defbIsPrimary],
	[defbCounterClaim],
	[defbThirdParty],
	[defsThirdPartyRole],
	[defnPriority],
	[defdFrmDt],
	[defdToDt],
	[defnRecUserID],
	[defdDtCreated],
	[defnModifyUserID],
	[defdDtModified],
	[defnLevelNo],
	[defsMarked],
	[saga],
	defbIsClient
	)
	select distinct
		cas.casnCaseID  as [defncaseid],
		cio.ctg			as [defncontactctgid],
		cio.cid			as [defncontactid],
		cio.aid			as [defnaddressid],
		s.sbrnSubRoleId as [defnsubrole],
		1				as [defbisprimary],
		null,
		null,
		null,
		null,
		null,
		null,
		368				as [defnrecuserid],
		GETDATE()		as [defddtcreated],
		null			as [defnmodifyuserid],
		null			as [defddtmodified],
		null,
		null,
		null,
		0				as defbisclient
	--FROM  (SELECT id as matterID, Primary_Defendant__c as Defendant, 'Primary Defendant' as [type] FROM ShinerLitify..litify_pm__Matter__c  WHERE isnull(Primary_Defendant__c,'')<>'' --or isnull(Legacy_Plaintiff__c,'') <>''
	--	UNION
	from ShinerLitify..litify_pm__role__c m
	join [sma_TRN_cases] cas
		on cas.saga_char = m.litify_pm__Matter__c
	join [sma_MST_SubRole] s
		on cas.casnOrgCaseTypeID = s.sbrnCaseTypeID
			and s.sbrnRoleID = 5
			and s.sbrsDscrptn = '(D)-Defendant'
	join IndvOrgContacts_Indexed cio
		on cio.saga_char = m.litify_pm__Party__c
	-- add defendants table so that we don't add any that already exist
	left join [sma_TRN_Defendants] d
		on d.defncaseid = cas.casnCaseID
			and d.defncontactctgid = cio.ctg
			and d.defncontactid = cio.cid
	where m.litify_pm__role__c in ('Defendant')
		and d.defncaseid is null; -- Exclude existing defendants

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

----------------------------------------------------------------
---(APPENDIX B)-- EVERY CASE NEED AT LEAST ONE DEFENDANT
----------------------------------------------------------------
insert into [sma_TRN_Defendants]
	(
	[defnCaseID],
	[defnContactCtgID],
	[defnContactID],
	[defnAddressID],
	[defnSubRole],
	[defbIsPrimary],
	[defbCounterClaim],
	[defbThirdParty],
	[defsThirdPartyRole],
	[defnPriority],
	[defdFrmDt],
	[defdToDt],
	[defnRecUserID],
	[defdDtCreated],
	[defnModifyUserID],
	[defdDtModified],
	[defnLevelNo],
	[defsMarked],
	[saga]
	)
	select
		casnCaseID as [defncaseid],
		1		   as [defncontactctgid],
		(
			select
				cinnContactID
			from sma_MST_IndvContacts
			where cinsFirstName = 'Defendant'
				and cinsLastName = 'Unidentified'
		)		   as [defncontactid],
		null	   as [defnaddressid],
		(
			select
				sbrnSubRoleId
			from sma_MST_SubRole s
			join sma_MST_SubRoleCode c
				on c.srcnCodeId = s.sbrnTypeCode
				and c.srcsDscrptn = '(D)-Defendant'
			where s.sbrnCaseTypeID = cas.casnOrgCaseTypeID
		)		   as [defnsubrole],
		1		   as [defbisprimary], -- reexamine??
		null,
		null,
		null,
		null,
		null,
		null,
		368		   as [defnrecuserid],
		GETDATE()  as [defddtcreated],
		368		   as [defnmodifyuserid],
		GETDATE()  as [defddtmodified],
		null,
		null,
		null
	from sma_trn_cases cas
	left join [sma_TRN_Defendants] d
		on d.defncaseid = cas.casnCaseID
	where d.defncaseid is null
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

----------------------------------------
--ONLY ONE PRIMARY DEFENDANT
----------------------------------------
update sma_TRN_Defendants
set defbIsPrimary = 0
go

update sma_TRN_Defendants
set defbIsPrimary = 1
from (
	select distinct
		d.defnCaseID,
		ROW_NUMBER() over (partition by d.defnCaseID order by d.defnDefendentID asc) as rownumber,
		d.defnDefendentID as id
	from sma_TRN_Defendants d
) a
where a.rownumber = 1
and defnDefendentID = a.id
go


alter table [sma_TRN_Plaintiff] enable trigger all
go

alter table [sma_TRN_Defendants] enable trigger all
go