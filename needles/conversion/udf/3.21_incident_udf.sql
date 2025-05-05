use [JohnSalazar_SA]
go

----------------------------
--PIVOT TABLE CONSTRUCTION
----------------------------
/*
select m.*
--distinct m.field_Title, column_name, 'convert(varchar(max), ['+ column_Name + '] ) as ['+ m.field_title +'], ', '['+m.field_title+'],'
FROM [JohnSalazar_Needles].[dbo].[user_case_matter] M 
inner join [JohnSalazar_Needles].[dbo].[user_case_fields] F on F.field_title=M.field_title
where m.field_Type <> 'label'
*/

if exists (
		select
			*
		from sys.tables
		where name = 'IncidentUDF'
			and TYPE = 'U'
	)
begin
	drop table IncidentUDF
end
----------------------
--PIVOT TABLE
----------------------
select
	casncaseid,
	casnorgcasetypeID,
	fieldTitle,
	FieldVal
into IncidentUDF
from (
	select
		cas.casnCaseID,
		cas.CasnOrgCaseTypeID,
		CONVERT(VARCHAR(MAX), [County]) as [County],
		CONVERT(VARCHAR(MAX), [State]) as [State],
		CONVERT(VARCHAR(MAX), [Time]) as [Time],
		CONVERT(VARCHAR(MAX), [FR_10]) as [Fr 10],
		CONVERT(VARCHAR(MAX), [TYPE_OF_COL]) as [Type Of Col],
		CONVERT(VARCHAR(MAX), [Witnesses]) as [Witnesses],
		CONVERT(VARCHAR(MAX), [PHOTOS_TKN]) as [Photos Tkn],
		CONVERT(VARCHAR(MAX), [NO_OF_VEH]) as [No. Of Veh],
		CONVERT(VARCHAR(MAX), [Punitives]) as [Punitives],
		CONVERT(VARCHAR(MAX), [PROP_DMG_$]) as [Prop Dmg $],
		CONVERT(VARCHAR(MAX), [CLIENT_NEG]) as [Client Neg],
		CONVERT(VARCHAR(MAX), [BODY_PART]) as [Body Part],
		CONVERT(VARCHAR(MAX), [Scarring]) as [Scarring],
		CONVERT(VARCHAR(MAX), [Rating]) as [Rating],
		CONVERT(VARCHAR(MAX), [TTTP_PAID]) as [Tt/Tp Paid],
		CONVERT(VARCHAR(MAX), [Coverage]) as [Coverage],
		CONVERT(VARCHAR(MAX), [COMP_RATE]) as [Comp Rate],
		CONVERT(VARCHAR(MAX), [Accepted]) as [Accepted],
		CONVERT(VARCHAR(MAX), [Reported]) as [Reported],
		CONVERT(VARCHAR(MAX), [Initials]) as [Initials],
		CONVERT(VARCHAR(MAX), [POLICE_RPT]) as [Police Rpt],
		CONVERT(VARCHAR(MAX), [Photos]) as [Photos],
		CONVERT(VARCHAR(MAX), [PROP_DAMG_$]) as [Prop Damg $],
		CONVERT(VARCHAR(MAX), [Alcohol]) as [Alcohol],
		CONVERT(VARCHAR(MAX), [Commercial]) as [Commercial],
		CONVERT(VARCHAR(MAX), [PRIOR_NOTICE]) as [Prior Notice],
		CONVERT(VARCHAR(MAX), [POLICE_REP]) as [Police Rep],
		CONVERT(VARCHAR(MAX), [Etoh]) as [Etoh],
		CONVERT(VARCHAR(MAX), [TYPE_OF_COLL]) as [Type Of Coll],
		CONVERT(VARCHAR(MAX), [NUM_OF_VEH]) as [Num Of Veh],
		CONVERT(VARCHAR(MAX), [Illuminatn]) as [Illuminatn],
		CONVERT(VARCHAR(MAX), [PR_ATTACKS]) as [Pr. Attacks],
		CONVERT(VARCHAR(MAX), [Destroyed]) as [Destroyed],
		CONVERT(VARCHAR(MAX), [Type]) as [Type],
		CONVERT(VARCHAR(MAX), [Experts]) as [Experts],
		CONVERT(VARCHAR(MAX), [STYLE_OF_CASE]) as [Style Of Case],
		CONVERT(VARCHAR(MAX), [TYPE_OF_SERVICE]) as [Type Of Service],
		CONVERT(VARCHAR(MAX), [Type_of_Accident]) as [Type of Accident],
		CONVERT(VARCHAR(MAX), [Type_of_Weather]) as [Type of Weather],
		CONVERT(VARCHAR(MAX), [Citation_Issue]) as [Citation Issue],
		CONVERT(VARCHAR(MAX), [Jurisdiction]) as [Jurisdiction],
		CONVERT(VARCHAR(MAX), [Location]) as [Location],
		CONVERT(VARCHAR(MAX), [Citation_Issued]) as [Citation Issued?],
		CONVERT(VARCHAR(MAX), [Citations]) as [Citations],
		CONVERT(VARCHAR(MAX), [Photo_Description]) as [Photo Description],
		CONVERT(VARCHAR(MAX), [Alcohol_Involved]) as [Alcohol Involved],
		CONVERT(VARCHAR(MAX), [Alcohol_Comments]) as [Alcohol Comments],
		CONVERT(VARCHAR(MAX), [Relationship]) as [Relationship],
		CONVERT(VARCHAR(MAX), [Prior_Claims]) as [Prior Claims],
		CONVERT(VARCHAR(MAX), [Type_of_Dog]) as [Type of Dog],
		CONVERT(VARCHAR(MAX), [Rcvd_Form_20]) as [Rcvd Form 20]
	from [JohnSalazar_Needles]..user_case_data ud
	join sma_TRN_Cases cas
		on cas.cassCaseNumber = CONVERT(VARCHAR, ud.casenum)
) pv
unpivot (
FieldVal for FieldTitle in (
[County],
[State],
[Time],
[Fr 10],
[Type Of Col],
[Witnesses],
[Photos Tkn],
[No. Of Veh],
[Punitives],
[Prop Dmg $],
[Client Neg],
[Body Part],
[Scarring],
[Rating],
[Tt/Tp Paid],
[Coverage],
[Comp Rate],
[Accepted],
[Reported],
[Initials],
[Police Rpt],
[Photos],
[Prop Damg $],
[Alcohol],
[Commercial],
[Prior Notice],
[Police Rep],
[Etoh],
[Type Of Coll],
[Num Of Veh],
[Illuminatn],
[Pr. Attacks],
[Destroyed],
[Type],
[Experts],
[Style Of Case],
[Type Of Service],
[Type of Accident],
[Type of Weather],
[Citation Issue],
[Jurisdiction],
[Location],
[Citation Issued?],
[Citations],
[Photo Description],
[Alcohol Involved],
[Alcohol Comments],
[Relationship],
[Prior Claims],
[Type of Dog],
[Rcvd Form 20]
)
) as unpvt;


