SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Wiki_DeleteGuide]') AND type = N'P')
    DROP PROCEDURE [dbo].[Wiki_DeleteGuide];
GO

CREATE PROCEDURE [dbo].[Wiki_DeleteGuide]
    @GuideID  INT,
    @UserID   INT,
    @Result   INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;

    DELETE FROM WikiGuideLike WHERE GuideID = @GuideID;
    DELETE FROM WikiPlayerGuide WHERE GuideID = @GuideID AND UserID = @UserID;
    SET @Result = @@ROWCOUNT;
END
GO
