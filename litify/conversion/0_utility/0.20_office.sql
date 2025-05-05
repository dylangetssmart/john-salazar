use ShinerSA
go

------------------------------------------------------------------------------------------------------
-- Table to store office values
------------------------------------------------------------------------------------------------------
begin

	if OBJECT_ID('conversion.office', 'U') is not null
	begin
		drop table conversion.office
	end

	create table conversion.office (
		OfficeName	   NVARCHAR(255),
		StateName	   NVARCHAR(100),
		PhoneNumber	   NVARCHAR(50),
		CaseGroup	   NVARCHAR(100),
		VenderCaseType NVARCHAR(25)
	);
	insert into conversion.office
		(
		OfficeName,
		StateName,
		PhoneNumber,
		CaseGroup,
		VenderCaseType
		)
	values (
	'Shiner Law Group',
	'Florida',
	'5617777700',
	'Litify',
	'ShinerCaseType'
	);
end

------------------------------------------------------------------------------------------------------
-- [1.0] Office
------------------------------------------------------------------------------------------------------
begin
	if not exists (
			select
				*
			from [sma_mst_offices]
			where office_name = (
					select
						OfficeName
					from conversion.office so
				)
		)
	begin
		insert into [sma_mst_offices]
			(
			[office_status],
			[office_name],
			[state_id],
			[is_default],
			[date_created],
			[user_created],
			[date_modified],
			[user_modified],
			[Letterhead],
			[UniqueContactId],
			[PhoneNumber]
			)
			select
				1					as [office_status],
				(
					select
						OfficeName
					from conversion.office so
				)					as [office_name],
				(
					select
						sttnStateID
					from sma_MST_States
					where sttsDescription = (
							select
								StateName
							from conversion.office so
						)
				)					as [state_id],
				1					as [is_default],
				GETDATE()			as [date_created],
				'dsmith'			as [user_created],
				GETDATE()			as [date_modified],
				'dbo'				as [user_modified],
				'LetterheadUt.docx' as [letterhead],
				null				as [uniquecontactid],
				(
					select
						phonenumber
					from conversion.office so
				)					as [phonenumber]
	end
end
