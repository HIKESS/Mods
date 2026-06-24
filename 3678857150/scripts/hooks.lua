-- ========== HUD 按钮注入（仅管理员可见）==========
local Widget = GLOBAL.require("widgets/widget")
local Text = GLOBAL.require("widgets/text")

local DSTADMIN_BTN_POS_KEY = "dstadmin_admin_btn_pos_v1"
local DSTADMIN_BTN_DEFAULT_X, DSTADMIN_BTN_DEFAULT_Y = 0, -50
local DSTADMIN_BTN_SCALE_NORMAL = 1
local DSTADMIN_BTN_SCALE_HOVER = 1.2
local DSTADMIN_BTN_SCALE_TIME = 0.5
local DSTADMIN_BTN_SCALE_MIN = 0.8
local DSTADMIN_BTN_SCALE_MAX = 1.25

local function _LoadAdminBtnPos(cb)
    if not (GLOBAL.TheSim and GLOBAL.TheSim.GetPersistentString) then
        cb(DSTADMIN_BTN_DEFAULT_X, DSTADMIN_BTN_DEFAULT_Y)
        return
    end
    GLOBAL.TheSim:GetPersistentString(DSTADMIN_BTN_POS_KEY, function(success, data)
        local x, y = DSTADMIN_BTN_DEFAULT_X, DSTADMIN_BTN_DEFAULT_Y
        if success and type(data) == "string" then
            local sx, sy = data:match("^([%-%d%.]+)|([%-%d%.]+)$")
            if sx and sy then
                x = GLOBAL.tonumber(sx) or x
                y = GLOBAL.tonumber(sy) or y
            end
        end
        cb(x, y)
    end)
end

local function _SaveAdminBtnPos(x, y)
    if GLOBAL.TheSim and GLOBAL.TheSim.SetPersistentString then
        local payload = tostring(x or DSTADMIN_BTN_DEFAULT_X) .. "|" .. tostring(y or DSTADMIN_BTN_DEFAULT_Y)
        GLOBAL.TheSim:SetPersistentString(DSTADMIN_BTN_POS_KEY, payload, false)
    end
end

local function _SetButtonAlpha(btn, a)
    if not btn then return end
    if btn.SetImageNormalColour and btn.SetImageFocusColour then
        -- ImageButton 的标准着色接口，优先保证图标透明度生效
        btn:SetImageNormalColour(1, 1, 1, a)
    end
    if btn.image and btn.image.SetTint then
        btn.image:SetTint(1, 1, 1, a)
    end
    if btn.SetTint then
        btn:SetTint(1, 1, 1, a)
    elseif btn.SetColor then
        btn:SetColor(1, 1, 1, a)
    elseif btn.SetColour then
        btn:SetColour(1, 1, 1, a)
    end
end

