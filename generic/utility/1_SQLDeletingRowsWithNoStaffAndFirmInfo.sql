use JoelBieberSA_Needles
go
truncate table  CP_UserNotesStatus
Go
truncate table  sma_trn_tasknew
go
--truncate table sma_TRN_AutomatedScopeCaseOffices
--go
--truncate table sma_TRN_AutomatedAction_Emails
--go
truncate table  sma_trn_caseJudgeorClerk
go
--delete from sma_TRN_AutomatedRules
--go
truncate table  sma_TRN_CaseContactComment
go
truncate table  sma_TRN_CriticalComments
go
truncate table  sma_TRN_MySmartAdvocateLayout
go
alter table sma_TRN_Negotiations disable trigger all
delete from sma_TRN_Negotiations

alter table sma_TRN_Negotiations enable trigger all
go
delete from sma_TRN_MedicalProviderRequest
go
truncate table  sma_trn_ChangeStaffByStatus
Go
--delete from sma_TRN_AutomatedActions
--go
--delete from sma_TRN_EmploymentStatuses
--go
delete from sma_trn_MedProviderERequestDependencies
go
delete from sma_trn_MedicalProviderERequest
go
delete from sma_TRN_Employment_Trades
go
alter table sma_TRN_Employment disable trigger all
delete from sma_TRN_Employment

alter table sma_TRN_Employment enable trigger all
go
truncate table  sma_TRN_ContactDocuments
go
truncate table  sma_MST_OtherCasesContact
go
truncate table  sma_TRN_SearchEngine
Go
truncate table  sma_trn_SSDAppealCounsel
GO
TRUNCATE TABLE  sma_TRN_ExpertsFromContacts
GO

--alter table [dbo].[acc_trn_transactions] disable trigger all
--delete from [dbo].[acc_trn_transactions]
--DBCC CHECKIDENT ('[dbo].[acc_trn_transactions]', RESEED, 0);
--alter table [dbo].[acc_trn_transactions] enable trigger all
--GO
--alter table [dbo].[acc_trn_DepositLines] disable trigger all
--delete from [dbo].[acc_trn_DepositLines]
--DBCC CHECKIDENT ('[dbo].[acc_trn_DepositLines]', RESEED, 0);
--alter table [dbo].[acc_trn_DepositLines] enable trigger all
--GO
--alter table [dbo].[acc_trn_expenseLines] disable trigger all
--delete from [dbo].[acc_trn_expenseLines]
--DBCC CHECKIDENT ('[dbo].[acc_trn_expenseLines]', RESEED, 0);
--alter table [dbo].[acc_trn_expenseLines] enable trigger all
--GO

alter table [dbo].[sma_trn_disbursement] disable trigger all
delete from [dbo].[sma_trn_disbursement]
DBCC CHECKIDENT ('[dbo].[sma_trn_disbursement]', RESEED, 0);
alter table [dbo].[sma_trn_disbursement] enable trigger all
GO

alter table sma_trn_settlements disable trigger all
delete from sma_TRN_Settlements

alter table sma_trn_settlements enable trigger all
go

--delete from  ACC_Account
--delete from ACC_Contractor
--go
--delete from ACC_Obligation
--go
--delete from ACC_Payment
--go
--delete from ACC_Transaction
--go
delete from ACC_Account
GO
ALTER TABLE [dbo].[sma_TRN_ExpertsFromContacts] DROP CONSTRAINT [FK_ExpertContact]
GO
ALTER TABLE [dbo].[ACC_Account] DROP CONSTRAINT [FK_ACC_Account_sma_MST_Users1]
GO

-- Enable all table constraints
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sma_TRN_CaseContactComment_sma_TRN_Cases]') AND parent_object_id = OBJECT_ID(N'[dbo].[sma_TRN_CaseContactComment]'))
ALTER TABLE [dbo].[sma_TRN_CaseContactComment] DROP CONSTRAINT [FK_sma_TRN_CaseContactComment_sma_TRN_Cases]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CP_UserNotesStatus_sma_TRN_Notes]') AND parent_object_id = OBJECT_ID(N'[dbo].[CP_UserNotesStatus]'))
ALTER TABLE [dbo].[CP_UserNotesStatus] DROP CONSTRAINT [FK_CP_UserNotesStatus_sma_TRN_Notes]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CP_UserDocumentStatus_sma_TRN_Documents]') AND parent_object_id = OBJECT_ID(N'[dbo].[CP_UserDocumentStatus]'))
ALTER TABLE [dbo].[CP_UserDocumentStatus] DROP CONSTRAINT [FK_CP_UserDocumentStatus_sma_TRN_Documents]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sma_TRN_MySmartAdvocateLayout_sma_MST_Users]') AND parent_object_id = OBJECT_ID(N'[dbo].[sma_TRN_MySmartAdvocateLayout]'))
ALTER TABLE [dbo].[sma_TRN_MySmartAdvocateLayout] DROP CONSTRAINT [FK_sma_TRN_MySmartAdvocateLayout_sma_MST_Users]
GO


IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sma_MST_StaffBillingRate_sma_MST_Users]') AND parent_object_id = OBJECT_ID(N'[dbo].[sma_MST_StaffBillingRate]'))
ALTER TABLE [dbo].[sma_MST_StaffBillingRate] DROP CONSTRAINT [FK_sma_MST_StaffBillingRate_sma_MST_Users]
GO



IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CP_UserAppointmentStatus_CP_Users]') AND parent_object_id = OBJECT_ID(N'[dbo].[CP_UserAppointmentStatus]'))
ALTER TABLE [dbo].[CP_UserAppointmentStatus] DROP CONSTRAINT [FK_CP_UserAppointmentStatus_CP_Users]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CP_UserAppointmentStatus_sma_TRN_CalendarAppointments]') AND parent_object_id = OBJECT_ID(N'[dbo].[CP_UserAppointmentStatus]'))
ALTER TABLE [dbo].[CP_UserAppointmentStatus] DROP CONSTRAINT [FK_CP_UserAppointmentStatus_sma_TRN_CalendarAppointments]
GO
 DECLARE @Name varchar(1000)
 DECLARE @SQL varchar(2000)
   
    -- Declare a cursor that will get staff contactid

	
DECLARE trnasactiontable_Cursor CURSOR FAST_FORWARD FOR 
select distinct name from sys.objects where type ='u' and name like '%trn_%' and name not like 'sma_trn_cases'   and name not like 'sma_TRN_MedicalProviderRequest' and name not like 'sma_TRN_Negotiations' and name not like 'sma_TRN_Settlements'  and name not like 'sma_trn_MedicalProviderERequest' and name not like 'sma_TRN_EmploymentStatuses' and name not like 'sma_TRN_Employment' and name not like 'sma_trn_disbursement'
and name not like 'sma_TRN_CourtDocket' and name not like 'sma_trn_automa%'   and name not like 'sma_trn_documenttypeextension' and name not like 'sma_TRN_CheckReceivedFeeRecorded' and name not like 'sma_TRN_PdfTemplateFields'  and name not like 'sma_TRN_AutomatedRules' and name not like 'sma_TRN_AutomatedActions' and name not like 'sma_TRN_Plaintiff' and name not like 'sma_TRN_CaseStagesStatus' and name not like 'sma_TRN_notes'
and name not like 'sma_TRN_WebDashboards'
--Open a cursor
OPEN trnasactiontable_Cursor 

FETCH NEXT FROM trnasactiontable_Cursor INTO @Name

WHILE @@FETCH_STATUS = 0
BEGIN
 
 select @SQL='truncate table '+@Name+''
 EXEC(@SQL)

FETCH NEXT FROM trnasactiontable_Cursor INTO @Name
END

CLOSE trnasactiontable_Cursor
DEALLOCATE trnasactiontable_Cursor


 DECLARE @Name1 varchar(1000)
 DECLARE @SQL1 varchar(2000)
   
    -- Declare a cursor that will get staff contactid

	
DECLARE Contacttable_Cursor CURSOR FAST_FORWARD FOR 
select distinct name from sys.objects where type ='u' and name like '%contact%' and name not like '%contacttype%'
and name not like '%sma_mst_ContactDocumentType%' and name not like 'sma_MST_AllContactInfo' and name not like 'sma_MST_RelContacts' and name not like '%sma_MST_ContactSubCategory%' and name not like '%sma_MST_IndvContacts%' and name not like 'CategoryContactFilters' and name not like '%sma_MST_orgContacts%' and name not like '%sma_MST_ContactCtg%' and name not like '%sma_MST_ContactNoType%' and name not like 'sma_MST_WorkPlan%' and name not like 'sma_trn_WorkPlan%' and name not like '%sma_TRN_RolePriorityGroup%' and name not like '%sma_TRN_DocumentTypeExtension%' and name not like '%sma_TRN_ActionType%' and name not like '%sma_trn_DueTerm%'
--Open a cursor
OPEN Contacttable_Cursor 

