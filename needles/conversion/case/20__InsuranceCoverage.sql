use [JohnSalazar_SA]
go

/* ------------------------------------------------------------------------------
Helper
*/

if OBJECT_ID('conversion.insurance_contacts_helper', 'U') is not null
begin
	drop table conversion.insurance_contacts_helper
end

create table conversion.insurance_contacts_helper (
	tableIndex			 INT identity (1, 1) not null,
	insurance_id		 INT,					-- table id
	insurer_id			 INT,					-- insurance company
	adjuster_id			 INT,					-- adjuster
	insured				 VARCHAR(100),			-- a person or organization covered by insurance
	incnInsContactID	 INT,
	incnInsAddressID	 INT,
	incnAdjContactId	 INT,
	incnAdjAddressID	 INT,
	incnInsured			 INT,
	pord				 VARCHAR(1),
	caseID				 INT,
	PlaintiffDefendantID INT 
	constraint IX_Insurance_Contacts_Helper primary key clustered
	(
	tableIndex
	) with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on, fillfactor = 80) on [PRIMARY]
) on [PRIMARY]
go

create nonclustered index IX_NonClustered_Index_insurance_id on conversion.insurance_contacts_helper (insurance_id);
create nonclustered index IX_NonClustered_Index_insurer_id on conversion.insurance_contacts_helper (insurer_id);
create nonclustered index IX_NonClustered_Index_adjuster_id on conversion.insurance_contacts_helper (adjuster_id);
go

---(0)---
insert into conversion.insurance_contacts_helper
	(
		insurance_id,
		insurer_id,
		adjuster_id,
		insured,
		incnInsContactID,
		incnInsAddressID,
		incnAdjContactId,
		incnAdjAddressID,
		incnInsured,
		pord,
		caseID,
		PlaintiffDefendantID
	)
	select
		ins.insurance_id,
		ins.insurer_id,
		ins.adjuster_id,
		ins.insured,
		ioc1.CID			 as incninscontactid,
		ioc1.AID			 as incninsaddressid,
		ioc2.CID			 as incnadjcontactid,
		ioc2.AID			 as incnadjaddressid,
		info.UniqueContactId as incninsured,
		null				 as pord,
		cas.casnCaseID		 as caseid,
		null				 as plaintiffdefendantid
	--select *
	from [JohnSalazar_Needles].[dbo].[insurance_Indexed] ins
	join [sma_TRN_Cases] cas
		on cas.cassCaseNumber = CONVERT(VARCHAR, ins.case_num)
	join IndvOrgContacts_Indexed ioc1
		on ioc1.saga = ins.insurer_id
			and ISNULL(ins.insurer_id, 0) <> 0
			and ioc1.CTG = 2
	left join IndvOrgContacts_Indexed ioc2
		on ioc2.saga = ins.adjuster_id
			and ISNULL(ins.adjuster_id, 0) <> 0
	LEFT join [sma_MST_IndvContacts] i
		on i.cinsLastName = ins.insured
			and i.source_id = ins.insured
			and i.source_ref = 'insurance'
	LEFT join [sma_MST_AllContactInfo] info
		on info.ContactId = i.cinnContactID
			and info.ContactCtg = i.cinnContactCtg
	--where ins.case_num = 213581
go

dbcc dbreindex ('conversion.insurance_contacts_helper', ' ', 90) with no_infomsgs
go

-------------------------------------------------------------------------------
-- Build conversion.multi_party_helper
-------------------------------------------------------------------------------
if OBJECT_ID('conversion.multi_party_helper') is not null
begin
	drop table conversion.multi_party_helper
end

go

-- Seed multi_party_helper with plaintiff id's
select
	ins.insurance_id as ins_id,
	t.plnnPlaintiffID
into conversion.multi_party_helper
--select *
from [JohnSalazar_Needles].[dbo].[insurance_Indexed] ins
join [sma_TRN_cases] cas
	on cas.cassCaseNumber = ins.case_num
join [IndvOrgContacts_Indexed] ioc
	on ioc.SAGA = ins.party_id