AddClassPostConstruct("widgets/controls", function(self)
    self.owner:DoTaskInTime(0, function()
        if not GLOBAL.TheNet:GetIsServerAdmin() then return end
        local ui_root = self:AddChild(Widget("dstadmin_admin_overlay_root"))
        ui_root:SetScaleMode(GLOBAL.SCALEMODE_PROPORTIONAL)
        ui_root:SetHAnchor(GLOBAL.ANCHOR_MIDDLE)
        ui_root:SetVAnchor(GLOBAL.ANCHOR_TOP)
        if ui_root.SetMaxPropUpscale and GLOBAL.MAX_HUD_SCALE then
            ui_root:SetMaxPropUpscale(GLOBAL.MAX_HUD_SCALE)
        end
        local top_scale = self.top_root and self.top_root:GetScale() and self.top_root:GetScale().x or 1
        ui_root:SetScale(top_scale)
        if self.inst and self.owner and self.owner.HUD and self.owner.HUD.inst then
            self.inst:ListenForEvent("refreshhudsize", function(_, scale)
                ui_root:SetScale(scale or 1)
            end, self.owner.HUD.inst)
        end
        ui_root:MoveToFront()

        local holder = ui_root:AddChild(Widget("dstadmin_admin_btn_holder"))
        local btn = holder:AddChild(ImageButton(
            "images/avatars.xml",
            "avatar_admin.tex",
            "avatar_admin.tex",
            "avatar_admin.tex",
            "avatar_admin.tex"
        ))
        btn:ForceImageSize(48, 48)
        btn:SetScale(DSTADMIN_BTN_SCALE_NORMAL, DSTADMIN_BTN_SCALE_NORMAL, 1)
        btn.scale_on_focus = false
        btn.move_on_click = false
        _SetButtonAlpha(btn, 0.7) -- 默认半透明

        local hover_label = holder:AddChild(Text(GLOBAL.CHATFONT, 22, T("btn_panel")))
        hover_label:SetPosition(0, 42)
        hover_label:SetColour(1, 1, 1, 1)
        hover_label:Hide()

        local dragging = false
        local did_drag = false
        local start_mouse_x, start_mouse_y = 0, 0
        local start_btn_x, start_btn_y = DSTADMIN_BTN_DEFAULT_X, DSTADMIN_BTN_DEFAULT_Y
        local scale_tween_task = nil
        local scale_tween_token = 0

        local function _StopScaleTween(force_scale)
            scale_tween_token = scale_tween_token + 1
            if scale_tween_task then
                scale_tween_task:Cancel()
                scale_tween_task = nil
            end
            if btn and btn.inst and btn.inst:IsValid() and force_scale ~= nil then
                force_scale = GLOBAL.math.max(DSTADMIN_BTN_SCALE_MIN, GLOBAL.math.min(DSTADMIN_BTN_SCALE_MAX, force_scale))
                btn:SetScale(force_scale, force_scale, 1)
            end
        end

        local function _StartScaleTween(target_scale)
            if not (btn and btn.inst and btn.inst:IsValid()) then return end
            _StopScaleTween(nil)
            target_scale = GLOBAL.math.max(DSTADMIN_BTN_SCALE_MIN, GLOBAL.math.min(DSTADMIN_BTN_SCALE_MAX, target_scale))

            local from_scale = DSTADMIN_BTN_SCALE_NORMAL
            if btn.GetScale then
                local s = btn:GetScale()
                from_scale = (s and s.x) or from_scale
            end
            from_scale = GLOBAL.math.max(DSTADMIN_BTN_SCALE_MIN, GLOBAL.math.min(DSTADMIN_BTN_SCALE_MAX, from_scale))
            if GLOBAL.math.abs(from_scale - target_scale) <= 0.001 then
                btn:SetScale(target_scale, target_scale, 1)
                return
            end

            local my_token = scale_tween_token
            local elapsed = 0
            local duration = GLOBAL.math.max(DSTADMIN_BTN_SCALE_TIME, GLOBAL.FRAMES)
            scale_tween_task = btn.inst:DoPeriodicTask(0, function()
                if my_token ~= scale_tween_token then return end
                elapsed = elapsed + GLOBAL.FRAMES
                local t = elapsed / duration
                if t > 1 then t = 1 end
                -- 平滑缓动（ease-out）
                local e = 1 - (1 - t) * (1 - t)
                local cur = from_scale + (target_scale - from_scale) * e
                cur = GLOBAL.math.max(DSTADMIN_BTN_SCALE_MIN, GLOBAL.math.min(DSTADMIN_BTN_SCALE_MAX, cur))
                btn:SetScale(cur, cur, 1)
                if t >= 1 then
                    _StopScaleTween(target_scale)
                end
            end)
        end

        local function ClampPos(nx, ny)
            local sw, sh = GLOBAL.TheSim:GetScreenSize()
            local margin = 32
            local sx = ui_root and ui_root:GetScale() and ui_root:GetScale().x or 1
            local sy = ui_root and ui_root:GetScale() and ui_root:GetScale().y or 1
            if sx == 0 then sx = 1 end
            if sy == 0 then sy = 1 end
            local half_w = (sw * 0.5 - margin) / sx
            -- ui_root 是顶部锚点：Y 轴应按“从顶部到屏幕底部”限制，而不是中心对称限制
            local min_y = -(sh - margin) / sy
            local max_y = -margin / sy
            nx = GLOBAL.math.max(-half_w, GLOBAL.math.min(half_w, nx))
            ny = GLOBAL.math.max(min_y, GLOBAL.math.min(max_y, ny))
            return nx, ny
        end

        btn:SetOnDown(function()
            dragging = true
            did_drag = false
            ui_root:MoveToFront()
            holder:MoveToFront()
            start_mouse_x = GLOBAL.TheFrontEnd.lastx or 0
            start_mouse_y = GLOBAL.TheFrontEnd.lasty or 0
            start_btn_x, start_btn_y = holder:GetPosition():Get()
            GLOBAL.TheFrontEnd:LockFocus(true)
        end)

        btn:SetWhileDown(function()
            if not dragging then return end
            local mx = GLOBAL.TheFrontEnd.lastx or start_mouse_x
            local my = GLOBAL.TheFrontEnd.lasty or start_mouse_y
            local sx = ui_root and ui_root:GetScale() and ui_root:GetScale().x or 1
            local sy = ui_root and ui_root:GetScale() and ui_root:GetScale().y or 1
            if sx == 0 then sx = 1 end
            if sy == 0 then sy = 1 end
            local dx = (mx - start_mouse_x) / sx
            local dy = (my - start_mouse_y) / sy
            if not did_drag and GLOBAL.math.abs(dx) <= 2 and GLOBAL.math.abs(dy) <= 2 then
                return
            end
            did_drag = true
            local nx, ny = ClampPos(start_btn_x + dx, start_btn_y + dy)
            holder:SetPosition(nx, ny)
        end)

        btn:SetOnClick(function()
            dragging = false
            GLOBAL.TheFrontEnd:LockFocus(false)
            local px, py = holder:GetPosition():Get()
            _SaveAdminBtnPos(px, py)
            if not did_drag then
                GLOBAL.TheFrontEnd:PushScreen(AdminPanelScreen(self.owner))
            end
        end)

        btn:SetOnGainFocus(function()
            ui_root:MoveToFront()
            holder:MoveToFront()
            if btn.SetImageFocusColour then
                btn:SetImageFocusColour(1, 1, 1, 1)
            end
            _StartScaleTween(DSTADMIN_BTN_SCALE_HOVER)
            _SetButtonAlpha(btn, 1)
            hover_label:Show()
        end)
        btn:SetOnLoseFocus(function()
            if btn.SetImageNormalColour then
                btn:SetImageNormalColour(1, 1, 1, 0.7)
            end
            _StartScaleTween(DSTADMIN_BTN_SCALE_NORMAL)
            _SetButtonAlpha(btn, 0.7)
            hover_label:Hide()
        end)
        btn.inst:ListenForEvent("onremove", function()
            _StopScaleTween(nil)
        end)
        _LoadAdminBtnPos(function(px, py)
            if btn and btn.inst and btn.inst:IsValid() then
                local cx, cy = ClampPos(px, py)
                holder:SetPosition(cx, cy)
            end
        end)
        self.admin_panel_btn = btn
        self.admin_panel_btn_holder = holder
        self.admin_panel_btn_root = ui_root
    end)
end)

