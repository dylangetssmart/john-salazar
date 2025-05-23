/* ######################################################################################
description: Creates an indexed version of needles..cases

steps:
	-

usage_instructions:
	-

dependencies:
	- 

notes:
	-
#########################################################################################
*/

USE JohnSalazar_Needles
GO

IF EXISTS (select * from sys.objects where name='cases_Indexed' and type='U')
BEGIN
	DROP TABLE [dbo].[cases_Indexed]
END
GO

----------

CREATE TABLE [dbo].[cases_Indexed](
	[casenum] [int] NULL,
	[alt_case_num] [nvarchar](75) NULL,
	[date_of_incident] [datetime2](0) NULL,
	[date_opened] [datetime2](0) NULL,
	[lim_date] [datetime2](0) NULL,
	[lim_stat] [nvarchar](1) NULL,
	[matcode] [nvarchar](3) NULL,
	[staff_1] [nvarchar](8) NULL,
	[staff_2] [nvarchar](8) NULL,
	[staff_3] [nvarchar](8) NULL,
	[staff_4] [nvarchar](8) NULL,
	[close_date] [datetime2](0) NULL,
	[case_date_1] [datetime2](0) NULL,
	[case_date_2] [datetime2](0) NULL,
	[case_date_3] [datetime2](0) NULL,
	[case_date_5] [datetime2](0) NULL,
	[case_date_4] [datetime2](0) NULL,
	[referred_link] [int] NULL,
	[referred_link_location] [int] NULL,
	[class] [nvarchar](3) NULL,
	[group_id] [int] NULL,
	[group_id_location] [int] NULL,
	[synopsis] [nvarchar](max) NULL,
	[ressign_date] [datetime2](0) NULL,
	[case_date_6] [datetime2](0) NULL,
	[litigation_title] [nvarchar](10) NULL,
	[court_link] [int] NULL,
	[court_link_location] [int] NULL,
	[judge_link] [int] NULL,
	[judge_link_location] [int] NULL,
	[docket] [nvarchar](35) NULL,
	[dormant] [nvarchar](1) NULL,
	[special_note] [nvarchar](max) NULL,
	[staff_5] [nvarchar](8) NULL,
	[staff_6] [nvarchar](8) NULL,
	[staff_7] [nvarchar](8) NULL,
	[staff_8] [nvarchar](8) NULL,
	[staff_9] [nvarchar](8) NULL,
	[staff_10] [nvarchar](8) NULL,
	[case_date_7] [datetime2](0) NULL,
	[case_date_8] [datetime2](0) NULL,
	[case_date_9] [datetime2](0) NULL,
	[open_status] [nvarchar](1) NULL,
	[case_title] [nvarchar](200) NULL,
	[alt_case_num_2] [nvarchar](75) NULL,
	[referred_to_id] [int] NULL,
	[referred_to_loc] [int] NULL,
	[intake_date] [datetime2](0) NULL,
	[intake_time] [datetime2](0) NULL,
	[intake_staff] [nvarchar](8) NULL,
	[import_date] [datetime2](0) NULL,
	[doc_default_path] [nvarchar](255) NULL,
	[bill_to_id] [int] NULL,
	[bill_to_location] [int] NULL,
	[last_modified] [datetime2](0) NULL,
	[date_created] [datetime2](0) NULL,
	[staff_created] [nvarchar](8) NULL,
	[date_modified] [datetime2](0) NULL,
	[staff_modified] [nvarchar](8) NULL,
	[TableIndex] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [IOC_Clustered_Index_cases_Indexed] PRIMARY KEY CLUSTERED 
(
	[TableIndex] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

----
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_cases_Indexed ON [cases_Indexed] (casenum);   
----
GO

INSERT INTO [cases_Indexed] (	
		[casenum],
		[alt_case_num],
		[date_of_incident],
		[date_opened],
		[lim_date],
		[lim_stat],
		[matcode],
		[staff_1],
		[staff_2],
		[staff_3],
		[staff_4],
		[close_date],
		[case_date_1],
		[case_date_2],
		[case_date_3],
		[case_date_5],
		[case_date_4],
		[referred_link],
		[referred_link_location],
		[class],
		[group_id],
		[group_id_location],
		[synopsis],
		[ressign_date],
		[case_date_6],
		[litigation_title],
		[court_link],
		[court_link_location],
		[judge_link],
		[judge_link_location],
		[docket],
		[dormant],
		[special_note],
		[staff_5],
		[staff_6],
		[staff_7],
		[staff_8],
		[staff_9],
		[staff_10],
		[case_date_7],
		[case_date_8],
		[case_date_9],
		[open_status],
		[case_title],
		[alt_case_num_2],
		[referred_to_id],
		[referred_to_loc],
		[intake_date],
		[intake_time],
		[intake_staff],
		[import_date],
		[doc_default_path],
		[bill_to_id],
		[bill_to_location],
		[last_modified],
		[date_created],
		[staff_created],
		[date_modified],
		[staff_modified]
)
SELECT	[casenum],
		[alt_case_num],
		[date_of_incident],
		[date_opened],
		[lim_date],
		[lim_stat],
		[matcode],
		[staff_1],
		[staff_2],
		[staff_3],
		[staff_4],
		[close_date],
		[case_date_1],
		[case_date_2],
		[case_date_3],
		[case_date_5],
		[case_date_4],
		[referred_link],
		[referred_link_location],
		[class],
		[group_id],
		[group_id_location],
		[synopsis],
		[ressign_date],
		[case_date_6],
		[litigation_title],
		[court_link],
		[court_link_location],
		[judge_link],
		[judge_link_location],
		[docket],
		[dormant],
		[special_note],
		[staff_5],
		[staff_6],
		[staff_7],
		[staff_8],
		[staff_9],
		[staff_10],
		[case_date_7],
		[case_date_8],
		[case_date_9],
		[open_status],
		[case_title],
		[alt_case_num_2],
		[referred_to_id],
		[referred_to_loc],
		[intake_date],
		[intake_time],
		[intake_staff],
		[import_date],
		[doc_default_path],
		[bill_to_id],
		[bill_to_location],
		[last_modified],
		[date_created],
		[staff_created],
		[date_modified],
		[staff_modified]
FROM [cases]

GO
  
DBCC DBREINDEX('cases_Indexed',' ',90) 

GO