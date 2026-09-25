/* ============================================================
   Wiki 分类 / 子项 数据导入脚本
   数据来源：解析 E:\War\wiki\docs 目录
     - 一级文件夹名  -> WikiCategory.CategoryName
     - 文件夹下 *.md -> WikiItem.ItemName（去掉扩展名）
   说明：CategoryID / ItemID 为自增主键，用 SCOPE_IDENTITY() 关联，不写死 ID。
        SortOrder 按 10 递增。
   ============================================================ */

SET NOCOUNT ON;

/* ---------- 1. alliances ---------- */
INSERT INTO WikiCategory (CategoryName, SortOrder, IsActive) VALUES ('alliances', 10, 1);
DECLARE @c1 INT = SCOPE_IDENTITY();
INSERT INTO WikiItem (CategoryID, ItemName, SortOrder, IsActive) VALUES
 (@c1,'bank',10,1),(@c1,'capital',20,1),(@c1,'championship',30,1),(@c1,'diplomacy',40,1),
 (@c1,'hierarchy',50,1),(@c1,'level',60,1),(@c1,'overview',70,1),(@c1,'regional',80,1),
 (@c1,'rivalry',90,1),(@c1,'territory',100,1),(@c1,'wars',110,1);

/* ---------- 2. cities ---------- */
INSERT INTO WikiCategory (CategoryName, SortOrder, IsActive) VALUES ('cities', 20, 1);
DECLARE @c2 INT = SCOPE_IDENTITY();
INSERT INTO WikiItem (CategoryID, ItemName, SortOrder, IsActive) VALUES
 (@c2,'airports',10,1),(@c2,'attributes',20,1),(@c2,'durability',30,1),(@c2,'infrastructure',40,1),
 (@c2,'overview',50,1),(@c2,'request',60,1),(@c2,'routes',70,1);

/* ---------- 3. economy ---------- */
INSERT INTO WikiCategory (CategoryName, SortOrder, IsActive) VALUES ('economy', 30, 1);
DECLARE @c3 INT = SCOPE_IDENTITY();
INSERT INTO WikiItem (CategoryID, ItemName, SortOrder, IsActive) VALUES
 (@c3,'gems',10,1),(@c3,'gold',20,1),(@c3,'market',30,1),(@c3,'resources',40,1);

/* ---------- 4. general ---------- */
INSERT INTO WikiCategory (CategoryName, SortOrder, IsActive) VALUES ('general', 40, 1);
DECLARE @c4 INT = SCOPE_IDENTITY();
INSERT INTO WikiItem (CategoryID, ItemName, SortOrder, IsActive) VALUES
 (@c4,'newbie',10,1),(@c4,'playerlevel',20,1),(@c4,'updates',30,1);

/* ---------- 5. units ---------- */
INSERT INTO WikiCategory (CategoryName, SortOrder, IsActive) VALUES ('units', 50, 1);
DECLARE @c5 INT = SCOPE_IDENTITY();
INSERT INTO WikiItem (CategoryID, ItemName, SortOrder, IsActive) VALUES
 (@c5,'airforces',10,1),(@c5,'armies',20,1),(@c5,'missiles',30,1),(@c5,'navies',40,1);

/* ---------- 6. wars ---------- */
INSERT INTO WikiCategory (CategoryName, SortOrder, IsActive) VALUES ('wars', 60, 1);
DECLARE @c6 INT = SCOPE_IDENTITY();
INSERT INTO WikiItem (CategoryID, ItemName, SortOrder, IsActive) VALUES
 (@c6,'civilizations',10,1),(@c6,'combat',20,1),(@c6,'country',30,1),(@c6,'dominion',40,1);

/* ---------- 7. weapons ---------- */
INSERT INTO WikiCategory (CategoryName, SortOrder, IsActive) VALUES ('weapons', 70, 1);
DECLARE @c7 INT = SCOPE_IDENTITY();
INSERT INTO WikiItem (CategoryID, ItemName, SortOrder, IsActive) VALUES
 (@c7,'aircraft',10,1),(@c7,'firearm',20,1),(@c7,'missiles',30,1),(@c7,'overview',40,1),
 (@c7,'ships',50,1),(@c7,'tanks',60,1);

/* ============================================================
   合计：7 个分类，39 个子项
   注：assets（静态资源）与空的 getting-started 未纳入
   ============================================================ */
