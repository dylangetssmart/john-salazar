use ShinerSA
go

-- [1.0] Drop CaseTypeMap if exists
if exists (
		select
			*
		from sys.objects
		where Name = 'CaseTypeMap'
	)
begin
	drop table [dbo].[CaseTypeMap]
end
go

set ansi_nulls on
go

set quoted_identifier on
go

-- [1.1] Create CaseTypeMap
create table [dbo].[CaseTypeMap] (
	[LitifyCaseTypeID]			  [NVARCHAR](255),
	[CaseType]					  [NVARCHAR](255) null,
	--[LitigationType] [nvarchar](255) NULL,
	--[PracticeArea] [nvarchar](255) NULL,
	--[SmartAdvocate Case Group] [nvarchar](255) NULL,
	[SmartAdvocate Case Type]	  [NVARCHAR](255) null,
	[SmartAdvocate Case Sub Type] [NVARCHAR](255) null
) on [PRIMARY]


-- [1.2] Insert data
--insert into [dbo].[CaseTypeMap]
--	(
--	[LitifyCaseTypeID], [CaseType], [SmartAdvocate Case Type], [SmartAdvocate Case Sub Type]
--	)
--	select distinct
--		ct.Id	  as caseTypeID,
--		ct.[Name] as caseType,
--		ct.[Name] as [SmartAdvocate Case Type],
--		'Unknown' as [SmartAdvocate Case Sub Type]
--	from ShinerLitify..litify_pm__Matter__c m
--	join ShinerLitify..litify_pm__Case_Type__c ct
--		on ct.Id = m.litify_pm__Case_Type__c
--	where ct.Name in ('Automobile Accident',
--		'Premises Liability x',
--		'Other',
--		'Slip and Fall',
--		'Premises Liability',
--		'Business Law',
--		'General Injury',
--		'Medical Malpractice',
--		'Wrongful Death',
--		'Animal Incident',
--		'Dog Bite Injury',
--		'Product Liability',
--		'Food Poison',
--		'Workers Compensation',
--		'Burn Injury Liability',
--		'Employment Law',
--		'General',
--		'MVA - SPANISH SPEAKER')


insert into [dbo].[CaseTypeMap]
	(
	[LitifyCaseTypeID], [CaseType], [SmartAdvocate Case Type], [SmartAdvocate Case Sub Type]
	)
	values
	('a038Z00000eLi1cQAC', 'Automobile Accident', 'Auto Accident', ''),
	('a038Z00000aRVcFQAW', 'Premises Liability x', 'Premises', ''),
	('a038Z00000ZUDmdQAH', 'Other', 'Negligence', ''),
	('a038Z00000ZUDn4QAH', 'Slip and Fall', 'Premises', ''),
	('a038Z00000ZUDmyQAH', 'Premises Liability', 'Premises', ''),
	('a038Z00000ZUDnYQAX', 'Business Law', 'Business Law', ''),
	('a038Z00000ZUDn5QAH', 'General Injury', 'General Injury', ''),
	('a038Z00000ZUDmmQAH', 'Medical Malpractice', 'Medical Malpractice', ''),
	('a038Z00000ZUDmfQAH', 'Wrongful Death', 'Auto Accident Death', ''),
	('a038Z00000ZUDnIQAX', 'Animal Incident', 'Premises', ''),
	('a038Z00000aRVVWQA4', 'Dog Bite Injury', 'Dog Bite', ''),
	('a038Z00000ZUDmjQAH', 'Product Liability', 'Product Liability', ''),
	('a038Z00000jdFNdQAM', 'Food Poison', 'Premises', ''),
	('a038Z00000ZUDmzQAH', 'Workers Compensation', 'Workers Compensation Case', ''),
	('a038Z00000aRVVfQAO', 'Burn Injury Liability', 'Premises', ''),
	('a038Z00000iR91bQAC', 'Employment Law', 'Employment Law', ''),
	('a038Z00000jcslSQAQ', 'General', 'Negligence', ''),
	('a038Z00000jd3EaQAI', 'MVA - SPANISH SPEAKER', 'Auto Accident', '')
