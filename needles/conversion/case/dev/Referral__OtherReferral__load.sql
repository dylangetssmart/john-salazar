use [SA]
go

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
		ioci.CTG		   as [otrnrefcontactctg],
		ioci.CID		   as [otrnrefcontactid],
		ioci.AID		   as [otrnrefaddressid],
		-1			   as [otrnplaintiffid],
		null		   as [otrscomments],
		368			   as [otrnuserid],
		GETDATE()	   as [otrddtcreated]
	from KurtYoung_Needles.[dbo].[cases_indexed] c
	join [sma_TRN_cases] cas
		on cas.cassCaseNumber = convert(varchar,c.casenum)
	join [IndvOrgContacts_Indexed] ioci
		on ioci.SAGA = c.referred_link
			and c.referred_link > 0