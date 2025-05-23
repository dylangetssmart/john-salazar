use [JohnSalazar_SA]
go

/****** Object:  Table [dbo].[PartyRoles]    Script Date: 11/21/2018 11:22:46 AM ******/
set ansi_nulls on
go

set quoted_identifier on
go

if exists (
		select
			*
		from sys.tables
		where name = 'PartyRoles'
			and type = 'U'
	)
begin
	drop table PartyRoles
end

create table [dbo].[PartyRoles] (
	[Needles Roles] [NVARCHAR](255) null,
	[SA Roles]		[NVARCHAR](255) null,
	[SA Party]		[NVARCHAR](255) null
) on [PRIMARY]

go

-- ds 2024-06-24 // From live mapping
insert into [dbo].[PartyRoles]
	(
		[Needles Roles],
		[SA Roles],
		[SA Party]
	)
	select
		'Witness',
		'(P)-Witness',
		'Plaintiff'
	union
	select
		'Employer',
		'(P)-Employer',
		'Plaintiff'
	union
	select
		'Beneficiary',
		'(P)-Beneficiary',
		'Plaintiff'
	union
	select
		'Plntf-Deceased',
		'(P)-Decedent',
		'Plaintiff'
	union
	select
		'Potential Guard.',
		'(P)-Guardian',
		'Plaintiff'
	union
	select
		'Defendant',
		'(D)-Defendant',
		'Defendant'
	union
	select
		'Plntf-Minor',
		'(P)-Minor',
		'Plaintiff'
	union
	select
		'Potential Adm''r',
		'(P)-Administrator',
		'Plaintiff'
	union
	select
		'Plaintiff',
		'(P)-Plaintiff',
		'Plaintiff'
	union
	select
		'Parent/Guardian',
		'(P)-Parent/Guardian',
		'Plaintiff'
go

-- add non-typical roles to Other Contacts (sma_MST_OtherCasesContact)
-- Drop the sma_MST_OtherCasesContact table if it exists
--IF EXISTS (SELECT * FROM sys.tables WHERE name = 'sma_MST_OtherCasesContact' AND type = 'U')
--BEGIN 
--    DROP TABLE [dbo].[sma_MST_OtherCasesContact]
--END
--GO

---- Create the sma_MST_OtherCasesContact table
--CREATE TABLE [dbo].[sma_MST_OtherCasesContact](
--    [OtherCasesContactPKID] [int] IDENTITY(1,1) NOT NULL,
--    [OtherCasesID] [int] NULL,
--    [OtherCasesContactID] [int] NULL,
--    [OtherCasesContactCtgID] [int] NULL,
--    [OtherCaseContactAddressID] [int] NULL,
--    [OtherCasesContactRole] [varchar](500) NULL,
--    [OtherCasesCreatedUserID] [int] NULL,
--    [OtherCasesContactCreatedDt] [smalldatetime] NULL,
--    [OtherCasesModifyUserID] [int] NULL,
--    [OtherCasesContactModifieddt] [smalldatetime] NULL,
-- CONSTRAINT [PK_sma_MST_OtherCasesContact] PRIMARY KEY CLUSTERED 
--(
--    [OtherCasesContactPKID] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
--) ON [PRIMARY]

---- Create
----INSERT [SASkolrood_Needles].[dbo].[sma_MST_OtherCasesContact](
----	[OtherCasesContactRole]
----)
----SELECT 'Personal Representative' UNION
----SELECT 'Seller' UNION
----SELECT 'Voter' UNION
----SELECT 'Payee' UNION
----SELECT 'Family Member' UNION
----SELECT 'Buyer'