-- ========== 右键玩家查看物品栏==========

local ADMIN_VIEWINV = AddAction("ADMIN_VIEWINV", T("action_view_inv"), function(act)
    return false
end)
ADMIN_VIEWINV.rmb = true
ADMIN_VIEWINV.priority = 10

local ADMIN_REVIVE = AddAction("ADMIN_REVIVE", T("action_revive"), function(act)
    return false
end)
ADMIN_REVIVE.rmb = true
ADMIN_REVIVE.priority = 11

-- 注册 NPC 伙伴查看物品动作（所有玩家可见自己的NPC）
local ADMIN_VIEWNPC = AddAction("ADMIN_VIEWNPC", T("action_view_npc"), function(act)
    return false
end)
ADMIN_VIEWNPC.rmb = true
ADMIN_VIEWNPC.priority = 9

-- 注册 NPC 状态查看 Action（左键点击 NPC 弹出状态面板）
local ADMIN_NPCSTATUS = AddAction("ADMIN_NPCSTATUS", T("action_npc_status"), function(act)
    return false
end)
ADMIN_NPCSTATUS.priority = 10
ADMIN_NPCSTATUS.instant = true
-- 用 stroverridefn 自定义格式，使左键提示与右键一致（“图标: 文本”）
ADMIN_NPCSTATUS.stroverridefn = function(act)
    local icon = GLOBAL.TheInput:GetLocalizedControl(GLOBAL.TheInput:GetControllerID(), GLOBAL.CONTROL_PRIMARY)
    return icon .. ": " .. T("action_npc_status")
