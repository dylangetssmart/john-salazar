/* ###################################################################################
Script Name: Update Contact Types for Attorneys
Group: load
Order: 5

Description:
This script populates staff roles and assigns them to cases in the target system.

Steps:
  1. Insert sub-role codes into [sma_MST_SubRoleCode] based on values from the source spreadsheet.
      You must uncomment the INSERT block for [sma_MST_SubRoleCode] and ensure the `srcsDscrptn` values match the descriptions in your mapping spreadsheet.
  2. For each staff column (staff_1 through staff_10), insert role "Staff" into [sma_TRN_caseStaff] using dynamic SQL.
  3. (Optional) Use the static INSERT blocks for staff_1 through staff_4 if more precise role mapping is needed:
      Uncomment each applicable block and update the subquery filtering `sbrsDscrptn` to reflect the correct role (e.g., 'Assigned Attorney', 'Case Manager', etc.).

Usage Instructions:
  - Ensure the target database context (e.g., [JohnSalazar_SA]) is correct.
  - Update hardcoded values as needed (e.g., user IDs, date handling).
  - Replace 'Staff' or other role descriptions in the subqueries with the appropriate role text from your role mappings.
  - The source data is expected to be in [JohnSalazar_Needles].[dbo].[cases_Indexed] and mapped via [sma_MST_Users].

Dependencies:
  - [conversion].[office] (update if needed)
  - Role ID 10 must exist in [sma_MST_SubRole]
  - Source fields like `staff_1`, `staff_2`, etc., must map to `source_id` in [sma_MST_Users]

Notes:
  - Trigger disabling is included to avoid side effects; ensure triggers are re-enabled afterward if needed.
  - Use dynamic inserts for general "Staff" assignments and static inserts for mapped role specificity.
  - Contact your data mapping analyst if sub-role names differ from spreadsheet.
################################################################################### */


use [JohnSalazar_SA]
go

/* ------------------------------------------------------------------------------
Create necessary staff roles
- Update srcsDscrptn values with SmartAdvocate Roles from the mapping spreadsheet
*/ ------------------------------------------------------------------------------

insert into [sma_MST_SubRoleCode]
	(
		srcsDscrptn,
		srcnRoleID
	)
	(
	select
		'Assigned Attorney',
		10
	union all
	select
		'Case Manager',
		10
	union all
	select
		'Secondary Case Manager',
		10
	union all
	select
		'Litigation Staff',
		10
	union all
	select
		'Managing Attorney',
		10
	)
	except
	select
		srcsDscrptn,
		srcnRoleID
	from [sma_MST_SubRoleCode]


alter table [sma_TRN_caseStaff] disable trigger all
go

/* ------------------------------------------------------------------------------
Use this block to hardcode staff_1 through staff_10 with "Staff"
*/ ------------------------------------------------------------------------------

---- Declare variables
--DECLARE @i INT = 1;
--DECLARE @sql NVARCHAR(MAX);
--DECLARE @staffColumn NVARCHAR(20);

---- Loop through staff_1 to staff_10
--WHILE @i <= 10
--BEGIN
--    -- Set the current staff column
--    SET @staffColumn = 'staff_' + CAST(@i AS NVARCHAR(2));

--    -- Create the dynamic SQL query
--    SET @sql = '
--    INSERT INTO sma_TRN_caseStaff 
--    (
--           [cssnCaseID]
--          ,[cssnStaffID]
--          ,[cssnRoleID]
--          ,[csssComments]
--          ,[cssdFromDate]
--          ,[cssdToDate]
--          ,[cssnRecUserID]
--          ,[cssdDtCreated]
--          ,[cssnModifyUserID]
--          ,[cssdDtModified]
--          ,[cssnLevelNo]
--    )
--    SELECT 
--        CAS.casnCaseID              as [cssnCaseID],
--        U.usrnContactID             as [cssnStaffID],
--        (
--            select sbrnSubRoleId
--            from sma_MST_SubRole
--            where sbrsDscrptn=''Staff'' and sbrnRoleID=10
--        )                           as [cssnRoleID],
--        null                        as [csssComments],
--        null                        as cssdFromDate,
--        null                        as cssdToDate,
--        368                         as cssnRecUserID,
--        getdate()                   as [cssdDtCreated],
--        null                        as [cssnModifyUserID],
--        null                        as [cssdDtModified],
--        0                           as cssnLevelNo
--    FROM [JohnSalazar_Needles].[dbo].[cases_Indexed] C
--    JOIN [sma_TRN_cases] CAS on CAS.cassCaseNumber = convert(varchar,C.casenum)
--    JOIN [sma_MST_Users] U on ( U.source_id = C.' + @staffColumn + ' )
--    ';

--    -- Execute the dynamic SQL query
--    EXEC sp_executesql @sql;

