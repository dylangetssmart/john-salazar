select
	[field_num],
	[field_num_location],
	[field_title],
	[field_type],
	[field_len],
	[mini_dir_id],
	[mini_dir_title],
	cfu.[column_name],
	[mini_dir_id_location],
	cfu.[tablename],
	[caseid],
	[ValueCount],
	CFSD.field_value as [Sample Data]
from CustomFieldUsage CFU
left join CustomFieldSampleData CFSD
	on CFU.column_name = CFSD.column_name
		and CFU.tablename = CFSD.tablename
where
	CFU.tablename = 'user_tab_data'
order by CFU.tablename, CFU.field_num