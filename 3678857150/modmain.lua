-- ================================================
-- 管理员面板 (Admin Panel)
-- ================================================

-- Widget 类引用（全局变量）
Screen = GLOBAL.require "widgets/screen"
Widget = GLOBAL.require "widgets/widget"
Text = GLOBAL.require "widgets/text"
Image = GLOBAL.require "widgets/image"
ImageButton = GLOBAL.require "widgets/imagebutton"
TextButton = GLOBAL.require "widgets/textbutton"
PlayerBadge = GLOBAL.require "widgets/playerbadge"
ScrollableList = GLOBAL.require "widgets/scrollablelist"

-- 按依赖顺序加载子模块
-- i18n 最先：翻译函数 T() 供所有模块使用
-- server_utils 第二：服务端工具函数供 rpc_handlers 调用
-- itemviewscreen 第三：物品面板控件供 rpc_handlers 中 ReceiveInventory 实例化
-- rpc_handlers 第四：注册所有 RPC 处理器
-- adminpanelscreen 第五：管理员面板 Screen（依赖 RPC 已注册）
-- hooks 最后：注入 HUD 按钮、右键拦截、图标隐藏（依赖面板类已定义）

DSTADMIN_ALLOW_VIEW_INV  = GetModConfigData("allow_view_inv")  == true  -- 普通成员是否可查看物品栏
DSTADMIN_ALLOW_TAKE_GIVE = GetModConfigData("allow_take_give") == true  -- 普通成员是否可拿取/存放物品
DSTADMIN_ALLOW_ADMIN_HP_REVIVE = GetModConfigData("allow_admin_hp_revive") ~= false -- 管理员面板“全满/复活”按钮总开关（默认开）
GLOBAL.rawset(GLOBAL, "DSTADMIN_ALLOW_ADMIN_HP_REVIVE", DSTADMIN_ALLOW_ADMIN_HP_REVIVE)

modimport("scripts/i18n.lua")
modimport("scripts/server_utils.lua")
modimport("scripts/offline_player_store.lua")
modimport("scripts/screens/itemviewscreen.lua")
modimport("scripts/screens/npcrangeoverlay.lua")
modimport("scripts/screens/npcstatusscreen.lua")
modimport("scripts/screens/npcaffinityscreen.lua")
modimport("scripts/screens/npcskinpopup.lua")
modimport("scripts/screens/npcrifttravelscreen.lua")
modimport("scripts/rpc_handlers.lua")
modimport("scripts/screens/adminpanelscreen.lua")
modimport("scripts/hooks.lua")

-- 调试开关（控制台）：

if GLOBAL and GLOBAL.rawset then
    GLOBAL.rawset(GLOBAL, "dstadmin_offline_debug", function(enabled)
        local v = (enabled == true)
        GLOBAL.rawset(GLOBAL, "DSTADMIN_OFFLINE_DEBUG", v)
        print("[DstAdmin] DSTADMIN_OFFLINE_DEBUG = " .. tostring(v))
    end)
    GLOBAL.rawset(GLOBAL, "dstadmin_npc_ui_debug", function(enabled)
        local v = (enabled == true)
        GLOBAL.rawset(GLOBAL, "DSTADMIN_NPC_UI_DEBUG", v)
        print("[DstAdmin] dstadmin_npc_ui_debug is deprecated, value=" .. tostring(v))
    end)
    -- 清理某离线玩家的待结算队列（用于修复历史重复结算污染）
    GLOBAL.rawset(GLOBAL, "dstadmin_offline_clear_pending", function(userid)
        local fn = GLOBAL.rawget and GLOBAL.rawget(GLOBAL, "DSTADMIN_OFFLINE_STORE_ClearPending")
        if not fn then
            print("[DstAdmin] clear pending failed: function missing")
            return
        end
        local ok = fn(userid)
        print("[DstAdmin] clear pending " .. tostring(userid) .. " => " .. tostring(ok))
    end)
    -- 跨 shard 离线写操作后的“额外强制保存”开关（默认 off）

    GLOBAL.rawset(GLOBAL, "dstadmin_offline_force_save_mode", function(mode)
        local m = tostring(mode or "off")
        if m ~= "on" then m = "off" end
        GLOBAL.rawset(GLOBAL, "DSTADMIN_OFFLINE_FORCE_SAVE_MODE", m)
        print("[DstAdmin] DSTADMIN_OFFLINE_FORCE_SAVE_MODE = " .. tostring(m))
    end)
end
