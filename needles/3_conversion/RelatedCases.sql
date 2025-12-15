/*
Inserts Needles companion cases into the sma_TRN_OthCases table
Don't confused Related Cases with Other Cases!!
*/

use [SA]
go

---------------------------------------------------
--CREATE FUNCTION TO GET COMPANION PAIRS
---------------------------------------------------
if exists (
		select
			*
		from sys.objects
		where name = 'get_companion_pairs'
			and type = 'TF'
	)
begin
	drop function get_companion_pairs
end

go

create function [dbo].[get_companion_pairs] (@String NVARCHAR(4000),
@Delimiter NCHAR(1))
returns @RtnValue table (
	id INT identity (1, 1),
	m  INT,
	n  INT
)
as
begin
	declare @max INT
	select top 1
		@max = ID
	from dbo.Split_New(@String, @Delimiter)
	order by ID desc
	option (maxrecursion 0)
	declare @n INT = 1
	declare @m INT = 1

	while @n < @max + 1
	begin
	while @m < @n
	begin
	insert into @RtnValue
		(
			m,
			n
		)
		select
			(
				select
					Data
				from dbo.Split_New(@String, @Delimiter)
				where ID = @m
			),
			(
				select
					Data
				from dbo.Split(@String, @Delimiter)
				where ID = @n
			)
		option (maxrecursion 0)
	set @m = @m + 1
	end
	set @m = 1;
	set @n = @n + 1
	end
	return
end
go

---------------------------------------------------
--CREATE COMPANION TABLE
---------------------------------------------------
if exists (
		select
			*
		from sys.objects
		where name = 'Companion'
			and type = 'U'
	)
begin
	drop table Companion
end

go

create table Companion (
	group_ID INT,
	caseids	 VARCHAR(5000)
)
go

---(0)---
truncate table Companion
go

---------------------------------------------------
--POPUlATE COMPANION TABLE WITH NEEDLES GROUP NAMES
---------------------------------------------------
insert into Companion
	(
		group_id,
		caseids
	)
	select
		A.group_id,
		STUFF((
			select
				',' + CONVERT(VARCHAR, CAS.casnCaseID)
			from [Needles].[dbo].[cases_Indexed] C
			join [sma_TRN_Cases] CAS
				on CAS.cassCaseNumber = CONVERT(VARCHAR, C.casenum)
			join [Needles].[dbo].[companion_cases] CC
				on CC.group_id = C.group_id
			where CC.group_id = A.group_id
				and CC.group_id <> 0
			for XML path ('')
		), 1, 1, '') as CaseIDs

	from (
		select distinct
			cc.group_id
		from [Needles].[dbo].[cases] C
		join [Needles].[dbo].[companion_cases] CC
			on CC.group_id = C.group_id
		where CC.group_id <> 0
	) A

go

--select * From companion


--truncate table [sma_TRN_OthCases]
---------------------------------------------------
--CURSOR TO INSERT INTO OTHCASES
---------------------------------------------------
declare @caseids VARCHAR(5000)
declare inner_cursor cursor for select
	caseids
from Companion
where caseids is not null

open inner_cursor

fetch next from inner_cursor into @caseids

while @@FETCH_STATUS = 0
begin


insert into [sma_TRN_OthCases]
	(
		[otcnRelcaseID],
		[otcnOrgCaseID],
		[otcnUserId],
		[otcdDtCreated]
	)
	select
		m,
		n,
		368,
		GETDATE()
	from dbo.get_companion_pairs(@caseids, ',')
	union
	select
		n,
		m,
		368,
		GETDATE()
	from dbo.get_companion_pairs(@caseids, ',')
	option (maxrecursion 0)

fetch next from inner_cursor into @caseids

end

close inner_cursor;
deallocate inner_cursor;


--select * From companion