end

-- 注册 NPC 复活 Action（手持告密的心左键点击 NPC 幽灵）
local ADMIN_REVIVE_NPC = AddAction("ADMIN_REVIVE_NPC", T("action_revive_npc"), function(act)
    return false
end)
ADMIN_REVIVE_NPC.priority = 15  -- 高于 NPCSTATUS(10) 和 GIVE(1)
ADMIN_REVIVE_NPC.instant = true
ADMIN_REVIVE_NPC.stroverridefn = function(act)
    local icon = GLOBAL.TheInput:GetLocalizedControl(GLOBAL.TheInput:GetControllerID(), GLOBAL.CONTROL_PRIMARY)
    return icon .. ": " .. T("action_revive_npc")
end

-- 悬停提示：玩家右键 → 查看/复活；自己的NPC右键 → 查看NPC物品
-- 合并为一个 AddComponentAction（同一 mod 同一组件只能注册一个函数，后者会覆盖前者）
local function _BlockNPCUI(ent)
    if not ent then return false end
    local ok_net, blocked_net = GLOBAL.pcall(function()
        return ent.npc_ui_blocked_net ~= nil and ent.npc_ui_blocked_net:value() == true
    end)
    if ok_net and blocked_net then return true end
    local ok_no_ui, no_ui = GLOBAL.pcall(function() return ent:HasTag("npc_no_ui") end)
    if ok_no_ui and no_ui then return true end
    local ok_hostile, hostile = GLOBAL.pcall(function() return ent:HasTag("npc_hostile") end)
    if ok_hostile and hostile then return true end
    return false
end

local function _CountAcceptableToNPC(npc, item, desired)
    if not npc or not item or not npc.components or not npc.components.inventory then return 0 end
    local want = GLOBAL.tonumber(desired) or 0
    if want <= 0 then return 0 end

    local ok, accepted = GLOBAL.pcall(function()
        return npc.components.inventory:CanAcceptCount(item, want)
    end)
    if ok and accepted ~= nil then
        return math.max(0, math.min(want, GLOBAL.tonumber(accepted) or 0))
    end
    return 0
end

-- 把 active item 转给 NPC：在 ADMIN_GIVE_NPC.fn 执行点（give 动画第 13 帧）调用。
-- 此时物品仍在玩家 active 槽（因为我们已经把 ADMIN_GIVE_NPC 加入 DoActionAutoEquip 的排除
-- 列表，原版不会再做"鼠标 HANDS 物品自动装备到手"）。流程与原版 trader.AcceptGift 一致。
local function _DetachPlayerActionItem(doer, inv, item)
    if doer == nil or inv == nil or item == nil then return false end
    if inv:GetActiveItem() == item then
        inv:SetActiveItem(nil)
        return true
    end
    if item.components ~= nil and item.components.equippable ~= nil then
        local eslot = item.components.equippable.equipslot
        if eslot ~= nil and inv:GetEquippedItem(eslot) == item then
            inv.equipslots[eslot] = nil
            if item.components.inventoryitem ~= nil then
                item.components.inventoryitem.owner = nil
            end
            doer:PushEvent("unequip", { item = item, eslot = eslot })
            return true
        end
    end
    local removed = inv:RemoveItem(item, true)
    return removed == item
end

local give_text = "Give"
GLOBAL.pcall(function()
    give_text = GLOBAL.STRINGS.ACTIONS.GIVE.GENERIC or give_text
end)

