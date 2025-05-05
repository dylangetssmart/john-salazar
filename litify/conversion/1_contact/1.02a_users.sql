use ShinerSA
go

---------------------------------------------------
-- [1.4] Users
---------------------------------------------------
alter table sma_MST_Users disable trigger all
go

-- Create aadmin user using Unassigned Staff contact
if (
		select
			COUNT(*)
		from sma_MST_Users
		where usrsLoginID = 'aadmin'
	) = 0
begin
	set identity_insert sma_MST_Users on

	insert into [sma_MST_Users]
		(
		usrnUserID, [usrnContactID], [usrsLoginID], [usrsPassword], [usrsBackColor], [usrsReadBackColor], [usrsEvenBackColor], [usrsOddBackColor], [usrnRoleID], [usrdLoginDate], [usrdLogOffDate], [usrnUserLevel], [usrsWorkstation], [usrnPortno], [usrbLoggedIn], [usrbCaseLevelRights], [usrbCaseLevelFilters], [usrnUnsuccesfulLoginCount], [usrnRecUserID], [usrdDtCreated], [usrnModifyUserID], [usrdDtModified], [usrnLevelNo], [usrsCaseCloseColor], [usrnDocAssembly], [usrnAdmin], [usrnIsLocked], [usrbActiveState]
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
	set identity_insert sma_MST_Users off
end
go

-- Create converison user using Unassigned Staff contact
if (
		select
			COUNT(*)
		from sma_mst_users
		where usrsLoginID = 'conversion'
	) = 0
begin
	insert into [sma_MST_Users]
		(
		[usrnContactID], [usrsLoginID], [usrsPassword], [usrsBackColor], [usrsReadBackColor], [usrsEvenBackColor], [usrsOddBackColor], [usrnRoleID], [usrdLoginDate], [usrdLogOffDate], [usrnUserLevel], [usrsWorkstation], [usrnPortno], [usrbLoggedIn], [usrbCaseLevelRights], [usrbCaseLevelFilters], [usrnUnsuccesfulLoginCount], [usrnRecUserID], [usrdDtCreated], [usrnModifyUserID], [usrdDtModified], [usrnLevelNo], [usrsCaseCloseColor], [usrnDocAssembly], [usrnAdmin], [usrnIsLocked], [usrbActiveState]
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

-- Create users from individual contacts
insert into [sma_MST_Users]
	(
	[usrnContactID], [usrsLoginID], [usrsPassword], [usrsBackColor], [usrsReadBackColor], [usrsEvenBackColor], [usrsOddBackColor], [usrnRoleID], [usrdLoginDate], [usrdLogOffDate], [usrnUserLevel], [usrsWorkstation], [usrnPortno], [usrbLoggedIn], [usrbCaseLevelRights], [usrbCaseLevelFilters], [usrnUnsuccesfulLoginCount], [usrnRecUserID], [usrdDtCreated], [usrnModifyUserID], [usrdDtModified], [usrnLevelNo], [usrsCaseCloseColor], [usrnDocAssembly], [usrnAdmin], [usrnIsLocked], [usrbActiveState], [usrnFirmRoleID], [usrnFirmTitleID], [usrbIsShowInSystem], [saga_char], [source_db], [source_ref]
	)
	select
		cinnContactID as [usrncontactid],
		--  ,LEFT(LEFT(Username, CHARINDEX('@', Username) - 1) +
		--CASE
		--	WHEN Username LIKE '%test123%'
		--		THEN 'T1'
		--	WHEN Username LIKE '%test%'
		--		THEN 'T'
		--	ELSE ''
		--END, 20) AS [usrsLoginID]
		case
			when lu.Alias <> 'APP'
				--then lu.Alias
				then case
						when lu.Id = '005Nt000005DCjdIAG'
							then 'knobl1'
						when lu.Id = '005Nt000005okBFIAY'
							then 'brian1'
						else LEFT(LEFT(Username, CHARINDEX('@', Username) - 1), 20)
					end
		end			  as [usrsloginid],
		'#'			  as [usrspassword],
		null		  as [usrsbackcolor],
		null		  as [usrsreadbackcolor],
		null		  as [usrsevenbackcolor],
		null		  as [usrsoddbackcolor],
		33			  as [usrnroleid],
		null		  as [usrdlogindate],
		null		  as [usrdlogoffdate],
		null		  as [usrnuserlevel],
		null		  as [usrsworkstation],
		null		  as [usrnportno],
		null		  as [usrbloggedin],
		null		  as [usrbcaselevelrights],
		null		  as [usrbcaselevelfilters],
		null		  as [usrnunsuccesfullogincount],
		1			  as [usrnrecuserid],
		GETDATE()	  as [usrddtcreated],
		null		  as [usrnmodifyuserid],
		null		  as [usrddtmodified],
		null		  as [usrnlevelno],
		null		  as [usrscaseclosecolor],
		null		  as [usrndocassembly],
		0			  as [usrnadmin],
		null		  as [usrnislocked],
		0			  as [usrbactivestate],
		21862		  as [usrnfirmroleid],
		21866		  as [usrnfirmtitleid],
		0			  as [usrbisshowinsystem],
		lu.id		  as [saga_char],
		'litify'	  as [source_db],
		'user'		  as [source_ref]
	--select * 
	from sma_MST_IndvContacts ind
	join ShinerLitify..[user] lu
		on ind.saga_char = lu.Id
	left join [sma_MST_Users] u
		on u.saga_char = ind.saga_char
	where
		u.usrsloginid is null
		and
		lu.Alias <> 'APP'
		and lu.Username not like '%settlements%'	-- ds 2025-03-14 - there is a "settlements" user in Litify
	order by usrsloginid
go
--SELECT * FROM sma_MST_IndvContacts smic where smic.cinnContactID = 3115
--SELECT * FROM ShinerLitify..[User] u
--SELECT * FROM sma_MST_Users smu

--select
--	username, alias, id
--from ShinerLitify..[User] u
--order by u.Username



/* ---------------------------------------------------------------------------------------------------------------
"Team" users
https://smartadvocate.slack.com/lists/TBXC0RF51/F08FZ9WM9U4?record_id=Rec08FZ9WS076
*/

-- MedicalRecords
if (
		select
			COUNT(*)
		from sma_MST_Users
		where usrsLoginID = 'Records'
	) = 0
begin
	--set identity_insert sma_MST_Users on

	insert into [sma_MST_Users]
		(
		--usrnUserID, 
		[usrnContactID], [usrsLoginID], [usrsPassword], [usrsBackColor], [usrsReadBackColor], [usrsEvenBackColor], [usrsOddBackColor], [usrnRoleID], [usrdLoginDate], [usrdLogOffDate], [usrnUserLevel], [usrsWorkstation], [usrnPortno], [usrbLoggedIn], [usrbCaseLevelRights], [usrbCaseLevelFilters], [usrnUnsuccesfulLoginCount], [usrnRecUserID], [usrdDtCreated], [usrnModifyUserID], [usrdDtModified], [usrnLevelNo], [usrsCaseCloseColor], [usrnDocAssembly], [usrnAdmin], [usrnIsLocked], [usrbActiveState]
		)
		select distinct
			--368		  as usrnuserid,
			(
				select
				top 1
					cinnContactID
				from dbo.sma_MST_IndvContacts
				where cinsLastName = 'Unassigned'
					and cinsFirstName = 'Staff'
			)		  as usrncontactid,
			'Records'  as usrsloginid,
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
	--set identity_insert sma_MST_Users off
end
go

-- Settlements
if (
		select
			COUNT(*)
		from sma_MST_Users
		where usrsLoginID = 'Settlements'
	) = 0
begin
	--set identity_insert sma_MST_Users on

	insert into [sma_MST_Users]
		(
		--usrnUserID,
		[usrnContactID], [usrsLoginID], [usrsPassword], [usrsBackColor], [usrsReadBackColor], [usrsEvenBackColor], [usrsOddBackColor], [usrnRoleID], [usrdLoginDate], [usrdLogOffDate], [usrnUserLevel], [usrsWorkstation], [usrnPortno], [usrbLoggedIn], [usrbCaseLevelRights], [usrbCaseLevelFilters], [usrnUnsuccesfulLoginCount], [usrnRecUserID], [usrdDtCreated], [usrnModifyUserID], [usrdDtModified], [usrnLevelNo], [usrsCaseCloseColor], [usrnDocAssembly], [usrnAdmin], [usrnIsLocked], [usrbActiveState]
		)
		select distinct
			--368		  as usrnuserid,
			(
				select
				top 1
					cinnContactID
				from dbo.sma_MST_IndvContacts
				where cinsLastName = 'Unassigned'
					and cinsFirstName = 'Staff'
			)		  as usrncontactid,
			'Settlements'  as usrsloginid,
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
	--set identity_insert sma_MST_Users off
end
go



-----------------------------------------------------------
-- Add default set of case browse columns for every user.
-----------------------------------------------------------

declare @UserID INT

declare staff_cursor cursor fast_forward for select
	usrnUserID
from sma_MST_Users

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
		cbsnColumnID, cbsnUserID, cbssCaption, cbsbVisible, cbsnWidth, cbsnOrder, cbsnRecUserID, cbsdDtCreated, cbsn_StyleName
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
go

---- Appendix ----
insert into Account_UsersInRoles
	(
	user_id, role_id
	)
	select
		usrnUserID as user_id,
		2		   as role_id
	from sma_MST_Users

update Account_UsersInRoles
set role_id = 1
where user_id = 368