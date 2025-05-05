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

/*
######################################################################
Lien Types
######################################################################
*/
insert into sma_MST_LienType
	(
	lntsDscrptn
	)
	--SELECT DISTINCT
	--	ISNULL([type__c], 'Unknown')
	--FROM ShinerLitify..[litify_pm__Lien__c]
	select
		'Unknown'
	union
	select
		'Subrogation Lien'
	except
	select
		lntsDscrptn
	from sma_MST_LienType
go