use [SA]
go

-------------------------------------------------------------------------------
-- Insert defendants
-------------------------------------------------------------------------------
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
	[saga_party]
	)
	select
		casnCaseID	  as [defncaseid],
		acio.CTG	  as [defncontactctgid],
		acio.CID	  as [defncontactid],
		acio.AID	  as [defnaddressid],
		sbrnSubRoleId as [defnsubrole],
		1			  as [defbisprimary],
		null,
		null,
		null,
		null,
		null,
		null,
		368			  as [defnrecuserid],
		GETDATE()	  as [defddtcreated],
		null		  as [defnmodifyuserid],
		null		  as [defddtmodified],
		null		  as [defnlevelno],
		null,
		null,
		p.TableIndex  as [saga_party]
	from Needles.[dbo].[party_indexed] p
	join [sma_TRN_Cases] cas
		on cas.cassCaseNumber = p.case_id
	join IndvOrgContacts_Indexed acio
		on acio.SAGA = p.party_id
	join [PartyRoles] pr
		on pr.[Needles Roles] = p.[role]
	join [sma_MST_SubRole] s
		on cas.casnOrgCaseTypeID = s.sbrnCaseTypeID
			and s.sbrsDscrptn = [sa roles]
			and s.sbrnRoleID = 5
	where pr.[sa party] = 'Defendant'
go

-------------------------------------------------------------------------------
-- Every case need at least one defendant
-------------------------------------------------------------------------------
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
				cinncontactid
			from sma_MST_IndvContacts
			where cinsFirstName = 'Defendant'
				and cinsLastName = 'Unidentified'
		)		   as [defncontactid],
		null	   as [defnaddressid],
		(
			select
				sbrnSubRoleId
			from sma_MST_SubRole s
			inner join sma_MST_SubRoleCode c
				on c.srcnCodeId = s.sbrnTypeCode
				and c.srcsDscrptn = '(D)-Default Role'
			where s.sbrnCaseTypeID = cas.casnOrgCaseTypeID
		)		   as [defnsubrole],
		1		   as [defbisprimary],-- reexamine??
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

-------------------------------------------------------------------------------
-- Update primary defendant
-------------------------------------------------------------------------------
update sma_TRN_Defendants
set defbIsPrimary = 0

update sma_TRN_Defendants
set defbIsPrimary = 1
from (
	select distinct
		d.defnCaseID,
		ROW_NUMBER() over (partition by d.defnCaseID order by p.record_num) as rownumber,
		d.defnDefendentID as id
	from sma_TRN_Defendants d
	left join Needles.[dbo].[party_indexed] p
		on p.TableIndex = d.saga_party
) a
where a.rownumber = 1
and defnDefendentID = a.id

go


---
alter table [sma_TRN_Defendants] enable trigger all
go