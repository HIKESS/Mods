local assets =
{
    Asset("ANIM", "anim/backpack.zip"),
    Asset("ANIM", "anim/jx_backpack_build4.zip"),
    Asset("ANIM", "anim/ui_backpack_2x4.zip"),
    Asset("ANIM", "anim/ui_piggyback_2x6.zip"),
}

local prefabs =
{
  "ash",
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "jx_backpack_build4", "swap_body")

    if inst.components.container ~= nil then
        inst.components.container:Open(owner)
    end
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    owner.AnimState:ClearOverrideSymbol("backpack")
    if inst.components.container ~= nil then
        inst.components.container:Close(owner)
    end
end

local function onequiptomodel(inst, owner, from_ground)
    if inst.components.container ~= nil then
        inst.components.container:Close(owner)
    end
end

--[[local function OnIsSummer(inst, issummer)
    if inst.components.insulator then
      local val, _ = inst.components.insulator:GetInsulation()
      if issummer then
        if val ~= 0 then
          inst.components.insulator:SetInsulation(0)
        end
      else
        if val ~= TUNING.INSULATION_TINY then
          inst.components.insulator:SetInsulation(TUNING.JX_TUNING.jx_backpack_insulator)
        end
      end
    end
end]]

local function OnSeason(inst, season)
  if inst.components.insulator then
    local val, _ = inst.components.insulator:GetInsulation()
    if season == SEASONS.SUMMER or (SEASONS.DRY ~= nil and season == SEASONS.DRY) then
      if val ~= 0 then
        inst.components.insulator:SetInsulation(0)
      end
    else
      if val ~= TUNING.JX_TUNING.jx_backpack_4_insulator then
        inst.components.insulator:SetInsulation(TUNING.JX_TUNING.jx_backpack_4_insulator)
      end
    end
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
    inst.AnimState:SetBuild("jx_backpack_build4")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("backpack")
    if TUNING.JX_TUNING.jx_backpack_4_preserver ~= false then
      inst:AddTag("fridge")
      inst:AddTag("nocool")
    end

    inst.MiniMapEntity:SetIcon("jx_backpack_4.tex")

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
    
    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.JX_TUNING.jx_backpack_4_insulator)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("jx_backpack_4")

    MakeHauntableLaunchAndDropFirstItem(inst)
    
    --inst:WatchWorldState("issummer", OnIsSummer)
    --OnIsSummer(inst, TheWorld.state.issummer)
    inst:WatchWorldState("season", OnSeason)
    OnSeason(inst, TheWorld.state.season)

    return inst
end

return Prefab("jx_backpack_4", fn, assets, prefabs)