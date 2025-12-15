SELECT *
FROM [Needles]..NeedlesUserFields nuf
where nuf.table_name = 'user_case_data'
order by nuf.column_name