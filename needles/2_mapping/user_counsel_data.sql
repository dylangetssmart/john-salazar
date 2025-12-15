SELECT *
FROM [Needles]..NeedlesUserFields nuf
where nuf.table_name = 'user_counsel_data'
order by nuf.column_name
