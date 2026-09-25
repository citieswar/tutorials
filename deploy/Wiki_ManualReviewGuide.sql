/* ============================================================
   存储过程：人工审核攻略
   用途：管理员手动通过/驳回玩家投稿攻略
   ============================================================ */

IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Wiki_ManualReviewGuide]') AND type = N'P')
    DROP PROCEDURE [dbo].[Wiki_ManualReviewGuide];
GO

CREATE PROCEDURE [dbo].[Wiki_ManualReviewGuide]
    @GuideID      INT,
    @ReviewerID   INT,          -- 审核人 UserID
    @NewStatus    TINYINT,      -- 1=通过, 2=驳回
    @RejectReason NVARCHAR(500) -- 驳回原因（通过时可为空）
AS
BEGIN
    SET NOCOUNT ON;

    -- 只允许审核待审核(Status=0)的攻略
    DECLARE @CurrentStatus TINYINT;
    SELECT @CurrentStatus = Status FROM WikiPlayerGuide WHERE GuideID = @GuideID;
    IF (@CurrentStatus IS NULL) RETURN;
    IF (@CurrentStatus <> 0) RETURN;  -- 非待审核状态不允许操作

    UPDATE WikiPlayerGuide
       SET Status       = @NewStatus,
           ReviewedBy   = @ReviewerID,
           ReviewedTime = GETUTCDATE(),
           PublishedTime = CASE WHEN @NewStatus = 1 THEN GETUTCDATE() ELSE NULL END,
           AIReason     = CASE WHEN @RejectReason IS NOT NULL AND @RejectReason <> N'' THEN @RejectReason ELSE AIReason END
     WHERE GuideID = @GuideID;
END
GO

/* ============================================================
   存储过程：获取待人工审核的攻略列表（含 AI 审核结果）
   ============================================================ */
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Wiki_GetPendingManualGuides]') AND type = N'P')
    DROP PROCEDURE [dbo].[Wiki_GetPendingManualGuides];
GO

CREATE PROCEDURE [dbo].[Wiki_GetPendingManualGuides]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT g.GuideID,
           g.UserID,
           g.Title,
           g.Summary,
           g.Content,
           g.CreatedTime,
           g.AIAction,
           g.AIReason,
           g.AIScores,
           g.AIReviewTime,
           ISNULL(u.Name, N'Unknown') AS AuthorName,
           ISNULL(wc.CategoryName, N'') AS CategoryName,
           ISNULL(wi.ItemName, N'') AS ItemName
      FROM WikiPlayerGuide g
      LEFT JOIN UserInfo u ON u.UserID = g.UserID
      LEFT JOIN WikiItem wi ON wi.ItemID = g.ItemID
      LEFT JOIN WikiCategory wc ON wc.CategoryID = wi.CategoryID
     WHERE g.Status = 0
     ORDER BY g.CreatedTime ASC;
END
GO

/* ============================================================
   存储过程：获取已审核的攻略列表（通过+驳回）
   ============================================================ */
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Wiki_GetReviewedGuides]') AND type = N'P')
    DROP PROCEDURE [dbo].[Wiki_GetReviewedGuides];
GO

CREATE PROCEDURE [dbo].[Wiki_GetReviewedGuides]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT g.GuideID,
           g.UserID,
           g.Title,
           g.Summary,
           g.Content,
           g.Status,
           g.CreatedTime,
           g.ReviewedTime,
           g.AIAction,
           g.AIReason,
           g.AIScores,
           g.AIReviewTime,
           ISNULL(u.Name, N'Unknown') AS AuthorName,
           ISNULL(wc.CategoryName, N'') AS CategoryName,
           ISNULL(wi.ItemName, N'') AS ItemName
      FROM WikiPlayerGuide g
      LEFT JOIN UserInfo u ON u.UserID = g.UserID
      LEFT JOIN WikiItem wi ON wi.ItemID = g.ItemID
      LEFT JOIN WikiCategory wc ON wc.CategoryID = wi.CategoryID
     WHERE g.Status IN (1, 2)
     ORDER BY g.ReviewedTime DESC;
END
GO

PRINT 'Wiki manual review stored procedures created.';
GO
