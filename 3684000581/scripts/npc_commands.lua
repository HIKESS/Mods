-- npc_commands.lua
-- NPCFriends 命令处理模块

local NPC_SPEECH = require("npc_speech")
local NPC_TUNING_REF = require("npc_tuning")
local npc_affinity = require("npc/npc_affinity")

local NpcCommands = {}

--------------------------------------------------------------------------
-- 通用辅助函数
--------------------------------------------------------------------------

local function IsWorkToggleCommand(cmd)
    return cmd == "FarmHere"
        or cmd == "CookHere"
        or cmd == "CleanHere"
        or cmd == "ChopHere"
        or cmd == "FishHere"
        or cmd == "OceanFishHere"
        or cmd == "StopWork"
end

local function SetUnrecruitedWander(npc)
    if not npc then return end
    if npc.components.locomotor then
        npc.components.locomotor:Stop()
    end
    if npc.components.follower then
        npc.components.follower:SetLeader(nil)
    end
    npc._owner_userid = nil
    if npc.owner_userid then
        npc.owner_userid:set("")
    end
    local x, _, z = npc.Transform:GetWorldPosition()
    if npc.components.knownlocations then
        npc.components.knownlocations:RememberLocation("home", _G.Vector3(x, 0, z))
    end
    if npc._update_hoverinfo then
        npc._update_hoverinfo()
    end
    if npc.sg and not npc.sg:HasStateTag("dead") then
        npc.sg:GoToState("idle")
    end
end

local function ClearAllWorkCenters(npc)
    if not npc then return end
    npc._woodie_chop_center = nil
    npc._cooking_center = nil
    npc._wes_farm_center = nil
    npc._wes_manual_center = nil
    npc._wes_go_to_farm = false
    npc._wes_iceboxes = nil
    npc._wes_chests = nil
    npc._winona_farm_center = nil
    npc._winona_manual_center = nil
    npc._winona_go_to_farm = false
    npc._winona_iceboxes = nil
    npc._winona_chests = nil
    npc._fishing_active = false
    npc._fishing_catch_count = 0
    npc._fishing_catch_done = false
    npc._fishing_center = nil
    npc._oceanfishing_active = false
    npc._oceanfishing_catch_count = 0
    npc._oceanfishing_center = nil
    if npc._farmer then
        npc._farmer:SetFarmCenter(nil)
        npc._farmer._user_specified_center = false
    end
end

local function SayLine(npc, speech_table, fallback)
    local line = NPC_SPEECH.GetLine(speech_table, npc and npc.npc_character_type)
    if line == nil then
        line = fallback
    end
    if npc ~= nil and npc.components ~= nil and npc.components.talker ~= nil and line ~= nil then
        npc.components.talker:ShutUp()
        npc.components.talker:Say(line)
    end
end

local function SayFormattedLine(npc, speech_table, ...)
    local line = NPC_SPEECH.GetLine(speech_table, npc and npc.npc_character_type)
    if line ~= nil then
        local ok, formatted = _G.pcall(string.format, line, ...)
        line = ok and formatted or line
    end
    if npc ~= nil and npc.components ~= nil and npc.components.talker ~= nil and line ~= nil then
        npc.components.talker:ShutUp()
        npc.components.talker:Say(line)
    end
end

local function GetWickerbottomGrowthCost(npc)
    local base = NPC_TUNING_REF.SCHOLAR_GROWTH_PURPLEGEM_BASE_COST or 1
    local step = NPC_TUNING_REF.SCHOLAR_GROWTH_PURPLEGEM_COST_STEP or 1
    local count = npc ~= nil and _G.tonumber(npc._scholar_growth_cast_count) or 0
    count = math.max(0, math.floor(count or 0))
    return math.max(1, math.floor(base + count * step))
end