----------------------------
--UDF DEFINITION
----------------------------
insert into [sma_MST_UDFDefinition]
	(
	[udfsUDFCtg], [udfnRelatedPK], [udfsUDFName], [udfsScreenName], [udfsType], [udfsLength], [udfbIsActive], [UdfShortName], [udfsNewValues], [udfnSortOrder]
	)
	select distinct
		'I'										   as [udfsudfctg],
		cg.IncidentTypeID						   as [udfnrelatedpk],
		m.field_title							   as [udfsudfname],
		'Incident Wizard'						   as [udfsscreenname],
		ucf.UDFType								   as [udfstype],
		ucf.field_len							   as [udfslength],
		1										   as [udfbisactive],
		'user_Case_Data' + ucf.column_name		   as [udfshortname],
		ucf.DropDownValues						   as [udfsnewvalues],
		DENSE_RANK() over (order by m.field_title) as udfnsortorder
	from [sma_MST_CaseType] cst
	join CaseTypeMixture mix
		on mix.[SmartAdvocate Case Type] = cst.cstsType
	join sma_MST_CaseGroup cg
		on cgpnCaseGroupID = cst.cstnGroupID
	join [JohnSalazar_Needles].[dbo].[user_case_matter] m
		on m.mattercode = mix.matcode
			and m.field_type <> 'label'
	join (
		select distinct
			fieldTitle
		from IncidentUDF
	) vd
		on vd.FieldTitle = m.field_title
	--JOIN [JohnSalazar_Needles].[dbo].[user_Case_Fields] ucf on m.ref_num = ucf.field_num
	join NeedlesUserFields ucf
		on ucf.field_num = m.ref_num
	--left join (
	--	select distinct
	--		table_name,
	--		column_name
	--	from [JohnSalazar_Needles].[dbo].[document_merge_params]
	--	where table_name = 'user_Case_Data'
	--) dmp
	--	on dmp.column_name = ucf.field_title
	left join [sma_MST_UDFDefinition] def
		on def.[udfnRelatedPK] = cg.IncidentTypeID		-- for Incidents, the�[sma_mst_UDFDefinition].[udfnRelatedPK]�references the�[sma_mst_casegroup].[IncidentTypeID]
			and def.[udfsudfname] = m.field_title
			and def.[udfsscreenname] = 'Incident Wizard'
			and udfstype = ucf.UDFType
	--where m.field_title <> 'Location'
	where def.udfnUDFID is null
	--and mix.matcode in ('CLW')
	order by m.field_title

--select * From [JohnSalazar_Needles]..[user_case_matter]

--------------------------------------
--UDF VALUES
--------------------------------------
alter table sma_trn_udfvalues disable trigger all
go

insert into [sma_TRN_UDFValues]
	(
	[udvnUDFID], [udvsScreenName], [udvsUDFCtg], [udvnRelatedID], [udvnSubRelatedID], [udvsUDFValue], [udvnRecUserID], [udvdDtCreated], [udvnModifyUserID], [udvdDtModified], [udvnLevelNo]
	)
	select --fieldtitle, udf.casnOrgCaseTypeID,
		def.udfnUDFID	  as [udvnudfid],
		'Incident Wizard' as [udvsscreenname],
		'I'				  as [udvsudfctg],
		casnCaseID		  as [udvnrelatedid],
		0				  as [udvnsubrelatedid],
		udf.FieldVal	  as [udvsudfvalue],
		368				  as [udvnrecuserid],
		GETDATE()		  as [udvddtcreated],
		null			  as [udvnmodifyuserid],
		null			  as [udvddtmodified],
		null			  as [udvnlevelno]
	--select *
	FROM IncidentUDF udf
	-- Link to CaseType to get CaseGroupID
	join sma_MST_CaseType ct
		on ct.cstnCaseTypeID = udf.casnOrgCaseTypeID
	-- Link to CaseGroup to get IncidentTypeID
	join sma_MST_CaseGroup cg
		on cg.cgpnCaseGroupID = ct.cstnGroupID
	left JOIN sma_MST_UDFDefinition def
	ON def.udfnRelatedPK = cg.IncidentTypeID
	AND def.udfsUDFName = FieldTitle
	AND def.udfsScreenName = 'Incident Wizard'

alter table sma_trn_udfvalues enable trigger all
go
