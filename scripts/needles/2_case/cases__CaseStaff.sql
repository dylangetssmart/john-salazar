/*---
description: >
  Insert case staff
source_tables:
  - [cases]
target_tables:
  - [sma_TRN_caseStaff]
target_screen:
  - Case Summary
depends_on:
---*/

/*******************************************************
 CASE STAFF INSERT SCRIPT  -  STAFF_1 .. STAFF_10

 HOW TO USE
 1. Copy the SmartAdvocate Role column from Excel.
 2. Paste it below inside the @pastedRoles string.
 3. Run the script.
    * You can paste fewer than 10 lines; only those slots load.
    * Blank lines are ignored.
*******************************************************/

use JohnSalazar_SA;
go

/* ---------- 1. PASTE ROLES HERE ---------- */
declare @pastedRoles VARCHAR(MAX) = '
Primary Case Handler
Secondary Case Handler
Review Attorney
Negotiator
Closing Specialist
Evidence Coordinator
Staff
Staff
File Custodian
Office Location
';
/* ------------------------------------------ */

/* 2. Ensure staging table exists, then clear it */
if OBJECT_ID('conversion.CaseStaffRoleMap', 'U') is null
begin
	create table conversion.CaseStaffRoleMap (
		StaffCol SYSNAME	  not null,
		RoleDesc VARCHAR(100) not null,
		RoleID	 INT		  not null
	);
end
else
	truncate table conversion.CaseStaffRoleMap;

	/* 3. Load pasted roles into the staging table */
	;

with Split
as
(
	select
		ROW_NUMBER() over (order by (
			select
				null
		))					as RowNum,
		LTRIM(RTRIM(value)) as RoleDesc
	from STRING_SPLIT(@pastedRoles, CHAR(10))
	where LTRIM(RTRIM(value)) <> ''
)
insert into conversion.CaseStaffRoleMap
	(
		StaffCol,
		RoleDesc,
		RoleID
	)
	select
		'staff_' + CAST(RowNum as VARCHAR(2)) as StaffCol,
		RoleDesc,
		10									  as RoleID
	from Split
	where
		RowNum <= 10;   -- staff_1 through staff_10 only

/* 4. Insert any missing sub‑role codes */
insert into sma_MST_SubRoleCode
	(
		srcsDscrptn,
		srcnRoleID
	)
	select distinct
		RoleDesc,
		RoleID
	from conversion.CaseStaffRoleMap
	except
	select
		srcsDscrptn,
		srcnRoleID
	from sma_MST_SubRoleCode;
go


/* 5. Bulk insert case‑staff records */
alter table sma_TRN_caseStaff disable trigger all;
go

insert into sma_TRN_caseStaff
	(
		cssnCaseID,
		cssnStaffID,
		cssnRoleID,
		csssComments,
		cssdFromDate,
		cssdToDate,
		cssnRecUserID,
		cssdDtCreated,
		cssnModifyUserID,
		cssdDtModified,
		cssnLevelNo
	)
	select
		cas.casnCaseID,
		u.usrnContactID,
		sr.sbrnSubRoleId,
		null,
		null,
		null,
		368,               -- modify if needed
		GETDATE(),
		null,
		null,
		0
	from JohnSalazar_Needles.dbo.cases_Indexed as c
	join sma_TRN_cases as cas
		on cas.cassCaseNumber = CONVERT(VARCHAR(50), c.casenum)
	cross apply (
	values
	('staff_1', c.staff_1),
	('staff_2', c.staff_2),
	('staff_3', c.staff_3),
	('staff_4', c.staff_4),
	('staff_5', c.staff_5),
	('staff_6', c.staff_6),
	('staff_7', c.staff_7),
	('staff_8', c.staff_8),
	('staff_9', c.staff_9),
	('staff_10', c.staff_10)
	) as x (StaffCol, SourceID)
	join conversion.CaseStaffRoleMap as map
		on map.StaffCol = x.StaffCol
	join sma_MST_Users as u
		on u.source_id = x.SourceID
	join sma_MST_SubRole as sr
		on sr.sbrsDscrptn = map.RoleDesc
			and sr.sbrnRoleID = map.RoleID
	where
		x.SourceID is not null;   -- ignore empty staff slots
go

alter table sma_TRN_caseStaff enable trigger all;
go

/* 6. (Optional) clear staging table for next run
TRUNCATE TABLE conversion.CaseStaffRoleMap;
GO
*/











/* ------------------------------------------------------------------------------
Create staff roles if they do not exist
*/
--insert into [sma_MST_SubRoleCode]
--	(
--		srcsDscrptn,
--		srcnRoleID
--	)
--	(
--	SELECT 'Primary Case Handler', 10 UNION all			-- staff_1
--	SELECT 'Secondary Case Handler', 10 UNION all		-- staff_2
--	SELECT 'Review Attorney ', 10 UNION all				-- staff_3
--	SELECT 'Negotiator ', 10 UNION all					-- staff_4
--	SELECT 'Closing Specialist ', 10 UNION all			-- staff_5
--	SELECT 'Evidence Coordinator ', 10 UNION all		-- staff_6
--	SELECT 'Staff ', 10 UNION all						-- staff_7
--	SELECT 'Staff', 10 UNION all						-- staff_8
--	SELECT 'File Custodian ', 10 UNION all				-- staff_9
--	SELECT 'Office Location', 10						-- staff_10
--	)
--	except
--	select
--		srcsDscrptn,
--		srcnRoleID
--	from [sma_MST_SubRoleCode]


--alter table [sma_TRN_caseStaff] disable trigger all
--go

/* ------------------------------------------------------------------------------
- Dynamic SQL that assigns case staff as per their needles assignment in staff_1 through staff_10
- Staff Role is assigned from the users "Default case role" in User Maintenance
- If you wish to instead hardcode staff_1 through staff_10 with role = "Staff", use the block below

	(
		select sbrnSubRoleId
		from sma_MST_SubRole
		where sbrsDscrptn=''Staff'' and sbrnRoleID=10
	 )                           as [cssnRoleID],

*/

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
--            from sma_MST_SubRole sr
--            where sr.sbrnSubRoleId = u.usrnRoleID  and sbrnRoleID=10
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
Use this block for manual inserts
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
--			where sbrsDscrptn = 'Assigned Attorney'		-- fill out the correct role
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
--go


alter table [sma_TRN_caseStaff] enable trigger all
go