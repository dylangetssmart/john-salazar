/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create users and contacts

replace:
'OfficeName'
'StateDescription'
'VenderCaseType'
##########################################################################################################################
*/

use [JohnSalazar_SA]
go

/*
alter table [sma_TRN_InsuranceCoverage] disable trigger all
delete from [sma_TRN_InsuranceCoverage]
DBCC CHECKIDENT ('[sma_TRN_InsuranceCoverage]', RESEED, 0);
alter table [sma_TRN_InsuranceCoverage] disable trigger all
*/

if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and object_id = OBJECT_ID(N'sma_TRN_InsuranceCoverage')
	)
begin
	alter table [sma_TRN_InsuranceCoverage]
	add [saga] INT null;
end

/*
-------------------------------------------------------------------------------
##############################################################################
-------------------------------------------------------------------------------
Build support table with anchors and values
*/
if exists (
		select
			*
		from sys.objects
		where name = 'Insurance_Contacts_Helper'
			and type = 'U'
	)
begin
	drop table Insurance_Contacts_Helper
end
go

create table Insurance_Contacts_Helper (
	tableIndex			 INT identity (1, 1) not null,
	insurance_id		 INT			-- table id
	,
	insurer_id			 INT				-- insurance company
	,
	adjuster_id			 INT				-- adjuster
	,
	insured				 VARCHAR(100)		-- a person or organization covered by insurance
	,
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

create nonclustered index IX_NonClustered_Index_insurance_id on Insurance_Contacts_Helper (insurance_id);
go

create nonclustered index IX_NonClustered_Index_insurer_id on Insurance_Contacts_Helper (insurer_id);
go

create nonclustered index IX_NonClustered_Index_adjuster_id on Insurance_Contacts_Helper (adjuster_id);
go

---(0)---
insert into Insurance_Contacts_Helper
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
		on cas.cassCaseNumber = ins.case_num
	join IndvOrgContacts_Indexed ioc1
		on ioc1.saga = ins.insurer_id
			and ISNULL(ins.insurer_id, 0) <> 0
			and ioc1.CTG = 2
	left join IndvOrgContacts_Indexed ioc2
		on ioc2.saga = ins.adjuster_id
			and ISNULL(ins.adjuster_id, 0) <> 0
	join [sma_MST_IndvContacts] i
		on i.cinsLastName = ins.insured
			and i.cinsGrade = ins.insured
			and i.saga = -1
	join [sma_MST_AllContactInfo] info
		on info.ContactId = i.cinnContactID
			and info.ContactCtg = i.cinnContactCtg
go

dbcc dbreindex ('Insurance_Contacts_Helper', ' ', 90) with no_infomsgs
go

---(0)--- (prepare for multiple party)
if exists (
		select
			*
		from sys.objects
		where Name = 'multi_party_helper_temp'
	)
begin
	drop table [multi_party_helper_temp]
end
go

select
	ins.insurance_id as ins_id,
	t.plnnPlaintiffID into [multi_party_helper_temp]
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

update [Insurance_Contacts_Helper]
set pord = 'P',
	PlaintiffDefendantID = A.plnnPlaintiffID
from [multi_party_helper_temp] a
where a.ins_id = insurance_id
go

if exists (
		select
			*
		from sys.objects
		where Name = 'multi_party_helper_temp'
	)
begin
	drop table [multi_party_helper_temp]
end
go

select
	ins.insurance_id as ins_id,
	d.defnDefendentID into [multi_party_helper_temp]
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

update [Insurance_Contacts_Helper]
set pord = 'D',
	PlaintiffDefendantID = A.defnDefendentID
from [multi_party_helper_temp] a
where a.ins_id = insurance_id
go

-------------------------------------------------------------------------------
-- Insurance Types ############################################################
-------------------------------------------------------------------------------
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
	where ISNULL(policy_type, '') <> ''
	except
	select
		intsDscrptn
	from [sma_MST_InsuranceType]
go

---
alter table [sma_TRN_InsuranceCoverage] disable trigger all
---
go

--(1)--- Insurance of plaintiffs
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
	select
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
		null					 as [incnstackedtimes]
		--  ,ISNULL('accept: ' + NULLIF(CONVERT(VARCHAR, INS.accept), '') + CHAR(13), '') +
		--ISNULL('actual: ' + NULLIF(CONVERT(VARCHAR, INS.actual), '') + CHAR(13), '') +
		--ISNULL('agent: ' + NULLIF(CONVERT(VARCHAR, INS.agent), '') + CHAR(13), '') +
		--ISNULL('date_settled: ' + NULLIF(CONVERT(VARCHAR, INS.date_settled), '') + CHAR(13), '') +
		--ISNULL('how_settled: ' + NULLIF(CONVERT(VARCHAR, INS.how_settled), '') + CHAR(13), '') +
		--ISNULL('maximum_amount: ' + NULLIF(CONVERT(VARCHAR, INS.maximum_amount), '') + CHAR(13), '') +
		--ISNULL('minimum_amount: ' + NULLIF(CONVERT(VARCHAR, INS.minimum_amount), '') + CHAR(13), '') +
		--ISNULL('policy: ' + NULLIF(CONVERT(VARCHAR, INS.policy), '') + CHAR(13), '') +
		--ISNULL('claim: ' + NULLIF(CONVERT(VARCHAR, INS.claim), '') + CHAR(13), '') +
		--ISNULL('insured: ' + NULLIF(CONVERT(VARCHAR, INS.insured), '') + CHAR(13), '') +
		--ISNULL('limits: ' + NULLIF(CONVERT(VARCHAR, INS.limits), '') + CHAR(13), '') +
		--ISNULL('comments : ' + NULLIF(CONVERT(VARCHAR, INS.comments), '') + CHAR(13), '') +
		--ISNULL('Value Date: ' + NULLIF(CONVERT(VARCHAR, Ud.Value_date, 101), '') + CHAR(13), '') +
		--ISNULL('Requested Limits: ' + NULLIF(CONVERT(VARCHAR, Ud.Requested_Limits), '') + CHAR(13), '') +
		--ISNULL('Projected Settlement Date: ' + NULLIF(CONVERT(VARCHAR, Ud.Projected_Settlement_Date, 101), '') + CHAR(13), '') +
		--ISNULL('Medpay: ' + NULLIF(CONVERT(VARCHAR, ud.Medpay), '') + CHAR(13), '') +
		--ISNULL('About Limits: ' + NULLIF(CONVERT(VARCHAR, Ud.About_Limits), '') + CHAR(13), '') +
		--ISNULL('ERISA Lien: ' + NULLIF(CONVERT(VARCHAR, Ud.ERISA_Lien), '') + CHAR(13), '') +
		--ISNULL('Subro Provider: ' + NULLIF(CONVERT(VARCHAR, Ud.Subro_Provider), '') + CHAR(13), '') +
		--ISNULL('Nurse Case Manager: ' + NULLIF(CONVERT(VARCHAR, Ud.Nurse_Case_Manager), '') + CHAR(13), '') +
		--ISNULL('NCM: ' + NULLIF(CONVERT(VARCHAR, Ud.NCM), '') + CHAR(13), '') +
		--ISNULL('Credit Attorney: ' + NULLIF(CONVERT(VARCHAR, Ud.Credit_Date, 101), '') + CHAR(13), '') +
		--ISNULL('Credit Date: ' + NULLIF(CONVERT(VARCHAR, Ud.NCM), '') + CHAR(13), '') +
		--ISNULL('Red Folder Research: ' + NULLIF(CONVERT(VARCHAR, Ud.Red_Folder_Research), '') + CHAR(13), '') +
		--ISNULL('Is_there_a_John_Doe: ' + NULLIF(CONVERT(VARCHAR, Ud.Is_there_a_John_Doe), '') + CHAR(13), '') +
		,
		''						 as [incscomments],
		map.incninsured			 as [incninsured],
		ins.actual				 as [incncovgamt],
		null					 as [incndeductible],
		--lim.[high]						as [incnUnInsPolicyLimit],
		--lim.[low]						as [incnUnderPolicyLimit],
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
	join [Insurance_Contacts_Helper] map
		on ins.insurance_id = map.insurance_id
			and map.pord = 'P'
go


---(2)--- Insurance of defendants
--INSERT INTO [sma_TRN_InsuranceCoverage] 
--(
--	[incnCaseID],[incnInsContactID],[incnInsAddressID],[incbCarrierHasLienYN],[incnInsType],[incnAdjContactId],[incnAdjAddressID],[incsPolicyNo],[incsClaimNo],[incnStackedTimes],
--	[incsComments],[incnInsured],[incnCovgAmt],[incnDeductible],[incnUnInsPolicyLimit],[incnUnderPolicyLimit],[incbPolicyTerm],[incbTotCovg],[incsPlaintiffOrDef],[incnPlaintiffIDOrDefendantID],
--	[incnTPAdminOrgID],[incnTPAdminAddID],[incnTPAdjContactID],[incnTPAdjAddID],[incsTPAClaimNo],[incnRecUserID],[incdDtCreated],[incnModifyUserID],[incdDtModified],[incnLevelNo],
--	[incnUnInsPolicyLimitAcc],[incnUnderPolicyLimitAcc],[incb100Per],[incnMVLeased],[incnPriority],[incbDelete],[incnauthtodefcoun],[incnauthtodefcounDt],[incbPrimary],[saga]
--)
--SELECT DISTINCT 
--	MAP.caseID					    as [incnCaseID],
--	MAP.incnInsContactID			as [incnInsContactID],
--	MAP.incnInsAddressID			as [incnInsAddressID],
--	null							as [incbCarrierHasLienYN],
--	(select intnInsuranceTypeID from [sma_MST_InsuranceType] where intsDscrptn = case when isnull(INS.policy_type,'')<>'' then INS.policy_type else 'Unspecified' end ) as [incnInsType], 
--	MAP.incnAdjContactId			as [incnAdjContactId],
--	MAP.incnAdjAddressID			as [incnAdjAddressID],
--	INS.policy					    as [incsPolicyNo],
--	INS.claim						as [incsClaimNo],
--	null							as [incnStackedTimes],
--    isnull('accept : ' + nullif(convert(varchar,INS.accept),'') + CHAR(13),'') +
--    isnull('actual : ' + nullif(convert(varchar,INS.actual),'') + CHAR(13),'') +
--    isnull('agent : ' + nullif(convert(varchar,INS.agent),'') + CHAR(13),'') +
--    isnull('date_settled : ' + nullif(convert(varchar,INS.date_settled),'') + CHAR(13),'') +
--    isnull('how_settled : ' + nullif(convert(varchar,INS.how_settled),'') + CHAR(13),'') +
--    isnull('maximum_amount : ' + nullif(convert(varchar,INS.maximum_amount),'') + CHAR(13),'') +
--    isnull('minimum_amount : ' + nullif(convert(varchar,INS.minimum_amount),'') + CHAR(13),'') +
--    isnull('policy : ' + nullif(convert(varchar,INS.policy),'') + CHAR(13),'') +
--    isnull('claim : ' + nullif(convert(varchar,INS.claim),'') + CHAR(13),'') +
--    isnull('insured : ' + nullif(convert(varchar,INS.insured),'') + CHAR(13),'') +
--    isnull('limits : ' + nullif(convert(varchar,INS.limits),'') + CHAR(13),'') +
--    isnull('comments : ' + nullif(convert(varchar,INS.comments),'') + CHAR(13),'') +
--	isnull('Value Date: ' + nullif(convert(varchar,Ud.Value_date,101),'') + CHAR(13),'') +
--	isnull('Requested Limits: ' + nullif(convert(varchar,Ud.Requested_Limits),'') + CHAR(13),'') +
--	isnull('Projected Settlement Date: ' + nullif(convert(varchar,Ud.Projected_Settlement_Date,101),'') + CHAR(13),'') +
--	isnull('Medpay: ' + nullif(convert(varchar,ud.Medpay),'') + CHAR(13),'') +
--	isnull('About Limits: ' + nullif(convert(varchar,Ud.About_Limits),'') + CHAR(13),'') +
--	isnull('ERISA Lien: ' + nullif(convert(varchar,Ud.ERISA_Lien),'') + CHAR(13),'') +
--	isnull('Subro Provider: ' + nullif(convert(varchar,Ud.Subro_Provider),'') + CHAR(13),'') +
--	isnull('Nurse Cas Manager: ' + nullif(convert(varchar,Ud.Nurse_Case_Manager),'') + CHAR(13),'') +
--	isnull('NCM: ' + nullif(convert(varchar,Ud.NCM),'') + CHAR(13),'') +
--	isnull('Credit Attorney: ' + nullif(convert(varchar,Ud.Credit_Date,101),'') + CHAR(13),'') +
--	isnull('Credit Date: ' + nullif(convert(varchar,Ud.NCM),'') + CHAR(13),'') +
--	isnull('Red Folder Research: ' + nullif(convert(varchar,Ud.Red_Folder_Research),'') + CHAR(13),'') +
--	isnull('Is_there_a_John_Doe: ' + nullif(convert(varchar,Ud.Is_there_a_John_Doe),'') + CHAR(13),'') +
--	''							    as [incsComments],
--    MAP.incnInsured					as [incnInsured],
--    INS.actual					    as [incnCovgAmt], 
--    null							as [incnDeductible],
--	lim.[high]						as [incnUnInsPolicyLimit],
--	lim.[low]						as [incnUnderPolicyLimit],
--    0							    as [incbPolicyTerm],
--    0							    as [incbTotCovg],
--    'D'							    as [incsPlaintiffOrDef],
--	MAP.PlaintiffDefendantID	    as [incnPlaintiffIDOrDefendantID],
--    null							as [incnTPAdminOrgID], 
--    null			    as [incnTPAdminAddID],
--    null			    as [incnTPAdjContactID],
--    null			    as [incnTPAdjAddID],
--    null			    as [incsTPAClaimNo],
--    368					as [incnRecUserID],
--    getdate()		    as [incdDtCreated],
--    null			    as [incnModifyUserID],
--    null			    as [incdDtModified],
--    null			    as [incnLevelNo],
--	null			    as [incnUnInsPolicyLimitAcc],
--    null			    as [incnUnderPolicyLimitAcc],
--    0					as [incb100Per],
--    null			    as [incnMVLeased],
--    null			    as [incnPriority],
--    0					as [incbDelete],
--    0					as [incnauthtodefcoun],
--    null			    as [incnauthtodefcounDt],
--    0					as [incbPrimary],
--	INS.insurance_id	as [saga]
--FROM [JohnSalazar_Needles].[dbo].[insurance_Indexed] INS
--LEFT JOIN [JohnSalazar_Needles].[dbo].[user_insurance_data] UD on INS.insurance_id=UD.insurance_id
--LEFT JOIN InsuranceLimMap LIM on LIM.case_num = ins.case_num and LIM.insurer_ID = ins.insurer_id
--JOIN [Insurance_Contacts_Helper] MAP on INS.insurance_id=MAP.insurance_id and MAP.pord='D'
go

---
alter table [sma_TRN_InsuranceCoverage] enable trigger all
go

---


---(Adjuster/Insurer association)---
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
	where ISNULL(ic.[incnAdjContactId], 0) <> 0
		and ISNULL(ic.[incnInsContactID], 0) <> 0


------------------------------
--INSURANCE ADJUSTERS
------------------------------
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
	where ca.InsuranceCoverageId is null