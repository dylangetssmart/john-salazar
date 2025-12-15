/*---
description: Create individual contacts & user records from [staff]
steps: >
	1. create aadmin user
	2. create conversion user
	3. Insert [sma_MST_IndvContacts] from [staff]
	4. Insert [sma_MST_Users] from [staff], join to [sma_MST_IndvContacts]
	5. Cleanup
---*/

use [SA]
go

set ansi_nulls on
set quoted_identifier on
go

exec AddBreadcrumbsToTable 'sma_MST_IndvContacts'
exec AddBreadcrumbsToTable 'sma_MST_Users'
go

/* ------------------------------------------------------------------------------
aadmin user
*/ ------------------------------------------------------------------------------
if (
	 select
		 COUNT(*)
	 from sma_mst_users
	 where usrsLoginID = 'aadmin'
	) = 0
begin
	set identity_insert sma_mst_users on

	insert into [sma_MST_Users]
		(
			usrnUserID,
			[usrnContactID],
			[usrsLoginID],
			[usrsPassword],
			[usrsBackColor],
			[usrsReadBackColor],
			[usrsEvenBackColor],
			[usrsOddBackColor],
			[usrnRoleID],
			[usrdLoginDate],
			[usrdLogOffDate],
			[usrnUserLevel],
			[usrsWorkstation],
			[usrnPortno],
			[usrbLoggedIn],
			[usrbCaseLevelRights],
			[usrbCaseLevelFilters],
			[usrnUnsuccesfulLoginCount],
			[usrnRecUserID],
			[usrdDtCreated],
			[usrnModifyUserID],
			[usrdDtModified],
			[usrnLevelNo],
			[usrsCaseCloseColor],
			[usrnDocAssembly],
			[usrnAdmin],
			[usrnIsLocked],
			[usrbActiveState]
		)
		select distinct
			368		  as usrnuserid,
			(
			 select
			 top 1
				 cinnContactID
			 from dbo.sma_MST_IndvContacts
			 where cinsLastName = 'Unassigned'
				 and cinsFirstName = 'Staff'
			)		  as usrncontactid,
			'aadmin'  as usrsloginid,
			'2/'	  as usrspassword,
			null	  as [usrsbackcolor],
			null	  as [usrsreadbackcolor],
			null	  as [usrsevenbackcolor],
			null	  as [usrsoddbackcolor],
			33		  as [usrnroleid],
			null	  as [usrdlogindate],
			null	  as [usrdlogoffdate],
			null	  as [usrnuserlevel],
			null	  as [usrsworkstation],
			null	  as [usrnportno],
			null	  as [usrbloggedin],
			null	  as [usrbcaselevelrights],
			null	  as [usrbcaselevelfilters],
			null	  as [usrnunsuccesfullogincount],
			1		  as [usrnrecuserid],
			GETDATE() as [usrddtcreated],
			null	  as [usrnmodifyuserid],
			null	  as [usrddtmodified],
			null	  as [usrnlevelno],
			null	  as [usrscaseclosecolor],
			null	  as [usrndocassembly],
			null	  as [usrnadmin],
			null	  as [usrnislocked],
			1		  as [usrbactivestate]
	set identity_insert sma_mst_users off
end

go

/* ------------------------------------------------------------------------------
conversion user
*/ ------------------------------------------------------------------------------
if (
	 select
		 COUNT(*)
	 from sma_mst_users
	 where usrsLoginID = 'conversion'
	) = 0
begin
	insert into [sma_MST_Users]
		(
			[usrnContactID],
			[usrsLoginID],
			[usrsPassword],
			[usrsBackColor],
			[usrsReadBackColor],
			[usrsEvenBackColor],
			[usrsOddBackColor],
			[usrnRoleID],
			[usrdLoginDate],
			[usrdLogOffDate],
			[usrnUserLevel],
			[usrsWorkstation],
			[usrnPortno],
			[usrbLoggedIn],
			[usrbCaseLevelRights],
			[usrbCaseLevelFilters],
			[usrnUnsuccesfulLoginCount],
			[usrnRecUserID],
			[usrdDtCreated],
			[usrnModifyUserID],
			[usrdDtModified],
			[usrnLevelNo],
			[usrsCaseCloseColor],
			[usrnDocAssembly],
			[usrnAdmin],
			[usrnIsLocked],
			[usrbActiveState]
		)
		select distinct
			(
			 select
			 top 1
				 cinnContactID
			 from dbo.sma_MST_IndvContacts
			 where cinsLastName = 'Unassigned'
				 and cinsFirstName = 'Staff'
			)			 as usrncontactid,
			'conversion' as usrsloginid,
			'pass'		 as usrspassword,
			null		 as [usrsbackcolor],
			null		 as [usrsreadbackcolor],
			null		 as [usrsevenbackcolor],
			null		 as [usrsoddbackcolor],
			33			 as [usrnroleid],
			null		 as [usrdlogindate],
			null		 as [usrdlogoffdate],
			null		 as [usrnuserlevel],
			null		 as [usrsworkstation],
			null		 as [usrnportno],
			null		 as [usrbloggedin],
			null		 as [usrbcaselevelrights],
			null		 as [usrbcaselevelfilters],
			null		 as [usrnunsuccesfullogincount],
			1			 as [usrnrecuserid],
			GETDATE()	 as [usrddtcreated],
			null		 as [usrnmodifyuserid],
			null		 as [usrddtmodified],
			null		 as [usrnlevelno],
			null		 as [usrscaseclosecolor],
			null		 as [usrndocassembly],
			null		 as [usrnadmin],
			null		 as [usrnislocked],
			1			 as [usrbactivestate]
