use [JohnSalazar_SA]
go

-- data.tabid = name.tabid
select
	*
from johnsalazar_needles..user_tab3_data
--select
--	*
--from johnsalazar_needles..user_tab3_matter utm
--select
--	*
--from johnsalazar_needles..user_tab3_name utn
--select
--	*
--from NeedlesUserFields nuf

/* ---------------------------------------------------------------------------
Step 1: Create helper table to collect data required for inserts
--------------------------------------------------------------------------- */
--- [value_tab_Lien_Helper]
if exists (
		select
			*
		from sys.objects
		where name = 'user_tab_Lien_Helper'
			and TYPE = 'U'
	)
begin
	drop table user_tab_Lien_Helper
end

go

---
create table user_tab_Lien_Helper (
	TableIndex	   [INT] identity (1, 1) not null,
	case_id		   INT,
	value_id	   INT,
	ProviderNameId INT,
	ProviderName   VARCHAR(200),
	ProviderCID	   INT,
	ProviderCTG	   INT,
	ProviderAID	   INT,
	casnCaseID	   INT,
	PlaintiffID	   INT,
	Paid		   VARCHAR(20),
	constraint IOC_Clustered_Index_user_tab_Lien_Helper primary key clustered (TableIndex)
) on [PRIMARY]
go

create nonclustered index IX_NonClustered_Index_user_tab_Lien_Helper_case_id on [user_tab_Lien_Helper] (case_id);
create nonclustered index IX_NonClustered_Index_user_tab_Lien_Helper_value_id on [user_tab_Lien_Helper] (value_id);
create nonclustered index IX_NonClustered_Index_user_tab_Lien_Helper_ProviderNameId on [user_tab_Lien_Helper] (ProviderNameId);
go

---
insert into user_tab_Lien_Helper
	(
		case_id,
		value_id,
		ProviderNameId,
		ProviderName,
		ProviderCID,
		ProviderCTG,
		ProviderAID,
		casnCaseID,
		PlaintiffID,
		Paid
	)
	select
		d.case_id	   as case_id,		-- needles case
		d.tab_id	   as tab_id,		-- needles records TAB item
		n.user_name	   as ProviderNameId,
		IOC.Name	   as ProviderName,
		IOC.CID		   as ProviderCID,
		IOC.CTG		   as ProviderCTG,
		IOC.AID		   as ProviderAID,
		CAS.casnCaseID as casnCaseID,
		null		   as PlaintiffID,
		null		   as Paid
	--select *
	from [JohnSalazar_Needles].[dbo].[user_tab3_data] D
	join [JohnSalazar_Needles].[dbo].[user_tab3_name] N
		on N.tab_id = D.tab_id
			and N.user_name <> 0
			and N.ref_num = (
				select top 1
					M.ref_num
				from [JohnSalazar_Needles].[dbo].[user_tab3_matter] M
				where M.field_title = 'Lienholder Name'
			)
	join [IndvOrgContacts_Indexed] IOC
		on IOC.SAGA = N.user_name
	join [sma_TRN_Cases] CAS
		on CAS.cassCaseNumber = CONVERT(VARCHAR, D.case_id)


--		FROM NeedlesGMA..user_tab3_data ud
--JOIN sma_trn_Cases cas on CAS.cassCaseNumber = UD.case_id
--LEFT JOIN (Select n.case_ID, ioc.unqcid FROM needlesgma..user_tab3_name n
--				JOIN needlesgma..user_tab3_matter m on n.ref_num = m.ref_num
--				JOIN IndvOrgContacts_Indexed ioc on ioc.saga = n.[user_name]
--				WHERE m.field_Title like 'Received from Defendant' and [user_name] <> 0 ) d ON d.case_id = ud.case_id

--from [JohnSalazar_Needles].[dbo].[value_Indexed] V
--inner join [sma_TRN_cases] CAS
--	on CAS.cassCaseNumber = CONVERT(VARCHAR, V.case_id)
--inner join [IndvOrgContacts_Indexed] IOC
--	on IOC.SAGA = V.provider
--		and ISNULL(V.provider, 0) <> 0
--where
--	code in (
--		select
--			code
--		from conversion.value_lienTracking
--	)
--	or V.value_id in (
--		select
--			value_id
--		from value_tab_Liencheckbox_Helper
--	)

go

dbcc dbreindex ('user_tab_Lien_Helper', ' ', 90) with no_infomsgs
go

/* ------------------------------------------------------------------------------
Create Lien Types
*/

insert into sma_MST_LienType
	(
		[lntsCode],
		[lntsDscrptn]
	)
	select distinct
		'CONVERSION',
		utd.Type_of_Lien
	from JohnSalazar_Needles..user_tab3_data utd
	where
		ISNULL(utd.Type_of_Lien, '') <> ''
	except
	select
		[lntsCode],
		[lntsDscrptn]
	from [sma_MST_LienType]
go

