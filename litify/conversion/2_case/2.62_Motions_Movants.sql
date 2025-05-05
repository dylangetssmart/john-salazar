use [ShinerSA]
go

/* ---------------------------------------------------------------------------------------------------------------
[sma_TRN_Motions] Schema
*/

-- saga
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and object_id = OBJECT_ID(N'sma_TRN_DiscoveryDepositionParties')
	)
begin
	-- Add the 'saga' column if it does not exist
	alter table [sma_TRN_DiscoveryDepositionParties] add [saga] INT null;
end
go

-- saga_char
-- NOTE - the standard field is [source_id], but the Shiner conversion uses [saga_char]
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_TRN_DiscoveryDepositionParties')
	)
begin
	alter table [sma_TRN_DiscoveryDepositionParties] add [saga_char] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and object_id = OBJECT_ID(N'sma_TRN_DiscoveryDepositionParties')
	)
begin
	alter table [sma_TRN_DiscoveryDepositionParties] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and object_id = OBJECT_ID(N'sma_TRN_DiscoveryDepositionParties')
	)
begin
	alter table [sma_TRN_DiscoveryDepositionParties] add [source_ref] VARCHAR(MAX) null;
end
go

/* ---------------------------------------------------------------------------------------------------------------
Insert Movants
*/

--select * from sma_TRN_DiscoveryDepositionParties stddp
--where  ddpnDiscDepoID is  mtnnMotionId from sma_TRN_Motions table and ddpsDiscDepoType = 'M'
--Joining sma_MST_AllContactInfo on ddpnContactCtgID and ddpnContactID will return the name.

insert into [dbo].[sma_TRN_DiscoveryDepositionParties]
	(
		[ddpnDiscDepoID],
		[ddpsPartyType],
		[ddpsDiscDepoType],
		[ddpnContactCtgID],
		[ddpnContactID],
		[ddpnAddressID],
		[ddpnRoleID],
		[ddpnRecUserID],
		[ddpdDtCreated],
		[ddpnModifyUserID],
		[ddpdDtModified],
		[ddpnLevelNo],
		[ddpnmotionID],
		[ddpsFormName],
		[ddpnVAmtTypeId],
		[saga],
		[saga_char],
		[source_db],
		[source_ref]
	)
	select
		sam.mtnnMotionId as ddpnDiscDepoID,		-- motion id
		'P'				 as ddpsPartyType,		-- P or D
		'M'				 as ddpsDiscDepoType,	-- M = motion
		ioci.CTG		 as ddpnContactCtgID,
		ioci.CID		 as ddpnContactID,
		null			 as ddpnAddressID,
		null			 as ddpnRoleID,
		null			 as ddpnRecUserID,
		null			 as ddpdDtCreated,
		null			 as ddpnModifyUserID,
		null			 as ddpdDtModified,
		null			 as ddpnLevelNo,
		sam.mtnnMotionId as ddpnmotionID,		-- motion id
		null			 as ddpsFormName,
		null			 as ddpnVAmtTypeId,
		null			 as saga,
		m.id			 as saga_char,
		'litify'		 as source_db,
		'Motion__c'		 as source_ref
	from ShinerLitify..Motion__c m
	join sma_TRN_Motions sam
		on sam.saga_char = m.Id
	join sma_TRN_Cases cas
		on cas.saga_char = m.Matter__c
	-- plaintiff
	join sma_TRN_Plaintiff p
		on p.plnnCaseID = cas.casnCaseID
			and p.plnbIsPrimary = 1
	join IndvOrgContacts_Indexed ioci
		on ioci.CID = p.plnnContactID
		and ioci.CTG = p.plnnContactCtg
go