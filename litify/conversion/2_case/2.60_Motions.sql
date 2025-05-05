use [ShinerSA]
go


--select * from ShinerLitify..litify_docs__File_Info__c
--where
--	litify_docs__Related_To_Api_Name__c = 'litify_pm__Damage__c'
--	and Matter__c = 'a0LNt00000B4BoWMAV'
--	and name like '%7.29.24 - BR%'

--select * from sma_TRN_Motions stm where stm.mtnnCaseID = 545

--select * from ShinerSA..sma_TRN_CalendarAppointments stca
--where
--	stca.CaseID = 545
--select * from sma_MST_AppointmentType smat
--select * from sma_MST_ActivityType smat

--select * from sma_TRN_MotionDetails stmd

--select * from ShinerLitify..litify_pm__Matter__c lpmc
--where
--	name = 'MAT-23013027796'
---- a0L8Z00000fL4pQUAS

--select * from ShinerLitify..Motion__c mc
--where
--	mc.Matter__c = 'a0L8Z00000fL4pQUAS'



/* ---------------------------------------------------------------------------------------------------------------
[sma_TRN_Motions] Schema
*/

-- saga
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and object_id = OBJECT_ID(N'sma_TRN_Motions')
	)
begin
	-- Add the 'saga' column if it does not exist
	alter table [sma_TRN_Motions] add [saga] INT null;
end
go

-- saga_char
-- NOTE - the standard field is [source_id], but the Shiner conversion uses [saga_char]
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_TRN_Motions')
	)
begin
	alter table [sma_TRN_Motions] add [saga_char] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and object_id = OBJECT_ID(N'sma_TRN_Motions')
	)
begin
	alter table [sma_TRN_Motions] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and object_id = OBJECT_ID(N'sma_TRN_Motions')
	)
begin
	alter table [sma_TRN_Motions] add [source_ref] VARCHAR(MAX) null;
end
go


/* ---------------------------------------------------------------------------------------------------------------
Create Service Type
*/
select
	*
from ShinerSA..sma_MST_ServiceTypes smst

if not exists (
		select
			1
		from [dbo].sma_MST_ServiceTypes
		where sctsCode = 'UNSPC'
	)
begin
	insert into [dbo].sma_MST_ServiceTypes
		(
			sctsCode,
			sctsDscrptn,
			sctnRecUserID,
			sctdDtCreated
		)
		select
			'UNSPC'		  as sctsCode,
			'Unspecified' as sctsDscrptn,
			368			  as sctnRecUserID,
			GETDATE()	  as sctdDtCreated
end

go

