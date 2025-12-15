use [JohnSalazar_SA]
go

declare @FileId INT;
declare @addnContactID INT;
declare @addnAddressID INT;
declare @addnContactCtgID INT;
declare @UTCCreationDateTime DATETIME;
declare @label VARCHAR(100);

declare OtherContact_cursor cursor for select distinct
	CAS.casnCaseID,
	IOC.CID,
	IOC.AID,
	'',
	IOC.CTG,
	case
		when P.[role] = 'See Relationship' then P.[relationship]
		when P.[role] = 'Witness' then 'Witness ' + ISNULL(': ' + NULLIF(P.relationship, ''), '')
		else null
	end
from [JohnSalazar_Needles].[dbo].[party_Indexed] P
join [sma_TRN_Cases] CAS
	on CAS.cassCaseNumber = P.case_id
join IndvOrgContacts_Indexed IOC
	on IOC.SAGA = P.party_id
where P.role in
	(
	'See Relationship',
	'Witness'
	)



open OtherContact_cursor

fetch next from OtherContact_cursor
into @FileId, @addnContactID, @addnAddressID, @UTCCreationDateTime, @addnContactCtgID, @label

while @@FETCH_STATUS = 0
begin

declare @p1 VARCHAR(80);

exec [dbo].[sma_SP_Insert_OtherCaseRelatedContacts] @CaseID				   = @FileId,
													@ContactID			   = @addnContactID,
													@ContactCtgID		   = @addnContactCtgID,
													@ContactAddressID	   = @addnAddressID,
													@ContactRoleID		   = @label,
													@ContactCreatedUserID  = 368,
													@ContactComment		   = null,
													@identity_column_value = @p1

print @p1

fetch next from OtherContact_cursor
into @FileId, @addnContactID, @addnAddressID, @UTCCreationDateTime, @addnContactCtgID, @label

end

close OtherContact_cursor;
deallocate OtherContact_cursor;

go

