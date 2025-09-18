/*---
group: load
order: 5
description: Update contact types for attorneys
---*/

use [JohnSalazar_SA]
go

/* --------------------------------------------------------------------------------------------------------------
Insert [sma_Mst_ContactRace] from [race]
*/

insert into sma_MST_ContactRace
	(
		RaceDesc
	)
	select distinct
		race_name
	from [JohnSalazar_Needles]..race
	except
	select
		RaceDesc
	from sma_Mst_ContactRace
go

/* --------------------------------------------------------------------------------------------------------------
Insert Individual Contacts from [names]
*/

alter table [sma_MST_IndvContacts] disable trigger all
go

insert into [sma_MST_IndvContacts]
	(
		[cinsPrefix],
		[cinsSuffix],
		[cinsFirstName],
		[cinsMiddleName],
		[cinsLastName],
		[cinsHomePhone],
		[cinsWorkPhone],
		[cinsSSNNo],
		[cindBirthDate],
		[cindDateOfDeath],
		[cinnGender],
		[cinsMobile],
		[cinsComments],
		[cinnContactCtg],
		[cinnContactTypeID],
		[cinnContactSubCtgID],
		[cinnRecUserID],
		[cindDtCreated],
		[cinbStatus],
		[cinbPreventMailing],
		[cinsNickName],
		[cinsPrimaryLanguage],
		[cinsOtherLanguage],
		[cinnRace],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		LEFT(n.[prefix], 20)					 as [cinsprefix],
		LEFT(n.[suffix], 10)					 as [cinssuffix],
		CONVERT(VARCHAR(30), n.[first_name])	 as [cinsfirstname],
		CONVERT(VARCHAR(30), n.[initial])		 as [cinsmiddlename],
		CONVERT(VARCHAR(40), n.[last_long_name]) as [cinslastname],
		LEFT(n.[home_phone], 20)				 as [cinshomephone],
		LEFT(n.[work_phone], 20)				 as [cinsworkphone],
		LEFT(n.[ss_number], 20)					 as [cinsssnno],
		case
			when (n.[date_of_birth] not between '1900-01-01' and '2079-12-31')
				then GETDATE()
			else n.[date_of_birth]
		end										 as [cindbirthdate],
		case
			when (n.[date_of_death] not between '1900-01-01' and '2079-12-31')
				then GETDATE()
			else n.[date_of_death]
		end										 as [cinddateofdeath],
		case
			when n.[sex] = 'M'
				then 1
			when n.[sex] = 'F'
				then 2
			else 0
		end										 as [cinngender],
		LEFT(n.[car_phone], 20)					 as [cinsmobile],
		case
			when ISNULL(n.[fax_number], '') <> ''
				then 'FAX NUMBER: ' + n.[fax_number]
			else null
		end										 as [cinscomments],
		1										 as [cinncontactctg],
		(
			select
				octnOrigContactTypeID
			from [sma_MST_OriginalContactTypes]
			where octsDscrptn = 'General'
				and octnContactCtgID = 1
		)										 as [cinncontacttypeid],
		case
			-- if names.deceased = "Y", then grab the contactSubCategoryID for "Deceased"
			when n.[deceased] = 'Y'
				then (
						select
							cscnContactSubCtgID
						from [sma_MST_ContactSubCategory]
						where cscsDscrptn = 'Deceased'
					)
			-- if incapacitated = "Y" on the [party_Indexed] table, then grab the contactSubCategoryID for "Incompetent"
			when exists (
					select
						*
					from [JohnSalazar_Needles].[dbo].[party_Indexed] p
					where p.party_id = n.names_id
						and p.incapacitated = 'Y'
				)
				then (
						select
							cscnContactSubCtgID
						from [sma_MST_ContactSubCategory]
						where cscsDscrptn = 'Incompetent'
					)
			-- if minor = "Y" on the [party_Indexed] table, then grab the contactSubCategoryID for "Infant"
			-- otherwise, grab the contactSubCategoryID for "Adult"
			when exists (
					select
						*
					from [JohnSalazar_Needles].[dbo].[party_Indexed] p
					where p.party_id = n.names_id
						and p.minor = 'Y'
				)
				then (
						select
							cscnContactSubCtgID
						from [sma_MST_ContactSubCategory]
						where cscsDscrptn = 'Infant'
					)
			else (
					select
						cscnContactSubCtgID
					from [sma_MST_ContactSubCategory]
					where cscsDscrptn = 'Adult'
				)
		end										 as cinncontactsubctgid,
		368										 as cinnrecuserid,
		GETDATE()								 as cinddtcreated,
		1										 as [cinbstatus],
		0										 as [cinbpreventmailing],
		CONVERT(VARCHAR(15), aka_full)			 as [cinsnickname],
		null									 as [cinsprimarylanguage],
		null									 as [cinsotherlanguage],
		case
			when ISNULL(n.race, '') <> ''
				then (
						select
							RaceID
						from sma_mst_ContactRace
						where RaceDesc = r.race_name
					)
			else null
		end										 as cinnrace,
		n.[names_id]							 as saga,
		null									 as source_id,
		'needles'								 as source_db,
		'names'									 as source_ref
	from [JohnSalazar_Needles].[dbo].[names] n
	left join [JohnSalazar_Needles].[dbo].[Race] r
		on r.race_id = case
				when ISNUMERIC(n.race) = 1
					then CONVERT(INT, n.race)
				else null
			end
	where
		n.[person] = 'Y'
go

alter table [sma_MST_IndvContacts] enable trigger all
go