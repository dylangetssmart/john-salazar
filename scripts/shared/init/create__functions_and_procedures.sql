/**************************************************
 * Functions:
 *	dbo.myvarchar
 *	dbo.get_firstword
 *	dbo.get_lastword
 *	dbo.GetContactCtg
 *	dbo.MoneyToDecimal
 *	dbo.my_smalldatetime
 *	dbo.Integer2Date
 *	dbo.fn_ConvertToDateTime
 *	dbo.LeftWord
 *	dbo.FirstName_FromText
 *	dbo.MiddleName_FromText
 *	dbo.LastName_FromText
 *	dbo.Dworkin_FirstName_FromText
 *	dbo.Dworkin_LastName_FromText
 *  dbo.ValidDate
 **************************************************/

use [JohnSalazar_SA]
go

-----
--ALTER TABLE [sma_MST_OrgContacts] ALTER COLUMN [saga] VARCHAR(100)
--GO
--ALTER TABLE [sma_MST_IndvContacts] ALTER COLUMN [cinsGrade] VARCHAR(60)
--GO

-----

if OBJECT_ID(N'dbo.FormatPhone', N'FN') is not null
	drop function FormatPhone;

go

create function dbo.FormatPhone (@phone VARCHAR(MAX))
returns VARCHAR(MAX)
as
begin

	if LEN(@phone) = 10
		and ISNUMERIC(@phone) = 1
	begin
		return '(' + SUBSTRING(@phone, 1, 3) + ') ' + SUBSTRING(@phone, 4, 3) + '-' + SUBSTRING(@phone, 7, 4) ---> this is good for perecman
	end

	return @phone;
end;
go

if OBJECT_ID(N'dbo.myvarchar', N'FN') is not null
	drop function myvarchar;

go

create function dbo.myvarchar (@DateParameter VARCHAR(100))
returns VARCHAR(100)
as

begin
	declare @ret VARCHAR(100);
	select
		@ret = @DateParameter;
	return @ret;
end;
go


if OBJECT_ID(N'dbo.get_firstword', N'FN') is not null
	drop function get_firstword;

go

create function dbo.get_firstword (@WordParameter VARCHAR(100))
returns VARCHAR(100)
as

begin
	declare @ret VARCHAR(100);
	select
		@ret = (
			select top 1
				data
			from dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @WordParameter))), ' ')
			order by ID asc
		);
	return @ret;
end;
go

if OBJECT_ID(N'dbo.get_lastword', N'FN') is not null
	drop function get_lastword;

go

create function dbo.get_lastword (@WordParameter VARCHAR(100))
returns VARCHAR(100)
as

begin
	declare @ret VARCHAR(100);
	select
		@ret = (
			select top 1
				Data
			from dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @WordParameter))), ' ')
			order by ID desc
		);
	return @ret;
end;
go


/*
Single word - Organization
Two words - individual FirstName LastName
Three words with the second one as single letter with the period - FirstName M. LastName
Everything else - Organization
*/
if OBJECT_ID(N'dbo.GetContactCtg', N'FN') is not null
	drop function GetContactCtg;

go

create function dbo.GetContactCtg (@name VARCHAR(500))
returns INT
as
begin
	declare @ret INT;

	declare @wc INT = 0;
	select
		@wc = COUNT(*)
	from dbo.split(@name, ' ')

	if @wc = 1
	begin
		set @ret = 2;
	end

	if @wc = 2
	begin
		set @ret = 1;
	end

	if @wc = 3
	begin

		if exists (
				select
					*
				from dbo.split(@name, ' ')
				where ID = 2
					and Data like '_.'
			)
		begin
			set @ret = 1;
		end
		else
		begin
			set @ret = 2;
		end

	end

	if @wc >= 4
	begin
		set @ret = 2;
	end

	return @ret;
end;
go

if OBJECT_ID(N'dbo.MoneyToDecimal', N'FN') is not null
	drop function MoneyToDecimal;

go

create function dbo.MoneyToDecimal (@WordParameter VARCHAR(100))
returns DECIMAL(18, 2)
as
begin
	declare @ret DECIMAL(18, 2);

	if ISNULL(@WordParameter, '') <> ''
	begin
		select
			@ret = REPLACE(REPLACE(@WordParameter, '$', ''), ',', '')
	end
	else
	begin
		select
			@ret = 0.0
	end

	return @ret;