local function BuildNPCLocationPayload()
    local parts = {}
    for _, ent in pairs(_G.Ents or {}) do
        if ent ~= nil and ent:IsValid() and ent:HasTag("npcfriend") and not ent:HasTag("npc_no_ui") then
            local char = ent.npc_character_type or "npcfriend"
            local x, _, z = ent.Transform:GetWorldPosition()
            parts[#parts + 1] = string.format("%s,%.2f,%.2f", tostring(char), x, z)
        end
    end
    return table.concat(parts, ";")
end

--------------------------------------------------------------------------
-- COMMAND_HANDLERS 工作好感度消耗
--------------------------------------------------------------------------
local COMMAND_HANDLERS = {}

-- ──────────────────────────────────────────────────────────────
-- 工作好感度消耗（沃利"在此处烹饪" / 植物人"在此处种地"）
--   · 点击停止工作 / 死亡 / 灵魂态 / 移除 时结束计时。
-- ──────────────────────────────────────────────────────────────
local WORK_DRAIN_PERIOD      = 60
local WORK_DRAIN_AMOUNT      = 1
local WORK_DRAIN_MIN         = 5   -- 好感度 < 此值（即 ≤4）自动停工
local WORK_DRAIN_WARN        = 10  -- 好感度 < 此值时，工作中开始喊累
local WORK_TIRED_TALK_PERIOD = 20  -- 坐下后每隔多少秒喊一次累

local function StopWorkAffinityDrain(npc)
    if npc and npc._work_affinity_drain_task then
        npc._work_affinity_drain_task:Cancel()
        npc._work_affinity_drain_task = nil
    end
end

-- 结束"太累了"的持续台词计时
local function StopTiredTalk(npc)
    if npc and npc._npc_tired_talk_task then
        npc._npc_tired_talk_task:Cancel()
        npc._npc_tired_talk_task = nil
    end
end

-- 坐下后持续喊累（直到好感度回升清除 _npc_tired，或被叫去跟随）
local function StartTiredTalk(npc)
    if not npc then return end
    StopTiredTalk(npc)
    npc._npc_tired_talk_task = npc:DoPeriodicTask(WORK_TIRED_TALK_PERIOD, function(n)
        if not n:IsValid() or not n._npc_tired or n._is_ghost_mode
           or (n.components.health and n.components.health:IsDead()) then
            StopTiredTalk(n)
            return
        end
        SayLine(n, NPC_SPEECH.WORK_TIRED_WARN, "我太累了，给我点吃的吧！")
    end)
end

local function EnterTiredSit(npc)
    npc._npc_tired = true
    if npc.sg and not npc._is_ghost_mode
       and not (npc.components.health and npc.components.health:IsDead())
       and npc.sg:HasStateTag("idle") then
        npc.sg:GoToState("idle")  -- 重新进入 idle，触发坐地动画
    end
    StartTiredTalk(npc)
end

local function ClearTiredSit(npc)
    if not npc then return end
    StopTiredTalk(npc)
    npc._npc_tired = false
    npc._npc_tired_sit_variant = nil
    if npc.sg and npc.sg:HasStateTag("idle")
       and not npc._is_ghost_mode
       and not (npc.components.health and npc.components.health:IsDead()) then
        npc.sg:GoToState("idle")  -- 刷新 idle，结束坐地动画
    end
end

local function StartWorkAffinityDrain(npc)
    if not npc then return end
    if not npc_affinity.IsEnabled() then return end
    StopWorkAffinityDrain(npc)
    npc._work_affinity_drain_task = npc:DoPeriodicTask(WORK_DRAIN_PERIOD, function(n)
        if not n:IsValid() or n._is_ghost_mode
           or (n.components.health and n.components.health:IsDead()) then
            StopWorkAffinityDrain(n)
            return
        end
        npc_affinity.AddAffinity(n, -WORK_DRAIN_AMOUNT)
        local aff = npc_affinity.GetAffinity(n)
        if aff < WORK_DRAIN_MIN then
            SayLine(n, NPC_SPEECH.WORK_TIRED_STOP, "我太累了，先歇会儿。")
            COMMAND_HANDLERS.StopWork(nil, n, nil, nil)
            EnterTiredSit(n)
        elseif aff < WORK_DRAIN_WARN then
            SayLine(n, NPC_SPEECH.WORK_TIRED_WARN, "我快撑不住了，喂我点吃的吧！")
        end
    end)
end


function NpcCommands.ResumeWorkDrainOnLoad(npc)
    if not npc or not npc:IsValid() then return end
    if not npc_affinity.IsEnabled() then return end
    if npc._work_paused or npc._is_ghost_mode then return end
    if npc.components.health and npc.components.health:IsDead() then return end
    local manual_working = false
    if npc._is_warly and npc._cooking_center ~= nil then
        manual_working = true
    elseif npc._is_wormwood and npc._farmer and npc._farmer._user_specified_center then
        manual_working = true
    end
    if manual_working then
        StartWorkAffinityDrain(npc)
    end
end

function NpcCommands.ResumeTiredSitOnLoad(npc)
    if not npc or not npc:IsValid() then return end
    if not npc_affinity.IsEnabled() then npc._npc_tired = false; return end
    if not npc._npc_tired then return end
    if npc._is_ghost_mode
       or (npc.components.health and npc.components.health:IsDead()) then
        npc._npc_tired = false
        return
    end
    local need = npc_affinity.GetThreshold(npc.npc_character_type, "work_here")
    if need ~= nil and npc_affinity.GetAffinity(npc) >= need then
        npc._npc_tired = false
        return
    end
    EnterTiredSit(npc)
end

COMMAND_HANDLERS.Follow = function(player, target_npc, owner_param, mod_env)
    local NPC_SPEECH = require("npc_speech")
    if target_npc:HasTag("npc_hostile") then
        return
    end
    if not npc_affinity.MeetsThreshold(target_npc, "follow") then
        return
    end
    local current_leader = target_npc.components.follower and target_npc.components.follower.leader
    if current_leader and current_leader.userid == player.userid then
        target_npc._owner_userid = player.userid
        if target_npc.owner_userid then
            target_npc.owner_userid:set(player.userid or "")
        end
        return
    end
    local max_followers = NPC_TUNING_REF.MAX_NPC_FOLLOWERS or 2
    local cur_count = 0
    if player.components.leader then
        cur_count = player.components.leader:CountFollowers("npcfriend")
    end
    if cur_count >= max_followers then
        if target_npc.components.talker and NPC_SPEECH.RECRUIT_FULL then
            local line = NPC_SPEECH.GetLine(NPC_SPEECH.RECRUIT_FULL, target_npc.npc_character_type)
            if line then target_npc.components.talker:Say(line) end
        end
        if target_npc.sg and target_npc.sg:HasStateTag("idle") and not target_npc._is_ghost_mode then
            target_npc.sg:GoToState("refuseeat")
        end
        return
    end
    if target_npc._oceanfishing_active then
        local inv = target_npc.components.inventory
        if inv then
            local hand = inv:GetEquippedItem(_G.EQUIPSLOTS.HANDS)
            if hand and hand.components.oceanfishingrod then
                hand.components.oceanfishingrod:StopFishing()
            end
        end
        if target_npc.sg and target_npc.sg:HasStateTag("fishing") then
            target_npc.sg:GoToState("idle")
        end
    end
    ClearAllWorkCenters(target_npc)
    -- 太累坐地上时被叫去跟随：起身，进入跟随状态
    ClearTiredSit(target_npc)
    if target_npc.components.follower then
        target_npc.components.follower:SetLeader(player)
        target_npc._owner_userid = player.userid  
        if target_npc.owner_userid then
            target_npc.owner_userid:set(player.userid or "")
        end
    end
    target_npc._work_paused = true
    if target_npc.npc_character_type == "wx78" and target_npc._wx78_spin_work_blocked then
        local WX78Combat = require("npc/characters/wx78")
        if WX78Combat.ClearSpinWorkBlock then
            WX78Combat.ClearSpinWorkBlock(target_npc, "follow_command")
        end
        if target_npc._wx78_spin_block_poll_task ~= nil then
            target_npc._wx78_spin_block_poll_task:Cancel()
            target_npc._wx78_spin_block_poll_task = nil
        end
    end
    if target_npc.components.talker and NPC_SPEECH.FOLLOW then
        local line = NPC_SPEECH.GetLine(NPC_SPEECH.FOLLOW, target_npc.npc_character_type)
        if line then
            target_npc.components.talker:ShutUp()
            target_npc.components.talker:Say(line)
        end
    end
end

COMMAND_HANDLERS.Unfollow = function(player, target_npc, owner_param, mod_env)
    local NPC_SPEECH = require("npc_speech")
    SetUnrecruitedWander(target_npc)
    target_npc._work_paused = true
    if target_npc.components.talker and NPC_SPEECH.DISMISS then
        local line = NPC_SPEECH.GetLine(NPC_SPEECH.DISMISS, target_npc.npc_character_type)
        if line then
            target_npc.components.talker:ShutUp()
            target_npc.components.talker:Say(line)
        end
    end
end

COMMAND_HANDLERS.CreatePool = function(player, target_npc, owner_param, mod_env)
    if target_npc.npc_character_type == "wilson" then
        mod_env.SendModRPCToClient(mod_env.GetClientModRPC("NPCFriends", "StartPoolPlacement"), player.userid, owner_param)
    end
end

COMMAND_HANDLERS.WilsonShowNPCLocations = function(player, target_npc, owner_param, mod_env)
    if target_npc.npc_character_type ~= "wilson" then return end
    if not npc_affinity.MeetsThreshold(target_npc, "show_locations") then
        return
    end
    local inv = target_npc.components.inventory
    if inv == nil then return end

    if not inv:Has("bluegem", 1) then
        SayLine(target_npc, NPC_SPEECH.WILSON_NEED_BLUEGEM_FOR_LOCATIONS, "需要蓝宝石×1。")
        return
    end

    inv:ConsumeByName("bluegem", 1)
    SayLine(target_npc, NPC_SPEECH.WILSON_FOUND_ALL_FRIENDS, "我找到了所有朋友，但只能显示30秒。")
    mod_env.SendModRPCToClient(
        mod_env.GetClientModRPC("NPCFriends", "ShowNPCLocations"),
        player.userid,
        BuildNPCLocationPayload()
    )
end

COMMAND_HANDLERS.OpenRift = function(player, target_npc, owner_param, mod_env)
    local NPC_SPEECH = require("npc_speech")
    if target_npc.npc_character_type == "wanda"
        and not target_npc._is_ghost_mode
        and target_npc.components.health
        and not target_npc.components.health:IsDead() then
        local inv = target_npc.components.inventory
        if inv ~= nil then
            local function SayNeedGem()
                if target_npc.components.talker then
                    local line = NPC_SPEECH.GetLine(NPC_SPEECH.RIFT_NEED_PURPLEGEM, target_npc.npc_character_type)
                    if line then
                        target_npc.components.talker:ShutUp()
                        target_npc.components.talker:Say(line)
                    end
                end
            end

            local function ConsumeOnePurpleGem(item)
                if item == nil then return end
                if item.components.stackable and item.components.stackable:StackSize() > 1 then
                    local one = item.components.stackable:Get(1)
                    if one ~= nil then
                        one:Remove()
                    end
                else
                    local removed = inv:RemoveItem(item, false, true)
                    if removed ~= nil then
                        removed:Remove()
                    else
                        item:Remove()
                    end
                end
            end

            local function GetCastPosAroundNPC()
                local p = target_npc:GetPosition()
                local offset = _G.FindWalkableOffset(p, math.random() * 2 * math.pi, 3 + math.random() * 2, 16, false, true)
                if offset ~= nil then
                    p = p + offset
                end
                return p
            end

            local function DoOpenRiftCast(inst)
                local _inv = inst.components.inventory
                if _inv == nil then return end

                local gem = _inv:FindItem(function(item)
                    return item ~= nil and item:IsValid() and item.prefab == "purplegem"
                end)
                if gem == nil then
                    SayNeedGem()
                    return
                end

                local cast_pos = GetCastPosAroundNPC()
                local ok = false
                local portal = _G.SpawnPrefab("npc_rift_portal")
                if portal ~= nil and portal.Transform ~= nil then
                    portal.Transform:SetPosition(cast_pos:Get())
                    if portal.components.writeable ~= nil then
                        local text = portal.components.writeable:GetText()
                        if text == nil or text == "" then
                            portal.components.writeable:SetText(string.format("Rift %d", _G.tonumber(portal.GUID) or 0))
                        end
                    end
                    inst.SoundEmitter:PlaySound("wanda1/wanda/portal_entrance_pre")
                    ok = true
                end

                if ok then
                    ConsumeOnePurpleGem(gem)
                end
            end

            local precheck_gem = inv:FindItem(function(item)
                return item ~= nil and item:IsValid() and item.prefab == "purplegem"
            end)
            if precheck_gem == nil then
                SayNeedGem()
                return
            end

            local show_watch = inv:FindItem(function(item)
                return item ~= nil and item:IsValid() and (item.prefab == "pocketwatch_heal" or item.prefab == "pocketwatch_weapon")
            end)
            local watch_build = show_watch and show_watch.AnimState and show_watch.AnimState:GetBuild() or "pocketwatch_heal"
            if target_npc.components.talker and NPC_SPEECH.RIFT_OPEN_CAST then
                local line = NPC_SPEECH.GetLine(NPC_SPEECH.RIFT_OPEN_CAST, target_npc.npc_character_type)
                if line then
                    target_npc.components.talker:ShutUp()
                    target_npc.components.talker:Say(line)
                end
            end
            if target_npc.sg ~= nil then
                target_npc._wanda_watch_cast_fn = DoOpenRiftCast
                target_npc.sg:GoToState("wanda_pocketwatch_cast", {
                    apply_event = "wanda_watch_cast_apply",
                    watch_build = watch_build,
                    cast_sound = "wanda2/characters/wanda/watch/MarkPosition",
                })
            else
                DoOpenRiftCast(target_npc)
            end
        end
    end
end

COMMAND_HANDLERS.WickerbottomGrowCrops = function(player, target_npc, owner_param, mod_env)
    if target_npc.npc_character_type ~= "wickerbottom" then return end
    if target_npc._is_ghost_mode then return end
    if target_npc.components.health ~= nil and target_npc.components.health:IsDead() then return end

    local inv = target_npc.components.inventory
    local cost = GetWickerbottomGrowthCost(target_npc)
    if inv == nil or not inv:Has("purplegem", cost) then
        SayFormattedLine(target_npc, NPC_SPEECH.SCHOLAR_GROWTH_NEED_PURPLEGEMS, cost)
        return
    end

    if target_npc.DoWickerbottomGrowCrops ~= nil then
        local started = target_npc:DoWickerbottomGrowCrops()
        if started then
            inv:ConsumeByName("purplegem", cost)
            target_npc._scholar_growth_cast_count = math.max(0, math.floor(_G.tonumber(target_npc._scholar_growth_cast_count) or 0)) + 1
        end
    end
end

COMMAND_HANDLERS.StopWork = function(player, target_npc, owner_param, mod_env)
    target_npc._work_paused = true
    if target_npc._oceanfishing_active then
        target_npc._oceanfishing_active = false
        target_npc._oceanfishing_catch_count = 0
        target_npc._oceanfishing_center = nil
    end
    StopWorkAffinityDrain(target_npc)
    ClearAllWorkCenters(target_npc)
    SetUnrecruitedWander(target_npc)
end

COMMAND_HANDLERS.FarmHere = function(player, target_npc, owner_param, mod_env)
    if target_npc and target_npc._farmer then
        target_npc._work_paused = false
        if target_npc.components.follower and target_npc.components.follower.leader then
            SetUnrecruitedWander(target_npc)
        end
        local nx, _, nz = target_npc.Transform:GetWorldPosition()
        target_npc._farmer:SetFarmCenter({x = nx, z = nz})
        target_npc._farmer._user_specified_center = true
        StartWorkAffinityDrain(target_npc)

        local has_farmland = false
        if target_npc._farmer.all_spots then
            for _, spot in ipairs(target_npc._farmer.all_spots) do
                if spot.soil and spot.soil:IsValid() then
                    has_farmland = true
                    break
                end
            end
        end
        if not has_farmland then
            if target_npc.components.talker then
                if NPC_SPEECH.NO_FARMLAND then
                    local line = NPC_SPEECH.GetLine(NPC_SPEECH.NO_FARMLAND, target_npc.npc_character_type)
                    if line then
                        target_npc.components.talker:Say(line)
                    end
                end
            end
        end
    end
end

COMMAND_HANDLERS.CancelFarm = function(player, target_npc, owner_param, mod_env)
    if target_npc and target_npc._farmer then
        target_npc._farmer:SetFarmCenter(nil)
        target_npc._farmer._user_specified_center = false
    end
end

COMMAND_HANDLERS.CookHere = function(player, target_npc, owner_param, mod_env)
    if target_npc._is_warly then
        target_npc._work_paused = false
        if target_npc.components.follower and target_npc.components.follower.leader then
            SetUnrecruitedWander(target_npc)
        end
        local nx, _, nz = target_npc.Transform:GetWorldPosition()
        target_npc._cooking_center = {x = nx, z = nz}
        StartWorkAffinityDrain(target_npc)

        local range = NPC_TUNING_REF.FARM_WORK_RADIUS or 17
        local pots = _G.TheSim:FindEntities(nx, 0, nz, range, {"stewer"})
        local has_pot = false
        for _, pot in ipairs(pots) do
            if pot:IsValid() and pot.components.stewer then
                has_pot = true
                break
            end
        end
        if not has_pot then
            if target_npc.components.talker then
                if NPC_SPEECH.NO_COOKPOT then
                    local line = NPC_SPEECH.GetLine(NPC_SPEECH.NO_COOKPOT, target_npc.npc_character_type)
                    if line then
                        target_npc.components.talker:Say(line)
                    end
                end
            end
        end
    end
end

COMMAND_HANDLERS.CleanHere = function(player, target_npc, owner_param, mod_env)
    if target_npc._is_wes or target_npc._is_winona then
        target_npc._work_paused = false
        if target_npc.components.follower and target_npc.components.follower.leader then
            SetUnrecruitedWander(target_npc)
        end
        local nx, _, nz = target_npc.Transform:GetWorldPosition()
        if target_npc._is_wes then
            target_npc._wes_farm_center = { x = nx, z = nz }
            target_npc._wes_manual_center = true
            target_npc._wes_go_to_farm = false
        else
            target_npc._winona_farm_center = { x = nx, z = nz }
            target_npc._winona_manual_center = true
            target_npc._winona_go_to_farm = false
        end

        local NPC_TUNING_REF = require("npc_tuning")
        local range = target_npc._is_winona and (NPC_TUNING_REF.WINONA_PATROL_RADIUS or 40)
            or (NPC_TUNING_REF.WES_PATROL_RADIUS or 40)

        local function IsCleanStorageContainer(ent)
            if ent == nil or not ent:IsValid() then return false end
            if ent:HasTag("storagerobot") or ent.prefab == "winona_storage_robot" then return false end
            if ent.prefab == "gelblob_storage" then return false end
            if ent.components == nil or ent.components.container == nil then return false end
            if ent.components.incinerator ~= nil then return false end
            return true
        end

        local iceboxes = {}
        local icebox_ents = _G.TheSim:FindEntities(nx, 0, nz, range, {"fridge"})
        for _, ent in ipairs(icebox_ents) do
            if IsCleanStorageContainer(ent)
               and not ent:HasTag("backpack") then
                table.insert(iceboxes, ent)
            end
        end
        if target_npc._is_wes then
            target_npc._wes_iceboxes = iceboxes
        else
            target_npc._winona_iceboxes = iceboxes
        end

        local chests = {}
        local chest_ents = _G.TheSim:FindEntities(nx, 0, nz, range, {"structure"})
        for _, ent in ipairs(chest_ents) do
            if IsCleanStorageContainer(ent)
               and not ent:HasTag("fridge") and not ent:HasTag("cookpot")
               and not ent:HasTag("stewer") then
                table.insert(chests, ent)
            end
        end
        if target_npc._is_wes then
            target_npc._wes_chests = chests
        else
            target_npc._winona_chests = chests
        end

        local has_container = #iceboxes > 0 or #chests > 0
        if not has_container then
            if target_npc.components.talker then
                if NPC_SPEECH.NO_CONTAINER then
                    local line = NPC_SPEECH.GetLine(NPC_SPEECH.NO_CONTAINER, target_npc.npc_character_type)
                    if line then
                        target_npc.components.talker:Say(line)
                    end
                end
            end
        end
    end
end

COMMAND_HANDLERS.ToggleCollectOrganize = function(player, target_npc, owner_param, mod_env)
    if target_npc == nil or not (target_npc._is_wes or target_npc._is_winona) then
        return
    end
    target_npc._collect_organize_disabled = target_npc._collect_organize_disabled ~= true
end

COMMAND_HANDLERS.ChopHere = function(player, target_npc, owner_param, mod_env)
    if target_npc._is_woodie then
        target_npc._work_paused = false
        local inv = target_npc.components.inventory
        local has_lucy = false
        if inv then
            local hand = inv:GetEquippedItem(_G.EQUIPSLOTS.HANDS)
            has_lucy = (hand and hand.prefab == "lucy")
                or (inv:FindItem(function(item) return item.prefab == "lucy" end) ~= nil)
        end
        
        if not has_lucy then
            if target_npc.components.talker then
                local NPC_SPEECH = require("npc_speech")
                local pool = NPC_SPEECH.CHOP_NO_LUCY
                if pool then
                    local line = NPC_SPEECH.GetLine(pool, target_npc.npc_character_type)
                    if line then
                        target_npc.components.talker:Say(line)
                    end
                end
            end
            return
        end
        
        if target_npc.components.follower and target_npc.components.follower.leader then
            SetUnrecruitedWander(target_npc)
        end
        local nx, _, nz = target_npc.Transform:GetWorldPosition()
        target_npc._woodie_chop_center = { x = nx, z = nz }

        if target_npc.components.talker then
            local NPC_SPEECH = require("npc_speech")
            local pool = NPC_SPEECH.CHOP_HERE_START
            if pool then
                local line = NPC_SPEECH.GetLine(pool, target_npc.npc_character_type)
                if line then
                    target_npc.components.talker:Say(line)
                end
            end
        end
    end
end

-- 吴迪砍树尺寸过滤开关（small/medium/big 各一条）

local function _ToggleChopFilter(target_npc, key)
    if not target_npc or not target_npc._is_woodie then return end
    if target_npc._woodie_chop_filter == nil then
        target_npc._woodie_chop_filter = { small = true, medium = true, big = true }
    end
    local cur = target_npc._woodie_chop_filter[key] ~= false
    target_npc._woodie_chop_filter[key] = not cur
end

COMMAND_HANDLERS.ToggleChopFilterSmall = function(player, target_npc, owner_param, mod_env)
    _ToggleChopFilter(target_npc, "small")
end

COMMAND_HANDLERS.ToggleChopFilterMedium = function(player, target_npc, owner_param, mod_env)
    _ToggleChopFilter(target_npc, "medium")
end

COMMAND_HANDLERS.ToggleChopFilterBig = function(player, target_npc, owner_param, mod_env)
    _ToggleChopFilter(target_npc, "big")
end


COMMAND_HANDLERS.ToggleChopTwiggy = function(player, target_npc, owner_param, mod_env)
    if not target_npc or not target_npc._is_woodie then return end
    target_npc._woodie_chop_twiggy = not (target_npc._woodie_chop_twiggy ~= false)
end

COMMAND_HANDLERS.ToggleDigStump = function(player, target_npc, owner_param, mod_env)
    if not target_npc or not target_npc._is_woodie then return end

    local new_state = not (target_npc._woodie_dig_stump == true)
    target_npc._woodie_dig_stump = new_state

    if new_state then
        local inv = target_npc.components.inventory
        local has_shovel = false
        if inv then
            local hand = inv:GetEquippedItem(_G.EQUIPSLOTS.HANDS)
            has_shovel = (hand and (hand.prefab == "shovel" or hand.prefab == "goldenshovel"))
                or (inv:FindItem(function(item)
                    return item.prefab == "shovel" or item.prefab == "goldenshovel"
                end) ~= nil)
        end

        if not has_shovel and target_npc.components.talker then
            local pool = NPC_SPEECH.DIG_NO_SHOVEL
            if pool then
                local line = NPC_SPEECH.GetLine(pool, target_npc.npc_character_type)
                if line then
                    target_npc.components.talker:Say(line)
                end
            end
        end
    end
end

COMMAND_HANDLERS.FishHere = function(player, target_npc, owner_param, mod_env)
    if target_npc._fishing_active then
        target_npc._fishing_active = false
        return
    end

    -- 好感度门槛：好感度 >= 50 才能开启钓鱼
    if not npc_affinity.MeetsThreshold(target_npc, "fishing") then
        return
    end

    local inv = target_npc.components.inventory
    local has_rod = false
    if inv then
        local hand = inv:GetEquippedItem(_G.EQUIPSLOTS.HANDS)
        has_rod = (hand and (hand.prefab == "fishingrod" or hand:HasTag("fishingrod")))
            or (inv:FindItem(function(item)
                return item.prefab == "fishingrod" or item:HasTag("fishingrod")
            end) ~= nil)
    end

    if not has_rod then
        if target_npc.components.talker and NPC_SPEECH.FISHING_NO_ROD then
            local line = NPC_SPEECH.GetLine(NPC_SPEECH.FISHING_NO_ROD, target_npc.npc_character_type)
            if line then
                target_npc.components.talker:Say(line)
            end
        end
        return
    end

    target_npc._work_paused = false
    if target_npc.components.follower and target_npc.components.follower.leader then
        SetUnrecruitedWander(target_npc)
    end
    ClearAllWorkCenters(target_npc)
    target_npc._fishing_active = true
    target_npc._fishing_catch_count = 0
    target_npc._fishing_catch_done = false
    local nx, _, nz = target_npc.Transform:GetWorldPosition()
    target_npc._fishing_center = { x = nx, z = nz }
end

COMMAND_HANDLERS.OceanFishHere = function(player, target_npc, owner_param, mod_env)
    if target_npc._oceanfishing_active then
        target_npc._oceanfishing_active = false
        target_npc._oceanfishing_catch_count = 0
        target_npc._oceanfishing_center = nil
        if target_npc.components.talker and NPC_SPEECH.OCEAN_FISHING_DONE then
            local line = NPC_SPEECH.GetLine(NPC_SPEECH.OCEAN_FISHING_DONE, target_npc.npc_character_type)
            if line then
                target_npc.components.talker:Say(line)
            end
        end
        return
    end

    -- 好感度门槛：达到钓鱼门槛才能开启海钓（未配置角色默认放行）
    if not npc_affinity.MeetsThreshold(target_npc, "fishing") then
        return
    end

    local inv = target_npc.components.inventory
    local has_rod = false
    if inv then
        local hand = inv:GetEquippedItem(_G.EQUIPSLOTS.HANDS)
        has_rod = (hand and (hand.prefab == "oceanfishingrod" or hand:HasTag("oceanfishingrod")))
            or (inv:FindItem(function(item)
                return item.prefab == "oceanfishingrod" or item:HasTag("oceanfishingrod")
            end) ~= nil)
    end

    if not has_rod then
        if target_npc.components.talker and NPC_SPEECH.OCEAN_FISHING_NO_ROD then
            local line = NPC_SPEECH.GetLine(NPC_SPEECH.OCEAN_FISHING_NO_ROD, target_npc.npc_character_type)
            if line then
                target_npc.components.talker:Say(line)
            end
        end
        return
    end

    local free_slots = 0
    if inv then
        for i = 1, (inv.maxslots or 0) do
            if not inv:GetItemInSlot(i) then
                free_slots = free_slots + 1
            end
        end
    end
    if free_slots < 7 then
        local NPC_SPEECH = require("npc_speech")
        if target_npc.components.talker and NPC_SPEECH.OCEAN_FISHING_NO_SPACE then
            local line = NPC_SPEECH.GetLine(NPC_SPEECH.OCEAN_FISHING_NO_SPACE, target_npc.npc_character_type)
            if line then target_npc.components.talker:Say(line) end
        end
        return
    end

    target_npc._work_paused = false
    if target_npc._fishing_active then
        target_npc._fishing_active = false
        target_npc._fishing_catch_count = 0
        target_npc._fishing_catch_done = false
        target_npc._fishing_center = nil
    end
    if target_npc.components.follower and target_npc.components.follower.leader then
        SetUnrecruitedWander(target_npc)
    end
    ClearAllWorkCenters(target_npc)
    target_npc._oceanfishing_active = true
    target_npc._oceanfishing_catch_count = 0
    local nx, _, nz = target_npc.Transform:GetWorldPosition()
    target_npc._oceanfishing_center = _G.Vector3(nx, 0, nz)

    if target_npc.components.talker and NPC_SPEECH.OCEAN_FISHING_START then
        local line = NPC_SPEECH.GetLine(NPC_SPEECH.OCEAN_FISHING_START, target_npc.npc_character_type)
        if line then
            target_npc.components.talker:Say(line)
        end
    end
end

local function HandlePlaceDevice(player, target_npc, owner_param, mod_env, command)
    if target_npc.npc_character_type == "winona" then
        local device_map = {
            PlaceGenerator = "generator",
            PlaceSpotlight = "spotlight",
            PlaceCatapult  = "catapult",
        }
        local device_type = device_map[command]
        mod_env.SendModRPCToClient(
            mod_env.GetClientModRPC("NPCFriends", "StartWinonaPlacement"),
            player.userid,
            owner_param .. "|" .. device_type
        )
    end
end

COMMAND_HANDLERS.PlaceGenerator = function(player, target_npc, owner_param, mod_env)
    HandlePlaceDevice(player, target_npc, owner_param, mod_env, "PlaceGenerator")
end

COMMAND_HANDLERS.PlaceSpotlight = function(player, target_npc, owner_param, mod_env)
    HandlePlaceDevice(player, target_npc, owner_param, mod_env, "PlaceSpotlight")
end

COMMAND_HANDLERS.PlaceCatapult = function(player, target_npc, owner_param, mod_env)
    HandlePlaceDevice(player, target_npc, owner_param, mod_env, "PlaceCatapult")
end

COMMAND_HANDLERS.OpenQuest = function(player, target_npc, owner_param, mod_env)
    if target_npc.npc_character_type ~= "wilba" then return end
    local QuestManager = require("npc/npc_quest_manager")
    QuestManager.RefreshDailyQuests(player)
    QuestManager.RecomputeFromWilba(player, target_npc)
    local daily = QuestManager.GetDailyQuests(player)
    local accepted = QuestManager.GetAcceptedQuests(player)

    -- 构建每日任务字符串
    local daily_parts = {}
    for _, q in ipairs(daily) do
        daily_parts[#daily_parts + 1] = q.id .. "|" .. (q.name or q.id)
    end
    local daily_str = table.concat(daily_parts, ";")

    -- 构建已接任务字符串
    local accepted_parts = {}
    for _, q in ipairs(accepted) do
        local progress_str = ""
        if q.progress then
            local prog_parts = {}
            for _, v in pairs(q.progress) do
                prog_parts[#prog_parts + 1] = tostring(v)
            end
            progress_str = table.concat(prog_parts, ",")
        end
        accepted_parts[#accepted_parts + 1] = q.id .. "|" .. (q.name or q.id) .. "|" .. progress_str .. "|" .. tostring(q.completed == true)
    end
    local accepted_str = table.concat(accepted_parts, ";")

    local payload = daily_str .. "\n" .. accepted_str .. "\nmax_active=" .. tostring(NPC_TUNING_REF.MAX_ACTIVE_QUESTS or 4)
    mod_env.SendModRPCToClient(
        mod_env.GetClientModRPC("NPCFriends", "ShowQuestScreen"),
        player.userid,
        payload
    )
end

COMMAND_HANDLERS.BuildWaxwellMagicChest = function(player, target_npc, owner_param, mod_env)
    if target_npc.npc_character_type ~= "waxwell" then return end
    mod_env.SendModRPCToClient(
        mod_env.GetClientModRPC("NPCFriends", "StartWaxwellMagicChestPlacement"),
        player.userid,
        owner_param
    )
end

local _HasRecipeMaterials
local _ConsumeRecipeMaterials
local _GiveCraftedItem
local _CraftInventoryItem

COMMAND_HANDLERS.WinonaCraftTape = function(player, target_npc, owner_param, mod_env)
    _CraftInventoryItem(
        target_npc,
        "winona",
        "winona_tape",
        "WINONA_NO_MATERIAL_TAPE",
        "制作胶带需要：蜘蛛丝×1、干草×3",
        "Tape needs: Silk x1, Cut Grass x3"
    )
end

local function _CraftWillowItem(target_npc, recipe_key, speech_key, fallback_zh, fallback_en)
    _CraftInventoryItem(target_npc, "willow", recipe_key, speech_key, fallback_zh, fallback_en)
end

COMMAND_HANDLERS.WillowCraftRainbowFireflies = function(player, target_npc, owner_param, mod_env)
    _CraftWillowItem(
        target_npc,
        "willow_rainbow_fireflies",
        "WILLOW_NO_MATERIAL_RAINBOW_FIREFLIES",
        "制作七彩萤火虫需要：红宝石×1",
        "Rainbow Fireflies need: Red Gem x1"
    )
end

function _HasRecipeMaterials(inv, recipe)
    if inv == nil or recipe == nil or recipe.materials == nil then return false end
    for _, mat in ipairs(recipe.materials) do
        if not inv:Has(mat.name, mat.count) then
            return false
        end
    end
    return true
end

function _ConsumeRecipeMaterials(inv, recipe)
    for _, mat in ipairs(recipe.materials) do
        inv:ConsumeByName(mat.name, mat.count)
    end
end

function _GiveCraftedItem(npc, inv, prefab, count)
    local item = _G.SpawnPrefab(prefab)
    if item == nil then return end

    if count ~= nil and count > 1 and item.components.stackable ~= nil then
        item.components.stackable:SetStackSize(count)
    end

    if not inv:GiveItem(item) then
        local x, y, z = npc.Transform:GetWorldPosition()
        item.Transform:SetPosition(x, y, z)
        if item.components.inventoryitem then
            item.components.inventoryitem:DoDropPhysics(x, y, z, true)
        end
    end
end

function _CraftInventoryItem(target_npc, expected_char_type, recipe_key, speech_key, fallback_zh, fallback_en, success_speech_key)
    if target_npc.npc_character_type ~= expected_char_type then return end
    if target_npc._npc_crafting_item ~= nil then return end
    local inv = target_npc.components.inventory
    if inv == nil then return end

    local NPC_SR = require("npc_speech")
    local recipe = NPC_TUNING_REF.CRAFT_RECIPES[recipe_key]
    if not _HasRecipeMaterials(inv, recipe) then
        local char_type = target_npc.npc_character_type or "_default"
        local pool = NPC_SR[speech_key]
        local msg = NPC_SR.GetLine(pool, char_type)
                 or NPC_SR.GetLine(pool, "_default")
                 or (NPC_SR._is_chinese and fallback_zh or fallback_en)
        if target_npc.components.talker and msg ~= nil then
            target_npc.components.talker:Say(msg)
        end
        return
    end

    if target_npc.sg then
        local inv_ref = inv
        target_npc._npc_crafting_item = recipe_key
        target_npc.sg:GoToState("wathgrithr_craft", {
            crafting_lock = true,
            on_done = function(npc)
                if not _HasRecipeMaterials(inv_ref, recipe) then return end
                _ConsumeRecipeMaterials(inv_ref, recipe)
                _GiveCraftedItem(npc, inv_ref, recipe.product, recipe.count or 1)
                if success_speech_key then
                    SayLine(npc, NPC_SR[success_speech_key])
                end
            end,
        })
    else
        _ConsumeRecipeMaterials(inv, recipe)
        _GiveCraftedItem(target_npc, inv, recipe.product, recipe.count or 1)
        if success_speech_key then
            SayLine(target_npc, NPC_SR[success_speech_key])
        end
    end
end

local function _UnlockWilsonTransmuteTech(target_npc)
    if target_npc.npc_character_type ~= "wilson" then return end
    if target_npc._npc_crafting_item ~= nil then return end
    if target_npc._is_ghost_mode then return end
    if target_npc.components.health and target_npc.components.health:IsDead() then return end

    local inv = target_npc.components.inventory
    if inv == nil then return end

    if target_npc._wilson_transmute_unlocked == true then
        SayLine(target_npc, NPC_SPEECH.WILSON_TRANSMUTE_ALREADY_UNLOCKED)
        return
    end

    if not inv:Has("opalpreciousgem", 1) then
        SayLine(target_npc, NPC_SPEECH.WILSON_TRANSMUTE_NO_OPAL)
        return
    end

    if target_npc.sg then
        local inv_ref = inv
        target_npc._npc_crafting_item = "wilson_unlock_transmute"
        target_npc.sg:GoToState("wathgrithr_craft", {
            crafting_lock = true,
            on_done = function(npc)
                if npc._wilson_transmute_unlocked == true then return end
                if inv_ref == nil or not inv_ref:Has("opalpreciousgem", 1) then return end
                inv_ref:ConsumeByName("opalpreciousgem", 1)
                npc._wilson_transmute_unlocked = true
                SayLine(npc, NPC_SPEECH.WILSON_TRANSMUTE_UNLOCKED)
            end,
        })
    else
        inv:ConsumeByName("opalpreciousgem", 1)
        target_npc._wilson_transmute_unlocked = true
        SayLine(target_npc, NPC_SPEECH.WILSON_TRANSMUTE_UNLOCKED)
    end
end

local function _CraftWilsonTransmuteItem(target_npc, recipe_key, no_material_speech_key, success_speech_key)
    if target_npc.npc_character_type ~= "wilson" then return end
    local unlocked = target_npc._wilson_transmute_unlocked == true
    local affinity_pass = npc_affinity.IsEnabled() and npc_affinity.MeetsThreshold(target_npc, "craft")
    if not unlocked and not affinity_pass then
        SayLine(target_npc, NPC_SPEECH.WILSON_TRANSMUTE_LOCKED)
        return
    end
    _CraftInventoryItem(target_npc, "wilson", recipe_key, no_material_speech_key, nil, nil, success_speech_key)
end

COMMAND_HANDLERS.UnlockWilsonTransmuteTech = function(player, target_npc, owner_param, mod_env)
    if not npc_affinity.MeetsThreshold(target_npc, "craft") then
        return
    end
    _UnlockWilsonTransmuteTech(target_npc)
end

COMMAND_HANDLERS.WilsonCraftPureBrilliance = function(player, target_npc, owner_param, mod_env)
    if not npc_affinity.MeetsThreshold(target_npc, "craft") then
        return
    end
    _CraftWilsonTransmuteItem(
        target_npc,
        "wilson_purebrilliance",
        "WILSON_NO_MATERIAL_PUREBRILLIANCE",
        "WILSON_CRAFTED_PUREBRILLIANCE"
    )
end

COMMAND_HANDLERS.WilsonCraftHorrorfuel = function(player, target_npc, owner_param, mod_env)
    if not npc_affinity.MeetsThreshold(target_npc, "craft") then
        return
    end
    _CraftWilsonTransmuteItem(
        target_npc,
        "wilson_horrorfuel",
        "WILSON_NO_MATERIAL_HORRORFUEL",
        "WILSON_CRAFTED_HORRORFUEL"
    )
end

local function _CraftWalterAmmo(target_npc, recipe_key, speech_key)
    _CraftInventoryItem(target_npc, "walter", recipe_key, speech_key)
end

COMMAND_HANDLERS.WalterCraftGoldAmmo = function(player, target_npc, owner_param, mod_env)
    _CraftWalterAmmo(target_npc, "walter_ammo_gold", "WALTER_NO_MATERIAL_AMMO_GOLD")
end

COMMAND_HANDLERS.WalterCraftScrapfeatherAmmo = function(player, target_npc, owner_param, mod_env)
    _CraftWalterAmmo(target_npc, "walter_ammo_scrapfeather", "WALTER_NO_MATERIAL_AMMO_SCRAPFEATHER")
end

COMMAND_HANDLERS.WalterCraftThuleciteAmmo = function(player, target_npc, owner_param, mod_env)
    _CraftWalterAmmo(target_npc, "walter_ammo_thulecite", "WALTER_NO_MATERIAL_AMMO_THULECITE")
end

COMMAND_HANDLERS.WalterCraftHorrorfuelAmmo = function(player, target_npc, owner_param, mod_env)
    _CraftWalterAmmo(target_npc, "walter_ammo_horrorfuel", "WALTER_NO_MATERIAL_AMMO_HORRORFUEL")
end

COMMAND_HANDLERS.WalterCraftFreezeAmmo = function(player, target_npc, owner_param, mod_env)
    _CraftWalterAmmo(target_npc, "walter_ammo_freeze", "WALTER_NO_MATERIAL_AMMO_FREEZE")
end

COMMAND_HANDLERS.WalterCraftSlowAmmo = function(player, target_npc, owner_param, mod_env)
    _CraftWalterAmmo(target_npc, "walter_ammo_slow", "WALTER_NO_MATERIAL_AMMO_SLOW")
end

local function _CraftWonkeyItem(target_npc, recipe_key, speech_key, fallback_zh, fallback_en)
    _CraftInventoryItem(target_npc, "wonkey", recipe_key, speech_key, fallback_zh, fallback_en)
end

COMMAND_HANDLERS.WonkeyCraftBananaBush = function(player, target_npc, owner_param, mod_env)
    _CraftWonkeyItem(
        target_npc,
        "wonkey_bananabush",
        "WONKEY_NO_MATERIAL_BANANABUSH",
        "制作香蕉丛种子需要：香蕉×10",
        "Banana Bush needs: Banana x10"
    )
end

COMMAND_HANDLERS.WonkeyCraftMonkeytail = function(player, target_npc, owner_param, mod_env)
    _CraftWonkeyItem(
        target_npc,
        "wonkey_monkeytail",
        "WONKEY_NO_MATERIAL_MONKEYTAIL",
        "制作猴尾草苗需要：芦苇×10",
        "Monkeytail Sapling needs: Reeds x10"
    )
end

COMMAND_HANDLERS.WonkeyCraftAncienttreeSeed = function(player, target_npc, owner_param, mod_env)
    _CraftWonkeyItem(
        target_npc,
        "wonkey_ancienttree_seed",
        "WONKEY_NO_MATERIAL_ANCIENTTREE_SEED",
        "制作惊喜种子需要：红宝石×2、蓝宝石×2",
        "Surprise Seed needs: Red Gem x2, Blue Gem x2"
    )
end

COMMAND_HANDLERS.ToggleWalterAutoStory = function(player, target_npc, owner_param, mod_env)
    if target_npc.npc_character_type ~= "walter" then
        return
    end
    if target_npc._is_ghost_mode
        or (target_npc.components.health ~= nil and target_npc.components.health:IsDead()) then
        return
    end
    target_npc._walter_auto_story_enabled = not target_npc._walter_auto_story_enabled
    if not target_npc._walter_auto_story_enabled
        and target_npc.components.storyteller ~= nil
        and target_npc.components.storyteller:IsTellingStory() then
        target_npc.components.storyteller:AbortStory()
    end
    if not target_npc._walter_auto_story_enabled then
        target_npc._npc_walter_story_lock_mount = nil
        target_npc._npc_walter_story_lock_until = nil
    end
    if target_npc.components.talker ~= nil then
        local pool = target_npc._walter_auto_story_enabled
            and NPC_SPEECH.WALTER_AUTO_STORY_ON
            or NPC_SPEECH.WALTER_AUTO_STORY_OFF
        local line = NPC_SPEECH.GetLine(pool, target_npc.npc_character_type)
        if line ~= nil then
            target_npc.components.talker:Say(line)
        end
    end
end

-- WX-78：在 NPC 身旁部署一台运输机（便携储存单元），并打上公共标记，
-- 让任意玩家都能开盖装物 + 通过地图发送（门控放开见 modmain 的 AddPrefabPostInit）。
local function _SpawnWX78TransportDrone(npc)
    local pt = npc:GetPosition()
    local offset = _G.FindWalkableOffset(pt, math.random() * 2 * math.pi, 2, 12, false, true)
    if offset ~= nil then
        pt = pt + offset
    end

    local drone = _G.SpawnPrefab("wx78_drone_delivery")
    if drone == nil then return end

    drone.Transform:SetPosition(pt:Get())
    drone:AddTag("npcfriend_publicdrone")
    drone:PushEvent("onbuilt")
end

COMMAND_HANDLERS.WX78CraftTransportDrone = function(player, target_npc, owner_param, mod_env)
    if target_npc.npc_character_type ~= "wx78" then return end
    if target_npc._is_ghost_mode then return end
    if target_npc.components.health ~= nil and target_npc.components.health:IsDead() then return end
    if target_npc._npc_crafting_item ~= nil then return end

    local inv = target_npc.components.inventory
    if inv == nil then return end

    local recipe = NPC_TUNING_REF.CRAFT_RECIPES.wx78_transport_drone
    if not _HasRecipeMaterials(inv, recipe) then
        SayLine(target_npc, NPC_SPEECH.WX78_NO_MATERIAL_TRANSPORT_DRONE, "制作运输机需要：齿轮×1、木板×3。")
        return
    end

    local function DoCraft(npc)
        if not _HasRecipeMaterials(inv, recipe) then return end
        _ConsumeRecipeMaterials(inv, recipe)
        _SpawnWX78TransportDrone(npc)
    end

    if target_npc.sg then
        target_npc._npc_crafting_item = "wx78_transport_drone"
        target_npc.sg:GoToState("wathgrithr_craft", {
            crafting_lock = true,
            on_done = DoCraft,
        })
    else
        DoCraft(target_npc)
    end
end

COMMAND_HANDLERS.WathgrithrCraftSpear = function(player, target_npc, owner_param, mod_env)
    _CraftInventoryItem(
        target_npc,
        "wathgrithr",
        "wathgrithr_spear",
        "WATHGRITHR_NO_MATERIAL_SPEAR",
        "制作战斗长矛需要：树枝×2、燧石×2、金块×2",
        "Need Twigs x2, Flint x2, Gold x2"
    )
end

COMMAND_HANDLERS.WathgrithrCraftHelmet = function(player, target_npc, owner_param, mod_env)
    _CraftInventoryItem(
        target_npc,
        "wathgrithr",
        "wathgrithr_helmet",
        "WATHGRITHR_NO_MATERIAL_HELMET",
        "制作战斗头盔需要：金块×2、石头×2",
        "Need Gold x2, Rocks x2"
    )
end

--------------------------------------------------------------------------
-- 主入口：HandleCommand
--------------------------------------------------------------------------
function NpcCommands.HandleCommand(player, params_str, mod_env)
    if not _G.TheWorld.ismastersim then return end
    if not player or not params_str then return end

    -- 解析参数: "command|owner_userid:char_type:slot_index"
    local command, owner_param = params_str:match("^([^|]+)|(.+)$")
    if not command or not owner_param then return end

    local parts = {}
    for seg in owner_param:gmatch("[^:]+") do parts[#parts + 1] = seg end
    local owner_userid = parts[1]
    local char_type = parts[2]
    local slot_index = _G.tonumber(parts[3])

    local target_npc = nil
    local owner_fallback = nil  -- owner匹配但无精确slot的后备
    local type_fallback = nil   -- 仅char_type+slot匹配的后备（无owner匹配，用于未跟随NPC）
    local any_npc_fallback = nil -- 最后关头：任意 NPC（无任何条件匹配时返回第一个）

    for _, ent in pairs(_G.Ents) do
        if ent:IsValid() and ent:HasTag("npcfriend") then
            if any_npc_fallback == nil then
                any_npc_fallback = ent
            end

            local leader = ent.components.follower and ent.components.follower.leader
            local ent_owner = ent.owner_userid and ent.owner_userid:value()
            local leader_match = leader and leader.userid == owner_userid
            local owner_match = ent_owner and ent_owner ~= "" and ent_owner == owner_userid

            if leader_match or owner_match then
                if slot_index and ent.npc_slot_index == slot_index then
                    target_npc = ent
                    break
                end
                if char_type and ent.npc_character_type == char_type and owner_fallback == nil then
                    owner_fallback = ent
                elseif owner_fallback == nil then
                    owner_fallback = ent  -- 无筛选条件，返回第一个
                end
            else
                if slot_index and ent.npc_slot_index == slot_index then
                    if char_type and ent.npc_character_type == char_type then
                        type_fallback = ent  -- char_type + slot都匹配
                    elseif type_fallback == nil then
                        type_fallback = ent  -- 仅slot匹配
                    end
                elseif char_type and ent.npc_character_type == char_type then
                    if type_fallback == nil then
                        type_fallback = ent  -- 仅char_type匹配
                    end
                end
            end
        end
    end

    if command == "Follow" then
        target_npc = target_npc or type_fallback or owner_fallback or any_npc_fallback
    else
        target_npc = target_npc or owner_fallback or type_fallback or any_npc_fallback
    end

    if not target_npc then
        print("[NPCCommand] Failed to find NPC: owner=" .. tostring(owner_userid)
            .. " char=" .. tostring(char_type)
            .. " slot=" .. tostring(slot_index))
        return
    end

    local leader = target_npc.components.follower and target_npc.components.follower.leader
    local actual_owner = target_npc._owner_userid
        or (target_npc.owner_userid and target_npc.owner_userid:value() ~= "" and target_npc.owner_userid:value())
        or nil
    local is_owner   = actual_owner and actual_owner ~= "" and actual_owner == player.userid
    local is_leader  = leader and leader.userid == player.userid
    local npc_is_free = (actual_owner == nil or actual_owner == "") and leader == nil

    if not is_owner and not is_leader and not npc_is_free then
        if command == "Follow" and leader == nil then
        else
            return  
        end
    end

    if IsWorkToggleCommand(command) then
        local now = _G.GetTime()
        local cooldown = 0.25
        target_npc._work_toggle_cd_until = target_npc._work_toggle_cd_until or 0
        if now < target_npc._work_toggle_cd_until then
            return
        end
        target_npc._work_toggle_cd_until = now + cooldown
    end


    if not npc_affinity.CommandUnlocked(target_npc, command) then
        if target_npc.sg and target_npc.sg:HasStateTag("idle") and not target_npc._is_ghost_mode then
            target_npc.sg:GoToState("refuseeat")
        end
        return
    end

    local handler = COMMAND_HANDLERS[command]
    if handler then
        handler(player, target_npc, owner_param, mod_env)
    end
end

return NpcCommands
