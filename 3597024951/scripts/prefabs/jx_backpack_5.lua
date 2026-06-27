local assets =
{
    Asset("ANIM", "anim/backpack.zip"),
    Asset("ANIM", "anim/jx_backpack_build5.zip"),
    Asset("ANIM", "anim/ui_backpack_2x4.zip"),
    Asset("ANIM", "anim/ui_piggyback_2x6.zip"),
}

local prefabs =
{
  "ash",
}

local function DoBackpackSound(inst)
  local x, y, z = inst.Transform:GetWorldPosition()
  local players = TheSim:FindEntities(x, y, z, 12, { "player" })
  for _, v in ipairs(players) do
    if v.userid then
      SendModRPCToClient(GetClientModRPC("JX", "JX_Backpack_5_DoSound"), v.userid)
    end
  end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "jx_backpack_build5", "swap_body")
    if inst.components.container ~= nil then
        inst.components.container:Open(owner)
    end
    inst:DoBackpackSound()
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    owner.AnimState:ClearOverrideSymbol("backpack")
    if inst.components.container ~= nil then
        inst.components.container:Close(owner)
    end
    inst:DoBackpackSound()
end

local function onequiptomodel(inst, owner, from_ground)
    if inst.components.container ~= nil then
        inst.components.container:Close(owner)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("backpack1")
    inst.AnimState:SetBuild("jx_backpack_build5")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("backpack")

    inst.MiniMapEntity:SetIcon("jx_backpack_5.tex")

    inst.foleysound = "dontstarve/movement/foley/backpack"

    MakeInventoryFloatable(inst, "small", 0.2, nil, nil, nil, {bank = "backpack1", anim = "anim"})

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.cangoincontainer = false

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BACKPACK or EQUIPSLOTS.BACK or EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel)
    
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("jx_backpack_5")
    
    MakeHauntableLaunchAndDropFirstItem(inst)
    
    inst.DoBackpackSound = DoBackpackSound

    return inst
end

return Prefab("jx_backpack_5", fn, assets, prefabs)