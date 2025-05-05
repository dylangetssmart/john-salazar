SELECT
	[role]
   ,COUNT(*) AS Count
FROM [JohnSalazar_Needles]..party_Indexed
WHERE ISNULL([role], '') <> ''
GROUP BY [role]