SELECT top 5 i.id as intake_id, m.id as matter_id, i.lps_Referred_To__c FROM ShinerLitify..litify_pm__Intake__c i
join ShinerLitify..litify_pm__Matter__c m
on i.litify_pm__Matter__c = m.Id
where isnull(i.lps_Referred_To__c ,'')<>''

--intake_id				matter_id				lps_Referred_To__c
--a0C8Z00000gYEibUAG	a0L8Z00000fKMe9UAG		001Nt000004PcMLIA0
--a0C8Z00000gZ5IkUAK	a0L8Z00000fmYMkUAM		001Nt000004PcMLIA0
--a0C8Z00000jtzjIUAQ	a0L8Z00000hNay8UAC		0018Z00002rz0R8QAI
--a0C8Z00000ju2aLUAQ	a0L8Z00000gcysSUAQ		001Nt000004PcMLIA0
--a0C8Z00000ju6cqUAA	a0L8Z00000gdp0dUAA		0018Z00002rz0R8QAI

select name from ShinerLitify..litify_pm__Matter__c lpmc where id = 'a0L8Z00000fKMe9UAG'

SELECT *
FROM IndvOrgContacts_Indexed ioci
where ioci.saga_char = '001Nt000004PcMLIA0'


/* ---------------------------------------------------------------------------------------------------------------
[sma_TRN_ReferredOut] Schema
*/

-- saga_char
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_TRN_ReferredOut')
	)
begin
	alter table [sma_TRN_ReferredOut] add [saga_char] VARCHAR(MAX) null;
end

go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and object_id = OBJECT_ID(N'sma_TRN_ReferredOut')
	)
begin
	alter table [sma_TRN_ReferredOut] add [source_db] VARCHAR(MAX) null;
end

go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and object_id = OBJECT_ID(N'sma_TRN_ReferredOut')
	)
begin
	alter table [sma_TRN_ReferredOut] add [source_ref] VARCHAR(MAX) null;
end

go

/* ---------------------------------------------------------------------------------------------------------------
Insert critical comments
*/

insert into [sma_TRN_ReferredOut]
	(
		rfosType,
		rfonCaseID,
		rfonPlaintiffID,
		rfonLawFrmContactID,
		rfonLawFrmAddressID,
		rfonAttContactID,
		rfonAttAddressID,
		rfonGfeeAgreement,
		rfobMultiFeeStru,
		rfobComplexFeeStru,
		rfonReferred,
		rfonCoCouncil,
		rfonIsLawFirmUpdateToSend,
		rfodRefOutDt,
			[saga_char],
		[source_db],
		[source_ref]
	)

	select
		'G'								  as rfostype,
		cas.casnCaseID					  as rfoncaseid,
		-1								  as rfonplaintiffid,
		case
			when ioc.CTG = 2
				then ioc.CID
			else null
		end								  as rfonlawfrmcontactid,
		case
			when ioc.CTG = 2
				then ioc.AID
			else null
		end								  as rfonlawfrmaddressid,
		case
			when ioc.CTG = 1
				then ioc.CID
			else null
		end								  as rfonattcontactid,
		case
			when ioc.CTG = 1
				then ioc.AID
			else null
		end								  as rfonattaddressid,
		0								  as rfongfeeagreement,
		0								  as rfobmultifeestru,
		0								  as rfobcomplexfeestru,
		1								  as rfonreferred,
		0								  as rfoncocouncil,
		0								  as rfonislawfirmupdatetosend,
		i.litify_pm__Referred_Out_Date__c as rfodRefOutDt,
				i.Id				   as [saga_char],
		'litify'			   as [source_db],
		'litify_pm__Intake__c' as [source_ref]
	from ShinerLitify..litify_pm__Intake__c i
	join ShinerLitify..litify_pm__Matter__c m
		on m.id = i.litify_pm__Matter__c
	join sma_trn_Cases cas
		on cas.saga_char = m.Id
	join [IndvOrgContacts_Indexed] ioc
		on ioc.saga_char = i.lps_Referred_To__c
	where
		ISNULL(i.lps_Referred_To__c, '') <> ''
		and m.Id = 'a0L8Z00000fKMe9UAG'
	--from JoelBieberNeedles.[dbo].[cases_indexed] c
	--join [sma_TRN_cases] cas
	--	on cas.cassCaseNumber = c.casenum
	--join [IndvOrgContacts_Indexed] ioc
	--	on ioc.SAGA = c.referred_to_id
	--		and c.referred_to_id > 0

--(2)--
--update sma_MST_IndvContacts
--set cinnContactTypeID = (
--	select
--		octnOrigContactTypeID
--	from [dbo].[sma_MST_OriginalContactTypes]
--	where octsDscrptn = 'Attorney'
--)
--where cinnContactID in (
--	select
--		rfonAttContactID
--	from sma_TRN_ReferredOut
--	where ISNULL(rfonAttContactID, '') <> ''
--)