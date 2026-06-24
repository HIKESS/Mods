-- scripts/stategraphs/SGnpcfriend.lua
-- NPC 伙伴专用状态图
-- 设计原则：使用玩家角色标准动画名（idle_loop / walk_loop / run_loop 等），
-- 不依赖猪人或玩家专属 API，所有角色外观（Wilson/Wendy/...）通用。

require("stategraphs/commonstates")

local NPC_TUNING   = require("npc_tuning")
local NPC_SPEECH   = require("npc_speech")
local InvUtil      = require("npc/npc_inventory_util")
local NPC_UTILS    = require("npc/npc_utils")
local SGNPCCommon  = require("stategraphs/sg_npc_common")
local WalterCombat = require("npc/characters/walter")
local WX78Combat   = require("npc/characters/wx78")
local WurtCombat   = require("npc/characters/wurt_combat")
local WobyRide     = require("npc/npc_woby_ride")

local function IsHardDeathLocked(inst)
    local state = inst.sg ~= nil and inst.sg.currentstate ~= nil and inst.sg.currentstate.name or nil
    return (inst.components.health ~= nil and inst.components.health:IsDead())
        or (inst.sg ~= nil and inst.sg:HasStateTag("dead"))
        or state == "death"
        or state == "corpse"
        or state == "ghost_despawn"
        or state == "revive_from_ghost"
end

local function IsDeathGhostLocked(inst)
    return inst._is_ghost_mode or inst:HasTag("ghost") or IsHardDeathLocked(inst)
end

local function IsWalterWobyActionLocked(inst)
    return inst._npc_woby_ride_disabled
        or inst._npc_reviving_from_ghost
        or IsDeathGhostLocked(inst)
end

-- 砍树自循环让位判断：chop 状态会高速自循环连续砍树。当大脑已改派"非砍树"的活
-- （典型是玩家切去挖矿、大脑下达 MINE）时，自循环应立刻停下回 idle，让那个动作得以执行，
-- 从而实现砍树↔挖矿的顺滑切换，且不会把大脑刚下的动作清掉。
-- 注意：尚未走到目标旁的动作存放在 locomotor.bufferedaction，到位后才转入 inst.bufferedaction，
-- 两处都要看，否则 NPC 还在走去矿点的途中就检测不到、继续锁死在砍树。
local function NPCChopShouldYield(inst)
    local ba = inst.bufferedaction
    if ba ~= nil and ba.action ~= ACTIONS.CHOP then
        return true
    end
    local lm = inst.components ~= nil and inst.components.locomotor or nil
    local lba = lm ~= nil and lm.bufferedaction or nil
    if lba ~= nil and lba.action ~= ACTIONS.CHOP then
        return true
    end
    return false
end

local function WandaReviveDbg(inst, fmt, ...)
    if not (NPC_TUNING and NPC_TUNING.WANDA_REVIVE_DEBUG) then
        return
    end
    if not inst or inst.npc_character_type ~= "wanda" then
        return
    end
    local ok, msg = pcall(string.format, fmt, ...)
    if not ok then
        msg = tostring(fmt)
    end
    local build = (inst.AnimState and inst.AnimState.GetBuild and inst.AnimState:GetBuild()) or "?"
    local state = (inst.sg and inst.sg.currentstate and inst.sg.currentstate.name) or "?"
    print(string.format("[NPCFriends][WandaRevive][%s] %s | state=%s build=%s ghost=%s",
        tostring(inst.GUID), msg, tostring(state), tostring(build), tostring(inst._is_ghost_mode)))
end

local function SafeAnimValue(inst, method)
    if inst == nil or inst.AnimState == nil or inst.AnimState[method] == nil then
        return "?"
    end
    local ok, value = pcall(inst.AnimState[method], inst.AnimState)
    return ok and tostring(value) or "?"
end

local function WalterStateDbg(inst, label, ...)
    if not (NPC_TUNING and NPC_TUNING.DEBUG_WALTER) then
        return
    end
    if inst == nil or inst.npc_character_type ~= "walter" then
        return
    end
    local combat = inst.components ~= nil and inst.components.combat or nil
    local rider = inst.components ~= nil and inst.components.rider or nil
    local mount = rider ~= nil and rider:IsRiding() and rider:GetMount() or nil
    local target = combat ~= nil and combat.target or nil
    print("[沃尔特调试]", label,
        "sg=" .. tostring(inst.sg ~= nil and inst.sg.currentstate ~= nil and inst.sg.currentstate.name or nil),
        "build=" .. SafeAnimValue(inst, "GetBuild"),
        "anim=" .. SafeAnimValue(inst, "GetCurrentAnimation"),
        "ghost=" .. tostring(inst._is_ghost_mode),
        "tag_ghost=" .. tostring(inst:HasTag("ghost")),
        "noattack=" .. tostring(inst:HasTag("noattack")),
        "reviving=" .. tostring(inst._npc_reviving_from_ghost),
        "woby_lock=" .. tostring(inst._npc_woby_ride_disabled),
        "canattack=" .. tostring(combat ~= nil and combat.canattack or nil),
        "target=" .. tostring(target ~= nil and (target.prefab or target.GUID) or nil),
        "riding=" .. tostring(mount ~= nil),
        "mount=" .. tostring(mount ~= nil and mount.prefab or nil),
        ...)
end

local function WX78SpinDbg(inst, label, ...)
    if not (NPC_TUNING and NPC_TUNING.DEBUG_COMBAT) then return end
    if inst == nil or inst.npc_character_type ~= "wx78" then return end
    local combat = inst.components ~= nil and inst.components.combat or nil
    local target = combat ~= nil and combat.target or nil
    local target_dist = "nil"
    if target ~= nil and target:IsValid() then
        target_dist = string.format("%.2f", math.sqrt(inst:GetDistanceSqToInst(target)))
    end
    print("[NPC_WX78][旋转状态]", label,
        "sg=" .. tostring(inst.sg ~= nil and inst.sg.currentstate ~= nil and inst.sg.currentstate.name or nil),
        "target=" .. tostring(target ~= nil and (target.prefab or target.GUID) or nil),
        "target_dist=" .. target_dist,
        ...)
end

local function DoTalkSound(inst)
    if inst.SoundEmitter == nil then
        return false
    end
    if inst.talksoundoverride ~= nil then
        inst.SoundEmitter:PlaySound(inst.talksoundoverride, "talk")
        inst.SoundEmitter:SetVolume("talk", NPC_TUNING.WALTER_STORY_TALK_VOLUME or 0.4)
        return true
    elseif not inst:HasTag("mime") then
        local sound_name = inst.soundsname or inst.npc_character_type or inst.prefab
        inst.SoundEmitter:PlaySound((inst.talker_path_override or "dontstarve/characters/") .. sound_name .. "/talk_LP", "talk")
        inst.SoundEmitter:SetVolume("talk", NPC_TUNING.WALTER_STORY_TALK_VOLUME or 0.4)
        return true
    end
    return false
end

local function StopTalkSound(inst, instant)
    if inst.SoundEmitter == nil then
        return
    end
    if not instant and inst.endtalksound ~= nil and inst.SoundEmitter:PlayingSound("talk") then
        inst.SoundEmitter:PlaySound(inst.endtalksound)
    end
    inst.SoundEmitter:KillSound("talk")
end

local function RestoreNormalCharacterBank(inst)
    if inst.AnimState == nil then
        return
    end
    local app = NPC_UTILS.APPEARANCE[inst.npc_character_type] or NPC_UTILS.APPEARANCE.npcfriend
    inst.AnimState:SetBank((app ~= nil and app.bank) or "wilson")
end


local function WeremooseBlockState(deststate)
    if type(deststate) == "string" then
        return function(inst)
            if inst._is_weremoose then return nil end
            return deststate
        end
    elseif type(deststate) == "function" then
        return function(inst, ...)
            if inst._is_weremoose then return nil end
            return deststate(inst, ...)
        end
    end
    return deststate
end


local function ToggleOffPhysics(inst)
    inst.sg.statemem.isphysicstoggle = true
    inst.Physics:SetCollisionMask(COLLISION.GROUND)
end

local function ToggleOnPhysics(inst)
    inst.sg.statemem.isphysicstoggle = nil
    inst.Physics:SetCollisionMask(
        COLLISION.WORLD,
        COLLISION.OBSTACLES,
        COLLISION.SMALLOBSTACLES,
        COLLISION.CHARACTERS,
        COLLISION.GIANTS
    )
end


local function PlayWandaAgingFx(inst, fx_name)
    if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
        fx_name = fx_name .. "_mount"
    end
    local fx = SpawnPrefab(fx_name)
    if fx ~= nil then
        fx.entity:SetParent(inst.entity)
    end
end

local BOOK_CAST_FX_CANDIDATES = {
    wickerbottom = { "book_fx_wicker", "book_fx" },
    waxwell      = { "book_fx_waxwell", "waxwell_book_fx", "book_fx" },
}

local function SpawnNPCBookCastFx(inst)
    local candidates = BOOK_CAST_FX_CANDIDATES[inst.npc_character_type] or { "book_fx" }
    local mounted = inst.components.rider ~= nil and inst.components.rider:IsRiding()

    for _, base_name in ipairs(candidates) do
        local fx_name = mounted and (base_name .. "_mount") or base_name
        if Prefabs == nil or Prefabs[fx_name] ~= nil then
            local fx = SpawnPrefab(fx_name)
            if fx ~= nil then
                fx.entity:SetParent(inst.entity)
                fx.Transform:SetPosition(0, 0, 0)
                return fx
            end
        end
    end
end

local function SetWortoxSoulHopResult(inst, token, ok)
    inst._wortox_soulhop_result = ok == true
    inst._wortox_soulhop_result_token = token
    if inst._wortox_soulhop_active_token == token then
        inst._wortox_soulhop_active_token = nil
    end
end


local actionhandlers =
{
    
    
    
    ActionHandler(ACTIONS.CHOP,
        WeremooseBlockState(function(inst)
            if inst.npc_character_type == "wx78" then
                if inst.sg:HasStateTag("working")
                    and inst.sg:HasAnyStateTag("prespin", "spinning") then
                    return nil
                end
                if WX78Combat.IsSpinWorkBlocked and WX78Combat.IsSpinWorkBlocked(inst) then
                    return nil
                end
            end
            if not inst.sg:HasStateTag("prechop") then
                local ba = inst.bufferedaction
                if ba and ba.target then
                    local workable = ba.target.components.workable
                    if not workable or workable:GetWorkAction() ~= ACTIONS.CHOP then
                        return nil
                    end
                    if WX78Combat.CanUseSpinWork(inst, ACTIONS.CHOP, ba.target) then
                        return "wx_spin_work_start"
                    end
                end
                return inst.sg:HasStateTag("chopping") and "chop" or "chop_start"
            end
        end)),

    
    
    
    ActionHandler(ACTIONS.MINE,
        WeremooseBlockState(function(inst)
            if inst.npc_character_type == "wx78" then
                if inst.sg:HasStateTag("working")
                    and inst.sg:HasAnyStateTag("prespin", "spinning") then
                    return nil
                end
                if WX78Combat.IsSpinWorkBlocked and WX78Combat.IsSpinWorkBlocked(inst) then
                    return nil
                end
            end
            if not inst.sg:HasStateTag("premine") then
                local ba = inst.bufferedaction
                if ba and ba.target and WX78Combat.CanUseSpinWork(inst, ACTIONS.MINE, ba.target) then
                    return "wx_spin_work_start"
                end
                return inst.sg:HasStateTag("mining") and "mine" or "mine_start"
            end
        end)),

    
    ActionHandler(ACTIONS.PICK, WeremooseBlockState("dolongaction")),

    
    ActionHandler(ACTIONS.INTERACT_WITH, WeremooseBlockState("domediumaction")),

    
    ActionHandler(ACTIONS.DEPLOY, WeremooseBlockState("doshortaction")),
    
    ActionHandler(ACTIONS.DIG, WeremooseBlockState("dig_start")),
    SGNPCCommon.MakePickupHandler(),
    ActionHandler(ACTIONS.PLANTSOIL, WeremooseBlockState("dolongaction")),

    
    ActionHandler(ACTIONS.POUR_WATER, WeremooseBlockState("pour")),
    ActionHandler(ACTIONS.POUR_WATER_GROUNDTILE, WeremooseBlockState("pour")),

    ActionHandler(ACTIONS.TILL, WeremooseBlockState(function(inst)
        if not inst.sg:HasStateTag("pretill") then
            return "till_start"
        end
    end)),

    
    ActionHandler(ACTIONS.PLAY,
        WeremooseBlockState(function(inst, action)
            if action.invobject ~= nil and action.invobject:HasTag("flute") then
                return "play_flute"
            end
        end)),

    ActionHandler(ACTIONS.TELLSTORY, WeremooseBlockState("dostorytelling")),

    ActionHandler(ACTIONS.TACKLE, function(inst)
        if inst:HasTag("weremoose") then
            return "moose_tackle_pre"
        end
    end),

    
    ActionHandler(ACTIONS.MURDER, WeremooseBlockState("dolongaction")),
}

local function IsSlingshotAttack(inst)
    local weapon = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
    return inst.npc_character_type == "walter"
        and weapon ~= nil
        and weapon:HasTag("slingshot")
        and WalterCombat.PrepareRangedAttack(inst, weapon)
        and weapon.components.weapon ~= nil
        and weapon.components.weapon.projectile ~= nil
end

local function OnNPCDoAttack(inst, data)
    if IsWalterWobyActionLocked(inst) then
        WalterStateDbg(inst, "doattack 被复活/死亡/Woby锁拦截")
        if inst.components.combat ~= nil then
            inst.components.combat:SetTarget(nil)
            inst.components.combat:CancelAttack()
        end
        return
    end
    if (not inst.sg:HasStateTag("busy") or
        (inst.sg:HasStateTag("hit") and not inst.sg:HasStateTag("electrocute"))) then
        local target = data and data.target or inst.components.combat and inst.components.combat.target or nil
        if inst._is_wurt and inst._wurt_skill_pending then
            inst._wurt_skill_pending = nil
            if target ~= nil and target:IsValid()
                and not (target.components.health ~= nil and target.components.health:IsDead())
                and WurtCombat.DoWeightedSpecial(inst, target) then
                return
            end
        end
        -- 锻锤跳劈优先：冷却就绪且目标在范围内则跳劈（内部已做 wx78/友军/距离判定）
        if WX78Combat.TryLeap(inst, target) then
            return
        end
        if inst.npc_character_type == "wx78" and inst.sg:HasAnyStateTag("prespin", "spinning") then
            WX78SpinDbg(inst, "doattack.ignore_already_spinning")
            return
        end
        if WX78Combat.CanUseSpinAttack(inst, target) then
            inst.sg:GoToState("wx_spin_start", target)
            return
        end
        local use_slingshot = IsSlingshotAttack(inst)
        inst.sg:GoToState(use_slingshot and "slingshot_shoot" or "attack", target)
    else
        WalterStateDbg(inst, "doattack 忽略：当前状态忙")
    end
end


