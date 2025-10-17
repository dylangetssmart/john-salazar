/*---
description: Creates a stored procedure to add breadcrumb columns to a specified table.

steps: >
  -

dependencies:
  -
---*/

-- ex) EXEC AddBreadcrumbsToTable 'sma_MST_IndvContacts';

use [SA]
go

CREATE PROCEDURE AddBreadcrumbsToTable
    @tableName NVARCHAR(128)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);

    -- Add the 'saga' column
    IF NOT EXISTS (
        SELECT * FROM sys.columns
        WHERE Name = N'saga' AND object_id = OBJECT_ID(@tableName)
    )
    BEGIN
        SET @sql = 'ALTER TABLE ' + QUOTENAME(@tableName) + ' ADD [saga] INT NULL;';
        EXEC sp_executesql @sql;
    END

    -- Add the 'source_id' column
    IF NOT EXISTS (
        SELECT * FROM sys.columns
        WHERE Name = N'source_id' AND object_id = OBJECT_ID(@tableName)
    )
    BEGIN
        SET @sql = 'ALTER TABLE ' + QUOTENAME(@tableName) + ' ADD [source_id] VARCHAR(50) NULL;';
        EXEC sp_executesql @sql;
    END

    -- Add the 'source_db' column
    IF NOT EXISTS (
        SELECT * FROM sys.columns
        WHERE Name = N'source_db' AND object_id = OBJECT_ID(@tableName)
    )
    BEGIN
        SET @sql = 'ALTER TABLE ' + QUOTENAME(@tableName) + ' ADD [source_db] VARCHAR(50) NULL;';
        EXEC sp_executesql @sql;
    END

    -- Add the 'source_ref' column
    IF NOT EXISTS (
        SELECT * FROM sys.columns
        WHERE Name = N'source_ref' AND object_id = OBJECT_ID(@tableName)
    )
    BEGIN
        SET @sql = 'ALTER TABLE ' + QUOTENAME(@tableName) + ' ADD [source_ref] VARCHAR(50) NULL;';
        EXEC sp_executesql @sql;
    END
END
GO