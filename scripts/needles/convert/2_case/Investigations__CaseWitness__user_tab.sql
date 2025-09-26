/*---
description: Insert Depositions from user_tab_data
steps:
	- Disable triggers, add breadcrumbs, create staging table
	- Insert a default deposition type if it doesn't exist.
	- Insert data from the staging table into [sma_TRN_Depositions].
usage_instructions: >
	1. Update the stored procedure BuildNeedlesUserTabStagingTable arguments
	2. Configure [sma_TRN_Depositions] insert as per client specifications
dependencies:
	- 
notes: >
	This script is designed to be reusable. The source data collection is
	abstracted into a CTE, making it clear what needs to change for a
	new project.
---*/

use JohnSalazar_SA
go

---
alter table [sma_TRN_CaseWitness] disable trigger all
go

exec AddBreadcrumbsToTable 'sma_TRN_CaseWitness'
go

exec dbo.BuildNeedlesUserTabStagingTable @SourceDatabase = 'JohnSalazar_Needles',
										 @TargetDatabase = 'JohnSalazar_SA',
										 @DataTableName	 = 'user_tab_data',
										 @StagingTable	 = 'staging_witnesses',
										 @ColumnList	 = '
Statement_Context,
Statement_Given_To,
Statement_Taken,
Type_of_Witness,
Witness_Notes,
Name,
Wit_Value_Code,
Ct_Rptr_Value_Code,
Video_Value_Code'
;
go
---

--select
--	*
--from JohnSalazar_SA..staging_witnesses

--select
--	*
--from SMA_MST_WitnessType smwt

/* --------------------------------------------------------------------------------------------------------------
Witness 1
*/
insert into [sma_TRN_CaseWitness]
	(
		[witnCaseID],
		[witnWitnesContactID],
		[witnWitnesAdID],
		[witnRoleID],
		[witnFavorable],
		[witnTestify],
		[witdStmtReqDate],
		[witdStmtDate],
		[witbHasRec],
		[witsDoc],
		[witsComment],
		[witnRecUserID],
		[witdDtCreated],
		[witnModifyUserID],
		[witdDtModified],
		[witnLevelNo]
	)
	select distinct
		c.casnCaseID as [witnCaseID],
		ioci.CID	 as [witnWitnesContactID],
		ioci.AID	 as [witnWitnesAdID],
		null		 as [witnRoleID],
		null		 as [witnFavorable],
		null		 as [witnTestify],
		null		 as [witdStmtReqDate],
		null		 as [witdStmtDate],
		null		 as [witbHasRec],
		null		 as [witsDoc],
		LEFT(ISNULL('Statement Context: ' + NULLIF(CONVERT(VARCHAR(MAX), sw.Statement_Context), '') + CHAR(13), '') +
		ISNULL('Statement Given To: ' + NULLIF(CONVERT(VARCHAR(MAX), sw.Statement_Given_To), '') + CHAR(13), '') +
		ISNULL('Statement Taken: ' + NULLIF(CONVERT(VARCHAR(MAX), sw.Statement_Taken), '') + CHAR(13), '') +
		ISNULL('Type of Witness: ' + NULLIF(CONVERT(VARCHAR(MAX), sw.Type_of_Witness), '') + CHAR(13), '') +
		ISNULL('Witness Notes: ' + NULLIF(CONVERT(VARCHAR(MAX), sw.Witness_Notes), '') + CHAR(13), '') +
		ISNULL('Wit Value Code: ' + NULLIF(CONVERT(VARCHAR(MAX), sw.Wit_Value_Code), '') + CHAR(13), '') +
		'', 200)	 as [witsComment],
		368			 as [witnRecUserID],
		GETDATE()	 as [witdDtCreated],
		null		 as [witnModifyUserID],
		null		 as [witdDtModified],
		null		 as [witnLevelNo]
	--select *
	from staging_witnesses sw
	join sma_TRN_Cases c
		on c.saga = sw.caseid
	join IndvOrgContacts_Indexed ioci
		on ioci.saga = sw.Name_CID
	where
		ISNULL(sw.Name_CID, '') <> ''
go

---
alter table [sma_TRN_CaseWitness] enable trigger all
go
---