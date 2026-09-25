SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Wiki_ToggleLike]') AND type = N'P')
    DROP PROCEDURE [dbo].[Wiki_ToggleLike];
GO

CREATE PROCEDURE [dbo].[Wiki_ToggleLike]
    @UserID  INT,
    @GuideID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM WikiGuideLike WHERE GuideID = @GuideID AND UserID = @UserID)
    BEGIN
        -- 已 like → 取消 like
        DELETE FROM WikiGuideLike WHERE GuideID = @GuideID AND UserID = @UserID;
        UPDATE WikiPlayerGuide SET LikeCount = LikeCount - 1 WHERE GuideID = @GuideID AND LikeCount > 0;
    END
    ELSE
    BEGIN
        -- 未 like → 添加 like
        INSERT INTO WikiGuideLike (GuideID, UserID, CreatedTime) VALUES (@GuideID, @UserID, GETUTCDATE());
        UPDATE WikiPlayerGuide SET LikeCount = LikeCount + 1 WHERE GuideID = @GuideID;
    END

    -- 返回当前 LikeCount 和是否已 like
    DECLARE @LikeCount INT = 0;
    DECLARE @IsLiked   INT = 0;

    SELECT @LikeCount = LikeCount FROM WikiPlayerGuide WHERE GuideID = @GuideID;
    IF EXISTS (SELECT 1 FROM WikiGuideLike WHERE GuideID = @GuideID AND UserID = @UserID)
        SET @IsLiked = 1;

    SELECT @GuideID AS GuideID, @LikeCount AS LikeCount, @IsLiked AS IsLiked;
END
GO
