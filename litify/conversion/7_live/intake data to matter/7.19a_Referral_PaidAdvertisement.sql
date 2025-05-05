-- find examples
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

/* ---------------------------------------------------------------------------------------------------------------
Create Missing Referral Types 
*/

insert into [dbo].[sma_MST_ReferralType]
	(
		[rftsCode],
		[rftsDscrptn],
		[rftnRecUserID],
		[rftdDtCreated],
		[rftnModifyUserID],
		[rftdDtModified],
		[rftnLevelNo]
	)
	select distinct
		null								  as rftsCode, --varchar(20),>
		LEFT(i.litify_pm__Source_Type__c, 50) as rftsDscrptn, --varchar(50),>
		368									  as rftnRecUserID, --int,>
		GETDATE()							  as rftdDtCreated, --smalldatetime,>
		null								  as rftnModifyUserID, --int,>
		null								  as rftdDtModified, --smalldatetime,>
		null								  as rftnLevelNo -- int,>
	from ShinerLitify..litify_pm__Intake__c i
	where
		ISNULL(i.litify_pm__Source_Type__c, '') <> ''
		and not exists (
			select
				1
			from [dbo].[sma_MST_ReferralType] rt
			where rt.rftsDscrptn = LEFT(i.litify_pm__Source_Type__c, 50)
		)
go

/* ---------------------------------------------------------------------------------------------------------------
[sma_TRN_PdAdvt] Schema
*/

-- saga_char
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_TRN_PdAdvt')
	)
begin
	alter table [sma_TRN_PdAdvt] add [saga_char] VARCHAR(MAX) null;
end

go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and object_id = OBJECT_ID(N'sma_TRN_PdAdvt')
	)
begin
	alter table [sma_TRN_PdAdvt] add [source_db] VARCHAR(MAX) null;
end

go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and object_id = OBJECT_ID(N'sma_TRN_PdAdvt')
	)
begin
	alter table [sma_TRN_PdAdvt] add [source_ref] VARCHAR(MAX) null;
end

go

/* ---------------------------------------------------------------------------------------------------------------
ADVERTISEMENT SOURCES
*/

-- [litify_pm__Matter__c].[litify_pm__Source__c] -> [sma_TRN_PdAdvt]
insert into sma_TRN_PdAdvt
	(
		advnCaseID,
		advnSrcContactCtg,
		advnSrcContactID,
		advnSrcAddressID,
		advnSubTypeID,
		advnPlaintiffID,
		advdDateTime,
		advdRetainedDt,
		advnFeeStruID,
		advsComments,
		advnRecUserID,
		advdDtCreated,
		advnModifyUserID,
		advdDtModified,
		advnRecordSource,
		[saga_char],
		[source_db],
		[source_ref]

	)
	select
		cas.casnCaseID			as advnCaseID,
		ioc.CTG					as advnSrcContactCtg,
		ioc.CID					as advnSrcContactID,
		ioc.AID					as advnSrcAddressID,
		(
			select
				rftnRefferalTypeID
			from sma_MST_ReferralType
			where rftsDscrptn = i.litify_pm__Source_Type__c
		)						as advnSubTypeID,
		-1						as advnPlaintiffID,
		null					as advdDateTime,
		null					as advdRetainedDt,
		null					as advnFeeStruID,
		i.lps_Source_Details__c as advsComments,
		368						as advnRecUserID,
		GETDATE()				as advdDtCreated,
		null					as advnModifyUserID,
		null					as advdDtModified,
		0						as advnRecordSource,
		i.Id					as [saga_char],
		'litify'				as [source_db],
		'post live - litify_pm__Intake__c'  as [source_ref]
	--select cas.casnCaseID, i.litify_pm__Source__c, ioc.Name
	from ShinerLitify..litify_pm__Intake__c i
	join ShinerLitify..litify_pm__Matter__c m
		on m.id = i.litify_pm__Matter__c
	join sma_trn_Cases cas
		on cas.saga_char = m.Id
	--where m.Id = 'a0L8Z00000fKMa2UAG'
	join ShinerLitify..[litify_pm__Source__c] s
		on i.litify_pm__Source__c = s.Id
	join IndvOrgContacts_Indexed ioc
		on ioc.saga_char = s.Id
	where
		ISNULL(i.litify_pm__Source__c, '') <> ''
		--and m.Id = 'a0L8Z00000fKMzWUAW'
		and not exists (
			select
				1
			from sma_TRN_PdAdvt p
			where p.advnSrcContactCtg = ioc.CTG
				and p.advnSrcContactID = ioc.CID
				and p.advnCaseID = cas.casnCaseID
		)