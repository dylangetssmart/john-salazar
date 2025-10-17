use [SA]
go

-------------------------------------------------------------------------------
-- [sma_TRN_Disbursement]
-------------------------------------------------------------------------------
-- saga
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and object_id = OBJECT_ID(N'sma_TRN_Disbursement')
	)
begin
	alter table [sma_TRN_Disbursement] add [saga] INT null;
end

-- source_id
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and object_id = OBJECT_ID(N'sma_TRN_Disbursement')
	)
begin
	alter table [sma_TRN_Disbursement] add [source_id] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and object_id = OBJECT_ID(N'sma_TRN_Disbursement')
	)
begin
	alter table [sma_TRN_Disbursement] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and object_id = OBJECT_ID(N'sma_TRN_Disbursement')
	)
begin
	alter table [sma_TRN_Disbursement] add [source_ref] VARCHAR(MAX) null;
end
go