SELECT 'staff_1' AS Label,
       (SELECT TOP 1 WITH TIES staff_1 FROM [JohnSalazar_Needles]..cases WHERE staff_1 <> '' GROUP BY staff_1 ORDER BY COUNT(*) DESC) AS [User]
UNION ALL
SELECT 'staff_2',
       (SELECT TOP 1 WITH TIES staff_2 FROM [JohnSalazar_Needles]..cases WHERE staff_2 <> '' GROUP BY staff_2 ORDER BY COUNT(*) DESC)
UNION ALL
SELECT 'staff_3',
       (SELECT TOP 1 WITH TIES staff_3 FROM [JohnSalazar_Needles]..cases WHERE staff_3 <> '' GROUP BY staff_3 ORDER BY COUNT(*) DESC)
UNION ALL
SELECT 'staff_4',
       (SELECT TOP 1 WITH TIES staff_4 FROM [JohnSalazar_Needles]..cases WHERE staff_4 <> '' GROUP BY staff_4 ORDER BY COUNT(*) DESC)
UNION ALL
SELECT 'staff_5',
       (SELECT TOP 1 WITH TIES staff_5 FROM [JohnSalazar_Needles]..cases WHERE staff_5 <> '' GROUP BY staff_5 ORDER BY COUNT(*) DESC)
UNION ALL
SELECT 'staff_6',
       (SELECT TOP 1 WITH TIES staff_6 FROM [JohnSalazar_Needles]..cases WHERE staff_6 <> '' GROUP BY staff_6 ORDER BY COUNT(*) DESC)
UNION ALL
SELECT 'staff_7',
       (SELECT TOP 1 WITH TIES staff_7 FROM [JohnSalazar_Needles]..cases WHERE staff_7 <> '' GROUP BY staff_7 ORDER BY COUNT(*) DESC)
UNION ALL
SELECT 'staff_8',
       (SELECT TOP 1 WITH TIES staff_8 FROM [JohnSalazar_Needles]..cases WHERE staff_8 <> '' GROUP BY staff_8 ORDER BY COUNT(*) DESC)
UNION ALL
SELECT 'staff_9',
       (SELECT TOP 1 WITH TIES staff_9 FROM [JohnSalazar_Needles]..cases WHERE staff_9 <> '' GROUP BY staff_9 ORDER BY COUNT(*) DESC)
UNION ALL
SELECT 'staff_10',
       (SELECT TOP 1 WITH TIES staff_10 FROM [JohnSalazar_Needles]..cases WHERE staff_10 <> '' GROUP BY staff_10 ORDER BY COUNT(*) DESC);