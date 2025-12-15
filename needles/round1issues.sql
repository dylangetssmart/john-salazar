select upd.case_id, upd.Prior_Medical_History FROM JohnSalazar_Needles..user_party_data upd
SELECT injur FROM JohnSalazar_Needles..user_tab10_data utd
SELECT * FROM JohnSalazar_SA..sma_MST_UDFDefinition smu where smu.udfsScreenName like '%incident%'

SELECT stc.casnCaseID, stc.cassCaseNumber, stc.casnOrgCaseTypeID FROM JohnSalazar_SA..sma_TRN_Cases stc where stc.casnCaseID = 179
-- 1573
SELECT * FROM JohnSalazar_SA..sma_MST_UDFDefinition smu where smu.udfsScreenName like '%plaintiff%' order by smu.udfsUDFName
SELECT * FROM JohnSalazar_SA..sma_TRN_UDFValues stu where stu.udvnUDFID = 24176

SELECT * FROM JohnSalazar_Needles..user_case_data ucd where casenum=215400
SELECT * FROM JohnSalazar_Needles..cases c where c.casenum=215400
SELECT c.intake_date, c.intake_time, c.intake_staff FROM JohnSalazar_Needles..cases c where c.casenum=215400

SELECT * FROM JohnSalazar_Needles..user_case_matter ucm

select * from [JohnSalazar_Needles].INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='cases' order by COLUMN_NAME
select * from [JohnSalazar_Needles].INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='user_case_data' order by COLUMN_NAME

--215400
SELECT * FROM JohnSalazar_sa..sma_TRN_Hospitals where hosnCaseID= 15402 order by hosnContactID

SELECT utd.*, utn.*, n.first_name, n.last_long_name, ioci.*
FROM JohnSalazar_Needles..user_tab2_data utd
join JohnSalazar_Needles..user_tab2_name utn
on utn.case_id = utd.case_id and utn.tab_id = utd.tab_id
join JohnSalazar_Needles..names n
on n.names_id = utn.user_name
join JohnSalazar_SA..IndvOrgContacts_Indexed ioci on ioci.SAGA = utn.user_name
where utd.case_id=215400
order by utd.name

SELECT * FROM JohnSalazar_Needles..user_tab2_data
SELECT * FROM JohnSalazar_Needles..user_tab2_name utn
SELECT * FROM JohnSalazar_SA..sma_MST_Users smu

delete from JohnSalazar_sa..sma_TRN_Hospitals where hosnCaseID= 15402 

SELECT * FROM JohnSalazar_Needles..user_case_data ucd
SELECT * FROM JohnSalazar_Needles..user_case_name ucn

delete from JohnSalazar_SA..sma_MST_UDFDefinition
delete from JohnSalazar_SA..sma_TRN_UDFValues


SELECT * FROM IndvOrgContacts_Indexed ioci where cid=107845
SELECT * FROM JohnSalazar_Needles..user_party_data upd where upd.case_id=215400
SELECT * FROM JohnSalazar_Needles..user_party_matter upm where upm.field_title = 'marital status'
SELECT * FROM JohnSalazar_Needles..NeedlesUserFields nuf where nuf.field_title = 'marital status'


SELECT * FROM JohnSalazar_Needles..cases where casenum=215400
SELECT * FROM JohnSalazar_Needles..names n where n.names_id=124451
SELECT * FROM JohnSalazar_Needles..party p where p.case_id=215400
SELECT * FROM JohnSalazar_Needles..party p where p.case_id=215400


------- courts
SELECT * FROM JohnSalazar_SA..sma_TRN_Courts stc where stc.crtnCaseID=15402
SELECT * FROM JohnSalazar_SA..sma_TRN_CourtDocket stcd where stcd.crdnCourtsID=2350

SELECT c.case_date_3
FROM JohnSalazar_Needles..cases c
join JohnSalazar_Needles..matter m on m.matcode = c.matcode
where casenum=215400

SELECT * FROM JohnSalazar_Needles..matter m

SELECT ucd.How_Resolved, ucd.County_of_Suit, ucd.County_Ct_No FROM JohnSalazar_Needles..user_case_data ucd





-- case status / class
SELECT casenum, class, cl.*
FROM JohnSalazar_Needles..cases c
join JohnSalazar_Needles..class cl on c.class = cl.classcode
where casenum=215400

SELECT * FROM JohnSalazar_Needles..cases where casenum = 216477 