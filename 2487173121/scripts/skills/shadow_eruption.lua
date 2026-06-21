local KodiUtils = require("kodi_utils")
local ShadowEruption = {}
ShadowEruption.RADIUS = 12
ShadowEruption.STUN_TIME = 2
ShadowEruption.DAMAGE = 30
ShadowEruption.SPIKE_DAMAGE = 20
ShadowEruption.DOT_DAMAGE = 5
ShadowEruption.DOT_DURATION = 10
ShadowEruption.ENERGY_COST = 30
ShadowEruption.COOLDOWN = 20
ShadowEruption.KNOCKBACK = 3
local function CreateBlackFireFX(enemy)
    local fire_fx = SpawnPrefab("character_fire")
    if fire_fx then
        fire_fx.entity:SetParent(enemy.entity)
        fire_fx.Transform:SetPosition(0, 0.5, 0)
        if fire_fx.components.firefx then
            fire_fx.components.firefx:SetLevel(2, true)
        end
        if fire_fx.AnimState then
            fire_fx.AnimState:SetMultColour(0.1, 0.1, 0.1, 1)
        end
        if fire_fx.components.firefx and fire_fx.components.firefx.light then
            local light = fire_fx.components.firefx.light
            if light.Light then
                light.Light:Enable(false)
                light.Light:SetRadius(0)
                light.Light:SetIntensity(0)
            end
            if light.AnimState then
                light.AnimState:SetMultColour(0, 0, 0, 0)
            end
        end
        if fire_fx.components.heater then
            fire_fx:RemoveComponent("heater")
        end
        return fire_fx
    end
    return nil
end
function ShadowEruption.ApplyBlackFlame(enemy, duration, damage_per_tick, attacker)
    if not enemy or not enemy:IsValid() then return end
    if enemy._kodi_black_flame_active then return end
    enemy._kodi_black_flame_active = true
    local fire_visual = CreateBlackFireFX(enemy)
    if enemy.components.health then
        enemy.components.health.takingfiredamage = true
    end
    local shadow_fx = SpawnPrefab("shadow_despawn")
    if shadow_fx then
        local ex, ey, ez = enemy.Transform:GetWorldPosition()
        shadow_fx.Transform:SetPosition(ex, ey, ez)
    end
    local dot_ticks = math.floor(duration)
    local current_tick = 0
    local function CleanupFlame()
        enemy._kodi_black_flame_active = nil
        if enemy:IsValid() and enemy.components.health then
            enemy.components.health.takingfiredamage = false
        end
        if fire_visual and fire_visual:IsValid() then
            fire_visual:Remove()
        end
        if enemy._kodi_black_flame_task then
            enemy._kodi_black_flame_task:Cancel()
            enemy._kodi_black_flame_task = nil
        end
    end
    enemy._kodi_black_flame_task = enemy:DoPeriodicTask(1, function()
        current_tick = current_tick + 1
        if current_tick > dot_ticks then
            CleanupFlame()
            return
        end
        if not enemy:IsValid() or not enemy.components.health or enemy.components.health:IsDead() then
            CleanupFlame()
            return
        end
        local tick_fx = SpawnPrefab("shadow_glob_fx")
        if tick_fx then
            local ex, ey, ez = enemy.Transform:GetWorldPosition()
            tick_fx.Transform:SetPosition(ex, ey, ez)
        end
        if enemy.components.health then
            enemy.components.health:DoDelta(-damage_per_tick)
        end
    end)
    enemy:ListenForEvent("death", function()
        enemy._kodi_black_flame_active = nil
        if enemy.components.health then
            enemy.components.health.takingfiredamage = false
        end
        if fire_visual and fire_visual:IsValid() then
            fire_visual:Remove()
        end
        if enemy._kodi_black_flame_task then
            enemy._kodi_black_flame_task:Cancel()
            enemy._kodi_black_flame_task = nil
        end
    end)
end
function ShadowEruption.Knockback(enemy, from_x, from_z, distance)
    if not enemy or not enemy:IsValid() then return end
    if not enemy.Physics then return end
    local ex, ey, ez = enemy.Transform:GetWorldPosition()
    local dx, dz = ex - from_x, ez - from_z
    local dist = math.sqrt(dx * dx + dz * dz)
    if dist > 0 then
        local nx, nz = dx / dist, dz / dist
        local new_x = ex + nx * distance
        local new_z = ez + nz * distance
        if KodiUtils.IsPassableAt(new_x, 0, new_z) then
            enemy.Physics:Teleport(new_x, ey, new_z)
        end
    end
end
function ShadowEruption.Use(inst)
    if not inst:HasTag("kodi_shadow_eruption") then return false end
    if inst:HasTag("NotDemon") then
        inst.components.talker:Say(STRINGS.KODI_SPEECH.ERUPTION_ONLY_DEMON, 2, true)
        return false
    end
    if inst._shadow_eruption_cooldown then
        inst.components.talker:Say(STRINGS.KODI_SPEECH.ERUPTION_NOT_READY, 2, true)
        return false
    end
    if inst.demonic_energy and inst.demonic_energy < ShadowEruption.ENERGY_COST then
        inst.components.talker:Say(STRINGS.KODI_SPEECH.ERUPTION_NO_ENERGY, 2, true)
        return false
    end
    if inst.demonic_energy then
        inst.demonic_energy = math.max(0, inst.demonic_energy - ShadowEruption.ENERGY_COST)
        inst:UpdateDemonicNetvar()
        inst:PushEvent("demonic_energy_changed", {percent = inst:GetDemonicPercent()})
    end
    inst._shadow_eruption_cooldown = true
    inst._shadow_eruption_cooldown_time = GetTime()
    inst:DoTaskInTime(ShadowEruption.COOLDOWN, function()
        inst._shadow_eruption_cooldown = false
    end)
    local x, y, z = inst.Transform:GetWorldPosition()
    local enemies = TheSim:FindEntities(x, y, z, ShadowEruption.RADIUS,
        {"_health"},
        {"player", "companion", "wall", "structure", "INLIMBO", "ghost"}
    )
    ShadowEruption.SpawnCasterEffects(inst, x, y, z)
    for _, enemy in ipairs(enemies) do
        if enemy and enemy:IsValid() and enemy.components.health and not enemy.components.health:IsDead() then
            ShadowEruption.ProcessEnemy(inst, enemy, x, z)
        end
    end
    return true
