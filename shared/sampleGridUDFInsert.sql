

--sample table
/*
RowID,	CaseId,		LawFirm,	Name,			Date
1,		518155,		'PW',		'Test Name',	'9/1/2025'
2,		518155,		'SA',		'Test Test',	'9/9/2025'
3,		518155,		'Law Firm',	'John Smith',	'12/9/2024'
*/

drop table #UDFGridData
drop table #gridUDFPivot

SELECT * FROM JohnSalazar_SA..sma_TRN_Cases stc

select *
INTO #UDFGridData
from (
select 1 as RowID,	10920 as CaseId,'PW' as LawFirm,'Test Name' as [name],	'9/1/2025' as [date]
UNION SELECT 2,		10920,		'SA',		'Test Test',	'9/9/2025'
UNION SELECT 3,		10920,		'Law Firm',	'John Smith',	'12/9/2024' ) a

select * from #UDFGridData


----------------------
--PIVOT TABLE
----------------------
SELECT casncaseid, casnorgcasetypeID, RowID, fieldTitle, FieldVal
INTO #gridUDFPivot
FROM ( SELECT cas.casnCaseID, cas.CasnOrgCaseTypeID, RowID,
		convert(varchar(max), LawFirm ) as LawFirm,
		convert(varchar(max), [Name] ) as [Name],
		convert(varchar(max), [date] ) as [date]
	FROM #UDFGridData ls
	JOIN johnsalazar_sa..sma_TRN_Cases cas on ls.CaseId = cas.casnCaseID
) pv
UNPIVOT (FieldVal FOR FieldTitle IN ( LawFirm,[Name],[date])
) as unpvt
GO

select * from #gridUDFPivot
-------------------------------------
--CREATE UDF GRID DEFINTION
-------------------------------------
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
    p.casnOrgCaseTypeID		as [udfnRelatedPK],
    p.FieldTitle			as [udfsUDFName],   
    'UDFs Grid1'			as [udfsScreenName],
    'Text'					as [udfsType],
    200						as [udfsLength],
    1						as [udfbIsActive],
	''						as [udfshortName],
    null					as [udfsNewValues],
    DENSE_RANK() over( order by FieldTitle) as udfnSortOrder
--SELECT * 
FROM #gridUDFPivot p
LEFT JOIN sma_MST_UDFDefinition def
	on def.[udfsUDFName] = p.FieldTitle
	and def.[udfnRelatedPK] = p.casnOrgCaseTypeID
	and def.[udfsScreenName] = 'UDFs Grid1'
WHERE def.udfnUDFID is null
GO

----------------------------------
--INSERT INTO GRID UDF ROWS
----------------------------------
alter table sma_TRN_GridUdfsRows
add source_id varchar(255)

alter table sma_TRN_GridUdfsRows
add source_ref varchar(255)

INSERT INTO sma_TRN_GridUdfsRows (DtCreted, RecUserID, source_id, SOURCE_REF)
SELECT DISTINCT getdate(),669, RowID, 'TestSrc'
FROM #gridUDFPivot p 



------------------------------
--INSERT INTO UDF VALUES
------------------------------
alter table sma_trn_udfvalues disable trigger all
go
INSERT INTO [sma_TRN_UDFValues]
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
	  ,GridRowID
)
SELECT --fieldtitle, udf.casnOrgCaseTypeID,
	def.udfnUDFID		as [udvnUDFID],
	'UDFs Grid1'		as [udvsScreenName],
	'C'					as [udvsUDFCtg],
	casnCaseID			as [udvnRelatedID],
	null				as [udvnSubRelatedID],
	p.FieldVal			as [udvsUDFValue],
	368					as [udvnRecUserID],
	getdate()			as [udvdDtCreated],
	null				as [udvnModifyUserID],
	null				as [udvdDtModified],
	null				as [udvnLevelNo],
	r.ID				as GridRowID
--select *
FROM #gridUDFPivot p
JOIN sma_MST_UDFDefinition def
	on def.[udfsUDFName] = p.FieldTitle
	and def.[udfnRelatedPK] = p.casnOrgCaseTypeID
	and def.[udfsScreenName] = 'UDFs Grid1'
JOIN sma_TRN_GridUdfsRows r
	on r.source_ID =  p.RowID
	and r.source_ref = 'TestSrc'
GO

ALTER TABLE sma_trn_udfvalues ENABLE TRIGGER ALL
go