-- 鼠标拿物品左键给 NPC：走原版 give 状态，动画执行点再真正转移物品。
-- 关键：我们把 ADMIN_GIVE_NPC 加入了 DoActionAutoEquip 的排除列表（见下方 PlayerController
-- post-construct），所以鼠标里的 HANDS 武器不会被原版预装备到玩家手。流程与原版 GIVE 完全
-- 一致：active 物品保留 → 走路 → give 动画 → 第 13 帧 PerformBufferedAction → action.fn 转移。
local ADMIN_GIVE_NPC = AddAction("ADMIN_GIVE_NPC", give_text, function(act)
    local doer = act.doer
    local target = act.target
    local item = act.invobject

    if not doer or not target or not item then return false end
    if not target:HasTag("npcfriend") then return false end
    if _BlockNPCUI(target) then return false end
    if target._is_ghost_mode or target:HasTag("ghost")
        or (target.components.health and target.components.health:IsDead()) then
        return false
    end
    if not target.components or not target.components.inventory then return false end

    local inv = doer.components and doer.components.inventory or nil
    if not inv then return false end

    local count = 1
    if item.components and item.components.stackable then
        count = item.components.stackable:StackSize() or 1
    end
    local accepted = _CountAcceptableToNPC(target, item, count)
    if accepted <= 0 then return false end

    local give_item = item
    if accepted < count then
        if not (item.components and item.components.stackable) then return false end
        give_item = item.components.stackable:Get(accepted)
    elseif not _DetachPlayerActionItem(doer, inv, item) then
        return false
    end

    local ok, gave = GLOBAL.pcall(function()
        return target.components.inventory:GiveItem(give_item)
    end)
    if not ok or gave == false then
        if give_item ~= item and give_item:IsValid() and item:IsValid()
            and item.components and item.components.stackable then
            item.components.stackable:Put(give_item)
        elseif give_item == item then
            GLOBAL.pcall(function() inv:GiveActiveItem(item) end)
        end
        return false
    end
    return true
end)
ADMIN_GIVE_NPC.priority = 2
ADMIN_GIVE_NPC.distance = 1.5
ADMIN_GIVE_NPC.mount_valid = true

AddComponentAction("USEITEM", "inventoryitem", function(inst, doer, target, actions, right)
    if right then return end
    if not target or not target:HasTag("npcfriend") then return end
    if _BlockNPCUI(target) then return end
    if target:HasTag("ghost") or target:HasTag("playerghost") then return end
    table.insert(actions, GLOBAL.ACTIONS.ADMIN_GIVE_NPC)
end)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.ADMIN_GIVE_NPC, "give"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.ADMIN_GIVE_NPC, "give"))

-- 根本修复：把 ADMIN_GIVE_NPC 加入 PlayerController:DoActionAutoEquip 的排除列表。
-- 原版 DoActionAutoEquip 对装备槽=HANDS 的 active item 会自动 Equip 到玩家手，但显式排除
-- ACTIONS.GIVE / GIVETOPLAYER / GIVEALLTOPLAYER / FEED 等"给与类"动作。
-- 我们的 ADMIN_GIVE_NPC 是自定义动作，不在白名单里，所以会被自动装备 → 装备闪烁 + 鼠标提前
-- 清空。包装 DoActionAutoEquip，对我们的动作直接跳过即可，无需任何 Equip / SetActiveItem
-- 等下游拦截。
AddClassPostConstruct("components/playercontroller", function(self)
    local _DoActionAutoEquip = self.DoActionAutoEquip
    if _DoActionAutoEquip == nil then return end
    self.DoActionAutoEquip = function(self_pc, buffaction, ...)
        if buffaction ~= nil and buffaction.action == GLOBAL.ACTIONS.ADMIN_GIVE_NPC then
            return
        end
        return _DoActionAutoEquip(self_pc, buffaction, ...)
    end
end)

