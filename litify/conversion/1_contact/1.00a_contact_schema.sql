/* ###################################################################################
description: Handles common operations related to [sma_MST_IndvContacts]
steps:
	- Add columns to [sma_MST_IndvContacts]
		- saga
		- saga_char
		- source_db
		- source_ref
	- Add columns to [sma_MST_OrgContacts]
		- saga
		- saga_char
		- source_db
		- source_ref
usage_instructions:
	-
dependencies:
	- 
notes:
	-
*/

use ShinerSA
go

---------------------------------------------------
-- sma_MST_IndvContacts
---------------------------------------------------

-- saga
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and Object_ID = OBJECT_ID(N'sma_MST_IndvContacts')
	)
begin
	alter table [sma_MST_IndvContacts] add [saga] INT null;
end
go

-- saga (INT)
-- Check if the column 'saga' exists and if it's not of type INT, change its type
if exists (
		select
			1
		from sys.columns
		where Name = N'saga'
			and Object_ID = OBJECT_ID(N'sma_MST_IndvContacts')
	)
begin
	-- Check the data type of the 'saga' column
	if exists (
			select
				1
			from INFORMATION_SCHEMA.COLUMNS
			where TABLE_NAME = N'sma_MST_IndvContacts'
				and COLUMN_NAME = N'saga'
				and DATA_TYPE <> 'int'
		)
	begin
		-- Drop and re-add the 'saga' column as INT if it exists with a different data type
		alter table [sma_MST_IndvContacts] drop column [saga];
		alter table [sma_MST_IndvContacts] add [saga] INT null;
	end
end
else
begin
	-- Add the 'saga' column if it does not exist
	alter table [sma_MST_IndvContacts] add [saga] INT null;
end
go

go

-- saga_char
/*
the newly agreed upon standard would be "source_id", but these scripts were already written with "saga_char"
*/
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and Object_ID = OBJECT_ID(N'sma_MST_IndvContacts')
	)
begin
	alter table [sma_MST_IndvContacts] add [saga_char] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and Object_ID = OBJECT_ID(N'sma_MST_IndvContacts')
	)
begin
	alter table [sma_MST_IndvContacts] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and Object_ID = OBJECT_ID(N'sma_MST_IndvContacts')
	)
begin
	alter table [sma_MST_IndvContacts] add [source_ref] VARCHAR(MAX) null;
end
go

---------------------------------------------------
-- [sma_MST_OrgContacts]
---------------------------------------------------

alter table sma_MST_OrgContacts
alter column saga int
go

-- saga
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and Object_ID = OBJECT_ID(N'sma_MST_OrgContacts')
	)
begin
	alter table [sma_MST_OrgContacts] add [saga] INT null;
end
go

/*
- saga_char
- the newly agreed upon standard would be "source_id", but these scripts were already written with "saga_char"
*/
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and Object_ID = OBJECT_ID(N'sma_MST_OrgContacts')
	)
begin
	alter table [sma_MST_OrgContacts] add [saga_char] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and Object_ID = OBJECT_ID(N'sma_MST_OrgContacts')
	)
begin
	alter table [sma_MST_OrgContacts] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and Object_ID = OBJECT_ID(N'sma_MST_OrgContacts')
	)
begin
	alter table [sma_MST_OrgContacts] add [source_ref] VARCHAR(MAX) null;
end
go