use [SA]
go


/* ------------------------------------------------------------------------------
[officer_helper]
*/ ------------------------------------------------------------------------------
if exists (
	 select
		 *
	 from sys.objects
	 where [name] = 'officer_helper'
		 and type = 'U'
	)
begin
	drop table officer_helper
end

go

create table officer_helper (
	OfficerCID INT,
	OfficerCTG INT,
	OfficerAID INT,
	saga	   INT		   null,
	source_id  VARCHAR(50) null,
	source_db  VARCHAR(50) null,
	source_ref VARCHAR(50) null
)
create nonclustered index IX_NonClustered_Index_Officer_Helper on [officer_helper] (saga);
go

insert into officer_helper
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
		null			 as saga,
		i.source_id		 as source_id,
		'needles'		 as source_db,
		'police'		 as source_ref
	--select *
	from [Needles].[dbo].[police] p
	join [sma_MST_IndvContacts] i
		on i.source_id = p.officer
			and i.cinsPrefix = 'Officer'
	join [sma_MST_Address] a
		on a.addnContactID = i.cinnContactID
			and a.addnContactCtgID = i.cinnContactCtg
			and a.addbPrimary = 1
go

dbcc dbreindex ('officer_helper', ' ', 90) with no_infomsgs


/* ------------------------------------------------------------------------------
[police_helper]
*/ ------------------------------------------------------------------------------
if exists (
	 select
		 *
	 from sys.objects
	 where name = 'police_helper'
		 and type = 'U'
	)
begin
	drop table police_helper
end

go

create table police_helper (
	PoliceCID  INT,
	PoliceCTG  INT,
	PoliceAID  INT,
	police_id  INT,
	case_num   INT,
	casnCaseID INT,
	officerCID INT,
	officerAID INT
)
create nonclustered index IX_NonClustered_Index_Police_Helper on [police_helper] (police_id);
go

insert into police_helper
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
		 from officer_helper h
		 where h.source_id = p.officer
		)			   as officercid,
		(
		 select
			 h.officeraid
		 from officer_helper h
		 where h.source_id = p.officer
		)			   as officeraid
	from [Needles].[dbo].[police] p
	join [sma_TRN_cases] cas
		on cas.cassCaseNumber = p.case_num
	join [IndvOrgContacts_Indexed] ioc
		on ioc.SAGA = p.police_id
go

dbcc dbreindex ('Police_Helper', ' ', 90) with no_infomsgs
go


/* ------------------------------------------------------------------------------
Insert [sma_TRN_PoliceReports]
*/ ------------------------------------------------------------------------------
exec AddBreadcrumbsToTable 'sma_TRN_PoliceReports'
go

alter table [sma_TRN_PoliceReports] disable trigger all
go

insert into [sma_TRN_PoliceReports]
	(
		[pornCaseID],
		[pornPoliceID],
		[pornPoliceAdID],
		[porsReportNo],
		[porsComments],
		[pornPOContactID],
		[pornPOCtgID],
		[pornPOAddressID],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
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
		map.PoliceAID		   as [pornpoaddressid],
		p.report_id			   as [saga],
		null				   as [source_id],
		'needles'			   as [source_db],
		'police'			   as [source_ref]
	from [Needles].[dbo].[police] p
	join Police_Helper map
		on map.police_id = p.police_id
			and map.case_num = p.case_num
go

alter table [sma_TRN_PoliceReports] enable trigger all
go