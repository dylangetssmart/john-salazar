
INSERT INTO sma_MST_CaseStatus (csssdescription, cssnstatustypeid)
SELECT 'Pending', 1
EXCEPT SELECT csssdescription, cssnstatustypeid FROM sma_MST_CaseStatus

UPDATE st
set cssnStatusID = stat.cssnStatusID
--select litify_pm__Status__c, stat.cssnStatusID
FROM [sma_trn_cases] CAS
JOIN LitifyLesser..[litify_pm__intake__c] m on m.Id = CAS.Litify_saga
JOIN sma_TRN_CaseStatus st on st.cssnCaseID = cas.casnCaseID
LEFT JOIN sma_MST_CaseStatus stat on stat.cssnstatustypeid = 1 and 
								stat.csssDescription = case when litify_pm__Status__c = 'BOLO' then 'Intake - BOLO'
													when litify_pm__Status__c = 'Contracts Sent' then 'Intake - Contracts Sent'
													when litify_pm__Status__c = 'Contracts Signed' then 'Intake - Contracts Signed'
													when litify_pm__Status__c = 'File closed' then 'Closed Case'
													when litify_pm__Status__c = 'Pending' then 'Pending'
													when litify_pm__Status__c = 'Referred Out' then 'Case referred out of firm'
													when litify_pm__Status__c = 'Turned Down' then 'Turndown' end
WHERE st.cssnStatusID IS NULL
GO

