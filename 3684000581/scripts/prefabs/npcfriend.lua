-- scripts/prefabs/npcfriend.lua
-- 自定义 NPC 伙伴 prefab（模块化 orchestrator）
-- 联机安全设计：SetPristine() 后服务端逻辑，使用 SGnpcfriend（标准角色动画，无玩家依赖）
-- 各功能系统已拆分到 scripts/npc/ 目录下的独立模块

local NPCFriendBrain = require("brains/npcfriend_brain")




local NPC_TUNING   = require("npc_tuning")
local NPC_SPEECH   = require("npc_speech")
local npc_utils    = require("npc/npc_utils")
local npc_skin     = require("npc/npc_skin")
local npc_ghost    = require("npc/npc_ghost")
local npc_combat   = require("npc/npc_combat")
local npc_inventory = require("npc/npc_inventory")
local npc_eater    = require("npc/npc_eater")
local npc_affinity = require("npc/npc_affinity")

local STATS        = NPC_TUNING.CHARACTER_STATS
local DEFAULT_STATS = npc_utils.DEFAULT_STATS
local APPEARANCE   = npc_utils.APPEARANCE
local UpdateHoverInfo = npc_utils.UpdateHoverInfo





local CHARACTER_MODULES = {}
for _, name in ipairs({"wilson", "wathgrithr", "wendy", "wolfgang", "wormwood", "warly", "waxwell", "wes", "winona", "woodie", "willow", "wickerbottom", "walter", "webber", "wurt", "wx78", "wortox", "wanda", "wonkey", "wilba"}) do
    local ok, mod = pcall(require, "npc/characters/" .. name)
    if not ok then
        print("[NPCFriends] Warning: Failed to load character module: " .. name)
        mod = {}
    end
    CHARACTER_MODULES[name] = mod
end




local SPEECH_SCENES = {
    "IDLE", "FOLLOW", "COMBAT", "PANIC", "EMOTE", "WORK",
    "NO_TOOL", "NO_PICKAXE", "HEAL_NO_FOOD", "HEAL_EATING",
    "HEAL_DONE", "HEAL_OUT_OF_FOOD", "OVERWHELM", "UNKNOWN_ENEMY",
    "RECRUIT", "IDLE_UNRECRUITED", "RECRUIT_FULL", "DISMISS", "GREET",
    "HIT_BY_PLAYER", "NEED_SPEED", "NEED_FLUTE",
    "STALKER_NEED_ITEMS", "STALKER_SNARE_ESCAPE", "STALKER_TORNADO",
    "DEATH", "REVIVE", "EAT", "RESKIN", "RESKIN_NO_SKINS",
    "BERNIE_MISSING", "BERNIE_FOUND", "BERNIE_DEPLOY",
}
for _, scene in ipairs(SPEECH_SCENES) do
    local data = NPC_SPEECH[scene]
    STRINGS["NPCFRIEND_TALK_" .. scene] = data and data._default or data
end
for _, char in ipairs({"wilson", "wendy", "wathgrithr", "wolfgang", "wormwood", "warly", "waxwell", "wes", "winona", "woodie", "willow", "wickerbottom", "walter", "webber", "wurt", "wx78", "wortox", "wanda", "wonkey", "wilba"}) do
    local uchar = string.upper(char)
    for _, scene in ipairs(SPEECH_SCENES) do
        local data = NPC_SPEECH[scene]
        if data and data[char] then
            STRINGS["NPCFRIEND_TALK_" .. scene .. "_" .. uchar] = data[char]
        end
    end
end

STRINGS.NPCFRIEND_TALK_REFUSE_FOOD        = NPC_SPEECH.REFUSE_FOOD
STRINGS.NPCFRIEND_TALK_ABIGAIL_REVIVE     = NPC_SPEECH.ABIGAIL_REVIVE

STRINGS.NPCFRIEND_TALK_WOLFGANG_STATE_WIMPY  = NPC_SPEECH.WOLFGANG_STATE_CHANGE and NPC_SPEECH.WOLFGANG_STATE_CHANGE.wimpy
STRINGS.NPCFRIEND_TALK_WOLFGANG_STATE_NORMAL = NPC_SPEECH.WOLFGANG_STATE_CHANGE and NPC_SPEECH.WOLFGANG_STATE_CHANGE.normal
STRINGS.NPCFRIEND_TALK_WOLFGANG_STATE_MIGHTY = NPC_SPEECH.WOLFGANG_STATE_CHANGE and NPC_SPEECH.WOLFGANG_STATE_CHANGE.mighty