AddClassPostConstruct("widgets/invslot", function(self)
    local _OnControl = self.OnControl
    self.OnControl = function(slot, control, down, ...)
        if not down and slot._dstadmin_shift_give_npc_consumed
            and (control == GLOBAL.CONTROL_ACCEPT or control == GLOBAL.CONTROL_PRIMARY) then
            slot._dstadmin_shift_give_npc_consumed = nil
            return true
        end

        if down
            and (control == GLOBAL.CONTROL_ACCEPT or control == GLOBAL.CONTROL_PRIMARY)
            and GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_SHIFT)
            and GLOBAL.ThePlayer ~= nil
            and GLOBAL.ThePlayer.HUD ~= nil then

            local itemview = GLOBAL.ThePlayer.HUD.dst_admin_itemview
            local item = slot.tile ~= nil and slot.tile.item or nil
            if itemview ~= nil
                and itemview.is_npc == true
                and itemview.is_offline_snapshot ~= true
                and itemview.target_userid ~= nil
                and itemview.target_userid:sub(1, 4) == "npc:"
                and item ~= nil
                and item.GUID ~= nil
                and (GLOBAL.ThePlayer.replica.inventory == nil
                    or GLOBAL.ThePlayer.replica.inventory:GetActiveItem() == nil) then

                local owned = false
                GLOBAL.pcall(function()
                    owned = item.replica ~= nil
                        and item.replica.inventoryitem ~= nil
                        and item.replica.inventoryitem:IsGrandOwner(GLOBAL.ThePlayer)
                end)
                if not owned then
                    GLOBAL.pcall(function()
                        owned = item.replica ~= nil
                            and item.replica.inventoryitem ~= nil
                            and item.replica.inventoryitem:GetGrandOwner() == GLOBAL.ThePlayer
                    end)
                end
                if owned then
                    GLOBAL.pcall(function()
                        SendModRPCToServer(GetModRPC("DstAdmin", "AdminGivePlayerSlotToNPC"),
                            itemview.target_userid .. "|" .. tostring(item.GUID))
                    end)
                    itemview._suspend_refresh_until = (GLOBAL.GetTime and GLOBAL.GetTime() or 0) + 0.4
                    slot._dstadmin_shift_give_npc_consumed = true
                    return true
                end
            end
        end

        if _OnControl then
            return _OnControl(slot, control, down, ...)
        end
        return false
    end
end)

AddComponentAction("SCENE", "health", function(inst, doer, actions, right)
    if not right then return end

    -- ── 玩家检测（管理员或配置允许）────────────────────────────────
    if inst:HasTag("player") and inst ~= doer then
        local is_admin = GLOBAL.TheNet:GetIsServerAdmin()
        if inst:HasTag("playerghost") then
            if is_admin then
                table.insert(actions, GLOBAL.ACTIONS.ADMIN_REVIVE)
            end
        else
            if is_admin or DSTADMIN_ALLOW_VIEW_INV then
                table.insert(actions, GLOBAL.ACTIONS.ADMIN_VIEWINV)
            end
        end
        return
    end

    -- ── NPC 伙伴检测（所有玩家均可查看NPC物品栏）────────────────────────
    local ok_tag, is_npc = GLOBAL.pcall(function() return inst:HasTag("npcfriend") end)
    if not ok_tag or not is_npc then return end
    if _BlockNPCUI(inst) then return end
    local has_active = false
    GLOBAL.pcall(function()
        has_active = doer.replica.inventory:GetActiveItem() ~= nil
    end)
    if has_active then return end
    table.insert(actions, GLOBAL.ACTIONS.ADMIN_VIEWNPC)
end)

-- NPC 提示注入：
-- 左键：inherentsceneaction 设置 ADMIN_NPCSTATUS（覆盖 NPCFriends 的 NPC_GREET）
-- 右键：inherentscenealtaction 设置 ADMIN_VIEWNPC（所有玩家可见）
-- 不加 ismastersim 守卫：HOST 玩家同时是 server+client，ismastersim=true 但仍需要 UI 提示。
AddPrefabPostInit("npcfriend", function(inst)
    local function _NoUI()
        return _BlockNPCUI(inst)
    end
    local function ApplySceneActions()
        if not (inst and inst:IsValid()) then return end
        if _NoUI() then
            inst.inherentsceneaction = nil
            inst.inherentscenealtaction = nil
        else
            inst.inherentsceneaction = GLOBAL.ACTIONS.ADMIN_NPCSTATUS
            inst.inherentscenealtaction = GLOBAL.ACTIONS.ADMIN_VIEWNPC
        end
    end
    inst:DoTaskInTime(0, function()
        ApplySceneActions()
    end)

    inst:ListenForEvent("npcfriend.owner_useriddirty", function()
        inst:DoTaskInTime(0, function()
            ApplySceneActions()
        end)
    end)

    -- 右键提示：所有玩家对NPC都显示
    inst:ListenForEvent("npcfriend.owner_useriddirty", ApplySceneActions)
    inst:DoTaskInTime(1, ApplySceneActions)
    inst._dstadmin_sceneaction_guard = inst:DoPeriodicTask(0.25, function()
        ApplySceneActions()
    end)
    inst:ListenForEvent("onremove", function(i)
        if i._dstadmin_sceneaction_guard then
            i._dstadmin_sceneaction_guard:Cancel()
            i._dstadmin_sceneaction_guard = nil
        end
    end)
end)

