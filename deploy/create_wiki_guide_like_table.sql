SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- WikiGuideLike 表：记录玩家对攻略的 like
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WikiGuideLike]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[WikiGuideLike]
    (
        [LikeID]     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [GuideID]    INT NOT NULL,
        [UserID]     INT NOT NULL,
        [CreatedTime] DATETIME NOT NULL CONSTRAINT [DF_WikiGuideLike_CreatedTime] DEFAULT GETUTCDATE(),
        CONSTRAINT [UQ_WikiGuideLike_GuideUser] UNIQUE ([GuideID], [UserID])
    );
END
GO
