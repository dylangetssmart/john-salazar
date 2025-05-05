select
	*
from ShinerLitify..litify_pm__Matter__c lpmc
where
	name = 'MAT-23042428099'
-- a0L8Z00000gCncMUAS

-- find examples



select
	cas.saga_char   as matter_id,
	cas.casnCaseID,
	dam.Name,
	hosp.hosnHospitalID as HospitalId,
	spdam.spdnSpDamageID as SpDamageId,
	dam.Provider_Adjustment_Amount__c,
	dam.Provider_Reduction_Amount__c,
	dam.Insurance_Paid__c
from ShinerLitify..litify_pm__Damage__c dam
	join sma_TRN_SpDamages spdam
		on spdam.saga_bill_id = dam.Id
	join sma_TRN_Hospitals hosp
		on spdam.spdnRecordID = hosp.hosnHospitalID
	join sma_TRN_Cases cas
		on cas.casnCaseID = hosp.hosnCaseID
	where
		dam.litify_pm__Matter__c = 'a0L8Z00000gCncMUAS'


select --top 5
	i.id   as intake_id,
	m.id   as matter_id,
	cas.casnCaseID,
	m.Name as case_number,
	i.litify_pm__Source__c,
	ioci.CID,
	ioci.ctg,
	i.litify_pm__Source_Type__c,
	i.lps_Source_Details__c
from ShinerLitify..litify_pm__Intake__c i
join ShinerLitify..litify_pm__Matter__c m
	on i.litify_pm__Matter__c = m.Id
join sma_TRN_Cases cas
	on cas.saga_char = m.Id
join IndvOrgContacts_Indexed ioci
	on ioci.saga_char = i.litify_pm__Source__c
where
	ISNULL(i.litify_pm__Source__c, '') <> ''
--intake_id				matter_id			casnCaseID	case_number			litify_pm__Source__c	CID		ctg		litify_pm__Source_Type__c	lps_Source_Details__c
--a0C8Z00000jvBiwUAE	a0L8Z00000eDaW6UAK	122			MAT-23010524977		a0YNt00000EZtsnMAD		7057	2		Advertisement				NULL
--a0C8Z00000iXIYKUA4	a0L8Z00000ek931UAA	449			MAT-23040327994		a0Y8Z00000Xcv9IUAR		7076	2		Internet					Google
--a0C8Z00000iXLXvUAO	a0L8Z00000elAPmUAM	456			MAT-23041028007		a0Y8Z00000XmSy3UAF		7063	2		Other						NULL
--a0C8Z00000iXSCKUA4	a0L8Z00000elVvHUAU	461			MAT-23041328014		a0Y8Z00000XGFSXUA5		7069	2		Non-Attorney Referral		NULL
--a0C8Z00000iXRzoUAG	a0L8Z00000elVXeUAM	462			MAT-23041328013		a0Y8Z00000ULOmvUAH		7065	2		Non-Attorney Referral		NULL

-- check the contacts
SELECT *
FROM IndvOrgContacts_Indexed ioci
where ioci.saga_char in (
'a0Y8Z00000ScTbNUAV',
'a0Y8Z00000ULOmvUAH',
'a0Y8Z00000WxRnQUAV',
'a0Y8Z00000Vf93JUAR',
'a0Y8Z00000TqkaVUAR'
)
--TableIndex	CID		CTG		AID		UNQCID	Name			saga_char			source_db	source_ref
--14436			7120	2		50987	27120	Webpage			a0Y8Z00000ScTbNUAV	litify		litify_pm__Source__c
--14707			7115	2		50982	27115	Television Ad	a0Y8Z00000TqkaVUAR	litify		litify_pm__Source__c
--14694			7065	2		50932	27065	Doctor			a0Y8Z00000ULOmvUAH	litify		litify_pm__Source__c
--14423			7068	2		50935	27068	Fedlyne			a0Y8Z00000Vf93JUAR	litify		litify_pm__Source__c
--12992			7109	2		50976	27109	Ronald Brodkin	a0Y8Z00000WxRnQUAV	litify		litify_pm__Source__c


select
	*
from sma_TRN_Hospitals sth
where
	sth.hosnCaseID = 608
	and sth.hosnHospitalID = 3566

select
	*
from sma_TRN_SpDamages stsd
where
	stsd.spdnSpDamageID = 3674

select
	*
from sma_TRN_SpecialDamageAmountPaid
SELECT * FROM sma_MST_AllContactInfo smaci where smaci.UniqueContactId = 27161 or smaci.UniqueContactId = 2186

