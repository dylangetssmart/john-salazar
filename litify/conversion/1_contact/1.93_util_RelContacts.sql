use ShinerSA
go

--SELECT * FROM sma_MST_RelContacts smrc
--INSERT INDV/ORG RELATED CONTACTS FROM ACCOUNT TABLE
insert into sma_MST_RelContacts
	(
	rlcnPrimaryCtgID,
	rlcnPrimaryContactID,
	rlcnPrimaryAddressID,
	rlcnRelCtgID,
	rlcnRelContactID,
	rlcnRelAddressID,
	rlcnRelTypeID,
	rlcnRecUserID,
	rlcdDtCreated,
	rlcsBizFam
	)
	select
		ioc.ctg	   as rlcnprimaryctgid,
		ioc.cid	   as rlcnprimarycontactid,
		ioc.aid	   as rlcnprimaryaddressid,
		ioco.ctg   as rlcnrelctgid,
		ioco.cid   as rlcnrelcontactid,
		ioco.aid   as rlcnreladdressid,
		2		   as rlcnreltypeid,
		368		   as rlcnrecuserid,
		GETDATE()  as rlcddtcreated,
		'Business' as rlcsbizfam
	--SELECT *
	from ShinerLitify..Account a
	join indvOrgContacts_indexed ioc
		on ioc.saga_char = a.id
	join indvOrgContacts_indexed ioco
		on ioco.saga_char = a.ParentId