local events =
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true, false),  
    CommonHandlers.OnFreeze(),
    EventHandler("doattack", OnNPCDoAttack),
    EventHandler("electrocute", function(inst)
        if IsWalterWobyActionLocked(inst) then
            return
        end
        if not inst.sg:HasAnyStateTag("busy", "dead", "ghost") then
            inst.sg:GoToState("electrocute")
        end
    end),
    EventHandler("attacked", function(inst, data)
        
        if inst._is_webber or inst._is_wurt then
            return
        end
        
        if inst.npc_character_type == "wx78"
            and inst.sg ~= nil
            and inst.sg.currentstate ~= nil
            and (inst.sg.currentstate.name == "wx_spin_dodge"
                or inst.sg.currentstate.name == "wx_spin_work") then
            return
        end
        if inst._is_groggy or inst.sg:HasStateTag("waking") then
            return  
        end
        if inst.components.health and not inst.components.health:IsDead() then
            if not inst.sg:HasStateTag("busy") or
                inst.sg:HasAnyStateTag("caninterrupt", "frozen")
            then
                inst.sg:GoToState("hit")
            end
        end
    end),
    
    EventHandler("death", function(inst)
        if inst.npc_character_type == "walter" then
            WobyRide.DisableForDeath(inst)
        end
        
        inst.sg:GoToState("death")
    end),
    
    EventHandler("becomeyounger_wanda", function(inst)
        if not inst._is_ghost_mode and not (inst.components.health and inst.components.health:IsDead()) then
            inst.sg:GoToState("becomeyounger_wanda")
        end
    end),
    EventHandler("becomeolder_wanda", function(inst)
        if not inst._is_ghost_mode and not (inst.components.health and inst.components.health:IsDead()) then
            inst.sg:GoToState("becomeolder_wanda")
        end
    end),
    EventHandler("wanda_rejuvenate", function(inst)
        if not inst._is_ghost_mode and not (inst.components.health and inst.components.health:IsDead()) then
            inst.sg:GoToState("wanda_rejuvenate")
        end
    end),
    CommonHandlers.OnSink(),
    CommonHandlers.OnFallInVoid(),
    EventHandler("dismount", function(inst)
        if inst.components.rider ~= nil
            and inst.components.rider:IsRiding()
            and not inst.sg:HasStateTag("dismounting")
            and not IsWalterWobyActionLocked(inst) then
            local mount = inst.components.rider:GetMount()
            if mount ~= nil and mount:HasTag("npc_woby") then
                inst.sg:GoToState("npc_woby_dismount")
            end
        end
    end),

    
    EventHandler("knockedout", function(inst)
        if not inst.sg:HasStateTag("knockout")
            and not inst.sg:HasStateTag("sleeping")
            and not inst.sg:HasStateTag("waking")
            and not inst._is_groggy
            and not (inst.components.health and inst.components.health:IsDead())
            and not inst._is_ghost_mode then
            inst.sg:GoToState("knockout")
        end
    end),

    
    
    EventHandler("equip", function(inst, data)
        if inst._is_ghost_mode then return end
        if inst._is_weremoose then return end  
        
        if data and data.item and data.item.prefab == "silvernecklace" then return end
        
        if SGNPCCommon.HandleEquipHeavy(inst, data) then return end
        if inst.sg:HasStateTag("busy") then return end
        if inst.sg:HasStateTag("idle") then
            if data and data.eslot == EQUIPSLOTS.HANDS then
                inst.sg:GoToState("item_out")
            else
                inst.sg:GoToState("item_hat")
            end
        end
    end),
    EventHandler("unequip", function(inst, data)
        if inst._is_ghost_mode then return end
        if inst._is_weremoose then return end  
        
        if data and data.item and data.item.prefab == "silvernecklace" then return end
        
        if SGNPCCommon.HandleUnequipHeavy(inst, data) then return end
        if inst.sg:HasStateTag("busy") then return end
        if inst.sg:HasStateTag("idle") then
            if data and data.eslot == EQUIPSLOTS.HANDS then
                inst.sg:GoToState("item_in")
            else
                inst.sg:GoToState("item_hat")
            end
        end
    end),
    
    
    EventHandler("wanda_watch_cast_apply", function(inst)
        if inst._wanda_watch_cast_fn ~= nil then
            local fn = inst._wanda_watch_cast_fn
            inst._wanda_watch_cast_fn = nil
            fn(inst)
        end
    end),
    
    EventHandler("npc_rift_arrive", function(inst, data)
        if inst.sg ~= nil then
            inst.sg:GoToState("npc_rift_arrive", data)
        end
    end),

    
    EventHandler("devoured", function(inst, data)
        if inst._is_ghost_mode or IsHardDeathLocked(inst) then
            return
        end
        inst.sg:GoToState("devoured", data)
    end),

    
    EventHandler("transform_to_werewilba", function(inst, data)
        inst.sg:GoToState("transform_werewilba", data)
    end),

    EventHandler("transform_to_wilba", function(inst, data)
        inst.sg:GoToState("transform_wilba", data)
    end),
}



SGNPCCommon.AddHopEventHandlers(events)





local function MooseTackleCheckCollision(inst, targets)
    local x, y, z = inst.Transform:GetWorldPosition()
    local angle = inst.Transform:GetRotation() * DEGREES
    local fx = x + math.cos(angle) * 1.5
    local fz = z - math.sin(angle) * 1.5
    local ents = TheSim:FindEntities(fx, 0, fz, 2.5, { "_combat" },
        { "INLIMBO", "companion", "player", "npcfriend", "wall", "flight", "invisible", "notarget", "noattack" })
    local tackle_dmg = NPC_TUNING.WEREMOOSE_TACKLE_DAMAGE or 59.5
    for _, v in ipairs(ents) do
        if v ~= inst and v:IsValid() and not (targets and targets[v])
           and inst.components.combat:CanTarget(v) then
            
            local dominated_leader = v.components.follower and v.components.follower:GetLeader()
            if dominated_leader and (dominated_leader:HasTag("player") or dominated_leader:HasTag("npcfriend")) then
                
            else
                if targets then targets[v] = true end
                
                v.components.combat:GetAttacked(inst, tackle_dmg)
                return true  
            end
        end
    end
    return false
end



local function MooseTackleCheckEdge(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local angle = inst.Transform:GetRotation() * DEGREES
    local fx = x + math.cos(angle) * 2
    local fz = z - math.sin(angle) * 2
    return not TheWorld.Map:IsPassableAtPoint(fx, 0, fz)
end

local function FinishReviveFromGhost(inst)
    WalterStateDbg(inst, "复活完成前")
    if inst.npc_character_type == "wanda" then
        inst:PushEvent("wanda_refresh_age_visual")
    end
    if inst.npc_character_type == "walter" and not inst._is_ghost_mode then
        WobyRide.EnableAfterRevive(inst)
    end
    inst._npc_reviving_from_ghost = nil
    if inst.components.combat ~= nil then
        inst.components.combat.canattack = true
        inst.components.combat:SetTarget(nil)
    end
    inst:RemoveTag("noattack")
    WalterStateDbg(inst, "复活完成后")
    inst.sg.statemem.completed = true
    inst.sg:GoToState("idle")
end

local function StartReviveWakeup(inst)
    WalterStateDbg(inst, "复活第二阶段开始前")
    if inst.sg.statemem.phase2 then
        return
    end
    inst.sg.statemem.phase2 = true

    
    local bank  = inst._saved_bank  or "wilson"
    local build = inst._saved_build or "wilson"
    if inst.npc_character_type == "wanda" then
        bank = "wilson"
        build = inst._saved_build or NPC_TUNING.WANDA_BUILD_NORMAL or "wanda_NPC"
    end
    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    if inst.npc_character_type == "wanda" and inst._wanda_reapply_overrides ~= nil then
        inst._wanda_reapply_overrides(inst)
    end
    inst.AnimState:SetMultColour(1, 1, 1, 1)
    inst.AnimState:Hide("ARM_carry")
    inst.AnimState:Hide("HAT")
    inst.AnimState:Hide("HAIR_HAT")
    inst.AnimState:Show("HAIR_NOHAT")
    inst.AnimState:Show("HAIR")
    inst.AnimState:Show("HEAD")
    inst.AnimState:Hide("HEAD_HAT")
    inst.AnimState:Hide("HEAD_HAT_NOHELM")
    inst.AnimState:Hide("HEAD_HAT_HELM")
    local inv = inst.components.inventory
    if inv then
        for _, eslot in ipairs({ EQUIPSLOTS.HANDS, EQUIPSLOTS.HEAD, EQUIPSLOTS.BODY }) do
            local item = inv:GetEquippedItem(eslot)
            if item and item.components.equippable and item.components.equippable.onequipfn then
                item.components.equippable.onequipfn(item, inst)
            end
        end
    end
    if inst._npc_clothing and inst.ApplyNPCClothing then
        inst:ApplyNPCClothing(inst._npc_clothing, inst._npc_clothing_userid or "")
    end
    WandaReviveDbg(inst, "state revive_from_ghost phase2 anim=wakeup bank=%s build=%s", tostring(bank), tostring(build))
    inst.AnimState:PlayAnimation("wakeup")
    inst.SoundEmitter:PlaySound("dontstarve/common/rebirth")
    inst.sg.statemem.restored = true
    inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() + FRAMES)
    WalterStateDbg(inst, "复活第二阶段开始后", "bank=" .. tostring(bank), "build_target=" .. tostring(build))
end


local WEREMOOSE_SYMBOLS = {
    "weremoose_antlers01",
    "weremoose_arm_lower",
    "weremoose_arm_upper",
    "weremoose_arm_upper_skin",
    "weremoose_eyes",
    "weremoose_face",
    "weremoose_foot",
    "weremoose_hairpigtails",
    "weremoose_hand",
    "weremoose_headbase",
    "weremoose_leg",
    "weremoose_mouth",
    "weremoose_torso",
    "weremoose_torso_pelvis",
}


