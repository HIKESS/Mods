-- scripts/screens/npc_quest_screen.lua
-- 猪人公主任务面板 UI
-- ════════════════════════════════════════════════════════════

local Screen = require("widgets/screen")
local Widget = require("widgets/widget")
local Text = require("widgets/text")
local Image = require("widgets/image")
local TEMPLATES = require("widgets/redux/templates")




local PANEL_W       = 215
local PANEL_PAD_X   = 18                          


local TOP_RESERVE   = 36

local BOT_RESERVE   = 6


local BTN_W         = PANEL_W - 30
local BTN_H         = 36
local ITEM_H        = 42


local BTN_PAIR_LEFT_W   = math.floor(PANEL_W * 0.42)   
local BTN_PAIR_RIGHT_W  = math.floor(PANEL_W * 0.28)   
local BTN_PAIR_X_OFFSET = math.floor(PANEL_W * 0.22)   
local BTN_ALONE_W       = math.floor(PANEL_W * 0.42)   
local BTN_PAIR_H        = 36


local TITLE_SIZE    = 24
local DIVIDER_SIZE  = 17
local DESC_SIZE     = 19
local LINE_SIZE     = 18


local SECTION_GAP   = 6
local DIVIDER_PAD   = 4
local RULE_GAP      = 4      
local ROW_GAP       = 2      


local GOLD    = { 1.0,  0.85, 0.30, 1 }
local GOLD_M  = { 0.85, 0.70, 0.40, 1 }   
local WHITE   = { 1, 1, 1, 1 }
local GRAYTXT = { 0.85, 0.85, 0.85, 1 }   
local LINETXT = { 0.92, 0.92, 0.92, 1 }   
local GREEN   = { 0.40, 1.00, 0.50, 1 }   
local GRAY    = { 0.55, 0.55, 0.55, 1 }
local RED     = { 1, 0.35, 0.35, 1 }





local function LH(font_size)
    return math.floor(font_size * 1.3 + 0.5)
end




local function IsChinese()
    local strings = STRINGS
    local ui = strings ~= nil and strings.UI or nil
    local mainscreen = ui ~= nil and ui.MAINSCREEN or nil
    local play = mainscreen ~= nil and mainscreen.PLAY or nil
    return type(play) == "string" and play:match("[\228-\233]") ~= nil
end

local function L(zh, en)
    return IsChinese() and zh or en
end




local NPCQuestScreen = Class(Screen, function(self, owner, payload)
    Screen._ctor(self, "NPCQuestScreen")

    self.owner = owner
    self.mode = "board"          
    self.detail_quest = nil       
    self.items = {}

    self:_ParsePayload(payload or "")

    self:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self:SetMaxPropUpscale(MAX_HUD_SCALE)
    self:SetVAnchor(ANCHOR_MIDDLE)
    self:SetHAnchor(ANCHOR_MIDDLE)

    self.root = self:AddChild(TEMPLATES.ScreenRoot("root"))

    self.black = self.root:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black:SetTint(0, 0, 0, 0.4)

    self:BuildBoard()
end)





