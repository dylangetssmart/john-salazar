use ShinerSA
go

/*

select  c.*, m.*
From ShinerLitify..litify_pm__Matter__c m
JOIN ShinerLitify..litify_pm__Companion__c c on m.litify_pm__Companion__c = c.Id
where isnull(litify_pm__Companion__c,'')<>''

*/

---------------------------------------------------
--CREATE FUNCTION TO GET COMPANION PAIRS
---------------------------------------------------
if exists (
		select
			*
		from sys.objects
		where name = 'conversion.get_companion_pairs'
			and type = 'TF'
	)
begin
	drop function conversion.get_companion_pairs
end

go

create function [conversion].[get_companion_pairs] (@String NVARCHAR(4000),
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
		where name = 'conversion.Companion'
			and type = 'U'
	)
begin
	drop table conversion.Companion
end
go

create table conversion.Companion (
	companionID VARCHAR(100),
	caseids		VARCHAR(5000)
)
go

---(0)---
--truncate table Companion
--go

---------------------------------------------------
--POPUlATE COMPANION TABLE WITH NEEDLES GROUP NAMES
---------------------------------------------------
insert into conversion.Companion
	(
	companionID,
	caseids
	)
	select
		a.companionid,
		STUFF((
			select
				',' + CONVERT(VARCHAR, cas.casnCaseID)
			from ShinerLitify..litify_pm__Matter__c m
			join [sma_TRN_Cases] cas
				on cas.saga_char = m.id
			join ShinerLitify..litify_pm__Companion__c c
				on m.litify_pm__Companion__c = c.Id
			where m.litify_pm__Companion__c = a.companionid
			for XML path ('')
		), 1, 1, '') as caseids

	from (
		select distinct
			c.ID as companionid
		from ShinerLitify..litify_pm__Matter__c m
		join ShinerLitify..litify_pm__Companion__c c
			on m.litify_pm__Companion__c = c.Id
		where ISNULL(litify_pm__Companion__c, '') <> ''
	) a

go

--select
--	*
--from Companion
---------------------------------------------------
--CURSOR TO INSERT INTO OTHCASES
---------------------------------------------------
declare @caseids VARCHAR(5000)
declare inner_cursor cursor for select
	caseids
from conversion.Companion

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
	from conversion.get_companion_pairs(@caseids, ',')
	union
	select
		n,
		m,
		368,
		GETDATE()
	from conversion.get_companion_pairs(@caseids, ',')
	option (maxrecursion 0)

fetch next from inner_cursor into @caseids

end

close inner_cursor;
deallocate inner_cursor;


select
	*
from [sma_TRN_OthCases]