local assets = {
    Asset("ANIM", "anim/player_emotes.zip"),
    Asset("ANIM", "anim/frozen.zip"),                  
    Asset("ANIM", "anim/ghost_abigail_build.zip"),     
    Asset("ANIM", "anim/ghost_abigail.zip"),           
    Asset("ANIM", "anim/player_actions_uniqueitem.zip"), 
    Asset("ANIM", "anim/player_attack_leap.zip"),      
    Asset("ANIM", "anim/elec_hit_fx.zip"),             -- 跳劈电击火花（electrichitsparks）
    Asset("ANIM", "anim/elec_immune_fx.zip"),          -- 电击免疫目标火花（electrichitsparks_electricimmune）
    Asset("ANIM", "anim/pan_flute.zip"),               
    Asset("ANIM", "anim/walter_storytelling.zip"),     
    
    Asset("ANIM", "anim/wormwood.zip"),                
    Asset("ANIM", "anim/player_wormwood.zip"),         
    Asset("ANIM", "anim/player_idles_wormwood.zip"),   
    Asset("ANIM", "anim/wormwood_pollen_fx.zip"),      
    Asset("ANIM", "anim/wormwood_plant_fx.zip"),       
    Asset("ANIM", "anim/wurt_npc.zip"),                
    Asset("ANIM", "anim/wortox_npc.zip"),              
    
    
    Asset("ANIM", "anim/weremoose_transform.zip"),     
    Asset("ANIM", "anim/weremoose_attacks.zip"),       
    Asset("ANIM", "anim/player_wx78_actions.zip"),     
    Asset("ANIM", "anim/wathgrithr_sing.zip"),         
    Asset("ANIM", "anim/status_oldage.zip"),           
    Asset("ANIM", "anim/wanda_NPC.zip"),               
    Asset("ANIM", "anim/wanda_young_NPC.zip"),         
    Asset("ANIM", "anim/wanda_old_NPC.zip"),           
    Asset("ANIM", "anim/wanda_basics.zip"),            
    Asset("ANIM", "anim/wanda_attack.zip"),            
    Asset("ANIM", "anim/wanda_casting.zip"),           
    Asset("ANIM", "anim/player_idles_wanda.zip"),      
    Asset("ANIM", "anim/player_idles_wonkey.zip"),     
    Asset("ANIM", "anim/wilba_npc.zip"),             
}





local function SetupLocomotor(inst)
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = NPC_TUNING.RUN_SPEED
    inst.components.locomotor.runspeed  = NPC_TUNING.RUN_SPEED
    
    
    
    inst.components.locomotor.pathcaps = {}
    
    
    
    inst.components.locomotor:SetAllowPlatformHopping(true)
end

local function SetupHealth(inst)
    inst:AddComponent("health")
    local init_stats = STATS.wilson or DEFAULT_STATS
    inst.components.health:SetMaxHealth(init_stats.max_health)
    inst.components.health.nofadeout = true  
    inst._is_ghost_mode = false
    
    inst._oceanfishing_active = false
    inst._oceanfishing_catch_count = 0
    inst._oceanfishing_center = nil

    
    inst:ListenForEvent("healthdelta", function(i)
        if not i._hoverinfo_pending then
            i._hoverinfo_pending = true
            i:DoTaskInTime(NPC_TUNING.HOVER_UPDATE_DELAY, function()
                i._hoverinfo_pending = false
                UpdateHoverInfo(i)
            end)
        end
    end)

    
    inst:ListenForEvent("death", function(i)
        -- 死亡掉好感度（所有 NPC 通用）：好感>=1 时至少保留 1 点，好感为 0 时维持 0
        npc_affinity.ApplyDeathPenalty(i)

        if i.npc_character_type ~= "webber" and i.npc_character_type ~= "wurt" and i.components.talker then
            local line = NPC_SPEECH.GetLine(NPC_SPEECH.DEATH, i.npc_character_type)
            if line then i.components.talker:Say(line) end
        end

        local char_mod = CHARACTER_MODULES[i.npc_character_type]
        if char_mod and char_mod.on_death then
            if char_mod.on_death(i) then
                return  
            end
        end

        npc_ghost.EnterGhostMode(i)

        if (i.npc_character_type == "webber" or i.npc_character_type == "wurt") and i.components.talker then
            i:DoTaskInTime(0, function(i2)
                if i2:IsValid() and i2._is_ghost_mode then
                    local line = NPC_SPEECH.GetLine(NPC_SPEECH.DEATH, i2.npc_character_type)
                    if line then i2.components.talker:Say(line) end
                end
            end)
        end
    end)
end





