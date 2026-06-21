local ShadowMinion = require("skills/shadow_minion")
local assets = {
}
local prefabs = {
    "shadow_despawn",
    "shadow_puff",
    "shadow_puff_large_front",
    "shadow_glob_fx",
    "spider",
    "spider_warrior",
}
local SHADOW_COLOR = { 0.3, 0.1, 0.5, 0.8 }
local function SanityAuraFn(inst, observer)
    if observer == inst._owner then
        return 0
    end
    if observer:HasTag("player") then
        return -TUNING.SANITYAURA_SMALL
    end
    return 0
end
local CANT_ATTACK_TAGS = {
    "player", "companion", "kodi_shadow_minion", "shadowminion",
    "shadow_terrorbeak", "wall", "structure", "Chester", "hutch",
    "critter", "abigail", "INLIMBO", "playerghost",
}
local PASSIVE_CANT_TAGS = {
    "player", "companion", "kodi_shadow_minion", "shadowminion",
    "shadow_terrorbeak", "wall", "structure", "Chester", "hutch",
    "critter", "abigail", "INLIMBO", "playerghost",
    "prey", "bird", "butterfly", "rabbit", "mole", "smallcreature",
}
local HOSTILE_MEMORY_TIME = 10
local function MarkPrefabHostile(owner, prefab)
    if not owner._hostile_prefabs then
        owner._hostile_prefabs = {}
    end
    owner._hostile_prefabs[prefab] = GetTime() + HOSTILE_MEMORY_TIME
end
local function IsPrefabHostile(owner, prefab)
    if not owner._hostile_prefabs then return false end
    local expire_time = owner._hostile_prefabs[prefab]
    return expire_time ~= nil and GetTime() < expire_time
end
local function CanTargetEnemy(inst, target)
    if not target or not target:IsValid() then return false end
    if target == inst._owner then return false end
    if not target.components.combat then return false end
    for _, tag in ipairs(CANT_ATTACK_TAGS) do
        if target:HasTag(tag) then return false end
    end
    return true
end
local function RetargetFn(inst)
    local owner = inst._owner
    if not owner or not owner:IsValid() then
        return inst._revenge_target
    end
    local current_target = inst.components.combat.target
    if current_target and current_target:IsValid() and CanTargetEnemy(inst, current_target) then
        if (current_target.components.combat and current_target.components.combat.target == owner)
           or IsPrefabHostile(owner, current_target.prefab)
           or current_target == inst._revenge_target then
            return nil
        end
    end
    local mx, my, mz = inst.Transform:GetWorldPosition()
    local threats = TheSim:FindEntities(mx, my, mz, 20,
        {"_combat"},
        PASSIVE_CANT_TAGS)
    for _, enemy in ipairs(threats) do
        if enemy ~= inst and enemy ~= owner and CanTargetEnemy(inst, enemy) then
            if enemy.components.combat and enemy.components.combat.target == owner then
                MarkPrefabHostile(owner, enemy.prefab)
                return enemy
            end
            if IsPrefabHostile(owner, enemy.prefab) then
                return enemy
            end
        end
    end
    if owner.components.combat and owner.components.combat.target then
        local target = owner.components.combat.target
        if target and target:IsValid() and CanTargetEnemy(inst, target) then
            return target
        end
    end
    if inst._revenge_target and inst._revenge_target:IsValid()
       and CanTargetEnemy(inst, inst._revenge_target) then
        return inst._revenge_target
    end
    return nil
end
local function KeepTargetFn(inst, target)
    if not target or not target:IsValid() then return false end
    if not CanTargetEnemy(inst, target) then return false end
    local owner = inst._owner
    if owner and owner:IsValid() and owner.components.combat then
        if owner.components.combat.target == target then return true end
    end
    if target.components.combat and target.components.combat.target == owner then
        return true
    end
    if owner and owner:IsValid() and IsPrefabHostile(owner, target.prefab) then
        return true
    end
    if inst._revenge_target == target then return true end
    if owner and owner:IsValid() and inst:IsNear(owner, 25) then
        return true
    end
    return false
