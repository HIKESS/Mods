-- ========== 物品交互 Widget（HUD内嵌，支持拿取/给予）==========

local function GetCursorItem()
    local ok, item = GLOBAL.pcall(function()
        return GLOBAL.ThePlayer and GLOBAL.ThePlayer.replica
            and GLOBAL.ThePlayer.replica.inventory
            and GLOBAL.ThePlayer.replica.inventory:GetActiveItem()
    end)
    if ok then return item end
    return nil
end

local ITEM_ICON_ALIASES = {
    npc_rainbow_fireflies = "fireflies",
}

-- 装备槽位中文标签
local EQUIP_LABELS = {head = T("slot_head"), body = T("slot_body"), hands = T("slot_hands")}

-- 物品交互面板
ItemViewScreen = GLOBAL.Class(Widget, function(self, equips, invitems, backpack, target_name, target_userid, cap_info, is_offline_snapshot)
    Widget._ctor(self, "ItemViewWidget")

    self.target_userid = target_userid or ""
    self.is_offline_snapshot = (is_offline_snapshot == true)
    self._killed = false
    -- NPC 伙伴标记：装备槽允许交互（取出/装备）
    self.is_npc = (self.target_userid ~= "" and self.target_userid:sub(1, 4) == "npc:")
    cap_info = cap_info or {inv_maxslots = 15, equip_slots = {"body", "hands", "head"}, bp_numslots = 0}

    -- 参数
    local SLOT_SCALE = 0.75
    local SLOT_SPACING = 52
    local SLOTS_PER_ROW = 8
    local SECTION_HEADER_H = 30
    local ROW_H = SLOT_SPACING + 4

    local equip_by_key = {}
    for _, item in ipairs(equips or {}) do
        equip_by_key[item.slot_key] = item
    end
    local inv_by_slot = {}
    for _, item in ipairs(invitems or {}) do
        local sn = GLOBAL.tonumber(item.slot_key)
        if sn then inv_by_slot[sn] = item end
    end
    local bp_by_slot = {}
    for _, item in ipairs(backpack or {}) do
        local sn = GLOBAL.tonumber(item.slot_key)
        if sn then bp_by_slot[sn] = item end
    end

    -- 计算面板尺寸
    local n_equip = #(cap_info.equip_slots or {})
    local n_inv = cap_info.inv_maxslots or 15
    local n_bp = cap_info.bp_numslots or 0

    local function CalcRows(n) return n > 0 and math.ceil(n / SLOTS_PER_ROW) or 0 end
    local equip_rows = CalcRows(n_equip)
    local inv_rows = CalcRows(n_inv)
    local bp_rows = CalcRows(n_bp)

    local equip_h = n_equip > 0 and (SECTION_HEADER_H + equip_rows * ROW_H) or 0
    local inv_h = SECTION_HEADER_H + inv_rows * ROW_H
    local bp_h = n_bp > 0 and (SECTION_HEADER_H + bp_rows * ROW_H) or 0

    local content_h = equip_h + inv_h + bp_h
    local panel_h = math.max(200, content_h + 100)
    local panel_w = SLOTS_PER_ROW * SLOT_SPACING + 80

    -- 面板背景
    self.panel_bg = self:AddChild(Image("images/scoreboard.xml", "scoreboard_frame.tex"))
    self.panel_bg:ScaleToSize(panel_w, panel_h)

    -- 标题
    self.title = self:AddChild(Text(GLOBAL.TITLEFONT, 30, GLOBAL.tostring(target_name) .. T("title_items_suffix")))
    self.title:SetPosition(0, panel_h / 2 - 25)
    self.title:SetColour(1, 0.8, 0.3, 1)

    -- 操作提示
    local tip = self:AddChild(Text(GLOBAL.CHATFONT, 16, T("tip_items")))
    tip:SetPosition(0, panel_h / 2 - 48)
    tip:SetColour(0.6, 0.6, 0.6, 1)

    -- 关闭按钮
    self.close_btn = self:AddChild(ImageButton("images/global_redux.xml", "close.tex"))
    self.close_btn:SetPosition(panel_w / 2 - 25, panel_h / 2 - 25)
    self.close_btn:SetScale(0.5)
    self.close_btn:SetOnClick(function()
        local hud = GLOBAL.ThePlayer and GLOBAL.ThePlayer.HUD
        if hud then
            hud._dstadmin_ui_suppress = hud._dstadmin_ui_suppress or {}
            hud._dstadmin_ui_suppress.item_until = (GLOBAL.GetTime() or 0) + 0.8
            hud._dstadmin_ui_suppress.item_target_userid = self.target_userid or ""
        end
        if hud then hud.dst_admin_itemview = nil end
        self:Kill()
    end)

    -- NPC 物品 UI 专属：右下角"解除跟随"按钮（已移至左键状态面板，暂时注释保留）
    -- if self.is_npc then
    --     local dismiss_btn = self:AddChild(ImageButton("images/global_redux.xml", "button_carny_long_normal.tex",
    --         "button_carny_long_hover.tex", "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
    --     dismiss_btn:ForceImageSize(107, 34)
    --     dismiss_btn:SetPosition(panel_w / 2 - 100, panel_h / 2 - 90)
    --     dismiss_btn:SetText(T("btn_dismiss"))
    --     dismiss_btn:SetFont(GLOBAL.CHATFONT)
    --     dismiss_btn:SetTextSize(20)
    --     dismiss_btn.scale_on_focus = false
    --     dismiss_btn:SetOnClick(function()
    --         local owner_param = self.target_userid:match("^npc:(.+)$") or ""
    --         if owner_param ~= "" then
    --             GLOBAL.pcall(function()
    --                 SendModRPCToServer(GetModRPC("NPCFriends", "DismissNPC"), owner_param)
    --             end)
    --         end
    --         local hud = GLOBAL.ThePlayer and GLOBAL.ThePlayer.HUD
    --         if hud then hud.dst_admin_itemview = nil end
    --         self:Kill()
    --     end)
    -- end

    -- 内容区
    local content = self:AddChild(Widget("content"))
    local cur_y = panel_h / 2 - 70

    -- 拿取物品
    local function DoTake(item, amount, mode, prefab_hint, count_hint)
        if not item or self.target_userid == "" then return end
        local params = self.target_userid .. "|" .. (item.slot_type or "I") .. "|" .. (item.slot_key or "1") .. "|" .. tostring(amount) .. "|" .. tostring(mode or "")
            .. "|" .. tostring(prefab_hint or "") .. "|" .. tostring(count_hint or 0)
            .. "|" .. tostring(self.is_offline_snapshot and "1" or "0")
        GLOBAL.pcall(function()
            SendModRPCToServer(GetModRPC("DstAdmin", "AdminTakeItem"), params)
        end)
        self._suspend_refresh_until = (GLOBAL.GetTime and GLOBAL.GetTime() or 0) + 1.0

        if self.is_npc then
            GLOBAL.pcall(function()
                local az = GLOBAL.rawget(GLOBAL, "DSTADMIN_ALLOW_BP_ZERO")
                if type(az) ~= "table" then
                    az = {}
                    GLOBAL.rawset(GLOBAL, "DSTADMIN_ALLOW_BP_ZERO", az)
                end
                az[self.target_userid] = (GLOBAL.GetTime and GLOBAL.GetTime() or 0) + 3
            end)
        end
    end

    local function DoGiveToSlot(s_type, s_key)
        if self.target_userid == "" then return end
        GLOBAL.pcall(function()
            local params = self.target_userid .. "|" .. s_type .. "|" .. s_key .. "|" .. tostring(self.is_offline_snapshot and "1" or "0")
            SendModRPCToServer(GetModRPC("DstAdmin", "AdminGiveToSlot"), params)
        end)
        self._suspend_refresh_until = (GLOBAL.GetTime and GLOBAL.GetTime() or 0) + 1.0
    end

    local function DoQuickGiveStack()
        if self.target_userid == "" then return end
        GLOBAL.pcall(function()
            SendModRPCToServer(GetModRPC("DstAdmin", "AdminGiveFromCursor"),
                self.target_userid .. "|" .. tostring(self.is_offline_snapshot and "1" or "0"))
        end)
        self._suspend_refresh_until = (GLOBAL.GetTime and GLOBAL.GetTime() or 0) + 1.0
    end

    local function MakeSlot(parent, item, slot_type, slot_key, x, y, label_text)
        local slot = parent:AddChild(ImageButton("images/hud.xml", "inv_slot.tex"))
        slot:SetPosition(x, y)
        slot:SetScale(SLOT_SCALE)
        slot.scale_on_focus = false

        -- 悬停放大
        local _ongf = slot.OnGainFocus
        slot.OnGainFocus = function(s)
            if _ongf then _ongf(s) end
            s:SetScale(SLOT_SCALE * 1.15)
        end
        local _onlf = slot.OnLoseFocus
        slot.OnLoseFocus = function(s)
            if _onlf then _onlf(s) end
            s:SetScale(SLOT_SCALE)
        end

        if item then
            GLOBAL.pcall(function()
                local icon_name = item.image or ITEM_ICON_ALIASES[item.prefab] or item.prefab
                local img_name = icon_name .. ".tex"
                local atlas = item.atlas or GLOBAL.GetInventoryItemAtlas(img_name)
                if atlas then
                    local img = slot:AddChild(Image(atlas, img_name))
                    img:SetClickable(false)
                end
            end)
            if item.count > 1 then
                local ct = slot:AddChild(Text(GLOBAL.NUMBERFONT, 36, tostring(item.count)))
                ct:SetPosition(2, 17) -- 第二个参数是Y轴，负数偏下，正数偏上
                ct:SetClickable(false)
            end
            slot:SetHoverText(item.name .. (item.count > 1 and (" x" .. item.count) or ""))
        else
            -- 空槽位标签（装备槽显示部位名）
            if label_text then
                local lbl = slot:AddChild(Text(GLOBAL.CHATFONT, 24, label_text))
                lbl:SetColour(0.5, 0.5, 0.5, 0.7)
                lbl:SetClickable(false)
            end
        end

        slot:SetOnClick(function()
            if slot_type == "E" and not self.is_npc then return end
            local cursor = GetCursorItem()
            if cursor then
                local shift = GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_SHIFT)
                if shift and (not self.is_npc) then
                    DoQuickGiveStack()
                    return
                end
                if item and item.untakeable and not self.is_npc then
                    return
                end
                DoGiveToSlot(slot_type, slot_key)
            elseif item then
                if item.untakeable and not self.is_npc then
                    return
                end
                local shift = GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_SHIFT)
                if shift then
                    DoTake(item, 0, "bag", item.prefab, item.count) -- Shift+左键：整组快速取出到玩家背包
                    return
                end
                local ctrl = GLOBAL.TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_STACK)
                DoTake(item, ctrl and math.ceil(item.count / 2) or 0)
            end
        end)

        local _base_oc = slot.OnControl
        slot.OnControl = function(s, control, down)
            if control == GLOBAL.CONTROL_SECONDARY then
                if (slot_type ~= "E" or self.is_npc)
                    and down and item and (not item.untakeable or self.is_npc)
                    and not GetCursorItem() then
                    DoTake(item, 1)
                end
                return true
            end
            if _base_oc then return _base_oc(s, control, down) end
            return false
        end

        return slot
    end

    -- 渲染装备区（固定槽位）
    if n_equip > 0 then
        local header = content:AddChild(Text(GLOBAL.UIFONT, 22, T("sec_equip")))
        header:SetPosition(-panel_w / 2 + 110, cur_y + 10)
        header:SetColour(1, 1, 1, 1)
        header:SetHAlign(GLOBAL.ANCHOR_LEFT)
        header:SetRegionSize(120, 26)
        cur_y = cur_y - SECTION_HEADER_H

        local total_w = SLOTS_PER_ROW * SLOT_SPACING
        local base_x = -total_w / 2 + SLOT_SPACING / 2
        for i, eslot in ipairs(cap_info.equip_slots) do
            local col = (i - 1) % SLOTS_PER_ROW
            local row = math.floor((i - 1) / SLOTS_PER_ROW)
            local sx = base_x + col * SLOT_SPACING
            local sy = cur_y - row * ROW_H
            local item = equip_by_key[eslot]
            MakeSlot(content, item, "E", eslot, sx, sy, EQUIP_LABELS[eslot] or eslot)
        end

        -- NPC 专属：在装备栏右侧放置“装备背包”按钮
        local HIDDEN_BACKPACK_CHARS = { wormwood = true, warly = true, wes = true, winona = true, wilba = true}
        local npc_char_type = nil
        do
            local op_for_char = self.target_userid:match("^npc:(.+)$") or ""
            local segs = {}
            for s in op_for_char:gmatch("[^:]+") do segs[#segs + 1] = s end
            npc_char_type = segs[2]  
        end
        if self.is_npc and not (npc_char_type and HIDDEN_BACKPACK_CHARS[npc_char_type]) then
            GLOBAL.pcall(function()
                local EQUIP_BTN_GAP   = 20                -- 与最后一个装备槽的水平间距(px)，可调
                local SLOT_RENDER_W   = 64 * SLOT_SCALE   -- 装备槽视觉宽度
                local BP_BTN_W        = 32                -- 背包按钮尺寸
                local last_equip_x    = base_x + (n_equip - 1) * SLOT_SPACING
                local bx = last_equip_x + SLOT_RENDER_W / 2 + EQUIP_BTN_GAP + BP_BTN_W / 2

                local bp_atlas = GLOBAL.GetInventoryItemAtlas("backpack.tex")
                local equip_bp_btn = content:AddChild(ImageButton(bp_atlas, "backpack.tex"))
                equip_bp_btn:SetPosition(bx, cur_y)
                equip_bp_btn:ForceImageSize(BP_BTN_W, BP_BTN_W)
                equip_bp_btn.ignore_standard_scaling = true  
                equip_bp_btn:SetFocusScale(1.1, 1.1, 1.1) 
                equip_bp_btn:SetHoverText(T("btn_equip_backpack"))
                equip_bp_btn:SetOnClick(function()
                    local op = self.target_userid:match("^npc:(.+)$")
                    if not op or op == "" then return end
                    local ok, UiModes = GLOBAL.pcall(GLOBAL.require, "npc_ui_modes")
                    if not (ok and UiModes and UiModes.StartEquipBackpackMode) then return end
                    UiModes.StartEquipBackpackMode(op)
                    -- 关闭面板，便于点击地面；短时间抑制自动重开
                    local hud = GLOBAL.ThePlayer and GLOBAL.ThePlayer.HUD
                    if hud then
                        hud._dstadmin_ui_suppress = hud._dstadmin_ui_suppress or {}
                        hud._dstadmin_ui_suppress.item_until = (GLOBAL.GetTime() or 0) + 3
                        hud._dstadmin_ui_suppress.item_target_userid = self.target_userid or ""
                        hud.dst_admin_itemview = nil
                    end
                    self:Kill()
                end)
            end)
        end

        cur_y = cur_y - equip_rows * ROW_H - 6
    end

    -- 渲染物品栏（固定槽位）
    do
        local header = content:AddChild(Text(GLOBAL.UIFONT, 22, T("sec_inv")))
        header:SetPosition(-panel_w / 2 + 110, cur_y + 10)
        header:SetColour(1, 1, 1, 1)
        header:SetHAlign(GLOBAL.ANCHOR_LEFT)
        header:SetRegionSize(120, 26)
        cur_y = cur_y - SECTION_HEADER_H

        local total_w = SLOTS_PER_ROW * SLOT_SPACING
        local base_x = -total_w / 2 + SLOT_SPACING / 2
        for i = 1, n_inv do
            local col = (i - 1) % SLOTS_PER_ROW
            local row = math.floor((i - 1) / SLOTS_PER_ROW)
            local sx = base_x + col * SLOT_SPACING
            local sy = cur_y - row * ROW_H
            MakeSlot(content, inv_by_slot[i], "I", tostring(i), sx, sy, nil)
        end
        cur_y = cur_y - inv_rows * ROW_H - 6
    end

    -- 渲染背包（固定槽位，仅当有背包时）
    if n_bp > 0 then
        local header = content:AddChild(Text(GLOBAL.UIFONT, 22, T("sec_bag")))
        header:SetPosition(-panel_w / 2 + 110, cur_y + 10)
        header:SetColour(1, 1, 1, 1)
        header:SetHAlign(GLOBAL.ANCHOR_LEFT)
        header:SetRegionSize(120, 26)
        cur_y = cur_y - SECTION_HEADER_H

        local total_w = SLOTS_PER_ROW * SLOT_SPACING
        local base_x = -total_w / 2 + SLOT_SPACING / 2
        for i = 1, n_bp do
            local col = (i - 1) % SLOTS_PER_ROW
            local row = math.floor((i - 1) / SLOTS_PER_ROW)
            local sx = base_x + col * SLOT_SPACING
            local sy = cur_y - row * ROW_H
            MakeSlot(content, bp_by_slot[i], "B", tostring(i), sx, sy, nil)
        end
    end

    -- 每1秒自动刷新一次（仅面板打开时生效）
    self.auto_refresh_task = GLOBAL.ThePlayer:DoPeriodicTask(1, function()
        if not self._killed then
            local now = GLOBAL.GetTime and GLOBAL.GetTime() or 0
            if not self._suspend_refresh_until or now >= self._suspend_refresh_until then
                GLOBAL.pcall(function()
                    if self.is_npc then
                        local owner_userid = self.target_userid:sub(5)
                        SendModRPCToServer(GetModRPC("DstAdmin", "RequestNPCInventory"), owner_userid)
                    elseif self.is_offline_snapshot then
                        SendModRPCToServer(GetModRPC("DstAdmin", "RequestOfflineInventory"), self.target_userid)
                    else
                        SendModRPCToServer(GetModRPC("DstAdmin", "RequestInventory"), self.target_userid)
                    end
                end)
            end
        end
    end)

    local _base_kill = self.Kill
    self.Kill = function(s)
        s._killed = true
        if s.auto_refresh_task then
            s.auto_refresh_task:Cancel()
            s.auto_refresh_task = nil
        end
        if _base_kill then _base_kill(s) end
    end
end)
