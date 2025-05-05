select * 
from sma_trn_Cases
where casscasenumber like 'int%'


select cas.casncaseid, cas.casscasenumber, litify_pm__Status__c, stat.csssDescription,cs.*
FROM [sma_trn_cases] CAS
JOIN LitifyLesser..[litify_pm__intake__c] m on m.Id = CAS.Litify_saga
JOIN sma_TRN_CaseStatus cs on cs.cssnCaseID = cas.casnCaseID and cs.cssnStatusTypeID =1 and cssdtodt is null
left JOIN sma_MST_CaseStatus stat on stat.cssnStatusID = cs.cssnStatusID 
where litify_pm__Status__c='Referred out'
and cs.cssnStatusID <> 1998 
and cssscomments= 'bulk change'


insert into sma_trn_Casestatus ([cssnCaseID],
	 [cssnStatusTypeID],
	 [cssnStatusID],
	 [cssnExpDays],
	 [cssdFromDate],
	 [cssdToDt],
	 [csssComments],
	 [cssnRecUserID],
	 [cssdDtCreated],
	 [cssnModifyUserID],
	 [cssdDtModified],
	 [cssnLevelNo],
	 [cssnDelFlag]
)

SELECT DISTINCT
    CAS.casnCaseID		as [cssnCaseID],
    (SELECT stpnStatusTypeID FROM sma_MST_CaseStatusType WHERE stpsStatusType='Status') as [cssnStatusTypeID],
    1998				as [cssnStatusID],
    ''					as [cssnExpDays],
    getdate()			 as [cssdFromDate],
    null				as [cssdToDt],
	''					as [csssComments],
    368					as [cssnRecUserID],
    GETDATE()			as [cssdDtCreated],
    null,null,null,null 
FROM [sma_trn_cases] CAS
JOIN LitifyLesser..[litify_pm__intake__c] m on m.Id = CAS.Litify_saga
JOIN sma_TRN_CaseStatus cs on cs.cssnCaseID = cas.casnCaseID and cs.cssnStatusTypeID =1 and cssdtodt is null
left JOIN sma_MST_CaseStatus stat on stat.cssnStatusID = cs.cssnStatusID 
where litify_pm__Status__c='Referred out'
and cs.cssnStatusID <> 1998 
and cssscomments= 'bulk change'


select Referral_Source__c, Referred_To__c, s.*--, ioc.*
FROM [sma_trn_cases] CAS
JOIN LitifyLesser..[litify_pm__intake__c] m on m.Id = CAS.Litify_saga
join LitifyLesser..[litify_pm__Source__c] s on m.litify_pm__Source__c= s.Id
--JOIN IndvOrgContacts_Indexed ioc on ioc.saga = m.Referred_To__c
where casncaseid = 6690

select * From sma_TRN_ReferredOut


--INSERT REFERRED OUt ATTY
INSERT INTO sma_TRN_ReferredOut (rfostype, rfonCaseID, rfonPlaintiffID, rfonLawFrmContactID, rfonLawFrmAddressID, rfonAttContactID, rfonAttAddressID, rfonUserID, rfodDtCreated, rfonReferred)
SELECT 'G',
		casncaseid,
		-1,
		ioc.cid,
		ioc.aid,
		ioci.cid,
		ioci.aid,
		368, getdate(), 1, Referred_To__c
FROM [sma_trn_cases] CAS
JOIN LitifyLesser..[litify_pm__intake__c] m on m.Id = CAS.Litify_saga
LEFT JOIN IndvOrgContacts_Indexed ioc on ioc.saga = m.Referred_To__c and ioc.ctg=2
LEFT JOIN IndvOrgContacts_Indexed ioci on ioci.saga = m.Referred_To__c and ioci.ctg=1
WHERE isnull(Referred_To__c,'') <> ''


select * from litifylesser..contact  where id = '0055Y00000HDdu8QAD'

delete from sma_TRN_ReferredOut where rfonLawFrmContactID is null AND rfonAttContactID IS NULL



select m.id, cas.casscasenumber, m.litify_pm__referred_out_Date__c, Referral_Source__c,litify_pm__Status__c, ioc.*
FROM [sma_trn_cases] CAS
JOIN LitifyLesser..[litify_pm__intake__c] m on m.Id = CAS.Litify_saga
LEFT JOIN IndvOrgContacts_Indexed  ioc on ioc.saga = Referral_Source__c
where isnull(Referral_Source__c,'') <> ''
and litify_pm__Status__c='Referred out'

select * from litifylesser..litify_pm__Firm__c
where id = '0054z00000BYjVpAAL'

select * from litifylesser..Contact
where lastname = 'acosta-castriz'
--accountid '0015Y00003DkaRQQAZ'
--id  '0035Y00004KcvYPQAZ'

select * from litifylesser..Account
where id = '0054z00000BYjVpAAL'

select * from sma_mst_users


select q.litify_pm__Question_Label__c, a.litify_pm__Answer__c
From LitifyLesser..litify_pm__Question_Answer__c a
join litifylesser..litify_pm__Question__c q on q.id = a.litify_pm__Question__c
where q.litify_pm__Question_Label__c like '%refer%to%'

select* from LitifyLesser..litify_Pm__Role__c where litify_pm__role__c like '%refer%out%'