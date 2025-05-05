use ShinerSA
go

alter table sma_MST_OrgContacts disable trigger all
go

-------------------------------------------
--CREATE REFERRAL SOURCE RECORDS
-------------------------------------------
insert into [sma_MST_OrgContacts]
	(
	[consName], [connContactCtg], [connContactTypeID], [connRecUserID], [condDtCreated], [consComments], [saga_char], [source_db], [source_ref]
	)
	select distinct
		s.[Name]										 as [consname],
		2												 as [conncontactctg],
		case
			when litify_tso_Source_Type_Name__c in ('Advertisement', 'Internet')
				then (
						select
							octnOrigContactTypeID
						from [sma_MST_OriginalContactTypes]
						where octnContactCtgID = 2
							and octsDscrptn = 'Advertise'
					)
			when litify_tso_Source_Type_Name__c = 'Attorney Referral'
				then (
						select
							octnOrigContactTypeID
						from [sma_MST_OriginalContactTypes]
						where octnContactCtgID = 2
							and octsDscrptn = 'Law Firm'
					)
			else (
					select
						octnOrigContactTypeID
					from [sma_MST_OriginalContactTypes]
					where octnContactCtgID = 2
						and octsDscrptn = 'General Unspecified'
				)
		end												 
		as [conncontacttypeid],
		368												 as [connrecuserid],
		GETDATE()										 as [conddtcreated],
		'Source Type: ' + litify_tso_Source_Type_Name__c as [conscomments],
		s.Id											 as [saga_char],
		'litify'										 as [source_db],
		'litify_pm__Source__c'							 as [source_ref]
	--select s.*
	from ShinerLitify..[litify_pm__Source__c] s

alter table sma_MST_OrgContacts enable trigger all
go