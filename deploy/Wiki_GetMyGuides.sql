SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Wiki_GetMyGuides]') AND type = N'P')
    DROP PROCEDURE [dbo].[Wiki_GetMyGuides];
GO

CREATE PROCEDURE [dbo].[Wiki_GetMyGuides]
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT g.GuideID,
           g.Title,
           g.Summary,
           g.Content,
           g.Status,
           g.ViewCount,
           g.LikeCount,
           g.IsPinned,
           g.CreatedTime,
           ISNULL(wc.CategoryName, N'') AS CategoryName,
           ISNULL(wi.ItemName, N'') AS ItemName,
           ISNULL(g.AIReason, N'') AS AIReason
      FROM WikiPlayerGuide g
      LEFT JOIN WikiItem wi ON wi.ItemID = g.ItemID
      LEFT JOIN WikiCategory wc ON wc.CategoryID = wi.CategoryID
     WHERE g.UserID = @UserID
     ORDER BY CASE WHEN g.Status = 3 THEN 0 ELSE 1 END,
              g.CreatedTime DESC;
END
GO
