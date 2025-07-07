use [JohnSalazar_SA]
go


alter table sma_MST_IndvContacts disable trigger all
go

/* ------------------------------------------------------------------------------
Push Provider Info to Contact Comments
*/ ------------------------------------------------------------------------------
update sma_MST_OrgContacts
set consComments = a.Provider_Info
from (
	select
		upd.provider_id,
		upd.Provider_Info
	from [JohnSalazar_Needles].[dbo].user_provider_data upd
	join [JohnSalazar_Needles].[dbo].[names] n
		on n.names_id = upd.provider_id
	where ISNULL(upd.Provider_Info,'') <> ''
) a
where a.provider_id = saga

---
alter table sma_MST_IndvContacts enable trigger all
go
---
