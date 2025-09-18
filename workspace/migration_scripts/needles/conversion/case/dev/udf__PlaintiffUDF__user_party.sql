/*
for each field in [user_party_matter] with [party_role] = 'Plaintiff':
1. create UDF definition 
2. populate UDF values from [user_party_data]


dependencies: ['[NeedlesUserFields]', ['PartyRoles'], ['CaseTypeMixture']

D:\john-salazar\needles\conversion\utility\create__NeedlesUserFields.sql
D:\john-salazar\needles\conversion\utility\create__PartyRoles.sql

*/

use JohnSalazar_SA
go



SELECT * FROM sma_MST_UDFDefinition where UdfShortName like '%user_party_data%'
SELECT * FROM sma_TRN_UDFValues stu

SELECT * FROM plaintiffUDF_Helper uh 
select top 1
upd.case_id, upd.party_id, upd.Employer_Name
FROM JohnSalazar_Needles..user_party_data upd
join JohnSalazar_Needles..user_party_matter upm
on upm.
where isnull(Employer_Name,'')<>''


select
	*
from JohnSalazar_Needles..user_party_data upd


/* 
find each applicable field
*/
select distinct
	upm.field_title,
	upm.field_type,
	ref_num
from JohnSalazar_Needles..user_party_matter upm
where
	upm.party_role = 'Plaintiff'
	and upm.field_type <> 'label'
order by upm.field_title


--SELECT *
--FROM JohnSalazar_Needles..user_party_data upd
--join JohnSalazar_Needles..user_party_matter upm
--on upm.ref_num = upd.


--SELECT top 1
--  upm.mattercode,
--  upm.ref_num,
--  upm.field_title,
--  upm.field_type,
--  upn.party_id,
--  upn.ref_num,
--  upn.user_name,
--  n.names_id,
--  n.first_name,
--  n.last_long_name
--FROM [JohnSalazar_Needles]..user_party_matter upm
--join [JohnSalazar_Needles]..user_party_name upn
--  on upm.ref_num = upn.ref_num
--join [JohnSalazar_Needles]..names n
--  on n.names_id = upn.user_name
--where upm.field_title = 'send mail to'

/*
---(Supporting Statements)---
select 'when LIST.column_name=' + ''''+ F.column_name +'''' + ' then convert(varchar(MAX),UD.' + F.column_name + ')',
'isnull( convert(varchar,'+F.column_name +'),'''')<>'''' or '
from [JohnSalazar_Needles].[dbo].[user_case_fields] F
where field_title in ( select distinct field_title from [JohnSalazar_Needles].[dbo].[user_party_matter] ) 
*/


--(0)---- build a supporting table with anchors and values
if exists (
		select
			*
		from sys.objects
		where name = 'plaintiffUDF_Helper'
			and type = 'U'
	)
begin
	drop table plaintiffUDF_Helper
end

go

----(0)---- 
create table plaintiffUDF_Helper (
	tableIndex  INT identity (1, 1) not null,
	ref_num		INT,
	column_name VARCHAR(100),
	field_title VARCHAR(100),
	mattercode  VARCHAR(100),
	field_type  VARCHAR(25),
	udf_type	VARCHAR(30),
	field_len   VARCHAR(20)
	constraint IX_plaintiffUDF_Helper primary key clustered
	(
	tableIndex
	) with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on, fillfactor = 80) on [PRIMARY]
) on [PRIMARY]
go

create nonclustered index IX_NonClustered_Index_ref_num on plaintiffUDF_Helper (ref_num);
create nonclustered index IX_NonClustered_Index_column_name on plaintiffUDF_Helper (column_name);
create nonclustered index IX_NonClustered_Index_field_title on plaintiffUDF_Helper (field_title);
create nonclustered index IX_NonClustered_Index_mattercode on plaintiffUDF_Helper (mattercode);
go

--select * From UDF_Helper

----(0)---- 
insert into plaintiffUDF_Helper
	(
		ref_num,
		column_name,
		field_title,
		mattercode,
		field_type,
		udf_type,
		field_len
	)
	select
		ref_num,
		F.column_name,
		F.field_title,
		M.mattercode,
		F.field_Type,
		F.UDFType as udf_type,
		F.field_len
	from JohnSalazar_Needles.[dbo].[user_party_matter] M
	join NeedlesUserFields F
		on F.field_num = M.ref_num
	join [PartyRoles] R
		on R.[Needles Roles] = M.party_role
	where
		R.[SA Party] = 'Plaintiff'
go

----(0)---- 
dbcc dbreindex ('plaintiffUDF_Helper', ' ', 90) with no_infomsgs



