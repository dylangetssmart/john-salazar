/*---
description: creates conversion schema if it does not exist
steps:
	-
usage_instructions:
	-
dependencies:
	- 
notes:
	-
---*/

use [JohnSalazar_SA]
go

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'conversion')
EXEC sys.sp_executesql N'CREATE SCHEMA [conversion]'
GO