-- dmg_amt_paid > damages > hospitals

select
	*
from sma_MST_CollateralType

SELECT * FROM sma_MST_OrgContacts smoc where smoc.consName like '%Litify%'

/* ---------------------------------------------------------------------------------------------------------------
[sma_TRN_SpecialDamageAmountPaid] Schema
*/

-- saga_char
if not exists (
		select
			*
		from sys.COLUMNS
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_TRN_SpecialDamageAmountPaid')
	)
begin
	alter table [sma_TRN_SpecialDamageAmountPaid]
	add [saga_char] [VARCHAR](100) null;
end


-- source_db
if not exists (
		select
			*
		from sys.COLUMNS
		where Name = N'source_db'
			and object_id = OBJECT_ID(N'sma_TRN_SpecialDamageAmountPaid')
	)
begin
	alter table [sma_TRN_SpecialDamageAmountPaid]
	add [source_db] VARCHAR(MAX) null;
end

go

-- source_ref
if not exists (
		select
			*
		from sys.COLUMNS
		where Name = N'source_ref'
			and object_id = OBJECT_ID(N'sma_TRN_SpecialDamageAmountPaid')
	)
begin
	alter table [sma_TRN_SpecialDamageAmountPaid]
	add [source_ref] VARCHAR(MAX) null;
end

go


/*  -------------------------------------------------------------------------
3rd Party Payments
	- Collateral = "Litify 3rd Party Payments"
	- Amount = The amount in the Litify Field for 3rd Party Payments > [Insurance_Paid__c]
	- Paid/Adjusted by = "Litify 3rd Party Payment"
*/ -------------------------------------------------------------------------

-- 3,492
select
	cas.saga_char   as matter_id,
	cas.casnCaseID,
	hosp.hosnHospitalID as HospitalId,
	spdam.spdnSpDamageID as SpDamageId,
	dam.Provider_Adjustment_Amount__c,
	dam.Provider_Reduction_Amount__c,
	dam.Insurance_Paid__c
from ShinerLitify..litify_pm__Damage__c dam
	join sma_TRN_SpDamages spdam
		on spdam.saga_bill_id = dam.Id
	join sma_TRN_Hospitals hosp
		on spdam.spdnRecordID = hosp.hosnHospitalID
	join sma_TRN_Cases cas
		on cas.casnCaseID = hosp.hosnCaseID
	where
		ISNULL(dam.Insurance_Paid__c,'') <> ''
		and dam.Insurance_Paid__c <> '0'


-- Add 'Litify 3rd Party Payment' as a case contact	to applicable cases
insert into [dbo].[sma_MST_OtherCasesContact]
	(
		[OtherCasesID],
		[OtherCasesContactID],
		[OtherCasesContactCtgID],
		[OtherCaseContactAddressID],
		[OtherCasesContactRole],
		[OtherCasesCreatedUserID],
		[OtherCasesContactCreatedDt],
		[OtherCasesModifyUserID],
		[OtherCasesContactModifieddt]
	)
	select distinct
		cas.casnCaseID							 as OtherCasesID,
		aci.ContactId							 as OtherCasesContactID,
		aci.ContactCtg							 as OtherCasesContactCtgID,
		aci.AddressId							 as OtherCaseContactAddressID,
		'Medical Provider bill paid/adjusted by' as OtherCasesContactRole,
		368										 as OtherCasesCreatedUserID,
		GETDATE()								 as OtherCasesContactCreatedDt,
		null									 as OtherCasesModifyUserID,
		null									 as OtherCasesContactModifieddt
	from ShinerLitify..litify_pm__Damage__c dam
	join sma_TRN_SpDamages spdam
		on spdam.saga_bill_id = dam.Id
	join sma_TRN_Hospitals hosp
		on spdam.spdnRecordID = hosp.hosnHospitalID
	join sma_TRN_Cases cas
		on cas.casnCaseID = hosp.hosnCaseID
	join sma_MST_AllContactInfo aci
		on aci.Name = 'Litify 3rd Party Payment'
	where
		ISNULL(dam.Insurance_Paid__c, '') <> ''
		and dam.Insurance_Paid__c <> '0'
go

