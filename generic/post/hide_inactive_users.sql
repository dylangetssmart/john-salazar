use ShinerSA
go

update sma_mst_users 
set usrbIsShowInSystem =0
where isnull(usrbActiveState,0)<> 1

update sma_MST_IndvContacts
Set cinbStatus = 0
--select ind.*
From sma_MST_IndvContacts ind
join sma_mst_users u on ind.cinnContactID = u.usrnContactID
where isnull(usrbActiveState,0)<> 1