--select distinct
--	'CONVERSION',
--	VC.[description]
--from JohnSalazar_Needles.[dbo].[value] V
--left join JohnSalazar_Needles.[dbo].[value_code] VC
--	on VC.code = V.code
--where ISNULL(V.code, '') in (
--		select
--			code
--		from conversion.value_lienTracking
--	)
--	and v.code is not null
--)
--except
--select
--	[lntsCode],
--	[lntsDscrptn]
--from [sma_MST_LienType]

/* ------------------------------------------------------------------------------
Insert Lienors

Value_Code						?
Lien_Notice_Received			First Notice Date
Lienholder_Name					Lienor
Lien_Amount						Unconfirmed Gross Amount
Type_of_Lien					Lienor Type
County							Comments
State							Comments
FUp_Notes						Comments
Copy_of_Lien_in_File			Comments
Lien_Filed_w_County				Comments
Date_Lien_Filed_w_County		Comments
*/

alter table [sma_TRN_Lienors] disable trigger all
go

insert into [sma_TRN_Lienors]
	(
		[lnrnCaseID],
		[lnrnLienorTypeID],
		[lnrnLienorContactCtgID],
		[lnrnLienorContactID],
		[lnrnLienorAddressID],
		[lnrnLienorRelaContactID],
		[lnrnPlaintiffID],
		[lnrnUnCnfrmdLienAmount],
		[lnrnCnfrmdLienAmount],
		[lnrnNegLienAmount],
		[lnrsComments],
		[lnrnRecUserID],
		[lnrdDtCreated],
		[lnrnFinal],
		[lnrdNoticeDate],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		MAP.casnCaseID							 as [lnrnCaseID],
		(
			select top 1
				lntnLienTypeID
			from [sma_MST_LienType]
			where lntsDscrptn = (
				utd.Type_of_Lien
				)
		)										 as [lnrnLienorTypeID],
		MAP.ProviderCTG							 as [lnrnLienorContactCtgID],
		MAP.ProviderCID							 as [lnrnLienorContactID],
		MAP.ProviderAID							 as [lnrnLienorAddressID],
		0										 as [lnrnLienorRelaContactID],
		(
			select
				plnnPlaintiffID
			from [sma_TRN_Plaintiff]
			where plnnCaseID = casnCaseID
				and plnbIsPrimary = 1
		)										 as [lnrnPlaintiffID],
		CAST(utd.Lien_Amount as NUMERIC(18, 2)) as [lnrnUnCnfrmdLienAmount],
		0										 as [lnrnCnfrmdLienAmount],
		0										 as [lnrnNegLienAmount],
		ISNULL('County: ' + ISNULL(utd.County, '') + CHAR(13), '') +
		ISNULL('State: ' + ISNULL(utd.State, '') + CHAR(13), '') +
		ISNULL('FUp Notes: ' + ISNULL(utd.FUp_Notes, '') + CHAR(13), '') +
		ISNULL('Copy of Lien in File: ' + ISNULL(utd.Copy_of_Lien_in_File, '') + CHAR(13), '') +
		ISNULL('Lien Filed w County: ' + ISNULL(utd.Lien_Filed_w_County, '') + CHAR(13), '') +
		ISNULL('Date Lien Filed w County: ' + ISNULL(CONVERT(VARCHAR, utd.Date_Lien_Filed_w_County), '') + CHAR(13), '') +
		ISNULL('Value Code: ' + ISNULL(utd.Value_Code, '') + CHAR(13), '') +
		''										 as [lnrsComments],
		368										 as [lnrnRecUserID],
		GETDATE()								 as [lnrdDtCreated],
		0										 as [lnrnFinal],
		utd.Lien_Notice_Received				 as [lnrdNoticeDate],
		null									 as [saga],
		null									 as [source_id],
		'needles'								 as [source_db],
		'user_tab3_data'						 as [source_ref]
	--select *
	from [JohnSalazar_Needles].[dbo].user_tab3_data utd
	--from [JohnSalazar_Needles].[dbo].[value_Indexed] V
	inner join [user_tab_Lien_Helper] MAP
		on MAP.case_id = utd.case_id
			and MAP.value_id = utd.tab_id

alter table [sma_TRN_Lienors] enable trigger all
go

/* ------------------------------------------------------------------------------
Lien Details
*/

alter table [sma_TRN_LienDetails] disable trigger all
go

insert into [sma_TRN_LienDetails]
	(
		lndnLienorID,
		lndnLienTypeID,
		lndnCnfrmdLienAmount,
		lndsRefTable,
		lndnRecUserID,
		lnddDtCreated
	)
	select
		lnrnLienorID		 as lndnLienorID, --> same as lndnRecordID
		lnrnLienorTypeID	 as lndnLienTypeID,
		lnrnCnfrmdLienAmount as lndnCnfrmdLienAmount,
		'sma_TRN_Lienors'	 as lndsRefTable,
		368					 as lndnRecUserID,
		GETDATE()			 as lnddDtCreated
	from [sma_TRN_Lienors]

alter table [sma_TRN_LienDetails] enable trigger all
go
