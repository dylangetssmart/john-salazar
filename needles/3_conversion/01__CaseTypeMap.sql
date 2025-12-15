use [SA]
go

if exists (select * from sys.objects where name = 'CaseTypeMap')
begin
	drop table [dbo].[CaseTypeMap]
end

go

set ansi_nulls on
set quoted_identifier on
go

create table [dbo].[CaseTypeMap] (
	[matcode]					  [NVARCHAR](255) null,
	[header]					  [NVARCHAR](255) null,
	[description]				  [NVARCHAR](255) null,
	[SmartAdvocate Case Type]	  [NVARCHAR](255) null,
	[SmartAdvocate Case Sub Type] [NVARCHAR](255) null,
	[case_count]				  INT			  null
) on [PRIMARY]
go

-- Comment this section once you receive the mapping and use the insert at the bottom
insert into [dbo].[CaseTypeMap]
	(
		[matcode],
		[header],
		[description],
		[SmartAdvocate Case Type],
		[SmartAdvocate Case Sub Type],
		[case_count]
	)
	select distinct
		c.matcode						   as [matcode],
		m.header						   as [header],
		m.description					   as [description],
		COALESCE(m.description, c.matcode) as [SmartAdvocate Case Type],
		''								   as [SmartAdvocate Case Sub Type],
		COUNT(*)						   as [case_count]
	from [Needles]..cases c
	left join [Needles]..matter m
		on m.matcode = c.matcode
	group by c.matcode,
			 m.header,
			 m.description
	order by c.matcode
go

---------------------------------------------------------------------------------
-- PLACEHOLDER FOR DATA INSERTION
--
-- To insert your data, uncomment the section below and paste your Excel rows
-- into the VALUES list. Each row must be enclosed in parentheses and comma-separated.
---------------------------------------------------------------------------------

--insert into [dbo].[CaseTypeMap]
--	(
--		[matcode],
--		[header],
--		[description],
--		[SmartAdvocate Case Type],
--		[SmartAdvocate Case Sub Type],
--		[case_count]
--	)
--	values
--		-- START PASTE HERE: Replace the example row below with your data
--		-- ('CA', 'CA', 'Class Action', 'CA', '', 100)