/* ###################################################################################
description: Handles common operations related to [sma_TRN_Notes]
steps:
	- Add columns to [sma_TRN_Notes]
		- saga
		- source_id
		- source_db
		- source_ref
usage_instructions:
	-
dependencies:
	- 
notes:
	-
*/

use [SA]
go

---------------------------------------------------
-- sma_TRN_Notes
---------------------------------------------------

-- saga
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and Object_ID = OBJECT_ID(N'sma_TRN_Notes')
	)
begin
	alter table [sma_TRN_Notes] add [saga] INT null;
end
go

-- source_id
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and Object_ID = OBJECT_ID(N'sma_TRN_Notes')
	)
begin
	alter table [sma_TRN_Notes] add [source_id] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and Object_ID = OBJECT_ID(N'sma_TRN_Notes')
	)
begin
	alter table [sma_TRN_Notes] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and Object_ID = OBJECT_ID(N'sma_TRN_Notes')
	)
begin
	alter table [sma_TRN_Notes] add [source_ref] VARCHAR(MAX) null;
end
go
