use ShinerSA
go


--------------

--select
--	*
--from ShinerLitify..[litify_pm__expense__c]
--where litify_pm__Matter__c = 'a0L8Z00000eDnNFUA0'
---- matter a0L8Z00000eDnNFUA0
--select
--	*
--from shinersa..sma_TRN_Cases stc
--where stc.Litify_saga = 'a0L8Z00000eDnNFUA0'


---- Expense Types
--select
--	*
--from ShinerLitify..litify_pm__Expense__c lpec
----litify_pm__ExpenseType2__c > a088Z000015ywrGQAQ
----Expense_Type__c
--select distinct
--	Expense_Type__c
--from ShinerLitify..litify_pm__Expense__c lpec

--select distinct
--	lpetc.name
--from ShinerLitify..litify_pm__Expense_Type__c lpetc
--left join ShinerLitify..litify_pm__Expense__c lpec
--	on lpec.litify_pm__ExpenseType2__c = lpetc.Id
--where lpetc.Id = 'a088Z000015ywrGQAQ'

------------


/*
alter table [sma_TRN_Disbursement] disable trigger all
delete from [sma_TRN_Disbursement] 
DBCC CHECKIDENT ('[sma_TRN_Disbursement]', RESEED, 0);
alter table [sma_TRN_Disbursement] enable trigger all

*/

--select distinct code, description from [NeedlesSchechter].[dbo].[value] order by code

---(0)---
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_TRN_Disbursement')
	)
begin
	alter table [sma_TRN_Disbursement] add [saga_char] VARCHAR(100) null;
end

go

--ALTER TABLE [sma_TRN_Disbursement]
--ALTER COLUMN saga VARCHAR(100)
--GO

------------------------
--CHECK STATUS
------------------------
insert into [sma_MST_CheckRequestStatus]
	(
		[Description]
	)
	select distinct
		litify_pm__Status__c
	from [ShinerLitify].[dbo].[litify_pm__Expense__c] e
	where
		ISNULL(litify_pm__Status__c, '') <> ''
	except
	select
		[Description]
	from [sma_MST_CheckRequestStatus]

------------------------
--DISBURSEMENT TYPE
------------------------
insert into [sma_MST_DisbursmentType]
	(
		dissTypeName
	)
	-- From [litify_pm__expense__c].[expense_type__c]
	select distinct
		ISNULL(Expense_Type__c, 'Unknown')
	from [ShinerLitify].[dbo].[litify_pm__expense__c]

	union

	-- From [litify_pm__Expense_Type__c].[name]
	select distinct
		lpetc.name
	from ShinerLitify..litify_pm__Expense_Type__c lpetc
	join ShinerLitify..litify_pm__Expense__c lpec
		on lpec.litify_pm__ExpenseType2__c = lpetc.Id

	except
	select
		dissTypeName
	from [sma_MST_DisbursmentType]

--select * FROM [sma_MST_DisbursmentType]
---
alter table [sma_TRN_Disbursement] disable trigger all
go

---(1)---
insert into [sma_TRN_Disbursement]
	(
		disnCaseID,
		disnPayeeContactCtgID,
		disnPayeeContactID,
		disnAmount,
		dissInvoiceNumber,
		disnPlaintiffID,
		dissDisbursementType,
		UniquePayeeID,
		dissDescription,
		dissComments,
		disnCheckRequestStatus,
		dissCheckNo,
		disdBillDate,
		disdDueDate,
		disnRecUserID,
		disdDtCreated,
		disnRecoverable,
		saga_char
	)
	select
		cas.casnCaseID						as disncaseid,
		ioc.CTG								as disnpayeecontactctgid,
		ioc.CID								as disnpayeecontactid,
		e.litify_pm__Amount__c				as disnamount,
		null								as dissinvoicenumber,
		(
			select top 1
				plnnPlaintiffID
			from sma_trn_plaintiff
			where plnnCaseID = cas.casncaseid
				and plnbIsPrimary = 1
		)									as disnplaintiffid
		--  ,(
		--	SELECT
		--		disnTypeID
		--	FROM [sma_MST_DisbursmentType]
		--	WHERE dissTypeName = ISNULL(expense_type__c, 'Unknown')
		--)
		--AS dissDisbursementType
		,
		(
			select
				disnTypeID
			from [sma_MST_DisbursmentType]
			where dissTypeName = ISNULL(lpetc.Name, 'Unknown')
		)									as dissdisbursementtype,
		ioc.UNQCID							as uniquepayeeid,
		e.litify_pm__Expense_Description__c as dissdescription,
		ISNULL('Note: ' + NULLIF(CONVERT(VARCHAR, e.litify_pm__Note__c), '') + CHAR(13), '') +
		ISNULL('Invoice Number: ' + NULLIF(CONVERT(VARCHAR, e.litify_pm__lit_Invoice__c), '') + CHAR(13), '') +
		''									as disscomments
		--ISNULL('Payment Mode: ' + NULLIF(CONVERT(VARCHAR, e.Payment_Mode__c), '') + CHAR(13), '') +
		--ISNULL('Bank Account Name: ' + NULLIF(CONVERT(VARCHAR, e.Bank_Account_Name__c), '') + CHAR(13), '') +
		--ISNULL('Bank Account: ' + NULLIF(CONVERT(VARCHAR, e.BankAccount_sk__c), '') + CHAR(13), '') +
		,
		(
			select
				Id
			from [sma_MST_CheckRequestStatus]
			where [Description] = e.litify_pm__Status__c
		)									as disncheckrequeststatus,
		null								as disscheckno,
		case
			when e.[litify_pm__Date__c] between '1900-01-01' and '2079-06-06'
				then e.[litify_pm__Date__c]
			else null
		end									as disdbilldate,
		null								as disdduedate,
		(
			select
				usrnUserID
			from sma_MST_Users
			where saga_char = e.CreatedById
		)									as disnrecuserid,
		e.CreatedDate						as disddtcreated,
		1									as disnrecoverable,
		e.Id								as saga_char
	--select *--max(len(litify_pm__lit_invoice__c))
	from [ShinerLitify].[dbo].[litify_pm__expense__c] e
	join sma_TRN_Cases cas
		on cas.saga_char = e.litify_pm__Matter__c
	left join IndvOrgContacts_Indexed ioc
		on ioc.saga_char = e.litify_ext__Payee_Party__c
	left join ShinerLitify..litify_pm__Expense_Type__c lpetc
		on e.litify_pm__ExpenseType2__c = lpetc.Id
	--where
	--	e.litify_pm__Matter__c = 'a0L8Z00000gCdZaUAK'
go

---
alter table [sma_TRN_Disbursement] enable trigger all
go
---