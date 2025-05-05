use [SA]
go

alter table sma_TRN_Cases
alter column saga INT
go

-- source_id_1
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and Object_ID = OBJECT_ID(N'sma_TRN_Cases')
	)
begin
	alter table [sma_TRN_Cases] add [source_id] VARCHAR(max) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and Object_ID = OBJECT_ID(N'sma_TRN_Cases')
	)
begin
	alter table [sma_TRN_Cases] add [source_db] VARCHAR(max) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and Object_ID = OBJECT_ID(N'sma_TRN_Cases')
	)
begin
	alter table [sma_TRN_Cases] add [source_ref] VARCHAR(max) null;
end
go