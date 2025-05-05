/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-23
Description: Create attorneys

--------------------------------------------------------------------------------------------------------------------------------------
Step								Object								Action			Source				
--------------------------------------------------------------------------------------------------------------------------------------
[1] Attorney Types					sma_MST_AttorneyTypes				insert			litify_pm__Role__c

[2] Plaintiff Attorneys
	[2.1]							sma_TRN_PlaintiffAttorney			insert			litify_pm__Originating_Attorney__c, litify_pm__Principal_Attorney__c
	[2.2]							sma_TRN_PlaintiffAttorney			insert			litify_pm__Role__c

[3] Defense Attorneys	
	[3.0]							sma_TRN_LawFirms					insert			litify_pm__Role__c

[4] Attorney Lists
	[4.1] Plaintiff Attorneys		sma_TRN_LawFirmAttorneys			insert			sma_TRN_LawFirms
	[4.2] Defense Attorneys			sma_TRN_LawFirmAttorneys			insert			sma_TRN_PlaintiffAttorney
						
##########################################################################################################################
*/

use ShinerSA
go

-----------------------------------------------------------------------------------
-- [1] INSERT ATTORNEY TYPES
-- Originating Attorney and Principal Attorney from matter
-- Attorney, Law Firm
-----------------------------------------------------------------------------------
insert into sma_MST_AttorneyTypes
	(
	atnsAtorneyDscrptn
	)
	-- Columns from matter
	select
		'Originating Attorney'
	union
	select
		'Principal Attorney'
	union
	select
		'Opposing Party Attorney'
	union
	-- From Party Role Mapping
	select distinct
		litify_pm__Role__c
	from ShinerLitify..litify_pm__Role__c
	where litify_pm__Role__c in ('Attorney', 'Law Firm')
	except
	select
		atnsAtorneyDscrptn
	from sma_MST_AttorneyTypes