--    -- Increment the counter
--    SET @i = @i + 1;
--END
--GO

/* ------------------------------------------------------------------------------
staff_1 = 
*/ ------------------------------------------------------------------------------

--insert into sma_TRN_caseStaff
--	(
--		[cssnCaseID],
--		[cssnStaffID],
--		[cssnRoleID],
--		[csssComments],
--		[cssdFromDate],
--		[cssdToDate],
--		[cssnRecUserID],
--		[cssdDtCreated],
--		[cssnModifyUserID],
--		[cssdDtModified],
--		[cssnLevelNo]
--	)
--	select
--		CAS.casnCaseID  as [cssnCaseID],
--		U.usrnContactID as [cssnStaffID]
--		,
--		(
--			select
--				sbrnSubRoleId
--			from sma_MST_SubRole
--			where sbrsDscrptn = 'Assigned Attorney'
--				and sbrnRoleID = 10
--		)				as [cssnRoleID],
--		null			as [csssComments],
--		null			as cssdFromDate,
--		null			as cssdToDate,
--		368				as cssnRecUserID,
--		GETDATE()		as [cssdDtCreated],
--		null			as [cssnModifyUserID],
--		null			as [cssdDtModified],
--		0				as cssnLevelNo
--	from [JohnSalazar_Needles].[dbo].[cases_Indexed] C
--	inner join [sma_TRN_cases] CAS
--		on CAS.cassCaseNumber = C.casenum
--	inner join [sma_MST_Users] U
--		on (U.source_id = C.staff_1)

/* ------------------------------------------------------------------------------
staff_2 = 
*/ ------------------------------------------------------------------------------

--insert into sma_TRN_caseStaff
--	(
--		[cssnCaseID],
--		[cssnStaffID],
--		[cssnRoleID],
--		[csssComments],
--		[cssdFromDate],
--		[cssdToDate],
--		[cssnRecUserID],
--		[cssdDtCreated],
--		[cssnModifyUserID],
--		[cssdDtModified],
--		[cssnLevelNo]
--	)
--	select
--		CAS.casnCaseID  as [cssnCaseID],
--		U.usrnContactID as [cssnStaffID]
--		,
--		(
--			select
--				sbrnSubRoleId
--			from sma_MST_SubRole
--			where sbrsDscrptn = 'Case Manager'
--				and sbrnRoleID = 10
--		)				as [cssnRoleID],
--		null			as [csssComments],
--		null			as cssdFromDate,
--		null			as cssdToDate,
--		368				as cssnRecUserID,
--		GETDATE()		as [cssdDtCreated],
--		null			as [cssnModifyUserID],
--		null			as [cssdDtModified],
--		0				as cssnLevelNo
--	from [JohnSalazar_Needles].[dbo].[cases_Indexed] C
--	join [sma_TRN_cases] CAS
--		on CAS.cassCaseNumber = C.casenum
--	join [sma_MST_Users] U
--		on (U.source_id = C.staff_2)

/* ------------------------------------------------------------------------------
staff_3 = 
*/ ------------------------------------------------------------------------------

--insert into sma_TRN_caseStaff
--	(
--		[cssnCaseID],
--		[cssnStaffID],
--		[cssnRoleID],
--		[csssComments],
--		[cssdFromDate],
--		[cssdToDate],
--		[cssnRecUserID],
--		[cssdDtCreated],
--		[cssnModifyUserID],
--		[cssdDtModified],
--		[cssnLevelNo]
--	)
--	select
--		CAS.casnCaseID  as [cssnCaseID],
--		U.usrnContactID as [cssnStaffID]
--		,
--		(
--			select
--				sbrnSubRoleId
--			from sma_MST_SubRole
--			where sbrsDscrptn = 'Secondary Case Manager'
--				and sbrnRoleID = 10
--		)				as [cssnRoleID],
--		null			as [csssComments],
--		null			as cssdFromDate,
--		null			as cssdToDate,
--		368				as cssnRecUserID,
--		GETDATE()		as [cssdDtCreated],
--		null			as [cssnModifyUserID],
--		null			as [cssdDtModified],
--		0				as cssnLevelNo
--	from [JohnSalazar_Needles].[dbo].[cases_Indexed] C
--	join [sma_TRN_cases] CAS
--		on CAS.cassCaseNumber = C.casenum
--	join [sma_MST_Users] U
--		on (U.source_id = C.staff_3)

/* ------------------------------------------------------------------------------
staff_4 = 
*/ ------------------------------------------------------------------------------

