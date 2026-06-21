local KodiStategraphs = {}
local GLOBAL = nil
local KodiTransformModule = nil
function KodiStategraphs.SetDependencies(deps)
    GLOBAL = deps.GLOBAL
    KodiTransformModule = deps.KodiTransformModule
end
local function SpawnTransformEffects(inst, is_to_demon)
    if KodiTransformModule and KodiTransformModule.SpawnEffects then
        KodiTransformModule.SpawnEffects(inst, is_to_demon)
    end
end
local function CreateTransformToDemonState()
    return GLOBAL.State {
        name = "kodi_transform_to_demon",
        tags = { "doing", "busy", "nopredict", "nomorph", "noelectrocute" },
        onenter = function(inst)
            if inst.components and inst.components.locomotor then
                inst.components.locomotor:Stop()
                inst.components.locomotor:Clear()
            end
            if inst.components and inst.components.playercontroller then
                inst.components.playercontroller:RemotePausePrediction()
            end
            inst.AnimState:PlayAnimation("shock")
            inst.AnimState:PushAnimation("shock_pst", false)
            if GLOBAL.TheWorld.ismastersim then
                local x, y, z = inst.Transform:GetWorldPosition()
                local lightning = GLOBAL.SpawnPrefab("lightning")
                if lightning then
                    lightning.Transform:SetPosition(x, y, z)
                end
            end
            inst._kodi_shock_fx = GLOBAL.SpawnPrefab("shock_fx")
            if inst._kodi_shock_fx then
                inst._kodi_shock_fx.entity:SetParent(inst.entity)
                inst._kodi_shock_fx.entity:AddFollower()
                inst._kodi_shock_fx.Follower:FollowSymbol(inst.GUID, "swap_shock_fx", 0, 0, 0)
            end
            if inst.components and inst.components.bloomer then
                inst.components.bloomer:PushBloom("kodi_transform", "shaders/anim.ksh", -2)
            end
            if inst.Light then
                inst.Light:Enable(true)
            end
            inst.SoundEmitter:PlaySound("dontstarve/rain/thunder_close")
        end,
        timeline = {
            GLOBAL.TimeEvent(2 * GLOBAL.FRAMES, function(inst)
                local shield1 = GLOBAL.SpawnPrefab("shadow_shield3")
                if shield1 then
                    shield1.entity:SetParent(inst.entity)
                end
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hit_scalemail")
            end),
            GLOBAL.TimeEvent(5 * GLOBAL.FRAMES, function(inst)
                if not GLOBAL.TheWorld.ismastersim then return end
                local x, y, z = inst.Transform:GetWorldPosition()
                local ring = GLOBAL.SpawnPrefab("groundpoundring_fx")
                if ring then
                    ring.Transform:SetPosition(x, y, z)
                end
                for i = 1, 6 do
                    local angle = (i / 6) * 2 * math.pi
                    local px, pz = x + math.cos(angle) * 1.2, z + math.sin(angle) * 1.2
                    local puff = GLOBAL.SpawnPrefab("shadow_puff_large_front")
                    if puff then
                        puff.Transform:SetPosition(px, y, pz)
                    end
                end
            end),
            GLOBAL.TimeEvent(8 * GLOBAL.FRAMES, function(inst)
                local shield2 = GLOBAL.SpawnPrefab("shadow_shield6")
                if shield2 then
                    shield2.entity:SetParent(inst.entity)
                end
            end),
            GLOBAL.TimeEvent(12 * GLOBAL.FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacle_attack")
                if inst._kodi_do_transform_to_demon then
                    inst:_kodi_do_transform_to_demon()
                end
            end),
            GLOBAL.TimeEvent(15 * GLOBAL.FRAMES, function(inst)
                if not GLOBAL.TheWorld.ismastersim then return end
                local x, y, z = inst.Transform:GetWorldPosition()
                local shadow = GLOBAL.SpawnPrefab("shadow_despawn")
                if shadow then
                    shadow.Transform:SetPosition(x, y, z)
                end
            end),
        },
        events = {
            GLOBAL.EventHandler("animover", function(inst)
                if inst._kodi_shock_fx then
                    inst._kodi_shock_fx:Remove()
                    inst._kodi_shock_fx = nil
                end
                if inst.components and inst.components.bloomer then
                    inst.components.bloomer:PopBloom("kodi_transform")
                end
                if inst.Light then
                    inst.Light:Enable(false)
                end
            end),
            GLOBAL.EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.components and inst.components.playercontroller then
                        inst.components.playercontroller:Enable(true)
                    end
                    inst.sg:GoToState("idle")
                end
            end),
        },
        onexit = function(inst)
            if inst._kodi_shock_fx then
                inst._kodi_shock_fx:Remove()
                inst._kodi_shock_fx = nil
            end
            if inst.components and inst.components.bloomer then
                inst.components.bloomer:PopBloom("kodi_transform")
            end
            if inst.Light then
                inst.Light:Enable(false)
            end
            if inst.components and inst.components.playercontroller then
                inst.components.playercontroller:Enable(true)
            end
        end,
    }
end
local function CreateTransformFromDemonState()
    return GLOBAL.State {
        name = "kodi_transform_from_demon",
        tags = { "busy", "pausepredict", "nomorph", "nodangle" },
        onenter = function(inst)
            if inst.Physics then
                inst.Physics:Stop()
            end
            inst.AnimState:PlayAnimation("powerdown")
            if inst.components and inst.components.playercontroller then
                inst.components.playercontroller:RemotePausePrediction()
            end
            inst.SoundEmitter:PlaySound("dontstarve/sanity/creature1/die")
        end,
        timeline = {
            GLOBAL.TimeEvent(5 * GLOBAL.FRAMES, function(inst)
                if not GLOBAL.TheWorld.ismastersim then return end
                local x, y, z = inst.Transform:GetWorldPosition()
                for i = 1, 4 do
                    local angle = (i / 4) * 2 * math.pi
                    local px, pz = x + math.cos(angle) * 0.6, z + math.sin(angle) * 0.6
                    local puff = GLOBAL.SpawnPrefab("shadow_puff")
                    if puff then
                        puff.Transform:SetPosition(px, y + 0.5, pz)
                    end
                end
            end),
            GLOBAL.TimeEvent(15 * GLOBAL.FRAMES, function(inst)
                if inst._kodi_do_transform_from_demon then
                    inst:_kodi_do_transform_from_demon()
                end
            end),
            GLOBAL.TimeEvent(25 * GLOBAL.FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
                if not GLOBAL.TheWorld.ismastersim then return end
                local x, y, z = inst.Transform:GetWorldPosition()
                local smoke = GLOBAL.SpawnPrefab("collapse_small")
                if smoke then
                    smoke.Transform:SetPosition(x, y, z)
                end
            end),
        },
        events = {
            GLOBAL.EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    }
end
function KodiStategraphs.Register(AddStategraphState)
    local transform_to_demon = CreateTransformToDemonState()
    local transform_from_demon = CreateTransformFromDemonState()
    AddStategraphState("wilson", transform_to_demon)
    AddStategraphState("wilson_client", transform_to_demon)
    AddStategraphState("wilson", transform_from_demon)
    AddStategraphState("wilson_client", transform_from_demon)
end
return KodiStategraphs
