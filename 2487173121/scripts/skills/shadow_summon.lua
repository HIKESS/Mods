local SendModRPCToClient = SendModRPCToClient
local GetClientModRPC = GetClientModRPC
local ShadowSummon = {}
local SUMMON_COST_ENERGY = 20
local SUMMON_COST_HP = 10
local MAX_TERRORBEAKS = 2
local DEMON_FORM_EXTRA_DRAIN = 0.5
local SUMMON_COOLDOWN = 60
function ShadowSummon.HasShadows(inst)
    if not inst or not inst:IsValid() then return false end
    if not inst.components.petleash then return false end
    return inst.components.petleash:GetNumPets() > 0
end
function ShadowSummon.CountShadows(inst)
    if not inst or not inst:IsValid() then return 0 end
    if not inst.components.petleash then return 0 end
    return inst.components.petleash:GetNumPets()
end
function ShadowSummon.DespawnShadows(inst)
    if not inst or not inst:IsValid() then return end
    if not inst.components.petleash then return end
    local pets = inst.components.petleash:GetPets()
    if pets then
        for k, pet in pairs(pets) do
            if pet and pet:IsValid() then
                local x, y, z = pet.Transform:GetWorldPosition()
                local fx = SpawnPrefab("shadow_despawn")
                if fx then
                    fx.Transform:SetPosition(x, y, z)
                end
                pet:Remove()
            end
        end
    end
    if inst._shadow_summon_drain_task then
        inst._shadow_summon_drain_task:Cancel()
        inst._shadow_summon_drain_task = nil
    end
    inst._shadow_summon_extra_drain = false
    if inst.components.talker then
        inst.components.talker:Say(STRINGS.KODI_SPEECH.SHADOW_SUMMON_DESPAWN or "*shadows return to the void*", 2, true)
    end
end
local function ApplyDemonDrain(inst)
    if inst._shadow_summon_extra_drain then return end
    inst._shadow_summon_extra_drain = true
end
local function RemoveDemonDrain(inst)
    inst._shadow_summon_extra_drain = false
end
function ShadowSummon.OnFormChanged(inst)
    if not ShadowSummon.HasShadows(inst) then return end
    local is_demon = not inst:HasTag("NotDemon")
    local pets = inst.components.petleash and inst.components.petleash:GetPets()
    if pets then
        for k, pet in pairs(pets) do
            if pet and pet:IsValid() and pet.UpdateForOwnerForm then
                pet:UpdateForOwnerForm(is_demon)
            end
        end
    end
    if is_demon then
        ApplyDemonDrain(inst)
    else
        RemoveDemonDrain(inst)
    end