join [sma_TRN_Plaintiff] t
	on t.plnnContactID = ioc.CID
		and t.plnnContactCtg = ioc.CTG
		and t.plnnCaseID = cas.casnCaseID
go

-- update insurance_contacts_helper.pord = P using multi_party_helper
update conversion.insurance_contacts_helper
set pord = 'P',
	PlaintiffDefendantID = A.plnnPlaintiffID
from conversion.multi_party_helper a
where a.ins_id = insurance_id
go

-- drop multi_party_helper
if OBJECT_ID('conversion.multi_party_helper') is not null
begin
	drop table conversion.multi_party_helper
end

go

-- Seed multi_party_helper with defendant id's
select
	ins.insurance_id as ins_id,
	d.defnDefendentID
into conversion.multi_party_helper
from [JohnSalazar_Needles].[dbo].[insurance_Indexed] ins
join [sma_TRN_cases] cas
	on cas.cassCaseNumber = ins.case_num
join [IndvOrgContacts_Indexed] ioc
	on ioc.SAGA = ins.party_id
join [sma_TRN_Defendants] d
	on d.defnContactID = ioc.CID
		and d.defnContactCtgID = ioc.CTG
		and d.defnCaseID = cas.casnCaseID
go

-- update insurance_contacts_helper.pord = D using multi_party_helper
update conversion.insurance_contacts_helper
set pord = 'D',
	PlaintiffDefendantID = A.defnDefendentID
from conversion.multi_party_helper a
where a.ins_id = insurance_id
go


/* ------------------------------------------------------------------------------
Insurance Types
*/ ------------------------------------------------------------------------------
insert into [sma_MST_InsuranceType]
	(
		intsDscrptn
	)
	select
		'Unspecified'
	union
	select distinct
		policy_type
	from [JohnSalazar_Needles].[dbo].[insurance] ins
	where
		ISNULL(policy_type, '') <> ''
	except
	select
		intsDscrptn
	from [sma_MST_InsuranceType]
go

/* ------------------------------------------------------------------------------
Plaintiff Insurance
*/ ------------------------------------------------------------------------------
alter table [sma_TRN_InsuranceCoverage] disable trigger all
go

insert into [sma_TRN_InsuranceCoverage]
	(
		[incnCaseID],
		[incnInsContactID],
		[incnInsAddressID],
		[incbCarrierHasLienYN],
		[incnInsType],
		[incnAdjContactId],
		[incnAdjAddressID],
		[incsPolicyNo],
		[incsClaimNo],
		[incnStackedTimes],
		[incsComments],
		[incnInsured],
		[incnCovgAmt],
		[incnDeductible],
		[incnUnInsPolicyLimit],
		[incnUnderPolicyLimit],
		[incbPolicyTerm],
		[incbTotCovg],
		[incsPlaintiffOrDef],
		[incnPlaintiffIDOrDefendantID],
		[incnTPAdminOrgID],
		[incnTPAdminAddID],
		[incnTPAdjContactID],
		[incnTPAdjAddID],
		[incsTPAClaimNo],
		[incnRecUserID],
		[incdDtCreated],
		[incnModifyUserID],
		[incdDtModified],
		[incnLevelNo],
		[incnUnInsPolicyLimitAcc],
		[incnUnderPolicyLimitAcc],
		[incb100Per],
		[incnMVLeased],
		[incnPriority],
		[incbDelete],
		[incnauthtodefcoun],
		[incnauthtodefcounDt],
		[incbPrimary],
		[saga]
	)
	select distinct
		map.caseID				 as [incncaseid],
		map.incninscontactid	 as [incninscontactid],
		map.incninsaddressid	 as [incninsaddressid],
		null					 as [incbcarrierhaslienyn],
		(
			select
				intnInsuranceTypeID
			from [sma_MST_InsuranceType]
			where intsDscrptn = case
					when ISNULL(ins.policy_type, '') <> ''
						then ins.policy_type
					else 'Unspecified'
				end
		)						 as [incninstype],
		map.incnadjcontactid	 as [incnadjcontactid],
		map.incnadjaddressid	 as [incnadjaddressid],
		ins.policy				 as [incspolicyno],
		ins.claim				 as [incsclaimno],
		null					 as [incnstackedtimes],
		''						 as [incscomments],
		map.incninsured			 as [incninsured],
		ins.actual				 as [incncovgamt],
		null					 as [incndeductible],
		0						 as [incnuninspolicylimit],
		0						 as [incnunderpolicylimit],
		0						 as [incbpolicyterm],
		0						 as [incbtotcovg],
		'P'						 as [incsplaintiffordef],
		--    ( select plnnPlaintiffID from sma_TRN_Plaintiff where plnnCaseID=MAP.caseID and plnbIsPrimary=1 )  
		map.PlaintiffDefendantID as [incnplaintiffidordefendantid],
		null					 as [incntpadminorgid],
		null					 as [incntpadminaddid],
		null					 as [incntpadjcontactid],
		null					 as [incntpadjaddid],
		null					 as [incstpaclaimno],
		368						 as [incnrecuserid],
		GETDATE()				 as [incddtcreated],
		null					 as [incnmodifyuserid],
		null					 as [incddtmodified],
		null					 as [incnlevelno],
		null					 as [incnuninspolicylimitacc],
		null					 as [incnunderpolicylimitacc],
		0						 as [incb100per],
		null					 as [incnmvleased],
		null					 as [incnpriority],
		0						 as [incbdelete],
		0						 as [incnauthtodefcoun],
		null					 as [incnauthtodefcoundt],
		0						 as [incbprimary],
		ins.insurance_id		 as [saga]
	--select *
	from [JohnSalazar_Needles].[dbo].[insurance_Indexed] ins
	left join [JohnSalazar_Needles].[dbo].[user_insurance_data] ud
		on ins.insurance_id = ud.insurance_id
	--LEFT JOIN InsuranceLimMap LIM on LIM.case_num = ins.case_num and LIM.insurer_ID = ins.insurer_id
	join conversion.insurance_contacts_helper map
		on ins.insurance_id = map.insurance_id
			and map.pord = 'P'
