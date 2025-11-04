/* ######################################################################################
description:
steps:
	-
usage_instructions:
dependencies:
notes:
requires_mapping:
	- 
#########################################################################################
*/

use [JohnSalazar_SA]
go

set QUOTED_IDENTIFIER on
go

---(0)---
if exists (
		select
			*
		from sys.objects
		where name = 'TempCaseName'
			and type = 'U'
	)
begin
	drop table TempCaseName
end

select
	CAS.casnCaseID										  as CaseID,
	CAS.cassCaseName									  as CaseName,
	ISNULL(IOC.Name, '') + ' v. ' + ISNULL(IOCD.Name, '') as NewCaseName
into TempCaseName
from sma_TRN_Cases CAS
left join sma_TRN_Plaintiff T
	on T.plnnCaseID = CAS.casnCaseID
		and T.plnbIsPrimary = 1
left join (
	select
		cinnContactID					   as CID,
		cinnContactCtg					   as CTG,
		cinsLastName + ', ' + cinsFirstName as Name,
		saga							   as SAGA
	from [sma_MST_IndvContacts]
	--	SELECT cinnContactID as CID, cinnContactCtg as CTG, cinsFirstName + ' ' + cinsLastName as Name, saga as SAGA FROM [sma_MST_IndvContacts]  
	union
	select
		connContactID  as CID,
		connContactCtg as CTG,
		consName	   as Name,
		saga		   as SAGA
	from [sma_MST_OrgContacts]
) IOC
	on IOC.CID = T.plnnContactID
		and IOC.CTG = T.plnnContactCtg
left join sma_TRN_Defendants D
	on D.defnCaseID = CAS.casnCaseID
		and D.defbIsPrimary = 1
left join (
	select
		cinnContactID					   as CID,
		cinnContactCtg					   as CTG,
		cinsLastName + ', ' + cinsFirstName as Name,
		saga							   as SAGA
	from [sma_MST_IndvContacts]
	union
	select
		connContactID  as CID,
		connContactCtg as CTG,
		consName	   as Name,
		saga		   as SAGA
	from [sma_MST_OrgContacts]
) IOCD
	on IOCD.CID = D.defnContactID
		and IOCD.CTG = D.defnContactCtgID


---(1)---
alter table [sma_TRN_Cases] disable trigger all
go

update sma_TRN_Cases
set cassCaseName = A.NewCaseName
from TempCaseName A
where A.CaseID = casnCaseID
and ISNULL(A.CaseName, '') = ''

alter table [sma_TRN_Cases] enable trigger all
go
