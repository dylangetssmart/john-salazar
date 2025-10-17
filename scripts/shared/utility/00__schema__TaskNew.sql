use [SA]
go

-------------------------------------------------------------------------------
-- Update schema
-------------------------------------------------------------------------------

if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and object_id = OBJECT_ID(N'sma_TRN_TaskNew')
	)
begin
	alter table [sma_TRN_TaskNew]
	add [saga] INT null;
end


-- source_id
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and Object_ID = OBJECT_ID(N'sma_TRN_TaskNew')
	)
begin
	alter table [sma_TRN_TaskNew] add [source_id] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and Object_ID = OBJECT_ID(N'sma_TRN_TaskNew')
	)
begin
	alter table [sma_TRN_TaskNew] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and Object_ID = OBJECT_ID(N'sma_TRN_TaskNew')
	)
begin
	alter table [sma_TRN_TaskNew] add [source_ref] VARCHAR(MAX) null;
end
go
