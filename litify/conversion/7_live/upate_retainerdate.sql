SELECT * FROM sma_TRN_Retainer str where str.rtnnCaseID = 596
SELECT * FROM sma_TRN_Cases stc where stc.casnCaseID = 596
--SELECT lpmc.litify_pm__Open_Date__c FROM ShinerLitify..litify_pm__Matter__c lpmc where lpmc.Id = 'a0L8Z00000gCdZaUAK'


select
--count(*)
*
FROM sma_TRN_Retainer str where str.rtndRcvdDt is null
-- 1282



---- when retainerdt is not null, use that for rcvddt (retainerdt was set to case open date)
select
count(*)
FROM sma_TRN_Retainer str where str.rtndRcvdDt is null and rtndRetainerDt is not null

update sma_TRN_Retainer
set rtndRcvdDt = rtndRetainerDt
where rtndRcvdDt is null and rtndRetainerDt is not null

---- when retainerdt is null, rtndSentDt is not null, use case open date
---- these are from intake
select
--count(*),
*
FROM sma_TRN_Retainer str where str.rtndRcvdDt is null and str.rtndRetainerDt is null and rtndSentDt is not null
-- 415

update ret
set rtndRcvdDt =
case
	when (i.litify_pm__Open_Date__c between '1900-01-01' and '2079-12-31')
		then i.litify_pm__Open_Date__c
end
from sma_TRN_Retainer ret
join sma_TRN_Cases cas
	on cas.casnCaseID = ret.rtnnCaseID
join ShinerLitify..litify_pm__Intake__c i
	on i.Id = cas.saga_char
--left join ShinerLitify..litify_pm__Intake__c i
--	on i.litify_pm__Matter__c = mat.Id
where ret.rtndRcvdDt is null and ret.rtndRetainerDt is null and rtndSentDt is not null



--select * 
--from sma_TRN_Retainer ret
--join sma_TRN_Cases cas
--	on cas.casnCaseID = ret.rtnnCaseID
--join ShinerLitify..litify_pm__Intake__c i
--	on i.Id = cas.saga_char
----left join ShinerLitify..litify_pm__Intake__c i
----	on i.litify_pm__Matter__c = mat.Id
--where ret.rtndRetainerDt is null 

--SELECT * FROM ShinerLitify..litify_pm__Intake__c lpic