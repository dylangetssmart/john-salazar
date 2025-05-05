use ShinerSA
go

------------------------------------------------------------------------------------------------------
-- [3.0] Case Type
------------------------------------------------------------------------------------------------------
-- [3.1] VenderCaseType
if not exists (
		select
			*
		from sys.columns
		where Name = N'VenderCaseType'
			and object_id = OBJECT_ID(N'sma_MST_CaseType')
	)
begin
	alter table sma_MST_CaseType
	add VenderCaseType VARCHAR(100)
end

go