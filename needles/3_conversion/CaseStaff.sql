/*******************************************************
 CASE STAFF INSERT SCRIPT  -  STAFF_1 .. STAFF_10

 HOW TO USE
 1. Copy the SmartAdvocate Role column from Excel.
 2. Paste it below inside the @pastedRoles string.
 3. Run the script.
    * You can paste fewer than 10 lines; only those slots load.
    * Blank lines are ignored.
*******************************************************/

use [SA]
go



/* ------------------------------------------------------------------------------
Create roles
*/
insert into [sma_MST_SubRoleCode]
	(
		srcsDscrptn,
		srcnRoleID
	)
	(
	SELECT 'Attorney', 10 UNION all
	SELECT 'Prior Paralegal', 10 UNION all
	SELECT 'Managing Partner', 10 UNION all
	SELECT 'Case Manager', 10 UNION all
	SELECT 'Paralegal', 10
	)
	except
	select
		srcsDscrptn,
		srcnRoleID
	from [sma_MST_SubRoleCode]




/* ------------------------------------------------------------------------------
Insert Case Staff
*/ ------------------------------------------------------------------------------
alter table [sma_TRN_caseStaff] disable trigger all
go


--staff_3	Case Manager
--staff_4	Paralegal
--staff_5	Prior Paralegal
--staff_6	Managing Partner
--staff_7	Prior Paralegal
--staff_8	Prior Paralegal
--staff_9	Prior Paralegal
--staff_10	Prior Paralegal

--staff_1	Attorney


/*
Instructions
- copy this code block for each staff role
- change the staff_X to the appropriate staff column
- change the subrole description

*/
insert into sma_TRN_caseStaff
(
    cssnCaseID,
    cssnStaffID,
    cssnRoleID,
    csssComments, cssdFromDate, cssdToDate,
    cssnRecUserID,
    cssdDtCreated,
    cssnModifyUserID, cssdDtModified, cssnLevelNo
)
select
    CAS.casnCaseID,
    U.usrnContactID,
    SR.sbrnSubRoleID,
    null, null, null,
    368, GETDATE(),
    null, null, 0
from [VanceLawFirm_Needles].[dbo].[cases_Indexed] C
cross apply (values (C.staff_1)) S(staff_val)
inner join sma_TRN_cases CAS on CAS.cassCaseNumber = C.casenum
inner join sma_MST_Users U on U.source_id = S.staff_val
inner join sma_MST_SubRole SR on SR.sbrsDscrptn = 'Attorney' and SR.sbrnRoleID = 10;
go


-- Case Manager: staff_2, staff_3
insert into sma_TRN_caseStaff
(
    cssnCaseID, cssnStaffID, cssnRoleID, csssComments, cssdFromDate, cssdToDate,
    cssnRecUserID, cssdDtCreated, cssnModifyUserID, cssdDtModified, cssnLevelNo
)
select
    CAS.casnCaseID,
    U.usrnContactID,
    SR.sbrnSubRoleID,
    null, null, null,
    368, GETDATE(), null, null, 0
from [VanceLawFirm_Needles].[dbo].[cases_Indexed] C
cross apply (values (C.staff_2), (C.staff_3)) S(staff_val)
inner join sma_TRN_cases CAS on CAS.cassCaseNumber = C.casenum
inner join sma_MST_Users U on U.source_id = S.staff_val
inner join sma_MST_SubRole SR on SR.sbrsDscrptn = 'Case Manager' and SR.sbrnRoleID = 10;
go

-- Paralegal: staff_4
insert into sma_TRN_caseStaff
(
    cssnCaseID, cssnStaffID, cssnRoleID, csssComments, cssdFromDate, cssdToDate,
    cssnRecUserID, cssdDtCreated, cssnModifyUserID, cssdDtModified, cssnLevelNo
)
select
    CAS.casnCaseID,
    U.usrnContactID,
    SR.sbrnSubRoleID,
    null, null, null,
    368, GETDATE(), null, null, 0
from [VanceLawFirm_Needles].[dbo].[cases_Indexed] C
cross apply (values (C.staff_4)) S(staff_val)
inner join sma_TRN_cases CAS on CAS.cassCaseNumber = C.casenum
inner join sma_MST_Users U on U.source_id = S.staff_val
inner join sma_MST_SubRole SR on SR.sbrsDscrptn = 'Paralegal' and SR.sbrnRoleID = 10;
go

-- Prior Paralegal: staff_5, staff_7, staff_8, staff_9, staff_10
insert into sma_TRN_caseStaff
(
    cssnCaseID, cssnStaffID, cssnRoleID, csssComments, cssdFromDate, cssdToDate,
    cssnRecUserID, cssdDtCreated, cssnModifyUserID, cssdDtModified, cssnLevelNo
)
select
    CAS.casnCaseID,
    U.usrnContactID,
    SR.sbrnSubRoleID,
    null, null, null,
    368, GETDATE(), null, null, 0
from [VanceLawFirm_Needles].[dbo].[cases_Indexed] C
cross apply (values (C.staff_5), (C.staff_7), (C.staff_8), (C.staff_9), (C.staff_10)) S(staff_val)
inner join sma_TRN_cases CAS on CAS.cassCaseNumber = C.casenum
inner join sma_MST_Users U on U.source_id = S.staff_val
inner join sma_MST_SubRole SR on SR.sbrsDscrptn = 'Prior Paralegal' and SR.sbrnRoleID = 10;
go

-- Managing Partner: staff_6
insert into sma_TRN_caseStaff
(
    cssnCaseID, cssnStaffID, cssnRoleID, csssComments, cssdFromDate, cssdToDate,
    cssnRecUserID, cssdDtCreated, cssnModifyUserID, cssdDtModified, cssnLevelNo
)
select
    CAS.casnCaseID,
    U.usrnContactID,
    SR.sbrnSubRoleID,
    null, null, null,
    368, GETDATE(), null, null, 0
from [VanceLawFirm_Needles].[dbo].[cases_Indexed] C
cross apply (values (C.staff_6)) S(staff_val)
inner join sma_TRN_cases CAS on CAS.cassCaseNumber = C.casenum
inner join sma_MST_Users U on U.source_id = S.staff_val
inner join sma_MST_SubRole SR on SR.sbrsDscrptn = 'Managing Partner' and SR.sbrnRoleID = 10;
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
--    FROM [Needles].[dbo].[cases_Indexed] C
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
--	from [Needles].[dbo].[cases_Indexed] C
--	inner join [sma_TRN_cases] CAS
--		on CAS.cassCaseNumber = C.casenum
--	inner join [sma_MST_Users] U
--		on (U.source_id = C.staff_1)
--go


alter table [sma_TRN_caseStaff] enable trigger all
go