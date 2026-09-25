SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Wiki_IncrementViewCount]') AND type = N'P')
    DROP PROCEDURE [dbo].[Wiki_IncrementViewCount];
GO

CREATE PROCEDURE [dbo].[Wiki_IncrementViewCount]
    @GuideID INT,
    @UserID  INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    -- 作者自己查看不计数
    IF (@UserID IS NOT NULL)
    BEGIN
        DECLARE @OwnerID INT;
        SELECT @OwnerID = UserID FROM WikiPlayerGuide WHERE GuideID = @GuideID;
        IF (@OwnerID = @UserID) RETURN;
    END
    UPDATE WikiPlayerGuide SET ViewCount = ViewCount + 1 WHERE GuideID = @GuideID;
END
GO
