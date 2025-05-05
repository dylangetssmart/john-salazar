SELECT * FROM sma_mst_offices smo
SELECT stc.office_id FROM sma_TRN_Cases stc

UPDATE sma_TRN_Cases
set office_id = 2
where office_id = 5