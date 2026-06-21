local assets =
{
    Asset("ANIM", "anim/skull_chest.zip"),
    Asset("ATLAS", "images/inventoryimages/wiltonmod_chest.xml"),
    Asset("ATLAS", "images/inventoryimages/skeleton.xml"),
    Asset("ATLAS", "images/inventoryimages/sturdyskeleton.xml"),   
}

local prefabs =
{
    "collapse_small",
}


local function onopen(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("open")
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    end
end

local function onclose(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("close")
        inst.AnimState:PushAnimation("closed", false)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("closed", false)

    inst.SoundEmitter:PlaySound("dontstarve/common/sign_craft")
end

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        if inst.components.container ~= nil then
            inst.components.container:DropEverything()
            inst.components.container:Close()
        end
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("closed", false)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst:AddTag("structure")
    inst:AddTag("chest")

    inst.AnimState:SetBank("skull_chest")
    inst.AnimState:SetBuild("skull_chest")
    inst.AnimState:PlayAnimation("closed")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = function(inst) 
            inst.replica.container:WidgetSetup("treasurechest") 
        end
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("treasurechest")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    inst:AddComponent("preserver")
    inst.components.preserver.perish_rate_multiplier = 10

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(2)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    return inst
end

return Prefab("wiltonmod_chest", fn, assets, prefabs),
       MakePlacer("wiltonmod_chest_placer", "skull_chest", "skull_chest", "closed")
