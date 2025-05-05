use ShinerSA
go

-- saga (INT)
-- Check if the column 'saga' exists and if it's not of type INT, change its type
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and object_id = OBJECT_ID(N'sma_TRN_Cases')
	)
begin
	-- Add the 'saga' column if it does not exist
	alter table [sma_TRN_Cases] add [saga] INT null;
end
go

-- source_id
-- this should be source_id, but many scripts already use `saga_char`
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_TRN_Cases')
	)
begin
	alter table [sma_TRN_Cases] add [saga_char] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and object_id = OBJECT_ID(N'sma_TRN_Cases')
	)
begin
	alter table [sma_TRN_Cases] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and object_id = OBJECT_ID(N'sma_TRN_Cases')
	)
begin
	alter table [sma_TRN_Cases] add [source_ref] VARCHAR(MAX) null;
end
go


--------------------------------------------------------------------------------------------------------
---- Table to store office values
--------------------------------------------------------------------------------------------------------
--begin

--	if OBJECT_ID('conversion.office', 'U') is not null
--	begin
--		drop table conversion.office
--	end

--	create table conversion.office (
--		OfficeName	   NVARCHAR(255),
--		StateName	   NVARCHAR(100),
--		PhoneNumber	   NVARCHAR(50),
--		CaseGroup	   NVARCHAR(100),
--		VenderCaseType NVARCHAR(25)
--	);
--	insert into conversion.office
--		(
--		OfficeName,
--		StateName,
--		PhoneNumber,
--		CaseGroup,
--		VenderCaseType
--		)
--	values (
--	'Shiner Law Group',
--	'Florida',
--	'5617777700',
--	'Litify',
--	'ShinerCaseType'
--	);
--end

--------------------------------------------------------------------------------------------------------
---- [1.0] Office
--------------------------------------------------------------------------------------------------------
--begin
--	if not exists (
--			select
--				*
--			from [sma_mst_offices]
--			where office_name = (
--					select
--						OfficeName
--					from conversion.office so
--				)
--		)
--	begin
--		insert into [sma_mst_offices]
--			(
--			[office_status],
--			[office_name],
--			[state_id],
--			[is_default],
--			[date_created],
--			[user_created],
--			[date_modified],
--			[user_modified],
--			[Letterhead],
--			[UniqueContactId],
--			[PhoneNumber]
--			)
--			select
--				1					as [office_status],
--				(
--					select
--						OfficeName
--					from conversion.office so
--				)					as [office_name],
--				(
--					select
--						sttnStateID
--					from sma_MST_States
--					where sttsDescription = (
--							select
--								StateName
--							from conversion.office so
--						)
--				)					as [state_id],
--				1					as [is_default],
--				GETDATE()			as [date_created],
--				'dsmith'			as [user_created],
--				GETDATE()			as [date_modified],
--				'dbo'				as [user_modified],
--				'LetterheadUt.docx' as [letterhead],
--				null				as [uniquecontactid],
--				(
--					select
--						phonenumber
--					from conversion.office so
--				)					as [phonenumber]
--	end
--end
