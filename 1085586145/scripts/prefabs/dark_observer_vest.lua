local foldername=KnownModIndex:GetModActualName(TUNING.ZOMBIEJ_ADDTIONAL_PACKAGE)



local additional_building=aipGetModConfig("additional_building")
if additional_building~="open" then
return nil
end


local additional_food=aipGetModConfig("additional_food")
if additional_food~="open" then
return nil
end

local language=aipGetModConfig("language")

local LANG_MAP={
["english"]={
["NAME"]="Observer",
["DESC"]="The icon from dark observer",
["DESCRIBE"]="Following the monster",
},
["chinese"]={
["NAME"]="观察者",
["DESC"]="跟随Boss的马甲单位",
["DESCRIBE"]="紧跟着怪物",
},
["russian"]={
["NAME"]="Наблюдатель",
["DESC"]="Значок из темного наблюдателя",
["DESCRIBE"]="Вслед за монстром!",
},
}

local LANG=LANG_MAP[language] or LANG_MAP.english


STRINGS.NAMES.DARK_OBSERVER_VEST=LANG.NAME
STRINGS.RECIPE_DESC.DARK_OBSERVER_VEST=LANG.DESC
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DARK_OBSERVER_VEST=LANG.DESCRIBE


require "prefabutil"

local assets=
{



Asset("ATLAS","minimap/dark_observer_vest.xml"),
Asset("IMAGE","minimap/dark_observer_vest.tex"),
}

local prefabs=
{
--"globalmapiconunderfog",
}

local function OnInit(inst)
if not inst.__hasMaster then
inst:Remove()
end
end

local function fn()
local inst=CreateEntity()

inst.entity:AddTransform()

inst.entity:AddMiniMapEntity()
inst.entity:AddSoundEmitter()
inst.entity:AddNetwork()


inst.MiniMapEntity:SetIcon("dark_observer_vest.tex")
inst.MiniMapEntity:SetCanUseCache(false)
inst.MiniMapEntity:SetDrawOverFogOfWar(true)
inst.MiniMapEntity:SetRestriction("player")
inst.MiniMapEntity:SetPriority(10)



--inst:AddComponent("maprevealable")
--inst.components.maprevealable:SetIconPrefab("globalmapiconunderfog")
--inst.components.maprevealable:SetIcon("dark_observer_vest.tex")






inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end


inst:AddComponent("inspectable")
inst:DoTaskInTime(1,OnInit)

return inst
end

return Prefab("dark_observer_vest",fn,assets,prefabs)
