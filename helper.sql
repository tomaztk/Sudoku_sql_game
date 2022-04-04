DROP TABLE IF EXISTS dbo.grid2;
CREATE TABLE dbo.grid2
( ID TINYINT IDENTITY(1,1)
, [1] TINYINT NOT NULL
, [2] TINYINT NOT NULL
, [3] TINYINT NOT NULL)


INSERT INTO dbo.grid2 ([1],[2],[3])
          SELECT 12,11,23
UNION ALL SELECT 23,34,35
UNION ALL SELECT 51,55,56


CREATE OR ALTER PROCEDURE dbo.get_grid
(@row TINYINT
,@col TINYINT
,@result TINYINT OUTPUT
)
AS
BEGIN
	DECLARE @sql NVARCHAR(1000)
	SET @sql = '
		SELECT 	
			 '+CAST(QUOTENAME(@col) as VARCHAR(100))+' 
		FROM dbo.grid2 as g
		WHERE
			g.ID = '+ CAST(@row AS VARCHAR(100)) +' 
	'

	DECLARE @t table (i tinyint)
	INSERT INTO @t
	EXEC sp_executesql @sql

	SET @result = (SELECT i FROM @t)
	 
END;
GO

DECLARE @v TINYINT; 
EXEC dbo.get_grid 2,3, @v OUT
SELECT @v


DECLARE @i INT = 1
WHILE @i <= 3
    BEGIN
    DECLARE @j INT = 1
    WHILE @j <= 3
        BEGIN
                DECLARE @v  TINYINT  = 0
                EXEC dbo.get_grid
                    @i
                    ,@j
                    ,@v OUT
                
                IF (@v = 23) 
                    SELECT 'True', @i, @j, @v
                ELSE
                    SELECT 'Not Exists', @i, @j, @v
        SET @j = @j + 1
        END
SET @i = @i + 1 
END
