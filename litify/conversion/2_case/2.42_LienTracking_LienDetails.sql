/* 
###########################################################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-24
Description: Create lienors and lien details

Step							Target						Source
-----------------------------------------------------------------------------------------------
[1.0] Lien Types				sma_MST_LienType			hardcode
[2.0] Lienors					sma_TRN_Lienors				[litify_pm__Lien__c]
[3.0] Lienors					sma_TRN_Lienors				[litify_pm__Damage__c]
[4.0] Lien Details				sma_TRN_LienDetails			[litify_pm__Lien__c]
[5.0] Lien Details				sma_TRN_LienDetails			[litify_pm__Damage__c]

*/

use ShinerSA
go

/* ---------------------------------------------------------------------------------------------------------------------------------
schema > saga_char
*/
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_TRN_LienDetails')
	)
begin
	alter table [sma_TRN_LienDetails]
	add saga_char VARCHAR(100)
end
go


/* ---------------------------------------------------------------------------------------------------------------------------------
Insert Lien Details from [litify_pm__Damage__c]
*/

alter table [sma_TRN_LienDetails] disable trigger all
go

insert into [sma_TRN_LienDetails]
	(
	lndnLienorID,
	lndnLienTypeID,
	lndnCnfrmdLienAmount,
	lndsRefTable,
	lndnRecUserID,
	lnddDtCreated,
	saga_char
	)
	select
		lnrnLienorID		 as lndnlienorid,
		lnrnLienorTypeID	 as lndnlientypeid,
		lnrnCnfrmdLienAmount as lndncnfrmdlienamount,
		'sma_TRN_Lienors'	 as lndsreftable,
		368					 as lndnrecuserid,
		GETDATE()			 as lndddtcreated,
		lien.saga_char		 as saga

	from --[ShinerLitify]..[litify_pm__Damage__c] l
	--JOIN sma_trn_Cases cas on cas.Litify_saga = l.id
	sma_TRN_Lienors lien --on  lien.saga = l.Id
	left join [sma_TRN_LienDetails] ld
		on ld.lndnlienorid = lien.lnrnLienorID
			and ld.lndnlientypeid = lien.lnrnLienorTypeID
			and ld.lndncnfrmdlienamount = lien.lnrnCnfrmdLienAmount
	where ld.lndnLienDetailID is null
go

/*
ds 2025-03-03
as per Sue, only create Lienors from damages
*/

/* ---------------------------------------------------------------------------------------------------------------------------------
Insert Lien Details from [litify_pm__Lien__c]
*/

--insert into [sma_TRN_LienDetails]
--	(
--	lndnLienorID,
--	lndnLienTypeID,
--	lndnCnfrmdLienAmount,
--	lndsRefTable,
--	lndnRecUserID,
--	lnddDtCreated,
--	saga_char
--	)
--	select
--		lnrnLienorID		 as lndnlienorid,
--		lnrnLienorTypeID	 as lndnlientypeid,
--		lnrnCnfrmdLienAmount as lndncnfrmdlienamount,
--		'sma_TRN_Lienors'	 as lndsreftable,
--		368					 as lndnrecuserid,
--		GETDATE()			 as lndddtcreated,
--		l.Id				 as saga
--	from [ShinerLitify]..[litify_pm__Lien__c] l
--	join sma_TRN_Cases cas
--		on cas.saga_char = l.Id
--	join sma_TRN_Lienors lien
--		on lien.[lnrnCaseID] = cas.casnCaseID
--			and lien.saga_char = l.Id
--go

alter table [sma_TRN_LienDetails] enable trigger all
go