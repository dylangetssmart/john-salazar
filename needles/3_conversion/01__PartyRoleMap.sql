use [SA]
go

if exists (select * from sys.objects where name = 'PartyRoleMap')
begin
	drop table [dbo].[PartyRoleMap]
end

go

set ansi_nulls on
set quoted_identifier on
go

create table [dbo].[PartyRoleMap] (
	[Needles Role] [NVARCHAR](255) null,
	[SA Role]	   [NVARCHAR](255) null,
	[SA Party]	   [NVARCHAR](255) null,
	[party_count]  INT			   null
) on [PRIMARY]


-- Comment this section once you receive the mapping and use the insert at the bottom
insert into [dbo].[PartyRoleMap]
	(
		[Needles Role],
		[SA Role],
		[SA Party],
		[party_count]
	)
	select distinct
		[role]	 as [Needles Role],
		''		 as [SA Role],
		''		 as [SA Party],
		COUNT(*) as [party_count]
	from [Needles]..party_Indexed
	where
		ISNULL([role], '') <> ''
	group by [role]
	order by [role]
go


---------------------------------------------------------------------------------
-- PLACEHOLDER FOR DATA INSERTION
--
-- To insert your data, uncomment the section below and paste your Excel rows
-- into the VALUES list. Each row must be enclosed in parentheses and comma-separated.
---------------------------------------------------------------------------------

--insert into [dbo].[PartyRoleMap]
--	(
--		[Needles Role],
--		[SA Role],
--		[SA Party],
--		[party_count]
--	)
--	values
--		-- START PASTE HERE: Replace the example row below with your data
--		-- ('Example', 'SA Role', 'SA Party', 100)