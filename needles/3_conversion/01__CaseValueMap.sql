USE [SA]
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from sys.tables where name = 'CaseValueMap')
begin
	drop table CaseValueMap
end

CREATE TABLE [dbo].[CaseValueMap](
	[Needles_Case_Value] [nvarchar](255) NULL,
	[Case_Value_From] [float] NULL,
	[Case_Value_To] [float] NULL
) ON [PRIMARY]
GO
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$010-25K', 10000, 25000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$0-10K', 0, 10000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$025-50K', 25000, 50000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$050-100K', 50000, 100000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$050-75K', 50000, 75000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$075-100K', 75000, 100000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$100-150K', 100000, 150000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$100-250K', 100000, 250000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$10-25K', 10000, 25000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$150-200K', 150000, 200000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$200-250K', 200000, 250000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$250-500K', 250000, 500000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$25-50K', 25000, 50000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$300-400K', 300000, 400000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$400-500K', 400000, 500000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$500-1MIL', 500000, 1000000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$500-600K', 500000, 600000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$500-750K', 500000, 750000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$50-100K', 50000, 100000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$600-700K', 600000, 700000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$700-800K', 700000, 800000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$750-M', 750000, 1000000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$900-1MIL', 900000, 1000000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$M - M1.5', 1000000, 1500000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$M1.5 - M2', 1500000, 2000000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$M2-M2.5', 2000000, 2500000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$M2-M3', 2000000, 3000000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$M3-M4', 3000000, 4000000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$M4-M5', 4000000, 5000000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$M5 +', 5000000, 99999999)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$MILL +', 1000000, 99999999)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$MILL.75-2.0M', 1750000, 2000000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'$MILL-1.25M', 1000000, 1250000)
INSERT [dbo].[CaseValueMap] ([Needles_Case_Value], [Case_Value_From], [Case_Value_To]) VALUES (N'Companion', NULL, NULL)
