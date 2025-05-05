use [ShinerSA]
go

/* ---------------------------------------------------------------------------------------------------------------
[sma_TRN_CriticalDeadlines] Schema
*/

-- saga
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and object_id = OBJECT_ID(N'sma_TRN_CriticalDeadlines')
	)
begin
	alter table [sma_TRN_CriticalDeadlines] add [saga] INT null;
end

go

-- saga_char
-- NOTE - the standard field is [source_id], but the Shiner conversion uses [saga_char]
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_TRN_CriticalDeadlines')
	)
begin
	alter table [sma_TRN_CriticalDeadlines] add [saga_char] VARCHAR(MAX) null;
end

go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and object_id = OBJECT_ID(N'sma_TRN_CriticalDeadlines')
	)
begin
	alter table [sma_TRN_CriticalDeadlines] add [source_db] VARCHAR(MAX) null;
end

go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and object_id = OBJECT_ID(N'sma_TRN_CriticalDeadlines')
	)
begin
	alter table [sma_TRN_CriticalDeadlines] add [source_ref] VARCHAR(MAX) null;
end

go

/* ---------------------------------------------------------------------------------------------------------------
Create critical deadlines from [Discovery__c].[Date_Response_Due__c]
*/

alter table [sma_TRN_CriticalDeadlines] disable trigger all
go

insert into [dbo].[sma_TRN_CriticalDeadlines]
	(
		[crdnCaseID],
		[crdnCriticalDeadlineTypeID],
		[crdsPartyFlag],
		[crdsPlntDefFlag],
		[crdnPlntDefID],
		[crddDueDate],
		[crddCompliedDate],
		[crdsComments],
		[crdnRecUserID],
		[crddDtCreated],
		[crdnModifyUserID],
		[crddDtModified],
		[crdnLevelNo],
		[crdnContactCtgId],
		[crdnContactId],
		[id_discovery],
		[crdnDiscoveryTypeId],
		[crdsWaivedFlag],
		[crdsSupercededFlag],
		[crdsCriteria],
		[WorkPlanItemId],
		[crdsRequestFrom],
		[ResponderUID],
		[ActionType],
		[saga],
		[saga_char],
		[source_db],
		[source_ref]
	)
	select
		cas.casnCaseID as crdnCaseID, 
		/*
		[crdnCriticalDeadlineTypeID] uses [sma_TRN_LitigationDiscovery].[TypeId]
		from the associated [sma_TRN_LitigationDiscovery] record
		*/
		ld.typeid	   as crdnCriticalDeadlineTypeID, 
		null		   as crdsPartyFlag, 
		null		   as crdsPlntDefFlag,
		null		   as crdnPlntDefID,
		case
			when (d.Date_Response_Due__c not between '1900-01-01' and '2079-12-31')
				then null
			else d.Date_Response_Due__c
		end			   as crddDueDate, 
		case
			when (d.Response_Served__c not between '1900-01-01' and '2079-12-31')
				then null
			else d.Response_Served__c
		end			   as crddCompliedDate,
		ISNULL('Discovery Name: ' + NULLIF(CONVERT(VARCHAR(MAX), d.name), '') + CHAR(13), '') +
		''			   as crdsComments, 
		(
			select
				smu.usrnUserID
			from sma_MST_Users smu
			where smu.saga_char = d.CreatedById
		)			   as crdnRecUserID, 
		case
			when (d.CreatedDate not between '1900-01-01' and '2079-12-31')
				then null
			else d.CreatedDate
		end			   as crddDtCreated, 
		null		   as crdnModifyUserID,
		null		   as crddDtModified,
		1			   as crdnLevelNo, 
		null		   as crdnContactCtgId,
		null		   as crdnContactId,
		null		   as id_discovery, 
		null		   as crdnDiscoveryTypeId, 
		null		   as crdsWaivedFlag, 
		null		   as crdsSupercededFlag, 
		'D'			   as crdsCriteria, 		-- Discovery
		null		   as WorkPlanItemId, 
		null		   as crdsRequestFrom,
		null		   as ResponderUID,
		null		   as ActionType,
		null		   as [saga],
		d.Id		   as [saga_char],
		'litify'	   as [source_db],
		'Discovery__c' as [source_ref]
	--select * 
	from ShinerLitify..Discovery__c d
	join sma_TRN_Cases cas
		on cas.saga_char = d.Matter__c
	join sma_TRN_LitigationDiscovery ld
		on ld.saga_char = d.Id
	where
		ISNULL(d.Date_Response_Due__c, '') <> ''

go

alter table [sma_TRN_CriticalDeadlines] enable trigger all
go