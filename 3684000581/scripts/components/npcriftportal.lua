local _ROOT = _G
local _G = (_ROOT ~= nil and _ROOT.rawget ~= nil and _ROOT.rawget(_ROOT, "GLOBAL")) or _ROOT

local NPC_TUNING = require("npc_tuning")

local function _GetRiftName(inst)
    if inst.components.writeable ~= nil then
        local txt = inst.components.writeable:GetText()
        if txt ~= nil and txt ~= "" then
            txt = string.gsub(txt, "[\r\n\t|]", " ")
            return txt
        end
    end
    return "未命名记忆点"
end

local function _GetWorldLabel()
    if _G.TheWorld ~= nil and _G.TheWorld.HasTag ~= nil and _G.TheWorld:HasTag("cave") then
        return "caves"
    end
    return "master"
end

local NPCRiftPortal = Class(function(self, inst)
    self.inst = inst
end)

function NPCRiftPortal:OpenTravelUI(player)
    if player == nil or player.userid == nil then
        return
    end
    local source = self.inst
    if source == nil or not source:IsValid() then
        return
    end

    local function BuildLocalLines()
        local worldid = (_G.TheShard and _G.TheShard.GetShardId and _G.TheShard:GetShardId()) or "unknown"
        local worldlabel = _GetWorldLabel()
        local rows = {}
        for _, ent in pairs(_G.Ents) do
            if ent ~= nil and ent:IsValid() and ent:HasTag("npc_rift_portal") then
                local x, _, z = ent.Transform:GetWorldPosition()
                rows[#rows + 1] = {
                    guid = _G.tonumber(ent.GUID) or 0,
                    name = _GetRiftName(ent),
                    x = x or 0,
                    z = z or 0,
                }
            end
        end
        table.sort(rows, function(a, b)
            if a.name == b.name then
                return a.guid < b.guid
            end
            return string.lower(a.name) < string.lower(b.name)
        end)
        local parts = {}
        for _, row in ipairs(rows) do
            parts[#parts + 1] = string.format("%s\t%s\t%s\t%.2f\t%.2f", tostring(worldid), tostring(worldlabel), tostring(row.name or ""), row.x, row.z)
        end
        return table.concat(parts, "\n")
    end

    local function SendUI()
        local local_lines = BuildLocalLines()
        if _G.NPCFRIENDS_RIFT_RequestRemoteRows ~= nil then
            _G.NPCFRIENDS_RIFT_RequestRemoteRows(player, self.inst.GUID, local_lines)
            return
        end

        local rows = {}
        local worldid = (_G.TheShard and _G.TheShard.GetShardId and _G.TheShard:GetShardId()) or "unknown"
        local worldlabel = _GetWorldLabel()
        for _, ent in pairs(_G.Ents) do
            if ent ~= nil and ent:IsValid() and ent:HasTag("npc_rift_portal") then
                local x, _, z = ent.Transform:GetWorldPosition()
                rows[#rows + 1] = {
                    guid = _G.tonumber(ent.GUID) or 0,
                    name = _GetRiftName(ent),
                    x = x or 0,
                    z = z or 0,
                }
            end
        end

        table.sort(rows, function(a, b)
            if a.name == b.name then
                return a.guid < b.guid
            end
            return string.lower(a.name) < string.lower(b.name)
        end)

        local parts = {}
        for _, row in ipairs(rows) do
            parts[#parts + 1] = string.format("%s\t%s\t%s\t%.2f\t%.2f", tostring(worldid), tostring(worldlabel), tostring(row.name or ""), row.x, row.z)
        end
        local payload = table.concat(parts, "\n")
        SendModRPCToClient(GetClientModRPC("NPCFriends", "ReceiveRiftList"), player.userid, string.format("%d|%s", self.inst.GUID, payload))
    end

    if player._npc_rift_openui_task ~= nil then
        player._npc_rift_openui_task:Cancel()
        player._npc_rift_openui_task = nil
    end
    player._npc_rift_openui_task = player:DoTaskInTime(0.25, function(p)
        if p ~= nil and p:IsValid() and source ~= nil and source:IsValid() then
            SendUI()
        end
        if p ~= nil then
            p._npc_rift_openui_task = nil
        end
    end)
end

function NPCRiftPortal:TeleportPlayerTo(player, dest_worldid, dest_x, dest_z)
    if player == nil or not player:IsValid() then
        return false
    end
    if dest_x == nil or dest_z == nil then
        return false
    end
    local source = self.inst
    if source == nil or not source:IsValid() then
        return false
    end

    local function StartWormholeJump()
        if not (player:IsValid() and source:IsValid()) then
            return false
        end
        local sx, _, sz = source.Transform:GetWorldPosition()
        local tx, tz = dest_x, dest_z
        local worldid = dest_worldid or ((_G.TheShard and _G.TheShard.GetShardId and _G.TheShard:GetShardId()) or nil)

        -- 出洞点：目标点周围 3~4 格
        local ex, ez = tx, tz
        local same_world = (worldid == nil)
            or (_G.TheShard ~= nil and _G.TheShard.GetShardId ~= nil and tostring(worldid) == tostring(_G.TheShard:GetShardId()))

        -- 消耗玩家饱食度
        if player.components.hunger ~= nil then
            local cost = same_world
                and NPC_TUNING.WANDA_RIFT_HUNGER_COST
                or  NPC_TUNING.WANDA_RIFT_HUNGER_COST_CROSSWORLD
            player.components.hunger:DoDelta(-cost)
        end

        local npc_followers = {}
        local npc_dest_x, npc_dest_z

        if same_world then
            local center = _G.Vector3(tx, 0, tz)
            local offset = _G.FindWalkableOffset(center, math.random() * 2 * math.pi, 3 + math.random(), 16, false, true)
            if offset ~= nil then
                ex = tx + offset.x
                ez = tz + offset.z
            else
                local ang = math.random() * 2 * math.pi
                local r = 3 + math.random()
                ex = tx + math.cos(ang) * r
                ez = tz + math.sin(ang) * r
            end

            -- 同世界传送：收集并隐藏 NPC 跟随者
            -- teleporter:Activate 会自动传送所有跟随者到出口（teleporter.lua:127-133）
            -- 先隐藏 NPC，等玩家落地时（doneteleporting 事件）再播放 NPC 落地动画
            npc_dest_x, npc_dest_z = ex, ez
            for _, ent in pairs(_G.Ents) do
                if ent ~= nil and ent:IsValid() and ent:HasTag("npcfriend")
                    and ent.components.follower
                    and ent.components.follower.leader == player then
                    npc_followers[#npc_followers + 1] = ent
                end
            end
            if #npc_followers > 0 then
                for _, npc in ipairs(npc_followers) do
                    if npc and npc:IsValid() then
                        -- StopLeashing：移除 entitysleep/entitywake 监听 + 取消 porttask
                        -- 防止 TryPorting 干扰（NPC 隐藏在 onActivate 中与玩家同帧执行）
                        if npc.components.follower then
                            npc.components.follower:StopLeashing()
                        end
                        if npc.components.locomotor then npc.components.locomotor:Stop() end
                    end
                end
            end
        else
            local ang = math.random() * 2 * math.pi
            local r = 3 + math.random()
            ex = tx + math.cos(ang) * r
            ez = tz + math.sin(ang) * r
            -- 标记：这是裂缝跨世界传送，目标 shard 到达后补一段出洞演出
            player._npc_rift_arrive_fx_pending = {
                source = "npc_rift_portal",
                worldid = tostring(worldid),
                x = ex,
                z = ez,
            }
        end

        local entrance = _G.SpawnPrefab("pocketwatch_portal_entrance")
        if entrance == nil then
            return false
        end
        entrance.Transform:SetPosition(sx, 0, sz)
        entrance:SpawnExit(worldid, ex, 0, ez)

        -- 同世界 NPC 传送处理
        if same_world and #npc_followers > 0 then
            if player._npc_rift_safety_task then
                player._npc_rift_safety_task:Cancel()
                player._npc_rift_safety_task = nil
            end
            local function RestoreNPCForRift(npc)
                if not (npc and npc:IsValid()) then return end
                if npc._npc_rift_orig_show then
                    npc.Show = npc._npc_rift_orig_show
                    npc._npc_rift_orig_show = nil
                end
                if npc.components and npc.components.talker then
                    if npc._npc_rift_orig_say then
                        npc.components.talker.Say = npc._npc_rift_orig_say
                        npc._npc_rift_orig_say = nil
                    end
                    if npc._npc_rift_orig_chatter then
                        npc.components.talker.Chatter = npc._npc_rift_orig_chatter
                        npc._npc_rift_orig_chatter = nil
                    end
                end
                npc.AnimState:SetMultColour(1, 1, 1, 1)
                if npc.Light then npc.Light:Enable(true) end
            end

            local orig_onActivate = entrance.components.teleporter.onActivate
            entrance.components.teleporter.onActivate = function(inst, doer, migration_data)
                if orig_onActivate then
                    orig_onActivate(inst, doer, migration_data)
                end
                for _, npc in ipairs(npc_followers) do
                    if npc and npc:IsValid() then
                        if not npc._npc_rift_orig_show then
                            npc._npc_rift_orig_show = npc.Show
                            npc.Show = function() end
                        end
                        npc:Hide()
                        npc.AnimState:SetMultColour(1, 1, 1, 0)
                        if npc.DynamicShadow then npc.DynamicShadow:Enable(false) end
                        if npc.Light then npc.Light:Enable(false) end
                        if npc.components and npc.components.talker then
                            npc.components.talker:ShutUp()
                            _G.TheNet:Talker("", npc.entity, 0)
                            if not npc._npc_rift_orig_say then
                                npc._npc_rift_orig_say = npc.components.talker.Say
                                npc.components.talker.Say = function() end
                            end
                            if not npc._npc_rift_orig_chatter then
                                npc._npc_rift_orig_chatter = npc.components.talker.Chatter
                                npc.components.talker.Chatter = function() end
                            end
                        end
                    end
                end
            end

            local exit_portal = entrance.components.teleporter
                and entrance.components.teleporter.targetTeleporter
            if exit_portal then

                exit_portal.components.teleporter.travelarrivetime = 5.5
                exit_portal:ListenForEvent("doneteleporting", function(portal, doer)
                    if doer ~= player then return end
                    doer:DoTaskInTime(0.5, function(p)
                        if not (p and p:IsValid()) then return end
                        for _, npc in ipairs(npc_followers) do
                            if npc and npc:IsValid() then
                                if npc.components.follower then
                                    npc.components.follower:StartLeashing()
                                end
                                if npc.components.follower
                                    and npc.components.follower.leader == p then
                                    if npc.components.locomotor then npc.components.locomotor:Stop() end
                                    local ang = math.random() * 2 * math.pi
                                    local dist = 3 + math.random()
                                    local ox = npc_dest_x + math.cos(ang) * dist
                                    local oz = npc_dest_z + math.sin(ang) * dist
                                    local off = _G.FindWalkableOffset(
                                        _G.Vector3(npc_dest_x, 0, npc_dest_z), ang, dist, 8, false, true)
                                    if off then ox = npc_dest_x + off.x; oz = npc_dest_z + off.z end
                                    npc.Transform:SetPosition(ox, 0, oz)
                                    local fx = _G.SpawnPrefab("pocketwatch_portal_exit_fx")
                                    if fx then
                                        fx.Transform:SetPosition(ox, 4, oz)
                                    end
                                    local is_wanda = npc.npc_character_type == "wanda"
                                    npc:DoTaskInTime(0.05, function(n)
                                        if n == nil or not n:IsValid() then return end
                                        RestoreNPCForRift(n)
                                        n:Hide()
                                        if n.DynamicShadow then n.DynamicShadow:Enable(false) end
                                        if n.sg ~= nil then
                                            n:PushEvent("npc_rift_arrive", { is_wanda = is_wanda })
                                        else
                                            n:Show()
                                            if n.DynamicShadow then n.DynamicShadow:Enable(true) end
                                        end
                                    end)
                                else
                                    RestoreNPCForRift(npc)
                                    npc:Show()
                                    if npc.DynamicShadow then npc.DynamicShadow:Enable(true) end
                                    if npc.components.follower then
                                        npc.components.follower:StartLeashing()
                                    end
                                end
                            end
                        end
                    end)
                end)
            end

            player._npc_rift_safety_task = player:DoTaskInTime(20, function(p)
                if not (p and p:IsValid()) then return end
                p._npc_rift_safety_task = nil
                for _, npc in ipairs(npc_followers) do
                    if npc and npc:IsValid() then
                        if npc.components.follower then
                            npc.components.follower:StartLeashing()
                        end
                        RestoreNPCForRift(npc)
                        npc:Show()
                        if npc.DynamicShadow then npc.DynamicShadow:Enable(true) end
                    end
                end
            end)
        end

        local act = _G.BufferedAction(player, entrance, _G.ACTIONS.JUMPIN)
        player:PushBufferedAction(act)
        return true
    end

    local NEAR_MAX_SQ = 3 * 3
    local function IsNearSource()
        local px, _, pz = player.Transform:GetWorldPosition()
        local sx, _, sz = source.Transform:GetWorldPosition()
        local dx = px - sx
        local dz = pz - sz
        local d2 = (dx * dx + dz * dz)
        return d2 <= NEAR_MAX_SQ
    end

    if player._npc_rift_travel_task ~= nil then
        player._npc_rift_travel_task:Cancel()
        player._npc_rift_travel_task = nil
    end

    if IsNearSource() then
        return StartWormholeJump()
    end

    local started_at = _G.GetTime()
    player._npc_rift_travel_task = player:DoPeriodicTask(0.1, function(p)
        if not (p:IsValid() and source:IsValid()) then
            if p._npc_rift_travel_task ~= nil then
                p._npc_rift_travel_task:Cancel()
                p._npc_rift_travel_task = nil
            end
            return
        end

        if (started_at ~= nil) and (_G.GetTime() - started_at > 10) then
            if p._npc_rift_travel_task ~= nil then
                p._npc_rift_travel_task:Cancel()
                p._npc_rift_travel_task = nil
            end
            return
        end

        if IsNearSource() then
            if p.components.locomotor ~= nil then
                p.components.locomotor:Stop()
            end
            if p._npc_rift_travel_task ~= nil then
                p._npc_rift_travel_task:Cancel()
                p._npc_rift_travel_task = nil
            end
            StartWormholeJump()
        else
            if p.components.locomotor ~= nil then
                local sx, _, sz = source.Transform:GetWorldPosition()
                local px, _, pz = p.Transform:GetWorldPosition()
                local dx = px - sx
                local dz = pz - sz
                local len = math.sqrt(dx * dx + dz * dz)
                local tx, tz
                if len > 0.001 then
                    local nx = dx / len
                    local nz = dz / len
                    tx = sx + nx * 2.5
                    tz = sz + nz * 2.5
                else
                    local ang = math.random() * 2 * math.pi
                    tx = sx + math.cos(ang) * 2.5
                    tz = sz + math.sin(ang) * 2.5
                end
                p.components.locomotor:GoToPoint(_G.Vector3(tx, 0, tz))
            end
        end
    end)
    return true
end

return NPCRiftPortal
