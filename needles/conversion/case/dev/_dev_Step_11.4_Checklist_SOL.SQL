

use SANeedlesHalperin

/*
alter table [SANeedlesHalperin].[dbo].[sma_TRN_SOLs] disable trigger all
delete [SANeedlesHalperin].[dbo].[sma_TRN_SOLs]
DBCC CHECKIDENT ('[SANeedlesHalperin].[dbo].[sma_TRN_SOLs]', RESEED, 0);
alter table [SANeedlesHalperin].[dbo].[sma_TRN_SOLs] enable trigger all
*/

---(1)---SOL for Defendant ---
alter table [sma_TRN_SOLs] disable trigger all
GO
INSERT INTO [sma_TRN_SOLs] (
	[solnCaseID],
	[solnSOLTypeID],
	[soldSOLDate],
	[soldDateComplied],
	[soldSnCFilingDate],
	[soldServiceDate],
	[solnDefendentID],
	[soldToProcessServerDt],
	[soldRcvdDate],
	[solsType],
     [solsComments],
     [solnRecUserID],
     [soldDtCreated],
     [solnModifyUserID],
     [soldDtModified]
)
SELECT DISTINCT
    CAS.casnCaseID		as [solnCaseID],
    S.sldnSOLDetID		as [solnSOLTypeID],
    case when ( CKL.due_date not between '1900-01-01' and '2079-12-31' )  then null else CKL.due_date end as [soldSOLDate],
    case when CKL.status='Done' then getdate()
	   else null
    end					as [soldDateComplied],
    null			     as [soldSnCFilingDate],
    null			     as [soldServiceDate],
    D.defnDefendentID	as [solnDefendentID],
    null				as [soldToProcessServerDt],
    null			     as [soldRcvdDate],
    'D'			     as [solsType],
    isnull('description : ' + nullif(CKL.[description],'') + CHAR(13) ,'') +
    isnull('staff assigned : ' + nullif(CKL.[staff_assigned],'') + CHAR(13) ,'') 
    				     as [solsComments],
    (select usrnUserID from sma_MST_Users where saga=CKL.staff_assigned)			     
				     as [solnRecUserID],
    getdate()		     as [soldDtCreated],
    null			     as [solnModifyUserID],
    null			     as [soldDtModified]
  FROM [sma_TRN_Defendants] D
  JOIN [sma_TRN_Cases] CAS on CAS.casnCaseID = D.defnCaseID and D.defbIsPrimary=1
  JOIN [sma_MST_SOLDetails] S on S.sldnCaseTypeID=CAS.casnOrgCaseTypeID and S.sldnStateID=CAS.casnStateID and S.sldnDefRole=D.defnSubRole
  JOIN [NeedlesHalperin].[dbo].[case_checklist] CKL on CKL.case_id=CAS.cassCaseNumber
  WHERE CKL.due_date between '1900-01-01' and '2079-06-06'
  and (select lim FROM [NeedlesHalperin].[dbo].[checklist_dir] where code=CKL.code and matcode=CKL.matcode)='Y'
  --and CKL.[status]='Done' ---> Jay want this
GO

alter table [sma_TRN_SOLs] enable trigger all
GO

/*
---------------------
select count(*)
  from [SANeedlesHalperin].[dbo].[sma_TRN_Defendants] D
  inner join [SANeedlesHalperin].[dbo].[sma_TRN_Cases] CAS on CAS.casnCaseID = D.defnCaseID and D.defbIsPrimary=1
  inner join [SANeedlesHalperin].[dbo].[sma_MST_SOLDetails] S on S.sldnCaseTypeID=CAS.casnOrgCaseTypeID and S.sldnStateID=CAS.casnStateID and S.sldnDefRole=D.defnSubRole
  inner join [NeedlesHalperin].[dbo].[case_checklist] CKL on CKL.case_id=CAS.cassCaseNumber
  inner join [NeedlesHalperin].[dbo].[checklist_dir] DIR on DIR.matcode=CKL.matcode and DIR.code=CKL.code and DIR.lim='Y'
  where CKL.due_date between '1900-01-01' and '2079-06-06'



use NeedlesHalperin

select A.*
from 
(
select 
    C.casenum,
    C.lim_date,
    CKL.status,
    CKL.due_date,
    (select min(CKL.due_date) from [dbo].[case_checklist] CKL where C.casenum=CKL.case_id and DIR.matcode=CKL.matcode and DIR.code=CKL.code and DIR.lim='Y' and CKL.status='Open' ) as min_due_date,
    (select max(CKL.due_date) from [dbo].[case_checklist] CKL where C.casenum=CKL.case_id and DIR.matcode=CKL.matcode and DIR.code=CKL.code and DIR.lim='Y' and CKL.status='Open') as max_due_date
from [dbo].[case_checklist] CKL
inner join [dbo].[cases] C on C.casenum=CKL.case_id
inner join [dbo].[checklist_dir] DIR on DIR.matcode=CKL.matcode and DIR.code=CKL.code and DIR.lim='Y'
where CKL.status='Open'
--where C.lim_date <> CKL.due_date --( select min(due_date) from [dbo].[case_checklist] where case_id=C.casenum )
) A
where A.lim_date<>A.min_due_date


select *
from [dbo].[checklist_dir] DIR 
where DIR.lim='Y'


use NeedlesHalperin
select C.lim_date,CKL.due_date,CKL.case_id,CKL.*
from [dbo].[case_checklist] CKL
inner join [dbo].[cases] C on C.casenum=CKL.case_id
inner join [dbo].[checklist_dir] DIR on DIR.matcode=CKL.matcode and DIR.code=CKL.code and DIR.lim='Y'
where case_id=200087

select CKL.case_id,count(CKL.case_id)
from [dbo].[case_checklist] CKL
inner join [dbo].[cases] C on C.casenum=CKL.case_id
inner join [dbo].[checklist_dir] DIR on DIR.matcode=CKL.matcode and DIR.code=CKL.code and DIR.lim='Y'
group by CKL.case_id
having count(CKL.case_id)>1
*/