/*
----------------------BUILD USER PARTY HELPER----------------------
if exists (select * from sys.objects where name='UserParty_Helper' and type='U')
begin
    drop table UserParty_Helper
end
GO

select p.tableindex, party_ID, case_ID, [role], [sa party],IOC.CID, IOC.CTG, IOC.AID, IOC.UNQCID, IOC.Name, IOC.SAGA 
INTO UserParty_Helper
From [JohnSalazar_Needles].[dbo].[party_Indexed] P
JOIN [SA].[dbo].[IndvOrgContacts_Indexed] IOC on IOC.SAGA = P.party_id
JOIN [SA].[dbo].[PartyRoles] R on R.[Needles Roles]=p.[role]
*/
--select * from JohnSalazar_Needles..user_case_fields

---(1/2)---
insert into [sma_MST_UDFDefinition]
	(
		[udfsUDFCtg],
		[udfnRelatedPK],
		[udfsUDFName],
		[udfsScreenName],
		[udfsType],
		[udfsLength],
		[udfbIsActive],
		[udfnLevelNo],
		[UdfShortName],
		[udfsNewValues],
		[udfnSortOrder]
	)
	select
		A.[udfsUDFCtg],
		A.[udfnRelatedPK],
		A.[udfsUDFName],
		A.[udfsScreenName],
		A.[udfsType],
		A.[udfsLength],
		A.[udfbIsActive],
		A.[udfnLevelNo],
		A.[udfshortName],
		a.[udfsNewValues],
		DENSE_RANK() over (order by A.[udfsUDFName]) as udfnSortOrder
	from (
		select distinct
			'C'									 as [udfsUDFCtg],
			--case
			--	when ucf.field_Type = 'name'
			--		then 'R'
			--	else 'C'
			--end									 as [udfsUDFCtg],
			CST.cstnCaseTypeID					 as [udfnRelatedPK],
			M.field_title						 as [udfsUDFName],
			r.[SA Party]						 as [udfsScreenName],
			ucf.UDFType							 as [udfsType],
			ucf.field_len						 as [udfsLength],
			--case
			--	when ucf.field_Type = 'name'
			--		then null
			--	else ucf.field_len
			--end									 as [udfsLength],
			1									 as [udfbIsActive],
			'user_party_Data.' + ucf.column_name as [udfshortName],
			ucf.dropdownValues					 as [udfsNewValues],
			M.ref_num							 as [udfnLevelNo]
		from [sma_MST_CaseType] CST
		join CaseTypeMixture mix
			on mix.[SmartAdvocate Case Type] = cst.cstsType
		join JohnSalazar_Needles.[dbo].[user_party_matter] M
			on M.mattercode = mix.matcode
		join [PartyRoles] R
			on R.[Needles Roles] = M.party_role
		join NeedlesUserFields ucf
			on m.ref_num = ucf.field_num
		left join (
			select distinct
				table_name,
				column_name
			from JohnSalazar_Needles.[dbo].[document_merge_params]
			where table_name = 'user_party_Data'
		) dmp
			on dmp.column_name = ucf.column_Name
		left join [sma_MST_UDFDefinition] udf
			on udf.udfnRelatedPK = cst.cstnCaseTypeID
			and udf.udfsScreenName = [SA Party]
			and udf.udfsUDFName = m.field_title
			and udfstype = ucf.UDFType
		where R.[SA Party] = 'Plaintiff'
			and CST.VenderCaseType = 'SalazarCaseType'
	--and udf.udfnUDFID is null
	) A

go

alter table sma_TRN_UDFValues disable trigger all
go