go

/* ------------------------------------------------------------------------------
Defendant Insurance
*/ ------------------------------------------------------------------------------
insert into [sma_TRN_InsuranceCoverage]
	(
		[incnCaseID],
		[incnInsContactID],
		[incnInsAddressID],
		[incbCarrierHasLienYN],
		[incnInsType],
		[incnAdjContactId],
		[incnAdjAddressID],
		[incsPolicyNo],
		[incsClaimNo],
		[incnStackedTimes],
		[incsComments],
		[incnInsured],
		[incnCovgAmt],
		[incnDeductible],
		[incnUnInsPolicyLimit],
		[incnUnderPolicyLimit],
		[incbPolicyTerm],
		[incbTotCovg],
		[incsPlaintiffOrDef],
		[incnPlaintiffIDOrDefendantID],
		[incnTPAdminOrgID],
		[incnTPAdminAddID],
		[incnTPAdjContactID],
		[incnTPAdjAddID],
		[incsTPAClaimNo],
		[incnRecUserID],
		[incdDtCreated],
		[incnModifyUserID],
		[incdDtModified],
		[incnLevelNo],
		[incnUnInsPolicyLimitAcc],
		[incnUnderPolicyLimitAcc],
		[incb100Per],
		[incnMVLeased],
		[incnPriority],
		[incbDelete],
		[incnauthtodefcoun],
		[incnauthtodefcounDt],
		[incbPrimary],
		[saga]
	)
	select distinct
		map.caseID				 as [incncaseid],
		map.incninscontactid	 as [incninscontactid],
		map.incninsaddressid	 as [incninsaddressid],
		null					 as [incbcarrierhaslienyn],
		(
			select
				intnInsuranceTypeID
			from [sma_MST_InsuranceType]
			where intsDscrptn = case
					when ISNULL(ins.policy_type, '') <> ''
						then ins.policy_type
					else 'Unspecified'
				end
		)						 as [incninstype],
		map.incnadjcontactid	 as [incnadjcontactid],
		map.incnadjaddressid	 as [incnadjaddressid],
		ins.policy				 as [incspolicyno],
		ins.claim				 as [incsclaimno],
		null					 as [incnstackedtimes],
		''						 as [incscomments],
		map.incninsured			 as [incninsured],
		ins.actual				 as [incncovgamt],
		null					 as [incndeductible],
		0						 as [incnuninspolicylimit],
		0						 as [incnunderpolicylimit],
		0						 as [incbpolicyterm],
		0						 as [incbtotcovg],
		'D'						 as [incsplaintiffordef],
		map.PlaintiffDefendantID as [incnplaintiffidordefendantid],
		null					 as [incntpadminorgid],
		null					 as [incntpadminaddid],
		null					 as [incntpadjcontactid],
		null					 as [incntpadjaddid],
		null					 as [incstpaclaimno],
		368						 as [incnrecuserid],
		GETDATE()				 as [incddtcreated],
		null					 as [incnmodifyuserid],
		null					 as [incddtmodified],
		null					 as [incnlevelno],
		null					 as [incnuninspolicylimitacc],
		null					 as [incnunderpolicylimitacc],
		0						 as [incb100per],
		null					 as [incnmvleased],
		null					 as [incnpriority],
		0						 as [incbdelete],
		0						 as [incnauthtodefcoun],
		null					 as [incnauthtodefcoundt],
		0						 as [incbprimary],
		ins.insurance_id		 as [saga]
	from [JohnSalazar_Needles].[dbo].[insurance_Indexed] ins
	left join [JohnSalazar_Needles].[dbo].[user_insurance_data] ud
		on ins.insurance_id = ud.insurance_id
	--LEFT JOIN InsuranceLimMap LIM on LIM.case_num = ins.case_num and LIM.insurer_ID = ins.insurer_id
	join conversion.insurance_contacts_helper map
		on ins.insurance_id = map.insurance_id
			and map.pord = 'D'