end;
go

/*
IF OBJECT_ID (N'dbo.GetDWorkinContactCtg', N'FN') IS NOT NULL
    DROP FUNCTION GetDWorkinContactCtg;
GO
CREATE FUNCTION dbo.GetDWorkinContactCtg(@name varchar(MAX) )
RETURNS int 
AS 
BEGIN
    DECLARE @ret int;
		
		set @ret=1;
	if exists ( select * from [TimeMattersMcCoy].[lntmu11].[contact] CT where org='O' and full_name=@name)
	begin
		set @ret=2;
	end
    RETURN @ret;
END;
GO
*/

if OBJECT_ID(N'dbo.my_smalldatetime', N'FN') is not null
	drop function my_smalldatetime;

go

create function dbo.my_smalldatetime (@WordParameter VARCHAR(100))
returns SMALLDATETIME
as

begin
	declare @ret SMALLDATETIME;
	set @ret = CONVERT(SMALLDATETIME, @WordParameter);
	return @ret;
end
go


--example:
--select dbo.Integer2DateTime(75293, 75293 ); --2007-02-19 00:13:00
--select dbo.Integer2DateTime(77246, 4254001 ); --2012-06-25 11:49:00
--SELECT dbo.Integer2DateTime(36163,0); --1900-01-01 00:00:00
if OBJECT_ID(N'dbo.Integer2DateTime', N'FN') is not null
	drop function Integer2DateTime;

go

-- CREATE FUNCTION dbo.Integer2DateTime( @intDate int, @intTime int )
-- RETURNS smalldatetime 
-- AS 

-- BEGIN
-- 	DECLARE @ret smalldatetime;
-- 	DECLARE @date date;
-- 	DECLARE @time time;

-- 	SELECT @date = cast(dateadd(day,@intDate,'1800-12-28') as date)

-- 	SELECT @time = cast(dateadd(second,@intTime/100,'1800-12-28 00:00:00') as time)

-- 	SET @ret= @date + cast(@time as smalldatetime);

--     RETURN @ret;
-- END
create function dbo.Integer2DateTime (@intDate INT, @intTime INT)
returns DATETIME
as
begin
	declare @ret DATETIME;
	declare @date DATETIME;
	declare @time DATETIME;

	-- Convert intDate to date
	set @date = DATEADD(day, @intDate, '1800-12-28')

	-- Convert intTime to time (as smalldatetime)
	set @time = CAST(DATEADD(second, @intTime / 100, '1800-12-28 00:00:00') as SMALLDATETIME)

	-- Combine date and time
	set @ret = DATEADD(day, DATEDIFF(day, '19000101', @date), @time)

	return @ret;
end
go

create function dbo.Integer2Date (@intDate INT)
returns DATE
as

begin
	declare @date DATE;

	select
		@date = CAST(DATEADD(day, @intDate, '1800-12-28') as DATE)

	return @date;
end
go



-- Unix Timestamp:

if OBJECT_ID(N'dbo.fn_ConvertToDateTime', N'FN') is not null
	drop function dbo.fn_ConvertToDateTime;

go

create function dbo.fn_ConvertToDateTime (@Datetime BIGINT)
returns DATETIME
as
begin
	declare @LocalTimeOffset BIGINT,
			@AdjustedLocalDatetime BIGINT;
	set @LocalTimeOffset = DATEDIFF(second, GETDATE(), GETUTCDATE())
	set @AdjustedLocalDatetime = @Datetime - @LocalTimeOffset
	return (
		select
			DATEADD(second, @AdjustedLocalDatetime, CAST('1970-01-01 00:00:00' as DATETIME))
	)
end;

go

---example:
---select dbo.LeftWord('WE 2013/12/3') -- WE

if OBJECT_ID(N'dbo.LeftWord', N'FN') is not null
	drop function LeftWord;

go

create function dbo.LeftWord (@string VARCHAR(MAX))
returns VARCHAR(MAX)
as
begin
	declare @Ret VARCHAR(MAX);

	set @string = RTRIM(LTRIM(@string))

	if (CHARINDEX(' ', @string) = 0)
	begin
		set @Ret = @string
	end
	else
	begin
		set @Ret = LEFT(@string, CHARINDEX(' ', @string) - 1)
	end

	return @Ret
end

