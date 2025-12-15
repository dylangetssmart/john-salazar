/*---
description: Adds identity column ROW_ID to case_intake
steps:
	-
usage_instructions:
	-
dependencies:
	- 
notes:
	-
---*/

USE [Needles]
GO

ALTER TABLE case_intake
ADD ROW_ID INT IDENTITY(1,1)