go

alter table [sma_TRN_InsuranceCoverage] enable trigger all
go


/* ------------------------------------------------------------------------------
Adjusters
*/ ------------------------------------------------------------------------------

-- Adjuster/Insurer association
insert into [sma_MST_RelContacts]
	(
		[rlcnPrimaryCtgID],
		[rlcnPrimaryContactID],
		[rlcnPrimaryAddressID],
		[rlcnRelCtgID],
		[rlcnRelContactID],
		[rlcnRelAddressID],
		[rlcnRelTypeID],
		[rlcnRecUserID],
		[rlcdDtCreated],
		[rlcnModifyUserID],
		[rlcdDtModified],
		[rlcnLevelNo],
		[rlcsBizFam],
		[rlcnOrgTypeID]
	)
	select distinct
		1					  as [rlcnprimaryctgid],
		ic.[incnAdjContactId] as [rlcnprimarycontactid],
		ic.[incnAdjAddressID] as [rlcnprimaryaddressid],
		2					  as [rlcnrelctgid],
		ic.[incnInsContactID] as [rlcnrelcontactid],
		ic.[incnAdjAddressID] as [rlcnreladdressid],
		2					  as [rlcnreltypeid],
		368					  as [rlcnrecuserid],
		GETDATE()			  as [rlcddtcreated],
		null				  as [rlcnmodifyuserid],
		null				  as [rlcddtmodified],
		null				  as [rlcnlevelno],
		'Business'			  as [rlcsbizfam],
		null				  as [rlcnorgtypeid]
	from [sma_TRN_InsuranceCoverage] ic
	where
		ISNULL(ic.[incnAdjContactId], 0) <> 0
		and ISNULL(ic.[incnInsContactID], 0) <> 0

-- Insert Insurance Adjusters
insert into [sma_TRN_InsuranceCoverageAdjusters]
	(
		InsuranceCoverageId,
		AdjusterContactUID
	)
	select
		incnInsCovgID,
		ioc2.UNQCID
	from sma_TRN_InsuranceCoverage ic
	join IndvOrgContacts_Indexed ioc2
		on ioc2.CID = ic.incnAdjContactId
			and ioc2.AID = ic.[incnAdjAddressID]
	left join sma_TRN_InsuranceCoverageAdjusters ca
		on ca.InsuranceCoverageId = incnInsCovgID
			and ca.AdjusterContactUID = ioc2.UNQCID
	where
		ca.InsuranceCoverageId is null