--insert into sma_TRN_caseStaff
--	(
--		[cssnCaseID],
--		[cssnStaffID],
--		[cssnRoleID],
--		[csssComments],
--		[cssdFromDate],
--		[cssdToDate],
--		[cssnRecUserID],
--		[cssdDtCreated],
--		[cssnModifyUserID],
--		[cssdDtModified],
--		[cssnLevelNo]
--	)
--	select
--		CAS.casnCaseID  as [cssnCaseID],
--		U.usrnContactID as [cssnStaffID],
--		(
--			select
--				sbrnSubRoleId
--			from sma_MST_SubRole
--			where sbrsDscrptn = 'Litigation Staff'
--				and sbrnRoleID = 10
--		)				as [cssnRoleID],
--		null			as [csssComments],
--		null			as cssdFromDate,
--		null			as cssdToDate,
--		368				as cssnRecUserID,
--		GETDATE()		as [cssdDtCreated],
--		null			as [cssnModifyUserID],
--		null			as [cssdDtModified],
--		0				as cssnLevelNo
--	from [JohnSalazar_Needles].[dbo].[cases_Indexed] C
--	inner join [sma_TRN_cases] CAS
--		on CAS.cassCaseNumber = C.casenum
--	inner join [sma_MST_Users] U
--		on (U.source_id = C.staff_4)

/* ------------------------------------------------------------------------------
staff_5 = 
*/ ------------------------------------------------------------------------------