FETCH NEXT FROM Contacttable_Cursor INTO @Name1

WHILE @@FETCH_STATUS = 0
BEGIN
 
 select @SQL1='truncate table '+@Name1+''
 EXEC(@SQL1)

FETCH NEXT FROM Contacttable_Cursor INTO @Name1
END

CLOSE Contacttable_Cursor
DEALLOCATE Contacttable_Cursor

--truncate table sma_mst_contactnumbers
--truncate table sma_mst_address
--truncate table sma_mst_emailwebsite


--select t.name as TableWithForeignKey, fk.constraint_column_id as FK_PartNo , c.name as ForeignKeyColumn 
--from sys.foreign_key_columns as fk
--inner join sys.tables as t on fk.parent_object_id = t.object_id
--inner join sys.columns as c on fk.parent_object_id = c.object_id and fk.parent_column_id = c.column_id
--where fk.referenced_object_id = (select object_id from sys.tables where name = 'sma_trn_cases')
--order by TableWithForeignKey, FK_PartNo

GO
ALTER TABLE [dbo].[ACC_Account] DROP CONSTRAINT [FK_ACC_Account_sma_MST_Users]
GO


IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sma_MST_CaseTypeCoCounsel_sma_MST_IndvContacts]') AND parent_object_id = OBJECT_ID(N'[dbo].[sma_MST_CaseTypeCoCounsel]'))
ALTER TABLE [dbo].[sma_MST_CaseTypeCoCounsel] DROP CONSTRAINT [FK_sma_MST_CaseTypeCoCounsel_sma_MST_IndvContacts]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sma_MST_CaseTypeCoCounsel_sma_MST_OrgContacts]') AND parent_object_id = OBJECT_ID(N'[dbo].[sma_MST_CaseTypeCoCounsel]'))
ALTER TABLE [dbo].[sma_MST_CaseTypeCoCounsel] DROP CONSTRAINT [FK_sma_MST_CaseTypeCoCounsel_sma_MST_OrgContacts]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sma_MST_OtherCasesContact_sma_TRN_Cases]') AND parent_object_id = OBJECT_ID(N'[dbo].[sma_MST_OtherCasesContact]'))
ALTER TABLE [dbo].[sma_MST_OtherCasesContact] DROP CONSTRAINT [FK_sma_MST_OtherCasesContact_sma_TRN_Cases]
GO


GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sma_trn_AgeolCallersInfo_sma_TRN_Cases]') AND parent_object_id = OBJECT_ID(N'[dbo].[sma_trn_AgeolCallersInfo]'))
ALTER TABLE [dbo].[sma_trn_AgeolCallersInfo] DROP CONSTRAINT [FK_sma_trn_AgeolCallersInfo_sma_TRN_Cases]
GO


IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sma_TRN_CaseContactComment_sma_TRN_Cases]') AND parent_object_id = OBJECT_ID(N'[dbo].[sma_TRN_CaseContactComment]'))
ALTER TABLE [dbo].[sma_TRN_CaseContactComment] DROP CONSTRAINT [FK_sma_TRN_CaseContactComment_sma_TRN_Cases]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sma_TRN_SearchEngine_sma_TRN_Cases]') AND parent_object_id = OBJECT_ID(N'[dbo].[sma_TRN_SearchEngine]'))
ALTER TABLE [dbo].[sma_TRN_SearchEngine] DROP CONSTRAINT [FK_sma_TRN_SearchEngine_sma_TRN_Cases]
GO

GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sma_trn_SSDAppealCounselnSma_trn_plaintiff]') AND parent_object_id = OBJECT_ID(N'[dbo].[sma_trn_SSDAppealCounsel]'))
ALTER TABLE [dbo].[sma_trn_SSDAppealCounsel] DROP CONSTRAINT [FK_sma_trn_SSDAppealCounselnSma_trn_plaintiff]
GO
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sma_trn_plaintiff]') AND parent_object_id = OBJECT_ID(N'[dbo].[sma_trn_SSDInitialApplication]'))
ALTER TABLE [dbo].[sma_trn_SSDInitialApplication] DROP CONSTRAINT [FK_sma_trn_plaintiff]
GO
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sma_trn_caseJudgeorClerk_sma_TRN_CourtDocket]') AND parent_object_id = OBJECT_ID(N'[dbo].[sma_trn_caseJudgeorClerk]'))
ALTER TABLE [dbo].[sma_trn_caseJudgeorClerk] DROP CONSTRAINT [FK_sma_trn_caseJudgeorClerk_sma_TRN_CourtDocket]
GO
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sma_TRN_MySmartAdvocateLayout_sma_MST_Users]') AND parent_object_id = OBJECT_ID(N'[dbo].[sma_TRN_MySmartAdvocateLayout]'))
ALTER TABLE [dbo].[sma_TRN_MySmartAdvocateLayout] DROP CONSTRAINT [FK_sma_TRN_MySmartAdvocateLayout_sma_MST_Users]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sma_trn_ChangeStaffByStatus_sma_MST_IndvContacts]') AND parent_object_id = OBJECT_ID(N'[dbo].[sma_trn_ChangeStaffByStatus]'))
ALTER TABLE [dbo].[sma_trn_ChangeStaffByStatus] DROP CONSTRAINT [FK_sma_trn_ChangeStaffByStatus_sma_MST_IndvContacts]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sma_TRN_ContactDocuments_sma_mst_ContactDocumentType]') AND parent_object_id = OBJECT_ID(N'[dbo].[sma_TRN_ContactDocuments]'))
ALTER TABLE [dbo].[sma_TRN_ContactDocuments] DROP CONSTRAINT [FK_sma_TRN_ContactDocuments_sma_mst_ContactDocumentType]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_WorkFlows_sma_MST_Users]') AND parent_object_id = OBJECT_ID(N'[dbo].[WorkFlows]'))
ALTER TABLE [dbo].[WorkFlows] DROP CONSTRAINT [FK_WorkFlows_sma_MST_Users]
Go
--truncate table sma_mst_indvcontacts
--truncate table sma_mst_orgcontacts
--delete from sma_mst_users
--truncate table sma_trn_cases

alter table sma_trn_cases disable trigger all
delete from sma_trn_cases
DBCC CHECKIDENT ('sma_trn_cases', RESEED, 0);
alter table sma_trn_cases disable trigger all

alter table sma_trn_plaintiff disable trigger all
delete from sma_trn_plaintiff
DBCC CHECKIDENT ('sma_trn_plaintiff', RESEED, 0);
alter table sma_trn_plaintiff disable trigger all

alter table sma_mst_ContactDocumentType disable trigger all
delete from sma_mst_ContactDocumentType
DBCC CHECKIDENT ('sma_mst_ContactDocumentType', RESEED, 0);
alter table sma_mst_ContactDocumentType disable trigger all

alter table sma_TRN_CourtDocket disable trigger all
delete from sma_TRN_CourtDocket
DBCC CHECKIDENT ('sma_TRN_CourtDocket', RESEED, 0);
alter table sma_TRN_CourtDocket disable trigger all

truncate table sma_mst_contacttypesforcontact
Truncate table  sma_MST_AdvertisementCampaign
truncate table sma_MST_ReferOutRules
Truncate table saemailsignature
Truncate table  sma_MST_LastAccessedCases
--truncate table workflows
--truncate table WorkFlowStepTasks
--truncate table WorkFlowTransactions
--truncate table WorkFlowValues
GO


ALTER TABLE [dbo].[sma_TRN_ContactDocuments]  WITH CHECK ADD  CONSTRAINT [FK_sma_TRN_ContactDocuments_sma_mst_ContactDocumentType] FOREIGN KEY([cntctDocumentTypeID])
REFERENCES [dbo].[sma_mst_ContactDocumentType] ([cntctDocTypeID])
GO

ALTER TABLE [dbo].[sma_TRN_ContactDocuments] CHECK CONSTRAINT [FK_sma_TRN_ContactDocuments_sma_mst_ContactDocumentType]
GO

ALTER TABLE [dbo].[sma_MST_OtherCasesContact]  WITH CHECK ADD  CONSTRAINT [FK_sma_MST_OtherCasesContact_sma_TRN_Cases] FOREIGN KEY([OtherCasesID])
REFERENCES [dbo].[sma_TRN_Cases] ([casnCaseID])
GO

ALTER TABLE [dbo].[sma_MST_OtherCasesContact] CHECK CONSTRAINT [FK_sma_MST_OtherCasesContact_sma_TRN_Cases]
GO

ALTER TABLE [dbo].[sma_TRN_CaseContactComment]  WITH CHECK ADD  CONSTRAINT [FK_sma_TRN_CaseContactComment_sma_TRN_Cases] FOREIGN KEY([CaseContactCaseID])
REFERENCES [dbo].[sma_TRN_Cases] ([casnCaseID])
GO

