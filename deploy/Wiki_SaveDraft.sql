SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Wiki_SaveDraft]') AND type = N'P')
    DROP PROCEDURE [dbo].[Wiki_SaveDraft];
GO

CREATE PROCEDURE [dbo].[Wiki_SaveDraft]
    @UserID   INT,
    @PageName NVARCHAR(200),
    @Title    NVARCHAR(200),
    @Summary  NVARCHAR(500),
    @Content  NVARCHAR(MAX),
    @GuideID  INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @GuideID = 0;

    -- 标题为空时给个默认名
    IF (@Title IS NULL OR LTRIM(RTRIM(@Title)) = N'')
        SET @Title = N'Untitled Draft';

    DECLARE @ItemID INT = NULL;

    IF (@PageName IS NOT NULL AND LTRIM(RTRIM(@PageName)) <> N'' AND @PageName <> N'0')
    BEGIN
        IF (@PageName = N'index')
        BEGIN
            SELECT @ItemID = wi.ItemID
              FROM WikiItem wi
              INNER JOIN WikiCategory wc ON wc.CategoryID = wi.CategoryID
             WHERE wi.ItemName = N'index'
               AND wi.IsActive = 1
               AND wc.IsActive = 1;
        END
        ELSE
        BEGIN
            DECLARE @sep INT = CHARINDEX(N'-', @PageName);
            IF (@sep > 1)
            BEGIN
                DECLARE @CategoryName NVARCHAR(100) = LEFT(@PageName, @sep - 1);
                DECLARE @ItemName     NVARCHAR(200) = SUBSTRING(@PageName, @sep + 1, LEN(@PageName));
                SELECT @ItemID = wi.ItemID
                  FROM WikiItem wi
                  INNER JOIN WikiCategory wc ON wc.CategoryID = wi.CategoryID
                 WHERE wc.CategoryName = @CategoryName
                   AND wi.ItemName = @ItemName
                   AND wi.IsActive = 1
                   AND wc.IsActive = 1;
            END
        END
    END

    INSERT INTO WikiPlayerGuide
        (UserID, ItemID, Title, Summary, Content, Status, IsPinned, ViewCount, LikeCount, CreatedTime)
    VALUES
        (@UserID, @ItemID, LTRIM(RTRIM(@Title)), @Summary, @Content, 3, 0, 0, 0, GETUTCDATE());

    SET @GuideID = CAST(SCOPE_IDENTITY() AS INT);
END
GO
