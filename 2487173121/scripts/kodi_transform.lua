local KodiTransform = {}
local GLOBAL = nil
local STRINGS = nil
function KodiTransform.SetDependencies(deps)
    GLOBAL = deps.GLOBAL
    STRINGS = deps.STRINGS
end
local TRANSFORM_PURPLE_TINT = {0.15, 0, 1.0, 1}
function KodiTransform.SpawnEffects(inst, is_to_demon)
    local x, y, z = inst.Transform:GetWorldPosition()
    if is_to_demon then
        local shadow_fx = GLOBAL.SpawnPrefab("shadow_despawn")
        if shadow_fx then
            shadow_fx.Transform:SetPosition(x, y, z)
        end
        for i = 1, 8 do
            local angle = (i / 8) * 2 * math.pi
            local dist = 1.5
            local px, pz = x + math.cos(angle) * dist, z + math.sin(angle) * dist
            local particle = GLOBAL.SpawnPrefab("shadow_puff_large_front")
            if particle then
                particle.Transform:SetPosition(px, y, pz)
            end
        end
        local portal = GLOBAL.SpawnPrefab("wortox_portal_jumpout_fx")
        if portal then
            portal.Transform:SetPosition(x, y, z)
            if portal.AnimState then
                portal.AnimState:SetMultColour(TRANSFORM_PURPLE_TINT[1], TRANSFORM_PURPLE_TINT[2], TRANSFORM_PURPLE_TINT[3], TRANSFORM_PURPLE_TINT[4])
            end
        end
        local ground_fx = GLOBAL.SpawnPrefab("groundpoundring_fx")
        if ground_fx then
            ground_fx.Transform:SetPosition(x, y, z)
        end
        for i = 1, 3 do
            inst:DoTaskInTime(0.1 * i, function()
                local bird = GLOBAL.SpawnPrefab("crow")
                if bird then
                    local angle = math.random() * 2 * math.pi
                    bird.Transform:SetPosition(x + math.cos(angle) * 2, y, z + math.sin(angle) * 2)
                    if bird.sg and bird.sg:HasState("flyaway") then
                        bird.sg:GoToState("flyaway")
                    end
                end
            end)
        end
        inst.SoundEmitter:PlaySound("dontstarve/sanity/creature2/taunt")
        inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacle_attack")
        inst:DoTaskInTime(0.2, function()
            inst.SoundEmitter:PlaySound("dontstarve/sanity/creature1/taunt")
        end)
    else
        local shadow_fx = GLOBAL.SpawnPrefab("shadow_spawn")
        if shadow_fx then
            shadow_fx.Transform:SetPosition(x, y, z)
        end
        for i = 1, 6 do
            local angle = (i / 6) * 2 * math.pi
            local dist = 1
            local px, pz = x + math.cos(angle) * dist, z + math.sin(angle) * dist
            inst:DoTaskInTime(0.1 * i, function()
                local puff = GLOBAL.SpawnPrefab("shadow_puff")
                if puff then
                    puff.Transform:SetPosition(px, y + 0.5, pz)
                end
            end)
        end
        local portal = GLOBAL.SpawnPrefab("wortox_portal_jumpin_fx")
        if portal then
            portal.Transform:SetPosition(x, y, z)
            if portal.AnimState then
                portal.AnimState:SetMultColour(TRANSFORM_PURPLE_TINT[1], TRANSFORM_PURPLE_TINT[2], TRANSFORM_PURPLE_TINT[3], 0.8)
            end
        end
        local smoke = GLOBAL.SpawnPrefab("collapse_small")
        if smoke then
            smoke.Transform:SetPosition(x, y, z)
        end
        inst.SoundEmitter:PlaySound("dontstarve/sanity/creature1/die")
        inst:DoTaskInTime(0.3, function()
            inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
        end)
    end
end
function KodiTransform.Execute(inst)
    if not inst.sg then
        return false
    end
    if inst.sg:HasStateTag("busy") then
        return false
    end
    if not inst:HasTag("NotDemon") then
        if inst.sg:HasState("kodi_transform_from_demon") then
            inst.sg:GoToState("kodi_transform_from_demon")
        else
            if inst._kodi_do_transform_from_demon then
                inst:_kodi_do_transform_from_demon()
            end
        end
        return true
    elseif inst:HasTag("NotDemon") then
        if inst.CanTransform and not inst:CanTransform() then
            if inst.components.talker and STRINGS and STRINGS.KODI_SPEECH then
                inst.components.talker:Say(STRINGS.KODI_SPEECH.NEED_NIGHTMARE_FUEL, 2.5, true)
            end
            return false
        end
        if inst.sg:HasState("kodi_transform_to_demon") then
            inst.sg:GoToState("kodi_transform_to_demon")
        else
            if inst._kodi_do_transform_to_demon then
                inst:_kodi_do_transform_to_demon()
            end
        end
        return true
    end
    return false
end
function KodiTransform.RegisterControls(modname, AddModRPCHandler, GetModConfigData, SendModRPCToServer, MOD_RPC)
    AddModRPCHandler(modname, "KodiTransform", function(player)
        KodiTransform.Execute(player)
    end)
    GLOBAL.TheInput:AddKeyDownHandler(GetModConfigData("key_kodi"), function()
        if not GLOBAL.ThePlayer then
            return
        end
        if GLOBAL.ThePlayer.prefab ~= "kodi" then return end
        if GLOBAL.TheFrontEnd:GetActiveScreen() ~= GLOBAL.ThePlayer.HUD then return end
        if GLOBAL.TheNet:GetIsServer() then
            KodiTransform.Execute(GLOBAL.ThePlayer)
        else
            SendModRPCToServer(MOD_RPC[modname]["KodiTransform"])
        end
    end)
end
return KodiTransform
