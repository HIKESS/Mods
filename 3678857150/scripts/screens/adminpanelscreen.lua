-- ========== 管理员面板 Screen ==========

local _rawget = GLOBAL.rawget or rawget
local _rawset = GLOBAL.rawset or rawset

local function MakeActionBtn(parent, label, x, y, w, onclick)
    local btn = parent:AddChild(ImageButton(
        "images/global_redux.xml",
        "button_carny_long_normal.tex",
        "button_carny_long_hover.tex",
        "button_carny_long_disabled.tex",
        "button_carny_long_down.tex"
    ))
    btn:ForceImageSize(w or 80, 34)
    btn:SetText(label)
    btn:SetFont(GLOBAL.CHATFONT)
    btn:SetTextSize(20)
    btn:SetPosition(x, y)
    btn:SetOnClick(onclick)
    btn.scale_on_focus = false
    return btn
end

local function HasNPCFriends()
    return (GLOBAL.ACTIONS and GLOBAL.ACTIONS.NPC_GREET ~= nil)
        or (_rawget(GLOBAL, "NPCFRIENDS") ~= nil)
end

AdminPanelScreen = GLOBAL.Class(Screen, function(self, owner)
    Screen._ctor(self, "AdminPanelScreen")
    self.owner = owner
    self.admin_userid = owner and owner.userid or GLOBAL.TheNet:GetUserID()

    -- 半透明黑色遮罩
    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(GLOBAL.ANCHOR_MIDDLE)
    self.black:SetHRegPoint(GLOBAL.ANCHOR_MIDDLE)
    self.black:SetVAnchor(GLOBAL.ANCHOR_MIDDLE)
    self.black:SetHAnchor(GLOBAL.ANCHOR_MIDDLE)
    self.black:SetScaleMode(GLOBAL.SCALEMODE_FILLSCREEN)
    self.black:SetTint(0, 0, 0, 0.2)
    self.black:SetClickable(false)

    -- 根节点
    self.root = self:AddChild(Widget("root"))
    self.root:SetVAnchor(GLOBAL.ANCHOR_MIDDLE)
    self.root:SetHAnchor(GLOBAL.ANCHOR_MIDDLE)
    self.root:SetScaleMode(GLOBAL.SCALEMODE_PROPORTIONAL)
    self.root:SetMaxPropUpscale(GLOBAL.MAX_HUD_SCALE)

    self.panel = self.root:AddChild(Widget("panel"))

    -- 面板背景（使用TAB同款框架）
    self.panel_bg = self.panel:AddChild(Image("images/scoreboard.xml", "scoreboard_frame.tex"))
    self.panel_bg:ScaleToSize(1100, 580)
    self._show_offline = (_rawget(GLOBAL, "DSTADMIN_SHOW_OFFLINE_PLAYERS") == true)
    self._has_npcfriends = HasNPCFriends()
    self._show_npc = self._has_npcfriends and (_rawget(GLOBAL, "DSTADMIN_SHOW_NPC_PLAYERS") == true) or false
    self._allow_admin_hp_revive = (_rawget(GLOBAL, "DSTADMIN_ALLOW_ADMIN_HP_REVIVE") ~= false)
    self._offline_records = _rawget(GLOBAL, "DSTADMIN_OFFLINE_CLIENT_CACHE") or {}
    self._npc_records = _rawget(GLOBAL, "DSTADMIN_NPC_CLIENT_CACHE") or {}

    -- 关闭按钮
    self.close_btn = self.panel:AddChild(ImageButton("images/global_redux.xml", "close.tex"))
    self.close_btn:SetPosition(515, 255)
    self.close_btn:SetScale(0.6)
    self.close_btn:SetOnClick(function() self:Close() end)

    -- 列标题
    local hy = 220
    local function AddHeader(txt, x)
        local h = self.panel:AddChild(Text(GLOBAL.UIFONT, 26, txt))
        h:SetPosition(x, hy)
        h:SetColour(0.85, 0.85, 0.6, 1)
    end
    AddHeader(T("col_player"), -350)
    AddHeader(T("col_status"), -60)
    AddHeader(T("col_items"), 100)
    -- AddHeader(T("col_actions"), 280) -- 暂时注释：与离线显示开关按钮位置重叠

    self.npc_toggle_btn = MakeActionBtn(self.panel, "", 210, 220, 140, function()
        self._show_npc = not self._show_npc
        _rawset(GLOBAL, "DSTADMIN_SHOW_NPC_PLAYERS", self._show_npc and true or false)
        self:_RefreshNPCToggleText()
        self:BuildPlayerList()
    end)
    self.npc_toggle_btn:SetTextSize(18)

    self.offline_toggle_btn = MakeActionBtn(self.panel, "", 360, 220, 140, function()
        self._show_offline = not self._show_offline
        _rawset(GLOBAL, "DSTADMIN_SHOW_OFFLINE_PLAYERS", self._show_offline and true or false)
        self:_RefreshOfflineToggleText()
        self:BuildPlayerList()
    end)
    self.offline_toggle_btn:SetTextSize(18)
    self:_RefreshNPCToggleText()
    self:_RefreshOfflineToggleText()

    -- 分割线
    local line = self.panel:AddChild(Image("images/global.xml", "square.tex"))
    line:ScaleToSize(880, 2)
    line:SetPosition(0, 205)
    line:SetTint(0.5, 0.5, 0.4, 0.8)

    self:BuildPlayerList()
end)