go


---
if OBJECT_ID(N'dbo.FirstName_FromText', N'FN') is not null
	drop function FirstName_FromText;

go

create function dbo.FirstName_FromText (@Str VARCHAR(MAX))
returns VARCHAR(MAX)
as
begin

	declare @Ret VARCHAR(MAX);

	set @Str = RTRIM(LTRIM(@Str));

	if CHARINDEX(',', @Str) <> 0
	begin
		set @Ret = RIGHT(@Str, LEN(@Str) - CHARINDEX(',', @Str));
	end

	else
	begin

		if (CHARINDEX(' ', @Str) = 0)
		begin

			if ISDATE(@Str) = 1
			begin
				set @Ret = null;
			end
			else
			begin
				set @Ret = @Str  -- 1 word
			end

		end
		else
		begin
			set @Ret = LEFT(@Str, CHARINDEX(' ', @Str) - 1)
		end

	end

	return @Ret;

end

go


----------------------------
if OBJECT_ID(N'dbo.LastName_FromText', N'FN') is not null
	drop function LastName_FromText;

go

create function dbo.LastName_FromText (@Str VARCHAR(MAX))
returns VARCHAR(MAX)
as
begin

	declare @Ret VARCHAR(MAX);

	set @Str = RTRIM(LTRIM(@Str));

	if CHARINDEX(',', @Str) <> 0
	begin
		set @Ret = LEFT(@Str, CHARINDEX(',', @Str) - 1);
	end

	else
	begin

		if (CHARINDEX(' ', @Str) = 0)
		begin

			if ISDATE(@Str) = 1
			begin
				set @Ret = null;
			end
			else
			begin
				set @Ret = @Str  -- 1 word
			end

		end
		else
		begin
			set @Ret = RIGHT(@Str, LEN(@Str) - CHARINDEX(' ', @Str))
		end

	end

	return @Ret;

end

go

------------------
------------------
------------------

if OBJECT_ID(N'dbo.FirstName_FromText', N'FN') is not null
	drop function dbo.FirstName_FromText;

go

create function dbo.FirstName_FromText (@StringParameter VARCHAR(100))
returns VARCHAR(100)
as
begin

	declare @Result VARCHAR(100) = '';
	declare @WordCount INT;

	if CHARINDEX(',', @StringParameter) > 0
	begin
		select
			@Result = Data
		from dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ',')
		where
			ID = 2
		return @Result
	end


	if CHARINDEX('&', @StringParameter) > 0
	begin
		select
			@StringParameter = SUBSTRING(@StringParameter, 0, CHARINDEX('&', @StringParameter))
	end

	select
		@WordCount = COUNT(Data)
	from dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ' ')

	if @WordCount >= 1
	begin
		select
			@Result = Data
		from dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ' ')
		where
			ID = 1
	end

	return @Result;

end

go

--
if OBJECT_ID(N'dbo.MiddleName_FromText', N'FN') is not null
	drop function dbo.MiddleName_FromText;

go

create function dbo.MiddleName_FromText (@StringParameter VARCHAR(100))
returns VARCHAR(100)
as
begin

	declare @Result VARCHAR(100) = '';
	declare @WordCount INT;

	if CHARINDEX('&', @StringParameter) > 0
	begin
		select
			@StringParameter = SUBSTRING(@StringParameter, 0, CHARINDEX('&', @StringParameter))
	end

	select
		@WordCount = COUNT(Data)
	from dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ' ')

	if @WordCount >= 3
	begin
		select
			@Result = Data
		from dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ' ')
		where
			ID = 2
	end

	return @Result;

end

go

--
if OBJECT_ID(N'dbo.LastName_FromText', N'FN') is not null
	drop function dbo.LastName_FromText;

go

create function dbo.LastName_FromText (@StringParameter VARCHAR(100))
returns VARCHAR(100)
as
begin

	declare @Marker VARCHAR(100);
	declare @Result VARCHAR(100) = ''
	declare @WordCount INT;

	if CHARINDEX(',', @StringParameter) > 0
	begin
		select
			@Result = Data
		from dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ',')
		where
			ID = 1
		return @Result
	end

	if CHARINDEX('&', @StringParameter) > 0
	begin
		select
			@StringParameter = SUBSTRING(@StringParameter, 0, CHARINDEX('&', @StringParameter))
	end


	select
		@WordCount = COUNT(Data)
	from dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ' ')

	if @WordCount > 3
	begin
		select
			@Marker = Data
		from dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ' ')
		where
			ID = 3
		select
			@Result = SUBSTRING(@StringParameter, CHARINDEX(@Marker, @StringParameter), LEN(@StringParameter))
	end
	else
	if @WordCount = 3
	begin
		select
			@Result = Data
		from dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ' ')
		where
			ID = 3
	end
	else
	begin

		if @WordCount = 2
		begin
			select
				@Result = Data
			from dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ' ')
			where
				ID = 2
		end

	end

	return @Result

