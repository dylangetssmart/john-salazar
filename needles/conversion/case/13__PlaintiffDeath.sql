/*---
group: party
order: 4
description: Update contact types for attorneys
---*/

/* ###################################################################################
description: Insert plaintiff death
steps:
	- Insert plantiff death from individual contact records > [sma_TRN_PlaintiffDeath]
	
usage_instructions:
	- 
dependencies:
	- 
notes:
	-
*/


USE [SA]
GO
/*
delete from [sma_TRN_PlaintiffDeath] 
DBCC CHECKIDENT ('[sma_TRN_PlaintiffDeath]', RESEED, 0);
*/

alter table [sma_TRN_PlaintiffDeath] disable trigger all
go

INSERT INTO [sma_TRN_PlaintiffDeath] 
( 
	[pldnCaseID],
	[pldnPlaintiffID],
	[pldnContactID],
	[plddDeathDt],
	[pldbAutopsyYN] 
) 
SELECT 
    P.plnnCaseID	    as [pldnCaseID],
    P.plnnPlaintiffID   as [pldnPlaintiffID],
    P.plnnContactID	    as [pldnContactID],
    I.cindDateOfDeath   as [plddDeathDt],
    0				    as [pldbAutopsyYN]
FROM [sma_TRN_Plaintiff]  P
JOIN [sma_MST_IndVContacts] I
	on I.cinnContactID = P.plnnContactID
WHERE cindDateOfDeath is not null

alter table [sma_TRN_PlaintiffDeath] enable trigger all