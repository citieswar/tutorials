/* ============================================================
   WikiPlayerGuide 测试数据（种子）
   说明：可重复执行 —— 先按「已知测试标题」清理旧测试行，再重新插入，
        不会影响其它标题的真实数据。
        共 6 条「已审核」(Status=1) + 2 条「未通过审核」(Status=0 待审 / Status=2 驳回)，
        用于验证 Player Guides tab 计数只统计 Status=1，即显示 (6)。
        ItemID 关联到真实 WikiItem，使「当前页面对应攻略」视图有数据：
          alliances-bank / cities-durability / economy-market / wars-dominion / economy-gems
        第 1 条 ItemID 为 NULL（通用攻略），只在「查看全部」里出现。
        UserID 取自 UserInfo 中的真实账号，作者昵称可正常显示。
   ============================================================ */

SET NOCOUNT ON;

DECLARE @item_bank       INT = (SELECT ItemID FROM WikiItem WHERE ItemName = 'bank'       AND CategoryID = (SELECT CategoryID FROM WikiCategory WHERE CategoryName = 'alliances'));
DECLARE @item_durability INT = (SELECT ItemID FROM WikiItem WHERE ItemName = 'durability' AND CategoryID = (SELECT CategoryID FROM WikiCategory WHERE CategoryName = 'cities'));
DECLARE @item_market     INT = (SELECT ItemID FROM WikiItem WHERE ItemName = 'market'     AND CategoryID = (SELECT CategoryID FROM WikiCategory WHERE CategoryName = 'economy'));
DECLARE @item_gems       INT = (SELECT ItemID FROM WikiItem WHERE ItemName = 'gems'       AND CategoryID = (SELECT CategoryID FROM WikiCategory WHERE CategoryName = 'economy'));
DECLARE @item_dominion   INT = (SELECT ItemID FROM WikiItem WHERE ItemName = 'dominion'   AND CategoryID = (SELECT CategoryID FROM WikiCategory WHERE CategoryName = 'wars'));

-- 清理旧测试行（仅匹配本脚本插入的标题），保证可重复执行
DELETE FROM WikiPlayerGuide
 WHERE Title IN (
    N'First 7 Days: A New Commander Roadmap',
    N'Alliance Bank: Deposit, Withdraw & Allowances',
    N'City Defense: Durability vs. Garrison',
    N'Market Trading: Buy Low, Sell High',
    N'Dominion & Regional Wars Explained',
    N'Gems Without Spending: A F2P Guide',
    N'Draft: Advanced Air Force Tactics',
    N'Cheap Exploit Tricks'
 );

INSERT INTO WikiPlayerGuide
    (UserID, ItemID, Title, Summary, Content, Status, IsPinned, ViewCount, LikeCount, CreatedTime, PublishedTime, ReviewedBy, ReviewedTime)
VALUES
-- ===== 已审核（Status=1），tab 计数 = 6 =====
(184, NULL, N'First 7 Days: A New Commander Roadmap',
 N'What to prioritise in your first week — resources, cities and staying alive.',
 N'<h2>Day 1-2: Get established</h2><p>Claim a city with food and oil, complete the tutorial quests, and spend your starting gems on permanent production boosts rather than instant finishes.</p><h2>Day 3-5: Join an alliance</h2><p>Alliance membership unlocks bank allowances, territory and reinforcements. Pick an active alliance near your region.</p><h2>Day 6-7: Defend what you own</h2><p>Build durability before you expand. A second city is worthless if your capital falls.</p>',
 1, 1, 184, 42, DATEADD(DAY, -12, GETUTCDATE()), DATEADD(DAY, -12, GETUTCDATE()), 185, DATEADD(DAY, -11, GETUTCDATE())),

