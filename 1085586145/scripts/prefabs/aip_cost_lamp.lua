
local additional_weapon=aipGetModConfig("additional_weapon")
if additional_weapon~="open" then
return nil
end

local language=aipGetModConfig("language")

local LANG_MAP={
english={
NAME="Misery Lamp",
DESC="Seems lost power forever",
},
chinese={
NAME="苦难之灯",
DESC="似乎已经失去了作用",
},
}

local LANG=LANG_MAP[language] or LANG_MAP.english


local assets={
Asset("ATLAS","images/inventoryimages/aip_cost_lamp.xml"),
Asset("ANIM","anim/aip_cost_lamp_swap.zip"),
}

local prefabs={}


STRINGS.NAMES.AIP_COST_LAMP=LANG.NAME
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_COST_LAMP=LANG.DESC



local function onequip(inst,owner)
owner.AnimState:OverrideSymbol("swap_object","aip_cost_lamp_swap","aip_cost_lamp_swap")

owner.AnimState:Show("ARM_carry")
owner.AnimState:Hide("ARM_normal")

end

local function onunequip(inst,owner)
owner.AnimState:Hide("ARM_carry")
owner.AnimState:Show("ARM_normal")
end


local function fn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddSoundEmitter()
inst.entity:AddNetwork()

MakeInventoryPhysics(inst)

inst.AnimState:SetBank("aip_cost_lamp_swap")
inst.AnimState:SetBuild("aip_cost_lamp_swap")
inst.AnimState:PlayAnimation("BUILD")



MakeInventoryFloatable(inst,"med",0.2,0.65)

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end

inst:AddComponent("inspectable")

inst:AddComponent("inventoryitem")
inst.components.inventoryitem.atlasname="images/inventoryimages/aip_cost_lamp.xml"




inst:AddComponent("equippable")


















MakeHauntableLaunch(inst)

inst.components.equippable:SetOnEquip(onequip)
inst.components.equippable:SetOnUnequip(onunequip)













return inst
end

return Prefab("aip_cost_lamp",fn,assets)
