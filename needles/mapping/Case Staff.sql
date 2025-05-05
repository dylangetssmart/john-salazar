SELECT
    (SELECT TOP 1 WITH TIES staff_1 FROM [Needles]..cases WHERE staff_1 <> '' GROUP BY staff_1 ORDER BY COUNT(*) DESC) AS staff_1,
    (SELECT TOP 1 WITH TIES staff_2 FROM [Needles]..cases WHERE staff_2 <> '' GROUP BY staff_2 ORDER BY COUNT(*) DESC) AS staff_2,
    (SELECT TOP 1 WITH TIES staff_3 FROM [Needles]..cases WHERE staff_3 <> '' GROUP BY staff_3 ORDER BY COUNT(*) DESC) AS staff_3,
    (SELECT TOP 1 WITH TIES staff_4 FROM [Needles]..cases WHERE staff_4 <> '' GROUP BY staff_4 ORDER BY COUNT(*) DESC) AS staff_4,
    (SELECT TOP 1 WITH TIES staff_5 FROM [Needles]..cases WHERE staff_5 <> '' GROUP BY staff_5 ORDER BY COUNT(*) DESC) AS staff_5,
    (SELECT TOP 1 WITH TIES staff_6 FROM [Needles]..cases WHERE staff_6 <> '' GROUP BY staff_6 ORDER BY COUNT(*) DESC) AS staff_6,
    (SELECT TOP 1 WITH TIES staff_7 FROM [Needles]..cases WHERE staff_7 <> '' GROUP BY staff_7 ORDER BY COUNT(*) DESC) AS staff_7,
    (SELECT TOP 1 WITH TIES staff_8 FROM [Needles]..cases WHERE staff_8 <> '' GROUP BY staff_8 ORDER BY COUNT(*) DESC) AS staff_8,
    (SELECT TOP 1 WITH TIES staff_9 FROM [Needles]..cases WHERE staff_9 <> '' GROUP BY staff_9 ORDER BY COUNT(*) DESC) AS staff_9,
    (SELECT TOP 1 WITH TIES staff_10 FROM [Needles]..cases WHERE staff_10 <> '' GROUP BY staff_10 ORDER BY COUNT(*) DESC) AS staff_10;