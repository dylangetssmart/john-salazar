use [SA]
go

---
alter table [sma_TRN_PoliceReports] disable trigger all
go

---

---(0)---
if exists (
		select
			*
		from sys.objects
		where [name] = 'officer_helper'
			and type = 'U'
			and schema_id = SCHEMA_ID('conversion')
	)
begin
	drop table conversion.officer_helper
end
go

create table conversion.officer_helper (
	OfficerCID INT,
	OfficerCTG INT,
	OfficerAID INT,
	saga	   VARCHAR(400)
)
go

----
create nonclustered index IX_NonClustered_Index_Officer_Helper on [conversion].[officer_helper] (saga);
----
go

---(0)---
insert into conversion.officer_helper
	(
	OfficerCID,
	OfficerCTG,
	OfficerAID,
	saga
	)
	select distinct
		i.cinnContactID	 as officercid,
		i.cinnContactCtg as officerctg,
		a.addnAddressID	 as officeraid,
		i.source_id		 as saga
	--select *
	from Needles.[dbo].[police] p
	join [sma_MST_IndvContacts] i
		--ON I.cinsGrade = P.officer
		--	AND I.cinsPrefix = 'Officer'
		on i.source_id = p.officer
			and i.cinsPrefix = 'Officer'
	join [sma_MST_Address] a
		on a.addnContactID = i.cinnContactID
			and a.addnContactCtgID = i.cinnContactCtg
			and a.addbPrimary = 1

go

dbcc dbreindex ('conversion.officer_helper', ' ', 90) with no_infomsgs


---(0)---
if exists (
		select
			*
		from sys.objects
		where name = 'police_helper'
			and type = 'U'
			and schema_id = SCHEMA_ID('conversion')
	)
begin
	drop table conversion.police_helper
end
go

create table conversion.police_helper (
	PoliceCID  INT,
	PoliceCTG  INT,
	PoliceAID  INT,
	police_id  INT,
	case_num   INT,
	casnCaseID INT,
	officerCID INT,
	officerAID INT
)
go

----
create nonclustered index IX_NonClustered_Index_Police_Helper on [conversion].[police_helper] (police_id);
----
go

insert into conversion.police_helper
	(
	PoliceCID,
	PoliceCTG,
	PoliceAID,
	police_id,
	case_num,
	casnCaseID,
	officerCID,
	officerAID
	)
	select
		ioc.CID		   as policecid,
		ioc.CTG		   as policectg,
		ioc.AID		   as policeaid,
		p.police_id	   as police_id,
		p.case_num,
		cas.casncaseid as casncaseid,
		(
			select
				h.officercid
			from conversion.officer_helper h
			--WHERE H.cinsGrade = P.officer
			where h.saga = p.officer
		)			   as officercid,
		(
			select
				h.officeraid
			from conversion.officer_helper h
			--WHERE H.cinsGrade = P.officer
			where h.saga = p.officer
		)			   as officeraid
	from Needles.[dbo].[police] p
	join [sma_TRN_cases] cas
		on cas.cassCaseNumber = p.case_num
	join [IndvOrgContacts_Indexed] ioc
		on ioc.SAGA = p.police_id
go

dbcc dbreindex ('conversion.Police_Helper', ' ', 90) with no_infomsgs
go


---(2)---
insert into [sma_TRN_PoliceReports]
	(
	[pornCaseID],
	[pornPoliceID],
	[pornPoliceAdID],
	[porsReportNo],
	[porsComments],
	[pornPOContactID],
	[pornPOCtgID],
	[pornPOAddressID]
	)

	select
		map.casnCaseID		   as porncaseid,
		map.officerCID		   as pornpoliceid,
		map.officerAID		   as pornpoliceadid,
		LEFT(p.report_num, 30) as porsreportno,
		ISNULL('Badge:' + NULLIF(p.badge, '') + CHAR(13), '')
		as porscomments,
		map.PoliceCID		   as [pornpocontactid],
		map.PoliceCTG		   as [pornpoctgid],
		map.PoliceAID		   as [pornpoaddressid]
	from Needles.[dbo].[police] p
	join conversion.Police_Helper map
		on map.police_id = p.police_id
			and map.case_num = p.case_num
go

---
alter table [sma_TRN_PoliceReports] enable trigger all
go
---


