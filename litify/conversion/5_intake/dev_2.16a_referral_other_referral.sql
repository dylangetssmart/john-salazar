/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create users and contacts

replace:
'OfficeName'
'StateDescription'
'VenderCaseType'
##########################################################################################################################
*/





use [JoelBieberSA_Needles]
go

/*
alter table [sma_TRN_OtherReferral] disable trigger all
delete [sma_TRN_OtherReferral]
DBCC CHECKIDENT ('[sma_TRN_OtherReferral]', RESEED, 0);
alter table [sma_TRN_OtherReferral] enable trigger all
*/

--(1)--

insert into [sma_TRN_OtherReferral]
	(
	[otrnCaseID],
	[otrnRefContactCtg],
	[otrnRefContactID],
	[otrnRefAddressID],
	[otrnPlaintiffID],
	[otrsComments],
	[otrnUserID],
	[otrdDtCreated]
	)
	select
		cas.casnCaseID as [otrncaseid],
		ioc.CTG		   as [otrnrefcontactctg],
		ioc.CID		   as [otrnrefcontactid],
		ioc.AID		   as [otrnrefaddressid],
		-1			   as [otrnplaintiffid],
		null		   as [otrscomments],
		368			   as [otrnuserid],
		GETDATE()	   as [otrddtcreated]
	from JoelBieberNeedles.[dbo].[cases_indexed] c
	join [sma_TRN_cases] cas
		on cas.cassCaseNumber = c.casenum
	join [IndvOrgContacts_Indexed] ioc
		on ioc.SAGA = c.referred_link
			and c.referred_link > 0