local states =
{
    
    
    
    State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst)
            if IsWalterWobyActionLocked(inst) then
                WalterStateDbg(inst, "attack onenter 被锁拦截")
                if inst.components.combat ~= nil then
                    inst.components.combat:SetTarget(nil)
                    inst.components.combat:CancelAttack()
                end
                inst.sg:GoToState(inst._is_ghost_mode and "ghost_idle" or "idle")
                return
            end
            inst.components.combat:StartAttack()
            inst.Physics:Stop()

            if inst:HasTag("weremoose") then
                
                local combo = inst._moose_combo or 0
                if combo == 0 then
                    inst.AnimState:PlayAnimation("punch_a")
                elseif combo == 1 then
                    inst.AnimState:PlayAnimation("punch_b")
                else
                    inst.AnimState:PlayAnimation("punch_c")
                end
                inst._moose_combo = (combo + 1) % 3
                inst.sg.statemem.ismoose = true
                
                inst.sg:SetTimeout(15 * FRAMES)
            else
                local equip = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
                if equip ~= nil and equip:HasTag("pocketwatch") then
                    inst.AnimState:PlayAnimation("pocketwatch_atk_pre")
                    inst.AnimState:PushAnimation("pocketwatch_atk", false)
                    inst.sg.statemem.ispocketwatch = true
                    if equip:HasTag("shadow_item") then
                        inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/pre_shadow")
                        inst.AnimState:Show("pocketwatch_weapon_fx")
                        inst.sg.statemem.ispocketwatch_fueled = true
                    else
                        inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/pre")
                        inst.AnimState:Hide("pocketwatch_weapon_fx")
                    end
                    inst.sg:SetTimeout(19 * FRAMES)
                else
                    
                    local atk_speed = inst._attack_speed_mult or 1
                    if atk_speed ~= 1 then
                        inst.AnimState:SetDeltaTimeMultiplier(atk_speed)
                    end
                    inst.AnimState:PlayAnimation("atk")
                    local cooldown = math.max(inst.components.combat.min_attack_period or 0, 13 * FRAMES)
                    inst.sg:SetTimeout(cooldown / atk_speed)
                end
            end
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                if inst.sg.statemem.ismoose then
                    inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/moose/punch", nil, nil, true)
                    inst.components.combat:DoAttack()
                    inst.sg:RemoveStateTag("busy")
                    inst.sg:AddStateTag("caninterrupt")
                end
            end),
            TimeEvent(8 * FRAMES, function(inst)
                if not inst.sg.statemem.ismoose and not inst.sg.statemem.ispocketwatch then
                    inst.components.combat:DoAttack()
                    inst.sg:RemoveStateTag("busy")
                    inst.sg:AddStateTag("caninterrupt")
                end
            end),
            TimeEvent(10 * FRAMES, function(inst)
                if inst.sg.statemem.ispocketwatch then
                    inst.components.combat:DoAttack()
                    inst.sg:RemoveStateTag("busy")
                    inst.sg:AddStateTag("caninterrupt")
                end
            end),
            TimeEvent(17 * FRAMES, function(inst)
                if inst.sg.statemem.ispocketwatch then
                    inst.SoundEmitter:PlaySound(
                        inst.sg.statemem.ispocketwatch_fueled
                        and "wanda2/characters/wanda/watch/weapon/pst_shadow"
                        or "wanda2/characters/wanda/watch/weapon/pst"
                    )
                end
            end),
        },

        ontimeout = function(inst)
            
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end,

        onexit = function(inst)
            
            inst.AnimState:SetDeltaTimeMultiplier(1)
            if inst.sg.statemem.ispocketwatch then
                inst.AnimState:Hide("pocketwatch_weapon_fx")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                
                if not inst.sg:HasStateTag("attack") then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "slingshot_shoot",
        tags = { "attack", "busy", "abouttoattack" },

        onenter = function(inst, target)
            if IsWalterWobyActionLocked(inst) then
                WalterStateDbg(inst, "slingshot_shoot 被锁拦截")
                if inst.components.combat ~= nil then
                    inst.components.combat:SetTarget(nil)
                    inst.components.combat:CancelAttack()
                end
                inst.sg:GoToState(inst._is_ghost_mode and "ghost_idle" or "idle")
                return
            end
            if target ~= nil and target:IsValid() then
                inst.components.combat:SetTarget(target)
                inst:FacePoint(target.Transform:GetWorldPosition())
                inst.sg.statemem.attacktarget = target
            end

            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("slingshot_pre")
            inst.AnimState:PushAnimation("slingshot_lag", false)
            inst.sg:SetTimeout(16 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/stretch")
            end),
        },

        ontimeout = function(inst)
            inst.sg.statemem.shooting = true
            inst.sg:GoToState("slingshot_shoot2", inst.sg.statemem.attacktarget)
        end,

        events =
        {
            EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.shooting then
                inst.components.combat:CancelAttack()
            end
        end,
    },

    State{
        name = "slingshot_shoot2",
        tags = { "attack", "busy", "abouttoattack" },

        onenter = function(inst, target)
            if IsWalterWobyActionLocked(inst) then
                WalterStateDbg(inst, "slingshot_shoot2 被锁拦截")
                if inst.components.combat ~= nil then
                    inst.components.combat:SetTarget(nil)
                    inst.components.combat:CancelAttack()
                end
                inst.sg:GoToState(inst._is_ghost_mode and "ghost_idle" or "idle")
                return
            end
            inst.sg.statemem.attacktarget = target
            inst.AnimState:PlayAnimation("slingshot")
            inst.sg:SetTimeout(13 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                local target = inst.sg.statemem.attacktarget
                local equip = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
                if equip == nil
                    or not equip:HasTag("slingshot")
                    or equip.components.weapon == nil
                    or equip.components.weapon.projectile == nil
                    or target == nil
                    or not target:IsValid()
                    or not inst.components.combat:CanTarget(target) then
                    inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/no_ammo")
                    inst.sg:GoToState("idle")
                    return
                end

                inst.components.combat:DoAttack(target)
                inst.sg:RemoveStateTag("abouttoattack")
                inst.sg:RemoveStateTag("busy")
                inst.sg:AddStateTag("caninterrupt")
                inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/shoot")
            end),
            TimeEvent(8 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("attack")
                inst.sg:AddStateTag("idle")
            end),
        },

        events =
        {
            EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,
    },

    
    
    
    State{
        name = "wx_spin_work_start",
        tags = { "busy", "prespin", "working" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            local ba = inst:GetBufferedAction()
            inst.sg.statemem.action = ba and ba.action or nil
            inst.sg.statemem.target = ba and ba.target or nil
            WX78SpinDbg(inst, "work_start.enter",
                "action=" .. tostring(inst.sg.statemem.action ~= nil and (inst.sg.statemem.action.id or inst.sg.statemem.action.str) or nil),
                "work_target=" .. tostring(inst.sg.statemem.target ~= nil and (inst.sg.statemem.target.prefab or inst.sg.statemem.target.GUID) or nil),
                "timeout=14frames")
            if inst.sg.statemem.target ~= nil and inst.sg.statemem.target:IsValid() then
                inst:ForceFacePoint(inst.sg.statemem.target.Transform:GetWorldPosition())
            end
            inst.AnimState:PlayAnimation("chop_pre")
            inst.AnimState:PushAnimation("wx_spin_attack_loop_slow", true)
            inst.sg:SetTimeout(14 * FRAMES)
        end,

        ontimeout = function(inst)
            WX78SpinDbg(inst, "work_start.timeout -> wx_spin_work")
            inst.sg:GoToState("wx_spin_work", {
                action = inst.sg.statemem.action,
                target = inst.sg.statemem.target,
            })
        end,

        events =
        {
            EventHandler("unequip", function(inst)
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle")
            end),
        },
    },

 
    State{
        name = "wx_spin_work",
        tags = { "spinning", "working", "canrotate", "overridelocomote" },

        onenter = function(inst, data)
            
            if data ~= nil then
                inst.sg.statemem.action = data.action or inst.sg.statemem.action
                inst.sg.statemem.target = data.target
            end
            WX78SpinDbg(inst, "work.enter",
                "action=" .. tostring(inst.sg.statemem.action ~= nil and (inst.sg.statemem.action.id or inst.sg.statemem.action.str) or nil),
                "target=" .. tostring(inst.sg.statemem.target ~= nil and (inst.sg.statemem.target.prefab or inst.sg.statemem.target.GUID) or nil),
                "radius=" .. tostring(NPC_TUNING.WX78_SPIN_RADIUS or 3))
            inst:ClearBufferedAction()
            
            if not inst.AnimState:IsCurrentAnimation("wx_spin_attack_loop_slow") then
                inst.AnimState:PlayAnimation("wx_spin_attack_loop_slow", true)
            end
            
            
            
            if inst.sg.statemem.target ~= nil and inst.sg.statemem.target:IsValid() then
                inst:ForceFacePoint(inst.sg.statemem.target.Transform:GetWorldPosition())
            end
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            
            inst.sg.statemem.next_work = 0
            inst.sg.statemem.last_chase_log = nil
        end,

        onupdate = function(inst)
            if inst._is_ghost_mode
                or (inst.components.health ~= nil and inst.components.health:IsDead()) then
                WX78SpinDbg(inst, "work.exit (self_dead/ghost)")
                inst.sg:GoToState("idle")
                return
            end

            local item = inst.components.inventory ~= nil
                and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
            if not WX78Combat.CanSpinUsingItem(item) then
                if WX78Combat.TryEquipSpinTool(inst) == nil then
                    WX78SpinDbg(inst, "work.exit (no_spin_tool)")
                    inst.sg:GoToState("idle")
                    return
                end
            end

            local action = inst.sg.statemem.action
            if action ~= ACTIONS.CHOP and action ~= ACTIONS.MINE then
                WX78SpinDbg(inst, "work.exit (invalid_action)")
                inst.sg:GoToState("idle")
                return
            end
            if item and item.components.tool and not item.components.tool:CanDoAction(action) then
                WX78SpinDbg(inst, "work.exit (tool_action_mismatch)",
                    "tool=" .. tostring(item.prefab),
                    "action=" .. tostring(action.id or action.str))
                inst.sg:GoToState("idle")
                return
            end

            local follower = inst.components.follower
            local leader = follower ~= nil and follower.leader or nil
            if leader ~= nil and leader:IsValid() then
                local lx, _, lz = leader.Transform:GetWorldPosition()
                local mx, _, mz = inst.Transform:GetWorldPosition()
                local ldx, ldz = lx - mx, lz - mz
                local leader_keep = action == ACTIONS.CHOP
                    and (NPC_TUNING.CHOP_KEEP_DIST or 20)
                    or  (NPC_TUNING.MINE_KEEP_DIST or 25)
                if ldx * ldx + ldz * ldz > leader_keep * leader_keep then
                    WX78SpinDbg(inst, "work.exit (leader_too_far)",
                        "dist=" .. string.format("%.2f", math.sqrt(ldx * ldx + ldz * ldz)),
                        "limit=" .. tostring(leader_keep))
                    WX78Combat.SetSpinWorkBlock(inst, "leader_too_far")
                    inst.sg:GoToState("idle")
                    return
                end
            end

            local x, y, z = inst.Transform:GetWorldPosition()
            local spin_radius = NPC_TUNING.WX78_SPIN_RADIUS or 3
            local search_r = spin_radius + 5
            local must_tags = action == ACTIONS.CHOP and { "CHOP_workable" } or { "MINE_workable" }
            local cant_tags = { "INLIMBO", "NOCLICK", "FX", "decor", "wall", "event_trigger", "carnivalgame_part" }
            local best_target, best_dist = nil, math.huge
            for _, ent in ipairs(TheSim:FindEntities(x, y, z, search_r, must_tags, cant_tags)) do
                if ent:IsValid() and ent.entity:IsVisible()
                    and ent.components.workable ~= nil
                    and ent.components.workable:CanBeWorked()
                    and ent.components.workable:GetWorkAction() == action then
                    local dist = math.sqrt(inst:GetDistanceSqToInst(ent))
                    if dist < best_dist then
                        best_target, best_dist = ent, dist
                    end
                end
            end
            if best_target == nil then
                WX78SpinDbg(inst, "work.exit (no_more_targets)",
                    "search_r=" .. tostring(search_r))
                inst.sg:GoToState("idle")
                return
            end
            inst.sg.statemem.target = best_target

            local locomotor = inst.components.locomotor
            local target_phys = best_target.GetPhysicsRadius and best_target:GetPhysicsRadius(0) or 0
            local stop_dist = math.max(spin_radius - 0.3, 1.0) + target_phys
            local moving = false
            if locomotor ~= nil then
                local tx, _, tz = best_target.Transform:GetWorldPosition()
                if best_dist > stop_dist then
                    inst:ForceFacePoint(tx, 0, tz)
                    locomotor:RunForward(true)
                    moving = true
                    if inst.sg.statemem.last_chase_log == nil
                        or GetTime() - inst.sg.statemem.last_chase_log >= 1.0 then
                        inst.sg.statemem.last_chase_log = GetTime()
                        WX78SpinDbg(inst, "work.chase",
                            "target=" .. tostring(best_target.prefab),
                            "dist=" .. string.format("%.2f", best_dist),
                            "stop=" .. string.format("%.2f", stop_dist))
                    end
                else
                    locomotor:StopMoving()
                    inst:ForceFacePoint(tx, 0, tz)
                    inst.sg.statemem.last_chase_log = nil
                end
            end

            local now = GetTime()
            if inst.sg.statemem.next_work == nil or now >= inst.sg.statemem.next_work then
                local period = moving
                    and (NPC_TUNING.WX78_SPIN_DODGE_HIT_PERIOD or 0.5)
                    or  (NPC_TUNING.WX78_SPIN_ATTACK_PERIOD or 0.8)
                inst.sg.statemem.next_work = now + period
                WX78Combat.DoSpinWork(inst, action)
            end

            if not inst.AnimState:IsCurrentAnimation("wx_spin_attack_loop_slow")
                and not inst.AnimState:IsCurrentAnimation("wx_spin_attack_loop") then
                inst.AnimState:PlayAnimation("wx_spin_attack_loop_slow", true)
            end
        end,

        events =
        {
            EventHandler("locomote", function(inst, data)
                local locomotor = inst.components.locomotor
                if locomotor == nil then return end
                if locomotor:WantsToMoveForward() then
                    locomotor:RunForward()
                else
                    locomotor:StopMoving()
                end
            end),
            EventHandler("unequip", function(inst)
                if WX78Combat.TryEquipSpinTool(inst) ~= nil then
                    WX78SpinDbg(inst, "work.unequip 重装成功，保持旋转")
                    return
                end
                inst:ClearBufferedAction()
                WX78SpinDbg(inst, "work.unequip -> idle")
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            if inst.components.locomotor ~= nil
                and not inst.components.locomotor:WantsToMoveForward() then
                inst.components.locomotor:StopMoving()
            end
        end,
    },

    State{
        name = "wx_spin_start",
        tags = { "attack", "busy", "prespin", "working" },

        onenter = function(inst, target)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()
            inst.sg.statemem.attacktarget = target
            WX78SpinDbg(inst, "attack_start.enter",
                "attack_target=" .. tostring(target ~= nil and (target.prefab or target.GUID) or nil),
                "timeout=14frames")
            if target ~= nil and target:IsValid() then
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end
            inst.AnimState:PlayAnimation("chop_pre")
            inst.AnimState:PushAnimation("wx_spin_attack_loop_slow", true)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
            inst.sg:SetTimeout(14 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                local target = inst.sg.statemem.attacktarget
                if target ~= nil and target:IsValid() then
                    inst:ForceFacePoint(target.Transform:GetWorldPosition())
                end
            end),
        },

        ontimeout = function(inst)
            WX78SpinDbg(inst, "attack_start.timeout -> wx_spin_dodge")
            inst.sg:GoToState("wx_spin_dodge", inst.sg.statemem.attacktarget)
        end,

        events =
        {
            EventHandler("unequip", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },


    State{
        name = "wx_spin_dodge",
        tags = { "spinning", "canrotate", "overridelocomote" },

        onenter = function(inst, target)
            if target ~= nil and target:IsValid() then
                inst._wx78_dodge_spin_target = target
            end
            WX78SpinDbg(inst, "spin.enter",
                "target=" .. tostring(inst._wx78_dodge_spin_target ~= nil and inst._wx78_dodge_spin_target.prefab or nil),
                "radius=" .. tostring(NPC_TUNING.WX78_SPIN_RADIUS or 2.1))
            inst:ClearBufferedAction()
            if not inst.AnimState:IsCurrentAnimation("wx_spin_attack_loop_slow") then
                inst.AnimState:PlayAnimation("wx_spin_attack_loop_slow", true)
            end
            if inst._wx78_dodge_spin_target ~= nil and inst._wx78_dodge_spin_target:IsValid() then
                inst:ForceFacePoint(inst._wx78_dodge_spin_target.Transform:GetWorldPosition())
            end
            if inst.components.locomotor ~= nil then
                if inst._wx78_dodge_spin_active then
                    if inst.components.locomotor:WantsToMoveForward() then
                        inst.components.locomotor:RunForward()
                    else
                        inst.components.locomotor:StopMoving()
                    end
                elseif inst._wx78_dodge_spin_target ~= nil
                    and inst._wx78_dodge_spin_target:IsValid() then
                    inst.components.locomotor:StopMoving()
                end
            end
            inst.components.combat:StartAttack()
            inst.sg.statemem.next_hit = 0
            inst.sg.statemem.last_chase_log = nil
        end,

        onupdate = function(inst)
            if inst._is_ghost_mode
                or (inst.components.health ~= nil and inst.components.health:IsDead()) then
                WX78SpinDbg(inst, "spin.exit (self_dead/ghost)")
                inst.sg:GoToState("idle")
                return
            end

            local item = inst.components.inventory ~= nil
                and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
            if not WX78Combat.CanSpinUsingItem(item) then
                if WX78Combat.TryEquipSpinTool(inst) == nil then
                    WX78SpinDbg(inst, "spin.exit (no_spin_tool)")
                    inst.sg:GoToState("idle")
                    return
                end
            end

            local combat_target = inst.components.combat ~= nil and inst.components.combat.target or nil
            local mem_target = inst._wx78_dodge_spin_target
            local spin_target = nil
            if combat_target ~= nil and combat_target:IsValid()
                and (combat_target.components.health == nil or not combat_target.components.health:IsDead()) then
                spin_target = combat_target
                inst._wx78_dodge_spin_target = combat_target
            elseif mem_target ~= nil and mem_target:IsValid()
                and (mem_target.components.health == nil or not mem_target.components.health:IsDead()) then
                spin_target = mem_target
            end
            if spin_target == nil then
                WX78SpinDbg(inst, "spin.exit (no_target)")
                inst.sg:GoToState("idle")
                return
            end

            local follower = inst.components.follower
            local leader = follower ~= nil and follower.leader or nil
            if leader ~= nil and leader:IsValid() then
                local lx, _, lz = leader.Transform:GetWorldPosition()
                local mx, _, mz = inst.Transform:GetWorldPosition()
                local ldx, ldz = lx - mx, lz - mz
                local leader_keep = NPC_TUNING.KITE_MAX_LEADER_DIST or 18
                if ldx * ldx + ldz * ldz > leader_keep * leader_keep then
                    WX78SpinDbg(inst, "spin.exit (leader_too_far)",
                        "dist=" .. string.format("%.2f", math.sqrt(ldx * ldx + ldz * ldz)),
                        "limit=" .. tostring(leader_keep))
                    inst._wx78_dodge_spin_active = nil
                    inst._wx78_dodge_spin_target = nil
                    if inst.components.combat ~= nil then
                        inst.components.combat:GiveUp()
                    end
                    inst.sg:GoToState("idle")
                    return
                end
            end

            if WX78Combat.TryLeap(inst, spin_target) then
                return
            end


            local locomotor = inst.components.locomotor
            local moving = false
            if locomotor ~= nil then
                if inst._wx78_dodge_spin_active then
                    if locomotor:WantsToMoveForward() then
                        locomotor:RunForward()
                        moving = true
                    else
                        locomotor:StopMoving()
                    end
                else
                    local me_x, _, me_z = inst.Transform:GetWorldPosition()
                    local tx, _, tz = spin_target.Transform:GetWorldPosition()
                    local dx, dz = tx - me_x, tz - me_z
                    local dist_to_target = math.sqrt(dx * dx + dz * dz)


                    local spin_radius = NPC_TUNING.WX78_SPIN_RADIUS or 3
                    local chase_threshold = math.max(spin_radius - 0.3, 1.2)

                    if dist_to_target > chase_threshold then
                        inst:ForceFacePoint(tx, 0, tz)
                        locomotor:RunForward(true)
                        moving = true
                        if inst.sg.statemem.last_chase_log == nil
                            or GetTime() - inst.sg.statemem.last_chase_log >= 1.0 then
                            inst.sg.statemem.last_chase_log = GetTime()
                            WX78SpinDbg(inst, "spin.chase",
                                "target=" .. tostring(spin_target.prefab),
                                "dist=" .. string.format("%.2f", dist_to_target),
                                "threshold=" .. string.format("%.2f", chase_threshold))
                        end
                    else
                        locomotor:StopMoving()
                        inst:ForceFacePoint(tx, 0, tz)
                        inst.sg.statemem.last_chase_log = nil
                    end
                end
            end

            local now = GetTime()
            if inst.sg.statemem.next_hit == nil or now >= inst.sg.statemem.next_hit then
                local period = moving
                    and (NPC_TUNING.WX78_SPIN_DODGE_HIT_PERIOD or 0.5)
                    or  (NPC_TUNING.WX78_SPIN_ATTACK_PERIOD or 0.8)
                inst.sg.statemem.next_hit = now + period
                WX78Combat.DoSpinAttack(inst)
            end

            if not inst.AnimState:IsCurrentAnimation("wx_spin_attack_loop_slow")
                and not inst.AnimState:IsCurrentAnimation("wx_spin_attack_loop") then
                inst.AnimState:PlayAnimation("wx_spin_attack_loop_slow", true)
            end
        end,

        events =
        {
            EventHandler("locomote", function(inst, data)
                local locomotor = inst.components.locomotor
                if locomotor == nil then return end
                if locomotor:WantsToMoveForward() then
                    locomotor:RunForward()
                else
                    locomotor:StopMoving()
                end
            end),
            EventHandler("unequip", function(inst)
                
                if WX78Combat.TryEquipSpinTool(inst) ~= nil then
                    WX78SpinDbg(inst, "spin.unequip 重装成功，保持旋转")
                    return
                end
                WX78SpinDbg(inst, "spin.unequip -> idle")
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            if inst.components.locomotor ~= nil
                and not inst.components.locomotor:WantsToMoveForward() then
                inst.components.locomotor:StopMoving()
            end
        end,
    },

    -- WX-78 跳劈
    State{
        name = "wx_leap_start",
        tags = { "attack", "busy", "nointerrupt", "nomorph", "wx_leaping" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()
            inst.sg.statemem.target = data and data.target or nil
            inst.sg.statemem.pos = data and data.pos or nil
            if inst.sg.statemem.pos ~= nil then
                inst:ForceFacePoint(inst.sg.statemem.pos.x, 0, inst.sg.statemem.pos.z)
            elseif inst.sg.statemem.target ~= nil and inst.sg.statemem.target:IsValid() then
                inst:ForceFacePoint(inst.sg.statemem.target.Transform:GetWorldPosition())
            end
            inst.AnimState:PlayAnimation("atk_leap_pre")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("wx_leap", {
                        target = inst.sg.statemem.target,
                        pos = inst.sg.statemem.pos,
                    })
                end
            end),
        },
    },

    State{
        name = "wx_leap",
        tags = { "attack", "busy", "nointerrupt", "nopredict", "nomorph", "wx_leaping" },

        onenter = function(inst, data)
            local pos = data and data.pos or nil
            inst.sg.statemem.target = data and data.target or nil
            if pos == nil then
                inst.sg:GoToState("idle")
                return
            end

            inst.components.locomotor:Stop()
            ToggleOffPhysics(inst)
            inst.Transform:SetEightFaced()
            inst.AnimState:PlayAnimation("atk_leap")
            inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")

            local startingpos = inst:GetPosition()
            inst.sg.statemem.startingpos = startingpos
            inst.sg.statemem.pos = pos
            if startingpos.x ~= pos.x or startingpos.z ~= pos.z then
                inst:ForceFacePoint(pos.x, 0, pos.z)
                inst.Physics:SetMotorVel(math.sqrt(distsq(startingpos.x, startingpos.z, pos.x, pos.z)) / (12 * FRAMES), 0, 0)
            end
        end,

        timeline =
        {
            -- 落地：恢复物理并瞬移到目标点
            TimeEvent(12 * FRAMES, function(inst)
                ToggleOnPhysics(inst)
                inst.Physics:Stop()
                inst.Physics:SetMotorVel(0, 0, 0)
                if inst.sg.statemem.pos ~= nil then
                    inst.Physics:Teleport(inst.sg.statemem.pos.x, 0, inst.sg.statemem.pos.z)
                end
            end),
            -- 锤击地面：震屏 + 范围带电伤害（友军过滤在 DoLeapAOE 内）
            TimeEvent(13 * FRAMES, function(inst)
                ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .015, .8, inst, 20)
                inst.sg:RemoveStateTag("nointerrupt")
                WX78Combat.DoLeapAOE(inst, inst.sg.statemem.pos)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
                inst.Physics:Stop()
                inst.Physics:SetMotorVel(0, 0, 0)
                local x, y, z = inst.Transform:GetWorldPosition()
                if TheWorld.Map:IsPassableAtPoint(x, 0, z) and not TheWorld.Map:IsGroundTargetBlocked(Vector3(x, 0, z)) then
                    inst.Physics:Teleport(x, 0, z)
                elseif inst.sg.statemem.pos ~= nil then
                    inst.Physics:Teleport(inst.sg.statemem.pos.x, 0, inst.sg.statemem.pos.z)
                end
            end
            inst.Transform:SetFourFaced()
        end,
    },

    
    
    

    
    State{
        name = "weremoose_transform",
        tags = { "busy", "nointerrupt" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()
            inst:StopBrain("weremoose_transform")
            inst.AnimState:PlayAnimation("weremoose_transform")
            for _, sym in ipairs(WEREMOOSE_SYMBOLS) do
                inst.AnimState:OverrideSymbol(sym, "weremoose_build", sym)
            end
            inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/moose/transform_forward")
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() - 2 * FRAMES)
        end,

        timeline =
        {
            
            TimeEvent(10 * FRAMES, function(inst)
                local fx = SpawnPrefab("weremoose_transform_fx")
                if fx then
                    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
                end
            end),
            
            
            
            
            TimeEvent(25 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/moose/roar")
            end),
            
            TimeEvent(27 * FRAMES, function(inst)
                local fx = SpawnPrefab("weremoose_transform2_fx")
                if fx then
                    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst:RestartBrain("weremoose_transform")
            if inst._is_weremoose then
                inst.AnimState:SetBank("weremoose")
                inst.AnimState:SetBuild("weremoose_build")
                inst.AnimState:SetMultColour(0.8, 0.7, 0.8, 1)
            end
            for _, sym in ipairs(WEREMOOSE_SYMBOLS) do
                inst.AnimState:ClearOverrideSymbol(sym)
            end
        end,
    },

    
    State{
        name = "weremoose_revert",
        tags = { "busy", "nointerrupt" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()
            inst:StopBrain("weremoose_revert")
            if inst._normal_bank then
                inst.AnimState:SetBank(inst._normal_bank)
            end
            if inst._normal_build then
                inst.AnimState:SetBuild(inst._normal_build)
            end
            for _, sym in ipairs(WEREMOOSE_SYMBOLS) do
                inst.AnimState:OverrideSymbol(sym, "weremoose_build", sym)
            end
            inst.AnimState:PlayAnimation("weremoose_revert")
            inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/moose/death_voice", nil, .5)
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        timeline =
        {
            
            TimeEvent(14 * FRAMES, function(inst)
                local fx = SpawnPrefab("weremoose_revert_fx")
                if fx then
                    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
                end
                
                for _, sym in ipairs(WEREMOOSE_SYMBOLS) do
                    inst.AnimState:ClearOverrideSymbol(sym)
                end
                inst.AnimState:SetMultColour(1, 1, 1, 1)
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst:RestartBrain("weremoose_revert")
            if not inst._is_weremoose then
                if inst._normal_bank then
                    inst.AnimState:SetBank(inst._normal_bank)
                end
                if inst._normal_build then
                    inst.AnimState:SetBuild(inst._normal_build)
                end
                inst.AnimState:SetMultColour(1, 1, 1, 1)
                
                inst.AnimState:Hide("ARM_carry")
                inst.AnimState:Hide("HAT")
                inst.AnimState:Hide("HAIR_HAT")
                inst.AnimState:Show("HAIR_NOHAT")
                inst.AnimState:Show("HAIR")
                inst.AnimState:Show("HEAD")
                inst.AnimState:Hide("HEAD_HAT")
                inst.AnimState:Hide("HEAD_HAT_NOHELM")
                inst.AnimState:Hide("HEAD_HAT_HELM")
                local inv = inst.components.inventory
                if inv then
                    for _, eslot in ipairs({ EQUIPSLOTS.HANDS, EQUIPSLOTS.HEAD, EQUIPSLOTS.BODY }) do
                        local item = inv:GetEquippedItem(eslot)
                        if item and item.components.equippable and item.components.equippable.onequipfn then
                            item.components.equippable.onequipfn(item, inst)
                        end
                    end
                end
                
                if inst._npc_clothing and inst.ApplyNPCClothing then
                    inst:ApplyNPCClothing(inst._npc_clothing, inst._npc_clothing_userid or "")
                end
            end
            for _, sym in ipairs(WEREMOOSE_SYMBOLS) do
                inst.AnimState:ClearOverrideSymbol(sym)
            end
        end,
    },

    
    State{
        name = "moose_tackle_pre",
        tags = { "busy", "nointerrupt" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:StopBrain("moose_tackle")  
            inst.AnimState:PlayAnimation("charge_lag_pre")
            
            local target = inst.bufferedaction and inst.bufferedaction.target
            if target and target:IsValid() then
                inst:FacePoint(target:GetPosition())
            end
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() - FRAMES)
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg.statemem.tackling = true
            inst.sg:GoToState("moose_tackle_start")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:ClearBufferedAction()
                    inst.sg.statemem.tackling = true
                    inst.sg:GoToState("moose_tackle_start")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.tackling then
                inst:RestartBrain("moose_tackle")  
            end
        end,
    },

    
    State{
        name = "moose_tackle_start",
        tags = { "busy", "nointerrupt" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:StopBrain("moose_tackle")
            inst.AnimState:PlayAnimation("charge_pre")
            local speed = NPC_TUNING.WEREMOOSE_TACKLE_SPEED or 12
            inst.Physics:SetMotorVel(speed, 0, 0)
            inst.Physics:ClearCollidesWith(COLLISION.CHARACTERS)  
            inst.Physics:ClearCollidesWith(COLLISION.GIANTS)      
            inst.sg.statemem.tackle_speed = speed  
            inst.sg.statemem.targets = {}
            inst.sg.statemem.edgecount = 0
            
            inst.sg.statemem.trailtask = inst:DoPeriodicTask(0, function(i, data)
                if data.delay > 0 then
                    data.delay = data.delay - 1
                else
                    data.delay = math.random(4, 6)
                    local x, y, z = i.Transform:GetWorldPosition()
                    local angle = i.Transform:GetRotation() * DEGREES
                    local pfx = SpawnPrefab("plant_dug_small_fx")
                    if pfx then
                        pfx.Transform:SetPosition(x - math.cos(angle) * 1.6, 0, z + math.sin(angle) * 1.6)
                        if math.random() < .5 then
                            pfx.AnimState:SetScale(-1, 1)
                        end
                        local scale = .8 + math.random() * .5
                        pfx.Transform:SetScale(scale, scale, scale)
                    end
                end
            end, nil, { delay = 0 })
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/moose/footstep")
            end),
        },

        onupdate = function(inst)
            
            
            local tackle_speed = inst.sg.statemem.tackle_speed or 12
            local vx = inst.Physics:GetMotorVel()
            if vx < tackle_speed * 0.5 then
                inst.Physics:ClearMotorVelOverride()
                inst.Physics:SetMotorVel(tackle_speed, 0, 0)
            end
            
            if MooseTackleCheckCollision(inst, inst.sg.statemem.targets) then
                local x, _, z = inst.Transform:GetWorldPosition()
                inst.sg.statemem.last_hit_x = x
                inst.sg.statemem.last_hit_z = z
            end
            
            if inst.sg.statemem.last_hit_x then
                local x, _, z = inst.Transform:GetWorldPosition()
                local dx = x - inst.sg.statemem.last_hit_x
                local dz = z - inst.sg.statemem.last_hit_z
                local overrun = NPC_TUNING.WEREMOOSE_TACKLE_OVERRUN or 3
                if dx * dx + dz * dz >= overrun * overrun then
                    inst.sg.statemem.stopping = true
                    inst.sg:GoToState("moose_tackle_stop")
                    return
                end
            end
            
            if MooseTackleCheckEdge(inst) then
                inst.sg.statemem.edgecount = (inst.sg.statemem.edgecount or 0) + 1
                if inst.sg.statemem.edgecount >= 3 then
                    inst.sg.statemem.stopping = true
                    inst.sg:GoToState("moose_tackle_stop")
                end
            else
                inst.sg.statemem.edgecount = 0
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.tackling = true
                    inst.sg:GoToState("moose_tackle", {
                        targets = inst.sg.statemem.targets,
                        edgecount = inst.sg.statemem.edgecount,
                        trail = inst.sg.statemem.trailtask,
                        loop = NPC_TUNING.WEREMOOSE_TACKLE_LOOPS or 3,
                        last_hit_x = inst.sg.statemem.last_hit_x,
                        last_hit_z = inst.sg.statemem.last_hit_z,
                    })
                end
            end),
        },

        onexit = function(inst)
            
            if not inst.sg.statemem.tackling then
                if inst.sg.statemem.trailtask then
                    inst.sg.statemem.trailtask:Cancel()
                    inst.sg.statemem.trailtask = nil
                end
            end
            
            if not inst.sg.statemem.tackling and not inst.sg.statemem.stopping then
                inst.Physics:ClearMotorVelOverride()  
                inst.Physics:Stop()
                inst.Physics:CollidesWith(COLLISION.CHARACTERS)
                inst.Physics:CollidesWith(COLLISION.GIANTS)  
                inst.Physics:Teleport(inst.Transform:GetWorldPosition())
                inst:RestartBrain("moose_tackle")
            end
        end,
    },

    
    State{
        name = "moose_tackle",
        tags = { "busy", "nointerrupt" },

        onenter = function(inst, data)
            inst.sg.statemem.targets = data and data.targets or {}
            inst.sg.statemem.edgecount = data and data.edgecount or 0
            inst.sg.statemem.trailtask = data and data.trail or nil
            inst.sg.statemem.loop = data and data.loop or 0
            inst.sg.statemem.last_hit_x = data and data.last_hit_x or nil
            inst.sg.statemem.last_hit_z = data and data.last_hit_z or nil
            inst.sg.statemem.tackle_speed = NPC_TUNING.WEREMOOSE_TACKLE_SPEED or 12  
            if not inst.AnimState:IsCurrentAnimation("charge_loop") then
                inst.AnimState:PlayAnimation("charge_loop", true)
            end
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        timeline =
        {
            TimeEvent(1 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/moose/footstep")
            end),
            TimeEvent(4 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/moose/footstep")
            end),
            TimeEvent(10 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/moose/footstep")
            end),
        },

        onupdate = function(inst)
            
            local tackle_speed = inst.sg.statemem.tackle_speed or 12
            local vx = inst.Physics:GetMotorVel()
            if vx < tackle_speed * 0.5 then
                inst.Physics:ClearMotorVelOverride()
                inst.Physics:SetMotorVel(tackle_speed, 0, 0)
            end
            
            if MooseTackleCheckCollision(inst, inst.sg.statemem.targets) then
                local x, _, z = inst.Transform:GetWorldPosition()
                inst.sg.statemem.last_hit_x = x
                inst.sg.statemem.last_hit_z = z
            end
            
            if inst.sg.statemem.last_hit_x then
                local x, _, z = inst.Transform:GetWorldPosition()
                local dx = x - inst.sg.statemem.last_hit_x
                local dz = z - inst.sg.statemem.last_hit_z
                local overrun = NPC_TUNING.WEREMOOSE_TACKLE_OVERRUN or 3
                if dx * dx + dz * dz >= overrun * overrun then
                    inst.sg.statemem.stopping = true
                    inst.sg:GoToState("moose_tackle_stop")
                    return
                end
            end
            
            if MooseTackleCheckEdge(inst) then
                inst.sg.statemem.edgecount = (inst.sg.statemem.edgecount or 0) + 1
                if inst.sg.statemem.edgecount >= 3 then
                    inst.sg.statemem.stopping = true
                    inst.sg:GoToState("moose_tackle_stop")
                end
            else
                inst.sg.statemem.edgecount = 0
            end
        end,

        ontimeout = function(inst)
            if inst.sg.statemem.loop > 0 then
                inst.sg.statemem.tackling = true
                inst.sg:GoToState("moose_tackle", {
                    targets = inst.sg.statemem.targets,
                    edgecount = inst.sg.statemem.edgecount,
                    trail = inst.sg.statemem.trailtask,
                    loop = inst.sg.statemem.loop - 1,
                    last_hit_x = inst.sg.statemem.last_hit_x,
                    last_hit_z = inst.sg.statemem.last_hit_z,
                })
            else
                inst.sg.statemem.stopping = true
                inst.sg:GoToState("moose_tackle_stop")
            end
        end,

        onexit = function(inst)
            
            if not inst.sg.statemem.tackling then
                if inst.sg.statemem.trailtask then
                    inst.sg.statemem.trailtask:Cancel()
                    inst.sg.statemem.trailtask = nil
                end
            end
            
            if not inst.sg.statemem.tackling and not inst.sg.statemem.stopping then
                inst.Physics:ClearMotorVelOverride()  
                inst.Physics:Stop()
                inst.Physics:CollidesWith(COLLISION.CHARACTERS)
                inst.Physics:CollidesWith(COLLISION.GIANTS)  
                inst.Physics:Teleport(inst.Transform:GetWorldPosition())
                inst:RestartBrain("moose_tackle")
            end
        end,
    },

    
    State{
        name = "moose_tackle_collide",
        tags = { "busy", "nointerrupt" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("charge_bash")
            inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
        end,

        timeline =
        {
            TimeEvent(32 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("nointerrupt")
            end),
            TimeEvent(35 * FRAMES, function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.Physics:ClearMotorVelOverride()  
            inst.Physics:Stop()
            inst.Physics:CollidesWith(COLLISION.CHARACTERS)
            inst.Physics:CollidesWith(COLLISION.GIANTS)  
            inst.Physics:Teleport(inst.Transform:GetWorldPosition())
            inst:RestartBrain("moose_tackle")  
        end,
    },

    
    State{
        name = "moose_tackle_stop",
        tags = { "busy", "nointerrupt" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("charge_pst")
            inst.sg.statemem.speed = NPC_TUNING.WEREMOOSE_TACKLE_SPEED or 12
            inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
            inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/moose/footstep")
            inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/moose/slide")
        end,

        onupdate = function(inst)
            if inst.sg.statemem.speed > .1 then
                inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
                inst.sg.statemem.speed = inst.sg.statemem.speed * .75
            elseif inst.sg.statemem.speed > 0 then
                inst.Physics:Stop()
                inst.sg.statemem.speed = 0
            end
        end,

        timeline =
        {
            TimeEvent(20 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("nointerrupt")
            end),
            TimeEvent(22 * FRAMES, function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.Physics:ClearMotorVelOverride()  
            inst.Physics:Stop()
            inst.Physics:CollidesWith(COLLISION.CHARACTERS)
            inst.Physics:CollidesWith(COLLISION.GIANTS)  
            inst.Physics:Teleport(inst.Transform:GetWorldPosition())
            inst:RestartBrain("moose_tackle")  
        end,
    },

    
    State{
        name = "hit",
        tags = { "busy" },

        onenter = function(inst)
            
            if inst._is_ghost_mode then
                inst.sg:GoToState("ghost_idle")
                return
            end
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit")
            CommonHandlers.UpdateHitRecoveryDelay(inst)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    
    
    
    State{
        name = "death",
        tags = { "busy", "dead" },

        onenter = function(inst)
            WalterStateDbg(inst, "death onenter 开始")
            inst.Physics:Stop()
            if inst.npc_character_type == "walter" then
                WobyRide.DisableForDeath(inst)
            end
            WandaReviveDbg(inst, "state death onenter anim=appear/death")
            if NPC_TUNING.DEBUG_WALTER and inst.npc_character_type == "walter" then
                local rider = inst.components.rider
                local mount = rider ~= nil and rider:IsRiding() and rider:GetMount() or nil
                print("[沃尔特调试]",
                    "死亡状态进入",
                    "riding=" .. tostring(mount ~= nil),
                    "mount=" .. tostring(mount ~= nil and mount.prefab or nil),
                    "mount_big=" .. tostring(mount ~= nil and mount._npc_woby_big or nil),
                    "state=" .. tostring(inst.sg ~= nil and inst.sg.currentstate ~= nil and inst.sg.currentstate.name or nil))
            end
            if inst._groggy_task then
                inst._groggy_task:Cancel()
                inst._groggy_task = nil
            end
            inst._is_groggy = false
            inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "npc_groggy")
            if inst._is_ghost_mode then
                inst.AnimState:SetBank("ghost")
                inst.AnimState:SetBuild("ghost_build")
                
                inst.AnimState:PlayAnimation("appear")
                WalterStateDbg(inst, "death 播放 ghost appear 后")
                
                inst.SoundEmitter:PlaySound("dontstarve/wilson/death")
                
                inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_howl")
            else
                inst.AnimState:PlayAnimation("death")
                WalterStateDbg(inst, "death 播放 death 后")
                RemovePhysicsColliders(inst)
            end
            inst.sg:SetTimeout(5)  
        end,

        ontimeout = function(inst)
            WalterStateDbg(inst, "death timeout")
            if inst._is_ghost_mode then
                inst.sg:GoToState("ghost_idle")
            else
                inst.sg:GoToState("corpse")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    WalterStateDbg(inst, "death animover")
                    if inst._is_ghost_mode then
                        inst.sg:GoToState("ghost_idle")
                    else
                        inst.sg:GoToState("corpse")
                    end
                end
            end),
        },
    },

    
    
    
    State{
        name = "ghost_idle",
        tags = { "idle", "ghost" },

        onenter = function(inst)
            
            WandaReviveDbg(inst, "state ghost_idle onenter anim=idle")
            inst.AnimState:PlayAnimation("idle", true)
            WalterStateDbg(inst, "ghost_idle onenter")
        end,
    },

    
    State{
        name = "ghost_despawn",
        tags = { "busy", "ghost" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:SetBank("ghost")
            inst.AnimState:SetBuild("ghost_build")
            inst.AnimState:SetMultColour(1, 1, 1, 1)
            inst.AnimState:PlayAnimation("dissipate")
            inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_haunt", nil, nil, true)
            inst.sg:SetTimeout(2)
        end,

        ontimeout = function(inst)
            if inst:IsValid() and inst._is_ghost_mode then
                inst:Remove()
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() and inst:IsValid() and inst._is_ghost_mode then
                    inst:Remove()
                end
            end),
        },
    },

    

    State{
        name = "revive_from_ghost",
        tags = { "busy", "noattack", "notarget", "nointerrupt" },

        onenter = function(inst)
            WalterStateDbg(inst, "revive_from_ghost onenter 开始")
            inst.Physics:Stop()
            inst:AddTag("noattack")
            inst:AddTag("notarget")
            if inst.components.combat ~= nil then
                inst.components.combat.canattack = false
                inst.components.combat:SetTarget(nil)
                inst.components.combat:CancelAttack()
            end
            inst.AnimState:SetBank("ghost")
            inst.AnimState:SetBuild("ghost_build")
            inst.AnimState:SetMultColour(1, 1, 1, 1)
            WandaReviveDbg(inst, "state revive_from_ghost phase1 anim=dissipate")
            inst.AnimState:PlayAnimation("dissipate")
            WalterStateDbg(inst, "revive_from_ghost 播放 dissipate 后")
            inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_haunt", nil, nil, true)
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() + FRAMES)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    WalterStateDbg(inst, "revive_from_ghost animover", "phase2=" .. tostring(inst.sg.statemem.phase2))
                    if inst.sg.statemem.phase2 then
                        FinishReviveFromGhost(inst)
                    else
                        StartReviveWakeup(inst)
                    end
                end
            end),
        },

        ontimeout = function(inst)
            WalterStateDbg(inst, "revive_from_ghost timeout", "phase2=" .. tostring(inst.sg.statemem.phase2))
            if inst.sg.statemem.phase2 then
                FinishReviveFromGhost(inst)
            else
                StartReviveWakeup(inst)
            end
        end,

        onexit = function(inst)
            WalterStateDbg(inst, "revive_from_ghost onexit", "restored=" .. tostring(inst.sg.statemem.restored), "completed=" .. tostring(inst.sg.statemem.completed))
            if not inst.sg.statemem.restored and not inst._is_ghost_mode then
                local bank  = inst._saved_bank  or "wilson"
                local build = inst._saved_build or "wilson"
                if inst.npc_character_type == "wanda" then
                    bank = "wilson"
                    build = "wanda"
                end
                inst.AnimState:SetBank(bank)
                inst.AnimState:SetBuild(build)
                if inst.npc_character_type == "wanda" and inst._wanda_reapply_overrides ~= nil then
                    inst._wanda_reapply_overrides(inst)
                end
                inst.AnimState:SetMultColour(1, 1, 1, 1)
                
                inst.AnimState:Hide("ARM_carry")
                inst.AnimState:Hide("HAT")
                inst.AnimState:Hide("HAIR_HAT")
                inst.AnimState:Show("HAIR_NOHAT")
                inst.AnimState:Show("HAIR")
                inst.AnimState:Show("HEAD")
                inst.AnimState:Hide("HEAD_HAT")
                inst.AnimState:Hide("HEAD_HAT_NOHELM")
                inst.AnimState:Hide("HEAD_HAT_HELM")
                local inv = inst.components.inventory
                if inv then
                    for _, eslot in ipairs({ EQUIPSLOTS.HANDS, EQUIPSLOTS.HEAD, EQUIPSLOTS.BODY }) do
                        local item = inv:GetEquippedItem(eslot)
                        if item and item.components.equippable and item.components.equippable.onequipfn then
                            item.components.equippable.onequipfn(item, inst)
                        end
                    end
                end
                if inst._npc_clothing and inst.ApplyNPCClothing then
                    inst:ApplyNPCClothing(inst._npc_clothing, inst._npc_clothing_userid or "")
                end
                WalterStateDbg(inst, "revive_from_ghost onexit 强制恢复外观后", "bank=" .. tostring(bank), "build_target=" .. tostring(build))
            end
        end,
    },

    
    
    State{
        name = "funnyidle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            inst.Physics:Stop()
            
            if inst._is_ghost_mode then
                inst.sg:GoToState("ghost_idle")
                return
            end
            
            local emotes = {
                "idle_inaction",        
                "research",             
                "emoteXL_waving1",      
                "emoteXL_waving2",      
                "emoteXL_happycheer",   
                "emoteXL_annoyed",      
                "emoteXL_facepalm",     
            }
            local anim = emotes[math.random(#emotes)]
            inst.AnimState:PlayAnimation(anim)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    

    
    
    State{
        name = "chop_start",
        tags = { "prechop", "working" },

        onenter = function(inst)
            inst.Physics:Stop()
            
            if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
                inst.AnimState:PlayAnimation("atk")
            elseif inst:HasTag("woodcutter") then
                inst.AnimState:PlayAnimation("woodie_chop_pre")
            else
                inst.AnimState:PlayAnimation("chop_pre")
            end
            inst.sg.statemem.target = inst.bufferedaction and inst.bufferedaction.target
        end,

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.chopping = true
                    inst.sg:GoToState("chop", { target = inst.sg.statemem.target })
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.chopping then
                inst:RemoveTag("prechop")
            end
        end,
    },

    
    State{
        name = "chop",
        tags = { "prechop", "chopping", "working" },

        onenter = function(inst, data)
            
            if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
                inst.AnimState:PlayAnimation("atk")
            elseif inst:HasTag("woodcutter") then
                inst.AnimState:PlayAnimation("woodie_chop_loop")
            else
                inst.AnimState:PlayAnimation("chop_loop")
            end
            
            inst.sg.statemem.target = (data and data.target)
                or (inst.bufferedaction and inst.bufferedaction.target)
            inst.sg.statemem.action = inst:GetBufferedAction()
            
            if NPC_TUNING.DEBUG_CHOP then
                print("[NPC_CHOP] SG: chop onenter, target=", inst.sg.statemem.target and inst.sg.statemem.target.prefab or "nil")
            end
        end,

        timeline =
        {
            TimeEvent(2 * FRAMES, function(inst)
                -- 大脑已改派别的活（如挖矿）→ 立刻停止砍树自循环，回 idle 让该动作执行
                if NPCChopShouldYield(inst) then
                    inst.sg:GoToState("idle")
                    return
                end
                if inst.bufferedaction then
                    inst.sg.statemem.target = inst.bufferedaction.target
                    inst:PerformBufferedAction()
                else
                    local target = inst.sg.statemem.target
                    if target and target:IsValid()
                       and target.components.workable
                       and target.components.workable:CanBeWorked()
                       and target.components.workable.action == ACTIONS.CHOP then
                        inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
                        local hand = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                        local eff = (hand and hand.components.tool and hand.components.tool:GetEffectiveness(ACTIONS.CHOP)) or 1
                        SGNPCCommon.ForceWork(target, inst, eff)
                    end
                end
                
                local target = inst.sg.statemem.target
                if target == nil or not target:IsValid()
                   or target.components.workable == nil
                   or not target.components.workable:CanBeWorked()
                   or target.components.workable:GetWorkAction() ~= ACTIONS.CHOP then
                    
                    if NPC_TUNING.DEBUG_CHOP then
                        print("[NPC_CHOP] SG: 第2帧检测到树砍倒或workable变更 → GoToState('idle')")
                    end
                    inst.sg:GoToState("idle")
                end
            end),

            TimeEvent(8 * FRAMES, function(inst)
                if not inst:HasTag("woodcutter") then return end
                if NPCChopShouldYield(inst) then
                    inst.sg:GoToState("idle")
                    return
                end
                local target = inst.sg.statemem.target
                if target ~= nil and target:IsValid()
                   and target.components.workable ~= nil
                   and target.components.workable:CanBeWorked()
                   and target.components.workable.action == ACTIONS.CHOP then
                    inst:ClearBufferedAction()
                    local hand = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
                    inst:PushBufferedAction(BufferedAction(inst, target, ACTIONS.CHOP, hand))
                    inst.sg.statemem.looping = true
                    inst.sg:GoToState("chop", { target = target })
                end
            end),

            TimeEvent(14 * FRAMES, function(inst)
                if inst:HasTag("woodcutter") then return end
                if NPCChopShouldYield(inst) then
                    inst.sg:GoToState("idle")
                    return
                end
                local target = inst.sg.statemem.target
                if target ~= nil and target:IsValid()
                   and target.components.workable ~= nil
                   and target.components.workable:CanBeWorked()
                   and target.components.workable.action == ACTIONS.CHOP then
                    inst:ClearBufferedAction()
                    local hand = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
                    inst:PushBufferedAction(BufferedAction(inst, target, ACTIONS.CHOP, hand))
                    inst.sg.statemem.looping = true
                    inst.sg:GoToState("chop", { target = target })
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if NPCChopShouldYield(inst) then
                        inst.sg:GoToState("idle")
                        return
                    end
                    local target = inst.sg.statemem.target
                    if target and target:IsValid()
                       and target.components.workable
                       and target.components.workable:CanBeWorked()
                       and target.components.workable.action == ACTIONS.CHOP then
                        
                        inst.sg.statemem.looping = true
                        inst.sg:GoToState("chop", { target = target })
                    else
                        
                        if NPC_TUNING.DEBUG_CHOP then
                            print("[NPC_CHOP] SG: animover 检测到树砍倒 → GoToState('idle')")
                        end
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },

        onexit = function(inst)
            
            if NPC_TUNING.DEBUG_CHOP then
                print("[NPC_CHOP] SG: chop onexit")
            end
        end,
    },

    State{
        name = "winona_place_device",
        tags = { "doing", "busy" },

        onenter = function(inst, data)
            inst.Physics:Stop()
            inst._winona_building = true
            inst.AnimState:SetDeltaTimeMultiplier(1)
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)
            inst.sg.statemem.build_prefab = data and data.prefab
            inst.sg.statemem.build_x     = data and data.x
            inst.sg.statemem.build_z     = data and data.z
            inst.sg:SetTimeout(1.0)
        end,

        ontimeout = function(inst)
            inst._winona_building = false
            local prefab = inst.sg.statemem.build_prefab
            local bx     = inst.sg.statemem.build_x
            local bz     = inst.sg.statemem.build_z
            if prefab and bx and bz then
                local structure = SpawnPrefab(prefab)
                if structure then
                    structure.Transform:SetPosition(bx, 0, bz)
                    structure:PushEvent("onbuilt", { builder = inst })
                end
            end
            inst.sg:GoToState("idle")
        end,

        onexit = function(inst)
            inst._winona_building = false
            inst.AnimState:SetDeltaTimeMultiplier(1)
        end,
    },

    
    
    State{
        name = "wathgrithr_craft",
        tags = { "busy" },

        onenter = function(inst, data)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)
            inst.sg.statemem.on_done = data and data.on_done
            inst.sg.statemem.crafting_lock = data and data.crafting_lock
            inst.sg:SetTimeout(1.0)
        end,

        ontimeout = function(inst)
            if inst.sg.statemem.on_done then
                inst.sg.statemem.on_done(inst)
            end
            inst.AnimState:PlayAnimation("build_pst")
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.crafting_lock then
                inst._npc_crafting_item = nil
            end
        end,
    },

    
    
    State{
        name = "knockout",
        tags = { "busy", "knockout" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("dozy")
            inst.sg:SetTimeout(TUNING.GESTALT_ATTACK_DAMAGE_KO_TIME or 6)
            if inst._groggy_task then
                inst._groggy_task:Cancel()
                inst._groggy_task = nil
            end
            inst._is_groggy = false
            inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "npc_groggy")
        end,

        ontimeout = function(inst)
            inst.sg.statemem.iswaking = true
            inst.sg:GoToState("wakeup")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg.statemem.cometo then
                        inst.sg.statemem.iswaking = true
                        inst.sg:GoToState("wakeup")
                    else
                        inst.AnimState:PlayAnimation("sleep_loop", true)
                        inst.sg:AddStateTag("sleeping")
                    end
                end
            end),
        },
    },

    State{
        name = "wakeup",
        tags = { "busy", "waking" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("wakeup")
            
            
            local GROGGY_SPEED = TUNING.MAX_GROGGY_SPEED_MOD or 0.6
            local RECOVERY_DUR = 2.5  
            
            if inst._groggy_task then
                inst._groggy_task:Cancel()
                inst._groggy_task = nil
            end
            inst._is_groggy = true  
            inst.components.locomotor:SetExternalSpeedMultiplier(inst, "npc_groggy", GROGGY_SPEED)
            local elapsed = 0
            inst._groggy_task = inst:DoPeriodicTask(0.1, function(i)
                elapsed = elapsed + 0.1
                if elapsed >= RECOVERY_DUR then
                    i.components.locomotor:RemoveExternalSpeedMultiplier(i, "npc_groggy")
                    i._is_groggy = false  
                    if i._groggy_task then
                        i._groggy_task:Cancel()
                        i._groggy_task = nil
                    end
                    return
                end
                local t = elapsed / RECOVERY_DUR
                local pct = t * t
                local speedmod = GROGGY_SPEED + pct * (1 - GROGGY_SPEED)
                i.components.locomotor:SetExternalSpeedMultiplier(i, "npc_groggy", speedmod)
            end)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    

    

    
    State{
        name = "becomeyounger_wanda",
        tags = { "busy", "nomorph" },

        onenter = function(inst)
            inst.Physics:Stop()
            if inst._is_ghost_mode or (inst.components.health and inst.components.health:IsDead()) then
                inst.sg:GoToState("ghost_idle")
                return
            end
            inst.AnimState:SetBank("wilson")
            inst.AnimState:SetBuild("wanda")
            inst.AnimState:PlayAnimation("wanda_young")
            inst.SoundEmitter:PlaySound("wanda2/characters/wanda/younger_transition")
            PlayWandaAgingFx(inst, "oldager_become_younger_front_fx")
            PlayWandaAgingFx(inst, "oldager_become_younger_back_fx")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:PushEvent("wanda_refresh_age_visual")
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "becomeolder_wanda",
        tags = { "busy", "nomorph", "nodangle" },

        onenter = function(inst)
            inst.Physics:Stop()
            if inst._is_ghost_mode or (inst.components.health and inst.components.health:IsDead()) then
                inst.sg:GoToState("ghost_idle")
                return
            end
            inst.AnimState:SetBank("wilson")
            inst.AnimState:SetBuild("wanda")
            inst.AnimState:PlayAnimation("wanda_old")
            inst.SoundEmitter:PlaySound("wanda2/characters/wanda/older_transition")
            PlayWandaAgingFx(inst, "oldager_become_older_fx")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:PushEvent("wanda_refresh_age_visual")
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "wurt_throw_waterballoon",
        tags = { "busy", "nomorph", "nodangle", "wurt_casting" },

        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.components.locomotor:Stop()
            if inst._is_ghost_mode then
                inst.sg:GoToState("ghost_idle")
                return
            end

            inst.sg.statemem.target = target

            inst.AnimState:PlayAnimation("throw_pre")
            inst.AnimState:PushAnimation("throw", false)

            inst.sg.statemem.throw_task = inst:DoTaskInTime(7 * FRAMES, function(i)
                i.sg.statemem.throw_task = nil
                WurtCombat.LaunchWaterBalloon(i, i.sg.statemem.target)
            end)
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.throw_task ~= nil then
                inst.sg.statemem.throw_task:Cancel()
                inst.sg.statemem.throw_task = nil
                WurtCombat.LaunchWaterBalloon(inst, inst.sg.statemem.target)
            end
            WurtCombat.EnsureWeaponEquipped(inst)
        end,
    },

    State{
        name = "wurt_cast_tornado",
        tags = { "busy", "nomorph", "nodangle", "wurt_casting" },

        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.components.locomotor:Stop()
            if inst._is_ghost_mode then
                inst.sg:GoToState("ghost_idle")
                return
            end

            inst.sg.statemem.target = target

            -- 第 1 段：强制切换并装备风向标，先手持亮相一会儿（让“装备风向标”看得清）
            local staff = WurtCombat.EquipTornadoStaff(inst)
            if staff == nil then
                inst.sg:GoToState("idle")
                return
            end
            inst.sg.statemem.staff = staff
            inst.AnimState:PlayAnimation("idle", true)

            local equip_delay = NPC_TUNING.HOSTILE_WURT_TORNADO_EQUIP_DELAY or 0.5
            inst.sg.statemem.swing_task = inst:DoTaskInTime(equip_delay, function(i)
                i.sg.statemem.swing_task = nil
                -- 第 2 段：原版风向标(quickcast)施法播放的是“攻击动画”，这里沿用 NPC 攻击动作
                i.AnimState:PlayAnimation("atk")
                local cstaff = i.sg.statemem.staff
                i.SoundEmitter:PlaySound((cstaff ~= nil and cstaff.castsound) or "dontstarve/wilson/attack_weapon")
                -- 攻击挥出瞬间放出龙卷风（约第 8 帧，与普通攻击 DoAttack 帧一致）
                i.sg.statemem.cast_task = i:DoTaskInTime(8 * FRAMES, function(ii)
                    ii.sg.statemem.cast_task = nil
                    if not ii.sg.statemem.cast_done then
                        ii.sg.statemem.cast_done = true
                        WurtCombat.PerformTornadoCast(ii, ii.sg.statemem.target)
                    end
                end)
            end)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                -- 亮相阶段(idle 循环)不收尾；只有攻击动作播完才进入收尾
                if inst.sg.statemem.swing_task ~= nil then return end
                if inst.sg.statemem.swapping then return end
                inst.sg.statemem.swapping = true
                -- 第 3 段：释放完先手持风向标停顿一会儿，再切回武器
                local delay = NPC_TUNING.HOSTILE_WURT_TORNADO_SWAPBACK_DELAY or 0.8
                inst.AnimState:PlayAnimation("idle", true)
                inst.sg.statemem.swap_task = inst:DoTaskInTime(delay, function(i)
                    i.sg.statemem.swap_task = nil
                    i.sg:GoToState("idle")
                end)
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.swing_task ~= nil then
                inst.sg.statemem.swing_task:Cancel()
                inst.sg.statemem.swing_task = nil
            end
            if inst.sg.statemem.cast_task ~= nil then
                inst.sg.statemem.cast_task:Cancel()
                inst.sg.statemem.cast_task = nil
            end
            if inst.sg.statemem.swap_task ~= nil then
                inst.sg.statemem.swap_task:Cancel()
                inst.sg.statemem.swap_task = nil
            end
            -- 被打断也要保证放出一次龙卷风
            if not inst.sg.statemem.cast_done then
                inst.sg.statemem.cast_done = true
                WurtCombat.PerformTornadoCast(inst, inst.sg.statemem.target)
            end
            -- 停顿结束后切回武器
            WurtCombat.EnsureWeaponEquipped(inst)
        end,
    },

    State{
        name = "wanda_rejuvenate",
        tags = { "busy", "nomorph", "nodangle", "nointerrupt" },

        onenter = function(inst)
            inst.Physics:Stop()
            if inst._is_ghost_mode then
                inst.sg:GoToState("ghost_idle")
                return
            end
            inst.AnimState:SetBank("wilson")
            inst.AnimState:SetBuild("wanda")
            inst.AnimState:PlayAnimation("useitem_pre")
            inst.AnimState:PushAnimation("pocketwatch_cast", false)
            inst.AnimState:PushAnimation("useitem_pst", false)
            inst._wanda_in_rejuvenate_cast = true

            local equip = nil
            local healwatch = nil
            if inst._wanda_ensure_heal_watch ~= nil then
                healwatch = inst._wanda_ensure_heal_watch(inst)
            end
            if equip == nil and inst.components.inventory then
                equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            end
            local watch_build = healwatch and healwatch.AnimState and healwatch.AnimState:GetBuild() or nil
            if watch_build == nil or watch_build == "" then
                watch_build = equip and equip.AnimState and equip.AnimState:GetBuild() or nil
            end
            if watch_build ~= nil and watch_build ~= "" then
                inst.AnimState:OverrideSymbol("watchprop", watch_build, "watchprop")
            else
                inst.AnimState:ClearOverrideSymbol("watchprop")
            end
            inst.sg.statemem.castfxcolour = (equip and equip.castfxcolour) or { 1, 1, 1 }
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                local fx = SpawnPrefab((inst.components.rider ~= nil and inst.components.rider:IsRiding())
                    and "pocketwatch_cast_fx_mount"
                    or "pocketwatch_cast_fx")
                if fx ~= nil then
                    fx.entity:SetParent(inst.entity)
                    if fx.SetUp ~= nil then
                        fx:SetUp(inst.sg.statemem.castfxcolour or { 1, 1, 1 })
                    end
                    inst.sg.statemem.stafffx = fx
                end
                inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/heal")
            end),
            TimeEvent(16 * FRAMES, function(inst)
                if inst.sg.statemem.stafffx ~= nil then
                    local light = SpawnPrefab("staff_castinglight_small")
                    if light ~= nil then
                        light.Transform:SetPosition(inst.Transform:GetWorldPosition())
                        if light.SetUp ~= nil then
                            light:SetUp(inst.sg.statemem.castfxcolour or { 1, 1, 1 }, 0.75, 0)
                        end
                        inst.sg.statemem.stafflight = light
                    end
                end
                inst:PushEvent("wanda_rejuvenate_apply")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:PushEvent("wanda_refresh_age_visual")
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst._wanda_in_rejuvenate_cast = nil
            inst.AnimState:ClearOverrideSymbol("watchprop")
            if inst.sg.statemem.stafffx ~= nil and inst.sg.statemem.stafffx:IsValid() then
                inst.sg.statemem.stafffx:Remove()
            end
            if inst.sg.statemem.stafflight ~= nil and inst.sg.statemem.stafflight:IsValid() then
                inst.sg.statemem.stafflight:Remove()
            end
        end,
    },

    State{
        name = "wanda_pocketwatch_cast",
        tags = { "busy", "nomorph", "nodangle", "nointerrupt" },

        onenter = function(inst, data)
            inst.Physics:Stop()
            if inst._is_ghost_mode then
                inst.sg:GoToState("ghost_idle")
                return
            end
            inst.AnimState:SetBank("wilson")
            inst.AnimState:SetBuild("wanda")
            inst.AnimState:PlayAnimation("useitem_pre")
            inst.AnimState:PushAnimation("pocketwatch_cast", false)
            inst.AnimState:PushAnimation("useitem_pst", false)

            inst.sg.statemem.apply_event = (data and data.apply_event) or "wanda_watch_cast_apply"
            inst.sg.statemem.cast_sound = (data and data.cast_sound) or "wanda2/characters/wanda/watch/heal"
            local watch_build = data and data.watch_build or nil
            if (watch_build == nil or watch_build == "") and inst.components.inventory then
                local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                watch_build = equip and equip.AnimState and equip.AnimState:GetBuild() or nil
            end
            if watch_build ~= nil and watch_build ~= "" then
                inst.AnimState:OverrideSymbol("watchprop", watch_build, "watchprop")
            else
                inst.AnimState:ClearOverrideSymbol("watchprop")
            end
            inst.sg.statemem.castfxcolour = { 1, 1, 1 }
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                local fx = SpawnPrefab((inst.components.rider ~= nil and inst.components.rider:IsRiding())
                    and "pocketwatch_cast_fx_mount"
                    or "pocketwatch_cast_fx")
                if fx ~= nil then
                    fx.entity:SetParent(inst.entity)
                    if fx.SetUp ~= nil then
                        fx:SetUp(inst.sg.statemem.castfxcolour or { 1, 1, 1 })
                    end
                    inst.sg.statemem.stafffx = fx
                end
                if inst.sg.statemem.cast_sound then
                    inst.SoundEmitter:PlaySound(inst.sg.statemem.cast_sound)
                end
            end),
            TimeEvent(16 * FRAMES, function(inst)
                if inst.sg.statemem.stafffx ~= nil then
                    local light = SpawnPrefab("staff_castinglight_small")
                    if light ~= nil then
                        light.Transform:SetPosition(inst.Transform:GetWorldPosition())
                        if light.SetUp ~= nil then
                            light:SetUp(inst.sg.statemem.castfxcolour or { 1, 1, 1 }, 0.75, 0)
                        end
                        inst.sg.statemem.stafflight = light
                    end
                end
                if inst.sg.statemem.apply_event then
                    inst:PushEvent(inst.sg.statemem.apply_event)
                end
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol("watchprop")
            if inst.sg.statemem.stafffx ~= nil and inst.sg.statemem.stafffx:IsValid() then
                inst.sg.statemem.stafffx:Remove()
            end
            if inst.sg.statemem.stafflight ~= nil and inst.sg.statemem.stafflight:IsValid() then
                inst.sg.statemem.stafflight:Remove()
            end
        end,
    },

    
    State{
        name = "wortox_soulcast",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            if inst._is_ghost_mode then
                inst.sg:GoToState("ghost_idle")
                return
            end
            inst.AnimState:PlayAnimation("pickup")
            inst.AnimState:PushAnimation("pickup_pst", false)
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    
    State{
        name = "wortox_soulhop_pre",
        tags = { "busy", "noattack", "nointerrupt", "nomorph" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst.sg.statemem.token = data and data.token or nil
            inst.sg.statemem.dest = data and data.dest or nil
            if inst.sg.statemem.token == nil or inst.sg.statemem.dest == nil then
                inst.sg:GoToState("idle")
                return
            end
            inst.AnimState:PlayAnimation("wortox_portal_jumpin_pre")
            inst:ForceFacePoint(inst.sg.statemem.dest:Get())
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.to_in = true
                    inst.sg:GoToState("wortox_soulhop_in", {
                        token = inst.sg.statemem.token,
                        dest = inst.sg.statemem.dest,
                    })
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.to_in then
                SetWortoxSoulHopResult(inst, inst.sg.statemem.token, false)
            end
        end,
    },

    State{
        name = "wortox_soulhop_in",
        tags = { "busy", "noattack", "nointerrupt", "nomorph" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst.sg.statemem.token = data and data.token or nil
            inst.sg.statemem.dest = data and data.dest or nil
            if inst.sg.statemem.token == nil or inst.sg.statemem.dest == nil then
                inst.sg:GoToState("idle")
                return
            end

            local x, y, z = inst.Transform:GetWorldPosition()
            local fx = SpawnPrefab("wortox_portal_jumpin_fx")
            if fx then
                fx.Transform:SetPosition(x, y, z)
            end
            inst.AnimState:PlayAnimation("wortox_portal_jumpin")
            inst.components.health:SetInvincible(true)
            inst.DynamicShadow:Enable(false)
            inst.sg:SetTimeout(11 * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg.statemem.going_out = true
            inst.sg:GoToState("wortox_soulhop_out", {
                token = inst.sg.statemem.token,
                dest = inst.sg.statemem.dest,
            })
        end,

        onexit = function(inst)
            if not inst.sg.statemem.going_out then
                inst.components.health:SetInvincible(false)
                inst.DynamicShadow:Enable(true)
                SetWortoxSoulHopResult(inst, inst.sg.statemem.token, false)
            end
        end,
    },

    State{
        name = "wortox_soulhop_out",
        tags = { "busy", "noattack", "nointerrupt", "nomorph" },

        onenter = function(inst, data)
            inst.sg.statemem.token = data and data.token or nil
            inst.sg.statemem.dest = data and data.dest or nil
            if inst.sg.statemem.token == nil or inst.sg.statemem.dest == nil then
                inst.sg:GoToState("idle")
                return
            end

            local dest = inst.sg.statemem.dest
            ToggleOffPhysics(inst)
            inst.Physics:Teleport(dest.x, 0, dest.z)
            inst.AnimState:PlayAnimation("wortox_portal_jumpout")
            local fx = SpawnPrefab("wortox_portal_jumpout_fx")
            if fx then
                fx.Transform:SetPosition(dest.x, 0, dest.z)
            end
            inst.sg:SetTimeout(14 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/hop_out")
            end),
            TimeEvent(7 * FRAMES, function(inst)
                inst.components.health:SetInvincible(false)
                inst.sg:RemoveStateTag("noattack")
            end),
            TimeEvent(8 * FRAMES, function(inst)
                inst.DynamicShadow:Enable(true)
                ToggleOnPhysics(inst)
            end),
        },

        ontimeout = function(inst)
            inst.sg.statemem.completed = true
            SetWortoxSoulHopResult(inst, inst.sg.statemem.token, true)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            inst.components.health:SetInvincible(false)
            inst.DynamicShadow:Enable(true)
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end
            
            if not inst.sg.statemem.completed then
                SetWortoxSoulHopResult(inst, inst.sg.statemem.token, false)
            end
        end,
    },

    
    
    
    State{
        name = "play_flute",
        tags = { "doing", "busy", "playing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("flute", false)
            
            inst.AnimState:OverrideSymbol("pan_flute01", "pan_flute", "pan_flute01")
        end,

        timeline =
        {
            TimeEvent(30 * FRAMES, function(inst)
                if inst:PerformBufferedAction() then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/flute_LP", "flute")
                else
                    inst.sg.statemem.action_failed = true
                    inst.AnimState:SetFrame(94)
                end
            end),
            TimeEvent(52 * FRAMES, function(inst)
                if not inst.sg.statemem.action_failed then
                    inst.sg:RemoveStateTag("busy")
                end
            end),
            TimeEvent(85 * FRAMES, function(inst)
                if not inst.sg.statemem.action_failed then
                    inst.SoundEmitter:KillSound("flute")
                end
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("flute")
            inst.AnimState:ClearOverrideSymbol("pan_flute01")
        end,
    },

    
    State{
        name = "dostorytelling",
        tags = { "doing", "busy", "nodangle" },

        onenter = function(inst)
            if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
                inst.sg:GoToState("npc_woby_dismount")
                return
            end
            RestoreNormalCharacterBank(inst)
            inst.sg.statemem.action = inst.bufferedaction
            inst.components.locomotor:Stop()
            if not inst:PerformBufferedAction() then
                inst.sg.statemem.not_interrupted = true
                inst.sg:GoToState("idle")
                return
            end
            inst.AnimState:PlayAnimation("idle_walter_storytelling_pre")
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, DoTalkSound),
        },

        events =
        {
            EventHandler("ontalk", function(inst)
                inst.sg.statemem.started = true
            end),
            EventHandler("donetalking", function(inst)
                if inst.sg.statemem.started then
                    inst.sg.statemem.not_interrupted = true
                    StopTalkSound(inst)
                    inst.AnimState:PlayAnimation("idle_walter_storytelling_pst")
                    inst.sg:GoToState("idle", true)
                end
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.not_interrupted = true
                    inst.sg:GoToState("dostorytelling_loop")
                end
            end),
        },

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action then
                inst:ClearBufferedAction()
            end
            if not inst.sg.statemem.not_interrupted then
                StopTalkSound(inst, true)
                if inst.components.talker ~= nil then
                    inst.components.talker:ShutUp()
                end
            end
        end,
    },

    State{
        name = "dostorytelling_loop",
        tags = { "doing", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation(math.random() < 0.7 and "idle_walter_storytelling" or "idle_walter_storytelling_2")
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.not_interrupted = true
                    inst.sg:GoToState("dostorytelling_loop")
                end
            end),
            EventHandler("donetalking", function(inst)
                inst.sg.statemem.not_interrupted = true
                StopTalkSound(inst)
                inst.AnimState:PlayAnimation("idle_walter_storytelling_pst")
                inst.sg:GoToState("idle", true)
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.not_interrupted then
                StopTalkSound(inst, true)
                if inst.components.talker ~= nil then
                    inst.components.talker:ShutUp()
                end
            end
        end,
    },

    
    
    

    State{
        name = "npc_book",
        tags = { "doing", "busy" },
        
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()
            inst:StopBrain("npc_book")
            SpawnNPCBookCastFx(inst)
            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("book", false)
        end,
        
        timeline = {
            
            TimeEvent(20 * FRAMES, function(inst)
                if inst._on_book_action then
                    inst._on_book_action(inst)
                end
            end),
        },
        
        events = {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
        
        onexit = function(inst)
            inst:RestartBrain("npc_book")
            
            inst._on_book_action = nil
        end,
    },
}




local function IsRidingNpcWoby(inst)
    if inst._npc_woby_ride_disabled or inst._is_ghost_mode then
        return false
    end
    local rider = inst.components.rider
    local mount = rider ~= nil and rider:IsRiding() and rider:GetMount() or nil
    return mount ~= nil and mount:HasTag("npc_woby")
end

local function IsGhostVisual(inst)
    if inst == nil then
        return false
    end
    if inst._is_ghost_mode or inst:HasTag("ghost") then
        return true
    end
    return SafeAnimValue(inst, "GetBuild") == "ghost_build"
end


local function ghost_or_default(default_anim)
    return function(inst)
        if IsGhostVisual(inst) or inst._npc_woby_ride_disabled then return "idle" end
        if IsRidingNpcWoby(inst) then
            if default_anim == "run_pre" then return "run_woby_pre" end
            if default_anim == "run_loop" then return "run_woby_loop" end
            if default_anim == "run_pst" then return "run_woby_pst" end
        end
        if inst._is_groggy then return "idle_walk" end
        if inst.components.inventory and inst.components.inventory:IsHeavyLifting() then
            return SGNPCCommon.GetHeavyWalkAnim(default_anim)
        end
        return default_anim
    end
end


CommonStates.AddRunStates(states,
{
    runtimeline =
    {
        TimeEvent(0,            PlayFootstep),
        TimeEvent(10 * FRAMES,  PlayFootstep),
    },
},
{
    startrun = ghost_or_default("run_pre"),
    run      = ghost_or_default("run_loop"),
    stoprun  = ghost_or_default("run_pst"),
})

for _, st in ipairs(states) do
    if st.name == "run_start" or st.name == "run" or st.name == "run_stop" then
        local _orig_run_onenter = st.onenter
        st.onenter = function(inst, ...)
            if IsHardDeathLocked(inst) then
                if inst.components.locomotor ~= nil then
                    inst.components.locomotor:StopMoving()
                    inst.components.locomotor:Stop()
                end
                if inst._is_ghost_mode then
                    inst.sg:GoToState("ghost_idle")
                elseif inst.components.health ~= nil and inst.components.health:IsDead() then
                    inst.sg:GoToState("death")
                else
                    inst.sg:GoToState("idle")
                end
                return
            end
            _orig_run_onenter(inst, ...)
        end
    end
end



CommonStates.AddIdle(states, "funnyidle", function(inst)
    if inst._is_ghost_mode then return "idle" end
    if IsRidingNpcWoby(inst) then return "idle_loop" end
    
    if inst._is_groggy then return "idle_groggy" end
    
    if inst._is_wormwood then return "idle_wormwood" end
    return "idle_loop"
end)

for _, st in ipairs(states) do
    if st.name == "idle" then
        local _orig_idle_onenter = st.onenter
        local _orig_idle_ontimeout = st.ontimeout
        local _orig_idle_events = st.events
        st.onenter = function(inst, pushanim)
            if inst.components.health ~= nil and inst.components.health:IsDead() then
                if inst.components.locomotor then
                    inst.components.locomotor:StopMoving()
                end
                inst.sg:GoToState("death")
                return
            end

            if inst._npc_tired and not inst._is_ghost_mode then
                if inst.components.locomotor then
                    inst.components.locomotor:StopMoving()
                end
                local sit_anims = inst._npc_tired_sit_variant
                if sit_anims == nil then
                    sit_anims = 2  --总共4种， 随机改回 math.random(4)
                    inst._npc_tired_sit_variant = sit_anims
                end
                if not inst.AnimState:IsCurrentAnimation("emote_loop_sit"..sit_anims)
                   and not inst.AnimState:IsCurrentAnimation("emote_pre_sit"..sit_anims) then
                    inst.AnimState:PlayAnimation("emote_pre_sit"..sit_anims)
                    inst.AnimState:PushAnimation("emote_loop_sit"..sit_anims, true)
                end
                return
            end

            if inst._is_ghost_mode then
                local anim = "idle"
                
                inst.AnimState:PlayAnimation(anim)
                return
            end

            if inst._is_groggy then
                if inst.components.locomotor then
                    inst.components.locomotor:StopMoving()
                end
                if not inst.AnimState:IsCurrentAnimation("idle_groggy")
                   and not inst.AnimState:IsCurrentAnimation("idle_groggy_pre") then
                    inst.AnimState:PlayAnimation("idle_groggy_pre")
                    inst.AnimState:PushAnimation("idle_groggy", true)
                end
                inst.sg:SetTimeout(1)  
                return
            end
            _orig_idle_onenter(inst, pushanim)
        end
        st.ontimeout = function(inst)
            if IsRidingNpcWoby(inst) then
                inst.sg:GoToState("idle")
            elseif _orig_idle_ontimeout ~= nil then
                _orig_idle_ontimeout(inst)
            end
        end
        st.events =
        {
            animover = EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if IsRidingNpcWoby(inst) then
                        inst.sg:GoToState("idle")
                    elseif _orig_idle_events ~= nil and _orig_idle_events.animover ~= nil then
                        _orig_idle_events.animover.fn(inst)
                    end
                end
            end),
        }
        break
    end
end

table.insert(states, State{
    name = "npc_woby_mount",
    tags = { "doing", "busy", "nomorph" },

    onenter = function(inst)
        if IsWalterWobyActionLocked(inst) then
            inst.sg:GoToState(inst._is_ghost_mode and "ghost_idle" or "idle")
            return
        end
        inst.components.locomotor:Stop()
        inst.AnimState:SetBank("wilsonbeefalo")
        inst.AnimState:PlayAnimation("mount")
        inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/bark")
    end,

    timeline =
    {
        TimeEvent(20 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/beefalo/saddle/dismount")
            inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
        end),
    },

    events =
    {
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },
})

table.insert(states, State{
    name = "npc_woby_dismount",
    tags = { "doing", "busy", "nomorph", "dismounting" },

    onenter = function(inst)
        if IsWalterWobyActionLocked(inst) then
            if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
                inst.components.rider:ActualDismount()
                RestoreNormalCharacterBank(inst)
            end
            inst.sg:GoToState(inst._is_ghost_mode and "ghost_idle" or "idle")
            return
        end
        inst.components.locomotor:Stop()
        inst.AnimState:SetBank("wilsonbeefalo")
        inst.AnimState:PlayAnimation("dismount")
    end,

    timeline =
    {
        TimeEvent(15 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/beefalo/saddle/dismount")
        end),
    },

    events =
    {
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                local mount = inst.components.rider ~= nil and inst.components.rider:IsRiding()
                    and inst.components.rider:ActualDismount() or nil
                RestoreNormalCharacterBank(inst)
                if inst._npc_woby_after_dismount ~= nil then
                    local fn = inst._npc_woby_after_dismount
                    inst._npc_woby_after_dismount = nil
                    fn(inst, mount)
                end
                inst.sg:GoToState("idle")
            end
        end),
    },

    onexit = function(inst)
        if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
            local mount = inst.components.rider:ActualDismount()
            RestoreNormalCharacterBank(inst)
            if inst._npc_woby_after_dismount ~= nil then
                local fn = inst._npc_woby_after_dismount
                inst._npc_woby_after_dismount = nil
                fn(inst, mount)
            end
        elseif inst._npc_woby_after_dismount ~= nil then
            RestoreNormalCharacterBank(inst)
            local fn = inst._npc_woby_after_dismount
            inst._npc_woby_after_dismount = nil
            fn(inst, nil)
        end
    end,
})


SGNPCCommon.AddPerformActionStates(states)


SGNPCCommon.AddEquipAnimStates(states)

SGNPCCommon.AddMineStates(states)

SGNPCCommon.AddEatStates(states)

SGNPCCommon.AddEmoteState(states)


SGNPCCommon.AddActionDigStates(states)

SGNPCCommon.AddActionPourStates(states)




table.insert(states, State{
    name = "farm_plant",
    tags = { "doing", "busy" },

    onenter = function(inst, data)
        inst.Physics:Stop()
        inst.sg.statemem.spot = data and data.spot or nil
        inst.AnimState:PlayAnimation("build_pre")
        inst.AnimState:PushAnimation("build_loop", false)
    end,

    events =
    {
        EventHandler("animqueueover", function(inst)
            local spot = inst.sg.statemem.spot
            if spot and inst._farmer then
                inst._farmer:DoPlant(spot)
            end
            inst.AnimState:PlayAnimation("build_pst")
            inst.sg:GoToState("idle")
        end),
    },
})


SGNPCCommon.AddActionTillStates(states)


table.insert(states, State{
    name = "npc_summon_abigail",
    tags = { "doing", "busy", "nodangle" },

    onenter = function(inst)
        inst.components.locomotor:Stop()
        if inst.brain then inst.brain:Stop() end
        inst.AnimState:PlayAnimation("wendy_channel")
        inst.AnimState:PushAnimation("wendy_channel_pst", false)
    end,

    timeline = {
        TimeEvent(51 * FRAMES, function(inst)
            
            if inst._summon_abigail_fn then
                inst._summon_abigail_fn(inst)
            end
        end),
    },

    events = {
        EventHandler("animqueueover", function(inst)
            if inst.brain then inst.brain:Start() end
            inst.sg:GoToState("idle")
        end),
    },

    onexit = function(inst)
        if inst.brain then inst.brain:Start() end
    end,
})


table.insert(states, State{
    name = "npc_unsummon_abigail",
    tags = { "doing", "busy", "nodangle" },

    onenter = function(inst)
        inst.components.locomotor:Stop()
        if inst.brain then inst.brain:Stop() end
        inst.AnimState:PlayAnimation("wendy_recall")
        inst.AnimState:PushAnimation("wendy_recall_pst", false)
    end,

    timeline = {
        TimeEvent(25 * FRAMES, function(inst)
            
            if inst._unsummon_abigail_fn then
                inst._unsummon_abigail_fn(inst)
            end
        end),
    },

    events = {
        EventHandler("animqueueover", function(inst)
            if inst.brain then inst.brain:Start() end
            inst.sg:GoToState("idle")
        end),
    },

    onexit = function(inst)
        if inst.brain then inst.brain:Start() end
    end,
})


table.insert(states, State{
    name = "npc_makeballoon",
    tags = { "doing", "busy", "nodangle" },

    onenter = function(inst)
        inst.Physics:Stop()
        inst.SoundEmitter:PlaySound("dontstarve/common/balloon_make", "make")
        inst.SoundEmitter:PlaySound("dontstarve/common/balloon_blowup")
        inst.AnimState:PlayAnimation("build_pre")
        inst.AnimState:PushAnimation("build_loop", true)
        inst.sg:SetTimeout(1)
    end,

    ontimeout = function(inst)
        inst.SoundEmitter:KillSound("make")
        inst.AnimState:PlayAnimation("build_pst")
        
        local x, y, z = inst.Transform:GetWorldPosition()
        local angle = inst.Transform:GetRotation()
        local angle_offset = GetRandomMinMax(-10, 10)
        angle_offset = angle_offset + (angle_offset < 0 and -65 or 65)
        angle = (angle + angle_offset) * DEGREES
        local bx = x + 0.5 * math.cos(angle)
        local bz = z - 0.5 * math.sin(angle)
        local balloon = SpawnPrefab("balloon")
        if balloon then
            balloon.Transform:SetPosition(bx, 0, bz)
            
            balloon.persists = false
            
            if balloon.components.combat then
                balloon.components.combat:SetDefaultDamage(0)
            end

            
            local target = nil
            local search_radius = NPC_TUNING.WES_BALLOON_TARGET_RANGE or 15
            local bx2, by2, bz2 = balloon.Transform:GetWorldPosition()
            
            local nearby = TheSim:FindEntities(bx2, by2, bz2, search_radius, nil, {"INLIMBO", "invisible", "playerghost"}, {"player", "npcfriend"})

            
            local valid_targets = {}
            for _, ent in ipairs(nearby) do
                if ent:IsValid() and ent ~= inst 
                   and ent.components.health and not ent.components.health:IsDead() then
                    table.insert(valid_targets, ent)
                end
            end

            if #valid_targets > 0 then
                target = valid_targets[math.random(#valid_targets)]
            end

            
            local pop_time = NPC_TUNING.WES_BALLOON_POP_TIME or 10
            balloon:DoTaskInTime(pop_time, function()
                if balloon:IsValid() and balloon.components.health and not balloon.components.health:IsDead() then
                    balloon.components.health:Kill()
                end
            end)

            
            if target then
                local flight_speed = NPC_TUNING.WES_BALLOON_FLIGHT_SPEED or 3
                local approach_dist = NPC_TUNING.WES_BALLOON_APPROACH_DIST or 1.5

                balloon._flight_task = balloon:DoPeriodicTask(1/30, function()
                    
                    if not balloon:IsValid() or balloon.components.health:IsDead() then
                        if balloon._flight_task then
                            balloon._flight_task:Cancel()
                            balloon._flight_task = nil
                        end
                        return
                    end

                    if not target:IsValid() or (target.components.health and target.components.health:IsDead()) then
                        if balloon._flight_task then
                            balloon._flight_task:Cancel()
                            balloon._flight_task = nil
                        end
                        return
                    end

                    local bpos_x, bpos_y, bpos_z = balloon.Transform:GetWorldPosition()
                    local tpos_x, tpos_y, tpos_z = target.Transform:GetWorldPosition()

                    local dx = tpos_x - bpos_x
                    local dz = tpos_z - bpos_z
                    local dist = math.sqrt(dx * dx + dz * dz)

                    
                    if dist < approach_dist then
                        if balloon._flight_task then
                            balloon._flight_task:Cancel()
                            balloon._flight_task = nil
                        end
                        
                        if balloon.components.health and not balloon.components.health:IsDead() then
                            balloon.components.health:Kill()
                        end
                        
                        if target:IsValid() and target.components.talker and target.npc_character_type then
                            local line = NPC_SPEECH.GetLine(NPC_SPEECH.BALLOON_REACT, target.npc_character_type)
                            if line then
                                target:DoTaskInTime(0.3, function()
                                    if target:IsValid() and target.components.talker then
                                        target.components.talker:Say(line)
                                    end
                                end)
                            end
                        end
                        return
                    end

                    
                    local move_speed = flight_speed / 30  
                    local nx = bpos_x + (dx / dist) * move_speed
                    local nz = bpos_z + (dz / dist) * move_speed
                    balloon.Transform:SetPosition(nx, bpos_y, nz)

                    
                    local angle = -math.atan2(dz, dx) / DEGREES
                    balloon.Transform:SetRotation(angle)
                end)
            end
        end
    end,

    events =
    {
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },
})

SGNPCCommon.AddFarmingStates(states)

SGNPCCommon.AddBuildingStates(states)

SGNPCCommon.AddHammerStates(states)
SGNPCCommon.AddChopStates(states)
SGNPCCommon.AddDigStates(states)

SGNPCCommon.AddInventoryStates(states)

SGNPCCommon.AddContainerStates(states)

SGNPCCommon.AddSlapStates(states)

SGNPCCommon.AddOceanFishingStates(states)



SGNPCCommon.AddHopStates(states)


SGNPCCommon.AddGiveState(states)


-- ── 薇洛月焰施法（channelcast 持物动画，锁定 LUNARFIRE_DURATION 秒）──
table.insert(states, State{
    name = "npc_lunarfire",
    tags = { "busy", "doing" },

    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("channelcast_idle_pre")
        inst.AnimState:PushAnimation("channelcast_idle", true)
        inst.sg:SetTimeout(NPC_TUNING.LUNARFIRE_CAST_TIME or 2)
    end,

    ontimeout = function(inst)
        inst.AnimState:PlayAnimation("channelcast_idle_pst")
        inst.sg:GoToState("idle", true)
    end,
})


CommonStates.AddFrozenStates(states)
CommonStates.AddElectrocuteStates(states, nil, {
    loop = "shock",      
    pst = "shock_pst",
})
CommonStates.AddInitState(states, "idle")
CommonStates.AddCorpseStates(states)
CommonStates.AddSinkAndWashAshoreStates(states)
CommonStates.AddVoidFallStates(states)







table.insert(states, State{
    name = "npc_rift_arrive",
    tags = { "busy", "nopredict", "nomorph", "nodangle", "jumping" },

    onenter = function(inst, data)
        
        
        inst:Hide()
        inst.AnimState:SetMultColour(1, 1, 1, 0)
        if inst.DynamicShadow then inst.DynamicShadow:Enable(false) end
        if inst.Light then inst.Light:Enable(false) end
        inst.components.locomotor:Stop()
        local is_wanda = (data and data.is_wanda) or (inst.npc_character_type == "wanda")
        inst.sg.statemem.is_wanda = is_wanda

        if is_wanda then
            
            inst.AnimState:PlayAnimation("jumpportal_out")
        else
            
            inst.AnimState:PlayAnimation("jumpportal2_out")
            inst.AnimState:PushAnimation("jumpportal2_out_pst", false)
        end
    end,

    timeline =
    {
        
        TimeEvent(16 * FRAMES, function(inst)
            inst:Show()
            inst.AnimState:SetMultColour(1, 1, 1, 1)
            if inst.DynamicShadow then
                inst.DynamicShadow:Enable(true)
            end
            if inst.Light then inst.Light:Enable(true) end
            if inst.sg.statemem.is_wanda then
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
            end
        end),
        
        TimeEvent(59 * FRAMES, function(inst)
            if not inst.sg.statemem.is_wanda then
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
            end
        end),
    },

    events =
    {
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                
                if inst.components.talker and inst.npc_character_type then
                    local line = NPC_SPEECH.GetLine(NPC_SPEECH.RIFT_ARRIVE, inst.npc_character_type)
                    if line then
                        inst:DoTaskInTime(0.2, function()
                            if inst:IsValid() and inst.components.talker then
                                inst.components.talker:Say(line)
                            end
                        end)
                    end
                end
                inst.sg:GoToState("idle")
            end
        end),
    },

    onexit = function(inst)
        
        inst:Show()
        inst.AnimState:SetMultColour(1, 1, 1, 1)
        if inst.DynamicShadow then
            inst.DynamicShadow:Enable(true)
        end
        if inst.Light then inst.Light:Enable(true) end
    end,
})




table.insert(states, State{
    name = "npc_fishing_pre",
    tags = { "prefish", "fishing" },

    onenter = function(inst, data)
        
        inst.sg.statemem.target = data and data.target or nil
        if NPC_TUNING.DEBUG_FISHING then print("[NPC_FISHING] SG: npc_fishing_pre, target=" .. tostring(data and data.target)) end
        
        if inst.sg.statemem.target and inst.sg.statemem.target:IsValid() then
            inst:ForceFacePoint(inst.sg.statemem.target.Transform:GetWorldPosition())
        end
        inst.AnimState:PlayAnimation("fishing_pre")
        inst.AnimState:PushAnimation("fishing_cast", false)
    end,

    timeline =
    {
        TimeEvent(13 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_cast")
        end),
    },

    events =
    {
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_baitsplash")
                inst.sg:GoToState("npc_fishing_loop", { target = inst.sg.statemem.target })
            end
        end),
    },
})


table.insert(states, State{
    name = "npc_fishing_loop",
    tags = { "fishing", "canrotate" },

    onenter = function(inst, data)
        inst.sg.statemem.target = data and data.target or nil
        inst.AnimState:PlayAnimation("fishing_idle", true)  
        
        local wait_min = NPC_TUNING.FISHING_WAIT_MIN or 3
        local wait_max = NPC_TUNING.FISHING_WAIT_MAX or 8
        local wait_time = wait_min + math.random() * (wait_max - wait_min)
        if NPC_TUNING.DEBUG_FISHING then print("[NPC_FISHING] SG: npc_fishing_loop, wait_time=" .. tostring(wait_time)) end
        inst.sg:SetTimeout(wait_time)
    end,

    ontimeout = function(inst)
        
        inst.sg:GoToState("npc_fishing_catch", { target = inst.sg.statemem.target })
    end,
})


table.insert(states, State{
    name = "npc_fishing_catch",
    tags = { "fishing", "catchfish", "busy" },

    onenter = function(inst, data)
        inst.sg.statemem.target = data and data.target or nil
        inst.AnimState:PlayAnimation("fish_catch")

        
        local pond = inst.sg.statemem.target
        if pond and pond:IsValid() and pond.components.fishable then
            local fishable = pond.components.fishable
            if fishable.fishleft and fishable.fishleft > 0 then
                
                local fish_prefab = (fishable.getfishfn ~= nil and fishable.getfishfn(pond))
                    or GetRandomKey(fishable.fish)
                    or "fish"
                if NPC_TUNING.DEBUG_FISHING then print("[NPC_FISHING] SG: npc_fishing_catch, pond=" .. tostring(pond) .. ", fish_prefab=" .. tostring(fish_prefab) .. ", fishleft=" .. tostring(fishable.fishleft)) end
                
                fishable.fishleft = fishable.fishleft - 1
                
                if fishable.fishleft < fishable.maxfish and fishable.fishrespawntime
                    and not fishable.respawntask then
                    fishable:RefreshFish()
                end
                local x, y, z = inst.Transform:GetWorldPosition()
                local spawn_x, spawn_z
                if pond and pond:IsValid() then
                    local px, py, pz = pond.Transform:GetWorldPosition()
                    local dx, dz = x - px, z - pz
                    local len = math.sqrt(dx * dx + dz * dz)
                    if len > 0 then
                        dx, dz = dx / len, dz / len
                    end
                    spawn_x = x + dx * 1
                    spawn_z = z + dz * 1
                else
                    
                    local angle = inst.Transform:GetRotation() * DEGREES
                    spawn_x = x - math.cos(angle) * 1
                    spawn_z = z + math.sin(angle) * 1
                end
                local fish = SpawnPrefab(fish_prefab)
                if fish then
                    fish.Transform:SetPosition(spawn_x, 0, spawn_z)
                    inst.sg.statemem.caught_fish = fish
                    
                    inst._fishing_caught_fish = fish
                    fish.entity:Hide()
                    if fish.Physics then
                        fish.Physics:SetActive(false)
                    end
                    if fish.DynamicShadow then
                        fish.DynamicShadow:Enable(false)
                    end
                    
                    local fish_build = fish.build or (fish.AnimState and fish.AnimState:GetBuild()) or fish_prefab
                    inst.AnimState:OverrideSymbol("fish01", fish_build, "fish01")
                    if NPC_TUNING.DEBUG_FISHING then print("[NPC_FISHING] SG: OverrideSymbol fish_build=" .. tostring(fish_build)) end
                end
            end
        end
    end,

    timeline =
    {
        TimeEvent(8 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishcaught")
        end),
        TimeEvent(23 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishland")
        end),
        TimeEvent(24 * FRAMES, function(inst)
            local fish = inst.sg.statemem.caught_fish
            if fish and fish:IsValid() then
                fish.entity:Show()
                if fish.Physics then
                    fish.Physics:SetActive(true)
                end
                if fish.DynamicShadow then
                    fish.DynamicShadow:Enable(true)
                end
            end
        end),
    },

    onexit = function(inst)
        inst.AnimState:ClearOverrideSymbol("fish01")
        
        local fish = inst.sg.statemem.caught_fish
        if fish and fish:IsValid() then
            fish.entity:Show()
            if fish.Physics then
                fish.Physics:SetActive(true)
            end
            if fish.DynamicShadow then
                fish.DynamicShadow:Enable(true)
            end
        end
    end,

    events =
    {
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("npc_fishing_pst")
            end
        end),
    },
})


table.insert(states, State{
    name = "npc_fishing_pst",
    tags = { "fishing" },

    onenter = function(inst)
        inst.AnimState:PlayAnimation("fishing_pst")
        
        inst._fishing_catch_done = true
        if NPC_TUNING.DEBUG_FISHING then print("[NPC_FISHING] SG: npc_fishing_pst, catch_done=true") end
    end,

    events =
    {
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },
})




table.insert(states, State{
    name = "devoured",
    tags = { "devoured", "invisible", "noattack", "nointerrupt", "busy", "nopredict", "silentmorph" },

    onenter = function(inst, data)
        local attacker = data and data.attacker
        
        inst.components.locomotor:Stop()
        inst:ClearBufferedAction()
        
        inst:Hide()
        inst.DynamicShadow:Enable(false)
        ToggleOffPhysics(inst)
        
        if attacker and attacker:IsValid() then
            inst.sg.statemem.attacker = attacker
            inst.Transform:SetRotation(attacker.Transform:GetRotation() + 180)
        end
    end,

    onupdate = function(inst)
        local attacker = inst.sg.statemem.attacker
        if attacker and attacker:IsValid() then
            inst.Transform:SetPosition(attacker.Transform:GetWorldPosition())
            inst.Transform:SetRotation(attacker.Transform:GetRotation() + 180)
        else
            inst.sg:GoToState("idle")
        end
    end,

    events =
    {
        EventHandler("spitout", function(inst, data)
            local attacker = data and data.spitter or inst.sg.statemem.attacker
            if attacker and attacker:IsValid() then
                local rot = (data and data.rot) or (attacker.Transform:GetRotation() + 180)
                inst.Transform:SetRotation(rot)
                local physradius = data and data.radius or (attacker:GetPhysicsRadius(0) + 1)
                if physradius > 0 then
                    local x, y, z = inst.Transform:GetWorldPosition()
                    rot = rot * DEGREES
                    x = x + math.cos(rot) * physradius
                    z = z - math.sin(rot) * physradius
                    inst.Physics:Teleport(x, 0, z)
                end
                inst:PushEventImmediate("knockback", {
                    knocker = attacker,
                    starthigh = data and data.starthigh or nil,
                    radius = physradius,
                    strengthmult = data and data.strengthmult or 1,
                })
            end
            inst.sg:GoToState("idle")
        end),
    },

    onexit = function(inst)
        ToggleOnPhysics(inst)
        inst.DynamicShadow:Enable(true)
        
        if inst.components.health and inst.components.health:IsDead() then
            inst.sg:GoToState("death")
        else
            inst:Show()
            inst.sg:GoToState("idle")
        end
    end,
})






local function SpawnSilverneckPuff(inst)
    if inst and inst:IsValid() and inst.Transform then
        local x, y, z = inst.Transform:GetWorldPosition()
        local fx = SpawnPrefab("small_puff")
        if fx then
            fx.Transform:SetPosition(x, y, z)
        end
    end
end


local function GetSilvUtils()
    return NPCFRIENDS_SILVERNECKLACE_UTILS
        or (_G and _G.NPCFRIENDS_SILVERNECKLACE_UTILS)
        or {}
end
local function GetSilvParams()
    return NPCFRIENDS_SILVERNECKLACE_PARAMS
        or (_G and _G.NPCFRIENDS_SILVERNECKLACE_PARAMS)
        or {
        transform_build  = "werewilba",
        transform_bank   = "wilson",
        override_build   = "werewilba_transform",
        anim_pre         = "transform_pre",
        anim_pst         = "transform_pst",
        anim_reform      = "reform",
        sound_to_were    = "dontstarve/creatures/werepig/transformToWere",
        sound_to_human   = "dontstarve/creatures/werepig/transformToPig",
        colour_cube      = "images/colour_cubes/beaver_vision_cc.tex",
    }
end

table.insert(states, State{
    name = "transform_werewilba",
    tags = { "busy", "nointerrupt", "nopredict" },

    onenter = function(inst, data)
        local P = GetSilvParams()
        local U = GetSilvUtils()
        inst._silvernecklace_transform_pending = true
        if U.DebugLog then U.DebugLog("SGnpcfriend.transform_werewilba.onenter", inst) end
        inst.Physics:Stop()
        inst.components.health:SetInvincible(true)
        inst.AnimState:AddOverrideBuild(P.override_build)
        inst.AnimState:PlayAnimation(P.anim_pre)
        inst.sg.statemem.pst_build = data and data.transform_build or P.transform_build
        inst.sg.statemem.pst_bank  = data and data.transform_bank  or P.transform_bank

        inst.SoundEmitter:PlaySound(P.sound_to_were)

        if inst.Light then
            inst.Light:Enable(true)
            inst.Light:SetColour(1, 0.2, 0.2)
            inst.Light:SetRadius(4)
            inst.Light:SetIntensity(0.6)
            inst.Light:SetFalloff(0.5)
        end

        if TheWorld and TheWorld.components.colourcubemanager then
            TheWorld.components.colourcubemanager:SetOverrideColourCube(P.colour_cube)
        end
    end,

    events = {
        EventHandler("animover", function(inst)
            local P = GetSilvParams()
            local U = GetSilvUtils()
            if inst.sg.statemem.phase2 then
                
                inst.AnimState:ClearOverrideBuild(P.override_build)
                inst._silvernecklace_were = true
                inst._silvernecklace_transform_pending = false
                if U.DebugLog then U.DebugLog("SGnpcfriend.transform_werewilba.complete", inst) end
                if U.ReconcileAfterTransform and U.ReconcileAfterTransform(inst) then
                    return
                end
                inst.components.health:SetInvincible(false)
                inst.sg:GoToState("idle")
            else
                
                if U.DebugLog then U.DebugLog("SGnpcfriend.transform_werewilba.phase2", inst) end
                SpawnSilverneckPuff(inst)
                inst.AnimState:SetBank(inst.sg.statemem.pst_bank)
                inst.AnimState:SetBuild(inst.sg.statemem.pst_build)
                -- 清掉换肤施加的头部/服装符号覆盖，否则有皮肤的 NPC 会保留原皮肤的头，看不到狼猪头
                if inst.ClearNPCClothingSymbols then
                    inst:ClearNPCClothingSymbols()
                end
                inst.AnimState:PlayAnimation(P.anim_pst)
                inst.sg.statemem.phase2 = true
            end
        end),
    },

    onexit = function(inst)
        if not inst.sg.statemem.phase2 then
            inst.components.health:SetInvincible(false)
            inst._silvernecklace_transform_pending = false
        end
    end,
})

table.insert(states, State{
    name = "transform_wilba",
    tags = { "busy", "nointerrupt", "nopredict" },

    onenter = function(inst, data)
        local P = GetSilvParams()
        local U = GetSilvUtils()
        inst._silvernecklace_reform_pending = true
        if U.DebugLog then U.DebugLog("SGnpcfriend.transform_wilba.onenter", inst) end
        inst.Physics:Stop()
        inst.components.health:SetInvincible(true)

        if inst.Light then
            inst.Light:Enable(false)
        end

        
        SpawnSilverneckPuff(inst)
        if U.RestoreAppearance then
            U.RestoreAppearance(inst)
        else
            
            local build    = (data and data.original_build) or inst._silvernecklace_orig_build
            local bank     = (data and data.original_bank)  or "wilson"
            local clothing = (data and data.npc_clothing)   or inst._silvernecklace_orig_npc_clothing
            local uid      = (data and data.npc_clothing_uid) or inst._silvernecklace_orig_npc_clothing_uid
            if bank and bank ~= "" then inst.AnimState:SetBank(bank) end
            if build and build ~= "" then inst.AnimState:SetBuild(build) end
            if clothing and inst.ApplyNPCClothing then
                inst:ApplyNPCClothing(clothing, uid or "")
            end
        end

        inst.AnimState:AddOverrideBuild(P.override_build)
        inst.AnimState:PlayAnimation(P.anim_reform)
        inst.SoundEmitter:PlaySound(P.sound_to_human)

        if inst._werewilba_grunt_task then
            inst._werewilba_grunt_task:Cancel()
            inst._werewilba_grunt_task = nil
        end
    end,

    events = {
        EventHandler("animover", function(inst)
            local P = GetSilvParams()
            local U = GetSilvUtils()
            inst.AnimState:ClearOverrideBuild(P.override_build)
            inst.components.health:SetInvincible(false)
            if U.DebugLog then U.DebugLog("SGnpcfriend.transform_wilba.complete", inst) end

            if TheWorld and TheWorld.components.colourcubemanager then
                TheWorld.components.colourcubemanager:SetOverrideColourCube(nil)
            end

            inst._silvernecklace_were = false
            inst._silvernecklace_transform_pending = false
            inst._silvernecklace_reform_pending = false
            inst._silvernecklace_queue_reform = false
            if U.ReconcileAfterReform and U.ReconcileAfterReform(inst) then
                return
            end
            if U.ClearSavedAppearance then
                U.ClearSavedAppearance(inst)
            end
            inst.sg:GoToState("idle")
        end),
    },

    onexit = function(inst)
        inst.components.health:SetInvincible(false)
        inst._silvernecklace_transform_pending = false
        inst._silvernecklace_reform_pending = false
        if inst.AnimState and inst.AnimState:GetBuild() ~= "werewilba" then
            inst._silvernecklace_queue_reform = false
        end
    end,
})

return StateGraph("npcfriend", states, events, "init", actionhandlers)
