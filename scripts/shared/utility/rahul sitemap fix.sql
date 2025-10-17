
declare @caseGroupID int

DECLARE siteMap_cursor CURSOR FOR 

select smcg.cgpnCaseGroupID from sma_MST_CaseGroup smcg where smcg.cgpnCaseGroupID not in ( 
SELECT distinct csmnCaseGroupId
FROM sma_mst_sitemaps
where csmncaseGroupid<>-1
)

OPEN siteMap_cursor 
FETCH NEXT FROM siteMap_cursor INTO @caseGroupID
WHILE @@FETCH_STATUS = 0
BEGIN

		DELETE sma_mst_sitemaps
		WHERE csmnCaseGroupID in (@caseGroupID)

		INSERT INTO sma_MST_SiteMaps
		(
			csmnParentId,
			csmsurl,
			csmsTitle,
			csmncasegroupid,
			csmbVisible,
			csmnnodelevel,
			csmnnodeid,
			csmsuniquetitle
		)
		SELECT csmnParentId,
				csmsurl,
				csmsTitle,
				@caseGroupID,  --csmncasegroupid,
				csmbVisible,
				csmnnodelevel,
				csmnnodeid,
				csmsuniquetitle
		From sma_mst_sitemaps
		where csmnCaseGroupId = -1


FETCH NEXT FROM siteMap_cursor INTO @caseGroupID
END 
CLOSE siteMap_cursor;
DEALLOCATE siteMap_cursor;