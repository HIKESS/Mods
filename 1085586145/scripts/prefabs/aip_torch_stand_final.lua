

local dev_mode=aipGetModConfig("dev_mode")=="enabled"


local additional_building=aipGetModConfig("additional_building")
if additional_building~="open" then return nil end

local language=aipGetModConfig("language")

local LANG_MAP={
english={
NAME="Final Monument",
REC_DESC="Empower your weapon",
DESC="This is the proof of my ability",
},
chinese={
NAME="永恒纪念碑",
REC_DESC="让你的武器获得强化",
DESC="这是我能力的证明",
}
}

local LANG=LANG_MAP[language] or LANG_MAP.english

STRINGS.NAMES.AIP_TORCH_STAND_FINAL=LANG.NAME
STRINGS.RECIPE_DESC.AIP_TORCH_STAND_FINAL=LANG.REC_DESC
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_TORCH_STAND_FINAL=LANG.DESC

local assets={
Asset("ANIM","anim/aip_torch_stand.zip"),
Asset("ATLAS","images/inventoryimages/aip_torch_stand_final.xml"),
}



local function onhammered(inst,worker)
inst.components.lootdropper:DropLoot()
local x,y,z=inst.Transform:GetWorldPosition()
local fx=SpawnPrefab("collapse_small")
fx.Transform:SetPosition(x,y,z)
fx:SetMaterial("stone")
inst:Remove()
end


local function postTypeFire(inst,fx,type)
if fx.components.firefx then
fx.components.firefx:SetLevel(2)
end

fx:AddTag("aip_rubik_fire")
fx:AddTag("aip_rubik_fire_"..type)
end


CONSTRUCTION_PLANS["aip_torch_stand_final"]={
Ingredient("furtuft",3),
Ingredient("beefalowool",1),
Ingredient("feather_canary",1),
}

local function OnConstructed(inst,doer)















if inst.components.constructionsite:IsComplete() then
for k,v in pairs(inst.components.constructionsite.materials) do
local num=inst.components.constructionsite:RemoveMaterial(k,v.amount)
end

aipFlingItem(
aipSpawnPrefab(inst,"aip_snakeoil")
)
end
end


local function fn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddSoundEmitter()
inst.entity:AddNetwork()

MakeObstaclePhysics(inst,.1)


inst.AnimState:SetBank("aip_torch_stand")
inst.AnimState:SetBuild("aip_torch_stand")
inst.AnimState:PlayAnimation("final",true)


inst:AddTag("structure")
inst:AddTag("aip_can_lighten")

inst.entity:SetPristine()

if not TheWorld.ismastersim then return inst end


inst:AddComponent("lootdropper")


inst:AddComponent("workable")
inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
inst.components.workable:SetWorkLeft(4)
inst.components.workable:SetOnFinishCallback(onhammered)


inst:AddComponent("aipc_type_fire")
inst.components.aipc_type_fire.forever=true
inst.components.aipc_type_fire.hotPrefab="aip_hot_fire"
inst.components.aipc_type_fire.coldPrefab="coldfirefire"
inst.components.aipc_type_fire.mixPrefab="aip_mix_fire"
inst.components.aipc_type_fire.followSymbol="firefx"
inst.components.aipc_type_fire.followOffset=Vector3(0,0,0)
inst.components.aipc_type_fire.postFireFn=postTypeFire

inst:AddComponent("constructionsite")
inst.components.constructionsite:SetConstructionPrefab("construction_container")
inst.components.constructionsite:SetOnConstructedFn(OnConstructed)


inst:AddComponent("inspectable")

return inst
end

return Prefab("aip_torch_stand_final",fn,assets,prefabs),
MakePlacer("aip_torch_stand_final_placer","aip_torch_stand","aip_torch_stand","final")