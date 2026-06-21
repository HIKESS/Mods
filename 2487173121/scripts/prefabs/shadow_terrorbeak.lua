local KodiUtils = require("kodi_utils")
local assets = {
}
local prefabs = {
    "shadow_despawn",
    "nightmarefuel",
    "shadow_puff",
    "shadow_glob_fx",
}
local STATS = {
    fox = {
        health = 400,
        damage = 65,
        attack_period = 1.4,
        attack_range = 3,
        color = {0.6, 0.3, 0.9, 1},
    },
    demon = {
        health = 600,
        damage = 85,
        attack_period = 1.2,
        attack_range = 3.5,
        color = {0.3, 0.1, 0.5, 1},
    },
}
local SANITY_AURA_RADIUS = 6
local SANITY_AURA_DRAIN = -TUNING.SANITYAURA_SMALL
local FOLLOW_DISTANCE = 8
local MAX_FOLLOW_DISTANCE = 20
local RETARGET_CANT_TAGS = { "player", "companion", "shadow_terrorbeak", "shadowminion", "INLIMBO", "playerghost", "wall", "structure" }
local function ShouldNotAttack(inst, target)
    if target == nil or not target:IsValid() then
        return true
    end
    if target:HasTag("player") and not TheNet:GetPVPEnabled() then
        return true
    end
    if target:HasTag("shadow_terrorbeak") or target:HasTag("shadowminion") then
        return true
    end
    if target:HasTag("companion") then
        return true
    end
    if target == inst._owner then
        return true
    end
    return false
end
local HOSTILE_MUST_TAGS = { "_combat", "_health" }
local HOSTILE_CANT_TAGS = { "player", "companion", "shadow_terrorbeak", "shadowminion", "INLIMBO", "playerghost", "wall", "structure", "prey", "bird", "butterfly", "critter", "rabbit", "mole", "frog" }
local HOSTILE_MEMORY_TIME = 10
local function MarkPrefabHostile(owner, prefab)
    if not owner._hostile_prefabs then
        owner._hostile_prefabs = {}
    end
    owner._hostile_prefabs[prefab] = GetTime() + HOSTILE_MEMORY_TIME
    KodiUtils.DebugLog("TARGETING", "Marked prefab as hostile: %s", tostring(prefab))
end
local function IsPrefabHostile(owner, prefab)
    if not owner._hostile_prefabs then return false end
    local expire_time = owner._hostile_prefabs[prefab]
    if expire_time and GetTime() < expire_time then
        return true
    end
    return false
end
local function IsActuallyHostile(ent, owner)
    if not ent.components.combat then
        return false
    end
    local target = ent.components.combat.target
    if target and target:IsValid() and target:HasTag("player") then
        KodiUtils.DebugLog("TARGETING", "%s - HOSTILE (targeting player)", tostring(ent.prefab))
        return true
    end
    if owner and owner:IsValid() and IsPrefabHostile(owner, ent.prefab) then
        KodiUtils.DebugLog("TARGETING", "%s - HOSTILE (prefab memory)", tostring(ent.prefab))
        return true
    end
    return false
end
local function IsAlwaysHostileCreature(ent)
    if ent:HasTag("hostile") or ent:HasTag("monster") then
        return true
    end
    if ent:HasTag("hound") or ent:HasTag("bat") or ent:HasTag("spider") or
       ent:HasTag("tentacle") or ent:HasTag("leif") or ent:HasTag("deerclops") or
       ent:HasTag("bearger") or ent:HasTag("moose") or ent:HasTag("dragonfly") or
       ent:HasTag("worm") or ent:HasTag("mosquito") or ent:HasTag("bee") or
       ent:HasTag("killerbee") or ent:HasTag("walrus") or ent:HasTag("ghost") or
       ent:HasTag("shadowcreature") or ent:HasTag("nightmare") or ent:HasTag("chess") or
       ent:HasTag("clockwork") or ent:HasTag("brightmare") or ent:HasTag("lunar_aligned") then
        return true
    end
    return false