end
function ShadowSummon.SummonShadows(inst)
    if not inst or not inst:IsValid() then return false end
    if ShadowSummon.HasShadows(inst) then
        ShadowSummon.DespawnShadows(inst)
        return true
    end
    if inst._shadow_summon_cooldown and inst._shadow_summon_cooldown > GetTime() then
        local remaining = math.ceil(inst._shadow_summon_cooldown - GetTime())
        if inst.components.talker then
            inst.components.talker:Say(string.format("*shadows need %d seconds to recover*", remaining), 2, true)
        end
        return false
    end
    if not inst:HasTag("kodi_shadow_summon") then
        if inst.components.talker then
            inst.components.talker:Say("*I haven't learned this yet*", 2, true)
        end
        return false
    end
    local energy = inst.demonic_energy or 0
    if energy < SUMMON_COST_ENERGY then
        if inst.components.talker then
            inst.components.talker:Say(STRINGS.KODI_SPEECH.SHADOW_SUMMON_NO_ENERGY or "*not enough shadow energy*", 2, true)
        end
        return false
    end
    if inst.components.health then
        local current_hp = inst.components.health.currenthealth
        if current_hp <= SUMMON_COST_HP then
            if inst.components.talker then
                inst.components.talker:Say(STRINGS.KODI_SPEECH.SHADOW_SUMMON_NO_HP or "*too weak to summon*", 2, true)
            end
            return false
        end
    end
    inst.demonic_energy = math.max(0, inst.demonic_energy - SUMMON_COST_ENERGY)
    if inst.UpdateDemonicNetvar then
        inst:UpdateDemonicNetvar()
    end
    inst:PushEvent("demonic_energy_changed", {percent = inst:GetDemonicPercent()})
    if inst.components.health then
        inst.components.health:DoDelta(-SUMMON_COST_HP, false, "shadow_summon")
    end
    local px, py, pz = inst.Transform:GetWorldPosition()
    local is_demon = not inst:HasTag("NotDemon")
    inst.SoundEmitter:PlaySound("dontstarve/common/together/skin_unveil")
    inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowhand_extend")
    if inst.ShakeCamera then
        inst:ShakeCamera(CAMERASHAKE.VERTICAL, 0.5, 0.02, 0.3)
    end
    local burst = SpawnPrefab("statue_transition_2")
    if burst then
        burst.Transform:SetPosition(px, py, pz)
    end
    local ring_radius = 1.5
    for i = 1, 8 do
        local ring_angle = (i / 8) * 2 * math.pi
        local ring_x = px + math.cos(ring_angle) * ring_radius
        local ring_z = pz + math.sin(ring_angle) * ring_radius
        inst:DoTaskInTime(i * 0.05, function()
            local puff = SpawnPrefab("shadow_puff")
            if puff then
                puff.Transform:SetPosition(ring_x, py, ring_z)
            end
        end)
    end
    local crack = SpawnPrefab("groundpoundring_fx")
    if crack then
        crack.Transform:SetPosition(px, py, pz)
        crack.Transform:SetScale(0.5, 0.5, 0.5)
    end
    local spawn_positions = {}
    for i = 1, MAX_TERRORBEAKS do
        local base_angle = ((i - 1) / MAX_TERRORBEAKS) * 2 * math.pi + math.random() * 0.3
        local offset = 2.5 + math.random() * 0.5
        spawn_positions[i] = {
            x = px + math.cos(base_angle) * offset,
            z = pz + math.sin(base_angle) * offset,
            angle = base_angle
        }
    end
    for i, pos in ipairs(spawn_positions) do
        local steps = 4
        for step = 1, steps do
            local t = step / steps
            local trail_x = px + (pos.x - px) * t
            local trail_z = pz + (pos.z - pz) * t
            inst:DoTaskInTime(0.3 + step * 0.08, function()
                local trail = SpawnPrefab("shadow_puff")
                if trail then
                    trail.Transform:SetPosition(trail_x, py, trail_z)
                    trail.Transform:SetScale(0.6 + t * 0.4, 0.6 + t * 0.4, 0.6 + t * 0.4)
                end
            end)
        end
    end
    for i, pos in ipairs(spawn_positions) do
        inst:DoTaskInTime(0.6 + (i - 1) * 0.3, function()
            if not inst:IsValid() then return end
            local crack = SpawnPrefab("nightmare_crack_fx")
            if crack then
                crack.Transform:SetPosition(pos.x, py, pos.z)
            end
            local pre_fx = SpawnPrefab("shadow_despawn")
            if pre_fx then
                pre_fx.Transform:SetPosition(pos.x, py, pos.z)
            end
            inst.SoundEmitter:PlaySound("dontstarve/sanity/creature2/appear")
            local terrorbeak = nil
            if inst.components.petleash then
                terrorbeak = inst.components.petleash:SpawnPetAt(pos.x, 0, pos.z, "shadow_terrorbeak")
            else
                terrorbeak = SpawnPrefab("shadow_terrorbeak")
                if terrorbeak then
                    terrorbeak.Transform:SetPosition(pos.x, 0, pos.z)
                    if terrorbeak.SetOwner then
                        terrorbeak:SetOwner(inst)
                    end
                end
            end
            if terrorbeak then
                if terrorbeak.UpdateForOwnerForm then
                    terrorbeak:UpdateForOwnerForm(is_demon)
                end
                local spawn_burst = SpawnPrefab("statue_transition")
                if spawn_burst then
                    spawn_burst.Transform:SetPosition(pos.x, py, pos.z)
                end
                for j = 1, 4 do
                    local puff_angle = math.random() * 2 * math.pi
                    local puff_dist = 0.5 + math.random() * 0.5
                    local puff = SpawnPrefab("shadow_puff")
                    if puff then
                        puff.Transform:SetPosition(
                            pos.x + math.cos(puff_angle) * puff_dist,
                            py,
                            pos.z + math.sin(puff_angle) * puff_dist
                        )
                    end
                end
            end
        end)
    end
    inst:DoTaskInTime(0.6 + MAX_TERRORBEAKS * 0.3 + 0.2, function()
        if not inst:IsValid() then return end
        inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowhand_grab")
        if is_demon then
            ApplyDemonDrain(inst)
        end
    end)
    inst._shadow_summon_cooldown = GetTime() + SUMMON_COOLDOWN
    if inst.userid and ShadowSummon.MODNAME then
        local rpc = GetClientModRPC(ShadowSummon.MODNAME, "ShadowSummonCooldownSync")
        if rpc then
            SendModRPCToClient(rpc, inst.userid, SUMMON_COOLDOWN)
        end
    end
    if inst.components.talker then
        inst.components.talker:Say(STRINGS.KODI_SPEECH.SHADOW_SUMMON_SUCCESS or "*rise, my shadows!*", 2, true)
    end
    return true
end
function ShadowSummon.GetExtraDrainMultiplier(inst)
    if inst._shadow_summon_extra_drain then
        return DEMON_FORM_EXTRA_DRAIN
    end
    return 0
end
function ShadowSummon.GetCooldownRemaining(inst)
    if not inst._shadow_summon_cooldown then return 0 end
    local remaining = inst._shadow_summon_cooldown - GetTime()
    return remaining > 0 and remaining or 0
end
function ShadowSummon.SetupPlayer(inst)
    inst.ShadowSummonToggle = function(self)
        ShadowSummon.SummonShadows(self)
    end
    inst:ListenForEvent("kodi_form_changed", function()
        ShadowSummon.OnFormChanged(inst)
    end)
    inst:ListenForEvent("death", function()
        ShadowSummon.DespawnShadows(inst)
    end)
end
return ShadowSummon
