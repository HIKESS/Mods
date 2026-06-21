local assets =
{
    Asset("ANIM", "anim/undead_armory.zip"),
    Asset("ATLAS", "images/inventoryimages/undead_armory_icon.xml"),
}

local prefabs =
{
    "collapse_small",
}

local function UpdateArmoryAnim(inst)
    if inst.components.container == nil then
        return
    end

    local basic_count = 0
    local fuel_count  = 0

    for i = 1, inst.components.container.numslots do
        local item = inst.components.container:GetItemInSlot(i)
        if item ~= nil then
            local stacksize = item.components.stackable ~= nil and item.components.stackable:StackSize() or 1
            if item.prefab == "flint" or item.prefab == "log" then
                basic_count = basic_count + stacksize
            elseif item.prefab == "nightmarefuel" then
                fuel_count = fuel_count + stacksize
            end
        end
    end

    local anim
    if basic_count == 0 and fuel_count == 0 then
        anim = "undead_armory0"
    elseif fuel_count > basic_count then
        anim = "undead_armory2"
    else
        anim = "undead_armory1"
    end

    if not inst.AnimState:IsCurrentAnimation(anim) then
        inst.AnimState:PlayAnimation(anim, true)
    end
end

local function onopen(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    UpdateArmoryAnim(inst)
end

local function onclose(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
    UpdateArmoryAnim(inst)
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
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
        inst.components.container:Close()
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

    inst.AnimState:SetBank("undead_armory")
    inst.AnimState:SetBuild("undead_armory")
    inst.AnimState:PlayAnimation("undead_armory0")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = function(inst)
            inst.replica.container:WidgetSetup("undead_armory")
        end
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("undead_armory")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({
        "cutstone", "cutstone",
        "boards", "boards",
        "boneshard", "boneshard", "boneshard", "boneshard", "boneshard", "boneshard",
        "marble", "marble",
    })

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    -- 初始化与周期刷新：根据容器内物品占比切换 idle 动画
    inst:DoTaskInTime(0, UpdateArmoryAnim)
    inst:DoPeriodicTask(1, UpdateArmoryAnim)

    return inst
end

return Prefab("undead_armory", fn, assets, prefabs),
       MakePlacer("undead_armory_placer", "undead_armory", "undead_armory", "undead_armory0")
