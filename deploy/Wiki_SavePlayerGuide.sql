/* ============================================================
   玩家投稿攻略存储过程：Wiki_SavePlayerGuide
   用途：前台 Wiki 窗口 Player Guides「Contribute」编辑器保存投稿。
   参数：@UserID   投稿人（当前登录用户）
        @PageName 当前 wiki 页面名（如 cities-durability），用于解析 WikiItem.ItemID，
                  把攻略挂到「对应的 wiki item」下；解析不到（如 index）则 ItemID 为 NULL（通用攻略）
        @Title    标题
        @Summary  摘要（后台由正文去标签截断生成）
        @Content  正文（HTML）
        @GuideID  OUTPUT：新插入的 GuideID
   规则：新投稿默认 Status = 0（待审核），审核通过（Status=1）后才会出现在列表与计数中。
        ViewCount/LikeCount 初始 0，IsPinned=0，CreatedTime=GETUTCDATE()。
   ============================================================ */

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Wiki_SavePlayerGuide]') AND type = N'P')
    DROP PROCEDURE [dbo].[Wiki_SavePlayerGuide];
GO

CREATE PROCEDURE [dbo].[Wiki_SavePlayerGuide]
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

    -- 标题/正文为空的非法投稿直接拒绝
    IF (@Title IS NULL OR LTRIM(RTRIM(@Title)) = N'') RETURN;

    DECLARE @ItemID INT = NULL;

    -- 页面名形如 {CategoryName}-{ItemName}，按第一个 '-' 拆分定位 WikiItem
    -- 特殊处理：'index' 代表 Getting Started 页面，直接查找 ItemName='index'
    IF (@PageName IS NOT NULL AND LTRIM(RTRIM(@PageName)) <> N'')
    BEGIN
        IF (@PageName = N'index')
        BEGIN
            -- Getting Started 页面
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
        (@UserID, @ItemID, LTRIM(RTRIM(@Title)), @Summary, @Content, 0, 0, 0, 0, GETUTCDATE());

    SET @GuideID = CAST(SCOPE_IDENTITY() AS INT);
END
GO