/* ---------------------------------------------------------------------------------------------------------------
Insert Motions
*/
insert into [dbo].[sma_TRN_Motions]
	(
		[mtnnMotionTypeID],
		[mtnnCaseID],
		[mtndDate],
		[mtnbDocAttached],
		[mtnbOSCTRO],
		[mtnsMovent],
		[mtndOSCTRODt],
		[mtndOSCLastDate],
		[mtnnCrossMotion],
		[mtnnCrossMotionID],
		[mtnsServiceMethod],
		[mtndServiceDt],
		[mtndCourtOrderServiceDt],
		[mtndOppositionDate],
		[mtndOppositionSR],
		[mtndReturnDate],
		[mtnnCreateAppointment],
		[mtndReplyDue],
		[mtndReplySR],
		[mtnnOral],
		[mtnsComment],
		[mtndOSCFiledDate],
		[mtnbPending],
		[mtndAffServiceRec],
		[mtndCourtFilingCompletedDt],
		[mtnnAppointmentID],
		[mtnnRecUserID],
		[mtndDtCreated],
		[mtnnModifyUserID],
		[mtndDtModified],
		[mtnnLevelNo],
		[mtnnMethodofService],
		[mtnnAppointmentIDNew],
		[mtnnMovantContactCtg],
		[mtnnMovantContactId],
		[mtnbTempRestOrder],
		[mtnsDocuments],
		[mtndSentReceived],
		[Efile],
		[CrossMotionText],
		[CrossMotionReceived],
		[saga],
		[saga_char],
		[source_db],
		[source_ref]
	)
	select
		(
			select
				mntnMotionTypeID
			from sma_mst_MotionType
			where mntsDscrptn = 'Motion'
		)			   as mtnnMotionTypeID, -- int,>
		cas.casnCaseID as mtnnCaseID, --int,>
		null		   as mtndDate,-- smalldatetime,>
		null		   as mtnbDocAttached,-- bit,>
		null		   as mtnbOSCTRO,-- bit,>
		null		   as mtnsMovent, --int,>
		null		   as mtndOSCTRODt, --smalldatetime,>
		null		   as mtndOSCLastDate,-- smalldatetime,>
		null		   as mtnnCrossMotion, --int,>
		null		   as mtnnCrossMotionID, --int,>
		(
			select
				sctnSrvcTypeID
			from sma_MST_ServiceTypes
			where sctsDscrptn = 'Unspecified'
		)			   as mtnsServiceMethod,-- varchar(500),>
		null		   as mtndServiceDt,-- smalldatetime,>
		null		   as mtndCourtOrderServiceDt,-- smalldatetime,>
		case
			when (m.Response_Deadline__c not between '1900-01-01' and '2079-12-31')
				then null
			else m.Response_Deadline__c
		end			   as mtndOppositionDate,-- smalldatetime,>
		null		   as mtndOppositionSR, --smalldatetime,>
		null		   as mtndReturnDate, --smalldatetime,>
		null		   as mtnnCreateAppointment,-- int,>
		null		   as mtndReplyDue, --smalldatetime,>
		null		   as mtndReplySR,-- smalldatetime,>
		null		   as mtnnOral, --int,>
		ISNULL('Motion Name: ' + NULLIF(CONVERT(VARCHAR(MAX), m.Name), '') + CHAR(13), '') +
		ISNULL('Order entered: ' + NULLIF(CONVERT(VARCHAR(MAX), m.Order_entered__c), '') + CHAR(13), '') +
		''			   as mtnsComment, --nvarchar(max),>
		null		   as mtndOSCFiledDate, --smalldatetime,>
		null		   as mtnbPending, --bit,>
		null		   as mtndAffServiceRec, --smalldatetime,>
		case
			when (m.Filed_Date__c not between '1900-01-01' and '2079-12-31')
				then null
			else m.Filed_Date__c
		end			   as mtndCourtFilingCompletedDt, --smalldatetime,>
		null		   as mtnnAppointmentID,-- int,>
		(
			select
				smu.usrnUserID
			from sma_MST_Users smu
			where smu.saga_char = m.CreatedById
		)			   as mtnnRecUserID, --int,>
		case
			when (m.CreatedDate not between '1900-01-01' and '2079-12-31')
				then null
			else m.CreatedDate
		end			   as mtndDtCreated, --smalldatetime,>
		null		   as mtnnModifyUserID, --int,>
		null		   as mtndDtModified, --smalldatetime,>
		null		   as mtnnLevelNo, --int,>
		null		   as mtnnMethodofService, --varchar(500),>
		null		   as mtnnAppointmentIDNew, ---int,>
		null		   as mtnnMovantContactCtg, --int,>
		null		   as mtnnMovantContactId, --int,>
		null		   as mtnbTempRestOrder,-- bit,>
		null		   as mtnsDocuments, --varchar(max),>
		case
			when (m.Response_Served__c not between '1900-01-01' and '2079-12-31')
				then null
			else m.Response_Served__c
		end			   as mtndSentReceived,-- datetime,>
		null		   as Efile, --bit,>
		null		   as CrossMotionText, --nvarchar(1000),>
		0			   as CrossMotionReceived, --bit,>
		null		   as [saga],
		m.Id		   as [saga_char],
		'litify'	   as [source_db],
		'Motion__c'	   as [source_ref]
	from ShinerLitify..Motion__c m
	join sma_TRN_Cases cas
		on cas.saga_char = m.Matter__c
--where
--	m.Matter__c = 'a0L8Z00000fL4pQUAS'
go

/* ---------------------------------------------------------------------------------------------------------------
Movants
*/

--select * from sma_TRN_DiscoveryDepositionParties stddp
--where  ddpnDiscDepoID is  mtnnMotionId from sma_TRN_Motions table and ddpsDiscDepoType = 'M'
--Joining sma_MST_AllContactInfo on ddpnContactCtgID and ddpnContactID will return the name.

--USE [ShinerSA]
--GO

--INSERT INTO [dbo].[sma_TRN_DiscoveryDepositionParties]
--           ([ddpnDiscDepoID]
--           ,[ddpsPartyType]
--           ,[ddpsDiscDepoType]
--           ,[ddpnContactCtgID]
--           ,[ddpnContactID]
--           ,[ddpnAddressID]
--           ,[ddpnRoleID]
--           ,[ddpnRecUserID]
--           ,[ddpdDtCreated]
--           ,[ddpnModifyUserID]
--           ,[ddpdDtModified]
--           ,[ddpnLevelNo]
--           ,[ddpnmotionID]
--           ,[ddpsFormName]
--           ,[ddpnVAmtTypeId])
--     VALUES
--           (<ddpnDiscDepoID, bigint,>
--           ,<ddpsPartyType, char(1),>
--           ,<ddpsDiscDepoType, char(1),>
--           ,<ddpnContactCtgID, bigint,>
--           ,<ddpnContactID, bigint,>
--           ,<ddpnAddressID, int,>
--           ,<ddpnRoleID, bigint,>
--           ,<ddpnRecUserID, int,>
--           ,<ddpdDtCreated, smalldatetime,>
--           ,<ddpnModifyUserID, int,>
--           ,<ddpdDtModified, smalldatetime,>
--           ,<ddpnLevelNo, int,>
--           ,<ddpnmotionID, bigint,>
--           ,<ddpsFormName, varchar(50),>
--           ,<ddpnVAmtTypeId, bigint,>)
--GO