end
local function OnAttacked(inst, data)
    local attacker = data and data.attacker
    if attacker and attacker:IsValid() and CanTargetEnemy(inst, attacker) then
        if attacker.prefab then
            MarkPrefabHostile(inst._owner, attacker.prefab)
        end
        inst._revenge_target = attacker
        inst.components.combat:SetTarget(attacker)
        if inst._revenge_task then inst._revenge_task:Cancel() end
        inst._revenge_task = inst:DoTaskInTime(10, function()
            inst._revenge_target = nil
            inst._revenge_task = nil
        end)
    end
end
local function OnOwnerAttacked(inst, owner, data)
    local attacker = data and data.attacker
    if attacker and attacker:IsValid() and attacker.prefab then
        MarkPrefabHostile(owner, attacker.prefab)
    end
    if CanTargetEnemy(inst, attacker) then
        if not inst.components.combat.target or not inst.components.combat.target:IsValid() then
            inst.components.combat:SetTarget(attacker)
        end
    end
end
local function OnOwnerAttackOther(inst, owner, data)
    local target = data and data.target
    if CanTargetEnemy(inst, target) then
        if not inst.components.combat.target or not inst.components.combat.target:IsValid() then
            inst.components.combat:SetTarget(target)
        end
    end
end
local function CleanupBabies(inst)
    if inst._shadow_babies then
        for i = #inst._shadow_babies, 1, -1 do
            local baby = inst._shadow_babies[i]
            if not baby or not baby:IsValid() then
                table.remove(inst._shadow_babies, i)
            end
        end
    end
end
local function DespawnAllBabies(inst)
    if inst._shadow_babies then
        for _, baby in ipairs(inst._shadow_babies) do
            if baby and baby:IsValid() then
                local bx, by, bz = baby.Transform:GetWorldPosition()
                local fx = SpawnPrefab("shadow_despawn")
                if fx then fx.Transform:SetPosition(bx, by, bz) end
                baby:Remove()
            end
        end
        inst._shadow_babies = {}
    end
end
local function SpawnShadowBaby(inst)
    if not inst:IsValid() or not inst._owner or not inst._owner:IsValid() then return end
    CleanupBabies(inst)
    local max_babies = TUNING.KODI_SHADOW_SPIDERQUEEN_MAX_BABIES or 6
    if #inst._shadow_babies >= max_babies then return end
    local baby_prefab = math.random() < 0.5 and "spider" or "spider_warrior"
    local baby = SpawnPrefab(baby_prefab)
    if not baby then return end
    local qx, qy, qz = inst.Transform:GetWorldPosition()
    local angle = math.random() * 2 * math.pi
    baby.Transform:SetPosition(qx + math.cos(angle) * 1.5, qy, qz + math.sin(angle) * 1.5)
    ShadowMinion.ApplyShadowAppearance(baby)
    baby:AddTag("kodi_shadow_minion")
    baby:AddTag("kodi_summoned_minion")
    baby:AddTag("noplayertarget")
    baby:AddTag("companion")
    baby.persists = false
    if baby.components.sanityaura then
        local queen_owner = inst._owner
        baby.components.sanityaura.aurafn = function(_, observer)
            if observer == queen_owner then return 0 end
            if observer:HasTag("player") then return -TUNING.SANITYAURA_SMALL end
            return 0
        end
    end
    if baby.components.follower then
        baby.components.follower:SetLeader(inst)
        baby.components.follower:KeepLeaderOnAttacked()
    end
    if baby.components.knownlocations then
        baby.components.knownlocations:ForgetLocation("home")
    end
    if baby.components.homeseeker then
        baby:RemoveComponent("homeseeker")
    end
    if baby.components.trader then
        baby.components.trader:Disable()
    end
    if baby.components.sleeper then
        baby.components.sleeper:SetSleepTest(function() return false end)
        baby.components.sleeper:SetWakeTest(function() return true end)
    end
    if baby.components.eater then
        baby.components.eater.caneat = {}
        baby.components.eater.Eat = function() return false end
        baby.components.eater.CanEat = function() return false end
    end
    if baby.components.combat then
        local queen = inst
        local owner = inst._owner
        baby.components.combat:SetRetargetFunction(1, function()
            if queen:IsValid() and queen.components.combat and queen.components.combat.target then
                local target = queen.components.combat.target
                if target:IsValid() and not target:HasTag("player")
                   and not target:HasTag("kodi_shadow_minion") then
                    return target
                end
            end
            if owner and owner:IsValid() and owner.components.combat and owner.components.combat.target then
                local target = owner.components.combat.target
                if target:IsValid() and not target:HasTag("player")
                   and not target:HasTag("kodi_shadow_minion") then
                    return target
                end
            end
            return nil
        end)
        baby.components.combat:SetKeepTargetFunction(function(_, target)
            if not target or not target:IsValid() then return false end
            if target:HasTag("player") or target:HasTag("kodi_shadow_minion") then return false end
            if target.components.health and target.components.health:IsDead() then return false end
            return true
        end)
        local old_GetAttacked = baby.components.combat.GetAttacked
        baby.components.combat.GetAttacked = function(self, attacker, damage, weapon, stimuli)
            if attacker and (attacker == owner or attacker:HasTag("player")
               or attacker:HasTag("kodi_shadow_minion")) then
                return false
            end
            if old_GetAttacked then
                return old_GetAttacked(self, attacker, damage, weapon, stimuli)
            end
        end
    end
    local baby_lifetime = TUNING.KODI_SHADOW_SPIDERQUEEN_BABY_LIFETIME or 45
    baby:DoTaskInTime(baby_lifetime, function()
        if baby:IsValid() then
            local bx, by, bz = baby.Transform:GetWorldPosition()
            local fx = SpawnPrefab("shadow_despawn")
            if fx then fx.Transform:SetPosition(bx, by, bz) end
            baby:Remove()
        end
    end)
    table.insert(inst._shadow_babies, baby)
    local fx = SpawnPrefab("shadow_puff")
    if fx then fx.Transform:SetPosition(baby.Transform:GetWorldPosition()) end
