use [JohnSalazar_SA]
go


---(1)---
delete from sma_MST_CaseTypeDefualtDefs

---(2)---
insert into sma_MST_CaseTypeDefualtDefs
	select distinct
		CST.cstnCaseTypeID as cddnCaseTypeID,
		I.cinnContactID	   as cddnDefContatID,
		I.cinnContactCtg   as cddnDefContactCtgID,
		sbrnSubRoleId	   as cddnRoleID,
		A.addnAddressID	   as cddnDefAddressID
	from sma_mst_casetype CST
	join sma_mst_SubRole S
		on sbrnCaseTypeID = CST.cstnCaseTypeID
	join sma_mst_SubRoleCode STC
		on S.sbrnTypeCode = STC.srcnCodeId
			and STC.srcsDscrptn = '(D)-Defendant'
	cross join sma_MST_IndvContacts I
	join sma_MST_Address A
		on A.addnContactID = I.cinnContactID
			and A.addnContactCtgID = I.cinnContactCtg
			and A.addbPrimary = 1
	where
		CST.VenderCaseType = (
			select
				VenderCaseType
			from conversion.office
		)
		and I.cinsFirstName = 'Individual'
		and I.cinsLastName = 'Unidentified'