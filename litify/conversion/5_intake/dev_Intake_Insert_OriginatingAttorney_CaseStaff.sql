Select m.Originating_Attorney__c
FROM [sma_trn_cases] CAS
JOIN [LitifyLesser]..[litify_pm__intake__c] m on m.id = cas.Litify_saga
JOIN [sma_MST_Users] u on u.saga = m.OwnerId 

--INSERT ORIGINATING ATTORNEY FOR INTAKE CASES
--------------------------------------------------------
ALTER TABLE sma_TRN_caseStaff DISABLE TRIGGER ALL
GO

------------------------------
--CASE STAFF - ADD AS INTAKE
------------------------------
INSERT INTO sma_TRN_caseStaff 
(
       [cssnCaseID]
      ,[cssnStaffID]
      ,[cssnRoleID]
      ,[csssComments]
      ,[cssdFromDate]
      ,[cssdToDate]
      ,[cssnRecUserID]
      ,[cssdDtCreated]
      ,[cssnModifyUserID]
      ,[cssdDtModified]
      ,[cssnLevelNo]
)
SELECT DISTINCT
	CAS.casnCaseID			  as [cssnCaseID],
	u.usrnContactID 		  as [cssnStaffID],
	(SELECT sbrnSubRoleId FROM sma_MST_SubRole WHERE sbrnRoleID=10 and sbrsDscrptn = 'Originating Attorney' )	 as [cssnRoleID],
	null					  as [csssComments],
	null					  as cssdFromDate,
	null					  as cssdToDate,
	368						  as cssnRecUserID,
	getdate()				  as [cssdDtCreated],
	null					  as [cssnModifyUserID],
	null					  as [cssdDtModified],
	0						  as cssnLevelNo
--Select *
FROM [sma_trn_cases] CAS
JOIN [LitifyLesser]..[litify_pm__intake__c] m on m.id = cas.Litify_saga
JOIN [sma_MST_Users] u on u.saga = m.Originating_Attorney__c 
GO

ALTER TABLE sma_TRN_caseStaff ENABLE TRIGGER ALL
GO
