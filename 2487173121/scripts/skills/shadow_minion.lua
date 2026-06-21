local ShadowMinion = {}
ShadowMinion.CORPSE_SEARCH_RADIUS = TUNING.KODI_SHADOW_MINION_CORPSE_SEARCH_RADIUS
ShadowMinion.FOLLOW_DISTANCE = TUNING.KODI_SHADOW_MINION_FOLLOW_DISTANCE
ShadowMinion.ATTACK_RANGE = TUNING.KODI_SHADOW_MINION_ATTACK_RANGE
ShadowMinion.LIFETIME_MIN = TUNING.KODI_SHADOW_MINION_LIFETIME_MIN
ShadowMinion.LIFETIME_MAX = TUNING.KODI_SHADOW_MINION_LIFETIME_MAX
ShadowMinion.EXPLOSION_DAMAGE = TUNING.KODI_SHADOW_MINION_EXPLOSION_DAMAGE
ShadowMinion.EXPLOSION_RADIUS = TUNING.KODI_SHADOW_MINION_EXPLOSION_RADIUS
ShadowMinion.COOLDOWN = TUNING.KODI_SHADOW_MINION_COOLDOWN
ShadowMinion.TELEPORT_DISTANCE = TUNING.KODI_SHADOW_MINION_TELEPORT_DISTANCE
ShadowMinion.STUCK_TIME = TUNING.KODI_SHADOW_MINION_STUCK_TIME
ShadowMinion.STUCK_THRESHOLD = TUNING.KODI_SHADOW_MINION_STUCK_THRESHOLD
ShadowMinion.COLOR = {
    r = 0.3,
    g = 0.1,
    b = 0.4,
    a = 0.8
}
ShadowMinion.RAISEABLE_FROM = {
    meat = {"pigman", "bunnyman", "merm"},
    smallmeat = {"rabbit", "crow", "robin", "robin_winter", "canary"},
    monstermeat = {"spider", "spider_warrior", "hound", "tentacle"},
    drumstick = {"tallbird"},
    batwing = {"bat"},
    froglegs = {"frog"},
    fish = {"fish"},
    spidergland = {"spider", "spider_warrior"},
    houndstooth = {"hound", "firehound", "icehound"},
    stinger = {"bee", "killerbee"},
    beardhair = {"pigman"},
}
ShadowMinion.CORPSE_TO_CREATURE = {
}
function ShadowMinion.SpawnFromCorpse(owner, corpse_prefab, position)
    local creature_options = ShadowMinion.RAISEABLE_FROM[corpse_prefab]
    if not creature_options then
        creature_options = {corpse_prefab}
    end
    local creature_prefab = creature_options[math.random(#creature_options)]
    local minion = SpawnPrefab(creature_prefab)
    if not minion then
        minion = SpawnPrefab("crawlinghorror")
    end
    if not minion then
        return nil
    end
    local x, y, z = position.x, position.y, position.z
    minion.Transform:SetPosition(x, y, z)
    ShadowMinion.ApplyShadowAppearance(minion)
    ShadowMinion.ConfigureAI(minion, owner)
    local lifetime = ShadowMinion.LIFETIME_MIN + math.random() * (ShadowMinion.LIFETIME_MAX - ShadowMinion.LIFETIME_MIN)
    ShadowMinion.SetLifetime(minion, owner, lifetime)
    ShadowMinion.SetupDeathExplosion(minion, owner)
    ShadowMinion.SpawnRaiseEffects(x, y, z)
    owner._shadow_minion = minion
    minion._shadow_owner = owner
    owner.SoundEmitter:PlaySound("dontstarve/cave/nightmare_spawner_open")
    return minion
end
function ShadowMinion.SpawnFromPool(owner, creature_prefab, position, skip_effects)
    local minion = SpawnPrefab(creature_prefab)
    if not minion then
        minion = SpawnPrefab("crawlinghorror")
    end
    if not minion then
        return nil
    end
    local x, y, z
    if position.x then
        x, y, z = position.x, position.y, position.z
    else
        x, y, z = position:Get()
    end
    minion.Transform:SetPosition(x, y, z)
    minion.persists = false
    ShadowMinion.ApplyShadowAppearance(minion)
    ShadowMinion.ConfigureAI(minion, owner)
    local lifetime = ShadowMinion.LIFETIME_MIN + math.random() * (ShadowMinion.LIFETIME_MAX - ShadowMinion.LIFETIME_MIN)
    ShadowMinion.SetLifetime(minion, owner, lifetime)
    ShadowMinion.SetupDeathExplosion(minion, owner)
    minion._shadow_owner = owner
    minion._shadow_owner_userid = owner.userid
    if not skip_effects then
        ShadowMinion.SpawnRaiseEffects(x, y, z)
        owner.SoundEmitter:PlaySound("dontstarve/cave/nightmare_spawner_open")
    end
    if owner.components.talker then
        local msg = STRINGS.KODI_SPEECH and STRINGS.KODI_SPEECH.MINION_SUMMONED or "*rise, shadow!*"
        owner.components.talker:Say(msg, 2, true)
    end
    return minion
end
function ShadowMinion.ApplyShadowAppearance(minion)
    if minion.AnimState then
        minion.AnimState:SetMultColour(
            ShadowMinion.COLOR.r,
            ShadowMinion.COLOR.g,
            ShadowMinion.COLOR.b,
            ShadowMinion.COLOR.a
        )
        minion.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    end
    minion:AddTag("kodi_shadow_minion")
    minion:AddTag("kodi_summoned_minion")
    if minion.components.hauntable then
        minion:RemoveComponent("hauntable")
    end
    if minion.components.lootdropper then
        minion.components.lootdropper:SetLoot({})
        minion.components.lootdropper:SetChanceLootTable(nil)
    end
    minion._shadow_particle_task = minion:DoPeriodicTask(0.3, function()
        if minion:IsValid() then
            local mx, my, mz = minion.Transform:GetWorldPosition()
            local offset_x = (math.random() - 0.5) * 1.2
            local offset_z = (math.random() - 0.5) * 1.2
            local drop = SpawnPrefab("shadow_glob_fx")
            if drop then
                drop.Transform:SetPosition(mx + offset_x, my + 0.5, mz + offset_z)
                drop.Transform:SetScale(0.3, 0.3, 0.3)
            else
                drop = SpawnPrefab("wetpoison_splash")
                if drop then
                    drop.Transform:SetPosition(mx + offset_x, my + 0.2, mz + offset_z)
                    drop.Transform:SetScale(0.4, 0.4, 0.4)
                    if drop.AnimState then
                        drop.AnimState:SetMultColour(0.1, 0, 0.15, 1)
                    end
                end
            end
        end
    end)
end
function ShadowMinion.TeleportToOwner(minion, owner)
    if not minion:IsValid() or not owner:IsValid() then return false end
    local mx, my, mz = minion.Transform:GetWorldPosition()
    local ox, oy, oz = owner.Transform:GetWorldPosition()
    local despawn_fx = SpawnPrefab("shadow_despawn")
    if despawn_fx then
        despawn_fx.Transform:SetPosition(mx, my, mz)
    end
    local target_x, target_z = ox, oz
    local offset = FindWalkableOffset(
        Vector3(ox, 0, oz),
        math.random() * 2 * math.pi,
        3,
        8,
        false,
        true
    )
    if offset then
        target_x = ox + offset.x
        target_z = oz + offset.z
    end
    if minion.Physics then
        minion.Physics:Teleport(target_x, 0, target_z)
    else
        minion.Transform:SetPosition(target_x, 0, target_z)
    end
    local arrive_fx = SpawnPrefab("shadow_puff_large_front")
    if arrive_fx then
        arrive_fx.Transform:SetPosition(target_x, 0, target_z)
    end
    if minion.SoundEmitter then
        minion.SoundEmitter:PlaySound("dontstarve/sanity/creature2/appear")
    end
    if minion.components.locomotor then
        minion.components.locomotor:Stop()
    end
    minion._last_progress_time = GetTime()
    minion._last_progress_pos = { x = target_x, z = target_z }
    return true
end
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
function ShadowMinion.ConfigureAI(minion, owner)
    if minion.components.hunger then
        minion.components.hunger:SetMax(0)
        minion.components.hunger:Pause()
    end
    if minion.components.eater then
        minion.components.eater.caneat = {}
        minion.components.eater.Eat = function() return false end
        minion.components.eater.CanEat = function() return false end
    end
    if minion.components.sleeper then
        minion.components.sleeper:SetSleepTest(function() return false end)
        minion.components.sleeper:SetWakeTest(function() return true end)
    end
    if minion.components.grogginess then
        minion.components.grogginess:SetEnable(false)
    end
    if minion.components.trader then
        minion.components.trader:Disable()
    end
    if minion.components.sanityaura then
        minion.components.sanityaura.aurafn = function(inst, observer)
            if observer == owner then return 0 end
            if observer:HasTag("player") then
                return -TUNING.SANITYAURA_SMALL
            end
            return 0
        end
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
    if minion.components.combat then
        minion.components.combat.CanTarget = function(self, target)
            if not target then return false end
            if not target:IsValid() then return false end
            if target == owner then return false end
            if not target.components.combat then return false end
            for _, tag in ipairs(CANT_ATTACK_TAGS) do
                if target:HasTag(tag) then return false end
            end
            return true
        end
        minion.components.combat:SetRetargetFunction(1, function()
            if not minion:IsValid() or not owner:IsValid() then
                return nil
            end
            local current_target = minion.components.combat.target
            if current_target and current_target:IsValid()
               and minion.components.combat:CanTarget(current_target) then
                if (current_target.components.combat and current_target.components.combat.target == owner)
                   or IsPrefabHostile(owner, current_target.prefab)
                   or current_target == minion._revenge_target then
                    return nil
                end
            end
            local mx, my, mz = minion.Transform:GetWorldPosition()
            local threats = TheSim:FindEntities(mx, my, mz, 20,
                {"_combat"},
                PASSIVE_CANT_TAGS)
            for _, enemy in ipairs(threats) do
                if enemy ~= minion and enemy ~= owner and minion.components.combat:CanTarget(enemy) then
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
                if target and target:IsValid() and minion.components.combat:CanTarget(target) then
                    return target
                end
            end
            if minion._revenge_target and minion._revenge_target:IsValid()
               and minion.components.combat:CanTarget(minion._revenge_target) then
                return minion._revenge_target
            end
            return nil
        end)
        minion.components.combat:SetKeepTargetFunction(function(inst, target)
            if not target or not target:IsValid() then return false end
            if not inst.components.combat:CanTarget(target) then return false end
            if owner:IsValid() and owner.components.combat and owner.components.combat.target == target then
                return true
            end
            if target.components.combat and target.components.combat.target == owner then
                return true
            end
            if owner:IsValid() and IsPrefabHostile(owner, target.prefab) then
                return true
            end
            if inst._revenge_target == target then
                return true
            end
            if owner:IsValid() and inst:IsNear(owner, 20) then
                return true
            end
            return false
        end)
        local old_GetAttacked = minion.components.combat.GetAttacked
        minion.components.combat.GetAttacked = function(self, attacker, damage, weapon, stimuli)
            if attacker == owner then return false end
            if attacker:HasTag("player") then return false end
            if old_GetAttacked then
                return old_GetAttacked(self, attacker, damage, weapon, stimuli)
            end
        end
        minion.components.combat.SuggestTarget = function(self, target)
            if not target then return end
            if target == owner then return end
            if target:HasTag("player") then return end
            if self:CanTarget(target) then
                self:SetTarget(target)
            end
        end
        minion.components.combat:SetDefaultDamage((minion.components.combat.defaultdamage or 20) * 1.5)
    end
    minion:AddTag("noplayertarget")
    minion:ListenForEvent("onhitother", function(inst, data)
        local target = data.target
        if target and target:IsValid() and target.components.combat then
            if target:HasTag("player") or target:HasTag("kodi_shadow_minion") then
                return
            end
            local enemy_combat = target.components.combat
            if enemy_combat then
                enemy_combat:SuggestTarget(minion)
            end
        end
    end)
    minion:ListenForEvent("attacked", function(inst, data)
        local attacker = data.attacker
        if attacker and attacker:IsValid() and minion.components.combat then
            if minion.components.combat:CanTarget(attacker) then
                if attacker.prefab then
                    MarkPrefabHostile(owner, attacker.prefab)
                end
                minion._revenge_target = attacker
                minion.components.combat:SetTarget(attacker)
                if minion._revenge_task then minion._revenge_task:Cancel() end
                minion._revenge_task = minion:DoTaskInTime(10, function()
                    minion._revenge_target = nil
                    minion._revenge_task = nil
                end)
            end
        end
    end)
    minion._owner_attacked_listener = function(player, data)
        if not minion:IsValid() then return end
        local attacker = data.attacker
        if attacker and attacker:IsValid() and attacker.prefab and minion.components.combat then
            MarkPrefabHostile(owner, attacker.prefab)
            if minion.components.combat:CanTarget(attacker) then
                if not minion.components.combat.target or not minion.components.combat.target:IsValid() then
                    minion.components.combat:SetTarget(attacker)
                end
            end
        end
    end
    minion._owner_ref = owner
    owner:ListenForEvent("attacked", minion._owner_attacked_listener)
    minion._owner_attack_other_listener = function(player, data)
        if not minion:IsValid() then return end
        local target = data and data.target
        if target and target:IsValid() and minion.components.combat then
            if minion.components.combat:CanTarget(target) then
                if not minion.components.combat.target or not minion.components.combat.target:IsValid() then
                    minion.components.combat:SetTarget(target)
                end
            end
        end
    end
    owner:ListenForEvent("onattackother", minion._owner_attack_other_listener)
    minion._last_progress_time = GetTime()
    minion._last_progress_pos = nil
    minion._follow_task = minion:DoPeriodicTask(1, function()
        if not minion:IsValid() or not owner:IsValid() then
            return
        end
        local combat = minion.components.combat
        local has_target = combat and combat.target and combat.target:IsValid()
        if minion.components.locomotor then
            local mx, my, mz = minion.Transform:GetWorldPosition()
            local ox, oy, oz = owner.Transform:GetWorldPosition()
            local dx, dz = ox - mx, oz - mz
            local dist = math.sqrt(dx * dx + dz * dz)
            if dist > ShadowMinion.TELEPORT_DISTANCE then
                ShadowMinion.TeleportToOwner(minion, owner)
                return
            end
            if not has_target and dist > ShadowMinion.FOLLOW_DISTANCE then
                local now = GetTime()
                local prev = minion._last_progress_pos
                if prev then
                    local moved = math.sqrt((mx - prev.x)^2 + (mz - prev.z)^2)
                    if moved >= ShadowMinion.STUCK_THRESHOLD then
                        minion._last_progress_time = now
                        minion._last_progress_pos = { x = mx, z = mz }
                    elseif now - minion._last_progress_time > ShadowMinion.STUCK_TIME then
                        ShadowMinion.TeleportToOwner(minion, owner)
                        return
                    end
                else
                    minion._last_progress_pos = { x = mx, z = mz }
                end
                local angle = math.atan2(dz, dx)
                local target_x = ox - math.cos(angle) * (ShadowMinion.FOLLOW_DISTANCE * 0.5)
                local target_z = oz - math.sin(angle) * (ShadowMinion.FOLLOW_DISTANCE * 0.5)
                minion.components.locomotor:GoToPoint(Vector3(target_x, 0, target_z))
            elseif not has_target and dist <= ShadowMinion.FOLLOW_DISTANCE then
                minion.components.locomotor:Stop()
                minion._last_progress_time = GetTime()
                minion._last_progress_pos = { x = mx, z = mz }
            else
                minion._last_progress_time = GetTime()
                minion._last_progress_pos = nil
            end
        end
    end)
    if minion.prefab == "spider_warrior" then
        local SpiderMerge = require("skills/spider_merge")
        if not minion.components.trader then
            minion:AddComponent("trader")
        end
        minion.components.trader:Enable()
        minion.components.trader.deleteitemonaccept = true
        minion.components.trader:SetAbleToAcceptTest(nil)
        minion.components.trader:SetAcceptTest(function(inst, item)
            return item.prefab == "darkcrystal" and not inst._fed_darkcrystal
        end)
        minion.components.trader.onrefuse = nil
        minion.components.trader.onaccept = function(inst, giver)
            local fx = SpawnPrefab("shadow_puff_large_front")
            if fx then
                fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
            end
            inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacle_attack")
            SpiderMerge.OnDarkCrystalFed(inst, owner)
        end
    end
end
function ShadowMinion.SetLifetime(minion, owner, duration)
    minion._shadow_lifetime = duration
    minion._shadow_spawn_time = GetTime()
    minion._shadow_lifetime_end = GetTime() + duration
    minion:DoTaskInTime(duration - 30, function()
        if minion:IsValid() and owner:IsValid() then
            owner.components.talker:Say(STRINGS.KODI_SPEECH and STRINGS.KODI_SPEECH.MINION_FADING or "*shadow weakening...*", 2, true)
            minion._flicker_task = minion:DoPeriodicTask(0.3, function()
                if minion:IsValid() and minion.AnimState then
                    local alpha = 0.4 + math.random() * 0.4
                    minion.AnimState:SetMultColour(
                        ShadowMinion.COLOR.r,
                        ShadowMinion.COLOR.g,
                        ShadowMinion.COLOR.b,
                        alpha
                    )
                end
            end)
        end
    end)
    minion._despawn_task = minion:DoTaskInTime(duration, function()
        if minion:IsValid() then
            ShadowMinion.Despawn(minion, owner, false)
        end
    end)
end
function ShadowMinion.SetupDeathExplosion(minion, owner)
    minion:ListenForEvent("death", function()
        ShadowMinion.DoExplosion(minion, owner)
        minion:DoTaskInTime(0.5, function()
            if minion:IsValid() then
                minion:Remove()
            end
        end)
    end)
    minion:ListenForEvent("onremove", function()
        if minion._should_explode and not minion._exploded then
            ShadowMinion.DoExplosion(minion, owner)
        end
    end)
    if minion.components.health then
        local old_Kill = minion.components.health.Kill
        minion.components.health.Kill = function(self)
            minion._should_explode = true
            if old_Kill then
                old_Kill(self)
            end
        end
    end
end
function ShadowMinion.DoExplosion(minion, owner)
    if minion._exploded then return end
    minion._exploded = true
    local x, y, z = minion.Transform:GetWorldPosition()
    ShadowMinion.SpawnExplosionEffects(x, y, z)
    local targets = TheSim:FindEntities(x, y, z, ShadowMinion.EXPLOSION_RADIUS,
        {"_combat"},
        {"player", "companion", "kodi_shadow_minion", "wall", "structure", "INLIMBO"})
    for _, target in ipairs(targets) do
        if target ~= minion and target.components.combat and target.components.health then
            target.components.health:DoDelta(-ShadowMinion.EXPLOSION_DAMAGE)
            if target.Physics then
                local tx, ty, tz = target.Transform:GetWorldPosition()
                local angle = math.atan2(tz - z, tx - x)
                local knockback = 3
                target.Physics:SetVel(math.cos(angle) * knockback, 2, math.sin(angle) * knockback)
            end
            local hit_fx = SpawnPrefab("shadow_despawn")
            if hit_fx then
                hit_fx.Transform:SetPosition(target.Transform:GetWorldPosition())
            end
        end
    end
    if owner and owner:IsValid() then
        owner.SoundEmitter:PlaySound("dontstarve/common/shadowTentacle_attack")
        owner.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/fossil_spike")
    end
    if owner then
        owner._shadow_minion = nil
    end
end
function ShadowMinion.Despawn(minion, owner, with_explosion)
    if not minion:IsValid() then return end
    if minion._follow_task then minion._follow_task:Cancel() end
    if minion._shadow_particle_task then minion._shadow_particle_task:Cancel() end
    if minion._flicker_task then minion._flicker_task:Cancel() end
    if minion._despawn_task then minion._despawn_task:Cancel() end
    if minion._revenge_task then minion._revenge_task:Cancel() end
    if minion._owner_ref and minion._owner_ref:IsValid() then
        if minion._owner_attacked_listener then
            minion._owner_ref:RemoveEventCallback("attacked", minion._owner_attacked_listener)
        end
        if minion._owner_attack_other_listener then
            minion._owner_ref:RemoveEventCallback("onattackother", minion._owner_attack_other_listener)
        end
    end
    local x, y, z = minion.Transform:GetWorldPosition()
    if with_explosion then
        minion._should_explode = true
        if minion.components.health then
            minion.components.health:Kill()
        else
            ShadowMinion.DoExplosion(minion, owner)
            minion:Remove()
        end
    else
        ShadowMinion.SpawnDespawnEffects(x, y, z)
        minion:Remove()
        if owner and owner:IsValid() then
            owner._shadow_minion = nil
            owner.components.talker:Say(STRINGS.KODI_SPEECH and STRINGS.KODI_SPEECH.MINION_GONE or "*shadow dispersed*", 1.5, true)
        end
    end
end
function ShadowMinion.SpawnWithEffects(owner, creature_prefab, position, item_to_consume, callback)
    local x, y, z
    if position.x then
        x, y, z = position.x, position.y, position.z
    else
        x, y, z = position:Get()
    end
    local pillars = {}
    for i = 1, 5 do
        local angle = (i / 5) * 2 * math.pi
        local radius = 1.8
        local pillar = SpawnPrefab("shadow_pillar")
        if pillar then
            pillar.Transform:SetPosition(x + math.cos(angle) * radius, y, z + math.sin(angle) * radius)
            pillar.Transform:SetScale(0.7, 0.9, 0.7)
            table.insert(pillars, pillar)
        end
    end
    local ground_fx = SpawnPrefab("statue_transition_2")
    if ground_fx then
        ground_fx.Transform:SetPosition(x, y, z)
    end
    owner.SoundEmitter:PlaySound("dontstarve/sanity/shadowrock_up")
    owner:DoTaskInTime(1.2, function()
        if not owner:IsValid() then return end
        local lightning = SpawnPrefab("lightning")
        if lightning then
            lightning.Transform:SetPosition(x, y, z)
        end
        if item_to_consume and item_to_consume:IsValid() then
            item_to_consume:RemoveTag("kodi_claimed_for_summon")
            local puff = SpawnPrefab("shadow_puff_large_front")
            if puff then
                puff.Transform:SetPosition(x, y, z)
            end
            if item_to_consume.components.stackable and item_to_consume.components.stackable:StackSize() > 1 then
                item_to_consume.components.stackable:SetStackSize(item_to_consume.components.stackable:StackSize() - 1)
            else
                item_to_consume:Remove()
            end
        end
        local minion = ShadowMinion.SpawnFromPool(owner, creature_prefab, position, true)
        owner:DoTaskInTime(0.5, function()
            for _, pillar in ipairs(pillars) do
                if pillar:IsValid() then
                    if pillar.components and pillar.components.timer then
                        pillar.components.timer:StopTimer("lifetime")
                        pillar.components.timer:StopTimer("warningtime")
                        pillar.components.timer:StopTimer("delay")
                    end
                    pillar:PushEvent("timerdone", {name = "lifetime"})
                end
            end
        end)
        if callback then
            callback(minion)
        end
    end)
end
function ShadowMinion.SpawnRaiseEffects(x, y, z)
    local ring = SpawnPrefab("groundpoundring_fx")
    if ring then
        ring.Transform:SetPosition(x, y, z)
    end
    for i = 1, 4 do
        local puff = SpawnPrefab("shadow_puff")
        if puff then
            puff.Transform:SetPosition(x + (math.random() - 0.5) * 2, y, z + (math.random() - 0.5) * 2)
        end
    end
end
function ShadowMinion.SpawnExplosionEffects(x, y, z)
    local burst = SpawnPrefab("shadow_despawn")
    if burst then
        burst.Transform:SetPosition(x, y, z)
        burst.Transform:SetScale(2, 2, 2)
    end
    for i = 1, 8 do
        local angle = (i / 8) * 2 * math.pi
        local radius = ShadowMinion.EXPLOSION_RADIUS * 0.8
        local puff = SpawnPrefab("shadow_puff_large_front")
        if puff then
            puff.Transform:SetPosition(x + math.cos(angle) * radius, y, z + math.sin(angle) * radius)
        end
    end
    for i = 1, 4 do
        local angle = (i / 4) * 2 * math.pi
        local radius = 1.5
        local ground_fx = SpawnPrefab("shadow_glob_fx")
        if ground_fx then
            ground_fx.Transform:SetPosition(x + math.cos(angle) * radius, y, z + math.sin(angle) * radius)
        end
    end
    local ring = SpawnPrefab("groundpoundring_fx")
    if ring then
        ring.Transform:SetPosition(x, y, z)
        ring.Transform:SetScale(1.5, 1.5, 1.5)
    end
    ShakeAllCameras(CAMERASHAKE.FULL, 0.5, 0.03, 0.2, Vector3(x, y, z), 20)
end
function ShadowMinion.SpawnDespawnEffects(x, y, z)
    local despawn = SpawnPrefab("shadow_despawn")
    if despawn then
        despawn.Transform:SetPosition(x, y, z)
    end
    for i = 1, 6 do
        local puff = SpawnPrefab("shadow_puff")
        if puff then
            puff.Transform:SetPosition(x, y + i * 0.3, z)
        end
    end
end
function ShadowMinion.FindNearbyCorpse(owner)
    local x, y, z = owner.Transform:GetWorldPosition()
    local items = TheSim:FindEntities(x, y, z, ShadowMinion.CORPSE_SEARCH_RADIUS,
        nil,
        {"INLIMBO", "FX", "player", "structure"})
    for _, item in ipairs(items) do
        if item.components.inventoryitem and not item.components.inventoryitem:IsHeld() then
            if ShadowMinion.RAISEABLE_FROM[item.prefab] then
                return item
            end
        end
    end
    return nil
end
function ShadowMinion.TryRaise(owner)
    if not owner:HasTag("kodi_shadow_minion") then
        return false
    end
    local remaining = (owner._shadow_minion_cooldown or 0) - GetTime()
    if remaining > 0 then
        owner.components.talker:Say("*" .. math.ceil(remaining) .. "s*", 1, true)
        return false
    end
    if owner._shadow_minion and owner._shadow_minion:IsValid() then
        owner.components.talker:Say(STRINGS.KODI_SPEECH and STRINGS.KODI_SPEECH.MINION_ALREADY or "*already have a shadow servant*", 2, true)
        return false
    end
    local corpse = ShadowMinion.FindNearbyCorpse(owner)
    if not corpse then
        owner.components.talker:Say(STRINGS.KODI_SPEECH and STRINGS.KODI_SPEECH.NO_CORPSE or "*need fresh remains...*", 2, true)
        return false
    end
    local cx, cy, cz = corpse.Transform:GetWorldPosition()
    local corpse_prefab = corpse.prefab
    local minion = ShadowMinion.SpawnFromCorpse(owner, corpse_prefab, {x = cx, y = cy, z = cz})
    if minion then
        if corpse:IsValid() then
            corpse:Remove()
        end
        owner._shadow_minion_cooldown = GetTime() + ShadowMinion.COOLDOWN
        owner.components.talker:Say(STRINGS.KODI_SPEECH and STRINGS.KODI_SPEECH.MINION_RAISED or "*rise, shadow!*", 2, true)
        return true
    end
    owner.components.talker:Say(STRINGS.KODI_SPEECH and STRINGS.KODI_SPEECH.MINION_FAILED or "*the shadows reject this...*", 2, true)
    return false
end
function ShadowMinion.SetupPlayer(inst)
    inst._shadow_minion = nil
    inst._shadow_minion_cooldown = 0
    inst.DoRaiseShadowMinion = function(self)
        return ShadowMinion.TryRaise(self)
    end
    inst:ListenForEvent("death", function()
        if inst._shadow_minion and inst._shadow_minion:IsValid() then
            ShadowMinion.Despawn(inst._shadow_minion, inst, true)
        end
    end)
    inst:ListenForEvent("onremove", function()
        if inst._shadow_minion and inst._shadow_minion:IsValid() then
            inst._shadow_minion:Remove()
        end
    end)
end
return ShadowMinion