local function SetupFreezable(inst)
    MakeSmallFreezableCharacter(inst)
    inst.components.freezable:SetResistance(2)
    inst.components.freezable:SetDefaultWearOffTime(5)
    
    inst.components.freezable.redirectfn = function(i, coldness, freezetime, nofreeze)
        return i._is_ghost_mode == true
    end
    
    inst.components.freezable.onfreezefn = function(i)
        if i._unfreeze_task ~= nil then i._unfreeze_task:Cancel() end
        i._unfreeze_task = i:DoTaskInTime(2, function()
            if i.components.freezable ~= nil and i.components.freezable:IsFrozen() then
                i.components.freezable:Unfreeze()
            end
            i._unfreeze_task = nil
        end)
    end

    
    local _PushTempGSM = inst.components.locomotor.PushTempGroundSpeedMultiplier
    inst.components.locomotor.PushTempGroundSpeedMultiplier = function(self, mult, tile)
        if inst._is_ghost_mode then
            return _PushTempGSM(self, 1, tile)
        end
        if mult ~= nil and mult < 1 then
            mult = 1 - (1 - mult) * 2 / 3
        end
        return _PushTempGSM(self, mult, tile)
    end
end






local function SetupBurnable(inst)
    local burnable, propagator = MakeSmallBurnableCharacter(inst)
    burnable:SetBurnTime(6)
    propagator.damages = false
    propagator.propagaterange = 0
    propagator.heatoutput = 0
end

local function SetupFollower(inst)
    inst:AddComponent("follower")
    inst.components.follower.neverexpire = true
    inst.components.follower:KeepLeaderOnAttacked()
    inst.components.follower.keepdeadleader = true            
    inst.components.follower.keepleaderduringminigame = true  
end

local function SetupKnownLocations(inst)
    inst:AddComponent("knownlocations")
end






local function SetupEmbarker(inst)
    inst:AddComponent("embarker")
    
end






local function SetupPlatformFollower(inst)
    local function SyncPlatformFollower(i)
        if not (i and i:IsValid()) then return end
        local x, y, z = i.Transform:GetWorldPosition()
        local platform = TheWorld and TheWorld.Map and TheWorld.Map:GetPlatformAtPoint(x, y, z) or nil
        local current = i.platform

        if current ~= platform then
            if current ~= nil then
                current:RemovePlatformFollower(i)
            end
            if platform ~= nil then
                platform:AddPlatformFollower(i)
            end
        end
    end

    
    inst._platform_follower_task = inst:DoPeriodicTask(0, SyncPlatformFollower)
    inst:DoTaskInTime(0, SyncPlatformFollower)
    inst:ListenForEvent("onremove", function(i)
        if i._platform_follower_task ~= nil then
            i._platform_follower_task:Cancel()
            i._platform_follower_task = nil
        end
        if i.platform ~= nil then
            i.platform:RemovePlatformFollower(i)
        end
    end)
end




