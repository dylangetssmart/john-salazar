/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create users and contacts

replace:
'OfficeName'
'StateDescription'
'VenderCaseType'
##########################################################################################################################
*/

use [SA]
go

-- saga
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and Object_ID = OBJECT_ID(N'sma_TRN_Courts')
	)
begin
	alter table [sma_TRN_Courts] add [saga] INT null;
end
go

-- source_id_1
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and Object_ID = OBJECT_ID(N'sma_TRN_Courts')
	)
begin
	alter table [sma_TRN_Courts] add [source_id] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and Object_ID = OBJECT_ID(N'sma_TRN_Courts')
	)
begin
	alter table [sma_TRN_Courts] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and Object_ID = OBJECT_ID(N'sma_TRN_Courts')
	)
begin
	alter table [sma_TRN_Courts] add [source_ref] VARCHAR(MAX) null;
end
go


-------------------------------------------------------------------
-- [sma_TRN_CourtDocket]
-------------------------------------------------------------------

-- saga
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and Object_ID = OBJECT_ID(N'sma_TRN_CourtDocket')
	)
begin
	alter table [sma_TRN_CourtDocket] add [saga] INT null;
end
go

-- source_id_1
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and Object_ID = OBJECT_ID(N'sma_TRN_CourtDocket')
	)
begin
	alter table [sma_TRN_CourtDocket] add [source_id] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and Object_ID = OBJECT_ID(N'sma_TRN_CourtDocket')
	)
begin
	alter table [sma_TRN_CourtDocket] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and Object_ID = OBJECT_ID(N'sma_TRN_CourtDocket')
	)
begin
	alter table [sma_TRN_CourtDocket] add [source_ref] VARCHAR(MAX) null;
end
go


-------------------------------------------------------------------
-- [sma_trn_caseJudgeorClerk]
-------------------------------------------------------------------

-- saga
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and Object_ID = OBJECT_ID(N'sma_TRN_caseJudgeorClerk')
	)
begin
	alter table [sma_TRN_caseJudgeorClerk] add [saga] INT null;
end
go

-- source_id_1
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and Object_ID = OBJECT_ID(N'sma_TRN_caseJudgeorClerk')
	)
begin
	alter table [sma_TRN_caseJudgeorClerk] add [source_id] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and Object_ID = OBJECT_ID(N'sma_TRN_caseJudgeorClerk')
	)
begin
	alter table [sma_TRN_caseJudgeorClerk] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and Object_ID = OBJECT_ID(N'sma_TRN_caseJudgeorClerk')
	)
begin
	alter table [sma_TRN_caseJudgeorClerk] add [source_ref] VARCHAR(MAX) null;
end
go
