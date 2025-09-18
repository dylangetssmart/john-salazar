select distinct
	cfu.[tablename],
	[caseid] as case_link,
	upm.party_role,
	cfu.[column_name],
	cfu.[field_title],
	cfu.[field_type],
	cfu.[field_len],
	[ValueCount] as count,
	CFSD.field_value as [Sample Data]
from CustomFieldUsage CFU
left join CustomFieldSampleData CFSD
	on CFU.column_name = CFSD.column_name
		and CFU.tablename = CFSD.tablename
join JohnSalazar_Needles..user_party_matter upm
on upm.ref_num = cfu.field_num and CFU.field_title = upm.field_title
where
	CFU.tablename = 'user_party_data'
order by upm.party_role, CFU.column_name--, CFU.field_num