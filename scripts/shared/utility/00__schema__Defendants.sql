use [SA]
go

-------------------------------------------------------------------------------
-- Update schema
-------------------------------------------------------------------------------

-- saga_party
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_party'
			and object_id = OBJECT_ID(N'sma_TRN_Defendants')
	)
begin
	alter table [sma_TRN_Defendants] add [saga_party] INT null;
end


-- source_id
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and Object_ID = OBJECT_ID(N'sma_TRN_Defendants')
	)
begin
	alter table [sma_TRN_Defendants] add [source_id] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and Object_ID = OBJECT_ID(N'sma_TRN_Defendants')
	)
begin
	alter table [sma_TRN_Defendants] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and Object_ID = OBJECT_ID(N'sma_TRN_Defendants')
	)
begin
	alter table [sma_TRN_Defendants] add [source_ref] VARCHAR(MAX) null;
end
go

