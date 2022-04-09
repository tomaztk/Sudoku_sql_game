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


DROP TABLE IF EXISTS dbo.grid3;
CREATE TABLE dbo.grid3
( ID TINYINT IDENTITY(1,1)
, [1] TINYINT NOT NULL
, [2] TINYINT NOT NULL
, [3] TINYINT NOT NULL
, [4] TINYINT NOT NULL
, [5] TINYINT NOT NULL
, [6] TINYINT NOT NULL
, [7] TINYINT NOT NULL
, [8] TINYINT NOT NULL
, [9] TINYINT NOT NULL
)


INSERT INTO dbo.grid3 ([1],[2],[3],[4],[5],[6],[7],[8],[9])
		  SELECT 5,3,0,0,7,0,0,0,0 
UNION ALL SELECT 6,0,0,1,9,5,0,0,0 
UNION ALL SELECT 0,8,9,0,0,0,0,6,0 
UNION ALL SELECT 8,0,0,0,6,0,0,0,3 
UNION ALL SELECT 4,0,0,8,0,3,0,0,1 
UNION ALL SELECT 7,0,0,0,2,0,0,0,6 
UNION ALL SELECT 0,6,0,0,0,0,2,0,8 
UNION ALL SELECT 0,0,0,4,1,9,0,0,5 
UNION ALL SELECT 0,0,0,0,8,0,0,7,9 


-- for 3x3 rectangles
DECLARE @i int = 1
declare @j int = 1

DECLARE @k INT = 1
WHILE @k <= 3
BEGIN
	DECLARE @n INT = 1
	WHILE @n <= 3
	BEGIN
			DECLARE @x0 INT = 0
			DECLARE @y0 INT = 0
			SET @x0 = (@i/3)*3
			SET @y0 = (@j/3)*3
			 
			 DECLARE @a INT = @x0+@i
			 DECLARE @b INT = @y0+@j
			 DECLARE @v INT = 0
			 EXEC dbo.get_grid 
					 @a
					,@b
					,@v OUT
				SELECT @a, @b, @v
		SET @n = @n + 1
	END

	SET @k = @k + 1
END




-- Full possible function
-- SET NOCOUNT ON; 


DECLARE @i INT = 0
WHILE @i <= 8
    BEGIN
    DECLARE @j INT = 0
    WHILE @j <= 8
        BEGIN
                DECLARE @v  TINYINT  = 0
                EXEC dbo.get_grid
                    @i
                    ,@j
                    ,@v OUT
                
                    --SELECT 'True', @i, @j, @v
		
		-- Add  checker for each square (3x3)
		 -- START:

		 		DECLARE @x0 INT = 0
				DECLARE @y0 INT = 0
				SET @x0 = (@i/3)*3
				SET @y0 = (@j/3)*3

				DECLARE @k INT = 1
				WHILE @k <= 3
				BEGIN
					DECLARE @n INT = 1
					WHILE @n <= 3
					BEGIN
			 
							-- DECLARE @a INT = @x0+@i
							-- DECLARE @b INT = @y0+@j

							 DECLARE @w INT = 0
							 EXEC dbo.get_grid 
									-- @a
									--,@b
									 @x0
									,@y0
									,@w OUT

						IF  @w = 5
							SELECT @w
					
								--SELECT @a, @b, @w

						SET @n = @n + 1
					END

					SET @k = @k + 1
				END
		 -- END:

        SET @j = @j + 1
        END
SET @i = @i + 1 
END


