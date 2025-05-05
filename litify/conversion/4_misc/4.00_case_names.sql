use ShinerSA
go

--Case Number (MAT-XXXXXXXXXXX) - PlaintiffFirstName PlaintiffLastName

-- create temp table
if exists (
		select
			*
		from sys.objects
		where name = 'TempCaseName'
			and Type = 'U'
	)
begin
	drop table TempCaseName
end

-- populate temp table
select
	cas.casnCaseID												 as caseid,
	cas.cassCaseName											 as casename,
	--ISNULL(ioc.name, '') + ' v. ' + ISNULL(iocd.name, '') as newcasename,
	--'(' + cas.cassCaseNumber + ') - ' + ioc.first_name + ' ' + ioc.last_name as newcasename
	ISNULL(ioc.first_name, '') + ' ' + ISNULL(ioc.last_name, '') as newcasename
into TempCaseName
from sma_TRN_Cases cas
/* Plaintiff
1. get plaintiff
2. get name from indv or org contacts
*/
left join sma_TRN_Plaintiff t
	on t.plnnCaseID = cas.casnCaseID
		and t.plnbIsPrimary = 1
left join (
	select
		cinnContactID  as cid,
		cinnContactCtg as ctg,
		cinsFirstName  as first_name,
		cinsLastName   as last_name,
		--cinsLastName + ', ' + cinsFirstName as name		-- ds 2024-10-15 #36
		--,cinsFirstName + ' ' + cinsLastName AS Name
		saga_char	   as saga
	from [sma_MST_IndvContacts]
--union
--select
--	connContactID  as cid,
--	connContactCtg as ctg,
--	consName	   as name,
--	saga_char	   as saga
--from [sma_MST_OrgContacts]
) ioc
	on ioc.cid = t.plnnContactID
		and ioc.ctg = t.plnnContactCtg
/* Defendant
1. get defendant
2. get name from indv or org contacts
*/
--left join sma_TRN_Defendants d
--	on d.defnCaseID = cas.casnCaseID
--		and d.defbIsPrimary = 1
--left join (
--	select
--		cinnContactID as cid,
--		cinnContactCtg as ctg,
--		cinsLastName + ', ' + cinsFirstName as name		-- ds 2024-10-15 #36
--		--,cinsFirstName + ' ' + cinsLastName AS Name
--		,
--		saga_char as saga
--	from [sma_MST_IndvContacts]
--	union
--	select
--		connContactID as cid,
--		connContactCtg as ctg,
--		consName as name,
--		saga_char as saga
--	from [sma_MST_OrgContacts]
--) iocd
--	on iocd.cid = d.defnContactID
--		and iocd.ctg = d.defnContactCtgID


--update case names
alter table [sma_TRN_Cases] disable trigger all
go

update sma_TRN_Cases
set cassCaseName = A.NewCaseName
from TempCaseName a
where a.CaseId = casnCaseID
and ISNULL(a.newcasename, '') <> ''
--and ISNULL(a.CaseName, '') = ''

alter table [sma_TRN_Cases] enable trigger all
go


--select * from TempCaseName WHERE CaseID = 4575
--select * FROM ShinerSA..sma_TRN_Cases stc WHERE stc.casnCaseID = 4575