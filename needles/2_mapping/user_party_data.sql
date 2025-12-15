select 
	nuf.*,
	upm.party_role
FROM [Needles]..NeedlesUserFields nuf
join [Needles]..user_party_matter upm
on upm.ref_num = nuf.field_num and nuf.field_title = upm.field_title
where nuf.table_name = 'user_party_data'
order by nuf.column_name
