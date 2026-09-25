/* ============================================================
   WikiPlayerGuide 表增加 AI 审核相关字段
   用途：记录 AI 对玩家投稿攻略的自动审核结果
   ============================================================ */

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- 1. 增加 AI 审核相关字段（如果尚不存在）
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[WikiPlayerGuide]') AND name = N'AIAction')
BEGIN
    ALTER TABLE [dbo].[WikiPlayerGuide] ADD
        [AIAction]      NVARCHAR(20)   NULL,   -- 'approve' / 'review' / 'reject'
        [AIReason]      NVARCHAR(500)  NULL,   -- AI 给出的原因说明
        [AIScores]      NVARCHAR(200)  NULL,   -- JSON: {"safety":5,"relevance":4,...}
        [AIReviewTime]  DATETIME       NULL;   -- AI 审核时间

    PRINT 'Added AI review fields to WikiPlayerGuide table.';
END
ELSE
BEGIN
    PRINT 'AI review fields already exist in WikiPlayerGuide table.';
END
GO

/* ============================================================
   存储过程：获取待 AI 审核的攻略列表
   返回 Status=0（待审核）且尚未被 AI 处理过的攻略
   ============================================================ */
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Wiki_GetPendingAIGuides]') AND type = N'P')
    DROP PROCEDURE [dbo].[Wiki_GetPendingAIGuides];
GO

CREATE PROCEDURE [dbo].[Wiki_GetPendingAIGuides]
    @MaxCount INT = 50   -- 每次最多取多少条，默认 50
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@MaxCount)
           g.GuideID,
           g.UserID,
           g.Title,
           g.Summary,
           g.Content,
           g.CreatedTime,
           ISNULL(u.Name, N'Unknown') AS AuthorName
      FROM WikiPlayerGuide g
      LEFT JOIN UserInfo u ON u.UserID = g.UserID
     WHERE g.Status = 0                          -- 待审核
       AND (g.AIAction IS NULL                   -- 从未被 AI 审核过
            OR g.AIReviewTime < DATEADD(HOUR, -24, GETUTCDATE()))  -- 或超过 24 小时未更新
     ORDER BY g.CreatedTime ASC;                 -- 按提交时间从早到晚
END
GO

/* ============================================================
   存储过程：更新 AI 审核结果
   根据 AI 返回的结果更新 Status 和 AI 相关字段
   ============================================================ */
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Wiki_UpdateAIReviewResult]') AND type = N'P')
    DROP PROCEDURE [dbo].[Wiki_UpdateAIReviewResult];
GO

CREATE PROCEDURE [dbo].[Wiki_UpdateAIReviewResult]
    @GuideID    INT,
    @AIAction   NVARCHAR(20),    -- 'approve' / 'review' / 'reject'
    @AIReason   NVARCHAR(500),
    @AIScores   NVARCHAR(200),   -- JSON 字符串
    @NewStatus  TINYINT          -- 新的 Status 值：1=通过, 0=待人工复审, 2=驳回
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE WikiPlayerGuide
       SET AIAction     = @AIAction,
           AIReason     = @AIReason,
           AIScores     = @AIScores,
           AIReviewTime = GETUTCDATE(),
           Status       = @NewStatus,
           PublishedTime = CASE WHEN @NewStatus = 1 THEN GETUTCDATE() ELSE PublishedTime END
     WHERE GuideID = @GuideID;
END
GO

PRINT 'Wiki AI review stored procedures created successfully.';
GO
