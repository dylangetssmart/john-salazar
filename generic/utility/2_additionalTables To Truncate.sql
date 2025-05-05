use JoelBieberSA_Needles
go

truncate table sma_trn_incidents
truncate table sma_trn_settlements
truncate table sma_TRN_Hospitals

alter table [sma_TRN_OtherReferral] disable trigger all

delete from [sma_TRN_OtherReferral]

DBCC CHECKIDENT ('[sma_TRN_OtherReferral]', RESEED, 0);
alter table [sma_TRN_OtherReferral] enable trigger all

truncate table sma_TRN_Defendants

alter table sma_TRN_CheckReceivedFeeRecorded disable trigger all
delete from sma_TRN_CheckReceivedFeeRecorded
DBCC CHECKIDENT ('sma_TRN_CheckReceivedFeeRecorded', RESEED, 0);
alter table sma_TRN_CheckReceivedFeeRecorded disable trigger all


alter table [sma_TRN_InsuranceCoverage] disable trigger all
delete from [sma_TRN_InsuranceCoverage]
DBCC CHECKIDENT ('[sma_TRN_InsuranceCoverage]', RESEED, 0);
alter table [sma_TRN_InsuranceCoverage] disable trigger all


alter table [sma_TRN_PlaintiffAttorney] disable trigger all
delete from [sma_TRN_PlaintiffAttorney] 
DBCC CHECKIDENT ('[sma_TRN_PlaintiffAttorney]', RESEED, 0);
alter table [sma_TRN_PlaintiffAttorney] enable trigger all

alter table [sma_TRN_LawFirms] disable trigger all
delete from [sma_TRN_LawFirms] 
DBCC CHECKIDENT ('[sma_TRN_LawFirms]', RESEED, 0);
alter table [sma_TRN_LawFirms] enable trigger all

alter table [sma_TRN_LawFirmAttorneys] disable trigger all
delete from [sma_TRN_LawFirmAttorneys] 
DBCC CHECKIDENT ('[sma_TRN_LawFirmAttorneys]', RESEED, 0);
alter table [sma_TRN_LawFirmAttorneys] enable trigger all


alter table [sma_TRN_Courts] disable trigger all
delete from [sma_TRN_Courts]
DBCC CHECKIDENT ('[sma_TRN_Courts]', RESEED, 0);
alter table [sma_TRN_Courts] enable trigger all

alter table [sma_TRN_SOLs] disable trigger all
delete [sma_TRN_SOLs]
DBCC CHECKIDENT ('[sma_TRN_SOLs]', RESEED, 0);
alter table [sma_TRN_SOLs] enable trigger all

alter table [sma_TRN_CriticalDeadlines] disable trigger all
delete [sma_TRN_CriticalDeadlines]
DBCC CHECKIDENT ('[sma_TRN_CriticalDeadlines]', RESEED, 0);
alter table [sma_TRN_CriticalDeadlines] enable trigger all


alter table [sma_TRN_PlaintiffDeath] disable trigger all
delete from [sma_TRN_PlaintiffDeath] 
DBCC CHECKIDENT ('[sma_TRN_PlaintiffDeath]', RESEED, 0);
alter table [sma_TRN_PlaintiffDeath] enable trigger all


alter table [sma_TRN_ReferredOut] disable trigger all
delete [sma_TRN_ReferredOut]
DBCC CHECKIDENT ('[sma_TRN_ReferredOut]', RESEED, 0);
alter table [sma_TRN_ReferredOut] enable trigger all


alter table [sma_TRN_LostWages] disable trigger all
delete [sma_TRN_LostWages]
DBCC CHECKIDENT ('[sma_TRN_LostWages]', RESEED, 0);
alter table [sma_TRN_LostWages] enable trigger all

alter table [sma_TRN_Lienors] disable trigger all
delete from [sma_TRN_Lienors] 
DBCC CHECKIDENT ('[sma_TRN_Lienors]', RESEED, 0);
alter table [sma_TRN_Lienors] enable trigger all

alter table [sma_TRN_LienDetails] disable trigger all
delete from [sma_TRN_LienDetails] 
DBCC CHECKIDENT ('[sma_TRN_LienDetails]', RESEED, 0);
alter table [sma_TRN_LienDetails] enable trigger all

alter table [sma_TRN_Depositions] disable trigger all
delete from [sma_TRN_Depositions] 
DBCC CHECKIDENT ('[sma_TRN_Depositions]', RESEED, 0);
alter table [sma_TRN_Depositions] enable trigger all

truncate table [sma_trn_OthCases]
truncate table [sma_trn_Vehicles]

truncate table [sma_TRN_UDFTableRowValues]
truncate table [sma_TRN_LitigationDiscovery]
truncate table [sma_TRN_UDFValues]
truncate table [sma_TRN_UDFTableRows]

truncate table sma_TRN_PdAdvt
truncate table sma_TRN_Retainer

truncate table [sma_TRN_SpecialDamageAmountPaid]
truncate table [sma_TRN_SpDamages]

truncate table sma_TRN_Injury

truncate table sma_trn_emails

alter table sma_trn_Documents disable trigger all
delete from sma_trn_Documents
DBCC CHECKIDENT ('sma_trn_Documents', RESEED, 0);
alter table sma_trn_Documents disable trigger all

truncate table sma_TRN_CalendarAppointments

truncate table sma_trn_casetags
TRUNCATE TABLE [sma_TRN_CaseStaff]
truncate table [sma_TRN_CaseStatus]

truncate table sma_MST_RelContacts


alter table sma_trn_Notes disable trigger all
delete from sma_trn_Notes
DBCC CHECKIDENT ('sma_trn_Notes', RESEED, 0);
alter table sma_trn_Notes disable trigger all