end

go



------------------

go

------

if OBJECT_ID(N'dbo.Dworkin_FirstName_FromText', N'FN') is not null
	drop function dbo.Dworkin_FirstName_FromText;

go

create function dbo.Dworkin_FirstName_FromText (@StringParameter VARCHAR(100))
returns VARCHAR(100)
as
begin

	declare @Result VARCHAR(100) = '';
	declare @WordCount INT;


	if CHARINDEX('&', @StringParameter) > 0
	begin
		select
			@StringParameter = SUBSTRING(@StringParameter, 0, CHARINDEX('&', @StringParameter))
	end

	select
		@WordCount = COUNT(Data)
	from dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ' ')

	if @WordCount >= 1
	begin
		select
			@Result = Data
		from dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ' ')
		where
			ID = 1
	end

	return @Result;

end

go

------

if OBJECT_ID(N'dbo.Dworkin_LastName_FromText', N'FN') is not null
	drop function dbo.Dworkin_LastName_FromText;

go

create function dbo.Dworkin_LastName_FromText (@StringParameter VARCHAR(100))
returns VARCHAR(100)
as
begin

	declare @Marker VARCHAR(100);
	declare @Result VARCHAR(100) = ''
	declare @WordCount INT;


	if CHARINDEX('&', @StringParameter) > 0
	begin
		select
			@StringParameter = SUBSTRING(@StringParameter, 0, CHARINDEX('&', @StringParameter))
	end


	select
		@WordCount = COUNT(Data)
	from dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ' ')

	if @WordCount >= 2
	begin
		select
			@Marker = Data
		from dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ' ')
		where
			ID = 2
		select
			@Result = SUBSTRING(@StringParameter, CHARINDEX(@Marker, @StringParameter), LEN(@StringParameter))
	end

	return @Result

end

go

if OBJECT_ID('dbo.ValidDate', 'FN') is not null
	drop function dbo.ValidDate;

go

create function dbo.ValidDate (@dt DATETIME2)
returns DATETIME2
as
begin
	return case
		when @dt between '1900-01-01' and '2079-06-06'
			then @dt
		else null
	end;
end;
go

/* ------------------------------------------------------------------------------
Stored Procedure: AddBreadcrumbsToTable
*/ ------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'AddBreadcrumbsToTable')
BEGIN
    DROP PROCEDURE AddBreadcrumbsToTable;
END
GO

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

/* ------------------------------------------------------------------------------
Stored Procedure: BuildNeedlesUserTabStagingTable
*/ ------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'BuildNeedlesUserTabStagingTable')
BEGIN
    DROP PROCEDURE BuildNeedlesUserTabStagingTable;
END
go

