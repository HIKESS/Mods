
local additional_food=aipGetModConfig("additional_food")
if additional_food~="open" then
return nil
end


local dev_mode=aipGetModConfig("dev_mode")=="enabled"

local language=aipGetModConfig("language")

local LANG_MAP={
["english"]={
["NAME"]="Wheat",
["DESC"]="Strong in the ocean",
},
["chinese"]={
["NAME"]="小麦",
["DESC"]="它是怎么长出来的？",
},
}

local LANG=LANG_MAP[language] or LANG_MAP.english


STRINGS.NAMES.AIP_WHEAT=LANG.NAME
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_WHEAT=LANG.DESC



local assets=
{
Asset("ANIM","anim/aip_wheat.zip"),
Asset("SOUND","sound/common.fsb"),
}


local prefabs=
{
"aip_veggie_wheat",
}



local function onregenfn(inst)
inst.AnimState:PlayAnimation("grow")
inst.AnimState:PushAnimation("idle",true)
end


local function onpickedfn(inst,picker)
inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds")
inst.AnimState:PlayAnimation("picking")

inst.AnimState:PushAnimation("picked",false)


if picker~=nil and picker.components.inventory~=nil then
local loot=SpawnPrefab("cutgrass")
picker:PushEvent("picksomething",{ object=inst,loot=loot })
picker.components.inventory:GiveItem(loot,nil,inst:GetPosition())
end
end


local function makeemptyfn(inst)
inst.AnimState:PlayAnimation("picked")
end


local function dig_up(inst,worker)
if inst.components.pickable~=nil and inst.components.lootdropper~=nil then
if inst.components.pickable:CanBePicked() then
inst.components.lootdropper:SpawnLootPrefab(inst.components.pickable.product)
end


inst.components.lootdropper:SpawnLootPrefab("cutgrass")
end
inst:Remove()
end


local function wheatFn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddSoundEmitter()
inst.entity:AddMiniMapEntity()
inst.entity:AddNetwork()



inst.MiniMapEntity:SetIcon("grass.png")

inst.AnimState:SetBank("aip_wheat")
inst.AnimState:SetBuild("aip_wheat")
inst.AnimState:PlayAnimation("idle",true)

inst:AddTag("plant")

inst:AddTag("silviculture")

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end


inst.AnimState:SetTime(math.random()*2)
local color=0.75+math.random()*0.25
inst.AnimState:SetMultColour(color,color,color,1)

inst:AddComponent("pickable")
inst.components.pickable.picksound="dontstarve/wilson/pickup_reeds"

inst.components.pickable:SetUp("aip_veggie_wheat",dev_mode and 1 or TUNING.GRASS_REGROW_TIME)
inst.components.pickable.onregenfn=onregenfn
inst.components.pickable.onpickedfn=onpickedfn
inst.components.pickable.makeemptyfn=makeemptyfn







inst:AddComponent("lootdropper")
inst:AddComponent("inspectable")

inst:AddComponent("workable")
inst.components.workable:SetWorkAction(ACTIONS.DIG)
inst.components.workable:SetOnFinishCallback(dig_up)
inst.components.workable:SetWorkLeft(1)

MakeMediumBurnable(inst)
MakeSmallPropagator(inst)
MakeNoGrowInWinter(inst)
MakeHauntableIgnite(inst)

return inst
end

return Prefab("aip_wheat",wheatFn,assets,prefabs)
