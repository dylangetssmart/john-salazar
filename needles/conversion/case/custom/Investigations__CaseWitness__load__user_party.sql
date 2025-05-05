use [SA]
go

alter table [sma_TRN_CaseWitness] disable trigger all
go

SELECT * FROM SMA_MST_WitnessType smwt

/* --------------------------------------------------------------------------------------------------------------
Witness 1
*/
insert into [sma_TRN_CaseWitness]
	(
		[witnCaseID],
		[witnWitnesContactID],
		[witnWitnesAdID],
		[witnRoleID],
		[witnFavorable],
		[witnTestify],
		[witdStmtReqDate],
		[witdStmtDate],
		[witbHasRec],
		[witsDoc],
		[witsComment],
		[witnRecUserID],
		[witdDtCreated],
		[witnModifyUserID],
		[witdDtModified],
		[witnLevelNo]
	)
	select distinct
		c.casnCaseID as [witnCaseID],
		ioc.CID		 as [witnWitnesContactID],
		ioc.AID		 as [witnWitnesAdID],
		null		 as [witnRoleID],
		null		 as [witnFavorable],
		null		 as [witnTestify],
		null		 as [witdStmtReqDate],
		null		 as [witdStmtDate],
		null		 as [witbHasRec],
		null		 as [witsDoc],
		null		 as [witsComment],
		368			 as [witnRecUserID],
		GETDATE()	 as [witdDtCreated],
		null		 as [witnModifyUserID],
		null		 as [witdDtModified],
		null		 as [witnLevelNo]
	--select *
	from Needles..user_party_data upd
	join sma_TRN_Cases c
		on c.cassCaseNumber = CONVERT(VARCHAR, upd.case_id)
	join IndvOrgContacts_Indexed ioc
		on ioc.source_id = upd.Witness_1
			and ioc.source_ref = 'user_party_data.witness_1'
	where
		ISNULL(upd.Witness_1, '') <> ''
--OR ISNULL(upd.Witness_2, '') <> ''
--OR ISNULL(upd.Witness_3, '') <> ''
go


/* --------------------------------------------------------------------------------------------------------------
Witness 2
*/
insert into [sma_TRN_CaseWitness]
	(
		[witnCaseID],
		[witnWitnesContactID],
		[witnWitnesAdID],
		[witnRoleID],
		[witnFavorable],
		[witnTestify],
		[witdStmtReqDate],
		[witdStmtDate],
		[witbHasRec],
		[witsDoc],
		[witsComment],
		[witnRecUserID],
		[witdDtCreated],
		[witnModifyUserID],
		[witdDtModified],
		[witnLevelNo]
	)
	select distinct
		c.casnCaseID as [witnCaseID],
		ioc.CID		 as [witnWitnesContactID],
		ioc.AID		 as [witnWitnesAdID],
		null		 as [witnRoleID],
		null		 as [witnFavorable],
		null		 as [witnTestify],
		null		 as [witdStmtReqDate],
		null		 as [witdStmtDate],
		null		 as [witbHasRec],
		null		 as [witsDoc],
		null		 as [witsComment],
		368			 as [witnRecUserID],
		GETDATE()	 as [witdDtCreated],
		null		 as [witnModifyUserID],
		null		 as [witdDtModified],
		null		 as [witnLevelNo]
	--select *
	from Needles..user_party_data upd
	join sma_TRN_Cases c
		on c.cassCaseNumber = CONVERT(VARCHAR, upd.case_id)
	join IndvOrgContacts_Indexed ioc
		on ioc.source_id = upd.Witness_2
			and ioc.source_ref = 'user_party_data.witness_2'
	where
		ISNULL(upd.Witness_2, '') <> ''
go


/* --------------------------------------------------------------------------------------------------------------
Witness 3
*/
insert into [sma_TRN_CaseWitness]
	(
		[witnCaseID],
		[witnWitnesContactID],
		[witnWitnesAdID],
		[witnRoleID],
		[witnFavorable],
		[witnTestify],
		[witdStmtReqDate],
		[witdStmtDate],
		[witbHasRec],
		[witsDoc],
		[witsComment],
		[witnRecUserID],
		[witdDtCreated],
		[witnModifyUserID],
		[witdDtModified],
		[witnLevelNo]
	)
	select distinct
		c.casnCaseID as [witnCaseID],
		ioc.CID		 as [witnWitnesContactID],
		ioc.AID		 as [witnWitnesAdID],
		null		 as [witnRoleID],
		null		 as [witnFavorable],
		null		 as [witnTestify],
		null		 as [witdStmtReqDate],
		null		 as [witdStmtDate],
		null		 as [witbHasRec],
		null		 as [witsDoc],
		null		 as [witsComment],
		368			 as [witnRecUserID],
		GETDATE()	 as [witdDtCreated],
		null		 as [witnModifyUserID],
		null		 as [witdDtModified],
		null		 as [witnLevelNo]
	--select *
	from Needles..user_party_data upd
	join sma_TRN_Cases c
		on c.cassCaseNumber = CONVERT(VARCHAR, upd.case_id)
	join IndvOrgContacts_Indexed ioc
		on ioc.source_id = upd.Witness_3
			and ioc.source_ref = 'user_party_data.witness_3'
	where
		ISNULL(upd.Witness_3, '') <> ''
go

alter table [sma_TRN_CaseWitness] enable trigger all
go