(186, @item_bank, N'Alliance Bank: Deposit, Withdraw & Allowances',
 N'How the alliance bank really works, and how to set fair withdrawal allowances.',
 N'<h2>Deposits</h2><p>Members donate to build the alliance capital and fund territory upkeep.</p><h2>Allowances</h2><p>Leaders set per-rank withdrawal limits. Keep them low for new members and raise them as trust grows.</p><h2>Tax discipline</h2><p>Territory collapses if the bank cannot cover taxes — always keep a reserve.</p>',
 1, 0, 96, 21, DATEADD(DAY, -10, GETUTCDATE()), DATEADD(DAY, -10, GETUTCDATE()), 185, DATEADD(DAY, -9, GETUTCDATE())),

(187, @item_durability, N'City Defense: Durability vs. Garrison',
 N'Balancing wall durability and defending armies so attackers give up.',
 N'<h2>Durability first</h2><p>Durability absorbs hits before your garrison takes losses. High durability buys time for allies to reinforce.</p><h2>Garrison mix</h2><p>A mixed garrison counters a wider range of attackers than stacking one unit type.</p><h2>Routes matter</h2><p>Control the routes into your city to force attackers through your strongest neighbours.</p>',
 1, 0, 143, 35, DATEADD(DAY, -8, GETUTCDATE()), DATEADD(DAY, -8, GETUTCDATE()), 185, DATEADD(DAY, -8, GETUTCDATE())),

(188, @item_market, N'Market Trading: Buy Low, Sell High',
 N'Practical market habits for steady resource income.',
 N'<h2>Watch the spread</h2><p>Buy when a resource floods the market after a big event, sell when everyone is rebuilding.</p><h2>Small frequent trades</h2><p>Many small margins beat waiting for one perfect flip.</p><h2>Avoid panic selling</h2><p>Prices recover — selling at the bottom is the most common mistake.</p>',
 1, 0, 78, 17, DATEADD(DAY, -6, GETUTCDATE()), DATEADD(DAY, -6, GETUTCDATE()), 185, DATEADD(DAY, -6, GETUTCDATE())),

(189, @item_dominion, N'Dominion & Regional Wars Explained',
 N'What dominion does, and how to contribute during a regional war.',
 N'<h2>Dominion</h2><p>Dominion projects your alliance control over a region and generates rewards over time.</p><h2>Regional war roles</h2><p>Not everyone must attack — holding key cities and reinforcing the front line wins wars.</p><h2>Timing</h2><p>Coordinated pushes at a set time beat scattered individual attacks.</p>',
 1, 0, 61, 12, DATEADD(DAY, -4, GETUTCDATE()), DATEADD(DAY, -4, GETUTCDATE()), 185, DATEADD(DAY, -4, GETUTCDATE())),

(191, @item_gems, N'Gems Without Spending: A F2P Guide',
 N'Every reliable free gem source and how to spend them wisely.',
 N'<h2>Free sources</h2><p>Daily login, level rewards, events and alliance milestones all grant gems over time.</p><h2>Spending priority</h2><p>Permanent upgrades &gt; convenience &gt; cosmetics.</p><h2>Be patient</h2><p>Saving for a large boost is far more efficient than many small impulse buys.</p>',
 1, 0, 205, 58, DATEADD(DAY, -2, GETUTCDATE()), DATEADD(DAY, -2, GETUTCDATE()), 185, DATEADD(DAY, -2, GETUTCDATE())),

-- ===== 未通过审核：不计入 tab 计数，也不出现在任何列表 =====
(190, NULL, N'Draft: Advanced Air Force Tactics',
 N'（待审核草稿）',
 N'<p>Work in progress — awaiting review.</p>',
 0, 0, 0, 0, DATEADD(DAY, -1, GETUTCDATE()), NULL, NULL, NULL),

(190, NULL, N'Cheap Exploit Tricks',
 N'（已驳回）',
 N'<p>Rejected: content violates the rules.</p>',
 2, 0, 0, 0, DATEADD(DAY, -1, GETUTCDATE()), NULL, 185, DATEADD(DAY, -1, GETUTCDATE()));

PRINT 'Seeded WikiPlayerGuide with 6 approved + 2 unapproved rows (ItemIDs linked).';
GO