end
local function RetargetFn(inst)
    local owner = inst._owner
    if not owner or not owner:IsValid() then
        return inst._revenge_target
    end
    local x, y, z = owner.Transform:GetWorldPosition()
    if owner.components.combat and owner.components.combat.target then
        local target = owner.components.combat.target
        if target and target:IsValid() and target ~= owner then
            local blocked = false
            if target:HasTag("player") and not TheNet:GetPVPEnabled() then
                blocked = true
            end
            if target:HasTag("shadow_terrorbeak") or target:HasTag("shadowminion") then
                blocked = true
            end
            if not blocked and inst.components.combat:CanTarget(target) then
                return target
            end
        end
    end
    if KodiUtils.IsDebugEnabled("TARGETING") then
        KodiUtils.DebugLog("TARGETING", "RetargetFn - owner: %s, hostile_prefabs: %s", tostring(owner), tostring(owner._hostile_prefabs ~= nil))
        if owner._hostile_prefabs then
            for k, v in pairs(owner._hostile_prefabs) do
                KodiUtils.DebugLog("TARGETING", "  hostile prefab: %s expires: %.1f", k, v - GetTime())
            end
        end
    end
    local threat = FindEntity(owner, 15, function(ent)
        if ShouldNotAttack(inst, ent) then
            return false
        end
        if not inst.components.combat:CanTarget(ent) then
            return false
        end
        if ent.components.combat and ent.components.combat.target == owner then
            KodiUtils.DebugLog("TARGETING", "Found direct threat: %s", tostring(ent.prefab))
            MarkPrefabHostile(owner, ent.prefab)
            return true
        end
        local is_group_hostile = IsPrefabHostile(owner, ent.prefab)
        KodiUtils.DebugLog("TARGETING", "Checking %s - IsPrefabHostile: %s", tostring(ent.prefab), tostring(is_group_hostile))
        if is_group_hostile then
            return true
        end
        return false
    end, HOSTILE_MUST_TAGS, RETARGET_CANT_TAGS)
    KodiUtils.DebugLog("TARGETING", "RetargetFn result: %s", tostring(threat and threat.prefab or "nil"))
    return threat
end
local function KeepTargetFn(inst, target)
    if target == nil or not target:IsValid() then
        return false
    end
    if target:HasTag("player") and not TheNet:GetPVPEnabled() then
        return false
    end
    if target:HasTag("shadow_terrorbeak") or target:HasTag("shadowminion") then
        return false
    end
    if not inst.components.combat:CanTarget(target) then
        return false
    end
    local owner = inst._owner
    if owner and owner:IsValid() and owner.components.combat then
        if owner.components.combat.target == target then
            return true
        end
    end
    if inst._revenge_target == target then
        return true
    end
    if owner and owner:IsValid() then
        return inst:IsNear(owner, 30)
    end
    return true
end
local function OnAttacked(inst, data)
    local attacker = data and data.attacker
    if attacker and attacker:IsValid() and not ShouldNotAttack(inst, attacker) then
        inst._revenge_target = attacker
        inst.components.combat:SetTarget(attacker)
        if inst._revenge_task then
            inst._revenge_task:Cancel()
        end
        inst._revenge_task = inst:DoTaskInTime(10, function()
            inst._revenge_target = nil
            inst._revenge_task = nil
        end)
    end
end
local function OnOwnerAttacked(inst, owner, data)
    local attacker = data and data.attacker
    KodiUtils.DebugLog("TARGETING", "OnOwnerAttacked called! attacker: %s, owner: %s", tostring(attacker and attacker.prefab or "nil"), tostring(owner))
    if attacker and attacker:IsValid() and attacker.prefab then
        MarkPrefabHostile(owner, attacker.prefab)
        KodiUtils.DebugLog("TARGETING", "After MarkPrefabHostile, owner._hostile_prefabs: %s", tostring(owner._hostile_prefabs ~= nil))
    end
    if not ShouldNotAttack(inst, attacker) and inst.components.combat:CanTarget(attacker) then
        inst.components.combat:SetTarget(attacker)
    end
