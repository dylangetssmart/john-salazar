/* ###################################################################################
description: Create Medical Providers and Medical Bills

- Create medical providers from litify_pm__Damage__c
- Create medical providers from litify_pm__Role__c
- Create medical bills from damages

*/

use ShinerSA
go

alter table [sma_TRN_Hospitals] disable trigger all
go


insert into [sma_TRN_Hospitals]
	(
		[hosnCaseID],
		[hosnContactID],
		[hosnContactCtg],
		[hosnAddressID],
		[hossMedProType],
		[hosdStartDt],
		[hosdEndDt],
		[hosnPlaintiffID],
		[hosnComments],
		[hosnHospitalChart],
		[hosnRecUserID],
		[hosdDtCreated],
		[hosnModifyUserID],
		[hosdDtModified],
		[saga_char],
		source_db,
		source_ref
	)
	select distinct
		casnCaseID			   as [hosncaseid],
		ioc.cid				   as [hosncontactid],
		ioc.ctg				   as [hosncontactctg],
		ioc.aid				   as [hosnaddressid],
		'M'					   as [hossmedprotype],			--M or P (P for Prior Medical Provider)
		null				   as [hosdstartdt],
		null				   as [hosdenddt],
		(
			select top 1
				plnnPlaintiffID
			from [sma_TRN_Plaintiff]
			where plnnCaseID = casnCaseID
				and plnbIsPrimary = 1
		)					   as hosnplaintiffid,
		''					   as [hosncomments],
		null				   as [hosnhospitalchart],
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga_char = i.CreatedById
		)					   as [hosnrecuserid],
		null				   as [hosddtcreated],
		null				   as [hosnmodifyuserid],
		null				   as [hosddtmodified],
		i.Id				   as [saga_char],
		'litify'			   as [source_db],
		'litify_pm__Intake__c' as [source_ref]
	--select * 
	from ShinerLitify..litify_pm__Intake__c i
	join sma_trn_Cases cas
		on cas.saga_char = i.Id
	join [IndvOrgContacts_Indexed] ioc
		on ioc.saga_char = i.lps_Initial_Treating_Doctor_Facility__c
	where
		ISNULL(lps_Initial_Treating_Doctor_Facility__c, '') <> ''


--from ShinerLitify..[litify_pm__Damage__c] d
--join ShinerSa..vw_litifyRoleMapID r
--	on d.litify_pm__Provider__c = r.Id
--left join IndvOrgContacts_Indexed ioci
--	on ioci.Name = 'Unidentified Medical Provider'
--join ShinerSA..[sma_TRN_Cases] cas
--	on cas.saga_char = d.litify_pm__Matter__c
--left join ShinerSA..[sma_TRN_Hospitals] h
--	on h.hosncaseid = cas.casnCaseID
--		and h.hosncontactctg = r.CTG
--		and h.hosncontactid = r.CID
--where
--	ISNULL(d.litify_pm__Type__c, '') in ('Medical Bill'
--	--select
--	--	code
--	--from #DamageTypes dt
--	)
--	and h.hosnHospitalID is null	--only add if it does not already exist
--and cas.casnCaseID = 2566
--and d.litify_pm__Matter__c = 'a0L8Z00000eDaxBUAS'
go

alter table [sma_TRN_Hospitals] enable trigger all
go
