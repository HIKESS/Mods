-- scripts/prefabs/npc_waxwell_magic_chest.lua
-- NPC 麦斯威尔专用魔术箱：外观参考原版，存储独立于原版 shadow 魔术箱。

require("prefabutil")
local Store = require("npc/npc_magic_chest_store")

local assets =
{
    Asset("ANIM", "anim/magician_chest.zip"),
    Asset("ANIM", "anim/ui_portal_shadow_3x4.zip"),
}

local prefabs =
{
    Store.STORE_PREFAB,
    "collapse_small",
}

local function AttachSharedContainer(inst)
    local master = Store.GetWorldContainer()
    if inst.components.container_proxy and master then
        inst.components.container_proxy:SetMaster(master)
    end
end

local function OnOpen(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("open")
        inst.AnimState:PushAnimation("loop")
        inst.SoundEmitter:PlaySound("maxwell_rework/magician_chest/open")
        inst.SoundEmitter:PlaySound("maxwell_rework/shadow_magic/storage_void_LP", "loop")
        inst.SoundEmitter:PlaySound("maxwell_rework/magician_chest/curtain_lp", "curtain_loop")
    end
end

local function OnClose(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("close")
        inst.AnimState:PushAnimation("closed", false)
        inst.SoundEmitter:PlaySound("maxwell_rework/magician_chest/close")
    end
    inst.SoundEmitter:KillSound("loop")
    inst.SoundEmitter:KillSound("curtain_loop")
end

local function OnBuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("closed", false)
    inst.SoundEmitter:PlaySound("maxwell_rework/magician_chest/place")
end

local function OnSave(inst, data)
    data.built_by_npc_waxwell = true
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.5)

    inst.MiniMapEntity:SetIcon("magician_chest.png")

    inst.AnimState:SetBank("magician_chest")
    inst.AnimState:SetBuild("magician_chest")
    inst.AnimState:PlayAnimation("closed")

    inst:AddTag("structure")
    inst:AddTag("chest")
    inst:AddTag("npc_waxwell_magic_chest")
    inst:AddTag("pocketdimension_container_proxy")

    inst:AddComponent("container_proxy")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst.components.container_proxy:SetOnOpenFn(OnOpen)
    inst.components.container_proxy:SetOnCloseFn(OnClose)
    AttachSharedContainer(inst)
    inst:DoTaskInTime(0, AttachSharedContainer)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(2)
    inst.components.workable:SetOnFinishCallback(function(chest, worker)
        chest.components.lootdropper:DropLoot()
        local fx = SpawnPrefab("collapse_small")
        if fx then
            fx.Transform:SetPosition(chest.Transform:GetWorldPosition())
            fx:SetMaterial("wood")
        end
        chest:Remove()
    end)
    inst.components.workable:SetOnWorkCallback(function(chest, worker)
        if chest.components.container_proxy then
            chest.components.container_proxy:Close()
        end
        chest.AnimState:PlayAnimation("hit")
        chest.AnimState:PushAnimation("closed", false)
    end)

    inst:AddComponent("lootdropper")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:ListenForEvent("onbuilt", OnBuilt)
    inst.OnSave = OnSave

    return inst
end

return Prefab("npc_waxwell_magic_chest", fn, assets, prefabs),
    MakePlacer("npc_waxwell_magic_chest_placer", "magician_chest", "magician_chest", "closed")