-- Add payments
insert into [dbo].[sma_TRN_SpecialDamageAmountPaid]
	(
		[AmountPaidDamageReferenceID],
		[AmountPaidCollateralType],
		[AmountPaidPaidByID],
		[AmountPaidTotal],
		[AmountPaidClaimSubmittedDt],
		[AmountPaidDate],
		[AmountPaidRecUserID],
		[AmountPaidDtCreated],
		[AmountPaidModifyUserID],
		[AmountPaidDtModified],
		[AmountPaidLevelNo],
		[AmountPaidAdjustment],
		[AmountPaidComments],
		[saga_char],
		[source_db],
		[source_ref]
	)
	select
		spdam.spdnSpDamageID									 as AmountPaidDamageReferenceID,
		(
			select
				cltnCollateralTypeID
			from sma_MST_CollateralType
			where cltsDscrptn = 'Litify 3rd Party Payments'
		)														 as AmountPaidCollateralType,
		aci.UniqueContactId										 as AmountPaidPaidByID,		-- Paid/Adjusted By
		dam.Insurance_Paid__c									 as AmountPaidTotal,
		null													 as AmountPaidClaimSubmittedDt,
		null													 as AmountPaidDate,
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga_char = dam.CreatedById
		)														 as AmountPaidRecUserID,
		case
			when dam.CreatedDate between '1900-01-01' and '2079-06-06'
				then dam.CreatedDate
			else GETDATE()
		end														 as AmountPaidDtCreated,
		null													 as AmountPaidModifyUserID,
		null													 as AmountPaidDtModified,
		1														 as AmountPaidLevelNo,
		null													 as AmountPaidAdjustment,
		--,isnull('Notes: ' + nullif(convert(varchar(max),mh.[Notes]),'') + char(13),'') +
		''														 as [AmountPaidComments],
		dam.id													 as [saga_char],
		'litify'												 as [source_db],
		'post live - [litify_pm__Damage__c].[Insurance_Paid__c]' as [source_ref]
	from ShinerLitify..litify_pm__Damage__c dam
	join sma_TRN_SpDamages spdam
		on spdam.saga_bill_id = dam.Id
	join sma_TRN_Hospitals hosp
		on spdam.spdnRecordID = hosp.hosnHospitalID
	join sma_TRN_Cases cas
		on cas.casnCaseID = hosp.hosnCaseID
	join sma_MST_AllContactInfo aci
		on aci.Name = 'Litify 3rd Party Payment'
	where
		ISNULL(dam.Insurance_Paid__c, '') <> ''
		and dam.Insurance_Paid__c <> '0'
		--and dam.litify_pm__Matter__c = 'a0L8Z00000gCncMUAS'


/*  -------------------------------------------------------------------------
Provider Adjustments
	- Collateral = "Litify Provider Adjustment"
	- Amount = The amount in the Litify Field for 3rd Party Payments > [Provider_Adjustment_Amount__c]
	- Paid/Adjusted by = Litify Provider Adjustment
*/ -------------------------------------------------------------------------

-- 2,493
select
	cas.saga_char   as matter_id,
	cas.casnCaseID,
	hosp.hosnHospitalID as HospitalId,
	spdam.spdnSpDamageID as SpDamageId,
	dam.Provider_Adjustment_Amount__c,
	dam.Provider_Reduction_Amount__c,
	dam.Insurance_Paid__c
from ShinerLitify..litify_pm__Damage__c dam
	join sma_TRN_SpDamages spdam
		on spdam.saga_bill_id = dam.Id
	join sma_TRN_Hospitals hosp
		on spdam.spdnRecordID = hosp.hosnHospitalID
	join sma_TRN_Cases cas
		on cas.casnCaseID = hosp.hosnCaseID
	where
		ISNULL(dam.Provider_Adjustment_Amount__c,'') <> ''
		and dam.Provider_Adjustment_Amount__c <> '0'

-- Add 'Litify Provider Adjustments' as a case contact to applicable cases
insert into [dbo].[sma_MST_OtherCasesContact]
	(
		[OtherCasesID],
		[OtherCasesContactID],
		[OtherCasesContactCtgID],
		[OtherCaseContactAddressID],
		[OtherCasesContactRole],
		[OtherCasesCreatedUserID],
		[OtherCasesContactCreatedDt],
		[OtherCasesModifyUserID],
		[OtherCasesContactModifieddt]
	)
	select distinct
		cas.casnCaseID							 as OtherCasesID,
		aci.ContactId							 as OtherCasesContactID,
		aci.ContactCtg							 as OtherCasesContactCtgID,
		aci.AddressId							 as OtherCaseContactAddressID,
		'Medical Provider bill paid/adjusted by' as OtherCasesContactRole,
		368										 as OtherCasesCreatedUserID,
		GETDATE()								 as OtherCasesContactCreatedDt,
		null									 as OtherCasesModifyUserID,
		null									 as OtherCasesContactModifieddt
	from ShinerLitify..litify_pm__Damage__c dam
	join sma_TRN_SpDamages spdam
		on spdam.saga_bill_id = dam.Id
	join sma_TRN_Hospitals hosp
		on spdam.spdnRecordID = hosp.hosnHospitalID
	join sma_TRN_Cases cas
		on cas.casnCaseID = hosp.hosnCaseID
	join sma_MST_AllContactInfo aci
		on aci.Name = 'Litify Provider Adjustment'
	where
		ISNULL(dam.Provider_Adjustment_Amount__c, '') <> ''
		and dam.Provider_Adjustment_Amount__c <> '0'
