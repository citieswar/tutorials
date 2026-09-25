SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Wiki_GetPlayerGuides]') AND type = N'P')
    DROP PROCEDURE [dbo].[Wiki_GetPlayerGuides];
GO

CREATE PROCEDURE [dbo].[Wiki_GetPlayerGuides]
    @PageName     NVARCHAR(200) = NULL,   -- 传入=只看该页攻略；空/NULL=看全部
    @CurrentUserID INT = NULL              -- 当前登录用户 ID（用于判断是否已 like）
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ItemID INT = NULL;

    IF (@PageName IS NOT NULL AND LTRIM(RTRIM(@PageName)) <> N'')
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

    SELECT g.GuideID,
           g.Title,
           g.Summary,
           g.Content,
           g.UserID,
           ISNULL(u.RoleName, N'') AS AuthorName,
           ISNULL(wc.CategoryName, N'') AS CategoryName,
           ISNULL(wi.ItemName, N'') AS ItemName,
           g.ViewCount,
           g.LikeCount,
           g.IsPinned,
           g.PublishedTime,
           CASE WHEN gl.LikeID IS NOT NULL THEN 1 ELSE 0 END AS IsLikedByUser
      FROM WikiPlayerGuide g
      LEFT JOIN UserInfo u ON u.UserID = g.UserID
      LEFT JOIN WikiItem wi ON wi.ItemID = g.ItemID
      LEFT JOIN WikiCategory wc ON wc.CategoryID = wi.CategoryID
      LEFT JOIN WikiGuideLike gl ON gl.GuideID = g.GuideID AND gl.UserID = @CurrentUserID
     WHERE g.Status = 1
       AND (
             (@PageName IS NULL OR LTRIM(RTRIM(@PageName)) = N'')
             OR g.ItemID = @ItemID
           )
     ORDER BY g.IsPinned DESC, g.PublishedTime DESC, g.GuideID DESC;
END
GO
