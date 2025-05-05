use ShinerSA
go


if exists (
		select
			*
		from sys.views
		where Name = 'vw_litifyRoleMapID'
	)
begin
	drop view vw_litifyRoleMapID
end
go

create view vw_litifyRoleMapID
as
select
	r.Id,
	r.CreatedDate,
	r.CreatedById,
	r.LastModifiedDate,
	r.LastModifiedById,
	r.litify_pm__Matter__c,
	r.litify_pm__Role__c,
	r.litify_pm__Comments__c,
	r.litify_pm__Subtype__c,
	ioc.*
from ShinerLitify..litify_pm__Role__c r
join IndvOrgContacts_Indexed ioc
	on r.litify_pm__Party__c = ioc.saga_char
go