ALTER TABLE [dbo].[sma_TRN_CaseContactComment] CHECK CONSTRAINT [FK_sma_TRN_CaseContactComment_sma_TRN_Cases]
GO


GO

ALTER TABLE [dbo].[sma_trn_AgeolCallersInfo]  WITH CHECK ADD  CONSTRAINT [FK_sma_trn_AgeolCallersInfo_sma_TRN_Cases] FOREIGN KEY([CaseID])
REFERENCES [dbo].[sma_TRN_Cases] ([casnCaseID])
GO

ALTER TABLE [dbo].[sma_trn_AgeolCallersInfo] CHECK CONSTRAINT [FK_sma_trn_AgeolCallersInfo_sma_TRN_Cases]
GO
ALTER TABLE [dbo].[sma_TRN_SearchEngine]  WITH CHECK ADD  CONSTRAINT [FK_sma_TRN_SearchEngine_sma_TRN_Cases] FOREIGN KEY([CaseID])
REFERENCES [dbo].[sma_TRN_Cases] ([casnCaseID])
GO

ALTER TABLE [dbo].[sma_TRN_SearchEngine] CHECK CONSTRAINT [FK_sma_TRN_SearchEngine_sma_TRN_Cases]
GO

GO

ALTER TABLE [dbo].[sma_trn_SSDAppealCounsel]  WITH CHECK ADD  CONSTRAINT [FK_sma_trn_SSDAppealCounselnSma_trn_plaintiff] FOREIGN KEY([SSDAppealCounselPlaintiffID])
REFERENCES [dbo].[sma_TRN_Plaintiff] ([plnnPlaintiffID])
GO

ALTER TABLE [dbo].[sma_trn_SSDAppealCounsel] CHECK CONSTRAINT [FK_sma_trn_SSDAppealCounselnSma_trn_plaintiff]
GO


GO

--ALTER TABLE [dbo].[sma_trn_SSDInitialApplication]  WITH CHECK ADD  CONSTRAINT [FK_sma_trn_plaintiff] FOREIGN KEY([SSDPlaintifID])
--REFERENCES [dbo].[sma_TRN_Plaintiff] ([plnnPlaintiffID])
--GO

--ALTER TABLE [dbo].[sma_trn_SSDInitialApplication] CHECK CONSTRAINT [FK_sma_trn_plaintiff]
GO

GO

ALTER TABLE [dbo].[sma_trn_caseJudgeorClerk]  WITH CHECK ADD  CONSTRAINT [FK_sma_trn_caseJudgeorClerk_sma_TRN_CourtDocket] FOREIGN KEY([crtDocketID])
REFERENCES [dbo].[sma_TRN_CourtDocket] ([crdnCourtDocketID])
GO

ALTER TABLE [dbo].[sma_trn_caseJudgeorClerk] CHECK CONSTRAINT [FK_sma_trn_caseJudgeorClerk_sma_TRN_CourtDocket]
GO

ALTER TABLE [dbo].[sma_MST_CaseTypeCoCounsel]  WITH CHECK ADD  CONSTRAINT [FK_sma_MST_CaseTypeCoCounsel_sma_MST_IndvContacts] FOREIGN KEY([CoCounselAttorneyID])
REFERENCES [dbo].[sma_MST_IndvContacts] ([cinnContactID])
GO

ALTER TABLE [dbo].[sma_MST_CaseTypeCoCounsel] CHECK CONSTRAINT [FK_sma_MST_CaseTypeCoCounsel_sma_MST_IndvContacts]
--GO

--ALTER TABLE [dbo].[WorkFlows]  WITH CHECK ADD  CONSTRAINT [FK_WorkFlows_sma_MST_Users] FOREIGN KEY([CreatorUserId])
--REFERENCES [dbo].[sma_MST_Users] ([usrnUserID])
--GO

--ALTER TABLE [dbo].[WorkFlows] CHECK CONSTRAINT [FK_WorkFlows_sma_MST_Users]
--GO
--ALTER TABLE [dbo].[sma_MST_CaseTypeCoCounsel]  WITH CHECK ADD  CONSTRAINT [FK_sma_MST_CaseTypeCoCounsel_sma_MST_OrgContacts] FOREIGN KEY([CoCounselLawfirmID])
--REFERENCES [dbo].[sma_MST_OrgContacts] ([connContactID])
--GO

