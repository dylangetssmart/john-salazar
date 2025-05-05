/*
This script manages the population of the `implementation_users` table for the [JohnSalazar_SA] project.
It consists of two main phases, controlled by the `@Phase` variable:

    - Phase 1: Initial Conversion
      - Seeds the `implementation_users` table from the `[JohnSalazar_Needles]..staff` table.
      - Used in the initial data conversion phase when only `staff` data is available.

    - Phase 2: Implementation Database Seeding
      - Drops and repopulates `implementation_users` based on the implementation database.
      - Joins `sma_mst_users` and `sma_MST_IndvContacts` from the implementation database.
      - Adds `staff_code` from `[JohnSalazar_Needles]..staff` if available.
      - Used in later project phases when the implementation database is the primary source.

Usage:
- Set the `@Phase` variable to `1` for Phase 1 or `2` for Phase 2, then run the script.

Requirements:
- Phase 1 assumes `staff` records exist in `[JohnSalazar_Needles]..staff`.
- Phase 2 assumes that both `sma_mst_users` and `sma_MST_IndvContacts` are populated in the implementation database.

*/

use [JohnSalazar_SA]
go

if OBJECT_ID('conversion.imp_user_map', 'U') is not null
begin
	drop table conversion.imp_user_map;
end;

create table conversion.imp_user_map (
	SAUserID	INT,
	SAContactID INT,
	StaffCode   VARCHAR(100),
	full_name   NVARCHAR(100),
	SALoginID   VARCHAR(100),
	Prefix		VARCHAR(25),
	SAFirst		VARCHAR(100),
	SAMiddle	VARCHAR(50),
	SALast		VARCHAR(100),
	Suffix		VARCHAR(100),
	active		BIT,
	Visible		BIT

);

--IF OBJECT_ID('implementation_users', 'U') IS NOT NULL
--BEGIN
--	DROP TABLE implementation_users;
--END;

---- Create the implementation_users table
--CREATE TABLE implementation_users (
--	SAContactID NVARCHAR(25)
--   ,SAUserID NVARCHAR(25)
--   ,StaffCode NVARCHAR(50)
--   ,full_name NVARCHAR(100)
--   ,SALoginID NVARCHAR(50)
--   ,Prefix NVARCHAR(10)
--   ,SAFirst NVARCHAR(50)
--   ,SAMiddle VARCHAR(5)
--   ,SALast NVARCHAR(50)
--   ,Suffix NVARCHAR(10)
--   ,Active BIT
--   ,Visible BIT
--);
--GO

---- Declare a variable to control the execution phase
--DECLARE @Phase INT = 2;  -- Set to 1 for Phase 1, 2 for Phase 2

--IF @Phase = 1
--BEGIN
--	-- Phase 1: Initial Conversion - Seed from [JohnSalazar_Needles]..staff

--	INSERT INTO implementation_users
--		(
--		SAContactID
--	   ,SAUserID
--	   ,StaffCode
--	   ,full_name
--	   ,SALoginID
--	   ,Prefix
--	   ,SAFirst
--	   ,SAMiddle
--	   ,SALast
--	   ,Suffix
--		)
--		SELECT
--			NULL						   AS SAContactID
--		   ,NULL						   AS SAUserID
--		   ,staff_code					   AS StaffCode
--		   ,s.full_name					   AS full_name
--		   ,staff_code					   AS SAloginID
--		   ,prefix						   AS Prefix
--		   ,dbo.get_firstword(s.full_name) AS SAFirst
--		   ,''							   AS SAMiddle
--		   ,dbo.get_lastword(s.full_name)  AS SALast
--		   ,suffix						   AS Suffix
--		FROM [JohnSalazar_Needles].[dbo].[staff] s;
--END
--ELSE
--IF @Phase = 2
--BEGIN
--	-- Phase 2: Use implementation database as starting point and add staff_code from [JohnSalazar_Needles]..staff
--	-- at this point, the user table contains legit users entered by the client
insert into conversion.imp_user_map
	(
		SAContactID,
		SAUserID,
		StaffCode,
		full_name,
		SALoginID,
		Prefix,
		SAFirst,
		SAMiddle,
		SALast,
		Suffix,
		active,
		Visible
	)
	select
		smic.cinnContactID	 as SAContactID,
		u.usrnUserID		 as SAUserID,
		--		COALESCE(s.staff_code, '') as StaffCode,
		s.staff_code		 as StaffCode,
		s.full_name			 as full_name,
		u.usrsLoginID		 as SALoginID,
		smic.cinsPrefix		 as Prefix,
		smic.cinsFirstName	 as SAFirst,
		smic.cinsMiddleName	 as SAMddle,
		smic.cinsLastName	 as SALast,
		smic.cinsSuffix		 as Suffix,
		u.usrbActiveState	 as Active,
		u.usrbIsShowInSystem as Visible
	--select * 
	from sma_mst_users u
	join sma_MST_IndvContacts smic
		on smic.cinnContactID = u.usrnContactID
	left join Needles..staff s
		on s.full_name = smic.cinsFirstName + ' ' + smic.cinsLastName

select
	*
from conversion.imp_user_map map
where
	map.StaffCode = ''

-- update conversion.imp_user_map
-- set StaffCode = 'RICK'
-- where SALoginID = 'rpopp'

-- update conversion.imp_user_map
-- set StaffCode = 'MARK'
-- where SALoginID = 'mskolrood'

--update conversion.imp_user_map
--set StaffCode = 'SUSIE'
--where SALoginID = 'susie'

--update conversion.imp_user_map
--set StaffCode = 'KYLE'
--where SALoginID = 'kweidman'

/*
file is cleaned in python first

>>> input = r"D:\Needles-JoelBieber\needles\mapping\imp_user_map.csv"
>>> output = r"D:\Needles-JoelBieber\needles\mapping\imp_user_map_cleaned.csv"
>>> with open(input,'r') as infile, open(output,'w') as outfile:
...     for line in infile:
...             cleaned_line = line.replace('NULL','')
...             outfile.write(cleaned_line)
*/

--if OBJECT_ID('conversion.imp_user_map', 'U') is not null
--begin
--	drop table conversion.imp_user_map;
--end;

--create table conversion.imp_user_map (
--	Name		VARCHAR(255),
--	Person		VARCHAR(100),
--	status		VARCHAR(100),
--	SAUserID	INT,
--	SAContactID INT,
--	StaffCode   VARCHAR(100),
--	SALoginID   VARCHAR(100),
--	Prefix		VARCHAR(25),
--	SAFirst		VARCHAR(100),
--	SAMiddle	VARCHAR(50),
--	SALast		VARCHAR(100),
--	Suffix		VARCHAR(100),
--	active		BIT,
--	Visible		BIT

--);

--bulk insert conversion.imp_user_map
--from 'D:\Needles-JoelBieber\needles\mapping\imp_user_map_cleaned.csv'
--with (
--fieldterminator = ',',
--rowterminator = '\n',
--firstrow = 2
--);