local function SetAppearance(inst, prefab_name)
    local app = APPEARANCE[prefab_name] or APPEARANCE.npcfriend
    inst.AnimState:SetBank(app.bank)
    if prefab_name == "wurt" and inst.AnimState and inst.AnimState.GetBuild then
        
        local candidates = { "wurt_npc_free", app.build, "wurt", "wurt_survivor" }
        local picked = nil
        for _, b in ipairs(candidates) do
            if b and b ~= "" then
                inst.AnimState:SetBuild(b)
                local actual = inst.AnimState:GetBuild()
                if actual == b then
                    picked = b
                    break
                end
            end
        end
        if not picked then
            inst.AnimState:SetBuild(app.build)
        end
    elseif prefab_name == "wortox" and inst.AnimState and inst.AnimState.GetBuild then
        
        local candidates = { "wortox_npc_face", app.build, "wortox" }
        local picked = nil
        for _, b in ipairs(candidates) do
            if b and b ~= "" then
                inst.AnimState:SetBuild(b)
                local actual = inst.AnimState:GetBuild()
                if actual == b then
                    picked = b
                    break
                end
            end
        end
        if not picked then
            inst.AnimState:SetBuild(app.build)
        end
    elseif prefab_name == "wanda" and inst.AnimState and inst.AnimState.GetBuild then
        
        local candidates = {
            NPC_TUNING.WANDA_BUILD_NORMAL,
            "wanda_NPC",
            app.build,
            "wanda",
        }
        local picked = nil
        for _, b in ipairs(candidates) do
            if b and b ~= "" then
                inst.AnimState:SetBuild(b)
                local actual = inst.AnimState:GetBuild()
                if actual == b then
                    picked = b
                    break
                end
            end
        end
        if not picked then
            inst.AnimState:SetBuild(app.build)
        end
    else
        inst.AnimState:SetBuild(app.build)
    end
    inst.AnimState:PlayAnimation("idle_loop", true)

    if TheWorld.ismastersim then
        inst.npc_character_type = prefab_name
        if inst.npc_character_net then
            inst.npc_character_net:set(prefab_name or "")
        end
        inst._npc_affinity = inst._npc_affinity or npc_affinity.GetInitialAffinity(prefab_name)
        local stats = STATS[prefab_name] or STATS.wilson or DEFAULT_STATS
        if not stats then stats = { max_health = 150, damage = 10, damage_mult = 1, attack_range = 2 } end
        local bonus_max_health = inst._npc_bonus_max_health or 0
        local bonus_damage = inst._npc_bonus_damage or 0
        if inst.components.health then
            inst.components.health:SetMaxHealth((stats.max_health or 0) + bonus_max_health)
            inst.components.health:SetPercent(1)
        end
        if inst.components.combat then
            inst.npc_base_damage = (stats.damage or 0) + bonus_damage
            inst.npc_damage_mult = stats.damage_mult or 1  
            
            
            inst.components.combat:SetDefaultDamage(inst.npc_base_damage * inst.npc_damage_mult)
            inst.components.combat:SetAttackPeriod(0)
            inst.components.combat:SetRange(stats.attack_range)
            inst.components.combat.damagemultiplier = stats.damage_mult or 1  
            
            
            
            inst.components.combat.customdamagemultfn = function(inst, target, weapon, multiplier, mount)
                if inst._is_weremoose then
                    local NPC_TUN = require("npc_tuning")
                    local moose_dmg = NPC_TUN.WEREMOOSE_DAMAGE or 59.5
                    if weapon ~= nil and weapon.components.weapon then
                        
                        local weapon_dmg = weapon.components.weapon:GetDamage(inst, target) or 0
                        if weapon_dmg > 0 then
                            return moose_dmg / weapon_dmg
                        end
                    end
                    
                    local dm = inst.components.combat.damagemultiplier or 1
                    return (dm ~= 0) and (1 / dm) or 1
                end
                
                local mult = inst.npc_damage_mult or 1
                if weapon ~= nil and weapon.components.weapon then
                    
                    
                    local base = inst.npc_base_damage or 0
                    local weapon_dmg = weapon.components.weapon:GetDamage(inst, target) or 0
                    if weapon_dmg > 0 and base > 0 then
                        return (base + weapon_dmg) / weapon_dmg
                    end
                    return 1
                else
                    
                    return (mult ~= 0) and (1 / mult) or 1
                end
            end
        end
        
        if inst.components.health then
            inst.components.health:SetAbsorptionAmount(stats.absorption or 0)
        end
        if inst._lifesteal_fn then
            inst:RemoveEventCallback("onattackother", inst._lifesteal_fn)
            inst._lifesteal_fn = nil
        end
        if stats.lifesteal and stats.lifesteal > 0 then
            local heal_amount = stats.lifesteal
            inst._lifesteal_fn = function(i)
                if i.components.health and not i.components.health:IsDead()
                   and not i._is_ghost_mode then
                    i.components.health:DoDelta(heal_amount, false, "lifesteal")
                end
            end
            inst:ListenForEvent("onattackother", inst._lifesteal_fn)
        end

        if inst.components.inventory then
            inst.components.inventory.maxslots = stats.inventory_slots or NPC_TUNING.INVENTORY_SLOTS
        end

        
        inst._pick_speed = stats.pick_speed or NPC_TUNING.PICK_SPEED

        local char_mod = CHARACTER_MODULES[prefab_name]
        if char_mod and char_mod.on_apply then
            char_mod.on_apply(inst, stats)
        end

        UpdateHoverInfo(inst)

        
        if inst._npc_clothing then
            npc_skin.ApplyNPCClothing(inst, inst._npc_clothing, inst._npc_clothing_userid or "")
        end
    end
end




