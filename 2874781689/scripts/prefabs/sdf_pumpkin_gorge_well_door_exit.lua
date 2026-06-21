local assets = {
    Asset("ANIM", "anim/sdf_pumpkin_gorge_well_door_exit.zip")
}

local function isWet(inst)
    inst.GetIsWet = function(...)
        return false
    end
end

local function Are7xU(a, wqU76o)
    if wqU76o ~= nil and wqU76o:HasTag("player") then
    end
end

local function yxjl(LB1Z, N9L)
    if N9L:HasTag("player") then
    elseif LB1Z.SoundEmitter ~= nil then
        LB1Z.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
    end
end

local function onAccept(hDc_M, qW0lRiD1, iD1IUx)
    hDc_M.components.inventory:DropItem(iD1IUx)
    hDc_M.components.sdf_pumpkin_gorge_well_teleporter:Activate(iD1IUx)
end

local function Vu0cCAf(JLCOx_ak, hPQ)
    if hPQ and hPQ:HasTag("player") then
        JLCOx_ak.components.sdf_pumpkin_gorge_well_teleporter:Activate(hPQ)
    end
end

local function OnSnowLevel(inst, snowlevel)
    if snowlevel >= .01 then
        if not inst.frozen then
            inst.frozen = true

	    --add frost
	    inst.components.colouradder:PushColour("frost", 82 / 255, 115 / 255, 124 / 255, 0)
        end
    elseif inst.frozen then
        inst.frozen = false

	--remove frost
	inst.components.colouradder:PopColour("frost")
    elseif inst.frozen == nil then
        inst.frozen = false

	--remove frost
	inst.components.colouradder:PopColour("frost")
    elseif inst.frozen == false then

	--remove frost
	inst.components.colouradder:PopColour("frost")
    end
end

local function q(inst)
    if inst.components.teleporter and inst.components.teleporter.targetTeleporter ~= nil then
        local NsoTwDs = inst.components.teleporter.targetTeleporter
        NsoTwDs.components.sdf_pumpkin_gorge_well_teleporter:Target(inst)
        inst.components.sdf_pumpkin_gorge_well_teleporter:Target(NsoTwDs)
        inst.components.teleporter:Target(nil)
        inst.components.teleporter:SetEnabled(false)
        if NsoTwDs.components.teleporter then
            NsoTwDs.components.teleporter:Target(nil)
            NsoTwDs.components.teleporter:SetEnabled(false)
        end
    end

    inst.task = nil
    inst:WatchWorldState("snowlevel", OnSnowLevel)
    OnSnowLevel(inst, TheWorld.state.snowlevel)
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddPhysics()

    inst.Physics:ClearCollisionMask()
    inst.Physics:SetSphere(1)

    inst.Transform:SetScale(1, 1.7, 1) --1.5

    inst.AnimState:SetBank("sdf_pumpkin_gorge_well_door_exit")
    inst.AnimState:SetBuild("sdf_pumpkin_gorge_well_door_exit")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)

    isWet(inst)

    inst:AddTag("trader")
    inst:AddTag("alltrader")
    inst:AddTag("sdf_pumpkin_gorge_well_door")
    inst:AddTag("sdf_pumpkin_gorge_well_door_exit")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("nonpackable")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable:RecordViews()

    inst:AddComponent("sdf_pumpkin_gorge_well_teleporter")
    inst.components.sdf_pumpkin_gorge_well_teleporter.onActivate = yxjl
    inst.components.sdf_pumpkin_gorge_well_teleporter.offset = 0
    inst.components.sdf_pumpkin_gorge_well_teleporter.travelcameratime = 1
    inst.components.sdf_pumpkin_gorge_well_teleporter.travelarrivetime = 0.5
    inst:ListenForEvent("doneteleporting", Are7xU)

    inst:AddComponent("inventory")

    inst:AddComponent("trader")
    inst.components.trader.acceptnontradable = true
    inst.components.trader.onaccept = onAccept
    inst.components.trader.deleteitemonaccept = false

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetOnHauntFn(Vu0cCAf)

    inst:AddComponent("colouradder")

    inst:DoTaskInTime(0.1, q)

    return inst
end

local function lqT(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    TheWorld.Map:CreateSDFPumpkinGorgeWell(x, z, inst)
end

local function onremove(inst)
    TheWorld.Map:RemoveSDFPumpkinGorgeWell(inst)
end

local function fnBase()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("NOCLICK")
    inst:AddTag("lightningrod")
    inst:AddTag("NOBLOCK")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("sdf_pumpkin_gorge_well_base")

    inst:DoTaskInTime(0, lqT)

    inst:ListenForEvent("onremove", onremove)

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

return Prefab("sdf_pumpkin_gorge_well_door_exit", fn, assets),
	Prefab("sdf_pumpkin_gorge_well_base", fnBase)
