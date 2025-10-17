use [SA]
go

---------------------------------------------------
-- [sma_TRN_Hospitals]
---------------------------------------------------
-- saga
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and Object_ID = OBJECT_ID(N'sma_TRN_Hospitals')
	)
begin
	alter table [sma_TRN_Hospitals] add [saga] INT null;
end
go

-- source_id
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and Object_ID = OBJECT_ID(N'sma_TRN_Hospitals')
	)
begin
	alter table [sma_TRN_Hospitals] add [source_id] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and Object_ID = OBJECT_ID(N'sma_TRN_Hospitals')
	)
begin
	alter table [sma_TRN_Hospitals] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and Object_ID = OBJECT_ID(N'sma_TRN_Hospitals')
	)
begin
	alter table [sma_TRN_Hospitals] add [source_ref] VARCHAR(MAX) null;
end
go

---------------------------------------------------
-- [sma_TRN_SpDamages]
---------------------------------------------------
-- saga
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and Object_ID = OBJECT_ID(N'sma_TRN_SpDamages')
	)
begin
	alter table [sma_TRN_SpDamages] add [saga] INT null;
end
go

-- saga_bill_id
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_bill_id'
			and Object_ID = OBJECT_ID(N'sma_TRN_SpDamages')
	)
begin
	alter table [sma_TRN_SpDamages] add [saga_bill_id] [VARCHAR](100) null;
end
go

-- source_id
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and Object_ID = OBJECT_ID(N'sma_TRN_SpDamages')
	)
begin
	alter table [sma_TRN_SpDamages] add [source_id] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and Object_ID = OBJECT_ID(N'sma_TRN_SpDamages')
	)
begin
	alter table [sma_TRN_SpDamages] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and Object_ID = OBJECT_ID(N'sma_TRN_SpDamages')
	)
begin
	alter table [sma_TRN_SpDamages] add [source_ref] VARCHAR(MAX) null;
end
go

