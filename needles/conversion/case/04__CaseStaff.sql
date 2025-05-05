/*---
group: load
order: 5
description: Update contact types for attorneys
---*/

/* ###################################################################################
description: Handles common operations related to [sma_MST_IndvContacts]
steps:
	- Insert sub-role codes from case staff mapping > [sma_MST_SubRoleCode]
	- Insert case staff from staff_1 through staff_4 > [sma_TRN_CaseStaff]	
usage_instructions:
	- update values for [conversion].[office]
dependencies:
	- 
notes:
	-
*/

use [JohnSalazar_SA]
go

/* ------------------------------------------------------------------------------
Create staff roles if they do not exist
*/
--insert into [sma_MST_SubRoleCode]
--	(
--		srcsDscrptn,
--		srcnRoleID
--	)
--	(
--	select
--		'Assigned Attorney',
--		10
--	union all
--	select
--		'Case Manager',
--		10
--	union all
--	select
--		'Secondary Case Manager',
--		10
--	union all
--	select
--		'Litigation Staff',
--		10
--	union all
--	select
--		'Managing Attorney',
--		10
--	)
--	except
--	select
--		srcsDscrptn,
--		srcnRoleID
--	from [sma_MST_SubRoleCode]


alter table [sma_TRN_caseStaff] disable trigger all
go

/* ------------------------------------------------------------------------------
Use this block to hardcode staff_1 through staff_10 with "Staff"
*/

-- Declare variables
DECLARE @i INT = 1;
DECLARE @sql NVARCHAR(MAX);
DECLARE @staffColumn NVARCHAR(20);

-- Loop through staff_1 to staff_10
WHILE @i <= 10
BEGIN
    -- Set the current staff column
    SET @staffColumn = 'staff_' + CAST(@i AS NVARCHAR(2));

    -- Create the dynamic SQL query
    SET @sql = '
    INSERT INTO sma_TRN_caseStaff 
    (
           [cssnCaseID]
          ,[cssnStaffID]
          ,[cssnRoleID]
          ,[csssComments]
          ,[cssdFromDate]
          ,[cssdToDate]
          ,[cssnRecUserID]
          ,[cssdDtCreated]
          ,[cssnModifyUserID]
          ,[cssdDtModified]
          ,[cssnLevelNo]
    )
    SELECT 
        CAS.casnCaseID              as [cssnCaseID],
        U.usrnContactID             as [cssnStaffID],
        (
            select sbrnSubRoleId
            from sma_MST_SubRole
            where sbrsDscrptn=''Staff'' and sbrnRoleID=10
        )                           as [cssnRoleID],
        null                        as [csssComments],
        null                        as cssdFromDate,
        null                        as cssdToDate,
        368                         as cssnRecUserID,
        getdate()                   as [cssdDtCreated],
        null                        as [cssnModifyUserID],
        null                        as [cssdDtModified],
        0                           as cssnLevelNo
    FROM [JohnSalazar_Needles].[dbo].[cases_Indexed] C
    JOIN [sma_TRN_cases] CAS on CAS.cassCaseNumber = convert(varchar,C.casenum)
    JOIN [sma_MST_Users] U on ( U.source_id = C.' + @staffColumn + ' )
    ';

    -- Execute the dynamic SQL query
    EXEC sp_executesql @sql;

    -- Increment the counter
    SET @i = @i + 1;
END
GO

--/* ------------------------------------------------------------------------------
--staff_1 = Assigned Attorney
--*/
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

--/* ------------------------------------------------------------------------------
--staff_2 = Case Manager
--*/
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

--/* ------------------------------------------------------------------------------
--staff_3 = Secondary Case Manager
--*/
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


--/* ------------------------------------------------------------------------------
--staff_4 = Litigation Staff
--*/
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
*/
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
*/
insert into sma_TRN_caseStaff
	(
		[cssnCaseID],
		[cssnStaffID],
		[cssnRoleID],
		[csssComments],
		[cssdFromDate],
		[cssdToDate],
		[cssnRecUserID],
		[cssdDtCreated],
		[cssnModifyUserID],
		[cssdDtModified],
		[cssnLevelNo]
	)
	select
		CAS.casnCaseID  as [cssnCaseID],
		U.usrnContactID as [cssnStaffID],
		(
			select
				sbrnSubRoleId
			from sma_MST_SubRole
			where sbrsDscrptn = 'Managing Attorney'
				and sbrnRoleID = 10
		)				as [cssnRoleID],
		null			as [csssComments],
		null			as cssdFromDate,
		null			as cssdToDate,
		368				as cssnRecUserID,
		GETDATE()		as [cssdDtCreated],
		null			as [cssnModifyUserID],
		null			as [cssdDtModified],
		0				as cssnLevelNo
	from [JohnSalazar_Needles].[dbo].[cases_Indexed] C
	join [sma_TRN_cases] CAS
		on CAS.cassCaseNumber = C.casenum
	join [sma_MST_Users] U
		on (U.source_id = C.staff_6)


/* ------------------------------------------------------------------------------
staff_7 =
*/

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
*/
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
*/
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
*/
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