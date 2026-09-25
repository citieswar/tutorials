SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Wiki_UpdateDraftStatus]') AND type = N'P')
    DROP PROCEDURE [dbo].[Wiki_UpdateDraftStatus];
GO

CREATE PROCEDURE [dbo].[Wiki_UpdateDraftStatus]
    @GuideID    INT,
    @UserID     INT,
    @NewStatus  TINYINT,
    @Result     INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;

    DECLARE @CurrentStatus TINYINT;
    SELECT @CurrentStatus = Status FROM WikiPlayerGuide WHERE GuideID = @GuideID AND UserID = @UserID;
    IF (@CurrentStatus IS NULL) RETURN;

    UPDATE WikiPlayerGuide
       SET Status = @NewStatus,
           UpdatedTime = GETUTCDATE()
     WHERE GuideID = @GuideID AND UserID = @UserID;

    SET @Result = 1;
END
GO
