/* ###################################################################################
description: Handles common operations related to [sma_MST_EmailWebsite]
steps:
	- Add columns to [sma_MST_EmailWebsite]
		- saga
		- source_id
		- source_db
		- source_ref
	- Add columns to [sma_MST_OrgContacts]
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
			and Object_ID = OBJECT_ID(N'sma_MST_EmailWebsite')
	)
begin
	alter table [sma_MST_EmailWebsite] add [saga] INT null;
end
go

-- source_id
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and Object_ID = OBJECT_ID(N'sma_MST_EmailWebsite')
	)
begin
	alter table [sma_MST_EmailWebsite] add [source_id] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and Object_ID = OBJECT_ID(N'sma_MST_EmailWebsite')
	)
begin
	alter table [sma_MST_EmailWebsite] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and Object_ID = OBJECT_ID(N'sma_MST_EmailWebsite')
	)
begin
	alter table [sma_MST_EmailWebsite] add [source_ref] VARCHAR(MAX) null;
end
go