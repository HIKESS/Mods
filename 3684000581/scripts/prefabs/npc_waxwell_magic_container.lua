-- scripts/prefabs/npc_waxwell_magic_container.lua
-- 隐藏的麦斯威尔 NPC 魔术箱共享容器，供实体箱子通过 container_proxy 访问。

local Store = require("npc/npc_magic_chest_store")
local containers = require("containers")


if containers.params ~= nil
    and containers.params[Store.STORE_PREFAB] == nil
    and containers.params.shadow_container ~= nil then
    containers.params[Store.STORE_PREFAB] = deepcopy(containers.params.shadow_container)
end

local assets =
{
    Asset("ANIM", "anim/ui_portal_shadow_3x4.zip"),
    Asset("SCRIPT", "scripts/containers.lua"),
}

local function OnAnyOpenStorage(inst, data)
    if inst.components.container.opencount > 1 then
        inst.Network:SetClassifiedTarget(nil)
    else
        inst.Network:SetClassifiedTarget(data and data.doer or nil)
    end
    Store.RequestPeerSync()
end

local function OnAnyCloseStorage(inst)
    local opencount = inst.components.container.opencount
    if opencount == 0 then
        inst.Network:SetClassifiedTarget(inst)
        Store.SaveAndBroadcast()
    elseif opencount == 1 then
        local opener = next(inst.components.container.openlist)
        inst.Network:SetClassifiedTarget(opener)
    end
end

local function fn()
    local inst = CreateEntity()

    if TheWorld.ismastersim then
        inst.entity:AddTransform()
    end
    inst.entity:AddNetwork()
    inst.entity:AddServerNonSleepable()
    inst.entity:SetCanSleep(false)
    inst.entity:Hide()
    inst.persists = false

    inst:AddTag("CLASSIFIED")
    inst:AddTag("pocketdimension_container")
    inst:AddTag("irreplaceable")
    inst:AddTag("npc_waxwell_magic_container")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.Network:SetClassifiedTarget(inst)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup(Store.STORE_PREFAB)
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    inst.components.container.skipautoclose = true
    inst.components.container.onanyopenfn = OnAnyOpenStorage
    inst.components.container.onanyclosefn = OnAnyCloseStorage
    Store.RegisterContainer(inst)

    if TheWorld.SetPocketDimensionContainer then
        TheWorld:SetPocketDimensionContainer(Store.STORE_NAME, inst)
    end

    return inst
end

return Prefab(Store.STORE_PREFAB, fn, assets)