local function _BuildNPCUIRequestParam(ent)
    if ent == nil then return nil end

    local char_type = ""
    local slot_idx = 0
    GLOBAL.pcall(function()
        char_type = ent.npc_character_net and ent.npc_character_net:value() or ""
        if char_type == "" and ent.AnimState then
            char_type = ent.AnimState:GetBuild() or ""
        end
        if char_type == "" then
            char_type = ent.prefab or ""
        end
        slot_idx = ent.npc_slot_index_net and ent.npc_slot_index_net:value() or 0
    end)

    local ok_own, owner_id = GLOBAL.pcall(function()
        return ent.owner_userid and ent.owner_userid:value()
    end)
    if not ok_own or not owner_id or owner_id == "" then
        owner_id = "_"
    end

    local rpc_param = owner_id
    if char_type ~= "" then rpc_param = rpc_param .. ":" .. char_type end
    if slot_idx > 0 then rpc_param = rpc_param .. ":" .. tostring(slot_idx) end
    local guid = ent.GUID and tostring(ent.GUID) or ""
    if guid ~= "" then
        rpc_param = guid .. "|" .. rpc_param
    end
    return rpc_param
end

AddClassPostConstruct("components/playercontroller", function(self)
    local _DoAction = self.DoAction
    self.DoAction = function(self_pc, buffaction, ...)
        if buffaction and buffaction.action == GLOBAL.ACTIONS.ADMIN_NPCSTATUS then
            local target = buffaction.target
            if target ~= nil and target:HasTag("npcfriend") and not _BlockNPCUI(target) then
                local rpc_param = _BuildNPCUIRequestParam(target)
                if rpc_param ~= nil then
                    GLOBAL.pcall(function()
                        SendModRPCToServer(GetModRPC("DstAdmin", "RequestNPCStatus"), rpc_param)
                    end)
                    GLOBAL.pcall(function()
                        SendModRPCToServer(GetModRPC("NPCFriends", "GreetNPC"), rpc_param)
                    end)
                end
            end
            return
        end
        if buffaction and (buffaction.action == GLOBAL.ACTIONS.ADMIN_VIEWINV
                        or buffaction.action == GLOBAL.ACTIONS.ADMIN_REVIVE
                        or buffaction.action == GLOBAL.ACTIONS.ADMIN_VIEWNPC) then
            return  -- 静默跳过，不走路不动画
        end
        if _DoAction then return _DoAction(self_pc, buffaction, ...) end
    end
end)

