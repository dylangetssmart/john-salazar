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

insert into [dbo].[PartyRoles]
	(
		[Needles Roles],
		[SA Roles],
		[SA Party]
	)
	SELECT 'Def Owner', '(D)-Defendant', 'Defendant' union
	SELECT 'Defendant', '(D)-Defendant', 'Defendant' UNION
	SELECT 'Guardian/Parent', '(P)-Plaintiff', 'Plaintiff' UNION
	--SELECT 'Recycle', '', '' UNION
	--SELECT 'Def Owner/Driver', '', 'Defendant' UNION
	SELECT 'Plaintiff', '(P)-Plaintiff', 'Plaintiff' UNION
	--SELECT 'Administrator', '', '' UNION
	SELECT 'Def Driver', '(D)-Defendant', 'Defendant' UNION
	SELECT 'Consortium Pltf', '(P)-Plaintiff', 'Plaintiff'
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