---(2/2)---
insert into [sma_TRN_UDFValues]
	(
		[udvnUDFID],
		[udvsScreenName],
		[udvsUDFCtg],
		[udvnRelatedID],
		[udvnSubRelatedID],
		[udvsUDFValue],
		[udvnRecUserID],
		[udvdDtCreated],
		[udvnModifyUserID],
		[udvdDtModified],
		[udvnLevelNo]
	)
	select distinct
		(
			select top 1
				udfnUDFID
			from [sma_MST_UDFDefinition]
			where udfnRelatedPK = casnOrgCaseTypeID
				and udfsUDFName = LIST.field_title
				and udfsScreenName = 'Plaintiff'
				and udfstype = UDFType
		)				  as [udvnUDFID],
		'Plaintiff'		  as [udvsScreenName],
		'C'				  as [udvsUDFCtg],
		CAS.casnCaseID	  as [udvnRelatedID],
		T.plnnPlaintiffID as [udvnSubRelatedID],
		/*
		if contact, contact unique cid
		*/
		
		100 as [udvsUDFValue],
		--case
		--	when LIST.column_name = 'Activity'
		--		then CONVERT(VARCHAR(MAX), UD.Activity)
		--	when LIST.column_name = 'Adjustor'
		--		then CONVERT(VARCHAR(MAX), UD.Adjustor)
		--	when LIST.column_name = 'Agent_for_Service'
		--		then CONVERT(VARCHAR(MAX), UD.Agent_for_Service)
		--	when LIST.column_name = 'AKA_Role'
		--		then CONVERT(VARCHAR(MAX), UD.AKA_Role)
		--	when LIST.column_name = 'Amt_of_Public_Assistance'
		--		then CONVERT(VARCHAR(MAX), UD.Amt_of_Public_Assistance)
		--	when LIST.column_name = 'Any_headbrain_injury'
		--		then CONVERT(VARCHAR(MAX), UD.Any_headbrain_injury)
		--	when LIST.column_name = 'AwwTtd'
		--		then CONVERT(VARCHAR(MAX), UD.AwwTtd)
		--	when LIST.column_name = 'Been_to_our_website'
		--		then CONVERT(VARCHAR(MAX), UD.Been_to_our_website)
		--	when LIST.column_name = 'Best_time_to_contact'
		--		then CONVERT(VARCHAR(MAX), UD.Best_time_to_contact)
		--	when LIST.column_name = 'Children'
		--		then CONVERT(VARCHAR(MAX), UD.Children)
		--	when LIST.column_name = 'CityStateZip'
		--		then CONVERT(VARCHAR(MAX), UD.CityStateZip)
		--	when LIST.column_name = 'Concierge_Form_Signed'
		--		then CONVERT(VARCHAR(MAX), UD.Concierge_Form_Signed)
		--	when LIST.column_name = 'Custom_Dictated'
		--		then CONVERT(VARCHAR(MAX), UD.Custom_Dictated)
		--	when LIST.column_name = 'Date_started'
		--		then CONVERT(VARCHAR(MAX), UD.Date_started)
		--	when LIST.column_name = 'Date_Thank_You_Sent'
		--		then CONVERT(VARCHAR(MAX), UD.Date_Thank_You_Sent)
		--	when LIST.column_name = 'Education'
		--		then CONVERT(VARCHAR(MAX), UD.Education)
		--	when LIST.column_name = 'Email_availability'
		--		then CONVERT(VARCHAR(MAX), UD.Email_availability)
		--	when LIST.column_name = 'Emerg_Contact_Phone_#'
		--		then CONVERT(VARCHAR(MAX), UD.Emerg_Contact_Phone_#)
		--	when LIST.column_name = 'Emergency_Contact'
		--		then CONVERT(VARCHAR(MAX), UD.Emergency_Contact)
		--	when LIST.column_name = 'Emergency_Contact_#'
		--		then CONVERT(VARCHAR(MAX), UD.Emergency_Contact_#)
		--	when LIST.column_name = 'Employed'
		--		then CONVERT(VARCHAR(MAX), UD.Employed)
		--	when LIST.column_name = 'Employer'
		--		then CONVERT(VARCHAR(MAX), UD.Employer)
		--	when LIST.column_name = 'Employer_Address'
		--		then CONVERT(VARCHAR(MAX), UD.Employer_Address)
		--	when LIST.column_name = 'Employer_Type'
		--		then CONVERT(VARCHAR(MAX), UD.Employer_Type)
		--	when LIST.column_name = 'Employment'
		--		then CONVERT(VARCHAR(MAX), UD.Employment)
		--	when LIST.column_name = 'ER_Contact_Name'
		--		then CONVERT(VARCHAR(MAX), UD.ER_Contact_Name)
		--	when LIST.column_name = 'ER_Contact_Phone_#'
		--		then CONVERT(VARCHAR(MAX), UD.ER_Contact_Phone_#)
		--	when LIST.column_name = 'Exertional_Requirement'
		--		then CONVERT(VARCHAR(MAX), UD.Exertional_Requirement)
		--	when LIST.column_name = 'Generic_Reject'
		--		then CONVERT(VARCHAR(MAX), UD.Generic_Reject)
		--	when LIST.column_name = 'Glasses'
		--		then CONVERT(VARCHAR(MAX), UD.Glasses)
		--	when LIST.column_name = 'Guardian_Name'
		--		then CONVERT(VARCHAR(MAX), UD.Guardian_Name)
		--	when LIST.column_name = 'Has_Atty'
		--		then CONVERT(VARCHAR(MAX), UD.Has_Atty)
		--	when LIST.column_name = 'Ime'
		--		then CONVERT(VARCHAR(MAX), UD.Ime)
		--	when LIST.column_name = 'Imp'
		--		then CONVERT(VARCHAR(MAX), UD.Imp)
		--	when LIST.column_name = 'Impairment'
		--		then CONVERT(VARCHAR(MAX), UD.Impairment)
		--	when LIST.column_name = 'Income_from_Investment'
		--		then CONVERT(VARCHAR(MAX), UD.Income_from_Investment)
		--	when LIST.column_name = 'Injuries'
		--		then CONVERT(VARCHAR(MAX), UD.Injuries)
		--	when LIST.column_name = 'InjuryNotes'
		--		then CONVERT(VARCHAR(MAX), UD.InjuryNotes)
		--	when LIST.column_name = 'Intake_By'
		--		then CONVERT(VARCHAR(MAX), UD.Intake_By)
		--	when LIST.column_name = 'Job_Description'
		--		then CONVERT(VARCHAR(MAX), UD.Job_Description)
		--	when LIST.column_name = 'Key_words_searched'
		--		then CONVERT(VARCHAR(MAX), UD.Key_words_searched)
		--	when LIST.column_name = 'License'
		--		then CONVERT(VARCHAR(MAX), UD.License)
		--	when LIST.column_name = 'License_Plate_Number'
		--		then CONVERT(VARCHAR(MAX), UD.License_Plate_Number)
		--	when LIST.column_name = 'License_Plate_State'
		--		then CONVERT(VARCHAR(MAX), UD.License_Plate_State)
		--	when LIST.column_name = 'License_State'
		--		then CONVERT(VARCHAR(MAX), UD.License_State)
		--	when LIST.column_name = 'Location_of_Vehicle'
		--		then CONVERT(VARCHAR(MAX), UD.Location_of_Vehicle)
		--	when LIST.column_name = 'Marital_Stat'
		--		then CONVERT(VARCHAR(MAX), UD.Marital_Stat)
		--	when LIST.column_name = 'Marital_Status'
		--		then CONVERT(VARCHAR(MAX), UD.Marital_Status)
		--	when LIST.column_name = 'Mileage'
		--		then CONVERT(VARCHAR(MAX), UD.Mileage)
		--	when LIST.column_name = 'New_AWW'
		--		then CONVERT(VARCHAR(MAX), UD.New_AWW)
		--	when LIST.column_name = 'New_employer'
		--		then CONVERT(VARCHAR(MAX), UD.New_employer)
		--	when LIST.column_name = 'Newaww'
		--		then CONVERT(VARCHAR(MAX), UD.Newaww)
		--	when LIST.column_name = 'Notes'
		--		then CONVERT(VARCHAR(MAX), UD.Notes)
		--	when LIST.column_name = 'Other_Household_Income'
		--		then CONVERT(VARCHAR(MAX), UD.Other_Household_Income)
		--	when LIST.column_name = 'Other_Income'
		--		then CONVERT(VARCHAR(MAX), UD.Other_Income)
		--	when LIST.column_name = 'Out_Of_Work'
		--		then CONVERT(VARCHAR(MAX), UD.Out_Of_Work)
		--	when LIST.column_name = 'Part_Of_Body'
		--		then CONVERT(VARCHAR(MAX), UD.Part_Of_Body)
		--	when LIST.column_name = 'Pension'
		--		then CONVERT(VARCHAR(MAX), UD.Pension)
		--	when LIST.column_name = 'Personal_Bio'
		--		then CONVERT(VARCHAR(MAX), UD.Personal_Bio)
		--	when LIST.column_name = 'Phone_Number'
		--		then CONVERT(VARCHAR(MAX), UD.Phone_Number)
		--	when LIST.column_name = 'Plantiff_Insurer'
		--		then CONVERT(VARCHAR(MAX), UD.Plantiff_Insurer)
		--	when LIST.column_name = 'PostInjury_Employer'
		--		then CONVERT(VARCHAR(MAX), UD.PostInjury_Employer)
		--	when LIST.column_name = 'Preferred_contact_method'
		--		then CONVERT(VARCHAR(MAX), UD.Preferred_contact_method)
		--	when LIST.column_name = 'Premature'
		--		then CONVERT(VARCHAR(MAX), UD.Premature)
		--	when LIST.column_name = 'Primary_Contact'
		--		then CONVERT(VARCHAR(MAX), UD.Primary_Contact)
		--	when LIST.column_name = 'Primary_Contact_Ph_#'
		--		then CONVERT(VARCHAR(MAX), UD.Primary_Contact_Ph_#)
		--	when LIST.column_name = 'Prior_Acc'
		--		then CONVERT(VARCHAR(MAX), UD.Prior_Acc)
		--	when LIST.column_name = 'Prior_Complaints'
		--		then CONVERT(VARCHAR(MAX), UD.Prior_Complaints)
		--	when LIST.column_name = 'Prior_Inj'
		--		then CONVERT(VARCHAR(MAX), UD.Prior_Inj)
		--	when LIST.column_name = 'Prior_Lawsuits'
		--		then CONVERT(VARCHAR(MAX), UD.Prior_Lawsuits)
		--	when LIST.column_name = 'Public_Assistance'
		--		then CONVERT(VARCHAR(MAX), UD.Public_Assistance)
		--	when LIST.column_name = 'Refer_out'
		--		then CONVERT(VARCHAR(MAX), UD.Refer_out)
		--	when LIST.column_name = 'Refer_to_Laura'
		--		then CONVERT(VARCHAR(MAX), UD.Refer_to_Laura)
		--	when LIST.column_name = 'Rel_To_Plntf'
		--		then CONVERT(VARCHAR(MAX), UD.Rel_To_Plntf)
		--	when LIST.column_name = 'Relationship'
		--		then CONVERT(VARCHAR(MAX), UD.relationship)
		--	when LIST.column_name = 'Relationship_to_Plntf'
		--		then CONVERT(VARCHAR(MAX), UD.Relationship_to_Plntf)
		--	when LIST.column_name = 'Relative'
		--		then CONVERT(VARCHAR(MAX), UD.[Relative])
		--	when LIST.column_name = 'Relative_Address'
		--		then CONVERT(VARCHAR(MAX), UD.Relative_Address)
		--	when LIST.column_name = 'Relative_City'
		--		then CONVERT(VARCHAR(MAX), UD.Relative_City)
		--	when LIST.column_name = 'Relative_Phone'
		--		then CONVERT(VARCHAR(MAX), UD.Relative_Phone)
		--	when LIST.column_name = 'Relative_State'
		--		then CONVERT(VARCHAR(MAX), UD.Relative_State)
		--	when LIST.column_name = 'Relative_Zip'
		--		then CONVERT(VARCHAR(MAX), UD.Relative_Zip)
		--	when LIST.column_name = 'Release_to_work'
		--		then CONVERT(VARCHAR(MAX), UD.Release_to_work)
		--	when LIST.column_name = 'RestricVoc'
		--		then CONVERT(VARCHAR(MAX), UD.RestricVoc)
		--	when LIST.column_name = 'Restrictions'
		--		then CONVERT(VARCHAR(MAX), UD.Restrictions)
		--	when LIST.column_name = 'Returntowork'
		--		then CONVERT(VARCHAR(MAX), UD.Returntowork)
		--	when LIST.column_name = 'Role_in_Accident'
		--		then CONVERT(VARCHAR(MAX), UD.Role_in_Accident)
		--	when LIST.column_name = 'RTW_old_employer'
		--		then CONVERT(VARCHAR(MAX), UD.RTW_old_employer)
		--	when LIST.column_name = 'Seen_Google_Reviews'
		--		then CONVERT(VARCHAR(MAX), UD.Seen_Google_Reviews)
		--	when LIST.column_name = 'Seen_our_commercials'
		--		then CONVERT(VARCHAR(MAX), UD.Seen_our_commercials)
		--	when LIST.column_name = 'Spouse'
		--		then CONVERT(VARCHAR(MAX), UD.Spouse)
		--	when LIST.column_name = 'Spouse_Name'
		--		then CONVERT(VARCHAR(MAX), UD.Spouse_Name)
		--	when LIST.column_name = 'Spouse_SS#'
		--		then CONVERT(VARCHAR(MAX), UD.Spouse_SS#)
		--	when LIST.column_name = 'Staff_Approving_Rides'
		--		then CONVERT(VARCHAR(MAX), UD.Staff_Approving_Rides)
		--	when LIST.column_name = 'State'
		--		then CONVERT(VARCHAR(MAX), UD.[State])
		--	when LIST.column_name = 'Surgery'
		--		then CONVERT(VARCHAR(MAX), UD.Surgery)
		--	when LIST.column_name = 'Thank_You_Letter'
		--		then CONVERT(VARCHAR(MAX), UD.Thank_You_Letter)
		--	when LIST.column_name = 'Time_Lost_From_Work'
		--		then CONVERT(VARCHAR(MAX), UD.Time_Lost_From_Work)
		--	when LIST.column_name = 'Title'
		--		then CONVERT(VARCHAR(MAX), UD.Title)
		--	when LIST.column_name = 'Transportation_Approved'
		--		then CONVERT(VARCHAR(MAX), UD.Transportation_Approved)
		--	when LIST.column_name = 'Treatingphy'
		--		then CONVERT(VARCHAR(MAX), UD.Treatingphy)
		--	when LIST.column_name = 'Type_of_Pension'
		--		then CONVERT(VARCHAR(MAX), UD.Type_of_Pension)
		--	when LIST.column_name = 'Type_of_Public_Assistance'
		--		then CONVERT(VARCHAR(MAX), UD.Type_of_Public_Assistance)
		--	when LIST.column_name = 'Unable_to_reach'
		--		then CONVERT(VARCHAR(MAX), UD.Unable_to_reach)
		--	when LIST.column_name = 'Veh_Owner'
		--		then CONVERT(VARCHAR(MAX), UD.Veh_Owner)
		--	when LIST.column_name = 'We_want_to_rep'
		--		then CONVERT(VARCHAR(MAX), UD.We_want_to_rep)
		--	when LIST.column_name = 'Wearing_Glas'
		--		then CONVERT(VARCHAR(MAX), UD.Wearing_Glas)
		--	when LIST.column_name = 'Wearing_Seatbelt'
		--		then CONVERT(VARCHAR(MAX), UD.Wearing_Seatbelt)
		--	when LIST.column_name = 'Welfare'
		--		then CONVERT(VARCHAR(MAX), UD.Welfare)
		--	when LIST.column_name = 'What_Capacity'
		--		then CONVERT(VARCHAR(MAX), UD.What_Capacity)
		--	when LIST.column_name = 'Where_Locatd'
		--		then CONVERT(VARCHAR(MAX), UD.Where_Locatd)
		--	when LIST.column_name = 'Where_Seated'
		--		then CONVERT(VARCHAR(MAX), UD.Where_Seated)
		--	when LIST.column_name = 'YearMakeModel'
		--		then CONVERT(VARCHAR(MAX), UD.YearMakeModel)
		--	when LIST.column_name = 'Years_Employed'
		--		then CONVERT(VARCHAR(MAX), UD.Years_Employed)
		--end				  as [udvsUDFValue],
		368				  as [udvnRecUserID],
		GETDATE()		  as [udvdDtCreated],
		null			  as [udvnModifyUserID],
		null			  as [udvdDtModified],
		null			  as [udvnLevelNo]
	--select * --cas.casncaseid, T.plnnPlaintiffID, cst.cstscode, p.role, casnOrgCaseTypeID, t.saga_party, p.tableindex, ud.*
	from [JohnSalazar_Needles].[dbo].[user_party_data] UD
	join [JohnSalazar_Needles].[dbo].[cases_Indexed] ci
		on ud.case_id = ci.casenum
	join [sma_TRN_cases] CAS
		on CAS.cassCaseNumber = CONVERT(VARCHAR, UD.case_id)
	join [sma_MST_CaseType] CST
		on CST.cstnCaseTypeID = CAS.casnOrgCaseTypeID
			and VenderCaseType = 'SalazarCaseType'
	join [JohnSalazar_Needles].[dbo].[party_Indexed] P
		on P.party_id = UD.party_id
			and P.case_id = UD.case_id
	join [IndvOrgContacts_Indexed] IOC
		on IOC.SAGA = UD.party_id
	join sma_TRN_Plaintiff T
		on P.TableIndex = T.[saga_party]
	join plaintiffUDF_Helper LIST
		on LIST.mattercode = ci.matcode
	join (
		select
			[Needles Roles]
		from [dbo].[PartyRoles]
		where [SA Party] = 'Plaintiff'
	) N
		on N.[Needles Roles] = P.[role]
	where
		(
			ISNULL(CONVERT(VARCHAR, Activity), '') <> '' or ISNULL(CONVERT(VARCHAR, Adjustor), '') <> '' or ISNULL(CONVERT(VARCHAR, Agent_for_Service), '') <> '' or ISNULL(CONVERT(VARCHAR, AKA_Role), '') <> '' or ISNULL(CONVERT(VARCHAR, Amt_of_Public_Assistance), '') <> '' or ISNULL(CONVERT(VARCHAR, Any_headbrain_injury), '') <> '' or ISNULL(CONVERT(VARCHAR, AwwTtd), '') <> '' or ISNULL(CONVERT(VARCHAR, Been_to_our_website), '') <> '' or ISNULL(CONVERT(VARCHAR, Best_time_to_contact), '') <> '' or ISNULL(CONVERT(VARCHAR, Children), '') <> '' or ISNULL(CONVERT(VARCHAR, CityStateZip), '') <> '' or ISNULL(CONVERT(VARCHAR, Concierge_Form_Signed), '') <> '' or ISNULL(CONVERT(VARCHAR, Custom_Dictated), '') <> '' or ISNULL(CONVERT(VARCHAR, Date_started), '') <> '' or ISNULL(CONVERT(VARCHAR, Date_Thank_You_Sent), '') <> '' or ISNULL(CONVERT(VARCHAR, Education), '') <> '' or ISNULL(CONVERT(VARCHAR, Email_availability), '') <> '' or ISNULL(CONVERT(VARCHAR, Emerg_Contact_Phone_#), '') <> '' or ISNULL(CONVERT(VARCHAR, Emergency_Contact), '') <> '' or ISNULL(CONVERT(VARCHAR, Emergency_Contact_#), '') <> '' or ISNULL(CONVERT(VARCHAR, Employed), '') <> '' or ISNULL(CONVERT(VARCHAR, Employer), '') <> '' or ISNULL(CONVERT(VARCHAR, Employer_Address), '') <> '' or ISNULL(CONVERT(VARCHAR, Employer_Type), '') <> '' or ISNULL(CONVERT(VARCHAR, Employment), '') <> '' or ISNULL(CONVERT(VARCHAR, ER_Contact_Name), '') <> '' or ISNULL(CONVERT(VARCHAR, ER_Contact_Phone_#), '') <> '' or ISNULL(CONVERT(VARCHAR, Exertional_Requirement), '') <> '' or ISNULL(CONVERT(VARCHAR, Generic_Reject), '') <> '' or ISNULL(CONVERT(VARCHAR, Glasses), '') <> '' or ISNULL(CONVERT(VARCHAR, Guardian_Name), '') <> '' or ISNULL(CONVERT(VARCHAR, Has_Atty), '') <> '' or ISNULL(CONVERT(VARCHAR, Ime), '') <> '' or ISNULL(CONVERT(VARCHAR, Imp), '') <> '' or ISNULL(CONVERT(VARCHAR, Impairment), '') <> '' or ISNULL(CONVERT(VARCHAR, Income_from_Investment), '') <> '' or ISNULL(CONVERT(VARCHAR, Injuries), '') <> '' or ISNULL(CONVERT(VARCHAR, InjuryNotes), '') <> '' or ISNULL(CONVERT(VARCHAR, Intake_By), '') <> '' or ISNULL(CONVERT(VARCHAR, Job_Description), '') <> '' or ISNULL(CONVERT(VARCHAR, Key_words_searched), '') <> '' or ISNULL(CONVERT(VARCHAR, License), '') <> '' or ISNULL(CONVERT(VARCHAR, License_Plate_Number), '') <> '' or ISNULL(CONVERT(VARCHAR, License_Plate_State), '') <> '' or ISNULL(CONVERT(VARCHAR, License_State), '') <> '' or ISNULL(CONVERT(VARCHAR, Location_of_Vehicle), '') <> '' or ISNULL(CONVERT(VARCHAR, Marital_Stat), '') <> '' or ISNULL(CONVERT(VARCHAR, Marital_Status), '') <> '' or ISNULL(CONVERT(VARCHAR, Mileage), '') <> '' or ISNULL(CONVERT(VARCHAR, New_AWW), '') <> '' or ISNULL(CONVERT(VARCHAR, New_employer), '') <> '' or ISNULL(CONVERT(VARCHAR, Newaww), '') <> '' or ISNULL(CONVERT(VARCHAR, Notes), '') <> '' or ISNULL(CONVERT(VARCHAR, Other_Household_Income), '') <> '' or ISNULL(CONVERT(VARCHAR, Other_Income), '') <> '' or ISNULL(CONVERT(VARCHAR, Out_Of_Work), '') <> '' or ISNULL(CONVERT(VARCHAR, Part_Of_Body), '') <> '' or ISNULL(CONVERT(VARCHAR, Pension), '') <> '' or ISNULL(CONVERT(VARCHAR, Personal_Bio), '') <> '' or ISNULL(CONVERT(VARCHAR, Phone_Number), '') <> '' or ISNULL(CONVERT(VARCHAR, Plantiff_Insurer), '') <> '' or ISNULL(CONVERT(VARCHAR, PostInjury_Employer), '') <> '' or ISNULL(CONVERT(VARCHAR, Preferred_contact_method), '') <> '' or ISNULL(CONVERT(VARCHAR, Premature), '') <> '' or ISNULL(CONVERT(VARCHAR, Primary_Contact), '') <> '' or ISNULL(CONVERT(VARCHAR, Primary_Contact_Ph_#), '') <> '' or ISNULL(CONVERT(VARCHAR, Prior_Acc), '') <> '' or ISNULL(CONVERT(VARCHAR, Prior_Complaints), '') <> '' or ISNULL(CONVERT(VARCHAR, Prior_Inj), '') <> '' or ISNULL(CONVERT(VARCHAR, Prior_Lawsuits), '') <> '' or ISNULL(CONVERT(VARCHAR, Public_Assistance), '') <> '' or ISNULL(CONVERT(VARCHAR, Refer_out), '') <> '' or ISNULL(CONVERT(VARCHAR, Refer_to_Laura), '') <> '' or ISNULL(CONVERT(VARCHAR, Rel_To_Plntf), '') <> '' or ISNULL(CONVERT(VARCHAR, ud.relationship), '') <> '' or ISNULL(CONVERT(VARCHAR, Relationship_to_Plntf), '') <> '' or ISNULL(CONVERT(VARCHAR, ud.[Relative]), '') <> '' or ISNULL(CONVERT(VARCHAR, Relative_Address), '') <> '' or ISNULL(CONVERT(VARCHAR, Relative_City), '') <> '' or ISNULL(CONVERT(VARCHAR, Relative_Phone), '') <> '' or ISNULL(CONVERT(VARCHAR, Relative_State), '') <> '' or ISNULL(CONVERT(VARCHAR, Relative_Zip), '') <> '' or ISNULL(CONVERT(VARCHAR, Release_to_work), '') <> '' or ISNULL(CONVERT(VARCHAR, RestricVoc), '') <> '' or ISNULL(CONVERT(VARCHAR, Restrictions), '') <> '' or ISNULL(CONVERT(VARCHAR, Returntowork), '') <> '' or ISNULL(CONVERT(VARCHAR, Role_in_Accident), '') <> '' or ISNULL(CONVERT(VARCHAR, RTW_old_employer), '') <> '' or ISNULL(CONVERT(VARCHAR, Seen_Google_Reviews), '') <> '' or ISNULL(CONVERT(VARCHAR, Seen_our_commercials), '') <> '' or ISNULL(CONVERT(VARCHAR, Spouse), '') <> '' or ISNULL(CONVERT(VARCHAR, Spouse_Name), '') <> '' or ISNULL(CONVERT(VARCHAR, Spouse_SS#), '') <> '' or ISNULL(CONVERT(VARCHAR, Staff_Approving_Rides), '') <> '' or ISNULL(CONVERT(VARCHAR, ud.[State]), '') <> '' or ISNULL(CONVERT(VARCHAR, Surgery), '') <> '' or ISNULL(CONVERT(VARCHAR, Thank_You_Letter), '') <> '' or ISNULL(CONVERT(VARCHAR, Time_Lost_From_Work), '') <> '' or ISNULL(CONVERT(VARCHAR, Title), '') <> '' or ISNULL(CONVERT(VARCHAR, Transportation_Approved), '') <> '' or ISNULL(CONVERT(VARCHAR, Treatingphy), '') <> '' or ISNULL(CONVERT(VARCHAR, Type_of_Pension), '') <> '' or ISNULL(CONVERT(VARCHAR, Type_of_Public_Assistance), '') <> '' or ISNULL(CONVERT(VARCHAR, Unable_to_reach), '') <> '' or ISNULL(CONVERT(VARCHAR, Veh_Owner), '') <> '' or ISNULL(CONVERT(VARCHAR, We_want_to_rep), '') <> '' or ISNULL(CONVERT(VARCHAR, Wearing_Glas), '') <> '' or ISNULL(CONVERT(VARCHAR, Wearing_Seatbelt), '') <> '' or ISNULL(CONVERT(VARCHAR, Welfare), '') <> '' or ISNULL(CONVERT(VARCHAR, What_Capacity), '') <> '' or ISNULL(CONVERT(VARCHAR, Where_Locatd), '') <> '' or ISNULL(CONVERT(VARCHAR, Where_Seated), '') <> '' or ISNULL(CONVERT(VARCHAR, YearMakeModel), '') <> '' or ISNULL(CONVERT(VARCHAR, Years_Employed), '') <> ''
		)

alter table sma_TRN_UDFValues enable trigger all
go