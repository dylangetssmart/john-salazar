select
	cfu.[tablename],
	cfu.[column_name],
	[field_title],
	[field_type],
	[field_len],
	[caseid] as case_link,
	[ValueCount] as count,
	CFSD.field_value as [Sample Data]
from CustomFieldUsage CFU
left join CustomFieldSampleData CFSD
	on CFU.column_name = CFSD.column_name
		and CFU.tablename = CFSD.tablename
where
	CFU.tablename = 'user_case_data'
order by CFU.tablename, CFU.field_num