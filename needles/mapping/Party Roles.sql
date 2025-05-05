SELECT
	[role]
   ,COUNT(*) AS Count
FROM [Needles]..party_Indexed
WHERE ISNULL([role], '') <> ''
GROUP BY [role]