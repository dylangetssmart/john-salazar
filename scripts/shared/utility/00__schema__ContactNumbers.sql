/*---
description: Adds breadcrumb columns to [sma_TRN_Cases] to support data lineage tracking.

steps: >
  - saga
  - source_id
  - source_db
  - source_ref

dependencies:
  -
---*/

use [SA]
go

---------------------------------------------------
-- [sma_MST_ContactNumbers] schema
---------------------------------------------------

--alter table sma_MST_ContactNumbers
--alter column saga int
--go

-- saga
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and Object_ID = OBJECT_ID(N'sma_MST_ContactNumbers')
	)
begin
	alter table [sma_MST_ContactNumbers] add [saga] INT null;
end
go

-- source_id
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and Object_ID = OBJECT_ID(N'sma_MST_ContactNumbers')
	)
begin
	alter table [sma_MST_ContactNumbers] add [source_id] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and Object_ID = OBJECT_ID(N'sma_MST_ContactNumbers')
	)
begin
	alter table [sma_MST_ContactNumbers] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and Object_ID = OBJECT_ID(N'sma_MST_ContactNumbers')
	)
begin
	alter table [sma_MST_ContactNumbers] add [source_ref] VARCHAR(MAX) null;
end
go