end
local function TrySpawnBaby(inst)
    if not inst:IsValid() then return end
    CleanupBabies(inst)
    local max_babies = TUNING.KODI_SHADOW_SPIDERQUEEN_MAX_BABIES or 6
    if #inst._shadow_babies >= max_babies then return end
    if not inst.components.combat or not inst.components.combat.target then return end
    if inst.sg and not inst.sg:HasStateTag("busy") and not inst.sg:HasStateTag("attack") then
        inst.sg:GoToState("taunt")
    end
    inst:DoTaskInTime(0.8, function()
        if inst:IsValid() then
            SpawnShadowBaby(inst)
        end
    end)
end
local function OnDeath(inst)
    DespawnAllBabies(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local fx = SpawnPrefab("shadow_despawn")
    if fx then
        fx.Transform:SetPosition(x, y, z)
        fx.Transform:SetScale(2, 2, 2)
    end
    for i = 1, 6 do
        local angle = (i / 6) * 2 * math.pi
        local puff = SpawnPrefab("shadow_puff_large_front")
        if puff then
            puff.Transform:SetPosition(x + math.cos(angle) * 2, y, z + math.sin(angle) * 2)
        end
    end
    ShakeAllCameras(CAMERASHAKE.FULL, 0.5, 0.03, 0.2, Vector3(x, y, z), 20)
    if inst._vfx_task then
        inst._vfx_task:Cancel()
        inst._vfx_task = nil
    end
    if inst._baby_spawn_task then
        inst._baby_spawn_task:Cancel()
        inst._baby_spawn_task = nil
    end
    inst:DoTaskInTime(0.5, function()
        if inst:IsValid() then
            inst:Remove()
        end
    end)
end
local function OnOwnerDeath(inst)
    DespawnAllBabies(inst)
    if inst:IsValid() then
        local x, y, z = inst.Transform:GetWorldPosition()
        local fx = SpawnPrefab("shadow_despawn")
        if fx then fx.Transform:SetPosition(x, y, z) end
        inst:Remove()
    end
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
    end
end
local function StartVFX(inst)
    if inst._vfx_task then return end
    inst._vfx_task = inst:DoPeriodicTask(0.4, function()
        if not inst:IsValid() then return end
        local x, y, z = inst.Transform:GetWorldPosition()
        local angle = math.random() * 2 * math.pi
        local dist = 0.5 + math.random() * 1.0
        local fx = SpawnPrefab("shadow_glob_fx")
        if fx then
            fx.Transform:SetPosition(x + math.cos(angle) * dist, y + 0.5, z + math.sin(angle) * dist)
        else
            fx = SpawnPrefab("wetpoison_splash")
            if fx then
                fx.Transform:SetPosition(x + math.cos(angle) * dist, y + 0.2, z + math.sin(angle) * dist)
                if fx.AnimState then
                    fx.AnimState:SetMultColour(0.1, 0, 0.15, 1)
                end
            end
        end
    end)
end
local function GetStatus(inst)
    return "GENERIC"
end
local function GetDescription(inst, viewer)
    local health = inst.components.health and math.floor(inst.components.health.currenthealth) or 0
    local max_health = inst.components.health and inst.components.health.maxhealth or 0
    local damage = TUNING.KODI_SHADOW_SPIDERQUEEN_DAMAGE or 60
    local baby_count = inst._shadow_babies and #inst._shadow_babies or 0
    return string.format("HP: %d/%d | DMG: %d | Babies: %d", health, max_health, damage, baby_count)
end
local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()
    MakeCharacterPhysics(inst, 1000, 1)
    inst.DynamicShadow:SetSize(7, 3)
    inst.Transform:SetFourFaced()
    inst.AnimState:SetBank("spider_queen")
    inst.AnimState:SetBuild("spider_queen_build")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:SetMultColour(unpack(SHADOW_COLOR))
    inst:AddTag("kodi_shadow_minion")
    inst:AddTag("kodi_summoned_minion")
    inst:AddTag("shadow_spiderqueen")
    inst:AddTag("companion")
    inst:AddTag("shadowminion")
    inst:AddTag("monster")
    inst:AddTag("NOBLOCK")
    inst:AddTag("noplayertarget")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst._owner = nil
    inst._revenge_target = nil
    inst._revenge_task = nil
    inst._shadow_babies = {}
    inst._vfx_task = nil
    inst._baby_spawn_task = nil
    inst._pool_slot_count = 3
    inst.persists = false
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.KODI_SHADOW_SPIDERQUEEN_WALKSPEED
    inst.components.locomotor.runspeed = TUNING.KODI_SHADOW_SPIDERQUEEN_WALKSPEED * 1.5
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = true, allowocean = false }
    inst.components.locomotor:SetSlowMultiplier(0.6)
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.KODI_SHADOW_SPIDERQUEEN_HEALTH)
    inst.components.health.nofadeout = true
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.KODI_SHADOW_SPIDERQUEEN_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.KODI_SHADOW_SPIDERQUEEN_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.KODI_SHADOW_SPIDERQUEEN_ATTACK_RANGE)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat.hiteffectsymbol = "body"
    inst:AddComponent("follower")
    inst.components.follower:KeepLeaderOnAttacked()
    inst.components.follower.keepdeadleader = true
    inst:AddComponent("leader")
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({})
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
    inst.components.inspectable.getspecialdescription = GetDescription
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = SanityAuraFn
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("death", OnDeath)
    local spawn_period = TUNING.KODI_SHADOW_SPIDERQUEEN_BABY_SPAWN_PERIOD or 12
    inst._baby_spawn_task = inst:DoPeriodicTask(spawn_period, function()
        TrySpawnBaby(inst)
    end)
    inst.SetOwner = SetOwner
    inst.TrySpawnBaby = TrySpawnBaby
    inst.DespawnAllBabies = DespawnAllBabies
    StartVFX(inst)
    inst.sounds = {
        attack = "dontstarve/creatures/spider_queen/attack",
        attack_grunt = "dontstarve/creatures/spider_queen/attack_grunt",
        death = "dontstarve/creatures/spider_queen/death",
        idle = "dontstarve/creatures/spider_queen/idle",
        taunt = "dontstarve/creatures/spider_queen/taunt",
    }
    local ShadowSpiderQueenBrain = require("brains/shadowspiderqueenbrain")
    inst:SetBrain(ShadowSpiderQueenBrain)
    inst:SetStateGraph("SGspiderqueen")
    return inst
end
return Prefab("shadow_spiderqueen", fn, assets, prefabs)
