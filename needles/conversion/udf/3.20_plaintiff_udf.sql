/*

Create Plaintiff UDF

https://smartadvocate.atlassian.net/wiki/spaces/Conversion/pages/2436366355/SmartAdvocate+Database+Reference#UDF
*/


use [JohnSalazar_SA]
go

/* ####################################
0.0 -- Create Pivot Table
*/

if exists (
		select
			*
		from sys.tables
		where name = 'PlaintiffUDF'
			and type = 'U'
	)
begin
	drop table PlaintiffUDF
end
go

select
	casncaseid,
	casnorgcasetypeID,
	fieldTitle,
	FieldVal
into PlaintiffUDF
from (
	select
		cas.casnCaseID,
		cas.CasnOrgCaseTypeID,
		CONVERT(VARCHAR(MAX), [Acc_Details])			   as [Acc. Details],
		CONVERT(VARCHAR(MAX), [Activity])				   as [Activity],
		CONVERT(VARCHAR(MAX), [Alcohol_Comments])		   as [Alcohol Comments],
		CONVERT(VARCHAR(MAX), [Alcohol_Involved])		   as [Alcohol Involved],
		CONVERT(VARCHAR(MAX), [Any_Dosage_Change])		   as [Any Dosage Change],
		CONVERT(VARCHAR(MAX), [Availability])			   as [Availability],
		CONVERT(VARCHAR(MAX), [Bias])					   as [Bias],
		CONVERT(VARCHAR(MAX), [Callers_Name])			   as [Callers Name],
		CONVERT(VARCHAR(MAX), [Cancer])					   as [Cancer?],
		CONVERT(VARCHAR(MAX), [Case_No])				   as [Case No],
		CONVERT(VARCHAR(MAX), [Charges])				   as [Charges],
		CONVERT(VARCHAR(MAX), [Citation_Issued])		   as [Citation Issued?],
		CONVERT(VARCHAR(MAX), [Citations])				   as [Citations],
		CONVERT(VARCHAR(MAX), [CityStateZip])			   as [City/State/Zip],
		CONVERT(VARCHAR(MAX), [County])					   as [County],
		CONVERT(VARCHAR(MAX), [Credibility])			   as [Credibility],
		CONVERT(VARCHAR(MAX), [Crosswalk])				   as [Crosswalk],
		CONVERT(VARCHAR(MAX), [Date_of_1st_prescription])  as [Date of 1st prescription],
		CONVERT(VARCHAR(MAX), [Date_of_Death])			   as [Date of Death],
		CONVERT(VARCHAR(MAX), [Date_of_Heart_Attack])	   as [Date of Heart Attack],
		CONVERT(VARCHAR(MAX), [Date_of_Implant])		   as [Date of Implant?],
		CONVERT(VARCHAR(MAX), [Date_of_removal])		   as [Date of removal?],
		CONVERT(VARCHAR(MAX), [Date_of_Stroke])			   as [Date of Stroke],
		CONVERT(VARCHAR(MAX), [Death_Cause])			   as [Death Cause],
		CONVERT(VARCHAR(MAX), [Death_Date])				   as [Death Date],
		CONVERT(VARCHAR(MAX), [Defenses])				   as [Defenses],
		CONVERT(VARCHAR(MAX), [Deployment_location])	   as [Deployment location],
		CONVERT(VARCHAR(MAX), [Die])					   as [Die?],
		CONVERT(VARCHAR(MAX), [Do_We_Rep_Pd])			   as [Do We Rep Pd],
		CONVERT(VARCHAR(MAX), [Do_You_Smoke])			   as [Do You Smoke?],
		CONVERT(VARCHAR(MAX), [Doctors_Address])		   as [Doctors Address],
		CONVERT(VARCHAR(MAX), [Doctors_City])			   as [Doctors City],
		CONVERT(VARCHAR(MAX), [Doctors_Name])			   as [Doctors Name],
		CONVERT(VARCHAR(MAX), [Doctors_Phone_#])		   as [Doctors Phone #],
		CONVERT(VARCHAR(MAX), [Doctors_State])			   as [Doctors State],
		CONVERT(VARCHAR(MAX), [Doctors_Zipcode])		   as [Doctors Zipcode],
		CONVERT(VARCHAR(MAX), [Dosage_Amount])			   as [Dosage Amount],
		CONVERT(VARCHAR(MAX), [Dr_Referred])			   as [Dr Referred],
		CONVERT(VARCHAR(MAX), [Dr_performing_implant])	   as [Dr. performing implant?],
		CONVERT(VARCHAR(MAX), [Drink_Alcohol])			   as [Drink Alcohol?],
		CONVERT(VARCHAR(MAX), [Driving_Rec])			   as [Driving Rec],
		CONVERT(VARCHAR(MAX), [Drug_Name])				   as [Drug Name],
		CONVERT(VARCHAR(MAX), [Employed])				   as [Employed],
		CONVERT(VARCHAR(MAX), [Employed])				   as [Employed?],
		CONVERT(VARCHAR(MAX), [Employer])				   as [Employer],
		CONVERT(VARCHAR(MAX), [Employer_Address])		   as [Employer Address],
		CONVERT(VARCHAR(MAX), [Employer_City])			   as [Employer City],
		CONVERT(VARCHAR(MAX), [Employer_Phone])			   as [Employer Phone],
		CONVERT(VARCHAR(MAX), [Employer_State])			   as [Employer State],
		CONVERT(VARCHAR(MAX), [Employers_Address])		   as [Employers Address],
		CONVERT(VARCHAR(MAX), [Ended_Vioxx])			   as [Ended Vioxx],
		CONVERT(VARCHAR(MAX), [Full_hearing_loss])		   as [Full hearing loss?],
		CONVERT(VARCHAR(MAX), [Guardian])				   as [Guardian],
		CONVERT(VARCHAR(MAX), [Heart_Attack])			   as [Heart Attack?],
		CONVERT(VARCHAR(MAX), [Height])					   as [Height],
		CONVERT(VARCHAR(MAX), [High_Cholesterol])		   as [High Cholesterol],
		CONVERT(VARCHAR(MAX), [How_Often])				   as [How Often?],
		CONVERT(VARCHAR(MAX), [Ime])					   as [Ime],
		CONVERT(VARCHAR(MAX), [In_the_last_5_yrs])		   as [In the last 5 yrs],
		CONVERT(VARCHAR(MAX), [Injured])				   as [Injured],
		CONVERT(VARCHAR(MAX), [Injuries_related_to_drug])  as [Injuries related to drug?],
		CONVERT(VARCHAR(MAX), [Kidney_Problems])		   as [Kidney Problems?],
		CONVERT(VARCHAR(MAX), [Kinship])				   as [Kinship],
		CONVERT(VARCHAR(MAX), [License])				   as [License],
		CONVERT(VARCHAR(MAX), [License_No])				   as [License No],
		CONVERT(VARCHAR(MAX), [Light_Duty])				   as [Light Duty],
		CONVERT(VARCHAR(MAX), [Location])				   as [Location],
		CONVERT(VARCHAR(MAX), [Location_of_removal])	   as [Location of removal?],
		CONVERT(VARCHAR(MAX), [Marital_Stat])			   as [Marital Stat],
		CONVERT(VARCHAR(MAX), [Married])				   as [Married],
		CONVERT(VARCHAR(MAX), [Married])				   as [Married?],
		CONVERT(VARCHAR(MAX), [Name_of_Cholesterol_Meds])  as [Name of Cholesterol Meds],
		CONVERT(VARCHAR(MAX), [Name_of_Prescribing_Dr])	   as [Name of Prescribing Dr.],
		CONVERT(VARCHAR(MAX), [No_In_Veh])				   as [No. In Veh],
		CONVERT(VARCHAR(MAX), [Notes])					   as [Notes],
		CONVERT(VARCHAR(MAX), [Num_In_Veh])				   as [Num In Veh],
		CONVERT(VARCHAR(MAX), [Other_Claims])			   as [Other Claims],
		CONVERT(VARCHAR(MAX), [Other_Meds_Taken_w])		   as [Other Meds Taken w/],
		CONVERT(VARCHAR(MAX), [Other_Meds_taken_wVioxx])   as [Other Meds taken w/Vioxx],
		CONVERT(VARCHAR(MAX), [Other_pharmacies_used])	   as [Other pharmacies used],
		CONVERT(VARCHAR(MAX), [Other_Side_Effects])		   as [Other Side Effects],
		CONVERT(VARCHAR(MAX), [Partial_hearing_loss])	   as [Partial hearing loss?],
		CONVERT(VARCHAR(MAX), [Past_Defects])			   as [Past Defects],
		CONVERT(VARCHAR(MAX), [Permission])				   as [Permission],
		CONVERT(VARCHAR(MAX), [Personal_Bio])			   as [Personal Bio],
		CONVERT(VARCHAR(MAX), [Pharmacy_Address])		   as [Pharmacy Address],
		CONVERT(VARCHAR(MAX), [Pharmacy_City])			   as [Pharmacy City],
		CONVERT(VARCHAR(MAX), [Pharmacy_Name])			   as [Pharmacy Name],
		CONVERT(VARCHAR(MAX), [Pharmacy_State])			   as [Pharmacy State],
		CONVERT(VARCHAR(MAX), [Pharmacy_to_fill_prescrip]) as [Pharmacy to fill prescrip],
		CONVERT(VARCHAR(MAX), [Photo_Description])		   as [Photo Description],
		CONVERT(VARCHAR(MAX), [Prescribing_Dr_Name])	   as [Prescribing Dr. Name],
		CONVERT(VARCHAR(MAX), [Prescribing_dr_practice])   as [Prescribing dr. practice],
		CONVERT(VARCHAR(MAX), [Prev_Claims])			   as [Prev. Claims],
		CONVERT(VARCHAR(MAX), [Prior_Attorney])			   as [Prior Attorney],
		CONVERT(VARCHAR(MAX), [Prior_Atty])				   as [Prior Atty],
		CONVERT(VARCHAR(MAX), [Prior_Claim])			   as [Prior Claim],
		CONVERT(VARCHAR(MAX), [Prior_Claims])			   as [Prior Claims],
		CONVERT(VARCHAR(MAX), [Prior_Health_Issues])	   as [Prior Health Issues],
		CONVERT(VARCHAR(MAX), [Prior_Rating])			   as [Prior Rating],
		CONVERT(VARCHAR(MAX), [Prod_Avail])				   as [Prod Avail],
		CONVERT(VARCHAR(MAX), [Prop_Dmg_$])				   as [Prop Dmg $],
		CONVERT(VARCHAR(MAX), [Providers])				   as [Providers:],
		CONVERT(VARCHAR(MAX), [PTSD])					   as [PTSD?],
		CONVERT(VARCHAR(MAX), [Reason_for_ESSURE])		   as [Reason for ESSURE?],
		CONVERT(VARCHAR(MAX), [Reason_for_Rx])			   as [Reason for Rx],
		CONVERT(VARCHAR(MAX), [Reason_for_SS_Disability])  as [Reason for SS Disability],
		CONVERT(VARCHAR(MAX), [Reasons_for_Truvada])	   as [Reasons for Truvada],
		CONVERT(VARCHAR(MAX), [Related_to_Anyone])		   as [Related to Anyone?],
		CONVERT(VARCHAR(MAX), [Relation])				   as [Relation],
		CONVERT(VARCHAR(MAX), [Relationship])			   as [Relationship],
		CONVERT(VARCHAR(MAX), [Reported])				   as [Reported],
		CONVERT(VARCHAR(MAX), [Spouse])					   as [Spouse],
		CONVERT(VARCHAR(MAX), [Spouse_Name])			   as [Spouse Name],
		CONVERT(VARCHAR(MAX), [SS_Disability])			   as [SS Disability],
		CONVERT(VARCHAR(MAX), [SS_Disability_Date])		   as [SS Disability Date],
		CONVERT(VARCHAR(MAX), [SS_Disability_End_Date])	   as [SS Disability End Date],
		CONVERT(VARCHAR(MAX), [Started_Vioxx])			   as [Started Vioxx],
		CONVERT(VARCHAR(MAX), [State_of_prescription])	   as [State of prescription],
		CONVERT(VARCHAR(MAX), [Statement])				   as [Statement],
		CONVERT(VARCHAR(MAX), [Stmt_At_Scn])			   as [Stmt At Scn],
		CONVERT(VARCHAR(MAX), [Stroke])					   as [Stroke],
		CONVERT(VARCHAR(MAX), [Supervisor])				   as [Supervisor],
		CONVERT(VARCHAR(MAX), [Symptoms_from_drug])		   as [Symptoms from drug?],
		CONVERT(VARCHAR(MAX), [Symptoms_from_implant])	   as [Symptoms from implant?],
		CONVERT(VARCHAR(MAX), [Tag])					   as [Tag],
		CONVERT(VARCHAR(MAX), [TBI])					   as [TBI?],
		CONVERT(VARCHAR(MAX), [Third_Party])			   as [Third Party],
		CONVERT(VARCHAR(MAX), [Tinnitus])				   as [Tinnitus?],
		CONVERT(VARCHAR(MAX), [Title])					   as [Title],
		CONVERT(VARCHAR(MAX), [To_Whom])				   as [To Whom],
		CONVERT(VARCHAR(MAX), [Type_Defect])			   as [Type Defect],
		CONVERT(VARCHAR(MAX), [Type_of_Cancer])			   as [Type of Cancer?],
		CONVERT(VARCHAR(MAX), [Type_Of_Case])			   as [Type Of Case],
		CONVERT(VARCHAR(MAX), [Type_Of_Veh])			   as [Type Of Veh],
		CONVERT(VARCHAR(MAX), [Vantage_Point])			   as [Vantage Point],
		CONVERT(VARCHAR(MAX), [Veh_Owner])				   as [Veh Owner],
		CONVERT(VARCHAR(MAX), [Veh_Owner])				   as [Veh. Owner],
		CONVERT(VARCHAR(MAX), [Vehic_Owner])			   as [Vehic Owner],
		CONVERT(VARCHAR(MAX), [Vehicl_Owner])			   as [Vehicl Owner],
		CONVERT(VARCHAR(MAX), [Viewpoint])				   as [Viewpoint],
		CONVERT(VARCHAR(MAX), [What_warning_were_given])   as [What warning were given?],
		CONVERT(VARCHAR(MAX), [When])					   as [When],
		CONVERT(VARCHAR(MAX), [When_Apptd])				   as [When Apptd],
		CONVERT(VARCHAR(MAX), [Where_Seated])			   as [Where Seated],
		CONVERT(VARCHAR(MAX), [Zip])					   as [Zip]
	--select *
	from [JohnSalazar_Needles]..user_party_data ud
	join sma_TRN_Cases cas
		on cas.cassCaseNumber = CONVERT(VARCHAR, ud.case_id)
) pv
unpivot (FieldVal for FieldTitle in ([Acc. Details],
[Activity],
[Alcohol Comments],
[Alcohol Involved],
[Any Dosage Change],
[Availability],
[Bias],
[Callers Name],
[Cancer?],
[Case No],
[Charges],
[Citation Issued?],
[Citations],
[City/State/Zip],
[County],
[Credibility],
[Crosswalk],
[Date of 1st prescription],
[Date of Death],
[Date of Heart Attack],
[Date of Implant?],
[Date of removal?],
[Date of Stroke],
[Death Cause],
[Death Date],
[Defenses],
[Deployment location],
[Die?],
[Do We Rep Pd],
[Do You Smoke?],
[Doctors Address],
[Doctors City],
[Doctors Name],
[Doctors Phone #],
[Doctors State],
[Doctors Zipcode],
[Dosage Amount],
[Dr Referred],
[Dr. performing implant?],
[Drink Alcohol?],
[Driving Rec],
[Drug Name],
[Employed],
[Employed?],
[Employer],
[Employer Address],
[Employer City],
[Employer Phone],
[Employer State],
[Employers Address],
[Ended Vioxx],
[Full hearing loss?],
[Guardian],
[Heart Attack?],
[Height],
[High Cholesterol],
[How Often?],
[Ime],
[In the last 5 yrs],
[Injured],
[Injuries related to drug?],
[Kidney Problems?],
[Kinship],
[License],
[License No],
[Light Duty],
[Location],
[Location of removal?],
[Marital Stat],
[Married],
[Married?],
[Name of Cholesterol Meds],
[Name of Prescribing Dr.],
[No. In Veh],
[Notes],
[Num In Veh],
[Other Claims],
[Other Meds Taken w/],
[Other Meds taken w/Vioxx],
[Other pharmacies used],
[Other Side Effects],
[Partial hearing loss?],
[Past Defects],
[Permission],
[Personal Bio],
[Pharmacy Address],
[Pharmacy City],
[Pharmacy Name],
[Pharmacy State],
[Pharmacy to fill prescrip],
[Photo Description],
[Prescribing Dr. Name],
[Prescribing dr. practice],
[Prev. Claims],
[Prior Attorney],
[Prior Atty],
[Prior Claim],
[Prior Claims],
[Prior Health Issues],
[Prior Rating],
[Prod Avail],
[Prop Dmg $],
[Providers:],
[PTSD?],
[Reason for ESSURE?],
[Reason for Rx],
[Reason for SS Disability],
[Reasons for Truvada],
[Related to Anyone?],
[Relation],
[Relationship],
[Reported],
[Spouse],
[Spouse Name],
[SS Disability],
[SS Disability Date],
[SS Disability End Date],
[Started Vioxx],
[State of prescription],
[Statement],
[Stmt At Scn],
[Stroke],
[Supervisor],
[Symptoms from drug?],
[Symptoms from implant?],
[Tag],
[TBI?],
[Third Party],
[Tinnitus?],
[Title],
[To Whom],
[Type Defect],
[Type of Cancer?],
[Type Of Case],
[Type Of Veh],
[Vantage Point],
[Veh Owner],
[Veh. Owner],
[Vehic Owner],
[Vehicl Owner],
[Viewpoint],
[What warning were given?],
[When],
[When Apptd],
[Where Seated],
[Zip]
)) as unpvt

;
go

/* ####################################
1.0 -- Plaintiff UDF
*/

-- 1.1 // Create the Plaintiff UDF Definitions
alter table [sma_MST_UDFDefinition] disable trigger all
go

insert into [sma_MST_UDFDefinition]
	(
	[udfsUDFCtg], [udfnRelatedPK], [udfsUDFName], [udfsScreenName], [udfsType], [udfsLength], [udfbIsActive], [udfshortName], [udfsNewValues], [udfnSortOrder]
	)
	select distinct
		'C'										   as [udfsUDFCtg],
		CST.cstnCaseTypeID						   as [udfnRelatedPK],
		M.field_title							   as [udfsUDFName],
		'Plaintiff'								   as [udfsScreenName],
		ucf.UDFType								   as [udfsType],
		ucf.field_len							   as [udfsLength],
		1										   as [udfbIsActive],
		'user_party_data' + ucf.column_name		   as [udfshortName],
		ucf.dropdownValues						   as [udfsNewValues],
		DENSE_RANK() over (order by M.field_title) as udfnSortOrder
	from [sma_MST_CaseType] CST
	join CaseTypeMixture mix
		on mix.[SmartAdvocate Case Type] = cst.cstsType
	join [JohnSalazar_Needles].[dbo].[user_party_matter] M
		on M.mattercode = mix.matcode
			and M.field_type <> 'label'
	join (
		select distinct
			fieldTitle
		from PlaintiffUDF
	) vd
		on vd.FieldTitle = M.field_title
	join [NeedlesUserFields] ucf
		on ucf.field_num = M.ref_num
	--LEFT JOIN	(
	--				SELECT DISTINCT table_Name, column_name
	--				FROM [JohnSalazar_Needles].[dbo].[document_merge_params]
	--				WHERE table_Name = 'user_case_data'
	--			) dmp
	--ON dmp.column_name = ucf.field_Title
	left join [sma_MST_UDFDefinition] def
		on def.[udfnRelatedPK] = cst.cstnCaseTypeID
			and def.[udfsUDFName] = M.field_title
			and def.[udfsScreenName] = 'Plaintiff'
			and def.[udfsType] = ucf.UDFType
			and def.udfnUDFID is null
	order by M.field_title
go

alter table [sma_MST_UDFDefinition] enable trigger all
go

-- 1.2 // Insert the Plaintiff UDF Values
-- [sma_trn_UDFValues].[udvnRelatedID] -> References Case ID 
-- [sma_trn_UDFValues].[udvnSubRelatedID] -> References the Plaintiff or Defendant ID
alter table sma_trn_udfvalues disable trigger all
go

insert into [sma_TRN_UDFValues]
	(
	[udvnUDFID], [udvsScreenName], [udvsUDFCtg], [udvnRelatedID], [udvnSubRelatedID], [udvsUDFValue], [udvnRecUserID], [udvdDtCreated], [udvnModifyUserID], [udvdDtModified], [udvnLevelNo]
	)
	select
		def.udfnUDFID		as [udvnUDFID],
		'Plaintiff'			as [udvsScreenName],
		'C'					as [udvsUDFCtg],
		udf.casnCaseID		as [udvnRelatedID],		-- case ID
		pln.plnnPlaintiffID as [udvnSubRelatedID],	-- plaintiff ID
		udf.FieldVal		as [udvsUDFValue],
		368					as [udvnRecUserID],
		GETDATE()			as [udvdDtCreated],
		null				as [udvnModifyUserID],
		null				as [udvdDtModified],
		null				as [udvnLevelNo]
	--select *
	from PlaintiffUDF udf
	-- get PlaintiffID for [udvnSubRelatedID]
	--join sma_TRN_Cases cas
	--	on cas.casnCaseID = udf.casnCaseID
	--join IndvOrgContacts_Indexed ioc
	--	on udf.party_id = ioc.SAGA
	join sma_TRN_Plaintiff pln
		on pln.plnnCaseID = udf.casnCaseID

	-- get caseID for [udvnRelatedID]
	--join [JohnSalazar_Needles].[dbo].user_case_data cd
	--	on udf.party_id = pd.party_id
	--join sma_TRN_Cases cas
	--	on convert(varchar, pd.case_id) = cas.cassCaseNumber

	-- only update Plaintiff UDF Definitions
	left join sma_MST_UDFDefinition def
		on def.udfnRelatedPK = udf.casnOrgCaseTypeID
			and def.udfsUDFName = FieldTitle
			and def.udfsScreenName = 'Plaintiff'
go

alter table sma_trn_udfvalues enable trigger all
go