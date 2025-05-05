select m.litify_pm__Open_Date__c, cas.*
from sma_trn_Cases cas
JOIN  LitifyLesser..[litify_pm__intake__c] m on cas.litify_Saga = m.id
where casdOpeningDate is null



update cas
set casdOpeningDate = cas.casdDtCreated
from sma_trn_Cases cas
JOIN  LitifyLesser..[litify_pm__intake__c] m on cas.litify_Saga = m.id
where casdOpeningDate is null