CREATE OR ALTER PROCEDURE dbo.BuildNeedlesUserTabStagingTable
    @SourceDatabase SYSNAME,
    @TargetDatabase SYSNAME,
    @DataTableName SYSNAME,
    @StagingTable SYSNAME,
    @ColumnList NVARCHAR(MAX) -- comma-separated column names
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MatterTable SYSNAME = REPLACE(@DataTableName, '_data', '_matter');
    DECLARE @NameTable SYSNAME   = REPLACE(@DataTableName, '_data', '_name');
    --DECLARE @StagingTable SYSNAME = 'stg_' + REPLACE(@DataTableName, 'user_tab_', '');
	
	-- Drop staging table if exists
	DECLARE @dropSQL NVARCHAR(MAX);
    SET @DropSql = '
    IF OBJECT_ID(''' + @TargetDatabase + '.dbo.' + @StagingTable + ''', ''U'') IS NOT NULL
        DROP TABLE ' + @TargetDatabase + '.dbo.' + @StagingTable + ';';
    EXEC(@DropSql);

	-- Clean and split column list into a table
	CREATE TABLE #Cols (colname NVARCHAR(255));
    INSERT INTO #Cols (colname)
    SELECT LTRIM(RTRIM(REPLACE(REPLACE(value, CHAR(10), ''), CHAR(13), '')))
    FROM STRING_SPLIT(@ColumnList, ',')
    WHERE LTRIM(RTRIM(REPLACE(REPLACE(value, CHAR(10), ''), CHAR(13), ''))) <> '';
	--Select * from #Cols c

    -- IN clause for mapping query
    DECLARE @InClause NVARCHAR(MAX);
    SELECT @InClause = STRING_AGG('''' + colname + '''', ',') FROM #Cols;

    -- Mapping table
    CREATE TABLE #Mapping (
        table_name  VARCHAR(100),
        column_name VARCHAR(100),
        field_type  VARCHAR(25),
        caseid_col  VARCHAR(10)
    );

    DECLARE @MappingSQL NVARCHAR(MAX) = '
        INSERT INTO #Mapping (table_name, column_name, field_type, caseid_col)
        SELECT DISTINCT nuf.table_name, nuf.column_name, utm.field_type, nuf.caseid_col
        FROM ' + QUOTENAME(@SourceDatabase) + '..NeedlesUserFields nuf
        JOIN ' + QUOTENAME(@SourceDatabase) + '..' + QUOTENAME(@MatterTable) + ' utm
            ON nuf.field_num = utm.ref_num
        WHERE nuf.table_name = @tbl
          AND nuf.column_name IN (' + @InClause + ')';
	--print @MappingSQL
    EXEC sp_executesql @MappingSQL, N'@tbl SYSNAME', @tbl=@DataTableName;
	--Select * from #Mapping m

	 -- Get caseid column
    DECLARE @CaseIdCol SYSNAME = (SELECT TOP 1 caseid_col FROM #Mapping);

    -- Build select columns
    DECLARE @SelectCols NVARCHAR(MAX);
    SELECT @SelectCols = STRING_AGG(
        CASE 
            WHEN field_type = 'name' THEN 'ioci.CID AS [' + column_name + '_CID]'
            ELSE 'utd.[' + column_name + '] AS [' + column_name + ']'
        END, ', '
    )
    FROM #Mapping;

    -- Build WHERE clause
    DECLARE @Where NVARCHAR(MAX);
    SELECT @Where = STRING_AGG(
        '(' + CASE 
            WHEN field_type = 'name' THEN 'ioci.CID'
            ELSE 'utd.[' + column_name + ']'
        END + ' IS NOT NULL)', ' OR '
    )
    FROM #Mapping;

    -- Assemble final SQL
    DECLARE @FinalSQL NVARCHAR(MAX) = '
        SELECT DISTINCT
            utd.' + @CaseIdCol + ' AS caseid,
            utd.tab_id AS tabid,
            ' + @SelectCols + '
        INTO ' + QUOTENAME(@TargetDatabase) + '.dbo.' + QUOTENAME(@StagingTable) + '
        FROM ' + QUOTENAME(@SourceDatabase) + '..' + QUOTENAME(@DataTableName) + ' utd
        LEFT JOIN ' + QUOTENAME(@SourceDatabase) + '..' + QUOTENAME(@NameTable) + ' utn
            ON utd.' + @CaseIdCol + ' = utn.case_id AND utd.tab_id = utn.tab_id
        LEFT JOIN ' + QUOTENAME(@SourceDatabase) + '..' + QUOTENAME(@MatterTable) + ' utm
            ON utn.ref_num = utm.ref_num
        LEFT JOIN ' + QUOTENAME(@SourceDatabase) + '..names n
            ON utn.user_name = n.names_id
        LEFT JOIN IndvOrgContacts_Indexed ioci
            ON ioci.SAGA = n.names_id
        WHERE ' + @Where + '
        ORDER BY utd.' + @CaseIdCol + ';';

    -- Execute dynamic SQL
    EXEC(@FinalSQL);

    -- Return staging table
    DECLARE @ReturnSQL NVARCHAR(MAX) = 'SELECT * FROM ' + QUOTENAME(@TargetDatabase) + '.dbo.' + QUOTENAME(@StagingTable) + ' ORDER BY caseid;';
    EXEC(@ReturnSQL);
END;
GO

