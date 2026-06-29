local _G=GLOBAL

local skinUtil=_G.require("utils/aip_skin_util")

local SKIN_CONFIGS={
_G.require("configurations/skin/aip_endless_lotus"),
_G.require("configurations/skin/aip_cozy_nest"),
_G.require("configurations/skin/aip_grandfather_clock"),
_G.require("configurations/skin/aip_lantern"),
_G.require("configurations/skin/aip_lantern_stand"),
}

for _,config in ipairs(SKIN_CONFIGS) do
skinUtil.RegisterBuildSkinConfig(config,_G.aipGetModConfig("language"))
end

local SKIN_CONFIG_BY_PREFAB={}
for _,config in ipairs(SKIN_CONFIGS) do
SKIN_CONFIG_BY_PREFAB[config.PREFAB]=config
end


local function isAipBuildSkin(prefab,skin)
local config=prefab~=nil and SKIN_CONFIG_BY_PREFAB[prefab] or nil

return skin~=nil and config~=nil and config.SKIN_INDEX[skin]~=nil
end


local function setPendingBuildSkin(builder,recipe,skin)
if recipe==nil then
return
end

builder._aipPendingBuildSkins=builder._aipPendingBuildSkins or {}

if isAipBuildSkin(recipe.product,skin) then
builder._aipPendingBuildSkins[recipe.name]=skin
else
builder._aipPendingBuildSkins[recipe.name]=nil
end
end


local function getCurrentBuildSkin(builder)
local builderComponent=builder.components~=nil and builder.components.builder or nil

return builderComponent~=nil and builderComponent._aipCurrentBuildSkin or nil
end


local function onBuildProduct(builder,data)
local skin=data~=nil and data.skin or nil

if skin==nil then
skin=getCurrentBuildSkin(builder)
end

if skin~=nil then
skinUtil.ApplyBuiltSkin({
item=data~=nil and data.item or nil,
skin=skin,
})
else
skinUtil.ApplyBuiltSkin(data)
end
end


local function patchBuilderBuildSkin()
local builderClass=_G.require("components/builder")

if builderClass._aip_build_skin_patched then
return
end

local oldMakeRecipeFromMenu=builderClass.MakeRecipeFromMenu

builderClass.MakeRecipeFromMenu=function(self,recipe,skin,...)
setPendingBuildSkin(self,recipe,skin)
return oldMakeRecipeFromMenu(self,recipe,skin,...)
end

local oldDoBuild=builderClass.DoBuild

builderClass.DoBuild=function(self,recname,pt,rotation,skin,...)
local recipe=_G.GetValidRecipe(recname)
local pendingSkin=self._aipPendingBuildSkins~=nil and
self._aipPendingBuildSkins[recname] or nil
local currentSkin=isAipBuildSkin(recipe~=nil and recipe.product or nil,skin) and
skin or pendingSkin

self._aipCurrentBuildSkin=currentSkin

local success,reason=oldDoBuild(self,recname,pt,rotation,skin,...)

self._aipCurrentBuildSkin=nil
if success and self._aipPendingBuildSkins~=nil then
self._aipPendingBuildSkins[recname]=nil
end

return success,reason
end

builderClass._aip_build_skin_patched=true
end

patchBuilderBuildSkin()

AddComponentPostInit("builder",function(self)
if _G.TheWorld==nil or not _G.TheWorld.ismastersim then
return
end


self.inst:ListenForEvent("builditem",onBuildProduct)
self.inst:ListenForEvent("buildstructure",onBuildProduct)
end)

local function patchSkinList(packageName)
local class=_G.require(packageName)
if class._aip_skin_list_patched then
return
end

local oldGetSkinsList=class.GetSkinsList
if type(oldGetSkinsList)~="function" then
return
end

class.GetSkinsList=function(self,...)
return skinUtil.AppendBuildSkins(self.recipe,oldGetSkinsList(self,...))
end

class._aip_skin_list_patched=true
end

if not _G.TheNet:IsDedicated() then
patchSkinList("widgets/recipepopup")
patchSkinList("widgets/redux/craftingmenu_skinselector")
end
