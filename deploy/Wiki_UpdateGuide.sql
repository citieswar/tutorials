SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Wiki_UpdateGuide]') AND type = N'P')
    DROP PROCEDURE [dbo].[Wiki_UpdateGuide];
GO

CREATE PROCEDURE [dbo].[Wiki_UpdateGuide]
    @GuideID  INT,
    @UserID   INT,
    @Title    NVARCHAR(200),
    @Summary  NVARCHAR(500),
    @Content  NVARCHAR(MAX),
    @Result   INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;

    IF (@Title IS NULL OR LTRIM(RTRIM(@Title)) = N'') RETURN;
    IF (@Content IS NULL OR LTRIM(RTRIM(@Content)) = N'') RETURN;

    DECLARE @CurrentStatus TINYINT;
    SELECT @CurrentStatus = Status FROM WikiPlayerGuide WHERE GuideID = @GuideID AND UserID = @UserID;
    IF (@CurrentStatus IS NULL) RETURN;

    UPDATE WikiPlayerGuide
       SET Title = LTRIM(RTRIM(@Title)),
           Summary = @Summary,
           Content = @Content,
           Status = CASE WHEN @CurrentStatus = 3 THEN 3 ELSE 0 END,
           UpdatedTime = GETUTCDATE()
     WHERE GuideID = @GuideID AND UserID = @UserID;

    SET @Result = 1;
END
GO
