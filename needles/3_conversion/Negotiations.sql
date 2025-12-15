use [SA]
go



/* ------------------------------------------------------------------------------
Insert [sma_TRN_Negotiations]
------------------------------------------------------------------------------ */
exec AddBreadCrumbsToTable 'sma_TRN_Negotiations'
go

-- SettlementAmount
if not exists (
	 select
		 *
	 from sys.columns
	 where Name = N'SettlementAmount'
		 and object_id = OBJECT_ID(N'sma_TRN_Negotiations')
	)
begin
	alter table sma_TRN_Negotiations
	add SettlementAmount DECIMAL(18, 2) null
end

go

alter table [sma_TRN_Negotiations] disable trigger all
go

insert into [sma_TRN_Negotiations]
	(
		[negnCaseID],
		[negsUniquePartyID],
		[negdDate],
		[negnStaffID],
		[negnPlaintiffID],
		[negbPartiallySettled],
		[negnClientAuthAmt],
		[negbOralConsent],
		[negdOralDtSent],
		[negdOralDtRcvd],
		[negnDemand],
		[negnOffer],
		[negbConsentType],
		[negnRecUserID],
		[negdDtCreated],
		[negnModifyUserID],
		[negdDtModified],
		[negnLevelNo],
		[negsComments],
		[SettlementAmount],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		CAS.casnCaseID as [negnCaseID],
		('I' + CONVERT(VARCHAR, (
		 select top 1
			 incnInsCovgID
		 from [sma_TRN_InsuranceCoverage] INC
		 where INC.incnCaseID = CAS.casnCaseID
			 and INC.saga = INS.insurance_id
			 and INC.incnInsContactID = (
			  select top 1
				  connContactID
			  from [sma_MST_OrgContacts]
			  where saga = INS.insurer_id
			 )
		)))			   
		as [negsUniquePartyID],
		case
			when NEG.neg_date between '1900-01-01' and '2079-12-31' then NEG.neg_date
			else null
		end			   as [negdDate],
		(
		 select
			 usrnContactID
		 from sma_MST_Users
		 where source_id = NEG.staff
		)			   as [negnStaffID],
		-1			   as [negnPlaintiffID],
		null		   as [negbPartiallySettled],
		case
			when NEG.kind = 'Client Auth.' then NEG.amount
			else null
		end			   as [negnClientAuthAmt],
		null		   as [negbOralConsent],
		null		   as [negdOralDtSent],
		null		   as [negdOralDtRcvd],
		case
			when NEG.kind = 'Demand' then NEG.amount
			else null
		end			   as [negnDemand],
		case
			when NEG.kind in ('Offer', 'Conditional Ofr') then NEG.amount
			else null
		end			   as [negnOffer],
		null		   as [negbConsentType],
		368,
		GETDATE(),
		368,
		GETDATE(),
		0			   as [negnLevelNo],
		ISNULL(NEG.kind + ' : ' + NULLIF(CONVERT(VARCHAR, NEG.amount), '') + CHAR(13) + CHAR(10), '') +
		NEG.notes	   as [negsComments],
		case
			when NEG.kind = 'Settled' then NEG.amount
			else null
		end			   as [SettlementAmount],
		neg.neg_id	   as [saga],
		null		   as [source_id],
		'needles'	   as [source_db],
		'negotiation'  as [source_ref]
	from [Needles].[dbo].[negotiation] NEG
	left join [Needles].[dbo].[insurance_Indexed] INS
		on INS.insurance_id = NEG.insurance_id
	join [sma_TRN_cases] CAS
		on CAS.saga = neg.case_id
	left join [Insurance_Contacts_Helper] MAP
		on INS.insurance_id = MAP.insurance_id
go

alter table [sma_TRN_Negotiations] enable trigger all
go
-----------------
/*

INSERT INTO [sma_TRN_Settlements]
(
    stlnSetAmt,
    stlnStaffID,
    stlnPlaintiffID,
    stlsUniquePartyID,
    stlnCaseID,
    stlnNegotID
)
SELECT 
    SettlementAmount    as stlnSetAmt,
    negnStaffID			as stlnStaffID,
	negnPlaintiffID		as stlnPlaintiffID,
    negsUniquePartyID   as stlsUniquePartyID,
    negnCaseID		    as stlnCaseID,
    negnID				as stlnNegotID
FROM [sma_TRN_Negotiations]
WHERE isnull(SettlementAmount ,0) > 0

*/
