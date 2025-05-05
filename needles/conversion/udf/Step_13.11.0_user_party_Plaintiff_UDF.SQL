
use SA
GO

/*
---(Supporting Statements)---
select 'when LIST.column_name=' + ''''+ F.column_name +'''' + ' then convert(varchar(MAX),UD.' + F.column_name + ')',
'isnull( convert(varchar,'+F.column_name +'),'''')<>'''' or '
from [NeedlesGMA].[dbo].[user_case_fields] F
where field_title in ( select distinct field_title from [NeedlesGMA].[dbo].[user_party_matter] ) 
*/


----(0)---- build a supporting table with anchors and values
if exists (select * from sys.objects where name='UDF_Helper' and type='U')
begin
    drop table UDF_Helper
end
GO
----(0)---- 
create table UDF_Helper
(
    tableIndex		int IDENTITY(1,1) NOT NULL,
    ref_num			int,		
    column_name		varchar(100),	
    field_title		varchar(100),	
    mattercode		varchar(100),
	UDFType			varchar(30),
	field_len		varchar(20)
 CONSTRAINT IX_UDF_Helper PRIMARY KEY CLUSTERED 
(
	tableIndex
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] 
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_ref_num ON UDF_Helper (ref_num);   
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_column_name ON UDF_Helper (column_name);   
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_field_title ON UDF_Helper (field_title); 
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_mattercode ON UDF_Helper (mattercode); 
GO  
--select * From UDF_Helper

----(0)---- 
insert into UDF_Helper (
    ref_num,
    column_name,
    field_title,
    mattercode,
	UDFType,
	field_len
)
select ref_num,F.column_name,F.field_title,M.mattercode , udftype, f.field_len
from [NeedlesGMA].[dbo].[user_party_matter] M 
JOIN NeedlesUserFields F on F.field_num=M.ref_num 
JOIN [PartyRoles] R on R.[Needles Roles]=M.party_role
where R.[SA Party]='Plaintiff'
GO
----(0)---- 
DBCC DBREINDEX('UDF_Helper',' ',90) WITH NO_INFOMSGS 
/*
----------------------BUILD USER PARTY HELPER----------------------
if exists (select * from sys.objects where name='UserParty_Helper' and type='U')
begin
    drop table UserParty_Helper
end
GO

select p.tableindex, party_ID, case_ID, [role], [sa party],IOC.CID, IOC.CTG, IOC.AID, IOC.UNQCID, IOC.Name, IOC.SAGA 
INTO UserParty_Helper
From [NeedlesGMA].[dbo].[party_Indexed] P
JOIN [SA].[dbo].[IndvOrgContacts_Indexed] IOC on IOC.SAGA = P.party_id
JOIN [SA].[dbo].[PartyRoles] R on R.[Needles Roles]=p.[role]
*/
--select * from NeedlesGMA..user_case_fields

---(1/2)---
insert into [sma_MST_UDFDefinition]
(
    [udfsUDFCtg]
    ,[udfnRelatedPK]
    ,[udfsUDFName]
    ,[udfsScreenName]
    ,[udfsType]
    ,[udfsLength]
    ,[udfbIsActive]
    ,[udfnLevelNo]
	,[UdfShortName]
	,[udfsNewValues]
    ,[udfnSortOrder]
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
    DENSE_RANK() over( order by A.[udfsUDFName]) as udfnSortOrder
from
(
select distinct 
    'C'					   as [udfsUDFCtg],
    CST.cstnCaseTypeID	   as [udfnRelatedPK],
    M.field_title		   as [udfsUDFName],   
    r.[SA Party]		   as [udfsScreenName],
    ucf.UDFType			   as [udfsType],
    ucf.field_len		   as [udfsLength],
    1					   as [udfbIsActive],
	'user_party_Data'+ ucf.column_name		as [udfshortName],
	ucf.dropdownValues	   as [udfsNewValues],
    M.ref_num			   as [udfnLevelNo]
from [sma_MST_CaseType] CST
JOIN CaseTypeMixture mix on mix.[SmartAdvocate Case Type] = cst.cstsType
JOIN [NeedlesGMA].[dbo].[user_party_matter] M on M.mattercode=mix.matcode
JOIN [PartyRoles] R on R.[Needles Roles]=M.party_role
JOIN NeedlesUserFields ucf on m.ref_num = ucf.field_num
LEFT JOIN (select distinct table_Name, column_name From [NeedlesGMA].[dbo].[document_merge_params] where table_Name = 'user_party_Data') dmp
												on dmp.column_name = ucf.column_Name
LEFT JOIN [sma_MST_UDFDefinition] udf on udf.udfnRelatedPK = cst.cstnCaseTypeID and udf.udfsScreenName = [SA Party] and udf.udfsUDFName = m.field_title and udfstype = ucf.UDFType
where R.[SA Party]='Plaintiff'
and CST.VenderCaseType='GMACaseType'
and udf.udfnUDFID IS NULL
) A

GO

alter table sma_TRN_UDFValues disable trigger all
GO

---(2/2)---
insert into [sma_TRN_UDFValues]
(
       [udvnUDFID]
      ,[udvsScreenName]
      ,[udvsUDFCtg]
      ,[udvnRelatedID]
      ,[udvnSubRelatedID]
      ,[udvsUDFValue]
      ,[udvnRecUserID]
      ,[udvdDtCreated]
      ,[udvnModifyUserID]
      ,[udvdDtModified]
      ,[udvnLevelNo]
)
select DISTINCT
	(select top 1 udfnUDFID from [sma_MST_UDFDefinition] 
		where udfnRelatedPK=casnOrgCaseTypeID and udfsUDFName=LIST.field_title and udfsScreenName='Plaintiff' and udfstype=UDFType)
						as [udvnUDFID],
	'Plaintiff'			as [udvsScreenName],
	'C'					as [udvsUDFCtg],
	CAS.casnCaseID		as [udvnRelatedID],
	T.plnnPlaintiffID	as[udvnSubRelatedID],
	case
		when LIST.column_name='Activity' then convert(varchar(MAX),UD.Activity)
		when LIST.column_name='Adjustor' then convert(varchar(MAX),UD.Adjustor)
		when LIST.column_name='Agent_for_Service' then convert(varchar(MAX),UD.Agent_for_Service)
		when LIST.column_name='AKA_Role' then convert(varchar(MAX),UD.AKA_Role)
		when LIST.column_name='Amt_of_Public_Assistance' then convert(varchar(MAX),UD.Amt_of_Public_Assistance)
		when LIST.column_name='Any_headbrain_injury' then convert(varchar(MAX),UD.Any_headbrain_injury)
		when LIST.column_name='AwwTtd' then convert(varchar(MAX),UD.AwwTtd)
		when LIST.column_name='Been_to_our_website' then convert(varchar(MAX),UD.Been_to_our_website)
		when LIST.column_name='Best_time_to_contact' then convert(varchar(MAX),UD.Best_time_to_contact)
		when LIST.column_name='Children' then convert(varchar(MAX),UD.Children)
		when LIST.column_name='CityStateZip' then convert(varchar(MAX),UD.CityStateZip)
		when LIST.column_name='Concierge_Form_Signed' then convert(varchar(MAX),UD.Concierge_Form_Signed)
		when LIST.column_name='Custom_Dictated' then convert(varchar(MAX),UD.Custom_Dictated)
		when LIST.column_name='Date_started' then convert(varchar(MAX),UD.Date_started)
		when LIST.column_name='Date_Thank_You_Sent' then convert(varchar(MAX),UD.Date_Thank_You_Sent)
		when LIST.column_name='Education' then convert(varchar(MAX),UD.Education)
		when LIST.column_name='Email_availability' then convert(varchar(MAX),UD.Email_availability)
		when LIST.column_name='Emerg_Contact_Phone_#' then convert(varchar(MAX),UD.Emerg_Contact_Phone_#)
		when LIST.column_name='Emergency_Contact' then convert(varchar(MAX),UD.Emergency_Contact)
		when LIST.column_name='Emergency_Contact_#' then convert(varchar(MAX),UD.Emergency_Contact_#)
		when LIST.column_name='Employed' then convert(varchar(MAX),UD.Employed)
		when LIST.column_name='Employer' then convert(varchar(MAX),UD.Employer)
		when LIST.column_name='Employer_Address' then convert(varchar(MAX),UD.Employer_Address)
		when LIST.column_name='Employer_Type' then convert(varchar(MAX),UD.Employer_Type)
		when LIST.column_name='Employment' then convert(varchar(MAX),UD.Employment)
		when LIST.column_name='ER_Contact_Name' then convert(varchar(MAX),UD.ER_Contact_Name)
		when LIST.column_name='ER_Contact_Phone_#' then convert(varchar(MAX),UD.ER_Contact_Phone_#)
		when LIST.column_name='Exertional_Requirement' then convert(varchar(MAX),UD.Exertional_Requirement)
		when LIST.column_name='Generic_Reject' then convert(varchar(MAX),UD.Generic_Reject)
		when LIST.column_name='Glasses' then convert(varchar(MAX),UD.Glasses)
		when LIST.column_name='Guardian_Name' then convert(varchar(MAX),UD.Guardian_Name)
		when LIST.column_name='Has_Atty' then convert(varchar(MAX),UD.Has_Atty)
		when LIST.column_name='Ime' then convert(varchar(MAX),UD.Ime)
		when LIST.column_name='Imp' then convert(varchar(MAX),UD.Imp)
		when LIST.column_name='Impairment' then convert(varchar(MAX),UD.Impairment)
		when LIST.column_name='Income_from_Investment' then convert(varchar(MAX),UD.Income_from_Investment)
		when LIST.column_name='Injuries' then convert(varchar(MAX),UD.Injuries)
		when LIST.column_name='InjuryNotes' then convert(varchar(MAX),UD.InjuryNotes)
		when LIST.column_name='Intake_By' then convert(varchar(MAX),UD.Intake_By)
		when LIST.column_name='Job_Description' then convert(varchar(MAX),UD.Job_Description)
		when LIST.column_name='Key_words_searched' then convert(varchar(MAX),UD.Key_words_searched)
		when LIST.column_name='License' then convert(varchar(MAX),UD.License)
		when LIST.column_name='License_Plate_Number' then convert(varchar(MAX),UD.License_Plate_Number)
		when LIST.column_name='License_Plate_State' then convert(varchar(MAX),UD.License_Plate_State)
		when LIST.column_name='License_State' then convert(varchar(MAX),UD.License_State)
		when LIST.column_name='Location_of_Vehicle' then convert(varchar(MAX),UD.Location_of_Vehicle)
		when LIST.column_name='Marital_Stat' then convert(varchar(MAX),UD.Marital_Stat)
		when LIST.column_name='Marital_Status' then convert(varchar(MAX),UD.Marital_Status)
		when LIST.column_name='Mileage' then convert(varchar(MAX),UD.Mileage)
		when LIST.column_name='New_AWW' then convert(varchar(MAX),UD.New_AWW)
		when LIST.column_name='New_employer' then convert(varchar(MAX),UD.New_employer)
		when LIST.column_name='Newaww' then convert(varchar(MAX),UD.Newaww)
		when LIST.column_name='Notes' then convert(varchar(MAX),UD.Notes)
		when LIST.column_name='Other_Household_Income' then convert(varchar(MAX),UD.Other_Household_Income)
		when LIST.column_name='Other_Income' then convert(varchar(MAX),UD.Other_Income)
		when LIST.column_name='Out_Of_Work' then convert(varchar(MAX),UD.Out_Of_Work)
		when LIST.column_name='Part_Of_Body' then convert(varchar(MAX),UD.Part_Of_Body)
		when LIST.column_name='Pension' then convert(varchar(MAX),UD.Pension)
		when LIST.column_name='Personal_Bio' then convert(varchar(MAX),UD.Personal_Bio)
		when LIST.column_name='Phone_Number' then convert(varchar(MAX),UD.Phone_Number)
		when LIST.column_name='Plantiff_Insurer' then convert(varchar(MAX),UD.Plantiff_Insurer)
		when LIST.column_name='PostInjury_Employer' then convert(varchar(MAX),UD.PostInjury_Employer)
		when LIST.column_name='Preferred_contact_method' then convert(varchar(MAX),UD.Preferred_contact_method)
		when LIST.column_name='Premature' then convert(varchar(MAX),UD.Premature)
		when LIST.column_name='Primary_Contact' then convert(varchar(MAX),UD.Primary_Contact)
		when LIST.column_name='Primary_Contact_Ph_#' then convert(varchar(MAX),UD.Primary_Contact_Ph_#)
		when LIST.column_name='Prior_Acc' then convert(varchar(MAX),UD.Prior_Acc)
		when LIST.column_name='Prior_Complaints' then convert(varchar(MAX),UD.Prior_Complaints)
		when LIST.column_name='Prior_Inj' then convert(varchar(MAX),UD.Prior_Inj)
		when LIST.column_name='Prior_Lawsuits' then convert(varchar(MAX),UD.Prior_Lawsuits)
		when LIST.column_name='Public_Assistance' then convert(varchar(MAX),UD.Public_Assistance)
		when LIST.column_name='Refer_out' then convert(varchar(MAX),UD.Refer_out)
		when LIST.column_name='Refer_to_Laura' then convert(varchar(MAX),UD.Refer_to_Laura)
		when LIST.column_name='Rel_To_Plntf' then convert(varchar(MAX),UD.Rel_To_Plntf)
		when LIST.column_name='Relationship' then convert(varchar(MAX),UD.Relationship)
		when LIST.column_name='Relationship_to_Plntf' then convert(varchar(MAX),UD.Relationship_to_Plntf)
		when LIST.column_name='Relative' then convert(varchar(MAX),UD.[Relative])
		when LIST.column_name='Relative_Address' then convert(varchar(MAX),UD.Relative_Address)
		when LIST.column_name='Relative_City' then convert(varchar(MAX),UD.Relative_City)
		when LIST.column_name='Relative_Phone' then convert(varchar(MAX),UD.Relative_Phone)
		when LIST.column_name='Relative_State' then convert(varchar(MAX),UD.Relative_State)
		when LIST.column_name='Relative_Zip' then convert(varchar(MAX),UD.Relative_Zip)
		when LIST.column_name='Release_to_work' then convert(varchar(MAX),UD.Release_to_work)
		when LIST.column_name='RestricVoc' then convert(varchar(MAX),UD.RestricVoc)
		when LIST.column_name='Restrictions' then convert(varchar(MAX),UD.Restrictions)
		when LIST.column_name='Returntowork' then convert(varchar(MAX),UD.Returntowork)
		when LIST.column_name='Role_in_Accident' then convert(varchar(MAX),UD.Role_in_Accident)
		when LIST.column_name='RTW_old_employer' then convert(varchar(MAX),UD.RTW_old_employer)
		when LIST.column_name='Seen_Google_Reviews' then convert(varchar(MAX),UD.Seen_Google_Reviews)
		when LIST.column_name='Seen_our_commercials' then convert(varchar(MAX),UD.Seen_our_commercials)
		when LIST.column_name='Spouse' then convert(varchar(MAX),UD.Spouse)
		when LIST.column_name='Spouse_Name' then convert(varchar(MAX),UD.Spouse_Name)
		when LIST.column_name='Spouse_SS#' then convert(varchar(MAX),UD.Spouse_SS#)
		when LIST.column_name='Staff_Approving_Rides' then convert(varchar(MAX),UD.Staff_Approving_Rides)
		when LIST.column_name='State' then convert(varchar(MAX),UD.[State])
		when LIST.column_name='Surgery' then convert(varchar(MAX),UD.Surgery)
		when LIST.column_name='Thank_You_Letter' then convert(varchar(MAX),UD.Thank_You_Letter)
		when LIST.column_name='Time_Lost_From_Work' then convert(varchar(MAX),UD.Time_Lost_From_Work)
		when LIST.column_name='Title' then convert(varchar(MAX),UD.Title)
		when LIST.column_name='Transportation_Approved' then convert(varchar(MAX),UD.Transportation_Approved)
		when LIST.column_name='Treatingphy' then convert(varchar(MAX),UD.Treatingphy)
		when LIST.column_name='Type_of_Pension' then convert(varchar(MAX),UD.Type_of_Pension)
		when LIST.column_name='Type_of_Public_Assistance' then convert(varchar(MAX),UD.Type_of_Public_Assistance)
		when LIST.column_name='Unable_to_reach' then convert(varchar(MAX),UD.Unable_to_reach)
		when LIST.column_name='Veh_Owner' then convert(varchar(MAX),UD.Veh_Owner)
		when LIST.column_name='We_want_to_rep' then convert(varchar(MAX),UD.We_want_to_rep)
		when LIST.column_name='Wearing_Glas' then convert(varchar(MAX),UD.Wearing_Glas)
		when LIST.column_name='Wearing_Seatbelt' then convert(varchar(MAX),UD.Wearing_Seatbelt)
		when LIST.column_name='Welfare' then convert(varchar(MAX),UD.Welfare)
		when LIST.column_name='What_Capacity' then convert(varchar(MAX),UD.What_Capacity)
		when LIST.column_name='Where_Locatd' then convert(varchar(MAX),UD.Where_Locatd)
		when LIST.column_name='Where_Seated' then convert(varchar(MAX),UD.Where_Seated)
		when LIST.column_name='YearMakeModel' then convert(varchar(MAX),UD.YearMakeModel)
		when LIST.column_name='Years_Employed' then convert(varchar(MAX),UD.Years_Employed)
     end					as [udvsUDFValue],
	368						as [udvnRecUserID],
	getdate()				as [udvdDtCreated],
	null					as [udvnModifyUserID],
	null					as [udvdDtModified],
	null					as [udvnLevelNo]
	--select * --cas.casncaseid, T.plnnPlaintiffID, cst.cstscode, p.role, casnOrgCaseTypeID, t.saga_party, p.tableindex, ud.*
from [NeedlesGMA].[dbo].[user_party_data] UD 
JOIN [NeedlesGMA].[dbo].[cases_Indexed] ci on ud.case_id = ci.casenum
JOIN [sma_TRN_cases] CAS on CAS.cassCaseNumber = convert(varchar,UD.case_id)
JOIN [sma_MST_CaseType] CST on CST.cstnCaseTypeID=CAS.casnOrgCaseTypeID and VenderCaseType='GMACaseType'
join [NeedlesGMA].[dbo].[party_Indexed] P on P.party_id=UD.party_id and P.case_id=UD.case_id
JOIN [IndvOrgContacts_Indexed] IOC on IOC.SAGA = UD.party_id
join sma_TRN_Plaintiff T on P.TableIndex= T.[saga_party]
join UDF_Helper LIST on LIST.mattercode=ci.matcode
join (SELECT [Needles Roles] FROM [SA].[dbo].[PartyRoles] where [SA Party]='Plaintiff') N on N.[Needles Roles]=P.[role]
WHERE (
		isnull( convert(varchar,Activity),'')<>'' or 
		isnull( convert(varchar,Adjustor),'')<>'' or 
		isnull( convert(varchar,Agent_for_Service),'')<>'' or 
		isnull( convert(varchar,AKA_Role),'')<>'' or 
		isnull( convert(varchar,Amt_of_Public_Assistance),'')<>'' or 
		isnull( convert(varchar,Any_headbrain_injury),'')<>'' or 
		isnull( convert(varchar,AwwTtd),'')<>'' or 
		isnull( convert(varchar,Been_to_our_website),'')<>'' or 
		isnull( convert(varchar,Best_time_to_contact),'')<>'' or 
		isnull( convert(varchar,Children),'')<>'' or 
		isnull( convert(varchar,CityStateZip),'')<>'' or 
		isnull( convert(varchar,Concierge_Form_Signed),'')<>'' or 
		isnull( convert(varchar,Custom_Dictated),'')<>'' or 
		isnull( convert(varchar,Date_started),'')<>'' or 
		isnull( convert(varchar,Date_Thank_You_Sent),'')<>'' or 
		isnull( convert(varchar,Education),'')<>'' or 
		isnull( convert(varchar,Email_availability),'')<>'' or 
		isnull( convert(varchar,Emerg_Contact_Phone_#),'')<>'' or 
		isnull( convert(varchar,Emergency_Contact),'')<>'' or 
		isnull( convert(varchar,Emergency_Contact_#),'')<>'' or 
		isnull( convert(varchar,Employed),'')<>'' or 
		isnull( convert(varchar,Employer),'')<>'' or 
		isnull( convert(varchar,Employer_Address),'')<>'' or 
		isnull( convert(varchar,Employer_Type),'')<>'' or 
		isnull( convert(varchar,Employment),'')<>'' or 
		isnull( convert(varchar,ER_Contact_Name),'')<>'' or 
		isnull( convert(varchar,ER_Contact_Phone_#),'')<>'' or 
		isnull( convert(varchar,Exertional_Requirement),'')<>'' or 
		isnull( convert(varchar,Generic_Reject),'')<>'' or 
		isnull( convert(varchar,Glasses),'')<>'' or 
		isnull( convert(varchar,Guardian_Name),'')<>'' or 
		isnull( convert(varchar,Has_Atty),'')<>'' or 
		isnull( convert(varchar,Ime),'')<>'' or 
		isnull( convert(varchar,Imp),'')<>'' or 
		isnull( convert(varchar,Impairment),'')<>'' or 
		isnull( convert(varchar,Income_from_Investment),'')<>'' or 
		isnull( convert(varchar,Injuries),'')<>'' or 
		isnull( convert(varchar,InjuryNotes),'')<>'' or 
		isnull( convert(varchar,Intake_By),'')<>'' or 
		isnull( convert(varchar,Job_Description),'')<>'' or 
		isnull( convert(varchar,Key_words_searched),'')<>'' or 
		isnull( convert(varchar,License),'')<>'' or 
		isnull( convert(varchar,License_Plate_Number),'')<>'' or 
		isnull( convert(varchar,License_Plate_State),'')<>'' or 
		isnull( convert(varchar,License_State),'')<>'' or 
		isnull( convert(varchar,Location_of_Vehicle),'')<>'' or 
		isnull( convert(varchar,Marital_Stat),'')<>'' or 
		isnull( convert(varchar,Marital_Status),'')<>'' or 
		isnull( convert(varchar,Mileage),'')<>'' or 
		isnull( convert(varchar,New_AWW),'')<>'' or 
		isnull( convert(varchar,New_employer),'')<>'' or 
		isnull( convert(varchar,Newaww),'')<>'' or 
		isnull( convert(varchar,Notes),'')<>'' or 
		isnull( convert(varchar,Other_Household_Income),'')<>'' or 
		isnull( convert(varchar,Other_Income),'')<>'' or 
		isnull( convert(varchar,Out_Of_Work),'')<>'' or 
		isnull( convert(varchar,Part_Of_Body),'')<>'' or 
		isnull( convert(varchar,Pension),'')<>'' or 
		isnull( convert(varchar,Personal_Bio),'')<>'' or 
		isnull( convert(varchar,Phone_Number),'')<>'' or 
		isnull( convert(varchar,Plantiff_Insurer),'')<>'' or 
		isnull( convert(varchar,PostInjury_Employer),'')<>'' or 
		isnull( convert(varchar,Preferred_contact_method),'')<>'' or 
		isnull( convert(varchar,Premature),'')<>'' or 
		isnull( convert(varchar,Primary_Contact),'')<>'' or 
		isnull( convert(varchar,Primary_Contact_Ph_#),'')<>'' or 
		isnull( convert(varchar,Prior_Acc),'')<>'' or 
		isnull( convert(varchar,Prior_Complaints),'')<>'' or 
		isnull( convert(varchar,Prior_Inj),'')<>'' or 
		isnull( convert(varchar,Prior_Lawsuits),'')<>'' or 
		isnull( convert(varchar,Public_Assistance),'')<>'' or 
		isnull( convert(varchar,Refer_out),'')<>'' or 
		isnull( convert(varchar,Refer_to_Laura),'')<>'' or 
		isnull( convert(varchar,Rel_To_Plntf),'')<>'' or 
		isnull( convert(varchar,ud.Relationship),'')<>'' or 
		isnull( convert(varchar,Relationship_to_Plntf),'')<>'' or 
		isnull( convert(varchar,ud.[Relative]),'')<>'' or 
		isnull( convert(varchar,Relative_Address),'')<>'' or 
		isnull( convert(varchar,Relative_City),'')<>'' or 
		isnull( convert(varchar,Relative_Phone),'')<>'' or 
		isnull( convert(varchar,Relative_State),'')<>'' or 
		isnull( convert(varchar,Relative_Zip),'')<>'' or 
		isnull( convert(varchar,Release_to_work),'')<>'' or 
		isnull( convert(varchar,RestricVoc),'')<>'' or 
		isnull( convert(varchar,Restrictions),'')<>'' or 
		isnull( convert(varchar,Returntowork),'')<>'' or 
		isnull( convert(varchar,Role_in_Accident),'')<>'' or 
		isnull( convert(varchar,RTW_old_employer),'')<>'' or 
		isnull( convert(varchar,Seen_Google_Reviews),'')<>'' or 
		isnull( convert(varchar,Seen_our_commercials),'')<>'' or 
		isnull( convert(varchar,Spouse),'')<>'' or 
		isnull( convert(varchar,Spouse_Name),'')<>'' or 
		isnull( convert(varchar,Spouse_SS#),'')<>'' or 
		isnull( convert(varchar,Staff_Approving_Rides),'')<>'' or 
		isnull( convert(varchar,ud.[State]),'')<>'' or 
		isnull( convert(varchar,Surgery),'')<>'' or 
		isnull( convert(varchar,Thank_You_Letter),'')<>'' or 
		isnull( convert(varchar,Time_Lost_From_Work),'')<>'' or 
		isnull( convert(varchar,Title),'')<>'' or 
		isnull( convert(varchar,Transportation_Approved),'')<>'' or 
		isnull( convert(varchar,Treatingphy),'')<>'' or 
		isnull( convert(varchar,Type_of_Pension),'')<>'' or 
		isnull( convert(varchar,Type_of_Public_Assistance),'')<>'' or 
		isnull( convert(varchar,Unable_to_reach),'')<>'' or 
		isnull( convert(varchar,Veh_Owner),'')<>'' or 
		isnull( convert(varchar,We_want_to_rep),'')<>'' or 
		isnull( convert(varchar,Wearing_Glas),'')<>'' or 
		isnull( convert(varchar,Wearing_Seatbelt),'')<>'' or 
		isnull( convert(varchar,Welfare),'')<>'' or 
		isnull( convert(varchar,What_Capacity),'')<>'' or 
		isnull( convert(varchar,Where_Locatd),'')<>'' or 
		isnull( convert(varchar,Where_Seated),'')<>'' or 
		isnull( convert(varchar,YearMakeModel),'')<>'' or 
		isnull( convert(varchar,Years_Employed),'')<>''  
 )
	
 alter table sma_TRN_UDFValues enable trigger all
GO