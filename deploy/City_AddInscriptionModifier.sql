/* ============================================================
   City 铭文编辑者信息 + 控制时长信息 - 数据库部署脚本
   用途：记录谁最后编辑了城市铭文，并在城市详情中返回编辑者信息
         返回最长控制玩家信息和当前玩家控制天数
   执行日期：2026/10/10 [AI]
   ============================================================ */

-- 1. Cities 表增加 InscriptionUserID 字段（已在数据库中执行）
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Cities]') AND name = N'InscriptionUserID')
BEGIN
    ALTER TABLE [dbo].[Cities] ADD [InscriptionUserID] INT NULL;
END
GO

-- 2. 修改 City_EditInscription 存储过程（已在数据库中执行）
-- 修改要点：
--   a) 增加输入参数：@InscriptionUserID INT（位于 @Inscription 之后）
--   b) UPDATE 语句增加：InscriptionUserID = @InscriptionUserID
-- 原始定义：2018/10/24
-- 修改日期：2026/10/10 [AI] 增加 @InscriptionUserID 参数，记录铭文编辑者
GO

-- 3. 修改 City_GetDeatilInfo 存储过程（已在数据库中执行）
-- 修改要点：
--   a) 第一个 SELECT 结果集增加：InscriptionUserID, InscriptionModifierName
--   b) 增加控制时长计算：
--      - LongestControlPlayerID: 最长控制玩家 ID
--      - LongestControlPlayerName: 最长控制玩家名
--      - LongestControlDays: 最长控制天数
--      - MyControlDays: 当前玩家控制天数（如果是城主）
-- 修改日期：2026/10/10 [AI] 增加铭文编辑者信息返回 + 控制时长信息返回
-- 
-- 新增字段使用子查询从 CityHistory 表计算：
--   SELECT TOP 1 ... FROM CityHistory ch WHERE ch.CityID = @CityID 
--   ORDER BY DATEDIFF(day, ch.OccupyTime, ISNULL(ch.LeftTime, GETDATE())) DESC
GO