--insert into sma_TRN_caseStaff 
--(
--       [cssnCaseID]
--      ,[cssnStaffID]
--      ,[cssnRoleID]
--      ,[csssComments]
--      ,[cssdFromDate]
--      ,[cssdToDate]
--      ,[cssnRecUserID]
--      ,[cssdDtCreated]
--      ,[cssnModifyUserID]
--      ,[cssdDtModified]
--      ,[cssnLevelNo]
--)
--select 
--	CAS.casnCaseID			  as [cssnCaseID],
--	U.usrnContactID		  as [cssnStaffID],
--	(select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Staff' and sbrnRoleID=10 )	 as [cssnRoleID],
--	null					  as [csssComments],
--	null					  as cssdFromDate,
--	null					  as cssdToDate,
--	368					  as cssnRecUserID,
--	getdate()				  as [cssdDtCreated],
--	null					  as [cssnModifyUserID],
--	null					  as [cssdDtModified],
--	0					  as cssnLevelNo
--FROM [JohnSalazar_Needles].[dbo].[cases_Indexed] C
--inner join [JohnSalazar_SA].[dbo].[sma_TRN_cases] CAS on CAS.cassCaseNumber = C.casenum
--inner join [JohnSalazar_SA].[dbo].[sma_MST_Users] U on ( U.saga = C.staff_5 )
--*/

/* ------------------------------------------------------------------------------
staff_6 = Managing Attorney
*/ ------------------------------------------------------------------------------

--insert into sma_TRN_caseStaff
--	(
--		[cssnCaseID],
--		[cssnStaffID],
--		[cssnRoleID],
--		[csssComments],
--		[cssdFromDate],
--		[cssdToDate],
--		[cssnRecUserID],
--		[cssdDtCreated],
--		[cssnModifyUserID],
--		[cssdDtModified],
--		[cssnLevelNo]
--	)
--	select
--		CAS.casnCaseID  as [cssnCaseID],
--		U.usrnContactID as [cssnStaffID],
--		(
--			select
--				sbrnSubRoleId
--			from sma_MST_SubRole
--			where sbrsDscrptn = 'Managing Attorney'
--				and sbrnRoleID = 10
--		)				as [cssnRoleID],
--		null			as [csssComments],
--		null			as cssdFromDate,
--		null			as cssdToDate,
--		368				as cssnRecUserID,
--		GETDATE()		as [cssdDtCreated],
--		null			as [cssnModifyUserID],
--		null			as [cssdDtModified],
--		0				as cssnLevelNo
--	from [JohnSalazar_Needles].[dbo].[cases_Indexed] C
--	join [sma_TRN_cases] CAS
--		on CAS.cassCaseNumber = C.casenum
--	join [sma_MST_Users] U
--		on (U.source_id = C.staff_6)


/* ------------------------------------------------------------------------------
staff_7 = 
*/ ------------------------------------------------------------------------------

--insert into sma_TRN_caseStaff 
--(
--       [cssnCaseID]
--      ,[cssnStaffID]
--      ,[cssnRoleID]
--      ,[csssComments]
--      ,[cssdFromDate]
--      ,[cssdToDate]
--      ,[cssnRecUserID]
--      ,[cssdDtCreated]
--      ,[cssnModifyUserID]
--      ,[cssdDtModified]
--      ,[cssnLevelNo]
--)
--select 
--	CAS.casnCaseID			  as [cssnCaseID],
--	U.usrnContactID		  as [cssnStaffID],
--	(select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Staff' and sbrnRoleID=10 )	 as [cssnRoleID],
--	null					  as [csssComments],
--	null					  as cssdFromDate,
--	null					  as cssdToDate,
--	368					  as cssnRecUserID,
--	getdate()				  as [cssdDtCreated],
--	null					  as [cssnModifyUserID],
--	null					  as [cssdDtModified],
--	0					  as cssnLevelNo
--FROM [JohnSalazar_Needles].[dbo].[cases_Indexed] C
--inner join [JohnSalazar_SA].[dbo].[sma_TRN_cases] CAS on CAS.cassCaseNumber = C.casenum
--inner join [JohnSalazar_SA].[dbo].[sma_MST_Users] U on ( U.saga = C.staff_7 )


/* ------------------------------------------------------------------------------
staff_8 = 
*/ ------------------------------------------------------------------------------

--insert into sma_TRN_caseStaff 
--(
--       [cssnCaseID]
--      ,[cssnStaffID]
--      ,[cssnRoleID]
--      ,[csssComments]
--      ,[cssdFromDate]
--      ,[cssdToDate]
--      ,[cssnRecUserID]
--      ,[cssdDtCreated]
--      ,[cssnModifyUserID]
--      ,[cssdDtModified]
--      ,[cssnLevelNo]
--)
--select 
--	CAS.casnCaseID			  as [cssnCaseID],
--	U.usrnContactID		  as [cssnStaffID],
--	(select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Staff' and sbrnRoleID=10 )	 as [cssnRoleID],
--	null					  as [csssComments],
--	null					  as cssdFromDate,
--	null					  as cssdToDate,
--	368					  as cssnRecUserID,
--	getdate()				  as [cssdDtCreated],
--	null					  as [cssnModifyUserID],
--	null					  as [cssdDtModified],
--	0					  as cssnLevelNo
--FROM [JohnSalazar_Needles].[dbo].[cases_Indexed] C
--inner join [JohnSalazar_SA].[dbo].[sma_TRN_cases] CAS on CAS.cassCaseNumber = C.casenum
--inner join [JohnSalazar_SA].[dbo].[sma_MST_Users] U on ( U.saga = C.staff_8 )
--*/

/* ------------------------------------------------------------------------------
staff_9 = 
*/ ------------------------------------------------------------------------------

--INSERT INTO sma_TRN_caseStaff 
--(
--       [cssnCaseID]
--      ,[cssnStaffID]
--      ,[cssnRoleID]
--      ,[csssComments]
--      ,[cssdFromDate]
--      ,[cssdToDate]
--      ,[cssnRecUserID]
--      ,[cssdDtCreated]
--      ,[cssnModifyUserID]
--      ,[cssdDtModified]
--      ,[cssnLevelNo]
--)
--SELECT 
--	CAS.casnCaseID			  as [cssnCaseID],
--	U.usrnContactID		  as [cssnStaffID],
--	(select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Intake Paralegal' and sbrnRoleID=10 )	 as [cssnRoleID],
--	null					  as [csssComments],
--	null					  as cssdFromDate,
--	null					  as cssdToDate,
--	368					  as cssnRecUserID,
--	getdate()				  as [cssdDtCreated],
--	null					  as [cssnModifyUserID],
--	null					  as [cssdDtModified],
--	0					  as cssnLevelNo
--FROM [JohnSalazar_Needles].[dbo].[cases_Indexed] C
--JOIN sma_TRN_cases CAS on CAS.cassCaseNumber = C.casenum
--JOIN sma_MST_Users U on ( U.saga = C.staff_9 )

/* ------------------------------------------------------------------------------
staff_10 = 
*/ ------------------------------------------------------------------------------

--insert into sma_TRN_caseStaff 
--(
--       [cssnCaseID]
--      ,[cssnStaffID]
--      ,[cssnRoleID]
--      ,[csssComments]
--      ,[cssdFromDate]
--      ,[cssdToDate]
--      ,[cssnRecUserID]
--      ,[cssdDtCreated]
--      ,[cssnModifyUserID]
--      ,[cssdDtModified]
--      ,[cssnLevelNo]
--)
--select 
--	CAS.casnCaseID			  as [cssnCaseID],
--	U.usrnContactID		  as [cssnStaffID],
--	(select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Staff' and sbrnRoleID=10 )	 as [cssnRoleID],
--	null					  as [csssComments],
--	null					  as cssdFromDate,
--	null					  as cssdToDate,
--	368					  as cssnRecUserID,
--	getdate()				  as [cssdDtCreated],
--	null					  as [cssnModifyUserID],
--	null					  as [cssdDtModified],
--	0					  as cssnLevelNo
--FROM [JohnSalazar_Needles].[dbo].[cases_Indexed] C
--inner join [JohnSalazar_SA].[dbo].[sma_TRN_cases] CAS on CAS.cassCaseNumber = C.casenum
--inner join [JohnSalazar_SA].[dbo].[sma_MST_Users] U on ( U.saga = C.staff_10 )

alter table [sma_TRN_caseStaff] enable trigger all
go