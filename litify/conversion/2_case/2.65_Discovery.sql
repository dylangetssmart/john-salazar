--SELECT * FROM ShinerSA..sma_TRN_Discovery std
--SELECT * FROM ShinerSA..sma_MST_DiscoveryType smdt
--SELECT * FROM ShinerSA..sma_TRN_DiscoveryDepositionParties stddp
--SELECT * FROM ShinerSA..sma_TRN_DiscoveryDepositionRespondents stddr


--SELECT * FROM ShinerLitify..Discovery__c dc
--SELECT * FROM ShinerSA..sma_TRN_LitigationDiscovery stld
--SELECT * FROM ShinerSA..sma_MST_ServiceTypes

--delete from  ShinerSA..sma_TRN_DiscoveryDepositionRespondents 

use [ShinerSA]
go

/* ---------------------------------------------------------------------------------------------------------------
[sma_TRN_LitigationDiscovery] Schema
*/

-- saga
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and object_id = OBJECT_ID(N'sma_TRN_LitigationDiscovery')
	)
begin
	alter table [sma_TRN_LitigationDiscovery] add [saga] INT null;
end
go

-- saga_char
-- NOTE - the standard field is [source_id], but the Shiner conversion uses [saga_char]
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_TRN_LitigationDiscovery')
	)
begin
	alter table [sma_TRN_LitigationDiscovery] add [saga_char] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and object_id = OBJECT_ID(N'sma_TRN_LitigationDiscovery')
	)
begin
	alter table [sma_TRN_LitigationDiscovery] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and object_id = OBJECT_ID(N'sma_TRN_LitigationDiscovery')
	)
begin
	alter table [sma_TRN_LitigationDiscovery] add [source_ref] VARCHAR(MAX) null;
end
go

/* ---------------------------------------------------------------------------------------------------------------
Create Discovery Type
*/

if not exists (
		select
			1
		from [dbo].[sma_MST_DiscoveryType]
		where dstsCode = 'DISC'
	)
begin
	insert into [dbo].[sma_MST_DiscoveryType]
		(
			[dstsCode],
			[dstsDescription],
			[dstsDescriptionType],
			[dstnRecUserID],
			[dstdDtCreated],
			[dstnModifyUserID],
			[dstdDtModified],
			[dstnLevelNo],
			[dstnCheckin],
			[dstnCheckinn],
			[dstncriteria]
		)
		select
			'DISC'		as dstsCode, --varchar(20),>
			'Discovery' as dstsDescription, --varchar(50),>
			'Discovery' as dstsDescriptionType, --varchar(2000),>
			368			as dstnRecUserID, --int,>
			GETDATE()   as dstdDtCreated, --smalldatetime,>
			null		as dstnModifyUserID, --int,>
			null		as dstdDtModified, --smalldatetime,>
			null		as dstnLevelNo, --int,>
			null		as dstnCheckin, --char(1),>
			null		as dstnCheckinn, --char(5),>
			null		as dstncriteria --varchar(5),>)
end

go

/* ---------------------------------------------------------------------------------------------------------------
Insert Discoveries
*/


insert into [dbo].[sma_TRN_LitigationDiscovery]
	(
		[CaseID],
		[EnteredDt],
		[TypeID],
		[MethodOfService],
		[ServedByID],
		[ResDescription],
		[DemandOrder],
		[OrderDt],
		[OnDate],
		[OnBeforeDt],
		[WithinDays],
		[FromDt],
		[DtToComply],
		[AppointmentID],
		[RecUserID],
		[ModifyUserID],
		[DtModified],
		[Deleted],
		[DeletedOn],
		[DeletedBy],
		[DissDocuments],
		[lidnRespondentType],
		[saga],
		[saga_char],
		[source_db],
		[source_ref]
	)
	select
		cas.casnCaseID as CaseID,-- int,>
		case
			when (d.CreatedDate not between '1900-01-01' and '2079-12-31')
				then null
			else d.CreatedDate
		end			   as EnteredDt,-- smalldatetime,>
		(
			select
				dstnDiscoveryTypeID
			from sma_MST_DiscoveryType
			where dstsDescription = 'Discovery'
		)			   as TypeID, --int,>
		(
			select
				sctnSrvcTypeID
			from sma_MST_ServiceTypes
			where sctsDscrptn = 'Unspecified'
		)			   as MethodOfService, --varchar(500),>
		null		   as ServedByID, --varchar(500),>
		ISNULL('Discovery Name: ' + NULLIF(CONVERT(VARCHAR(MAX), d.name), '') + CHAR(13), '') +
		ISNULL('Document Description: ' + NULLIF(CONVERT(VARCHAR(MAX), d.Document_Description__c), '') + CHAR(13), '') +
		ISNULL('Date Served: ' + NULLIF(CONVERT(VARCHAR(MAX), d.Date_Served__c), '') + CHAR(13), '') +
		''			   as ResDescription, --varchar(2000),>
		1			   as DemandOrder, --int,>
		case
			when (d.Date__c not between '1900-01-01' and '2079-12-31')
				then null
			else d.Date__c
		end			   as OrderDt, --smalldatetime,>
		null		   as OnDate, --smalldatetime,>
		null		   as OnBeforeDt,-- smalldatetime,>
		null		   as WithinDays, --int,>
		null		   as FromDt, --smalldatetime,>
			case
			when (d.Date_Response_Due__c not between '1900-01-01' and '2079-12-31')
				then null
			else d.Date_Response_Due__c
		end			   as DtToComply, --smalldatetime,>
		null		   as AppointmentID, --int,>
			(
			select
				smu.usrnUserID
			from sma_MST_Users smu
			where smu.saga_char = d.CreatedById
		)			   as RecUserID, --int,>
		null		   as ModifyUserID, --int,>
		null		   as DtModified, --smalldatetime,>
		null		   as Deleted, --bit,>
		null		   as DeletedOn, --smalldatetime,>
		null		   as DeletedBy, --int,>
		null		   as DissDocuments,-- varchar(max),>
		2			   as lidnRespondentType, -- int,>)
		null		   as [saga],
		d.Id		   as [saga_char],
		'litify'	   as [source_db],
		'Discovery__c' as [source_ref]
	--select * 
	from ShinerLitify..Discovery__c d
	join sma_TRN_Cases cas
		on cas.saga_char = d.Matter__c
go