if GLOBAL.TheInput then
    GLOBAL.TheInput:AddMouseButtonHandler(function(button, down, x, y)
        if button ~= GLOBAL.MOUSEBUTTON_LEFT or not down then return false end
        -- 左键 NPC 状态交给 ADMIN_NPCSTATUS 动作处理，避免原始鼠标事件在
        -- 鼠标拿武器时误判 active item 并吞掉 GIVE 动作。
        return false
    end)

    GLOBAL.TheInput:AddMouseButtonHandler(function(button, down, x, y)
        if button ~= GLOBAL.MOUSEBUTTON_RIGHT or not down then return false end
        if not GLOBAL.ThePlayer then return false end
        if GLOBAL.TheFrontEnd:GetActiveScreen() ~= GLOBAL.ThePlayer.HUD then return false end

        local ok_eq, hand_item = GLOBAL.pcall(function()
            return GLOBAL.ThePlayer.replica.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS)
        end)
        if ok_eq and hand_item and hand_item.prefab == "reskin_tool" then return false end

        local ent = nil
        GLOBAL.pcall(function() ent = GLOBAL.TheInput:GetWorldEntityUnderMouse() end)
        if not ent or ent == GLOBAL.ThePlayer then return false end

        -- ── NPC 伙伴检测（所有玩家均可查看NPC物品栏）──────────────────
        local ok_npc, is_npc = GLOBAL.pcall(function() return ent:HasTag("npcfriend") end)
        if ok_npc and is_npc then
            if _BlockNPCUI(ent) then return false end
            local active_item = nil
            GLOBAL.pcall(function()
                active_item = GLOBAL.ThePlayer.replica.inventory:GetActiveItem()
            end)
            if active_item then return false end

            local ok_own, owner_id = GLOBAL.pcall(function()
                return ent.owner_userid and ent.owner_userid:value()
            end)
            if not ok_own or not owner_id or owner_id == "" then
                owner_id = "_"  -- 占位符：服务端通过 char_type+slot_idx 定位
            end

            local char_type = ""
            local slot_idx = 0
            GLOBAL.pcall(function()
                char_type = ent.npc_character_net and ent.npc_character_net:value() or ""
                -- 回退：AnimState build 更可靠（不依赖 net_string 同步时序）
                if char_type == "" and ent.AnimState then
                    char_type = ent.AnimState:GetBuild() or ""
                end
                -- 如果仍为空，尝试从 prefab 名获取（最后手段）
                if char_type == "" then
                    char_type = ent.prefab or ""
                end
                slot_idx = ent.npc_slot_index_net and ent.npc_slot_index_net:value() or 0
            end)
            local rpc_param = owner_id
            if char_type ~= "" then rpc_param = rpc_param .. ":" .. char_type end
            if slot_idx > 0 then rpc_param = rpc_param .. ":" .. tostring(slot_idx) end
            local guid = ent.GUID and tostring(ent.GUID) or ""
            if guid ~= "" then
                rpc_param = guid .. "|" .. rpc_param
            end

            GLOBAL.pcall(function()
                SendModRPCToServer(GetModRPC("DstAdmin", "RequestNPCInventory"), rpc_param)
            end)
            return true
        end

        -- ── 玩家检测（需要管理员权限或配置允许）────────────────────────────
        local is_admin = GLOBAL.TheNet:GetIsServerAdmin()
        if not is_admin and not DSTADMIN_ALLOW_VIEW_INV then return false end

        if not ent.userid then return false end
        local ok, is_player = GLOBAL.pcall(function() return ent:HasTag("player") end)
        if not ok or not is_player then return false end

        local is_ghost = false
        GLOBAL.pcall(function() is_ghost = ent:HasTag("playerghost") end)

        if is_ghost then
            if not is_admin then return false end
            GLOBAL.pcall(function()
                SendModRPCToServer(GetModRPC("DstAdmin", "AdminAction"), "respawn|" .. ent.userid)
            end)
        else
            GLOBAL.pcall(function()
                SendModRPCToServer(GetModRPC("DstAdmin", "RequestInventory"), ent.userid)
            end)
        end
        return true
    end)
end

-- 隐藏管理员图标（TAB）
AddClassPostConstruct("screens/playerstatusscreen", function(self)
    local _DoInit = self.DoInit
    self.DoInit = function(self, ...)
        _DoInit(self, ...)
        if self.player_widgets then
            for _, widget in ipairs(self.player_widgets) do
                if widget.adminBadge then
                    widget.adminBadge:Hide()
                    widget.adminBadge.Show = function() end
                end
            end
        end
    end
end)

-- 隐藏管理员图标（旧版玩家列表）
AddClassPostConstruct("widgets/playerlist", function(self)
    if self.player_widgets then
        for _, widget in ipairs(self.player_widgets) do
            if widget.adminBadge then
                widget.adminBadge:Hide()
                widget.adminBadge.Show = function() end
            end
        end
    end
end)

-- 隐藏管理员图标（选人界面）
AddClassPostConstruct("widgets/redux/playerlist", function(self)
    local _BuildPlayerList = self.BuildPlayerList
    if _BuildPlayerList then
        self.BuildPlayerList = function(self, ...)
            _BuildPlayerList(self, ...)
            if self.scroll_list and self.scroll_list.widgets_to_update then
                for _, widget in ipairs(self.scroll_list.widgets_to_update) do
                    if widget and widget.adminBadge then
                        widget.adminBadge:Hide()
                        widget.adminBadge.Show = function() end
                    end
                end
            end
        end
    end
end)
