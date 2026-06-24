local _locale = locale or ""
local _is_chinese = _locale == "zh" or _locale == "zhs" or _locale == "zht"
                 or _locale == "schinese" or _locale == "tchinese"

name = _is_chinese and "橘子的超级管理员" or "Admin Panel"

if _is_chinese then
description = [[
服务器管理员专用面板，快捷管理在线玩家。
【打开方式】
屏幕顶部「管理员面板」按钮（仅管理员可见）
【玩家管理】
· 显示所有在线玩家：角色头像、玩家名、Klei ID
· 实时三维属性（生命/饥饿/理智），数据来自服务端
· 一键复活幽灵玩家
· 一键全满（生命、饥饿、理智恢复至满值）
【物品管理】
· 查看任意玩家的装备、物品栏、背包
· 左键拿取全部 / Ctrl+左键拿取一半 / 右键拿取1个
· 手持物品点击槽位可给予目标玩家
· 装备栏物品仅可查看，不可拿取
· 角色专属物品受保护（如Lucy斧、阿比盖尔花、伯尼、灵魂等）
【跨世界支持】
· 支持查看和操作不同世界的玩家（地面/洞穴）
· 跨世界复活、全满、物品拿取/给予均可正常使用
【隐藏管理图标】
· 隐藏TAB记分板与选人界面中的管理员图标
]]
else
description = [[
An exclusive admin panel for server administrators to manage online players efficiently.
[How to Open]
Click the "Admin Panel" button at the top of the screen (visible to admins only).
[Player Management]
· Displays all online players: character portrait, name, and Klei ID
· Real-time stats (HP / Hunger / Sanity) fetched from the server
· One-click revive for ghost players
· One-click full restore (HP, Hunger, and Sanity to max)
· Scrollbar appears automatically when there are many players
[Item Management]
· View equipment, inventory, and backpack of any player
· Left-click: take all | Ctrl+Left-click: take half | Right-click: take 1
· Click a slot while holding an item to give it to the target player
· Equipment slots are view-only and cannot be taken
[Cross-Shard Support]
· Supports viewing and managing players across different shards (surface / caves)
· Cross-shard revive, full restore, and item transfer all work normally
[Hidden Admin Badge]
· Hides the admin badge in the TAB scoreboard and character select screen
]]
end
author = "我给你们去买橘子♡"
version = "1.3.1"

api_version = 10              -- DST mod API 版本，固定填 10
dst_compatible = true         -- 兼容 Don't Starve Together 多人模式
all_clients_require_mod = true  -- 所有进入服务器的客户端均需安装此 mod（含服务端逻辑）
client_only_mod = false       -- 非纯客户端 mod，服务端也会加载

icon_atlas = "modicon.xml"    -- mod 图标 atlas 索引文件
icon = "modicon.tex"          -- mod 图标贴图文件

configuration_options = {
    {
        name    = "allow_view_inv",
        label   = _is_chinese and "查看其他玩家物品" or "Members View Inventory",
        hover   = _is_chinese
            and "开启后，所有玩家均可右键查看其他玩家物品栏（管理员面板/复活仍仅管理员可用）"
            or  "Allow all players to right-click view others' inventory (Admin panel & revive remain admin-only)",
        options = {
            {description = _is_chinese and "仅管理员" or "Admin Only", data = false},
            {description = _is_chinese and "所有人"   or "Everyone",   data = true },
        },
        default = false,
    },
    {
        name    = "allow_take_give",
        label   = _is_chinese and "拿取/存放其他玩家物品" or "Members Take/Give Items",
        hover   = _is_chinese
            and "开启后，所有玩家均可从其他玩家物品面板拿取或存放物品（需同时开启查看权限）"
            or  "Allow all players to take/give items via item panel (requires View permission enabled too)",
        options = {
            {description = _is_chinese and "仅管理员" or "Admin Only", data = false},
            {description = _is_chinese and "所有人"   or "Everyone",   data = true },
        },
        default = false,
    },
    {
        name    = "allow_admin_hp_revive",
        label   = _is_chinese and "管理员面板启用满血/复活按钮" or "Enable Full/Revive In Admin Panel",
        hover   = _is_chinese
            and "关闭后，管理员面板玩家列表中的“全满”“复活”按钮将隐藏"
            or  "When disabled, the 'Full' and 'Revive' buttons in player rows are hidden",
        options = {
            {description = _is_chinese and "显示" or "Show", data = true},
            {description = _is_chinese and "隐藏" or "Hide", data = false},
        },
        default = true,
    },
}

