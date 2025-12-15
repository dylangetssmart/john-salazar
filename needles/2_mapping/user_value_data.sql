SELECT *
FROM [Needles]..NeedlesUserFields nuf
where nuf.table_name = 'user_value_data'
order by nuf.column_name
