
local additional_building=aipGetModConfig("additional_building")
if additional_building~="open" then
return nil
end

local language=aipGetModConfig("language")

local LANG_MAP={
english={
NAME="Peace Sign",
RECDESC="To hold a doll fighting competition,you need to put the dolls into the field to activate the game.",
DESC="Let's have fun!",
},
chinese={
NAME="和平标识",
RECDESC="举办玩偶战斗比赛，需要将玩偶放入场地激活游戏。",
DESC="让我们玩个痛快！",
},
}

local LANG=LANG_MAP[language] or LANG_MAP.english


STRINGS.NAMES.AIP_PROTECTED_MARK=LANG.NAME
STRINGS.RECIPE_DESC.AIP_PROTECTED_MARK=LANG.RECDESC
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_PROTECTED_MARK=LANG.DESC


require "prefabutil"

local assets={
Asset("ANIM","anim/aip_protected_mark.zip"),

}

local prefabs={}



local function onhammered(inst,worker)
local fx=aipReplacePrefab(inst,"collapse_small"):SetMaterial("wood")
end






local function onbuilt(inst)
inst.AnimState:PlayAnimation("place")
inst.AnimState:PushAnimation("idle")
inst.SoundEmitter:PlaySound("dontstarve/common/chest_craft")
end


local function fn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddSoundEmitter()
inst.entity:AddMiniMapEntity()
inst.entity:AddNetwork()

inst:AddTag("structure")

inst.AnimState:SetBank("aip_protected_mark")
inst.AnimState:SetBuild("aip_protected_mark")
inst.AnimState:PlayAnimation("idle")

MakeObstaclePhysics(inst,.1)

--Dedicated server does not need deployhelper





inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end

inst:AddComponent("inspectable")

inst:AddComponent("workable")
inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
inst.components.workable:SetWorkLeft(3)
inst.components.workable:SetOnFinishCallback(onhammered)


MakeHauntableLaunch(inst)

inst:ListenForEvent("onbuilt",onbuilt)

return inst
end































return Prefab("aip_protected_mark",fn,assets,prefabs),
MakePlacer("aip_protected_mark_placer","firefighter_placement","firefighter_placement","idle")



