USE SA
GO

----------------------------
--PIVOT TABLE CONSTRUCTION
----------------------------
/*
select m.*
--distinct m.field_Title, column_name, 'convert(varchar(max), ['+ column_Name + '] ) as ['+ m.field_title +'], ', '['+m.field_title+'],'
FROM [NeedlesGMA].[dbo].[user_case_matter] M 
inner join [NeedlesGMA].[dbo].[user_case_fields] F on F.field_title=M.field_title
where m.field_Type <> 'label'
*/


IF EXISTS (Select * From sys.tables where name = 'CaseUDF_Incident' and type = 'U')
begin
	drop table CaseUDF_Incident
end
----------------------
--PIVOT TABLE
----------------------
SELECT casncaseid, casnorgcasetypeID, fieldTitle, FieldVal
INTO CaseUDF_Incident
FROM ( SELECT cas.casnCaseID, cas.CasnOrgCaseTypeID, 
		convert(varchar(max), [If_TV_Show_what_show] ) as [If TV Show, what show?], 
		convert(varchar(max), [Appointment_Date] ) as [Appointment Date], 
		convert(varchar(max), [Appointment_Time] ) as [Appointment Time], 
		convert(varchar(max), [We_want_to_rep] ) as [We want to rep], 
		convert(varchar(max), [Unable_to_reach] ) as [Unable to reach], 
		convert(varchar(max), [Premature] ) as [Premature], 
		convert(varchar(max), [Refer_out] ) as [Refer out], 
		convert(varchar(max), [Generic_Reject] ) as [Generic Reject], 
		convert(varchar(max), [Custom_Dictated] ) as [Custom (Dictated)], 
		convert(varchar(max), [Appointment_With] ) as [Appointment With], 
		convert(varchar(max), [Mail_SignUp] ) as [Mail Sign-Up], 
		convert(varchar(max), [Do_you_have_an_attorney] ) as [Do you have an attorney?], 
		convert(varchar(max), [Reason_on_Property] ) as [Reason on Property], 
		convert(varchar(max), [Familiarity_with_Property] ) as [Familiarity with Property], 
		convert(varchar(max), [Seen_our_commercials] ) as [Seen our commercials?], 
		convert(varchar(max), [Been_to_our_website] ) as [Been to our website?], 
		convert(varchar(max), [Diagnostic_tests] ) as [Diagnostic tests], 
		convert(varchar(max), [Liability_Accepted] ) as [Liability Accepted?], 
		convert(varchar(max), [Intake_Method] ) as [Intake Method], 
		convert(varchar(max), [Do_We_Want_This_Case] ) as [Do We Want This Case?], 
		convert(varchar(max), [Follow_up_date] ) as [Follow up date], 
		convert(varchar(max), [Pen_and_paper] ) as [Pen and paper?], 
		convert(varchar(max), [Told_to_write] ) as [Told to write], 
		convert(varchar(max), [PI_Value_Rank] ) as [PI Value Rank], 
		convert(varchar(max), [Fees_Disc_Recd_Date] ) as [Fees Disc Recd Date], 
		convert(varchar(max), [Outside_Intake] ) as [Outside Intake], 
		convert(varchar(max), [Signup_Date] ) as [Sign-up Date], 
		convert(varchar(max), [Gift_bag_sent] ) as [Gift bag sent?], 
		convert(varchar(max), [Demand_to_Attorney] ) as [Demand to Attorney], 
		convert(varchar(max), [Settled_Primary] ) as [Settled Primary], 
		convert(varchar(max), [Date_Contract_Signed] ) as [Date Contract Signed], 
		convert(varchar(max), [Date_Accepted] ) as [Date Accepted], 
		convert(varchar(max), [Settlement_Sent_to_MLS] ) as [Settlement Sent to MLS], 
		convert(varchar(max), [NA] ) as [N/A], 
		convert(varchar(max), [Date_of_First_Contact] ) as [Date of First Contact], 
		convert(varchar(max), [Time_of_First_Contact] ) as [Time of First Contact], 
		convert(varchar(max), [Transferred_to_LIT] ) as [Transferred to LIT], 
		convert(varchar(max), [Prescriptions] ) as [Prescriptions?], 
		convert(varchar(max), [DDF_Recd_from_Client] ) as [DDF Rec'd from Client], 
		convert(varchar(max), [Diagnoses] ) as [Diagnoses], 
		convert(varchar(max), [Who_made_Diagnosis] ) as [Who made Diagnosis?], 
		convert(varchar(max), [Honorable_Discharge] ) as [Honorable Discharge?], 
		convert(varchar(max), [Receiving_VA_Benefits] ) as [Receiving VA Benefits?], 
		convert(varchar(max), [If_yes_for_Lejeune] ) as [If yes, for Lejeune?], 
		convert(varchar(max), [First_Date_on_Base] ) as [First Date on Base], 
		convert(varchar(max), [Last_Date_on_Base] ) as [Last Date on Base], 
		convert(varchar(max), [Rank] ) as [Rank], 
		convert(varchar(max), [Sent_to_PW] ) as [Sent to PW], 
		convert(varchar(max), [Accepted_by_PW] ) as [Accepted by PW?], 
		convert(varchar(max), [Branch_of_Service] ) as [Branch of Service]
	FROM NeedlesGMA..user_Case_Data ud
	JOIN NeedlesGMA..cases_Indexed c on c.casenum = ud.casenum
	JOIN sma_TRN_Cases cas on cas.cassCaseNumber = convert(varchar,ud.casenum)
	WHERE c.matcode in ('CLW')
) pv
UNPIVOT (FieldVal FOR FieldTitle IN ([If TV Show, what show?], [Appointment Date], [Appointment Time], [We want to rep], 
		[Unable to reach], [Premature], [Refer out], [Generic Reject], [Custom (Dictated)], [Appointment With], [Mail Sign-Up], 
		[Do you have an attorney?], [Reason on Property], [Familiarity with Property], [Seen our commercials?], 
		[Been to our website?], [Diagnostic tests], [Liability Accepted?], [Intake Method], [Do We Want This Case?], 
		[Follow up date], [Pen and paper?], [Told to write], [PI Value Rank], [Fees Disc Recd Date], [Outside Intake], [Sign-up Date], 
		[Gift bag sent?], [Demand to Attorney], [Settled Primary], [Date Contract Signed], [Date Accepted], [Settlement Sent to MLS], 
		[N/A], [Date of First Contact], [Time of First Contact], [Transferred to LIT], [Prescriptions?], [DDF Rec'd from Client], 
		[Diagnoses], [Who made Diagnosis?], [Honorable Discharge?], [Receiving VA Benefits?], [If yes, for Lejeune?], [First Date on Base], 
		[Last Date on Base], [Rank], [Sent to PW], [Accepted by PW?], [Branch of Service] )
) as unpvt


----------------------------
--UDF DEFINITION
----------------------------
INSERT INTO [sma_MST_UDFDefinition]
(
    [udfsUDFCtg]
    ,[udfnRelatedPK]
    ,[udfsUDFName]
    ,[udfsScreenName]
    ,[udfsType]
    ,[udfsLength]
    ,[udfbIsActive]
	,[udfshortName]
	,[udfsNewValues]
    ,[udfnSortOrder]
)
SELECT DISTINCT 
    'C'						as [udfsUDFCtg],
    CST.cstnCaseTypeID		as [udfnRelatedPK],
    M.field_title			as [udfsUDFName],   
    'Case Wizard'			as [udfsScreenName],
    ucf.UDFType			    as [udfsType],
    ucf.field_len		    as [udfsLength],
    1					    as [udfbIsActive],
	 'user_Case_Data'+ucf.column_name	as [udfshortName],
    ucf.dropdownValues		as [udfsNewValues],
    DENSE_RANK() over( order by M.field_title) as udfnSortOrder
FROM [sma_MST_CaseType] CST
JOIN CaseTypeMixture mix on mix.[SmartAdvocate Case Type] = cst.cstsType
JOIN [NeedlesGMA].[dbo].[user_case_matter] M on M.mattercode=mix.matcode and M.field_type <> 'label'
JOIN (select DISTINCT fieldTitle from CaseUDF_Incident) vd on vd.FieldTitle = m.field_title
--JOIN [NeedlesGMA].[dbo].[user_Case_Fields] ucf on m.ref_num = ucf.field_num
JOIN NeedlesUserFields ucf on ucf.field_num = m.ref_num
LEFT JOIN (select distinct table_Name, column_name From [NeedlesGMA].[dbo].[document_merge_params] where table_Name = 'user_Case_Data') dmp
												on dmp.column_name = ucf.field_Title
LEFT JOIN [sma_MST_UDFDefinition] def on def.[udfnRelatedPK] = cst.cstnCaseTypeID and def.[udfsUDFName] = m.field_title and def.[udfsScreenName] = 'Case Wizard' and udfstype = ucf.UDFType
WHERE m.Field_Title <> 'Location'
and def.udfnUDFID IS NULL
and mix.matcode IN ('CLW')
order by m.field_title

--select * From [NeedlesGMA]..[user_case_matter]

--------------------------------------
--UDF VALUES
--------------------------------------
alter table sma_trn_udfvalues disable trigger all
go
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
select --fieldtitle, udf.casnOrgCaseTypeID,
	def.udfnUDFID		as [udvnUDFID],
	'Case Wizard'		as [udvsScreenName],
	'C'					as [udvsUDFCtg],
	casnCaseID			as [udvnRelatedID],
	0					as [udvnSubRelatedID],
	udf.FieldVal		as [udvsUDFValue],
	368					as [udvnRecUserID],
	getdate()			as [udvdDtCreated],
	null				as [udvnModifyUserID],
	null				as [udvdDtModified],
	null				as [udvnLevelNo]
--select *
FROM CaseUDF_Incident udf
LEFT JOIN sma_MST_UDFDefinition def on def.udfnRelatedPK = udf.casnOrgCaseTypeID and def.udfsUDFName = FieldTitle and def.udfsScreenName = 'Case Wizard'

alter table sma_trn_udfvalues enable trigger all
go