local function StartNPCChat(npcA, npcB)
    local now = GetTime()
    npcA._npc_chat_cd = now
    npcB._npc_chat_cd = now

    local a = npcA.npc_character_type or "wilson"
    local b = npcB.npc_character_type or "wilson"
    if a > b then a, b = b, a; npcA, npcB = npcB, npcA end

    
    
    local pool_ab = NPC_SPEECH.NPC_CHAT[a .. "_" .. b]
    local pool_ba = (a ~= b) and NPC_SPEECH.NPC_CHAT[b .. "_" .. a] or nil
    local n_ab = pool_ab and #pool_ab or 0
    local n_ba = pool_ba and #pool_ba or 0
    local total = n_ab + n_ba

    local dialog, swapped
    if total > 0 then
        local idx = math.random(total)
        if idx <= n_ab then
            dialog = pool_ab[idx]
            swapped = false
        else
            dialog = pool_ba[idx - n_ab]
            swapped = true  
        end
    else
        local fallback = NPC_SPEECH.NPC_CHAT._default
        if not fallback or #fallback == 0 then return end
        dialog = fallback[math.random(#fallback)]
        swapped = false
    end
    
    
    
    if swapped then npcA, npcB = npcB, npcA end

    npcA._npc_chat_lock = now
    npcB._npc_chat_lock = now

    if npcA.components.talker then npcA.components.talker:ShutUp() end
    if npcB.components.talker then npcB.components.talker:ShutUp() end

    npcA:ForceFacePoint(npcB.Transform:GetWorldPosition())
    if npcA.components.talker then
        npcA.components.talker:Say(dialog[1])
    end

    npcB:DoTaskInTime(NPC_TUNING.NPC_CHAT_REPLY_DELAY[1] + math.random() * NPC_TUNING.NPC_CHAT_REPLY_DELAY[2], function()
        if npcB:IsValid() and npcA:IsValid()
           and not (npcB.components.health and npcB.components.health:IsDead())
           and not (npcB.components.combat and npcB.components.combat.target) then
            local now2 = GetTime()
            npcA._npc_chat_lock = now2
            npcB._npc_chat_lock = now2
            npcB:ForceFacePoint(npcA.Transform:GetWorldPosition())
            if npcB.components.talker then
                npcB.components.talker:Say(dialog[2])
            end
        end
    end)
end





local function fn()
    local inst = CreateEntity()

    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    
    
    inst.owner_userid  = net_string(inst.GUID, "npcfriend.owner_userid", "npcfriend.owner_useriddirty")
    
    inst.npc_hoverinfo = net_string(inst.GUID, "npcfriend.hoverinfo")
    
    inst.npc_character_net = net_string(inst.GUID, "npcfriend.character_type")
    
    inst.npc_slot_index_net = net_ushortint(inst.GUID, "npcfriend.slot_index")
    
    inst.npc_ui_blocked_net = net_bool(inst.GUID, "npcfriend.ui_blocked")

    inst.npc_wormwood_pollen = net_tinybyte(inst.GUID, "npcfriend.wormwood_pollen", "npcwormwoodpollendirty")
    
    inst.npc_character_type = nil

    
    inst:AddTag("npcfriend")
    inst:AddTag("companion")
    inst:AddTag("character")     
    inst:AddTag("crazy")         
    inst:AddTag("notarget")      
    inst:AddTag("handfed")       
    inst:AddTag("fedbyall")      
    inst:AddTag("OMNI_eater")    

    inst.displaynamefn = function(inst)
        local char_type = inst.npc_character_net and inst.npc_character_net:value() or ""
        if char_type ~= "" then
            local key = string.upper(char_type)
            if STRINGS.NAMES[key] then return STRINGS.NAMES[key] end
        end
        return "NPC Friend"
    end

    
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("wilson")
    inst.AnimState:AddOverrideBuild("player_actions_uniqueitem")  
    inst.AnimState:PlayAnimation("idle_loop", true)

    
    inst.AnimState:Hide("ARM_carry")
    inst.AnimState:Hide("HAT")
    inst.AnimState:Hide("HAIR_HAT")
    inst.AnimState:Show("HAIR_NOHAT")
    inst.AnimState:Show("HAIR")
    inst.AnimState:Show("HEAD")
    inst.AnimState:Hide("HEAD_HAT")
    inst.AnimState:Hide("HEAD_HAT_NOHELM")
    inst.AnimState:Hide("HEAD_HAT_HELM")

    inst.DynamicShadow:SetSize(1.5, 0.6)

    inst:AddComponent("talker")
    inst.components.talker.fontsize = NPC_TUNING.TALKER_FONT_SIZE
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.lineduration = NPC_TUNING.TALKER_LINE_DURATION
    inst.components.talker.offset = Vector3(0, -400, 0)
    inst.components.talker:MakeChatter()

    
    MakeCharacterPhysics(inst, NPC_TUNING.PHYSICS_MASS, NPC_TUNING.PHYSICS_RAD)

    
    
    inst.entity:SetCanSleep(false)

    
    inst.entity:SetPristine()
    if not TheNet:IsDedicated() then
        require("npc/npc_wormwood_bloom_fx").InitClient(inst)
    end
    if not TheWorld.ismastersim then
        return inst  
    end

    
    SetupLocomotor(inst)
    SetupHealth(inst)
    SetupFreezable(inst)       
    SetupBurnable(inst)        
    npc_combat.SetupCombat(inst)
    SetupFollower(inst)
    SetupKnownLocations(inst)
    SetupEmbarker(inst)
    SetupPlatformFollower(inst)
    npc_inventory.SetupInventorySystem(inst)
    npc_eater.SetupEater(inst)

    
    local npc_platform_debug = require("npc/npc_platform_debug")
    npc_platform_debug.Install(inst)

    -- NPC "突然消失" 诊断（由 NPC_TUNING.DEBUG_VISIBILITY 控制；关闭时几乎零开销）
    local npc_visibility_debug = require("npc/npc_visibility_debug")
    npc_visibility_debug.Install(inst)

    inst:ListenForEvent("startfollowing", function(i, data)
        local leader = data and data.leader or (i.components.follower and i.components.follower.leader)
        if leader then
            npc_platform_debug.InstallOnLeader(leader)
        end
    end)

    
    local function SyncUIBlocked(i)
        if not (i and i:IsValid() and i.npc_ui_blocked_net) then return end
        local blocked = i:HasTag("npc_hostile") or i:HasTag("npc_no_ui")
        if i.npc_ui_blocked_net:value() ~= blocked then
            i.npc_ui_blocked_net:set(blocked)
        end
    end
    inst:DoTaskInTime(0, function(i) SyncUIBlocked(i) end)
    inst._npc_ui_blocked_sync_task = inst:DoPeriodicTask(0.25, function(i) SyncUIBlocked(i) end)
    inst:ListenForEvent("onremove", function(i)
        if i._npc_ui_blocked_sync_task then
            i._npc_ui_blocked_sync_task:Cancel()
            i._npc_ui_blocked_sync_task = nil
        end
    end)

    inst._update_hoverinfo = function() UpdateHoverInfo(inst) end

    
    npc_combat.SetupCombatEvents(inst)

    
    
    
    
    do
        local _orig_Chatter = inst.components.talker.Chatter
        inst.components.talker.Chatter = function(self, ...)
            if inst._npc_chat_lock and GetTime() - inst._npc_chat_lock < NPC_TUNING.NPC_CHAT_LOCK_DURATION then
                return  
            end
            return _orig_Chatter(self, ...)
        end
    end

    
    inst:ListenForEvent("equip", function(i, data)
        if data and data.eslot == EQUIPSLOTS.HANDS and i.SoundEmitter then
            i.SoundEmitter:PlaySound("dontstarve/wilson/equip_item")
        end
    end)

    
    inst:SetBrain(NPCFriendBrain)

    
    
    inst:SetStateGraph("SGnpcfriend")

    inst.SetAppearance = function(i, prefab_name) SetAppearance(i, prefab_name) end

    inst.RandomizeNPCClothing = npc_skin.RandomizeNPCClothing
    inst.ApplyNPCClothing = npc_skin.ApplyNPCClothing
    inst.ClearNPCClothingSymbols = npc_skin.ClearNPCClothingSymbols
    
    
    local IDLE_SPEED_PRIORITY = { orangestaff = 1, cane = 2 }
    inst:DoPeriodicTask(8, function()
        
        if inst.components.combat and inst.components.combat.target then return end
        if inst._is_ghost_mode then return end
        if inst._is_weremoose then return end  
        
        if inst.sg and inst.sg:HasStateTag("working") then return end
        
        local ba = inst:GetBufferedAction()
        if ba and ba.action
           and (ba.action == ACTIONS.CHOP or ba.action == ACTIONS.MINE) then
            return
        end
        if inst.components.follower and not inst.components.follower.leader then return end
        local inv = inst.components.inventory
        if not inv then return end
        local current = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
        local need_light = TheWorld.state.isnight or TheWorld:HasTag("cave")
        if need_light and current ~= nil then
            if current:HasTag("lighter") or current:HasTag("light")
               or current.fire ~= nil or current.fires ~= nil then
                return
            end
        end
        if current ~= nil and current.components.equippable
           and current.components.equippable:GetWalkSpeedMult() > 1 then
            return
        end
        local best, best_pri, best_wsm = nil, 999, 0
        for i = 1, inv.maxslots do
            local item = inv:GetItemInSlot(i)
            if item ~= nil and item.components.equippable ~= nil
               and item.components.equippable.equipslot == EQUIPSLOTS.HANDS then
                local wsm = item.components.equippable:GetWalkSpeedMult()
                if wsm > 1 then
                    local pri = IDLE_SPEED_PRIORITY[item.prefab] or 99
                    if pri < best_pri or (pri == best_pri and wsm > best_wsm) then
                        best, best_pri, best_wsm = item, pri, wsm
                    end
                end
            end
        end
        if best then
            inv:Equip(best)
        end
    end)
    
    
    
    
    local function NoHoles(pt)
        return not TheWorld.Map:IsPointNearHole(pt)
    end
    
    local function TryTeleportToLeader(npc)
        if not npc:IsValid() then return end
        local follower = npc.components.follower
        if not follower or not follower.leader then return end
        local leader = follower.leader
        if not leader:IsValid() then return end
        
        if leader:IsAsleep() then return end
        if npc._is_ghost_mode then return end
        
        
        local distsq = npc:GetDistanceSqToInst(leader)
        if distsq <= 2500 then return end
        
        if npc.components.combat then
            npc.components.combat:SetTarget(nil)
        end
        
        local npc_pos = npc:GetPosition()
        local leader_pos = leader:GetPosition()
        local angle = leader:GetAngleToPoint(npc_pos) * DEGREES
        
        local offset = FindWalkableOffset(leader_pos, angle, 30, 10, false, true, NoHoles)
        if offset then
            leader_pos.x = leader_pos.x + offset.x
            leader_pos.z = leader_pos.z + offset.z
        end
        leader_pos.y = 0
        
        if TheWorld.Map:IsOceanAtPoint(leader_pos.x, leader_pos.y, leader_pos.z, true) then
            return
        end
        
        if npc.Physics then
            npc.Physics:Teleport(leader_pos:Get())
        else
            npc.Transform:SetPosition(leader_pos:Get())
        end
    end
    
    inst:DoPeriodicTask(3, function()
        TryTeleportToLeader(inst)
    end)
    
    
    
    inst:DoPeriodicTask(NPC_TUNING.NPC_CHAT_CHECK_INTERVAL, function()
        if inst._is_ghost_mode then return end
        if inst.components.combat and inst.components.combat.target then return end
        if inst._npc_chat_cd and GetTime() - inst._npc_chat_cd < NPC_TUNING.NPC_CHAT_COOLDOWN then return end
        if inst.components.follower and not inst.components.follower.leader then return end

        local x, y, z = inst.Transform:GetWorldPosition()
        local nearby = _G.TheSim:FindEntities(x, y, z, NPC_TUNING.NPC_CHAT_SEARCH_RANGE, {"npcfriend"})
        local candidates = {}
        for _, other in ipairs(nearby) do
            if other ~= inst and other:IsValid()
               and not other._is_ghost_mode
               and not (other.components.combat and other.components.combat:HasTarget())
               and not (other._npc_chat_cd and GetTime() - other._npc_chat_cd < NPC_TUNING.NPC_CHAT_COOLDOWN) then
                candidates[#candidates + 1] = other
            end
        end
        if #candidates > 0 then
            StartNPCChat(inst, candidates[math.random(#candidates)])
        end
    end)
    
    inst:DoTaskInTime(0, function()
        if inst:IsValid() then
            inst.components.knownlocations:RememberLocation("home", inst:GetPosition())
        end
    end)

    
    
    
    
    
    inst:ListenForEvent("onremove", function(inst)
        local inv = inst.components.inventory
        if inv then
            for _, item in pairs(inv.equipslots) do
                if item and item.components.inventoryitem then
                    item.components.inventoryitem.owner = nil
                end
            end
            for _, item in pairs(inv.itemslots) do
                if item and item.components.inventoryitem then
                    item.components.inventoryitem.owner = nil
                end
            end
        end
    end)

    
    inst.OnSave = function(inst, data)
        data.npc_character_type = inst.npc_character_type
        data.npc_slot_index = inst.npc_slot_index
        data.owner_userid = inst._owner_userid
        data.is_ghost_mode = inst._is_ghost_mode or false
        data.npc_bonus_max_health = inst._npc_bonus_max_health or 0
        data.npc_bonus_damage = inst._npc_bonus_damage or 0
        data.affinity = inst._npc_affinity or 0
        if inst.npc_character_type == "walter" then
            data.walter_auto_story_enabled = inst._walter_auto_story_enabled == true
        end
        if inst.npc_character_type == "wilson" then
            data.wilson_transmute_unlocked = inst._wilson_transmute_unlocked == true
        end
        if inst._collect_organize_disabled == true then
            data.collect_organize_disabled = true
        end
        local char_mod = CHARACTER_MODULES[inst.npc_character_type]
        if char_mod and char_mod.on_save then
            char_mod.on_save(inst, data)
        end
        if inst._npc_clothing then
            data.npc_clothing = inst._npc_clothing
            data.npc_clothing_userid = inst._npc_clothing_userid
        end
        
        if inst._fishing_active then
            data.fishing_active = true
            data.fishing_catch_count = inst._fishing_catch_count or 0
            if inst._fishing_center then
                data.fishing_center = { x = inst._fishing_center.x, z = inst._fishing_center.z }
            end
            print("[NPCFriends] OnSave: 保存钓鱼状态 active=true, catch_count="
                .. tostring(data.fishing_catch_count)
                .. ", center=" .. (data.fishing_center and string.format("(%.1f,%.1f)", data.fishing_center.x, data.fishing_center.z) or "nil"))
        end
        
        if inst._oceanfishing_active then
            data.oceanfishing_active = true
            data.oceanfishing_catch_count = inst._oceanfishing_catch_count or 0
            if inst._oceanfishing_center then
                data.oceanfishing_center = {
                    x = inst._oceanfishing_center.x,
                    z = inst._oceanfishing_center.z
                }
            end
            print("[NPCFriends] OnSave: 保存海钓状态 active=true, catch_count="
                .. tostring(data.oceanfishing_catch_count)
                .. ", center=" .. (data.oceanfishing_center and string.format("(%.1f,%.1f)", data.oceanfishing_center.x, data.oceanfishing_center.z) or "nil"))
        end
        
        if inst._work_paused then
            data.work_paused = true
        end

        -- 太累坐地上的状态（好感度耗尽自动停工后）：存档保留，读档后继续坐着
        if inst._npc_tired then
            data.npc_tired = true
        end
    end

    inst.OnLoad = function(inst, data)
        if data ~= nil then
            inst._npc_bonus_max_health = data.npc_bonus_max_health or 0
            inst._npc_bonus_damage = data.npc_bonus_damage or 0
            inst._npc_affinity = data.affinity or 0
            if data.npc_character_type ~= nil then
                SetAppearance(inst, data.npc_character_type)
            end
            if data.npc_slot_index ~= nil then
                inst.npc_slot_index = data.npc_slot_index
                if inst.npc_slot_index_net then
                    inst.npc_slot_index_net:set(data.npc_slot_index)
                end
            end
            if data.owner_userid then
                inst._owner_userid = data.owner_userid
                if inst.owner_userid then
                    inst.owner_userid:set(data.owner_userid)
                end
            end
            if inst.npc_character_type == "walter" then
                inst._walter_auto_story_enabled = data.walter_auto_story_enabled == true
            end
            if inst.npc_character_type == "wilson" then
                inst._wilson_transmute_unlocked = data.wilson_transmute_unlocked == true
            end
            inst._collect_organize_disabled = data.collect_organize_disabled == true
            if data.is_ghost_mode then
                inst:DoTaskInTime(0, function()
                    if not inst:IsValid() then return end
                    npc_ghost.EnterGhostMode(inst)
                    
                    
                    if inst.sg then
                        inst.sg:GoToState("ghost_idle")
                    end
                end)
            end
            local char_mod = CHARACTER_MODULES[inst.npc_character_type]
            if char_mod and char_mod.on_load then
                char_mod.on_load(inst, data)
            end
            inst._work_paused = data.work_paused == true
            inst._npc_tired = data.npc_tired == true
            
            if data.fishing_active then
                inst._fishing_active = true
                inst._fishing_catch_count = data.fishing_catch_count or 0
                if data.fishing_center then
                    inst._fishing_center = { x = data.fishing_center.x, z = data.fishing_center.z }
                end
                
                inst._work_paused = false
                print("[NPCFriends] OnLoad: 恢复钓鱼状态 active=true, catch_count="
                    .. tostring(inst._fishing_catch_count)
                    .. ", center=" .. (inst._fishing_center and string.format("(%.1f,%.1f)", inst._fishing_center.x, inst._fishing_center.z) or "nil"))
            end
            
            if data.oceanfishing_active then
                inst._oceanfishing_active = true
                inst._oceanfishing_catch_count = data.oceanfishing_catch_count or 0
                if data.oceanfishing_center then
                    inst._oceanfishing_center = Vector3(
                        data.oceanfishing_center.x, 0,
                        data.oceanfishing_center.z
                    )
                end
                inst._work_paused = false
                print("[NPCFriends] OnLoad: 恢复海钓状态 active=true, catch_count="
                    .. tostring(inst._oceanfishing_catch_count)
                    .. ", center=" .. (inst._oceanfishing_center and string.format("(%.1f,%.1f)", inst._oceanfishing_center.x, inst._oceanfishing_center.z) or "nil"))
            end
        end
        
        
        
        local inv = inst.components.inventory
        if inv and inst.components.combat then
            local weapon = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
            if weapon and weapon.components.weapon then
                local base = inst.npc_base_damage or 0
                local mult = inst.npc_damage_mult or 1
                
                inst.components.combat:SetDefaultDamage((base + (weapon.components.weapon.damage or 0)) * mult)
            end
        end
        UpdateHoverInfo(inst)

        
        
        if data and data.npc_clothing then
            inst:DoTaskInTime(0.1, function()
                if inst:IsValid() and not inst._is_ghost_mode then
                    npc_skin.ApplyNPCClothing(inst, data.npc_clothing, data.npc_clothing_userid or "")
                end
            end)
        end

        
        
        inst:DoTaskInTime(0.3, function(i)
            if i:IsValid()
                and not i._is_ghost_mode
                and NPCFRIENDS_SILVERNECKLACE_UTILS
                and NPCFRIENDS_SILVERNECKLACE_UTILS.ApplyFinalFormAfterLoad then
                NPCFRIENDS_SILVERNECKLACE_UTILS.ApplyFinalFormAfterLoad(i)
            end
        end)

        inst:DoTaskInTime(0.5, function(i)
            if not i:IsValid() then return end
            local ok, NpcCommands = pcall(require, "npc_commands")
            if ok and NpcCommands then
                if NpcCommands.ResumeWorkDrainOnLoad then
                    NpcCommands.ResumeWorkDrainOnLoad(i)
                end
                if NpcCommands.ResumeTiredSitOnLoad then
                    NpcCommands.ResumeTiredSitOnLoad(i)
                end
            end
        end)
    end

    return inst
end




return Prefab("npcfriend", fn, assets)