end
local function OnOwnerAttackOther(inst, owner, data)
    local target = data and data.target
    if not ShouldNotAttack(inst, target) and inst.components.combat:CanTarget(target) then
        if inst.components.combat.target == nil then
            inst.components.combat:SetTarget(target)
        end
    end
end
local function OnDeath(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local fx = SpawnPrefab("shadow_despawn")
    if fx then
        fx.Transform:SetPosition(x, y, z)
    end
    if math.random() < 0.3 then
        local loot = SpawnPrefab("nightmarefuel")
        if loot then
            loot.Transform:SetPosition(x, y, z)
        end
    end
    if inst._vfx_task then
        inst._vfx_task:Cancel()
        inst._vfx_task = nil
    end
    inst:Remove()
end
local function OnOwnerDeath(inst)
    if inst:IsValid() then
        local x, y, z = inst.Transform:GetWorldPosition()
        local fx = SpawnPrefab("shadow_despawn")
        if fx then
            fx.Transform:SetPosition(x, y, z)
        end
        inst:Remove()
    end
end
local function SanityAuraFn(inst, observer)
    if observer == inst._owner then
        return 0
    end
    if observer:HasTag("player") then
        return SANITY_AURA_DRAIN
    end
    return 0
end
local function StartDemonVFX(inst)
    if inst._vfx_task then return end
    inst._vfx_task = inst:DoPeriodicTask(0.5, function()
        if not inst:IsValid() then return end
        if not inst._is_demon_boosted then
            if inst._vfx_task then
                inst._vfx_task:Cancel()
                inst._vfx_task = nil
            end
            return
        end
        local x, y, z = inst.Transform:GetWorldPosition()
        local angle = math.random() * 2 * math.pi
        local dist = 0.5 + math.random() * 0.5
        local fx_x = x + math.cos(angle) * dist
        local fx_z = z + math.sin(angle) * dist
        local fx = SpawnPrefab("stalker_shadow_fx")
        if fx then
            fx.Transform:SetPosition(fx_x, y, fx_z)
        end
    end)
end
local function StopDemonVFX(inst)
    if inst._vfx_task then
        inst._vfx_task:Cancel()
        inst._vfx_task = nil
    end
end
local function UpdateForOwnerForm(inst, is_demon)
    local stats = is_demon and STATS.demon or STATS.fox
    inst._is_demon_boosted = is_demon
    if inst.components.health then
        local health_pct = inst.components.health:GetPercent()
        inst.components.health:SetMaxHealth(stats.health)
        inst.components.health:SetPercent(health_pct)
    end
    if inst.components.combat then
        inst.components.combat:SetDefaultDamage(stats.damage)
        inst.components.combat:SetAttackPeriod(stats.attack_period)
        inst.components.combat:SetRange(stats.attack_range)
    end
    inst.AnimState:SetMultColour(unpack(stats.color))
    if is_demon then
        StartDemonVFX(inst)
    else
        StopDemonVFX(inst)
    end
    inst._current_damage = stats.damage
    inst._current_form = is_demon and "demon" or "fox"
end
local function SetOwner(inst, owner)
    inst._owner = owner
    if owner then
        inst.components.follower:SetLeader(owner)
        inst:ListenForEvent("death", function() OnOwnerDeath(inst) end, owner)
        inst:ListenForEvent("attacked", function(owner, data)
            OnOwnerAttacked(inst, owner, data)
        end, owner)
        inst:ListenForEvent("onattackother", function(owner, data)
            OnOwnerAttackOther(inst, owner, data)
        end, owner)
        local is_demon = owner and not owner:HasTag("NotDemon")
        UpdateForOwnerForm(inst, is_demon)
    end
end
local function OnPetSpawn(inst, owner)
    SetOwner(inst, owner)
end
local function GetStatus(inst)
    local health = inst.components.health and math.floor(inst.components.health.currenthealth) or 0
    local max_health = inst.components.health and inst.components.health.maxhealth or 0
    local damage = inst._current_damage or 65
    if inst._is_demon_boosted then
        return "DEMON"
    end
    return "FOX"
end
local function GetDescription(inst, viewer)
    local health = inst.components.health and math.floor(inst.components.health.currenthealth) or 0
    local max_health = inst.components.health and inst.components.health.maxhealth or 0
    local damage = inst._current_damage or 65
    local form_str = inst._is_demon_boosted and "Empowered" or "Normal"
    return string.format("HP: %d/%d | DMG: %d | %s", health, max_health, damage, form_str)
end
local function OnSave(inst, data)
    if inst._owner and inst._owner:IsValid() then
        data.owner_userid = inst._owner.userid
    end
    data.is_demon_boosted = inst._is_demon_boosted
end
local function OnLoad(inst, data)
    if data then
        if data.is_demon_boosted ~= nil then
            inst._is_demon_boosted = data.is_demon_boosted
            UpdateForOwnerForm(inst, data.is_demon_boosted)
        end
        if data.owner_userid then
            inst._saved_owner_userid = data.owner_userid
            inst:DoTaskInTime(0.1, function()
                if inst:IsValid() and inst._saved_owner_userid then
                    for _, player in ipairs(AllPlayers) do
                        if player.userid == inst._saved_owner_userid then
                            SetOwner(inst, player)
                            inst._saved_owner_userid = nil
                            return
                        end
                    end
                    local x, y, z = inst.Transform:GetWorldPosition()
                    local fx = SpawnPrefab("shadow_despawn")
                    if fx then
                        fx.Transform:SetPosition(x, y, z)
                    end
                    inst:Remove()
                end
            end)
        end
    end
end
local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst:SetPhysicsRadiusOverride(0.5)
    MakeGhostPhysics(inst, 1, inst.physicsradiusoverride)
    inst.AnimState:SetBank("shadowcreature2")
    inst.AnimState:SetBuild("shadow_insanity2_basic")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:SetMultColour(unpack(STATS.fox.color))
    inst.Transform:SetFourFaced()
    inst:AddTag("shadow_terrorbeak")
    inst:AddTag("shadowcreature")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("companion")
    inst:AddTag("shadowminion")
    inst:AddTag("NOBLOCK")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst._owner = nil
    inst._revenge_target = nil
    inst._revenge_task = nil
    inst._is_demon_boosted = false
    inst._current_damage = STATS.fox.damage
    inst._current_form = "fox"
    inst._vfx_task = nil
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 6
    inst.components.locomotor.runspeed = 10
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = {
        ignorecreep = true,
        allowocean = false,
    }
    inst.components.locomotor:SetSlowMultiplier(0.6)
    inst.components.locomotor:SetAllowPlatformHopping(true)
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(STATS.fox.health)
    inst.components.health.nofadeout = true
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(STATS.fox.damage)
    inst.components.combat:SetAttackPeriod(STATS.fox.attack_period)
    inst.components.combat:SetRange(STATS.fox.attack_range)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat.hiteffectsymbol = "marker"
    inst:AddComponent("follower")
    inst.components.follower:KeepLeaderOnAttacked()
    inst.components.follower.keepdeadleader = true
    inst:AddComponent("lootdropper")
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
    inst.components.inspectable.getspecialdescription = GetDescription
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = SanityAuraFn
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("death", OnDeath)
    inst.SetOwner = SetOwner
    inst.OnPetSpawn = OnPetSpawn
    inst.UpdateForOwnerForm = UpdateForOwnerForm
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.sounds = {
        attack = "dontstarve/sanity/creature2/attack",
        attack_grunt = "dontstarve/sanity/creature2/attack_grunt",
        death = "dontstarve/sanity/creature2/die",
        idle = "dontstarve/sanity/creature2/idle",
        taunt = "dontstarve/sanity/creature2/taunt",
        appear = "dontstarve/sanity/creature2/appear",
        disappear = "dontstarve/sanity/creature2/dissappear",
    }
    local ShadowTerrorbeakBrain = require("brains/shadowterrorbeakbrain")
    inst:SetBrain(ShadowTerrorbeakBrain)
    inst:SetStateGraph("SGshadowcreature")
    return inst
end
return Prefab("shadow_terrorbeak", fn, assets, prefabs)