end

go

/* ------------------------------------------------------------------------------
Insert [sma_MST_IndvContacts] from [staff]
*/ ------------------------------------------------------------------------------

begin try
	begin tran
		insert into [sma_MST_IndvContacts]
			(
				[cinsPrefix],
				[cinsSuffix],
				[cinsFirstName],
				[cinsLastName],
				[cinsHomePhone],
				[cinsWorkPhone],
				[cinsSSNNo],
				[cindBirthDate],
				[cindDateOfDeath],
				[cinnGender],
				[cinsMobile],
				[cinsComments],
				[cinnContactCtg],
				[cinnContactTypeID],
				[cinnRecUserID],
				[cindDtCreated],
				[cinbStatus],
				[cinbPreventMailing],
				[cinsNickName],
				[cinsOccupation],
				[saga],
				[source_id],
				[source_db],
				[source_ref]
			)
			select
				p.[name]						as [cinsPrefix],
				s.[name]						as [cinsSuffix],
				case
					when stf.first_name = '' then LEFT(dbo.get_firstword(full_name), 30)
					else stf.first_name
				end								as [cinsFirstName],
				case
					when stf.last_name = '' then LEFT(dbo.get_lastword(full_name), 40)
					else stf.last_name
				end								as [cinsLastName],
				null							as [cinsHomePhone],
				LEFT(phone_number, 20)			as [cinsWorkPhone],
				null							as [cinsSSNNo],
				null							as [cindBirthDate],
				null							as [cindDateOfDeath],
				case [gender]
					when 1 then 1
					when 2 then 2
					else 0
				end								as [cinnGender],
				LEFT(mobile_number, 20)			as [cinsMobile],
				ISNULL('Supervisor: ' + NULLIF(CONVERT(VARCHAR, stf.supervisor), '') + CHAR(13), '') +
				ISNULL('Bar1: ' + NULLIF(CONVERT(VARCHAR, stf.bar1), '') + CHAR(13), '') +
				ISNULL('Bar1 State: ' + NULLIF(CONVERT(VARCHAR, stf.bar_state1), '') + CHAR(13), '') +
				ISNULL('Bar2: ' + NULLIF(CONVERT(VARCHAR, stf.bar2), '') + CHAR(13), '') +
				ISNULL('Bar2 State: ' + NULLIF(CONVERT(VARCHAR, stf.bar_state2), '') + CHAR(13), '') +
				ISNULL('Bar3: ' + NULLIF(CONVERT(VARCHAR, stf.bar3), '') + CHAR(13), '') +
				ISNULL('Bar3 State: ' + NULLIF(CONVERT(VARCHAR, stf.bar_state3), '') + CHAR(13), '') +
				--'Works on Cases: ' + case when stf.works_on_cases = 1 then 'Yes' else 'No' end + CHAR(13) +
				''								as [cinsComments],
				1								as [cinnContactCtg],
				(
				 select
					 octnOrigContactTypeID
				 from sma_MST_OriginalContactTypes
				 where octsDscrptn = 'General'
					 and octnContactCtgID = 1
				)								as [cinnContactTypeID],
				368,
				GETDATE()						as [cindDtCreated], -- no created field
				1								as [cinbStatus],
				0								as [cinbPreventMailing],
				CONVERT(VARCHAR(15), full_name) as [cinsNickName],
				stf.job_title					as [cinsOccupation],
				null							as [saga],
				stf.id							as [source_id],
				'needles'						as [source_db],
				'staff_' + stf.staff_code		as [source_ref]
			from [BenAbbot_Needles].[dbo].[staff] stf
			left join [BenAbbot_Needles]..[prefix] p
				on stf.prefixid = p.id
			left join [BenAbbot_Needles]..[suffix] s
				on s.id = stf.suffixid
			left join sma_MST_IndvContacts ind
				on ind.source_id = CONVERT(VARCHAR(MAX), stf.id)
			where
				ind.cinnContactID is null
	commit tran
