/*---
group: load
order: 10
description: Update contact types for attorneys
---*/

use [JohnSalazar_SA]
go

---------------------------------------------------
-- aadmin
---------------------------------------------------
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

---------------------------------------------------
-- conversion user
---------------------------------------------------
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

---------------------------------------------------
-- Insert [sma_MST_Users] from [staff]
---------------------------------------------------
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
	from [JohnSalazar_Needles]..staff s
	join sma_MST_IndvContacts indv
		on indv.source_id = s.staff_code
		and indv.source_ref = 'staff'
	LEFT join [sma_MST_Users] u
		on u.source_id = s.staff_code
	where u.usrsloginid is null
	order by usrsloginid
	
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
		where cbcnColumnID not in (1, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 33);
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