function AdminPanelScreen:_RefreshNPCToggleText()
    if not self.npc_toggle_btn then return end
    self._has_npcfriends = HasNPCFriends()
    if not self._has_npcfriends then
        self._show_npc = false
        _rawset(GLOBAL, "DSTADMIN_SHOW_NPC_PLAYERS", false)
        self.npc_toggle_btn:Hide()
        return
    end
    self.npc_toggle_btn:Show()
    local mark = self._show_npc and "[x] " or "[ ] "
    self.npc_toggle_btn:SetText(mark .. T("btn_show_npc"))
end

function AdminPanelScreen:_RefreshOfflineToggleText()
    if not self.offline_toggle_btn then return end
    local mark = self._show_offline and "[x] " or "[ ] "
    self.offline_toggle_btn:SetText(mark .. T("btn_show_offline"))
end

function AdminPanelScreen:SetOfflineRecords(records)
    self._offline_records = records or {}
    if self._show_offline then
        self:BuildPlayerList(true)
    end
end

function AdminPanelScreen:SetNPCRecords(records)
    self._npc_records = records or {}
    if self._show_npc then
        self:BuildPlayerList(true, true)
    end
end

function AdminPanelScreen:BuildPlayerList(skip_offline_request, skip_npc_request)
    self:_RefreshNPCToggleText()
    local clients = GLOBAL.TheNet:GetClientTable() or {}
    local players = {}
    local online_order = 0
    for _, c in ipairs(clients) do
        -- 过滤掉专用服务器的 [HOST] 条目（prefab 为空，说明不是真实玩家）
        if c.userid and c.userid ~= "" and c.prefab and c.prefab ~= "" then
            online_order = online_order + 1
            c._category = 1 -- 在线
            c._order = online_order
            table.insert(players, c)
        end
    end

    if self._show_offline then
        local online_uid = {}
        local offline_order = 0
        for _, p in ipairs(players) do
            if p and p.userid then
                online_uid[tostring(p.userid)] = true
            end
        end
        for _, r in ipairs(self._offline_records or {}) do
            local uid = tostring(r.userid or "")
            if uid ~= "" and not online_uid[uid] then
                offline_order = offline_order + 1
                table.insert(players, {
                    userid = uid,
                    name = r.name or "???",
                    prefab = r.prefab or "",
                    userflags = r.is_ghost == 1 and 1 or 0,
                    _offline = true,
                    _category = 2, -- 离线
                    _order = offline_order,
                    _hp = r.hp or 0,
                    _hu = r.hu or 0,
                    _sa = r.sa or 0,
                    _ghost = r.is_ghost == 1,
                })
            end
        end
    end

    if self._has_npcfriends and self._show_npc then
        local npc_order = 0
        for _, n in ipairs(self._npc_records or {}) do
            if n and n.userid then
                npc_order = npc_order + 1
                table.insert(players, {
                    userid = n.userid,
                    name = n.name or "NPC",
                    prefab = n.prefab or "",
                    userflags = n.userflags or 0,
                    _npc = true,
                    _owner_param = n._owner_param,
                    _guid = n._guid,
                    _ghost = n._ghost == true,
                    _hostile = n._hostile == true,
                    _category = 3, -- NPC
                    _order = npc_order,
                })
            end
        end
    end

    table.sort(players, function(a, b)
        local ca = a._category or 99
        local cb = b._category or 99
        if ca ~= cb then
            return ca < cb
        end
        return (a._order or 0) < (b._order or 0)
    end)

    -- 清理旧内容前先记录滚动位置，避免自动刷新后跳回顶部
    local prev_view_offset = 0
    if self.scroll_list and self.scroll_list.view_offset ~= nil then
        prev_view_offset = self.scroll_list.view_offset or 0
    elseif self._saved_view_offset ~= nil then
        prev_view_offset = self._saved_view_offset or 0
    end
    self._saved_view_offset = prev_view_offset

    if self.scroll_list then self.scroll_list:Kill(); self.scroll_list = nil end
    if self.list_container then self.list_container:Kill() end
    self.list_container = self.panel:AddChild(Widget("list_container"))
    -- 列表整体位置：第2个值越小越往下，越大越往上
    self.list_container:SetPosition(0, -10)

    local ROW_HEIGHT = 55
    -- 滚动条出现条件：玩家数 > math.ceil(SCROLL_LIST_HEIGHT / ROW_HEIGHT)
    -- 385 → 可见7行，8人起滚动 |330 → 可见6行，7人起滚动 | 275 → 可见5行，6人起滚动 | 220 → 可见4行，5人起滚动
    local SCROLL_LIST_HEIGHT = 385
    local admin_userid = self.admin_userid
    self.player_rows = {}
    self.stat_refs = {}       -- userid -> stat_text widget（用于异步更新跨世界三维）
    self.badge_refs = {}      -- userid -> {widget, parent, prefab, colour}（用于异步更新头像）
    self.respawn_refs = {}    -- userid -> btn_respawn widget（用于异步更新复活按钮）
    local remote_uids = {}    -- 需要跨世界查询三维的userid列表

    -- 截断过长字符串，保留末尾省略号（正确处理UTF-8多字节字符，避免截断半个汉字）
    local function SafeTruncate(str, maxbytes)
        str = tostring(str or "")
        if #str <= maxbytes then return str end
        local s = string.sub(str, 1, maxbytes)
        local b = string.byte(s, #s)
        if b and b >= 128 then
            while #s > 0 and string.byte(s, #s) >= 128 and string.byte(s, #s) < 192 do
                s = string.sub(s, 1, #s - 1)
            end
            if #s > 0 and string.byte(s, #s) >= 192 then
                s = string.sub(s, 1, #s - 1)
            end
        end
        return s .. "..."
    end

    -- 获取玩家三维（通过客户端 replica），第4返回值标识是否找到
    local function GetPlayerStats(userid)
        for _, p in ipairs(GLOBAL.AllPlayers or {}) do
            if p and p.userid == userid and p.replica then
                local hp, hu, sa

                local function ReadStat(replica_comp)
                    if not replica_comp then return nil end
                    -- 优先 GetPercent * GetMax（对其他玩家准确）
                    local ok1, pct = GLOBAL.pcall(function() return replica_comp:GetPercent() end)
                    local ok2, max = GLOBAL.pcall(function() return replica_comp:GetMax() end)
                    if ok1 and ok2 and type(pct) == "number" and type(max) == "number" and max > 0 then
                        return math.floor(pct * max)
                    end
                    -- fallback: GetCurrent（对自己准确）
                    local ok3, cur = GLOBAL.pcall(function() return replica_comp:GetCurrent() end)
                    if ok3 and type(cur) == "number" then
                        return math.floor(cur)
                    end
                    return nil
                end

                hp = ReadStat(p.replica.health)
                hu = ReadStat(p.replica.hunger)
                sa = ReadStat(p.replica.sanity)

                return hp, hu, sa, true
            end
        end
        return nil, nil, nil, false
    end

    -- 延迟后通过服务端RPC刷新三维（不读replica，避免同步延迟导致数值不准）
    local function DelayedRefreshStat(uid, delay)
        if not GLOBAL.ThePlayer then return end
        GLOBAL.ThePlayer:DoTaskInTime(delay or 0.5, function()
            if not self.stat_refs or not self.stat_refs[uid] then return end
            GLOBAL.pcall(function()
                SendModRPCToServer(GetModRPC("DstAdmin", "RequestRemoteStats"), uid)
            end)
        end)
    end

    for idx, data in ipairs(players) do

        local uid = tostring(data.userid or "")
        local is_offline = data._offline == true
        local is_npc = data._npc == true

        local row = Widget("row_" .. idx)

        -- 背景（使用TAB记分板行背景）
        row.bg = row:AddChild(Image("images/scoreboard.xml", "row.tex"))
        row.bg:ScaleToSize(870, 60)
        row.bg:SetTint(1, 1, 1, (idx % 2 == 0) and 0.7 or 0.4)

        -- 角色头像（PlayerBadge）
        local prefab = tostring(data.prefab or "")
        local uf = data.userflags
        local safe_colour = {1, 1, 1, 1}
        if type(data.colour) == "table" and type(data.colour[1]) == "number" and type(data.colour[2]) == "number" and type(data.colour[3]) == "number" then
            safe_colour = {data.colour[1], data.colour[2], data.colour[3], data.colour[4] or 1}
        end
        row.badge = row:AddChild(PlayerBadge(prefab, safe_colour, data.performance ~= nil, type(uf) == "number" and uf or 0))
        row.badge:SetScale(0.65)
        row.badge:SetPosition(-440, 0)
        self.badge_refs[uid] = {widget = row.badge, parent = row, prefab = prefab, colour = safe_colour}

        -- 玩家名 + Klei ID
        local name_str = SafeTruncate(tostring(data.name or "???"), 16)
        local id_str = SafeTruncate(uid, 14)
        row.name_text = row:AddChild(Text(GLOBAL.UIFONT, 26, ""))
        row.name_text:SetPosition(-250, 0)
        row.name_text:SetRegionSize(280, 35)
        row.name_text:SetHAlign(GLOBAL.ANCHOR_LEFT)
        row.name_text:SetString(name_str .. "  (" .. id_str .. ")")
        row.name_text:SetColour(1, 1, 1, 1)

        -- 三维状态
        local is_ghost = is_offline and (data._ghost == true) or false
        if is_npc then
            is_ghost = data._ghost == true
        end
        local entity_found = false
        if not is_offline and not is_npc then
            for _, p in ipairs(GLOBAL.AllPlayers or {}) do
                if p and p.userid == uid then
                    entity_found = true
                    local ok, ghost = GLOBAL.pcall(function() return p:HasTag("playerghost") end)
                    if ok and ghost then is_ghost = true end
                    break
                end
            end
        end
        if not entity_found then
            is_ghost = type(uf) == "number" and (uf % 2) >= 1
        end
        if is_ghost then
            row.stat_text = row:AddChild(Text(GLOBAL.UIFONT, 26, T("status_ghost")))
            row.stat_text:SetPosition(-60, 0)
            row.stat_text:SetColour(0.6, 0.6, 0.9, 1)
        elseif is_npc then
            row.stat_text = row:AddChild(Text(GLOBAL.UIFONT, 24, is_ghost and T("status_ghost") or "NPC"))
            row.stat_text:SetPosition(-60, 0)
            row.stat_text:SetColour(0.75, 0.9, 0.75, 1)
        elseif is_offline then
            local stat_str = (data._hp or "--") .. "/" .. (data._hu or "--") .. "/" .. (data._sa or "--")
            row.stat_text = row:AddChild(Text(GLOBAL.UIFONT, 24, stat_str))
            row.stat_text:SetPosition(-60, 0)
            row.stat_text:SetColour(0.85, 0.85, 0.85, 1)
        elseif prefab == "" then
            row.stat_text = row:AddChild(Text(GLOBAL.UIFONT, 26, T("status_lobby")))
            row.stat_text:SetPosition(-60, 0)
            row.stat_text:SetColour(0.7, 0.7, 0.5, 1)
        else
            local hp, hu, sa, found = GetPlayerStats(uid)
            if found then
                local stat_str = (hp or "--") .. "/" .. (hu or "--") .. "/" .. (sa or "--")
                row.stat_text = row:AddChild(Text(GLOBAL.UIFONT, 26, stat_str))
                row.stat_text:SetPosition(-60, 0)
                row.stat_text:SetColour(1, 1, 1, 1)
            else
                row.stat_text = row:AddChild(Text(GLOBAL.UIFONT, 26, T("status_cross")))
                row.stat_text:SetPosition(-60, 0)
                row.stat_text:SetColour(0.7, 0.7, 0.5, 1)
            end
            if not is_npc then
                table.insert(remote_uids, uid)
            end
        end
        if not is_offline and not is_npc then
            self.stat_refs[uid] = row.stat_text
        end

        -- 物品按钮（通过RPC向服务端请求物品数据）
        MakeActionBtn(row, T("btn_items"), 100, 0, 80, function()
            GLOBAL.pcall(function()
                if is_npc then
                    local owner_param = data._owner_param or ""
                    if owner_param ~= "" then
                        SendModRPCToServer(GetModRPC("DstAdmin", "RequestNPCInventory"), owner_param)
                    end
                elseif is_offline then
                    SendModRPCToServer(GetModRPC("DstAdmin", "RequestOfflineInventory"), uid)
                else
                    SendModRPCToServer(GetModRPC("DstAdmin", "RequestInventory"), uid)
                end
            end)
            GLOBAL.pcall(function()
                local fe = GLOBAL.TheFrontEnd
                local top = fe.screenstack[#fe.screenstack]
                if top and top.name == "AdminPanelScreen" then
                    fe:PopScreen()
                end
            end)
        end)

        -- 操作按钮
        local bx = 250

        if self._allow_admin_hp_revive then
            local btn_respawn = MakeActionBtn(row, T("btn_respawn"), bx, 0, 80, function()
                GLOBAL.pcall(function()
                    SendModRPCToServer(GetModRPC("DstAdmin", "AdminAction"), "respawn|" .. uid)
                end)
                DelayedRefreshStat(uid, 1.5)
            end)
            if is_npc or is_offline or (not is_ghost) then btn_respawn:Disable() end
            self.respawn_refs[uid] = btn_respawn

            local btn_full = MakeActionBtn(row, T("btn_fullrest"), bx + 90, 0, 80, function()
                GLOBAL.pcall(function()
                    SendModRPCToServer(GetModRPC("DstAdmin", "AdminAction"), "fullrestore|" .. uid)
                end)
                DelayedRefreshStat(uid)
            end)
            if is_npc or is_offline then btn_full:Disable() end
        end

        table.insert(self.player_rows, row)
    end

    -- 用 ScrollableList 包裹玩家行，超过可见区域高度自动出现滚动条
    self.scroll_list = self.list_container:AddChild(ScrollableList(
        self.player_rows,       -- items：预构建的行控件
        870,                    -- listwidth：列表宽度
        SCROLL_LIST_HEIGHT,     -- listheight：可见区域高度
        ROW_HEIGHT,             -- itemheight：每行高度
        0,                      -- itempadding：行间距
        nil,                    -- updatefn
        nil,                    -- widgetstoupdate
        450,                    -- widgetXOffset：行的水平偏移（width/2 使行居中）
        nil, prev_view_offset,  -- always_show_static, starting_offset
        0,                      -- yInit
        nil, nil,               -- bar_width_scale_factor, bar_height_scale_factor
        "GOLD"                  -- scrollbar_style：金色滚动条
    ))
    self.scroll_list:SetPosition(0, 0)
    -- 防止数据条数变化导致 offset 越界，强制做一次 clamp 并刷新
    self.scroll_list:Scroll(0, true)
    self._saved_view_offset = self.scroll_list.view_offset or 0

    -- 请求所有玩家的三维属性（统一通过服务端RPC获取准确值）
    if #remote_uids > 0 then
        GLOBAL.pcall(function()
            SendModRPCToServer(GetModRPC("DstAdmin", "RequestRemoteStats"), table.concat(remote_uids, ","))
        end)
    end

    if not skip_offline_request then
        GLOBAL.pcall(function()
            SendModRPCToServer(GetModRPC("DstAdmin", "RequestOfflinePlayers"))
        end)
    end
    if self._has_npcfriends and self._show_npc and not skip_npc_request then
        GLOBAL.pcall(function()
            SendModRPCToServer(GetModRPC("DstAdmin", "RequestNPCPlayers"))
        end)
    end

    -- 启动定时自动刷新（每5秒刷新一次所有三维/头像/按钮）
    if self.auto_refresh_task then
        self.auto_refresh_task:Cancel()
        self.auto_refresh_task = nil
    end
    self.auto_refresh_task = GLOBAL.ThePlayer:DoPeriodicTask(5, function()
        if not self.stat_refs then return end
        local all_uids = {}
        for uid, _ in pairs(self.stat_refs) do
            table.insert(all_uids, uid)
        end
        if #all_uids > 0 then
            GLOBAL.pcall(function()
                SendModRPCToServer(GetModRPC("DstAdmin", "RequestRemoteStats"), table.concat(all_uids, ","))
            end)
        end
        if not skip_offline_request then
            GLOBAL.pcall(function()
                SendModRPCToServer(GetModRPC("DstAdmin", "RequestOfflinePlayers"))
            end)
        end
        if self._has_npcfriends and self._show_npc then
            GLOBAL.pcall(function()
                SendModRPCToServer(GetModRPC("DstAdmin", "RequestNPCPlayers"))
            end)
        end
    end)
end

function AdminPanelScreen:Close()
    if self.auto_refresh_task then
        self.auto_refresh_task:Cancel()
        self.auto_refresh_task = nil
    end
    GLOBAL.TheFrontEnd:PopScreen(self)
end

-- 按键输入处理：按 ESC（CONTROL_CANCEL）时关闭面板
function AdminPanelScreen:OnControl(control, down)
    if AdminPanelScreen._base.OnControl(self, control, down) then
        return true
    end
    if not down and control == GLOBAL.CONTROL_CANCEL then
        self:Close()
        return true
    end
    return false
end
