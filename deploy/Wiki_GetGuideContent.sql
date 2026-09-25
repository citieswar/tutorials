SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Wiki_GetGuideContent]') AND type = N'P')
    DROP PROCEDURE [dbo].[Wiki_GetGuideContent];
GO

CREATE PROCEDURE [dbo].[Wiki_GetGuideContent]
    @GuideID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Content FROM WikiPlayerGuide WHERE GuideID = @GuideID;
END
GO