go

insert into [dbo].[sma_TRN_SpecialDamageAmountPaid]
	(
		[AmountPaidDamageReferenceID],
		[AmountPaidCollateralType],
		[AmountPaidPaidByID],
		[AmountPaidTotal],
		[AmountPaidClaimSubmittedDt],
		[AmountPaidDate],
		[AmountPaidRecUserID],
		[AmountPaidDtCreated],
		[AmountPaidModifyUserID],
		[AmountPaidDtModified],
		[AmountPaidLevelNo],
		[AmountPaidAdjustment],
		[AmountPaidComments],
		[IsAdjustment],
		[saga_char],
		[source_db],
		[source_ref]
	)
	select
		spdam.spdnSpDamageID												 as AmountPaidDamageReferenceID,
		(
			select
				cltnCollateralTypeID
			from sma_MST_CollateralType
			where cltsDscrptn = 'Litify Provider Adjustments'
		)																	 as AmountPaidCollateralType,
		aci.UniqueContactId													 as AmountPaidPaidByID,		-- Paid/Adjusted By
		dam.Provider_Adjustment_Amount__c									 as AmountPaidTotal,
		null																 as AmountPaidClaimSubmittedDt,
		null																 as AmountPaidDate,
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga_char = dam.CreatedById
		)																	 as AmountPaidRecUserID,
		case
			when dam.CreatedDate between '1900-01-01' and '2079-06-06'
				then dam.CreatedDate
			else GETDATE()
		end																	 as AmountPaidDtCreated,
		null																 as AmountPaidModifyUserID,
		null																 as AmountPaidDtModified,
		1																	 as AmountPaidLevelNo,
		null																 as AmountPaidAdjustment,
		--,isnull('Notes: ' + nullif(convert(varchar(max),mh.[Notes]),'') + char(13),'') +
		''																	 as [AmountPaidComments],
		1																	 as [IsAdjustment],
		dam.id																 as [saga_char],
		'litify'															 as [source_db],
		'post live - [litify_pm__Damage__c].[Provider_Adjustment_Amount__c]' as [source_ref]
	from ShinerLitify..litify_pm__Damage__c dam
	join sma_TRN_SpDamages spdam
		on spdam.saga_bill_id = dam.Id
	join sma_TRN_Hospitals hosp
		on spdam.spdnRecordID = hosp.hosnHospitalID
	join sma_TRN_Cases cas
		on cas.casnCaseID = hosp.hosnCaseID
	join sma_MST_AllContactInfo aci
		on aci.Name = 'Litify Provider Adjustment'
	where
		ISNULL(dam.Provider_Adjustment_Amount__c, '') <> ''
		and dam.Provider_Adjustment_Amount__c <> '0'
		--and dam.litify_pm__Matter__c = 'a0L8Z00000gCncMUAS'

/*  -------------------------------------------------------------------------
Provider Reductions
	- Collateral = "Litify Provider Reductions"
	- Amount = The amount in the Litify Field for Provider Adjustment > [Provider_Reduction_Amount__c]
	- Paid/Adjusted by = Litify Provider Reductions
*/ -------------------------------------------------------------------------

-- 1,305
select
	cas.saga_char   as matter_id,
	cas.casnCaseID,
	hosp.hosnHospitalID as HospitalId,
	spdam.spdnSpDamageID as SpDamageId,
	dam.Provider_Adjustment_Amount__c,
	dam.Provider_Reduction_Amount__c,
	dam.Insurance_Paid__c
from ShinerLitify..litify_pm__Damage__c dam
	join sma_TRN_SpDamages spdam
		on spdam.saga_bill_id = dam.Id
	join sma_TRN_Hospitals hosp
		on spdam.spdnRecordID = hosp.hosnHospitalID
	join sma_TRN_Cases cas
		on cas.casnCaseID = hosp.hosnCaseID
	where
		ISNULL(dam.Provider_Reduction_Amount__c,'') <> ''
		and dam.Provider_Reduction_Amount__c <> '0'

