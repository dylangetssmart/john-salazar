use [SA]
go

if exists (select * from sys.objects where name = 'ValueCodeMap')
begin
	drop table [dbo].[ValueCodeMap]
end

go

set ansi_nulls on
set quoted_identifier on
go

create table [dbo].[ValueCodeMap] (
	[code]			  [NVARCHAR](50)  not null,
	[description]	  [NVARCHAR](255) null,
	[credit_or_debit] [NVARCHAR](10)  null,
	[due_to_firm]	  [NVARCHAR](1)	  null,
	[SA_Screen]		  [NVARCHAR](255) null,
	[SA_Field]		  [NVARCHAR](255) null,
	[status_or_type]  [NVARCHAR](50)  null,
	[Comment]		  [NVARCHAR](MAX) null,
	[value_count]	  INT			  null

	constraint [PK_ValueCodeMap] primary key clustered ([Code] asc)
) on [PRIMARY]
go

-- Comment this section once you receive the mapping and use the insert at the bottom
insert into [dbo].[ValueCodeMap]
	(
		[Code],
		[description],
		[credit_or_debit],
		[due_to_firm],
		[SA_Screen],
		[SA_Field],
		[status_or_type],
		[comment],
		[value_count]
	)
	select distinct
		v.code		   as [code],
		vc.description as [description],
		vc.c_d		   as [credit_or_debit],
		vc.dtf		   as [due_to_firm],
		''			   as [SA Section],
		''			   as [SA Screen],
		''			   as [SA Field],
		''			   as [status_or_type],
		''			   as [Comment],
		COUNT(*)	   as [value_count]
	from [Needles]..value v
	left join [Needles]..value_code vc
		on v.code = vc.code
	where
		v.code is not null
	group by v.code,
			 vc.description,
			 vc.c_d,
			 vc.dtf
	order by code
go

---------------------------------------------------------------------------------
-- PLACEHOLDER FOR DATA INSERTION
--
-- To insert your data, uncomment the section below and paste your Excel rows
-- into the VALUES list. Each row must be enclosed in parentheses and comma-separated.
---------------------------------------------------------------------------------

--insert into [dbo].[ValueCodeMap]
--	(
--		[Code],
--		[description],
--		[credit_or_debit],
--		[due_to_firm],
--		[SA_Screen],
--		[SA_Field],
--		[status_or_type],
--		[comment],
--		[value_count]
--	)
--	values
--		-- START PASTE HERE: Replace the example row below with all your (data, 'from', 'Excel', 'formatted', 'as', 'SQL', 'rows', NULL, NULL),
--		--('EXAMPLE', 'Example Placeholder Entry', 'X', 'Y', NULL, NULL, NULL, 'Pending', 'Replace this with your data')