--ALTER TABLE [dbo].[sma_MST_CaseTypeCoCounsel] CHECK CONSTRAINT [FK_sma_MST_CaseTypeCoCounsel_sma_MST_OrgContacts]
GO


ALTER TABLE [dbo].[sma_trn_ChangeStaffByStatus]  WITH CHECK ADD  CONSTRAINT [FK_sma_trn_ChangeStaffByStatus_sma_MST_IndvContacts] FOREIGN KEY([chngStaffID])
REFERENCES [dbo].[sma_MST_IndvContacts] ([cinnContactID])
GO

ALTER TABLE [dbo].[sma_trn_ChangeStaffByStatus] CHECK CONSTRAINT [FK_sma_trn_ChangeStaffByStatus_sma_MST_IndvContacts]
GO
ALTER TABLE [dbo].[sma_TRN_MySmartAdvocateLayout]  WITH CHECK ADD  CONSTRAINT [FK_sma_TRN_MySmartAdvocateLayout_sma_MST_Users] FOREIGN KEY([UserID])
REFERENCES [dbo].[sma_MST_Users] ([usrnUserID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[sma_TRN_MySmartAdvocateLayout] CHECK CONSTRAINT [FK_sma_TRN_MySmartAdvocateLayout_sma_MST_Users]
GO
insert into sma_MST_ClientContactFrequency
select 0,60,0,'53,78',NULL
union
select 0,90,1,'53,78',64
go
delete from sma_MST_Tenants
go
--ALTER TABLE [dbo].[CP_UserNotesStatus] DROP CONSTRAINT [FK_CP_UserNotesStatus_sma_TRN_Notes]
GO
ALTER TABLE [dbo].[sma_TRN_TaskNew] DROP CONSTRAINT [FK_sma_TRN_TaskNew_sma_TRN_Notes]
GO
TRUNCATE TABLE sma_trn_notes
go
--ALTER TABLE [dbo].[CP_UserNotesStatus]  WITH CHECK ADD  CONSTRAINT [FK_CP_UserNotesStatus_sma_TRN_Notes] FOREIGN KEY([SANoteID])
--REFERENCES [dbo].[sma_TRN_Notes] ([notnNoteID])
--GO

--ALTER TABLE [dbo].[CP_UserNotesStatus] CHECK CONSTRAINT [FK_CP_UserNotesStatus_sma_TRN_Notes]
--GO



ALTER TABLE [dbo].[sma_TRN_TaskNew]  WITH CHECK ADD  CONSTRAINT [FK_sma_TRN_TaskNew_sma_TRN_Notes] FOREIGN KEY([tskCompletedNoteID])
REFERENCES [dbo].[sma_TRN_Notes] ([notnNoteID])
GO

ALTER TABLE [dbo].[sma_TRN_TaskNew] CHECK CONSTRAINT [FK_sma_TRN_TaskNew_sma_TRN_Notes]
GO


go
update sma_MST_AdminParameters set adpsKeyValue='' where adpsKeyValue like '%parker%'

  -- Update a 
-- set frisName=consName, frisAddress1=addsAddress1,frisAddress2=addsAddress2, 
-- frisCity=addsCity,frisState=addsStateCode,frisZip=addsZip,frisCounty=addsCounty,frisPhoneNo='''',frisEmailID='',frisCPPhoneNo='',frisCPEmailID='',frinAddsID=addnAddressID,frinLicUsers='',fridRecCreatedDt=GETDATE(),frinRecUserID=368,frisFaxNo='',frisContactPerson='',frisAppEmailID='',frinUniqueContactId=isnull('2'+CAST(connContactID as varchar(20)),0)
  -- from sma_MST_FirmInfo a
  -- outer apply(select top 1 conncontactid,consName from sma_MST_OrgContacts where consName='Morell Kelly')z
  -- left join sma_mst_address on addnContactID=connContactID and addnContactCtgID=2 and addbPrimary=1
-- go

 DECLARE @Name2 varchar(1000)
 DECLARE @SQL2 varchar(2000)
   
    -- Declare a cursor that will get staff contactid

	
DECLARE droptable_Cursor CURSOR FAST_FORWARD FOR 
select distinct name from sys.objects where type ='u' and name like '%$%' 
--Open a cursor
OPEN droptable_Cursor 

FETCH NEXT FROM droptable_Cursor INTO @Name2

WHILE @@FETCH_STATUS = 0
BEGIN
 
 select @SQL2='drop table '+'['+@Name2+''+']'
 print @sql2
 EXEC(@SQL2)

FETCH NEXT FROM droptable_Cursor INTO @Name2
END

CLOSE droptable_Cursor
DEALLOCATE droptable_Cursor

go
 DECLARE @Name3 varchar(1000)
 DECLARE @SQL3 varchar(2000)
   
    -- Declare a cursor that will get staff contactid

	
DECLARE droptable1_Cursor CURSOR FAST_FORWARD FOR 
select distinct name from sys.objects where type ='u' and name like 'tmp%' 
--Open a cursor
OPEN droptable1_Cursor 

FETCH NEXT FROM droptable1_Cursor INTO @Name3

WHILE @@FETCH_STATUS = 0
BEGIN
 
 select @SQL3='drop table '+'['+@Name3+''+']'
 print @SQL3
 EXEC(@SQL3)

FETCH NEXT FROM droptable1_Cursor INTO @Name3
END

CLOSE droptable1_Cursor
DEALLOCATE droptable1_Cursor

go
update sma_MST_AdminParameters set adpsKeyValue='' where adpsKeyGroup like 'call%'

update sma_MST_AdminParameters set adpsKeyValue='' where adpsKeyName like '%fax%'
go

GO


ALTER TABLE [dbo].[CP_UserAppointmentStatus]  WITH CHECK ADD  CONSTRAINT [FK_CP_UserAppointmentStatus_CP_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[CP_Users] ([userId])
GO

ALTER TABLE [dbo].[CP_UserAppointmentStatus] CHECK CONSTRAINT [FK_CP_UserAppointmentStatus_CP_Users]
GO


--ALTER TABLE [dbo].[CP_UserAppointmentStatus]  WITH CHECK ADD  CONSTRAINT [FK_CP_UserAppointmentStatus_sma_TRN_CalendarAppointments] FOREIGN KEY([SAAppointmentId])
--REFERENCES [dbo].[sma_TRN_CalendarAppointments] ([AppointmentID])
--GO

--ALTER TABLE [dbo].[CP_UserAppointmentStatus] CHECK CONSTRAINT [FK_CP_UserAppointmentStatus_sma_TRN_CalendarAppointments]
--GO


--ALTER TABLE [dbo].[CP_UserNotesStatus]  WITH CHECK ADD  CONSTRAINT [FK_CP_UserNotesStatus_sma_TRN_Notes] FOREIGN KEY([SANoteID])
--REFERENCES [dbo].[sma_TRN_Notes] ([notnNoteID])
--GO

--ALTER TABLE [dbo].[CP_UserNotesStatus] CHECK CONSTRAINT [FK_CP_UserNotesStatus_sma_TRN_Notes]
--GO
ALTER TABLE [dbo].[sma_TRN_ExpertsFromContacts]  WITH CHECK ADD  CONSTRAINT [FK_ExpertContact] FOREIGN KEY([efcnExpertID])
REFERENCES [dbo].[sma_TRN_ExpertContacts] ([ectnExpertContactID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[sma_TRN_ExpertsFromContacts] CHECK CONSTRAINT [FK_ExpertContact]
GO


ALTER TABLE [dbo].[ACC_Account]  WITH CHECK ADD  CONSTRAINT [FK_ACC_Account_sma_MST_Users] FOREIGN KEY([CreatedUserID])
REFERENCES [dbo].[sma_MST_Users] ([usrnUserID])
GO

ALTER TABLE [dbo].[ACC_Account] CHECK CONSTRAINT [FK_ACC_Account_sma_MST_Users]
GO

ALTER TABLE [dbo].[ACC_Account]  WITH CHECK ADD  CONSTRAINT [FK_ACC_Account_sma_MST_Users1] FOREIGN KEY([ModifiedUserID])
REFERENCES [dbo].[sma_MST_Users] ([usrnUserID])
GO

ALTER TABLE [dbo].[ACC_Account] CHECK CONSTRAINT [FK_ACC_Account_sma_MST_Users1]
GO




ALTER TABLE [dbo].[sma_TRN_CaseContactComment] CHECK CONSTRAINT [FK_sma_TRN_CaseContactComment_sma_TRN_Cases]
GO
--delete from sma_TRN_AutomatedActions
--go
truncate table  sma_TRN_ContactDocuments
go
truncate table  sma_MST_OtherCasesContact
go
truncate table  sma_TRN_SearchEngine
go
ALTER TABLE [dbo].[ACC_Contractor] DROP CONSTRAINT [FK_ACC_Contractor_sma_MST_AllContactInfo]
GO
ALTER TABLE [dbo].[QBO_SyncContractor] DROP CONSTRAINT [FK_QBO_SyncContractor_sma_MST_AllContactInfo]
GO

alter table [dbo].sma_mst_allcontactinfo disable trigger all
delete from [dbo].sma_mst_allcontactinfo 
DBCC CHECKIDENT ('[dbo].sma_mst_allcontactinfo', RESEED, 0);
alter table [dbo].sma_mst_allcontactinfo enable trigger all

--truncate table sma_mst_allcontactinfo

ALTER TABLE [dbo].[ACC_Contractor]  WITH CHECK ADD  CONSTRAINT [FK_ACC_Contractor_sma_MST_AllContactInfo] FOREIGN KEY([AllContactID])
REFERENCES [dbo].[sma_MST_AllContactInfo] ([UniqueContactId])
GO
																																																			  

ALTER TABLE [dbo].[ACC_Contractor] CHECK CONSTRAINT [FK_ACC_Contractor_sma_MST_AllContactInfo]
GO

ALTER TABLE [dbo].[QBO_SyncContractor]  WITH CHECK ADD  CONSTRAINT [FK_QBO_SyncContractor_sma_MST_AllContactInfo] FOREIGN KEY([SAContactID])
REFERENCES [dbo].[sma_MST_AllContactInfo] ([UniqueContactId])
GO

ALTER TABLE [dbo].[QBO_SyncContractor] CHECK CONSTRAINT [FK_QBO_SyncContractor_sma_MST_AllContactInfo]
GO



alter table sma_mst_address disable trigger all 
go
alter table sma_MST_ContactNumbers disable trigger all 
go
alter table sma_MST_EmailWebsite disable trigger all 
go
alter table sma_MST_IndvContacts disable trigger all 
go
alter table sma_MST_OrgContacts disable trigger all 
go
Delete from sma_mst_address where addnContactCtgID=1 and addnContactID in (select cinnContactID from sma_MST_IndvContacts where cinnContactID not in (select usrncontactid from sma_mst_users) and cinnContactID not in (8,9))
Delete from sma_MST_ContactNumbers where cnnnContactCtgID=1 and cnnnContactID in (select cinnContactID from sma_MST_IndvContacts where cinnContactID not in (select usrncontactid from sma_mst_users) and cinnContactID not in (8,9))
Delete from sma_MST_EmailWebsite where cewnContactCtgID=1 and cewnContactID in (select cinnContactID from sma_MST_IndvContacts where cinnContactID not in (select usrncontactid from sma_mst_users) and cinnContactID not in (8,9))
delete  from sma_MST_IndvContacts where cinnContactID in  (select cinnContactID from sma_MST_IndvContacts where cinnContactID not in (select usrncontactid from sma_mst_users) and cinnContactID not in (8,9))

--select connContactID from sma_MST_OrgContacts where '2'+cast(connContactID as varchar(20)) not in (select frinUniqueContactId from sma_MST_FirmInfo )
  

Delete from sma_mst_address where addnContactCtgID=2 and addnContactID in (select connContactID from sma_MST_OrgContacts where '2'+cast(connContactID as varchar(20)) not in (select frinUniqueContactId from sma_MST_FirmInfo ))
Delete from sma_MST_ContactNumbers where cnnnContactCtgID=2 and cnnnContactID in (select connContactID from sma_MST_OrgContacts where '2'+cast(connContactID as varchar(20)) not in (select frinUniqueContactId from sma_MST_FirmInfo ))
Delete from sma_MST_EmailWebsite where cewnContactCtgID=2 and cewnContactID in (select connContactID from sma_MST_OrgContacts where '2'+cast(connContactID as varchar(20)) not in (select frinUniqueContactId from sma_MST_FirmInfo ))
delete from sma_MST_OrgContacts where conncontactid in(select connContactID from sma_MST_OrgContacts where '2'+cast(connContactID as varchar(20)) not in (select frinUniqueContactId from sma_MST_FirmInfo ))

alter table sma_mst_address enable trigger all 
go
alter table sma_MST_ContactNumbers enable trigger all 
go
alter table sma_MST_EmailWebsite enable trigger all 
go
alter table sma_MST_IndvContacts enable trigger all 
go
alter table sma_MST_OrgContacts enable trigger all 
go