use ShinerSA
go


-- saga (INT)
-- Check if the column 'saga' exists and if it's not of type INT, change its type
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and object_id = OBJECT_ID(N'sma_MST_Users')
	)
begin
	-- Add the 'saga' column if it does not exist
	alter table [sma_MST_Users] add [saga] INT null;
end
go

-- saga_char
-- this should be source_id, but many scripts already use `saga_char`
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_MST_Users')
	)
begin
	alter table [sma_MST_Users] add [saga_char] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and object_id = OBJECT_ID(N'sma_MST_Users')
	)
begin
	alter table [sma_MST_Users] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and object_id = OBJECT_ID(N'sma_MST_Users')
	)
begin
	alter table [sma_MST_Users] add [source_ref] VARCHAR(MAX) null;
end
go