end try
begin catch
	rollback tran;
	--RAISERROR('FAILED: %s (Line %d)', 16, 1, ERROR_MESSAGE(), ERROR_LINE()) with nowait;
end catch

go

/* ------------------------------------------------------------------------------
Insert [sma_MST_Users] from [staff]
*/ ------------------------------------------------------------------------------
insert into [sma_MST_Users]
	(
		[usrnContactID],
		[usrsLoginID],
		[usrsPassword],
		[usrsBackColor],
		[usrsReadBackColor],
		[usrsEvenBackColor],
		[usrsOddBackColor],
		[usrnRoleID],
		[usrdLoginDate],
		[usrdLogOffDate],
		[usrnUserLevel],
		[usrsWorkstation],
		[usrnPortno],
		[usrbLoggedIn],
		[usrbCaseLevelRights],
		[usrbCaseLevelFilters],
		[usrnUnsuccesfulLoginCount],
		[usrnRecUserID],
		[usrdDtCreated],
		[usrnModifyUserID],
		[usrdDtModified],
		[usrnLevelNo],
		[usrsCaseCloseColor],
		[usrnDocAssembly],
		[usrnAdmin],
		[usrnIsLocked],
		[usrbActiveState],
		[usrbIsShowInSystem],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		indv.cinnContactID as [usrncontactid],
		s.staff_code	   as [usrsloginid],
		'#'				   as [usrspassword],
		null			   as [usrsbackcolor],
		null			   as [usrsreadbackcolor],
		null			   as [usrsevenbackcolor],
		null			   as [usrsoddbackcolor],
		33				   as [usrnroleid],
		null			   as [usrdlogindate],
		null			   as [usrdlogoffdate],
		null			   as [usrnuserlevel],
		null			   as [usrsworkstation],
		null			   as [usrnportno],
		null			   as [usrbloggedin],
		null			   as [usrbcaselevelrights],
		null			   as [usrbcaselevelfilters],
		null			   as [usrnunsuccesfullogincount],
		1				   as [usrnrecuserid],
		GETDATE()		   as [usrddtcreated],
		null			   as [usrnmodifyuserid],
		null			   as [usrddtmodified],
		null			   as [usrnlevelno],
		null			   as [usrscaseclosecolor],
		null			   as [usrndocassembly],
		null			   as [usrnadmin],
		null			   as [usrnislocked],
		0				   as [usrbactivestate],
		1				   as [usrbisshowinsystem],
		null			   as [saga],
		s.staff_code	   as [source_id],
		'needles'		   as [source_db],
		'staff'			   as [source_ref]
	--select *
	from [Needles]..staff s
	join sma_MST_IndvContacts indv
		on indv.source_id = s.staff_code
			and indv.source_ref = 'staff'
	left join [sma_MST_Users] u
		on u.source_id = s.staff_code
	where
		u.usrsLoginID is null
go


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

declare @UserID INT

declare staff_cursor cursor fast_forward for select
	usrnUserID
from sma_mst_users

open staff_cursor

fetch next from staff_cursor into @UserID

set nocount on;
while @@FETCH_STATUS = 0
begin
-- Print the fetched UserID for debugging
print 'Fetched UserID: ' + CAST(@UserID as VARCHAR);

-- Check if @UserID is NULL

if @UserID is not null
begin
	print 'Inserting for UserID: ' + CAST(@UserID as VARCHAR);

	insert into sma_TRN_CaseBrowseSettings
		(
			cbsnColumnID,
			cbsnUserID,
			cbssCaption,
			cbsbVisible,
			cbsnWidth,
			cbsnOrder,
			cbsnRecUserID,
			cbsdDtCreated,
			cbsn_StyleName
		)
		select distinct
			cbcnColumnID,
			@UserID,
			cbcsColumnName,
			'True',
			200,
			cbcnDefaultOrder,
			@UserID,
			GETDATE(),
			'Office2007Blue'
		from [sma_MST_CaseBrowseColumns]
		where
			cbcnColumnID not in (1, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 33);
end
else
begin
	-- Log the NULL @UserID occurrence
	print 'NULL UserID encountered. Skipping insert.';
end

fetch next from staff_cursor into @UserID;
end

close staff_cursor
deallocate staff_cursor



---- Appendix ----
insert into Account_UsersInRoles
	(
		user_id,
		role_id
	)
	select
		usrnUserID as user_id,
		2		   as role_id
	from sma_MST_Users

update sma_MST_Users
set usrbActiveState = 1
where usrsLoginID = 'aadmin'

update Account_UsersInRoles
set role_id = 1
where user_id = 368 


