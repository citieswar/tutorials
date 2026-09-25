/* ============================================================
   Wiki 词条点击计数存储过程：Wiki_ClickItem
   用途：前台玩家点击 wiki 词条（打开某个 wiki 页面）时调用，
        按页面名将对应 WikiItem.ClickCount + 1；
        同时通过 @GuideCount 输出参数带回「已审核玩家攻略」数量
        （WikiPlayerGuide.Status = 1），供前台 Player Guides tab 显示计数。
   页面名格式：「分类-子项」，如 cities-attributes
        -> WikiCategory.CategoryName = 'cities'
        -> WikiItem.ItemName         = 'attributes'
   说明：分类名与子项名内部均不含 '-'，故按第一个 '-' 拆分；
        无 '-'（如 index）或未命中分类/子项时静默忽略，不做任何更新；
        但无论词条是否命中，@GuideCount 都会先赋值并正常返回。
   ============================================================ */

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Wiki_ClickItem]') AND type = N'P')
    DROP PROCEDURE [dbo].[Wiki_ClickItem];
GO

CREATE PROCEDURE [dbo].[Wiki_ClickItem]
    @PageName   NVARCHAR(200),       -- wiki 页面名（index.json 中的 page），如 cities-attributes
    @GuideCount INT OUTPUT           -- 输出：已审核(Status=1)的玩家攻略数量
AS
BEGIN
    SET NOCOUNT ON;

    -- 先带回已审核玩家攻略数量（即使后续因页面名不合法而提前 RETURN，也已赋值）
    SET @GuideCount = (SELECT COUNT(*) FROM WikiPlayerGuide WHERE Status = 1);

    IF (@PageName IS NULL OR LTRIM(RTRIM(@PageName)) = N'')
        RETURN;

    DECLARE @sep INT = CHARINDEX(N'-', @PageName);

    -- 没有 '-' 或 '-' 位于首位：无法定位分类，忽略
    IF (@sep <= 1)
        RETURN;

    DECLARE @CategoryName NVARCHAR(100) = LEFT(@PageName, @sep - 1);
    DECLARE @ItemName     NVARCHAR(200) = SUBSTRING(@PageName, @sep + 1, LEN(@PageName));

    IF (@ItemName = N'')
        RETURN;

    -- 命中「分类 + 子项」后 ClickCount + 1
    UPDATE wi
       SET wi.ClickCount = ISNULL(wi.ClickCount, 0) + 1
      FROM WikiItem wi
      INNER JOIN WikiCategory wc ON wc.CategoryID = wi.CategoryID
     WHERE wc.CategoryName = @CategoryName
       AND wi.ItemName     = @ItemName
       AND wi.IsActive     = 1
       AND wc.IsActive     = 1;
END
GO
