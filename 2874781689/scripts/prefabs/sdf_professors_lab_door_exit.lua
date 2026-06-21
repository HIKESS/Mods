local assets = {Asset("ANIM", "anim/sdf_professors_lab_door_exit.zip")}

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
    hDc_M.components.sdf_professors_lab_teleporter:Activate(iD1IUx)
end

local function Vu0cCAf(JLCOx_ak, hPQ)
    if hPQ and hPQ:HasTag("player") then
        JLCOx_ak.components.sdf_professors_lab_teleporter:Activate(hPQ)
    end
end

local function q(inst)
    if inst.components.teleporter and inst.components.teleporter.targetTeleporter ~= nil then
        local NsoTwDs = inst.components.teleporter.targetTeleporter
        NsoTwDs.components.sdf_professors_lab_teleporter:Target(inst)
        inst.components.sdf_professors_lab_teleporter:Target(NsoTwDs)
        inst.components.teleporter:Target(nil)
        inst.components.teleporter:SetEnabled(false)
        if NsoTwDs.components.teleporter then
            NsoTwDs.components.teleporter:Target(nil)
            NsoTwDs.components.teleporter:SetEnabled(false)
        end
    end
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

    inst.Transform:SetScale(1.3, 1.3, 1.3) --1.5

    inst.AnimState:SetBank("sdf_professors_lab_door_exit")
    inst.AnimState:SetBuild("sdf_professors_lab_door_exit")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)

    isWet(inst)

    inst:AddTag("trader")
    inst:AddTag("alltrader")
    inst:AddTag("sdf_professors_lab_door")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("nonpackable")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable:RecordViews()

    inst:AddComponent("sdf_professors_lab_teleporter")
    inst.components.sdf_professors_lab_teleporter.onActivate = yxjl
    inst.components.sdf_professors_lab_teleporter.offset = 0
    inst.components.sdf_professors_lab_teleporter.travelcameratime = 1
    inst.components.sdf_professors_lab_teleporter.travelarrivetime = 0.5
    inst:ListenForEvent("doneteleporting", Are7xU)

    inst:AddComponent("inventory")

    inst:AddComponent("trader")
    inst.components.trader.acceptnontradable = true
    inst.components.trader.onaccept = onAccept
    inst.components.trader.deleteitemonaccept = false

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetOnHauntFn(Vu0cCAf)

    inst:DoTaskInTime(0.1, q)

    return inst
end

local function lqT(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    TheWorld.Map:CreateSDFProfessorsLab(x, z, inst)
end

local function onremove(inst)
    TheWorld.Map:RemoveSDFProfessorsLab(inst)
end

local function fnBase()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("NOCLICK")
    inst:AddTag("lightningrod")
    inst:AddTag("NOBLOCK")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("sdf_professors_lab_base")

    inst:DoTaskInTime(0, lqT)

    inst:ListenForEvent("onremove", onremove)

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

return Prefab("sdf_professors_lab_door_exit", fn, assets),
	Prefab("sdf_professors_lab_base", fnBase)
