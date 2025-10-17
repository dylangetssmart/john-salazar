/* ###################################################################################
description: Handles common operations related to [sma_MST_IndvContacts]
steps:
	- Add columns to [sma_MST_Users]
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

-- saga
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

-- source_id
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and object_id = OBJECT_ID(N'sma_MST_Users')
	)
begin
	alter table [sma_MST_Users] add [source_id] VARCHAR(MAX) null;
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