end
function ShadowEruption.ProcessEnemy(inst, enemy, x, z)
    local ex, ey, ez = enemy.Transform:GetWorldPosition()
    ShadowEruption.SpawnTrail(inst, x, z, ex, ez)
    local chain_fx = SpawnPrefab("shadow_shield" .. tostring(math.random(1, 3)))
    if chain_fx then
        chain_fx.entity:SetParent(enemy.entity)
    end
    ShadowEruption.SpawnSpike(inst, ex, ez)
    ShadowEruption.Knockback(enemy, x, z, ShadowEruption.KNOCKBACK)
    ShadowEruption.ApplyBlackFlame(enemy, ShadowEruption.DOT_DURATION, ShadowEruption.DOT_DAMAGE, inst)
    if enemy.components.combat then
        enemy.components.combat:GetAttacked(inst, ShadowEruption.DAMAGE)
    else
        enemy.components.health:DoDelta(-ShadowEruption.DAMAGE)
    end
    if enemy.components.locomotor then
        enemy.components.locomotor:Stop()
        enemy:AddTag("kodi_stunned")
    end
    if enemy.components.combat then
        enemy.components.combat:SetTarget(nil)
    end
    inst:DoTaskInTime(ShadowEruption.STUN_TIME, function()
        if enemy:IsValid() and enemy.components.health and not enemy.components.health:IsDead() then
            enemy:RemoveTag("kodi_stunned")
            if enemy.components.combat then
                enemy.components.combat:GetAttacked(inst, ShadowEruption.DAMAGE)
            else
                enemy.components.health:DoDelta(-ShadowEruption.DAMAGE)
            end
        end
    end)
end
function ShadowEruption.SpawnCasterEffects(inst, x, y, z)
    local wave_fx = SpawnPrefab("groundpoundring_fx")
    if wave_fx then wave_fx.Transform:SetPosition(x, y, z) end
    for i = 1, 3 do
        inst:DoTaskInTime(i * 0.15, function()
            if inst:IsValid() then
                local shield_fx = SpawnPrefab("shadow_shield" .. tostring(math.random(1, 3)))
                if shield_fx then
                    shield_fx.entity:SetParent(inst.entity)
                end
            end
        end)
    end
    local shadow_fx = SpawnPrefab("shadow_teleport_in")
    if shadow_fx then shadow_fx.Transform:SetPosition(x, y, z) end
    inst:ShakeCamera(CAMERASHAKE.FULL, 1.0, 0.03, 0.5)
    inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacle_attack")
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/fossil_spike")
end
function ShadowEruption.SpawnTrail(inst, from_x, from_z, to_x, to_z)
    local dx = to_x - from_x
    local dz = to_z - from_z
    local dist = math.sqrt(dx * dx + dz * dz)
    if dist < 1 then return end
    local steps = math.floor(dist / 1.5)
    for i = 1, steps do
        local t = i / (steps + 1)
        local px = from_x + dx * t
        local pz = from_z + dz * t
        inst:DoTaskInTime(i * 0.05, function()
            local trail_fx = SpawnPrefab("shadow_glob_fx")
            if trail_fx then trail_fx.Transform:SetPosition(px, 0, pz) end
            local ground_fx = SpawnPrefab("statue_transition_2")
            if ground_fx then
                ground_fx.Transform:SetPosition(px, 0, pz)
                ground_fx.Transform:SetScale(0.5, 0.5, 0.5)
            end
        end)
    end
end
function ShadowEruption.SpawnSpike(inst, ex, ez)
    local spike = SpawnPrefab("fossilspike")
    if spike then
        spike.Transform:SetPosition(ex, 0, ez)
        spike.AnimState:SetMultColour(0.1, 0.1, 0.1, 1)
        if spike.components.combat then
            local spike_owner = inst
            local old_cantarget = spike.components.combat.CanTarget
            spike.components.combat.CanTarget = function(combat_self, targ)
                if targ then
                    if targ == spike_owner then return false end
                    if targ.components.follower and targ.components.follower:GetLeader() == spike_owner then return false end
                    if (targ:HasTag("chester") or targ:HasTag("hutch")) and targ.components.follower then
                        local leader = targ.components.follower:GetLeader()
                        if leader and leader.components.leader and leader.components.leader:IsFollower(spike_owner) then return false end
                    end
                end
                return old_cantarget and old_cantarget(combat_self, targ) or true
            end
        end
    end
end
function ShadowEruption.SetupPlayer(inst)
    inst._shadow_eruption_cooldown = false
    inst._shadow_eruption_cooldown_time = 0
    inst.UseShadowEruption = function(self) return ShadowEruption.Use(self) end
    inst.GetShadowEruptionCooldown = function(self)
        if not self._shadow_eruption_cooldown then return 0 end
        local remaining = ShadowEruption.COOLDOWN - (GetTime() - self._shadow_eruption_cooldown_time)
        return math.max(0, remaining)
    end
end
return ShadowEruption