function NPCQuestScreen:_ParsePayload(payload)

    self.daily_quests = {}
    self.accepted_quests = {}
    self.meta = {}

    local lines = {}
    if payload ~= "" then
        local pos = 1
        while true do
            local nl = payload:find("\n", pos, true)
            if nl then
                lines[#lines + 1] = payload:sub(pos, nl - 1)
                pos = nl + 1
            else
                lines[#lines + 1] = payload:sub(pos)
                break
            end
        end
    end

    
    if lines[1] and lines[1] ~= "" then
        for seg in lines[1]:gmatch("[^;]+") do
            local parts = {}
            for p in seg:gmatch("[^|]+") do parts[#parts + 1] = p end
            if #parts >= 2 then
                self.daily_quests[#self.daily_quests + 1] = {
                    id         = parts[1],
                    name       = parts[2] or parts[1],
                }
            end
        end
    end

    
    if lines[2] and lines[2] ~= "" then
        for seg in lines[2]:gmatch("[^;]+") do
            local parts = {}
            for p in seg:gmatch("[^|]+") do parts[#parts + 1] = p end
            if #parts >= 2 then
                local progress = {}
                if parts[3] and parts[3] ~= "" then
                    for v in parts[3]:gmatch("[^,]+") do
                        local n = tonumber(v)
                        progress[#progress + 1] = (n or 0)
                    end
                end
                self.accepted_quests[#self.accepted_quests + 1] = {
                    id        = parts[1],
                    name      = parts[2] or parts[1],
                    progress  = progress,
                    completed = parts[4] == "true",
                }
            end
        end
    end

    
    if lines[3] and lines[3] ~= "" then
        for seg in lines[3]:gmatch("[^;]+") do
            local k, v = seg:match("^([^=]+)=(.*)$")
            if k and v then
                local n = tonumber(v)
                self.meta[k] = (n ~= nil) and n or v
            end
        end
    end
end




function NPCQuestScreen:_MeasureLines(font, font_size, text, max_width)
    if text == nil or text == "" then return 0 end
    local dummy = self.root:AddChild(Text(font, font_size, ""))
    
    local n = dummy:SetMultilineTruncatedString(text, 50, max_width, nil, false)
    dummy:Kill()
    return math.max(1, n or 1)
end

function NPCQuestScreen:_AddWrappedText(font, font_size, text, max_width, color, halign)
    local w = self.panel:AddChild(Text(font, font_size, ""))
    w:SetMultilineTruncatedString(text or "", 50, max_width, nil, false)
    if halign ~= nil then w:SetHAlign(halign) end
    if color  ~= nil then w:SetColour(unpack(color)) end
    table.insert(self.items, w)
    return w
end

function NPCQuestScreen:_AddSingleLine(font, font_size, text, color, halign)
    local w = self.panel:AddChild(Text(font, font_size, text or ""))
    if halign ~= nil then w:SetHAlign(halign) end
    if color  ~= nil then w:SetColour(unpack(color)) end
    table.insert(self.items, w)
    return w
end

function NPCQuestScreen:_AddDivider(top_y, label, color)
    local div = self:_AddSingleLine(UIFONT, DIVIDER_SIZE,
        "── " .. label .. " ──", color or GOLD_M)
    div:SetPosition(0, top_y - DIVIDER_SIZE * 0.5)
    return top_y - LH(DIVIDER_SIZE) - DIVIDER_PAD
end





function NPCQuestScreen:BuildBoard()
    self:_ClearPanel()
    self.mode = "board"

    local n_daily  = #self.daily_quests
    local n_accept = #self.accepted_quests

    
    local title_h    = LH(TITLE_SIZE) + 4              
    local hdr_h      = LH(DIVIDER_SIZE) + DIVIDER_PAD  
    local empty_h    = LH(LINE_SIZE) + 6               
    local btn_band_h = ITEM_H                          

    local daily_body_h  = n_daily  > 0 and n_daily  * btn_band_h or empty_h
    local accept_body_h = n_accept > 0 and n_accept * btn_band_h or empty_h

    
    local close_band_h = btn_band_h

    local content_h = title_h + SECTION_GAP
                    + hdr_h + daily_body_h + SECTION_GAP
                    + hdr_h + accept_body_h
                    + close_band_h
    local panel_h = math.max(360, math.min(600, TOP_RESERVE + content_h + BOT_RESERVE))

    self.panel = self.root:AddChild(TEMPLATES.RectangleWindow(PANEL_W, panel_h))
    self.panel:SetPosition(0, 10)

    local panel_top = panel_h * 0.5
    local panel_bot = -panel_h * 0.5
    local top_y = panel_top - TOP_RESERVE

    
    self.title = self:_AddSingleLine(BODYTEXTFONT, TITLE_SIZE,
        L("公主的任务", "Princess's Quest"), GOLD)
    self.title:SetPosition(0, top_y - title_h * 0.5)
    top_y = top_y - title_h - SECTION_GAP

    
    top_y = self:_AddDivider(top_y, L("今日任务", "Daily Quests"), GOLD_M)
    if n_daily == 0 then
        local empty = self:_AddSingleLine(UIFONT, LINE_SIZE,
            L("今日暂无新任务", "No quests today"),
            GRAY)
        empty:SetPosition(0, top_y - empty_h * 0.5)
        top_y = top_y - empty_h
    else
        for _, quest in ipairs(self.daily_quests) do
            local btn = self.panel:AddChild(TEMPLATES.StandardButton(
                function() self:ShowDetail(quest.id) end,
                quest.name,
                { BTN_W, BTN_H }
            ))
            btn:SetPosition(0, top_y - btn_band_h * 0.5)
            btn:SetTextSize(16)
            table.insert(self.items, btn)
            top_y = top_y - btn_band_h
        end
    end
    top_y = top_y - SECTION_GAP

    local active_count = #self.accepted_quests
    local max_active = (self.meta and self.meta.max_active) or 4
    local active_label = string.format(
        L("进行中的任务  (已接 %d/%d)", "Active Quests  (%d/%d)"),
        active_count, max_active)
    top_y = self:_AddDivider(top_y, active_label, GOLD_M)
    if n_accept == 0 then
        local empty = self:_AddSingleLine(UIFONT, LINE_SIZE,
            L("暂无进行中的任务", "No active quests"), GRAY)
        empty:SetPosition(0, top_y - empty_h * 0.5)
        top_y = top_y - empty_h
    else
        for _, quest in ipairs(self.accepted_quests) do
            local status_text
            if quest.completed then
                status_text = L("  ★ 可提交", "  * Ready")
            else
                status_text = L("  · 进行中", "  * In Progress")
            end
            local btn = self.panel:AddChild(TEMPLATES.StandardButton(
                function()
                    if quest.completed then
                        self:SubmitQuest(quest.id)
                    else
                        self:ShowDetail(quest.id)
                    end
                end,
                quest.name .. status_text,
                { BTN_W, BTN_H }
            ))
            btn:SetPosition(0, top_y - btn_band_h * 0.5)
            btn:SetTextSize(15)
            table.insert(self.items, btn)
            top_y = top_y - btn_band_h
        end
    end

    
    self.close_btn = self.panel:AddChild(TEMPLATES.StandardButton(
        function() self:Close() end,
        L("关闭", "Close"),
        { BTN_ALONE_W, BTN_PAIR_H }
    ))
    self.close_btn:SetPosition(0, top_y - close_band_h * 0.5)
end











function NPCQuestScreen:BuildDetail()
    self:_ClearPanel()
    self.mode = "detail"

    local def = self.detail_quest

    
    local progress = nil
    local is_accepted = false
    local is_daily    = false
    for _, q in ipairs(self.accepted_quests) do
        if q.id == def.id then
            is_accepted = true
            progress = q.progress
            break
        end
    end
    for _, q in ipairs(self.daily_quests) do
        if q.id == def.id then is_daily = true; break end
    end

    local LEFT_X     = -PANEL_W * 0.5 + PANEL_PAD_X
    local RIGHT_X    =  PANEL_W * 0.5 - PANEL_PAD_X
    local CONTENT_W  = RIGHT_X - LEFT_X
    local BODY_INDENT = 12
    local BODY_LEFT  = LEFT_X + BODY_INDENT
    local BODY_W     = RIGHT_X - BODY_LEFT

    
    local desc_text = def.desc or ""

    local title_lines = self:_MeasureLines(BODYTEXTFONT, TITLE_SIZE, def.name,  CONTENT_W)
    local desc_lines  = self:_MeasureLines(UIFONT,       DESC_SIZE,  desc_text, BODY_W)

    local title_h    = title_lines * LH(TITLE_SIZE) + 2
    local hdr_block_h = LH(DIVIDER_SIZE) + RULE_GAP + 1 + RULE_GAP   
    local desc_h     = math.max(LH(DESC_SIZE), desc_lines * LH(DESC_SIZE))

    local obj_count  = #(def.objectives or {})
    local rwd_count  = #(def.rewards or {}) + (def.random_count or 0)
    local row_h      = LH(LINE_SIZE) + ROW_GAP
    local obj_body_h = math.max(row_h, obj_count * row_h)
    local rwd_body_h = math.max(row_h, rwd_count * row_h)
    local btn_band_h = ITEM_H

    local content_h = title_h + SECTION_GAP
                    + hdr_block_h + desc_h + SECTION_GAP
                    + hdr_block_h + obj_body_h + SECTION_GAP
                    + hdr_block_h + rwd_body_h + SECTION_GAP
                    + btn_band_h
    local detail_h = math.max(360, math.min(600, TOP_RESERVE + content_h + BOT_RESERVE))

    self.panel = self.root:AddChild(TEMPLATES.RectangleWindow(PANEL_W, detail_h))
    self.panel:SetPosition(0, 10)

    local panel_top = detail_h * 0.5
    local panel_bot = -detail_h * 0.5
    local top_y = panel_top - TOP_RESERVE

    local function AddSectionHeader(label, color)
        local hdr = self.panel:AddChild(Text(UIFONT, DIVIDER_SIZE, label))
        hdr:SetRegionSize(CONTENT_W, LH(DIVIDER_SIZE))
        hdr:SetPosition(0, top_y - LH(DIVIDER_SIZE) * 0.5)
        hdr:SetHAlign(ANCHOR_LEFT)
        hdr:SetColour(unpack(color or GOLD))
        table.insert(self.items, hdr)
        top_y = top_y - LH(DIVIDER_SIZE) - RULE_GAP

        
        local rule = self.panel:AddChild(Image("images/global.xml", "square.tex"))
        rule:SetSize(CONTENT_W, 1)
        rule:SetPosition(0, top_y)
        rule:SetTint(0.85, 0.7, 0.4, 0.55)
        table.insert(self.items, rule)
        top_y = top_y - RULE_GAP - 1
    end


    local function AddBodyText(text, font_size, color, body_h)
        local w = self.panel:AddChild(Text(UIFONT, font_size, ""))
        if text and text ~= "" then
            w:SetMultilineTruncatedString(text, 50, BODY_W, nil, false)
        end
        w:SetHAlign(ANCHOR_LEFT)
        w:SetColour(unpack(color))
        local rw = w:GetRegionSize()
        w:SetPosition(BODY_LEFT + rw * 0.5, top_y - body_h * 0.5)
        table.insert(self.items, w)
        top_y = top_y - body_h - SECTION_GAP
    end

    local function AddListRow(label_text, count_text, color, color_count)
        local cy = top_y - LH(LINE_SIZE) * 0.5

        local label_w = self.panel:AddChild(Text(UIFONT, LINE_SIZE, label_text or ""))
        label_w:SetRegionSize(BODY_W, LH(LINE_SIZE))
        label_w:SetPosition(BODY_LEFT + BODY_W * 0.5, cy)
        label_w:SetHAlign(ANCHOR_LEFT)
        label_w:SetColour(unpack(color))
        table.insert(self.items, label_w)

        if count_text and count_text ~= "" then
            local count_w = self.panel:AddChild(Text(UIFONT, LINE_SIZE, count_text))
            count_w:SetRegionSize(BODY_W, LH(LINE_SIZE))
            count_w:SetPosition(BODY_LEFT + BODY_W * 0.5, cy)
            count_w:SetHAlign(ANCHOR_RIGHT)
            count_w:SetColour(unpack(color_count or color))
            table.insert(self.items, count_w)
        end
        top_y = top_y - row_h
    end

    local title = self:_AddWrappedText(BODYTEXTFONT, TITLE_SIZE, def.name,
        CONTENT_W, GOLD, ANCHOR_MIDDLE)
    title:SetPosition(0, top_y - title_h * 0.5)
    top_y = top_y - title_h - SECTION_GAP

    
    AddSectionHeader(L("任务说明", "Description"), GOLD)
    AddBodyText(desc_text, DESC_SIZE, GRAYTXT, desc_h)

    
    AddSectionHeader(L("目标", "Objectives"), WHITE)
    if obj_count == 0 then
        AddListRow(L("（无）", "(none)"), "", GRAY, GRAY)
    else
        for i, obj in ipairs(def.objectives) do
            local total  = obj.count or 1
            local cur    = (progress and progress[i]) or 0
            local done   = is_accepted and cur >= total
            local prefix = obj.is_kill and L("[击杀] ", "[Kill] ") or "· "
            local label  = prefix .. (obj.label or obj.prefab or "?")
            local count
            if is_accepted then
                count = string.format("%d / %d", math.min(cur, total), total)
            else
                count = "x " .. total
            end
            local color = done and GREEN or LINETXT
            AddListRow(label, count, color, color)
        end
    end
    top_y = top_y - SECTION_GAP

    
    AddSectionHeader(L("奖励", "Rewards"), GOLD)
    if rwd_count == 0 then
        AddListRow(L("（无）", "(none)"), "", GRAY, GRAY)
    else
        for _, reward in ipairs(def.rewards) do
            local label = "· " .. (reward.label or reward.prefab or "?")
            local count = "x " .. (reward.count or 1)
            AddListRow(label, count, GREEN, GREEN)
        end
        for i = 1, (def.random_count or 0) do
            AddListRow(L("· ？？？", "· ???"), L("???", "???"), GOLD, GOLD)
        end
    end
    top_y = top_y - SECTION_GAP

    if not is_accepted and is_daily then
        self.accept_btn = self.panel:AddChild(TEMPLATES.StandardButton(
            function() self:AcceptQuest(def.id) end,
            L("接受任务", "Accept Quest"),
            { BTN_PAIR_LEFT_W, BTN_PAIR_H }
        ))
        self.accept_btn:SetPosition(-BTN_PAIR_X_OFFSET, top_y - btn_band_h * 0.5)
        table.insert(self.items, self.accept_btn)

        self.back_btn = self.panel:AddChild(TEMPLATES.StandardButton(
            function() self:BuildBoard() end,
            L("返回", "Back"),
            { BTN_PAIR_RIGHT_W, BTN_PAIR_H }
        ))
        self.back_btn:SetPosition(BTN_PAIR_X_OFFSET, top_y - btn_band_h * 0.5)
        table.insert(self.items, self.back_btn)
    elseif is_accepted then
        self.abandon_btn = self.panel:AddChild(TEMPLATES.StandardButton(
            function() self:AbandonQuest(def.id) end,
            L("删除任务", "Abandon Quest"),
            { BTN_PAIR_LEFT_W, BTN_PAIR_H }
        ))
        self.abandon_btn:SetPosition(-BTN_PAIR_X_OFFSET, top_y - btn_band_h * 0.5)
        table.insert(self.items, self.abandon_btn)

        self.back_btn = self.panel:AddChild(TEMPLATES.StandardButton(
            function() self:BuildBoard() end,
            L("返回", "Back"),
            { BTN_PAIR_RIGHT_W, BTN_PAIR_H }
        ))
        self.back_btn:SetPosition(BTN_PAIR_X_OFFSET, top_y - btn_band_h * 0.5)
        table.insert(self.items, self.back_btn)
    else
        self.back_btn = self.panel:AddChild(TEMPLATES.StandardButton(
            function() self:BuildBoard() end,
            L("返回", "Back"),
            { BTN_ALONE_W, BTN_PAIR_H }
        ))
        self.back_btn:SetPosition(0, top_y - btn_band_h * 0.5)
        table.insert(self.items, self.back_btn)
    end
end





function NPCQuestScreen:ShowDetail(quest_id)
    
    if SendModRPCToServer ~= nil and GetModRPC ~= nil then
        SendModRPCToServer(GetModRPC("NPCFriends", "RequestQuestDetail"), quest_id)
    end
end

function NPCQuestScreen:AcceptQuest(quest_id)
    if SendModRPCToServer ~= nil and GetModRPC ~= nil then
        SendModRPCToServer(GetModRPC("NPCFriends", "AcceptQuest"), quest_id)
    end
    
    self.mode = "board"
end

function NPCQuestScreen:SubmitQuest(quest_id)
    if SendModRPCToServer ~= nil and GetModRPC ~= nil then
        SendModRPCToServer(GetModRPC("NPCFriends", "SubmitQuest"), quest_id)
    end
end

function NPCQuestScreen:AbandonQuest(quest_id)
    if SendModRPCToServer ~= nil and GetModRPC ~= nil then
        SendModRPCToServer(GetModRPC("NPCFriends", "AbandonQuest"), quest_id)
    end
    self.mode = "board"
end


function NPCQuestScreen:ReceiveDetail(payload)
    
    local parts = {}
    for seg in payload:gmatch("[^|]+") do parts[#parts + 1] = seg end
    if #parts < 3 then return end

    local def = {
        id         = parts[1],
        name       = parts[2],
        desc       = parts[3],
        objectives = {},
        rewards    = {},
    }

    local idx = 4
    while idx + 2 <= #parts do
        local obj_prefab = parts[idx]
        if obj_prefab:match("^rwd:") then break end
        if obj_prefab:match("^label:") then break end
        local obj_count = tonumber(parts[idx + 1])
        if not obj_count then break end
        local obj_label = parts[idx + 2]
        
        if obj_label:match("^rwd:") then break end
        def.objectives[#def.objectives + 1] = {
            prefab = obj_prefab,
            count  = obj_count,
            label  = obj_label,
        }
        idx = idx + 3
    end

    while idx + 2 <= #parts do
        local rwd_prefab_raw = parts[idx]
        local rwd_prefab = rwd_prefab_raw:gsub("^rwd:", "")
        
        if rwd_prefab == rwd_prefab_raw then break end
        local rwd_count = tonumber(parts[idx + 1])
        if not rwd_count then break end
        local rwd_label = parts[idx + 2]
        def.rewards[#def.rewards + 1] = {
            prefab = rwd_prefab,
            count  = rwd_count,
            label  = rwd_label,
        }
        idx = idx + 3
    end

    if idx <= #parts then
        local rnd = parts[idx]:match("^rnd:(%d+)")
        if rnd then
            def.random_count = tonumber(rnd) or 0
        end
    end

    self.detail_quest = def
    self:BuildDetail()
end





function NPCQuestScreen:Refresh(quest_payload)
    self:_ParsePayload(quest_payload or "")
    
    self:BuildBoard()
end





function NPCQuestScreen:_ClearPanel()
    if self.items then
        for _, item in ipairs(self.items) do
            if item and item.Kill then
                item:Kill()
            end
        end
        self.items = {}
    end
    if self.panel then
        self.panel:Kill()
        self.panel = nil
    end
end

function NPCQuestScreen:Close()
    if self.owner ~= nil and self.owner.HUD ~= nil and self.owner.HUD._npc_quest_screen == self then
        self.owner.HUD._npc_quest_screen = nil
    end
    if self._npcfriends_attached_to_hud then
        self:Kill()
    else
        TheFrontEnd:PopScreen(self)
    end
end

function NPCQuestScreen:OnControl(control, down)
    if NPCQuestScreen._base.OnControl(self, control, down) then
        return true
    end
    
    
    return false
end

return NPCQuestScreen