-- Add 'Litify Provider Reductions' as a case contact to applicable cases
insert into [dbo].[sma_MST_OtherCasesContact]
	(
		[OtherCasesID],
		[OtherCasesContactID],
		[OtherCasesContactCtgID],
		[OtherCaseContactAddressID],
		[OtherCasesContactRole],
		[OtherCasesCreatedUserID],
		[OtherCasesContactCreatedDt],
		[OtherCasesModifyUserID],
		[OtherCasesContactModifieddt]
	)
	select distinct
		cas.casnCaseID							 as OtherCasesID,
		aci.ContactId							 as OtherCasesContactID,
		aci.ContactCtg							 as OtherCasesContactCtgID,
		aci.AddressId							 as OtherCaseContactAddressID,
		'Medical Provider bill paid/adjusted by' as OtherCasesContactRole,
		368										 as OtherCasesCreatedUserID,
		GETDATE()								 as OtherCasesContactCreatedDt,
		null									 as OtherCasesModifyUserID,
		null									 as OtherCasesContactModifieddt
	from ShinerLitify..litify_pm__Damage__c dam
	join sma_TRN_SpDamages spdam
		on spdam.saga_bill_id = dam.Id
	join sma_TRN_Hospitals hosp
		on spdam.spdnRecordID = hosp.hosnHospitalID
	join sma_TRN_Cases cas
		on cas.casnCaseID = hosp.hosnCaseID
	join sma_MST_AllContactInfo aci
		on aci.Name = 'Litify Provider Reductions'
	where
		ISNULL(dam.Provider_Reduction_Amount__c, '') <> ''
		and dam.Provider_Reduction_Amount__c <> '0'
go

insert into [dbo].[sma_TRN_SpecialDamageAmountPaid]
	(
		[AmountPaidDamageReferenceID],
		[AmountPaidCollateralType],
		[AmountPaidPaidByID],
		[AmountPaidTotal],
		[AmountPaidClaimSubmittedDt],
		[AmountPaidDate],
		[AmountPaidRecUserID],
		[AmountPaidDtCreated],
		[AmountPaidModifyUserID],
		[AmountPaidDtModified],
		[AmountPaidLevelNo],
		[AmountPaidAdjustment],
		[AmountPaidComments],
		[IsAdjustment],
		[saga_char],
		[source_db],
		[source_ref]
	)
	select
		spdam.spdnSpDamageID												as AmountPaidDamageReferenceID,
		(
			select
				cltnCollateralTypeID
			from sma_MST_CollateralType
			where cltsDscrptn = 'Litify Provider Reductions'
		)																	as AmountPaidCollateralType,
		aci.UniqueContactId													as AmountPaidPaidByID,		-- Paid/Adjusted By
		dam.Provider_Reduction_Amount__c									as AmountPaidTotal,
		null																as AmountPaidClaimSubmittedDt,
		null																as AmountPaidDate,
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga_char = dam.CreatedById
		)																	as AmountPaidRecUserID,
		case
			when dam.CreatedDate between '1900-01-01' and '2079-06-06'
				then dam.CreatedDate
			else GETDATE()
		end																	as AmountPaidDtCreated,
		null																as AmountPaidModifyUserID,
		null																as AmountPaidDtModified,
		1																	as AmountPaidLevelNo,
		null																as AmountPaidAdjustment,
		--,isnull('Notes: ' + nullif(convert(varchar(max),mh.[Notes]),'') + char(13),'') +
		''																	as [AmountPaidComments],
		1																	as [IsAdjustment],
		dam.id																as [saga_char],
		'litify'															as [source_db],
		'post live - [litify_pm__Damage__c].[Provider_Reduction_Amount__c]' as [source_ref]
	from ShinerLitify..litify_pm__Damage__c dam
	join sma_TRN_SpDamages spdam
		on spdam.saga_bill_id = dam.Id
	join sma_TRN_Hospitals hosp
		on spdam.spdnRecordID = hosp.hosnHospitalID
	join sma_TRN_Cases cas
		on cas.casnCaseID = hosp.hosnCaseID
	join sma_MST_AllContactInfo aci
		on aci.Name = 'Litify Provider Reductions'
	where
		ISNULL(dam.Provider_Reduction_Amount__c, '') <> ''
		and dam.Provider_Reduction_Amount__c <> '0'
		--and dam.litify_pm__Matter__c = 'a0L8Z00000gCncMUAS'